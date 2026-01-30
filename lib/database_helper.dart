// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// // Models
// import 'models/chaper.dart';
// import 'models/hadith.dart';

// // Import data file (لازم تكون مجهّز lists فيه)
// import 'hadith_data.dart';

// class DatabaseHelper {
//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

//   static Database? _database;

//   static const String _databaseName = 'hadith_db.db';
//   static const int _databaseVersion = 2;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final databasePath = await getDatabasesPath();
//     final path = join(databasePath, _databaseName);

//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: _onCreate,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE chapter(
//         id INTEGER PRIMARY KEY,
//         title TEXT NOT NULL,
//         hadith_count INTEGER NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE hadith(
//         id INTEGER PRIMARY KEY,
//         chapter_id INTEGER NOT NULL,
//         hadith_text TEXT NOT NULL,
//         is_favorite INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY (chapter_id) REFERENCES chapter(id) ON DELETE CASCADE
//       )
//     ''');

//     // ✅ أول مرة تتعمل DB: نضيف البيانات من hadith_data.dart
//     Batch batch = db.batch();

//     for (var chapter in hadithChapters) {
//       batch.insert('chapter', chapter.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//     for (var hadith in hadithList) {
//       batch.insert('hadith', hadith.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//     }

//     await batch.commit();
//   }

//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 2) {
//       await db.execute(
//         'ALTER TABLE hadith ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0'
//       );
//     }
//   }

//   // ================== CRUD & Utils ==================

//   Future<void> insertChapters(List<Chapter> chapters) async {
//     final db = await database;
//     final batch = db.batch();
//     for (var chapter in chapters) {
//       batch.insert('chapter', chapter.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//     await batch.commit();
//   }

//   Future<void> insertHadiths(List<Hadith> hadiths) async {
//     final db = await database;
//     final batch = db.batch();
//     for (var hadith in hadiths) {
//       batch.insert('hadith', hadith.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//     await batch.commit();
//   }

//   Future<List<Chapter>> getChapters() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('chapter');
//     return List.generate(maps.length, (i) {
//       return Chapter(
//         id: maps[i]['id'],
//         title: maps[i]['title'],
//         hadithCount: maps[i]['hadith_count'],
//       );
//     });
//   }

//   Future<Chapter?> getChapterById(int id) async {
//     final db = await database;
//     final maps = await db.query(
//       'chapter',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (maps.isNotEmpty) {
//       return Chapter(
//         id: maps.first['id'] as int,
//         title: maps.first['title'] as String,
//         hadithCount: maps.first['hadith_count'] as int,
//       );
//     }
//     return null;
//   }

//   Future<List<Hadith>> getHadiths(int chapterId) async {
//     final db = await database;
//     final maps = await db.query(
//       'hadith',
//       where: 'chapter_id = ?',
//       whereArgs: [chapterId],
//     );
//     return maps.map((e) => Hadith.fromMap(e)).toList();
//   }

//   Future<Hadith?> getRandomHadith() async {
//     final db = await database;
//     final maps = await db.rawQuery(
//       'SELECT * FROM hadith ORDER BY RANDOM() LIMIT 1'
//     );
//     if (maps.isNotEmpty) {
//       return Hadith.fromMap(maps.first);
//     }
//     return null;
//   }

//   Future<List<Hadith>> searchHadiths(String keyword) async {
//     final db = await database;
//     final maps = await db.query(
//       'hadith',
//       where: 'hadith_text LIKE ?',
//       whereArgs: ['%$keyword%'],
//     );
//     return maps.map((e) => Hadith.fromMap(e)).toList();
//   }

//   Future<List<Hadith>> getFavoriteHadiths() async {
//     final db = await database;
//     final maps = await db.query(
//       'hadith',
//       where: 'is_favorite = ?',
//       whereArgs: [1],
//     );
//     return maps.map((e) => Hadith.fromMap(e)).toList();
//   }

//   Future<void> toggleFavorite(int hadithId, bool isFavorite) async {
//     final db = await database;
//     await db.update(
//       'hadith',
//       {'is_favorite': isFavorite ? 1 : 0},
//       where: 'id = ?',
//       whereArgs: [hadithId],
//     );
//   }
// }


import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Models
import 'models/chaper.dart';
import 'models/hadith.dart';

// Import data file
import 'hadith_data.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  static const String _databaseName = 'hadith_db.db';
  static const int _databaseVersion = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    // Open the database
    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    // 🛠️ SCHEMA SELF-HEALING: Ensure tables exist
    // This fixes the issue where 'notes' or 'collections' tables might be missing
    // if the upgrade logic failed or didn't run.
    await _createTables(db);
    
    // 🛠️ DATA SELF-HEALING: Check if data is missing despite apparent success
    // This fixes the "hidden chapters" bug if the DB was created but not populated
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM chapter'));
    if (count == 0) {
      print("⚠️ Database appears empty. Attempting to repopulate...");
      await _populateDatabase(db);
    }

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    print("creating database...");
    await _createTables(db);
    await _populateDatabase(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from $oldVersion to $newVersion");
    
    if (oldVersion < 2) {
      // Version 2: Added favorites
      try {
        await db.execute('ALTER TABLE hadith ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
      } catch (e) { 
        print("Column is_favorite might already exist: $e");
      }
    }
    
    if (oldVersion < 3) {
      // Version 3: Notes, Collections, FTS5
      await _createNotesTable(db);
      await _createCollectionsTables(db);
      await _createFtsTable(db);
      
      // Populate FTS from existing data if upgrade
      try {
         final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM hadith_fts'));
         if (count == 0) {
            await db.execute('''
              INSERT INTO hadith_fts(rowid, hadith_text)
              SELECT id, hadith_text FROM hadith
            ''');
         }
      } catch (e) {
        print("Error checking/populating FTS during upgrade: $e");
      }
    }
    
    if (oldVersion < 4) {
      // Version 4: Add color column to notes
      try {
        await db.execute('ALTER TABLE notes ADD COLUMN color INTEGER NOT NULL DEFAULT 4294951687');
        print("Added color column to notes table");
      } catch (e) {
        print("Column color might already exist in notes: $e");
      }
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chapter(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        hadith_count INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadith(
        id INTEGER PRIMARY KEY,
        chapter_id INTEGER NOT NULL,
        hadith_text TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (chapter_id) REFERENCES chapter(id) ON DELETE CASCADE
      )
    ''');
    
    await _createNotesTable(db);
    await _createCollectionsTables(db);
    await _createFtsTable(db);
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hadith_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        color INTEGER NOT NULL DEFAULT 4294951687,
        FOREIGN KEY (hadith_id) REFERENCES hadith(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createCollectionsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS collections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS collection_items(
        collection_id INTEGER NOT NULL,
        hadith_id INTEGER NOT NULL,
        created_at INTEGER,
        PRIMARY KEY (collection_id, hadith_id),
        FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE,
        FOREIGN KEY (hadith_id) REFERENCES hadith(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createFtsTable(Database db) async {
    // Wrap in try-catch because FTS5 might not be supported on all devices
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS hadith_fts USING fts5(
          hadith_text,
          content='hadith',
          content_rowid='id'
        )
      ''');
    } catch (e) {
      print("⚠️ FTS5 creation failed: $e. Search will fall back to LIKE.");
    }
  }

  Future<void> _populateDatabase(Database db) async {
    print("Populating database...");
    Batch batch = db.batch();

    // Use ConflictAlgorithm.replace to avoid 'UNIQUE constraint failed' if partial data exists
    for (var chapter in hadithChapters) {
      batch.insert('chapter', chapter.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (var hadith in hadithList) {
      batch.insert('hadith', hadith.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
    print("Database populated. Inserting FTS...");
    
    try {
      await db.execute('''
        INSERT OR REPLACE INTO hadith_fts(rowid, hadith_text)
        SELECT id, hadith_text FROM hadith
      ''');
    } catch (e) {
      print("FTS population failed: $e");
    }
  }

  // ================== CRUD & Utils ==================

  Future<List<Chapter>> getChapters() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('chapter');
      return List.generate(maps.length, (i) {
        return Chapter(
          id: maps[i]['id'],
          title: maps[i]['title'],
          hadithCount: maps[i]['hadith_count'],
        );
      });
    } catch (e) {
       print("Error getting chapters: $e");
       // Fatal error recovery: try to populate if empty
       return [];
    }
  }

  Future<Chapter?> getChapterById(int id) async {
    final db = await database;
    final maps = await db.query(
      'chapter',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Chapter(
        id: maps.first['id'] as int,
        title: maps.first['title'] as String,
        hadithCount: maps.first['hadith_count'] as int,
      );
    }
    return null;
  }

  Future<List<Hadith>> getHadiths(int chapterId) async {
    final db = await database;
    final maps = await db.query(
      'hadith',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );
    return maps.map((e) => Hadith.fromMap(e)).toList();
  }

  Future<Hadith?> getRandomHadith() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT * FROM hadith ORDER BY RANDOM() LIMIT 1'
    );
    if (maps.isNotEmpty) {
      return Hadith.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Hadith>> searchHadiths(String keyword) async {
    final db = await database;
    try {
      // Use FTS5 MATCH query
      final maps = await db.rawQuery('''
        SELECT hadith.* FROM hadith 
        JOIN hadith_fts ON hadith.id = hadith_fts.rowid
        WHERE hadith_fts MATCH ?
      ''', [keyword]);
      
      return maps.map((e) => Hadith.fromMap(e)).toList();
    } catch (e) {
      print("FTS search failed ($e), falling back to LIKE");
      final maps = await db.query(
        'hadith',
        where: 'hadith_text LIKE ?',
        whereArgs: ['%$keyword%'],
      );
      return maps.map((e) => Hadith.fromMap(e)).toList();
    }
  }

  Future<List<Hadith>> getFavoriteHadiths() async {
    final db = await database;
    final maps = await db.query(
      'hadith',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return maps.map((e) => Hadith.fromMap(e)).toList();
  }

  Future<void> toggleFavorite(int hadithId, bool isFavorite) async {
    final db = await database;
    await db.update(
      'hadith',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [hadithId],
    );
  }

  // ================== Notes CRUD ==================

  Future<int> addNote(int hadithId, String text, {int color = 0xFFFFC107}) async {
    final db = await database;
    return await db.insert('notes', {
      'hadith_id': hadithId,
      'text': text,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'color': color,
    });
  }

  Future<List<Map<String, dynamic>>> getNotes(int hadithId) async {
    final db = await database;
    try {
      return await db.query('notes', where: 'hadith_id = ?', whereArgs: [hadithId], orderBy: 'created_at DESC');
    } catch (e) {
      // If table missing (downgrade/upgrade issue), clean fail
      print("Error getting notes: $e");
      return [];
    }
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNote(int id, String text) async {
    final db = await database;
    return await db.update('notes', {'text': text}, where: 'id = ?', whereArgs: [id]);
  }

  // Get all notes for the global Notes Page
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    try {
      return await db.rawQuery('''
        SELECT n.id, n.text, n.created_at, n.color, n.hadith_id, h.hadith_text 
        FROM notes n
        JOIN hadith h ON n.hadith_id = h.id
        ORDER BY n.created_at DESC
      ''');
    } catch (e) {
      print("Error getting all notes: $e");
      return [];
    }
  }

  // ================== Collections CRUD ==================

  Future<int> createCollection(String name, int color) async {
    final db = await database;
    return await db.insert('collections', {
      'name': name,
      'color': color,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getCollections() async {
    final db = await database;
     try {
       return await db.query('collections', orderBy: 'created_at DESC');
     } catch (e) {
       print("Error getCollections: $e");
       return [];
     }
  }

  Future<void> deleteCollection(int id) async {
    final db = await database;
    await db.delete('collections', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addHadithToCollection(int collectionId, int hadithId) async {
    final db = await database;
    await db.insert('collection_items', {
      'collection_id': collectionId,
      'hadith_id': hadithId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeHadithFromCollection(int collectionId, int hadithId) async {
    final db = await database;
    await db.delete('collection_items', 
      where: 'collection_id = ? AND hadith_id = ?', 
      whereArgs: [collectionId, hadithId]
    );
  }

  Future<List<Hadith>> getHadithsInCollection(int collectionId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT h.* FROM hadith h
      INNER JOIN collection_items ci ON h.id = ci.hadith_id
      WHERE ci.collection_id = ?
    ''', [collectionId]);
    return results.map((e) => Hadith.fromMap(e)).toList();
  }

  // 🆕 Reset Function (Force Wipe)
  Future<void> resetDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    _database = null;

    // Delete the file
    await deleteDatabase(path);
    print("Database deleted. Re-initializing...");
    
    // This will trigger creation and population again
    await database;
  }
}
