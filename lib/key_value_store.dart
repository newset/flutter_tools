import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const _dbName = "cache.db";

class KeyValueStore {
  KeyValueStore._();

  /// 添加
  static Future<bool> put(String name, dynamic object) async {
    final database = await _getDB();
    final data = jsonEncode(object, toEncodable: (obj) => obj.toString());
    await database.transaction((txn) async {
      final res = await txn.rawInsert(
        'INSERT OR REPLACE INTO "cache" VALUES (?, ?, ?,?);',
        [name.hashCode, DateTime.now().millisecondsSinceEpoch, data, data.hashCode],
      );
      return res > 0;
    });
    // print(res);
    return false;
  }

  /// 获取
  static Future<KeyValueStoreItem?> getObject(String name) async {
    final database = await _getDB();
    List<Map> list = await database.rawQuery('SELECT * FROM "cache" WHERE name=?', [name.hashCode]);
    if (list.isEmpty) {
      return null;
    }
    Map<String, dynamic> map = {};
    for (var key in list.first.keys) {
      map[key] = list.first[key];
    }

    return KeyValueStoreItem.fromJson(map);
  }

  /// 获取内容值
  static Future<T?> get<T>(String name) async {
    try {
      final item = await getObject(name);
      return item?.content;
    } catch (_) {
      return null;
    }
  }

  /// 删除
  static delete(String name) async {
    final database = await _getDB();
    database.transaction((txn) async {
      txn.rawDelete('DELETE FROM "cache" WHERE name=?', [name.hashCode]);
    });
  }

  static Database? _dataBase;

  /// getDB
  static Future<Database> _getDB() async {
    if (_dataBase != null) {
      return _dataBase!;
    }
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);
    // print("sqlite: " + path);
    _dataBase = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      // print("----初始化数据表:" + databasesPath);
      await db.execute("""CREATE TABLE IF NOT EXISTS "cache" (
        "name" char NOT NULL,
        "create_time" integer NOT NULL,        
        "content" text,
        "content_hash" char,
        PRIMARY KEY ("name"));
     """);
    });

    return _dataBase!;
  }
}

class KeyValueStoreItem {
  late final String name;
  late final int createTime;
  late final dynamic content;
  late final String contentHash;

  bool get isEmpty {
    return createTime < 1;
  }

  // KeyValueStoreItem({this.name, this.createTime, this.content, this.contentHash});

  KeyValueStoreItem.fromJson(Map<String, dynamic> json) {
    name = json["name"].toString();
    createTime = json["create_time"];
    content = jsonDecode(json["content"]);
    contentHash = json["content_hash"];
  }
}
