import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_migrations.dart';

class DatabaseHelper {
  static const String _databaseName = 'allpa_database.db';
  static Database? _database;

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase({String? customPath}) async {
    // Si corre en Windows, Linux, o macOS en modo desktop/test, inicializar FFI
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (customPath != null) {
      path = customPath;
    } else if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final docDir = await getApplicationSupportDirectory();
      path = join(docDir.path, _databaseName);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _databaseName);
    }

    return await openDatabase(
      path,
      version: DatabaseMigrations.currentVersion,
      onConfigure: DatabaseMigrations.onConfigure,
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
  }

  /// Método para inicializar con base de datos en memoria o ruta específica (para tests unitarios)
  static Future<Database> initInMemoryDatabase() async {
    sqfliteFfiInit();
    final factory = databaseFactoryFfi;
    final db = await factory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseMigrations.currentVersion,
        onConfigure: DatabaseMigrations.onConfigure,
        onCreate: DatabaseMigrations.onCreate,
      ),
    );
    return db;
  }

  /// Reiniciar o cerrar la base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

}
