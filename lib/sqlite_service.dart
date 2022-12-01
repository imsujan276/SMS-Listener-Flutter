import 'package:path/path.dart';
import 'package:sms_catch/sms_model.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  final String dbName = "data.db";

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      onCreate: (db, version) async {
        var batch = db.batch();
        createDataTable(batch);
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) {},
      version: 2,
    );
  }

  createDataTable(Batch batch) {
    batch.execute('Drop table if exists sms');
    batch.execute('''Create table sms(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      text TEXT NOT NULL,
      sender TEXT NOT NULL,
      date INTEGER NOT NULL
    )''');
  }

  Future<int> insertSMS(SMS sms) async {
    final db = await initDB();
    final id = await db.insert(
      "sms",
      sms.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<SMS>> getAllSms() async {
    final db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.query(
      'sms',
      orderBy: 'date ASC',
    );
    print(queryResult);
    return queryResult.map((e) => SMS.fromMap(e)).toList();
  }

  Future<void> deleteSMS(String id) async {
    final db = await initDB();
    try {
      await db.delete("sms", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting a sms: $err");
    }
  }

  Future<void> deleteAllSMS() async {
    final db = await initDB();
    try {
      await db.delete("sms");
    } catch (err) {
      print("Something went wrong when deleting all sms: $err");
    }
  }
}
