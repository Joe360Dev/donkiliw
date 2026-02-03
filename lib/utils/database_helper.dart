import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:donkiliw/database/data/thematics.dart';
import 'package:donkiliw/models/hymn_collection.dart';
import 'package:donkiliw/models/hymn_collection_join.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slugify/slugify.dart';
import 'package:sqflite/sqflite.dart';

// Import your models
import '../models/hymn_book.dart';
import '../models/hymn_theme.dart';
import '../models/hymn.dart';
import '../models/section.dart';
import '../models/phrase.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _isUpgrading = false;
  static const int currentDataVersion =
      3; // Increment this to trigger a re-import
  static const String _dataVersionKey = 'data_version';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'donkiliw_app.db');
    if (kDebugMode) print('Database path: $path');

    // Copy pre-populated database from assets if it doesn’t exist
    // Ensure directory exists
    if (!await File(path).exists()) {
      await Directory(dbPath).create(recursive: true);

      try {
        ByteData data =
            await rootBundle.load('assets/databases/donkiliw_app.db');
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        // Ensure write completes
        await File(path).writeAsBytes(bytes, flush: true);
        if (kDebugMode) print('Pre-populated database copied from assets');
      } catch (e) {
        if (kDebugMode) print('Error copying database: $e');
        // Fallback: Create an empty database if asset is missing
        return await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
      }
    }

    // Open the existing database
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    // Check if we need to refresh static data (JSON content)
    // Run this in the background to avoid blocking the app launch
    _checkDataUpgrade(db);

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute('''
    CREATE TABLE hymn_book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        publication_year INTEGER,
        language TEXT,
        UNIQUE(name, publication_year)
    )''');

    await db.execute('''
    CREATE TABLE theme (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon_name TEXT,
        description TEXT
    )''');

    await db.execute('''
    CREATE TABLE hymn (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_book_id INTEGER NOT NULL,
        book_name TEXT,
        hymn_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        first_line TEXT,
        other_reference TEXT,
        FOREIGN KEY (hymn_book_id) REFERENCES hymn_book(id)
    )''');

    await db.execute('''
    CREATE TABLE favorite_hymn (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hymn_id INTEGER NOT NULL,
      FOREIGN KEY (hymn_id) REFERENCES hymn(id) ON DELETE CASCADE
    )''');

    // hymn theme tab
    await db.execute('''
    CREATE TABLE hymn_theme (
        hymn_id INTEGER NOT NULL,
        theme_id INTEGER NOT NULL,
        PRIMARY KEY (hymn_id, theme_id),
        FOREIGN KEY (hymn_id) REFERENCES hymn(id) ON DELETE CASCADE,
        FOREIGN KEY (theme_id) REFERENCES theme(id) ON DELETE CASCADE
    )''');

    // Collections table
    await db.execute('''
    CREATE TABLE hymn_collection (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      creation_date TEXT NOT NULL
    )
    ''');

    await db.execute('''
      CREATE TABLE hymn_collection_join (
      hymn_id INTEGER NOT NULL,
      collection_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (hymn_id) REFERENCES hymn (id) ON DELETE CASCADE,
      FOREIGN KEY (collection_id) REFERENCES hymn_collection (id) ON DELETE CASCADE,
      PRIMARY KEY (hymn_id, collection_id)
    )
    ''');

    await db.execute('''
    CREATE TABLE section (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_id INTEGER NOT NULL,
        title TEXT,
        section_type TEXT CHECK(section_type IN ('title', 'verse', 'refrain')) NOT NULL,
        sequence INTEGER NOT NULL,
        FOREIGN KEY (hymn_id) REFERENCES hymn(id),
        UNIQUE(hymn_id, sequence)
    )''');

    await db.execute('''
    CREATE TABLE phrase (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        section_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        sequence INTEGER NOT NULL,
        repeat_count INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (section_id) REFERENCES section(id),
        UNIQUE(section_id, sequence)
    )''');

    await db.execute(
      'CREATE INDEX idx_hymn_number ON hymn(hymn_book_id, hymn_number)',
    );
    await db.execute(
      'CREATE INDEX idx_section_sequence ON section(hymn_id, sequence)',
    );
  }

  Future<void> _checkDataUpgrade(Database db) async {
    if (_isUpgrading) return;

    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt(_dataVersionKey) ?? 0;

    if (currentDataVersion > storedVersion) {
      _isUpgrading = true;
      try {
        debugPrint(
          'Data upgrade detected: $storedVersion -> $currentDataVersion. '
          'Starting seamless import..',
        );

        await seamlessImport(db);
        await prefs.setInt(_dataVersionKey, currentDataVersion);
      } catch (e) {
        debugPrint('Error during seamless import: $e');
      } finally {
        _isUpgrading = false;
      }
    }
  }

  Future<void> setHymnThemes([DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    for (var themeMap in thematics.entries) {
      final themeId = await insertTheme(
        HymnTheme(
          name: themeMap.key,
          iconName: '${slugify(themeMap.key, delimiter: '_')}.svg',
        ),
        executor,
      );

      if (themeId <= 0) continue;
      for (var hymnId in themeMap.value) {
        await setHymnTheme(hymnId, themeId, executor);
      }
    }

    if (kDebugMode) print('Hymn theme setting COMPLETED!');
  }

  /// Seamlessly imports new data while preserving user favorites and collections.
  Future<void> seamlessImport([Database? db]) async {
    final activeDb = db ?? await database;

    // 1. Backup User Data (Favorites and Collections)
    final backup = await _backupUserData(activeDb);

    // 2. Clear static data and re-import within a SINGLE transaction
    await activeDb.transaction((txn) async {
      // Clear static data tables
      await txn.execute('DELETE FROM phrase');
      await txn.execute('DELETE FROM section');
      await txn.execute('DELETE FROM hymn_theme');
      await txn.execute('DELETE FROM theme');
      await txn.execute('DELETE FROM hymn_collection_join');
      await txn.execute('DELETE FROM hymn');
      await txn.execute('DELETE FROM hymn_book');

      // Reset sequences for clean AUTOINCREMENT from 1
      await txn.execute("DELETE FROM sqlite_sequence WHERE name='hymn'");
      await txn.execute("DELETE FROM sqlite_sequence WHERE name='hymn_book'");
      await txn.execute("DELETE FROM sqlite_sequence WHERE name='section'");
      await txn.execute("DELETE FROM sqlite_sequence WHERE name='phrase'");
      await txn.execute("DELETE FROM sqlite_sequence WHERE name='theme'");

      // 3. Re-import everything from JSON within the SAME transaction
      await importHymnsFromJson(txn);
      await setHymnThemes(txn);

      // 4. Restore User Data by matching Books, Numbers, and Titles
      await _restoreUserData(txn, backup);
    });

    if (kDebugMode) print('Seamless Import COMPLETED!');
  }

  Future<Map<String, dynamic>> _backupUserData(DatabaseExecutor db) async {
    // Backup Favorites
    final favorites = await db.rawQuery('''
      SELECT hb.name AS book_name, h.hymn_number, h.title 
      FROM favorite_hymn f
      JOIN hymn h ON f.hymn_id = h.id
      JOIN hymn_book hb ON h.hymn_book_id = hb.id
    ''');

    // Backup Collections
    final collectionJoins = await db.rawQuery('''
      SELECT hcj.collection_id, hb.name AS book_name, h.hymn_number, h.title, hcj.order_index
      FROM hymn_collection_join hcj
      JOIN hymn h ON hcj.hymn_id = h.id
      JOIN hymn_book hb ON h.hymn_book_id = hb.id
    ''');

    return {
      'favorites': favorites,
      'collectionJoins': collectionJoins,
    };
  }

  Future<void> _restoreUserData(
      DatabaseExecutor db, Map<String, dynamic> backup) async {
    final List<Map<String, dynamic>> favorites = backup['favorites'];
    final List<Map<String, dynamic>> collectionJoins =
        backup['collectionJoins'];

    // Restore Favorites
    // We clear the old table because IDs might have changed
    await db.execute('DELETE FROM favorite_hymn');
    for (var fav in favorites) {
      final newHymnId = await _findNewHymnId(
        db,
        fav['book_name'],
        fav['hymn_number'],
        fav['title'],
      );
      if (newHymnId != null) {
        await db.insert('favorite_hymn', {'hymn_id': newHymnId});
      }
    }

    // Restore Collection Joins
    // Note: hymn_collection_join was already deleted in seamlessImport
    for (var join in collectionJoins) {
      final newHymnId = await _findNewHymnId(
        db,
        join['book_name'],
        join['hymn_number'],
        join['title'],
      );
      if (newHymnId != null) {
        await db.insert('hymn_collection_join', {
          'hymn_id': newHymnId,
          'collection_id': join['collection_id'],
          'order_index': join['order_index'],
        });
      }
    }
  }

  Future<int?> _findNewHymnId(
      DatabaseExecutor db, String bookName, int number, String title) async {
    final results = await db.rawQuery('''
      SELECT h.id FROM hymn h
      JOIN hymn_book hb ON h.hymn_book_id = hb.id
      WHERE hb.name = ? AND h.hymn_number = ? AND h.title = ?
    ''', [bookName, number, title]);

    if (results.isNotEmpty) {
      return results.first['id'] as int;
    }
    return null;
  }

  Future<void> importHymnsFromJson([DatabaseExecutor? db]) async {
    final executor = db ?? await database;

    final hymnBookFiles = [
      {
        'book_name': 'Beti Coura',
        'path': 'assets/json_books/betiba_v2.json',
      },
      {
        'book_name': 'Ala Tanu Donkiliw Nº1',
        'path': 'assets/json_books/ala_tanu_donkiliw_1_v2.json',
      },
      {
        'book_name': 'Ala Tanu Donkiliw Nº2',
        'path': 'assets/json_books/ala_tanu_donkiliw_2_v2.json',
      },
      {
        'book_name': 'Nii Don Diyɛ',
        'path': 'assets/json_books/nii_don_v2.json',
      },
    ];

    final repeatCountRegex = RegExp(r'\((\d+)x\)', unicode: true);
    final cleanRegex = RegExp(r'^[:\s]*|[:\s]*$', unicode: true);

    for (var bookFile in hymnBookFiles) {
      final bookName = bookFile['book_name'] as String;
      final List<Map<String, dynamic>> data =
          await jsonToHymnBookData(bookFile['path'] as String);

      final hymnBookId = await insertHymnBook(
        HymnBook(name: bookName),
        executor,
      );

      for (var jsonHymn in data) {
        final hymnNumber = jsonHymn['hymn_number'] as int;
        final List<dynamic> content = jsonHymn['content'];

        List<Map<String, String>> currentHymnSections = [];
        String? currentHymnTitle;
        String? otherReference;

        for (var rawSection in content) {
          final section = Map<String, String>.from(rawSection);
          if (section.containsKey('autrepassage')) {
            otherReference = section['autrepassage'];
            continue;
          }
          if (section.containsKey('titre')) {
            currentHymnTitle = section['titre'];
          }
          currentHymnSections.add(section);
        }

        if (currentHymnSections.isNotEmpty) {
          await _processAndInsertHymn(
            executor,
            hymnBookId,
            bookName,
            hymnNumber,
            currentHymnTitle ?? 'Untitled',
            currentHymnSections,
            repeatCountRegex,
            cleanRegex,
            otherReference,
          );
        }
      }
    }
    if (kDebugMode) print('Hymn Import COMPLETED!');
  }

  Future<void> _processAndInsertHymn(
    DatabaseExecutor db,
    int hymnBookId,
    String bookName,
    int hymnNumber,
    String title,
    List<Map<String, String>> sections,
    RegExp repeatCountRegex,
    RegExp cleanRegex,
    String? otherReference,
  ) async {
    // Determine first line
    String? firstLine;
    for (var section in sections) {
      if (section.containsKey('couple') || section.containsKey('refrain')) {
        firstLine = section.values.first
            .split('\n')
            .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '')
            .replaceAll(cleanRegex, '');
        if (firstLine.isNotEmpty) break;
      }
    }

    String finalTitle = title;
    if (bookName == 'Nii Don Diyɛ') {
      finalTitle = title.replaceFirst(RegExp(r'^\d+[\.\s]+'), '').trim();
    }

    final hymn = Hymn(
      hymnBookId: hymnBookId,
      bookName: bookName,
      number: hymnNumber,
      title: finalTitle,
      firstLine: firstLine,
      otherReference: otherReference,
    );

    final hymnId = await insertHymn(hymn, db);

    // Insert sections with their phrases using a single batch if possible,
    // but here we need the sectionId for phrases, so we stick to simpler sequential for now or nested batches.
    // Optimization: Wrapped in the caller's transaction is enough for massive performance.

    String? previousRefrain;
    int sequence = 1;

    for (var jsonSection in sections) {
      final sectionType = jsonSection.containsKey('titre')
          ? 'title'
          : jsonSection.containsKey('couple')
              ? 'verse'
              : 'refrain';

      if (sectionType == 'refrain' &&
          jsonSection.values.first == previousRefrain) {
        continue;
      } else if (sectionType == 'refrain') {
        previousRefrain = jsonSection.values.first;
      }

      final sectionId = await insertSection(
        Section(
          hymnId: hymnId,
          title: jsonSection.containsKey('titre') ? jsonSection['titre'] : null,
          sectionType: sectionType,
          sequence: sequence++,
        ),
        db,
      );

      final jsonPhrases = jsonSection.values.first.split('\n');
      int phraseSequence = 1;

      for (var jsonPhrase in jsonPhrases) {
        if (jsonPhrase.trim().isEmpty) continue;

        int repeatCount = 1;
        final match = repeatCountRegex.firstMatch(jsonPhrase);
        if (match != null) {
          repeatCount = int.parse(match.group(1)!);
        }

        String cleanedPhrase = jsonPhrase
            .trim()
            .replaceAll(repeatCountRegex, '')
            .replaceAll(cleanRegex, '')
            .trim();

        if (cleanedPhrase.isNotEmpty) {
          await insertPhrase(
            Phrase(
              sectionId: sectionId,
              content: cleanedPhrase,
              sequence: phraseSequence++,
              repeatCount: repeatCount,
            ),
            db,
          );
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> jsonToHymnBookData(String filePath) async {
    // Load JSON from assets
    final jsonString = await rootBundle.loadString(filePath);
    final List<dynamic> jsonData = jsonDecode(jsonString);

    return List<Map<String, dynamic>>.from(jsonData);
  }

  // Reset the database
  Future<void> resetDatabase() async {
    final db = await database;

    // Drop all tables
    await db.execute('DROP TABLE IF EXISTS phrase');
    await db.execute('DROP TABLE IF EXISTS section');
    await db.execute('DROP TABLE IF EXISTS hymn_theme');
    await db.execute('DROP TABLE IF EXISTS theme');
    await db.execute('DROP TABLE IF EXISTS hymn');
    await db.execute('DROP TABLE IF EXISTS hymn_book');
    await db.execute('DROP TABLE IF EXISTS favorite_hymn');
    await db.execute('DROP TABLE IF EXISTS hymn_collection_join');
    await db.execute('DROP TABLE IF EXISTS hymn_collection');

    // Recreate all tables
    await _onCreate(db, 1);

    if (kDebugMode) print('DB reset DONE!');
  }

  Future<Map<String, List<Hymn>>> searchHymns(String query) async {
    final db = await database;
    final lowerQuery = query.toLowerCase().trim();

    final results = await db.rawQuery(
      '''
    SELECT DISTINCT h.*, hb.name AS book_name
    FROM hymn h
    LEFT JOIN hymn_book hb ON h.hymn_book_id = hb.id
    LEFT JOIN section s ON s.hymn_id = h.id
    LEFT JOIN phrase p ON p.section_id = s.id
    WHERE LOWER(h.title) LIKE ? 
       OR LOWER(h.first_line) LIKE ? 
       OR LOWER(h.other_reference) LIKE ?
       OR LOWER(p.content) LIKE ?
    ORDER BY id
    ''',
      ['%$lowerQuery%', '%$lowerQuery%', '%$lowerQuery%', '%$lowerQuery%'],
    );

    final groupedHymns = <String, List<Hymn>>{};
    final hymnIdsByBook = <String, Set<int>>{};

    for (var row in results) {
      final hymnId = row['id'] as int;
      final bookName = row['book_name'] as String? ?? 'Autres';

      groupedHymns.putIfAbsent(bookName, () => []);
      hymnIdsByBook.putIfAbsent(bookName, () => <int>{});

      if (!hymnIdsByBook[bookName]!.contains(hymnId)) {
        final hymn = Hymn.fromMap(row);
        groupedHymns[bookName]!.add(hymn);
        hymnIdsByBook[bookName]!.add(hymnId);
      }
    }

    return groupedHymns;
  }

  // HymnBook Methods
  Future<int> insertHymnBook(HymnBook hymnBook, [DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    return await executor.insert('hymn_book', hymnBook.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HymnBook>> getHymnBooks() async {
    final db = await database;
    final maps = await db.query('hymn_book');
    return List.generate(maps.length, (i) => HymnBook.fromMap(maps[i]));
  }

  Future<HymnBook> getHymnBook(int id) async {
    final db = await database;
    final maps = await db.query('hymn_book', where: 'id = ?', whereArgs: [id]);
    return HymnBook.fromMap(maps.first);
  }

  // Theme Methods
  Future<int> insertTheme(HymnTheme theme, [DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    return await executor.insert(
      'theme',
      theme.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // hymn theme methods
  Future<List<HymnTheme>> getHymnThemes() async {
    final db = await database;
    final maps = await db.query('theme');
    return List.generate(
      maps.length,
      (i) => HymnTheme.fromMap(maps[i]),
    );
  }

  // set theme for hymn
  Future<void> setHymnTheme(int hymnId, int themeId,
      [DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    await executor.insert(
      'hymn_theme',
      {'hymn_id': hymnId, 'theme_id': themeId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Hymn>> getHymnsByTheme(int themeId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT h.id AS hymn_id, h.title AS hymn_title, 
           h.hymn_book_id, h.book_name, h.hymn_number, h.first_line
    FROM hymn h
    INNER JOIN hymn_theme ht ON h.id = ht.hymn_id
    WHERE ht.theme_id = ?
    ORDER BY h.hymn_number ASC
  ''', [themeId]);

    return result
        .map((row) => Hymn(
              id: row['hymn_id'] as int,
              title: row['hymn_title'] as String,
              hymnBookId: row['hymn_book_id'] as int,
              bookName: row['book_name'] as String,
              number: row['hymn_number'] as int,
              firstLine: row['first_line'] as String?,
            ))
        .toList();
  }

  // Hymn Methods
  Future<int> insertHymn(Hymn hymn, [DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    return await executor.insert(
      'hymn',
      hymn.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // get hymns
  Future<Map<String, List<Hymn>>> getHymns() async {
    final db = await database;

    final results = await db.rawQuery(
      '''
    SELECT h.*, hb.name AS book_name
    FROM hymn h
    LEFT JOIN hymn_book hb ON h.hymn_book_id = hb.id
    ORDER BY hb.id, h.hymn_number
    ''',
    );

    final groupedHymns = <String, List<Hymn>>{};
    final hymnIdsByBook = <String, Set<int>>{};

    for (var row in results) {
      final hymnId = row['id'] as int;
      final bookName = row['book_name'] as String? ?? 'Autres';

      groupedHymns.putIfAbsent(bookName, () => []);
      hymnIdsByBook.putIfAbsent(bookName, () => <int>{});

      if (!hymnIdsByBook[bookName]!.contains(hymnId)) {
        final hymn = Hymn.fromMap(row);
        groupedHymns[bookName]!.add(hymn);
        hymnIdsByBook[bookName]!.add(hymnId);
      }
    }

    return groupedHymns;
  }

  Future<Hymn> getHymnData(int hymnId) async {
    final db = await database;
    final hymnMaps = await db.query(
      'hymn',
      where: 'id = ?',
      whereArgs: [hymnId],
    );
    final isLiked = await db.query(
      'favorite_hymn',
      where: 'hymn_id = ?',
      whereArgs: [hymnId],
    ).then((map) => map.isNotEmpty);

    final hymn = Hymn.fromMap(
      hymnMaps.first,
      isLiked: isLiked,
    );
    final sectionMaps = await db.query(
      'section',
      where: 'hymn_id = ?',
      whereArgs: [hymnId],
    );

    for (var sectionMap in sectionMaps) {
      final section = Section.fromMap(sectionMap);

      final phraseMaps = await db.query(
        'phrase',
        where: 'section_id = ?',
        whereArgs: [section.id],
      );

      section.phrases = List.generate(
        phraseMaps.length,
        (index) => Phrase.fromMap(
          phraseMaps[index],
        ),
      );
      hymn.sections.add(section);
    }

    return hymn;
  }

  Future<int> updateHymnFirstLine(int hymnId, String firstLine) async {
    final db = await database;
    return await db.update(
      'hymn',
      {'first_line': firstLine},
      where: 'id = ?',
      whereArgs: [hymnId],
    );
  }

  Future<List<Hymn>> getHymnsByNumber(int bookId, int number) async {
    final db = await database;
    final results = await db.query(
      'hymn',
      where: 'hymn_book_id = ? AND hymn_number = ?',
      whereArgs: [bookId, number],
      orderBy: 'id ASC',
    );

    final List<Hymn> hymns = [];
    for (var row in results) {
      hymns.add(await getHymnData(row['id'] as int));
    }
    return hymns;
  }

  Future<List<Hymn>> getHymnsByBook(int bookId) async {
    final db = await database;

    // Query hymns for the given book
    final maps = await db.query(
      'hymn',
      where: 'hymn_book_id = ?',
      whereArgs: [bookId],
    );

    final likedHymnIds = await getFavoriteHymnIds();

    return List.generate(maps.length, (i) {
      final hymnMap = maps[i];
      final hymnId = hymnMap['id'] as int;
      return Hymn.fromMap(
        hymnMap,
        isLiked: likedHymnIds.contains(hymnId),
      );
    });
  }

  // hymn like methods
  Future<void> toggleHymnLike(int hymnId, bool isCurrentlyLiked) async {
    if (isCurrentlyLiked) {
      await unlikeHymn(hymnId);
    } else {
      await likeHymn(hymnId);
    }
  }

  Future<void> likeHymn(int hymnId) async {
    final db = await database;
    await db.insert(
      'favorite_hymn',
      {'hymn_id': hymnId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> unlikeHymn(int hymnId) async {
    final db = await database;
    await db.delete(
      'favorite_hymn',
      where: 'hymn_id = ?',
      whereArgs: [hymnId],
    );
  }

  Future<List<int>> getFavoriteHymnIds() async {
    final db = await database;
    final maps = await db.query(
      'favorite_hymn',
      columns: ['hymn_id'],
    );
    return maps.map((m) => m['hymn_id'] as int).toList();
  }

  Future<List<Hymn>> getFavoriteHymns() async {
    final db = await database;
    final maps = await db.rawQuery(
      '''SELECT h.* FROM hymn h 
      INNER JOIN favorite_hymn f 
      ON h.id = f.hymn_id''',
    );

    return List.generate(maps.length, (i) {
      return Hymn.fromMap(
        maps[i],
        isLiked: true,
      );
    });
  }

  // HymnCollection CRUD
  Future<HymnCollection> createCollection(HymnCollection collection) async {
    final db = await database;
    final id = await db.insert('hymn_collection', collection.toMap());
    return collection.copyWith(
      id: id,
      title: collection.title,
      description: collection.description,
      creationDate: collection.creationDate,
    );
  }

  Future<List<HymnCollection>> getAllCollections() async {
    final db = await database;
    final result = await db.query(
      'hymn_collection',
      orderBy: 'creation_date ASC',
    );
    return result.map((json) => HymnCollection.fromMap(json)).toList();
  }

  Future<List<HymnCollection>> getCollectionsData() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT hc.*, h.id AS hymn_id, h.title AS hymn_title, h.hymn_book_id, h.book_name, h.hymn_number, h.first_line, h.other_reference
      FROM hymn_collection hc
      LEFT JOIN hymn_collection_join hcj ON hc.id = hcj.collection_id
      LEFT JOIN hymn h ON hcj.hymn_id = h.id
      ORDER BY hc.creation_date DESC, hcj.order_index ASC
    ''');

    // Group hymns by collection
    final Map<int, HymnCollection> collectionMap = {};

    for (final row in result) {
      final collectionId = row['id'] as int;

      if (!collectionMap.containsKey(collectionId)) {
        final hymnCollection = HymnCollection(
          id: collectionId,
          title: row['title'] as String,
          description: row['description'] as String?,
        );
        hymnCollection.creationDate = DateTime.parse(
          row['creation_date'] as String,
        );
        collectionMap[collectionId] = hymnCollection;
      }

      if (row['hymn_id'] != null) {
        collectionMap[collectionId]!.hymns.add(
              Hymn(
                id: row['hymn_id'] as int,
                title: row['hymn_title'] as String,
                hymnBookId: row['hymn_book_id'] as int,
                bookName: row['book_name'] as String,
                number: row['hymn_number'] as int,
                firstLine: row['first_line'] as String?,
                otherReference: row['other_reference'] as String?,
              ),
            );
      }
    }
    return collectionMap.values.toList();
  }

  Future<HymnCollection> getHymnByCollection(int collectionId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''SELECT hc.*, h.id AS hymn_id, h.title AS hymn_title, h.hymn_book_id, h.book_name, h.hymn_number, h.first_line, h.other_reference
        FROM hymn_collection hc
        LEFT JOIN hymn_collection_join hcj ON hc.id = hcj.collection_id
        LEFT JOIN hymn h ON hcj.hymn_id = h.id
        WHERE hc.id = ?
        ORDER BY hcj.order_index ASC''',
      [collectionId],
    );

    if (result.isEmpty) {
      throw Exception('Collection with ID $collectionId not found');
    }

    final hymnCollection = HymnCollection(
      id: result.first['id'] as int,
      title: result.first['title'] as String,
      description: result.first['description'] as String?,
    );

    hymnCollection.creationDate = DateTime.parse(
      result.first['creation_date'] as String,
    );

    for (final row in result) {
      if (row['hymn_id'] != null) {
        hymnCollection.hymns.add(
          Hymn(
            id: row['hymn_id'] as int,
            title: row['hymn_title'] as String,
            hymnBookId: row['hymn_book_id'] as int,
            bookName: row['book_name'] as String,
            number: row['hymn_number'] as int,
            firstLine: row['first_line'] as String?,
            otherReference: row['other_reference'] as String?,
          ),
        );
      }
    }

    return hymnCollection;
  }

  Future<HymnCollection> saveCollectionChanges(
      HymnCollection collection) async {
    final db = await database;
    int collectionId = collection.id ?? 0;
    if (collection.id != null) {
      await db.update(
        'hymn_collection',
        collection.toMap(),
        where: 'id = ?',
        whereArgs: [collection.id],
      );
    } else {
      collectionId = await db.insert(
        'hymn_collection',
        collection.toMap(),
      );
    }

    final maps = collectionId > 0
        ? await db.query(
            'hymn_collection',
            where: 'id = ?',
            whereArgs: [collectionId],
          )
        : null;
    final result = maps != null
        ? HymnCollection.fromMap(
            maps.first,
          )
        : collection;
    return result;
  }

  Future<void> deleteCollection(int id) async {
    final db = await database;
    await db.delete(
      'hymn_collection',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Junction Table Operations
  Future<void> addHymnToCollection(int hymnId, int collectionId) async {
    final db = await database;

    // Get the current maximum order_index for this collection
    final result = await db.rawQuery(
      'SELECT MAX(order_index) as max_index FROM hymn_collection_join WHERE collection_id = ?',
      [collectionId],
    );
    int nextIndex = 0;
    if (result.isNotEmpty && result.first['max_index'] != null) {
      nextIndex = (result.first['max_index'] as int) + 1;
    }

    await db.insert(
      'hymn_collection_join',
      HymnCollectionJoin(
        hymnId: hymnId,
        collectionId: collectionId,
        orderIndex: nextIndex,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeHymnFromCollection(int hymnId, int collectionId) async {
    final db = await database;
    await db.delete(
      'hymn_collection_join',
      where: 'hymn_id = ? AND collection_id = ?',
      whereArgs: [hymnId, collectionId],
    );
  }

  Future<List<Hymn>> getHymnsByCollection(int collectionId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT h.* FROM hymn h
      INNER JOIN hymn_collection_join hcj ON h.id = hcj.hymn_id
      WHERE hcj.collection_id = ?
      ORDER BY hcj.order_index ASC
    ''', [collectionId]);
    return result.map((json) => Hymn.fromMap(json)).toList();
  }

  Future<void> reorderHymnsInCollection(
    int collectionId,
    List<Hymn> hymns,
  ) async {
    final db = await database;
    for (int i = 0; i < hymns.length; i++) {
      await db.update(
        'hymn_collection_join',
        {'order_index': i},
        where: 'hymn_id = ? AND collection_id = ?',
        whereArgs: [hymns[i].id!, collectionId],
      );
    }
  }

  // hymn section methods
  Future<int> insertSection(Section section, [DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    return await executor.insert('section', section.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Section>> getSectionsByHymn(int hymnId) async {
    final db = await database;
    final maps = await db.query(
      'section',
      where: ' hymn_id = ?',
      whereArgs: [hymnId],
    );
    return List.generate(
      maps.length,
      (i) => Section.fromMap(maps[i]),
    );
  }

// Phrase Methods
  Future<int> insertPhrase(Phrase phrase, [DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    return await executor.insert('phrase', phrase.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Phrase>> getPhrases() async {
    final db = await database;
    final maps = await db.query('phrase');
    return List.generate(maps.length, (i) => Phrase.fromMap(maps[i]));
  }

  Future<List<Phrase>> getPhrasesBySection(int sectionId) async {
    final db = await database;
    final maps = await db.query(
      'phrase',
      where: 'section_id = ?',
      whereArgs: [sectionId],
    );
    return List.generate(maps.length, (i) => Phrase.fromMap(maps[i]));
  }
}
