import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hymns/database/data/thematics.dart';
import 'package:hymns/models/hymn_collection.dart';
import 'package:hymns/models/hymn_collection_join.dart';
import 'package:path/path.dart';
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
        ByteData data = await rootBundle.load('assets/databases/hymn_app.db');
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
    // Only runs if the database is newly created (rare case)
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
        FOREIGN KEY (hymn_book_id) REFERENCES hymn_book(id),
        UNIQUE(hymn_book_id, hymn_number)
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

  Future<void> setHymnThemes() async {
    final dbHelper = DatabaseHelper();
    for (var themeMap in thematics.entries) {
      dbHelper
          .insertTheme(HymnTheme(
        name: themeMap.key,
        iconName: '${slugify(themeMap.key, delimiter: '_')}.svg',
      ))
          .then(
        (themeId) {
          if (themeId <= 0) return;
          for (var hymnId in themeMap.value) {
            dbHelper.setHymnTheme(hymnId, themeId);
          }
        },
      );
    }

    if (kDebugMode) print('Hymn theme setting COMPLETED!');
  }

  Future<void> importHymnsFromJson() async {
    final dbHelper = DatabaseHelper();

    final hymnBookFiles = [
      {
        'book_name': 'Beti Coura',
        'data': await jsonToHymnBookData('assets/json_books/betiba.json'),
      },
      {
        'book_name': 'Ala Tanu Donkiliw Nº1',
        'data': await jsonToHymnBookData(
            'assets/json_books/ala_tanu_donkiliw_1.json'),
      },
      {
        'book_name': 'Ala Tanu Donkiliw Nº2',
        'data': await jsonToHymnBookData(
            'assets/json_books/ala_tanu_donkiliw_2.json'),
      },
    ];

    // Regex to extract repeat count like (6x), Unicode-safe
    final repeatCountRegex = RegExp(r'\((\d+)x\)', unicode: true);

    // Regex to remove leading/trailing colons and spaces, preserving Bamanakan characters
    final cleanRegex = RegExp(r'^[:\s]*|[:\s]*$', unicode: true);

    for (var bookFile in hymnBookFiles) {
      final bookName = bookFile['book_name'] as String;
      final List<List<Map<String, String>>> jsonBook =
          bookFile['data'] as List<List<Map<String, String>>>;

      // Insert the hymn book
      final hymnBookId = await dbHelper.insertHymnBook(
        HymnBook(name: bookName),
      );

      int hymnNumber = 1;

      for (var jsonHymn in jsonBook) {
        // Extract title
        final titleSection = jsonHymn.firstWhere(
            (jsonSection) => jsonSection.containsKey('titre'),
            orElse: () => {'titre': 'Untitled $hymnNumber'});
        final sectionFirst = jsonHymn.firstWhere(
          (jsonSection) =>
              jsonSection.containsKey('couple') ||
              jsonSection.containsKey('refrain'),
          orElse: () => {'couple': ''},
        );

        final hymn = Hymn(
          hymnBookId: hymnBookId,
          bookName: bookName,
          number: hymnNumber,
          title: titleSection['titre']!,
          firstLine: sectionFirst[
                  sectionFirst.containsKey('couple') ? 'couple' : 'refrain']
              ?.split('\n')
              .first
              .replaceAll(cleanRegex, ''),
        );

        final hymnId = await dbHelper.insertHymn(hymn);

        // Insert sections
        String? previousRefrain;
        for (var jsonSection in jsonHymn) {
          if (jsonSection['titre'] == null &&
              jsonSection['couple'] == null &&
              jsonSection['refrain'] == null) {
            continue;
          }

          final section = Section(
            hymnId: hymnId,
            title:
                jsonSection.containsKey('titre') ? jsonSection['titre'] : null,
            sectionType: jsonSection.containsKey('titre')
                ? 'title'
                : jsonSection.containsKey('couple')
                    ? 'verse'
                    : 'refrain',
            sequence: jsonHymn.indexOf(jsonSection) + 1,
          );

          if (section.sectionType == 'refrain' &&
              jsonSection.values.first == previousRefrain) {
            continue;
          } else if (section.sectionType == 'refrain') {
            previousRefrain = jsonSection.values.first;
          }

          final sectionId = await dbHelper.insertSection(section);

          // Split and clean phrases
          final jsonPhrases = jsonSection.values.first.split('\n');
          int sequence = 1;

          for (var jsonPhrase in jsonPhrases) {
            if (jsonPhrase.trim().isEmpty) continue;

            // Extract repeat count
            int repeatCount = 1;
            final match = repeatCountRegex.firstMatch(jsonPhrase);
            if (match != null) {
              repeatCount = int.parse(match.group(1)!);
            }

            // Clean the phrase, preserving Bamanakan characters
            String cleanedPhrase = jsonPhrase
                .trim()
                .replaceAll(repeatCountRegex, '')
                .replaceAll(cleanRegex, '')
                .trim();

            if (cleanedPhrase.isNotEmpty) {
              final phrase = Phrase(
                sectionId: sectionId,
                content: cleanedPhrase,
                sequence: sequence++,
                repeatCount: repeatCount,
              );
              await dbHelper.insertPhrase(phrase);
            }
          }
        }
        hymnNumber++;
      }
    }
    if (kDebugMode) print('Hymn Import COMPLETED!');
  }

  Future<List<List<Map<String, String>>>> jsonToHymnBookData(
      String filePath) async {
    // Load JSON from assets
    final jsonString = await rootBundle.loadString(filePath);
    final List<dynamic> jsonData = jsonDecode(jsonString);

    // Flatten the nested structure into a list of maps
    final List<List<Map<String, String>>> book = [];

    for (var jsonHymn in jsonData) {
      final List<Map<String, String>> jsonSections = [];
      for (var jsonSection in jsonHymn) {
        // Each item is a Map with one key-value pair
        jsonSection.forEach((key, value) {
          jsonSections.add({key: value as String});
        });
      }
      book.add(jsonSections);
    }

    return book;
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
       OR LOWER(p.content) LIKE ?
    ORDER BY id
    ''',
      ['%$lowerQuery%', '%$lowerQuery%', '%$lowerQuery%'],
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
  Future<int> insertHymnBook(HymnBook hymnBook) async {
    final db = await database;
    return await db.insert('hymn_book', hymnBook.toMap(),
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
  Future<int> insertTheme(HymnTheme theme) async {
    final db = await database;
    return await db.insert(
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
  Future<void> setHymnTheme(int hymnId, int themeId) async {
    final db = await database;
    await db.insert(
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
  Future<int> insertHymn(Hymn hymn) async {
    final db = await database;
    return await db.insert(
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
    ).then((maps) => maps.isNotEmpty);

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
  Future<void> toggleHymnLike(Hymn hymn) async {
    final hymnId = hymn.id!;
    if (hymn.isLiked) {
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
      SELECT hc.*, h.id AS hymn_id, h.title AS hymn_title, h.hymn_book_id, h.book_name, h.hymn_number, h.first_line
      FROM hymn_collection hc
      LEFT JOIN hymn_collection_join hcj ON hc.id = hcj.collection_id
      LEFT JOIN hymn h ON hcj.hymn_id = h.id
      ORDER BY hc.creation_date DESC
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
              ),
            );
      }
    }
    return collectionMap.values.toList();
  }

  Future<HymnCollection> getHymnByCollection(int collectionId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''SELECT hc.*, h.id AS hymn_id, h.title AS hymn_title, h.hymn_book_id, h.book_name, h.hymn_number, h.first_line
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
    await db.insert(
      'hymn_collection_join',
      HymnCollectionJoin(
        hymnId: hymnId,
        collectionId: collectionId,
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
  Future<int> insertSection(Section section) async {
    final db = await database;
    return await db.insert('section', section.toMap(),
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
  Future<int> insertPhrase(Phrase phrase) async {
    final db = await database;
    return await db.insert('phrase', phrase.toMap(),
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
