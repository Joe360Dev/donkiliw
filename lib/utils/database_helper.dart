import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:donkiliw/models/hymn_theme.dart';
import 'package:donkiliw/models/hymn.dart';
import 'package:donkiliw/models/hymn_book.dart';
import 'package:donkiliw/models/section.dart';
import 'package:donkiliw/models/phrase.dart';
import 'package:donkiliw/models/hymn_collection.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _staticDbName = 'donkiliw_static.db';
  static const String _userDbName = 'donkiliw_user.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final staticPath = join(dbPath, _staticDbName);
    final userPath = join(dbPath, _userDbName);

    final oldPath = join(dbPath, 'donkiliw_app.db');

    debugPrint('Static DB path: $staticPath');
    debugPrint('User DB path: $userPath');
    debugPrint('Old DB path: $oldPath');

    if (await File(oldPath).exists()) {
      await File(oldPath).delete();
    }

    // 1. Ensure User Database exists with correct schema
    final userDbInitial = await openDatabase(
      userPath,
      version: 1,
      onCreate: _onUserDbCreate,
    );
    await userDbInitial.close();

    // Check if app version has changed to update static DB
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentAppVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final lastDbVersion = prefs.getString('static_db_version');

    if (lastDbVersion != currentAppVersion) {
      debugPrint('App version changed ($lastDbVersion -> $currentAppVersion). Updating static DB.');
      if (await File(staticPath).exists()) {
        await File(staticPath).delete();
      }
      await prefs.setString('static_db_version', currentAppVersion);
    }

    // 2. Handle Static Database (Hymns)
    if (!await File(staticPath).exists()) {
      await _copyStaticDbFromAssets(staticPath);
    }

    // 3. Open Static Database and ATTACH User Database
    final db = await openDatabase(staticPath);

    // Check if user_db is already attached (prevents error on hot restart)
    final List<Map<String, dynamic>> databases =
        await db.rawQuery('PRAGMA database_list');
    if (kDebugMode) {
      debugPrint('Current databases attached: $databases');
    }

    final bool isAlreadyAttached =
        databases.any((database) => database['name'] == 'user_db');

    if (!isAlreadyAttached) {
      try {
        debugPrint('Attaching user database...');
        await db.execute("ATTACH DATABASE '$userPath' AS user_db");
      } catch (e) {
        // Double check the error message
        if (e.toString().contains('already in use')) {
          debugPrint(
              'User database was already attached (detected via catch).');
        } else {
          debugPrint('Error attaching user database: $e');
        }
      }
    } else {
      debugPrint('User database already attached (detected via PRAGMA).');
    }

    return db;
  }

  Future<void> _copyStaticDbFromAssets(String path) async {
    try {
      ByteData data = await rootBundle.load('assets/databases/$_staticDbName');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
      debugPrint('Static database copied from assets');
    } catch (e) {
      debugPrint('Error copying static database: $e');
      // If asset is missing, we might need to build it from JSON
      // but the user said it should be pre-populated.
    }
  }

  Future<void> _onUserDbCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hymn_collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        creation_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorite_hymn (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_name TEXT NOT NULL,
        hymn_number INTEGER NOT NULL,
        UNIQUE(book_name, hymn_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE hymn_collection_join (
        collection_id INTEGER NOT NULL,
        book_name TEXT NOT NULL,
        hymn_number INTEGER NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (collection_id) REFERENCES hymn_collection (id) ON DELETE CASCADE,
        PRIMARY KEY (collection_id, book_name, hymn_number)
      )
    ''');
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

    if (hymnMaps.isEmpty) throw Exception('Hymn $hymnId not found');
    final hymnRow = hymnMaps.first;

    final isLiked = await db.query(
      'user_db.favorite_hymn',
      where: 'book_name = ? AND hymn_number = ?',
      whereArgs: [hymnRow['book_name'], hymnRow['hymn_number']],
    ).then((map) => map.isNotEmpty);

    final hymn = Hymn.fromMap(
      hymnRow,
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

    // Join with favorite_hymn using stable keys from user_db
    final results = await db.rawQuery('''
      SELECT h.*, f.id IS NOT NULL as is_liked
      FROM hymn h
      LEFT JOIN user_db.favorite_hymn f 
        ON h.book_name = f.book_name AND h.hymn_number = f.hymn_number
      WHERE h.hymn_book_id = ?
      ORDER BY h.hymn_number
    ''', [bookId]);

    return results.map((row) {
      return Hymn.fromMap(
        row,
        isLiked: row['is_liked'] == 1,
      );
    }).toList();
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
    final hymn = await getHymnData(hymnId);
    await db.insert(
      'user_db.favorite_hymn',
      {
        'book_name': hymn.bookName,
        'hymn_number': hymn.number,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> unlikeHymn(int hymnId) async {
    final db = await database;
    final hymn = await getHymnData(hymnId);
    await db.delete(
      'user_db.favorite_hymn',
      where: 'book_name = ? AND hymn_number = ?',
      whereArgs: [hymn.bookName, hymn.number],
    );
  }

  // Removed getFavoriteHymnIds in favor of joined queries

  Future<List<Hymn>> getFavoriteHymns() async {
    final db = await database;
    final results = await db.rawQuery(
      '''SELECT h.* FROM hymn h 
      INNER JOIN user_db.favorite_hymn f 
      ON h.book_name = f.book_name AND h.hymn_number = f.hymn_number''',
    );

    return results.map((row) {
      return Hymn.fromMap(
        row,
        isLiked: true,
      );
    }).toList();
  }

  // HymnCollection CRUD
  Future<HymnCollection> createCollection(HymnCollection collection) async {
    final db = await database;
    final id = await db.insert('user_db.hymn_collection', collection.toMap());
    return collection.copyWith(
      id: id,
    );
  }

  Future<List<HymnCollection>> getAllCollections() async {
    final db = await database;
    final result = await db.query(
      'user_db.hymn_collection',
      orderBy: 'creation_date ASC',
    );
    return result.map((json) => HymnCollection.fromMap(json)).toList();
  }

  Future<List<HymnCollection>> getCollectionsData() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT hc.*, h.id AS hymn_id, h.title AS hymn_title, h.hymn_book_id, h.book_name, h.hymn_number, h.first_line, h.other_reference
      FROM user_db.hymn_collection hc
      LEFT JOIN user_db.hymn_collection_join hcj ON hc.id = hcj.collection_id
      LEFT JOIN hymn h ON hcj.book_name = h.book_name AND hcj.hymn_number = h.hymn_number
      ORDER BY hc.creation_date DESC, hcj.order_index ASC
    ''');

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
        FROM user_db.hymn_collection hc
        LEFT JOIN user_db.hymn_collection_join hcj ON hc.id = hcj.collection_id
        LEFT JOIN hymn h ON hcj.book_name = h.book_name AND hcj.hymn_number = h.hymn_number
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
        'user_db.hymn_collection',
        collection.toMap(),
        where: 'id = ?',
        whereArgs: [collection.id],
      );
    } else {
      collectionId = await db.insert(
        'user_db.hymn_collection',
        collection.toMap(),
      );
    }
    return collection.copyWith(id: collectionId);
  }

  Future<void> deleteCollection(int id) async {
    final db = await database;
    await db.delete(
      'user_db.hymn_collection',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Junction Table Operations
  Future<void> addHymnToCollection(int hymnId, int collectionId) async {
    final db = await database;
    final hymn = await getHymnData(hymnId);

    final result = await db.rawQuery(
      'SELECT MAX(order_index) as max_index FROM user_db.hymn_collection_join WHERE collection_id = ?',
      [collectionId],
    );
    int nextIndex = 0;
    if (result.isNotEmpty && result.first['max_index'] != null) {
      nextIndex = (result.first['max_index'] as int? ?? -1) + 1;
    }

    await db.insert(
      'user_db.hymn_collection_join',
      {
        'collection_id': collectionId,
        'book_name': hymn.bookName,
        'hymn_number': hymn.number,
        'order_index': nextIndex,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeHymnFromCollection(int hymnId, int collectionId) async {
    final db = await database;
    final hymn = await getHymnData(hymnId);
    await db.delete(
      'user_db.hymn_collection_join',
      where: 'collection_id = ? AND book_name = ? AND hymn_number = ?',
      whereArgs: [collectionId, hymn.bookName, hymn.number],
    );
  }

  Future<List<Hymn>> getHymnsByCollection(int collectionId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT h.* FROM hymn h
      INNER JOIN user_db.hymn_collection_join hcj 
        ON h.book_name = hcj.book_name AND h.hymn_number = hcj.hymn_number
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
        'user_db.hymn_collection_join',
        {'order_index': i},
        where: 'collection_id = ? AND book_name = ? AND hymn_number = ?',
        whereArgs: [collectionId, hymns[i].bookName, hymns[i].number],
      );
    }
  }

  // hymn section methods
  Future<int> insertSection(Section section, [DatabaseExecutor? db]) async {
    final executor = db ?? await database;
    return await executor.insert(
      'section',
      section.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
