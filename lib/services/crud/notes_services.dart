import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:flutter/foundation.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DataBaseNotes> _notes = [];

// making a singletone of NotesServices so when ever called it uses one shared NotesServices
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DataBaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;
//
  late final StreamController<List<DataBaseNotes>> _notesStreamController;

  Stream<List<DataBaseNotes>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DataBaseUser> getOrCreate({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createUser = await creatUser(email: email);
      return createUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DataBaseNotes> updateNote({
    required String text,
    required DataBaseNotes note,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(
      notesTable,
      {
        textcoulmn: text,
        isSyncedWithCloudcoulmn: 0,
      },
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DataBaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final notes = await db.query(notesTable);
    return notes.map((notesRow) => DataBaseNotes.formRow(notesRow));
  }

  Future<DataBaseNotes> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notesTable.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DataBaseNotes.formRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final finalnumberOfDeletedNotes = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return finalnumberOfDeletedNotes;
  }

// this will get the delete data for the note that it should be deleted and
// it delets the note and it updates the arrey and it gives it to stream controller
// in which it updates the data on notes view
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final deletedcount = await db.delete(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedcount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DataBaseNotes> creatNote({required DataBaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    // make sure owner exists in database with correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    // creat note
    final noteId = await db.insert(userTable, {
      userIdcoulmn: owner.id,
      textcoulmn: text,
      isSyncedWithCloudcoulmn: 1,
    });
    final note = DataBaseNotes(
      id: noteId,
      text: text,
      userId: owner.id,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DataBaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final result = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DataBaseUser.fromrow(result.first);
    }
  }

  Future<DataBaseUser> creatUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final result = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlredyExists();
    }
    final userId = await db.insert(userTable, {
      emailcoulmn: email.toLowerCase(),
    });
    return DataBaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    final deletCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(creatUserTable);

      await db.execute(creatNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Database _getDataBaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }
}

@immutable
class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email,
  });

  DataBaseUser.fromrow(Map<String, Object?> map)
      : id = map[idcoulmn] as int,
        email = map[emailcoulmn] as String;

  @override
  String toString() => 'person ,id = $id, email = $email';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DataBaseNotes {
  final int id;
  final String text;
  final int userId;
  final bool isSyncedWithCloud;

  const DataBaseNotes({
    required this.id,
    required this.text,
    required this.userId,
    required this.isSyncedWithCloud,
  });

  DataBaseNotes.formRow(Map<String, Object?> map)
      : id = map[idcoulmn] as int,
        userId = map[userIdcoulmn] as int,
        isSyncedWithCloud =
            map[isSyncedWithCloudcoulmn] as int == 1 ? true : false,
        text = map[textcoulmn] as String;

  @override
  String toString() =>
      'person ,id = $id, user_id= $userId , is_symced_with_cloud = $isSyncedWithCloud ';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const idcoulmn = 'id';
const emailcoulmn = 'email';
const userIdcoulmn = 'user_id';
const isSyncedWithCloudcoulmn = 'is_synced_with_cloud';
const textcoulmn = 'text';
const creatUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	string NOT NULL UNIQUE,
	PRIMARY KEY("id")
);''';
const creatNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id","user_id")
);''';
