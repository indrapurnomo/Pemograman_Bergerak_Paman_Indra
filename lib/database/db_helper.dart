import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uts_indra/utils/encryption.dart';


class DBHelper {
  static Database? _database;

  // Membuat dan menginisialisasi database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version for adding new table
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            full_name TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE accounts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            account_name TEXT,
            username TEXT,
            password TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  // CREATE: Menambahkan pengguna baru
  Future<int> createUser(String username, String fullName, String password) async {
    final db = await database;
    final encryptedPassword = EncryptionHelper.encryptPassword(username, password);
    return await db.insert('users', {
      'username': username,
      'full_name': fullName,
      'password': encryptedPassword,
    });
  }

  // READ: Mengambil data pengguna berdasarkan username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // CREATE: Menambahkan akun baru
  Future<int> createAccount(int userId, String accountName, String username, String password) async {
    final db = await database;
    final encryptedPassword = EncryptionHelper.encryptPassword(accountName, password);
    return await db.insert('accounts', {
      'user_id': userId,
      'account_name': accountName,
      'username': username,
      'password': encryptedPassword,
    });
  }

  // READ: Mengambil semua akun untuk pengguna tertentu
  Future<List<Map<String, dynamic>>> getAccounts(int userId) async {
    final db = await database;
    return await db.query('accounts', where: 'user_id = ?', whereArgs: [userId]);
  }

  // UPDATE: Mengupdate akun
  Future<int> updateAccount(int accountId, String accountName, String username, String password) async {
    final db = await database;
    final encryptedPassword = EncryptionHelper.encryptPassword(accountName, password);
    return await db.update(
      'accounts',
      {
        'account_name': accountName,
        'username': username,
        'password': encryptedPassword,
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  // DELETE: Menghapus akun
  Future<int> deleteAccount(int accountId) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }
}
