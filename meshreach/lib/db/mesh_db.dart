import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MeshDB {
  static final MeshDB _i = MeshDB._();
  factory MeshDB() => _i;
  MeshDB._();
  Database? _db;

  Future<Database> get db async => _db ??= await openDatabase(
        join(await getDatabasesPath(), 'meshreach.db'),
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''CREATE TABLE messages(
            uuid TEXT PRIMARY KEY, type TEXT, content TEXT,
            direction TEXT, peer_id TEXT, ts INTEGER)''');
          await db.execute('''CREATE TABLE peers(
            device_id TEXT PRIMARY KEY, name TEXT,
            last_seen INTEGER, lat REAL, lng REAL)''');
          await db.execute('''CREATE TABLE ack(
            uuid TEXT PRIMARY KEY, acked_at INTEGER)''');
        },
      );

  Future<void> insertMessage(Map<String, dynamic> row) async =>
      (await db).insert('messages', row,
          conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<List<Map<String, dynamic>>> getMessages(String peerId) async =>
      (await db).query('messages',
          where: 'peer_id = ?', whereArgs: [peerId], orderBy: 'ts ASC');

  Future<void> upsertPeer(Map<String, dynamic> row) async =>
      (await db).insert('peers', row,
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<bool> isDuplicate(String uuid) async {
    final r = await (await db)
        .query('ack', where: 'uuid = ?', whereArgs: [uuid], limit: 1);
    if (r.isNotEmpty) return true;
    await (await db).insert('ack',
        {'uuid': uuid, 'acked_at': DateTime.now().millisecondsSinceEpoch});
    return false;
  }
}