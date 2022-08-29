import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_constance.dart';
import 'package:notes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseClouStorage {
  // the collection is like a stream but you can write to it as well
  // in streams you can only read
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      //we are giving the documents path which is it's id, to be updated
      //(each document in our notes collection will have an id)
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

// when you want to get data from a stream as it is evolving you use snapshot
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      // we want to see all the changes as they happening and they happen in the query snapshot
      // so there is our query snapshot in event with docs in it
      notes.snapshots().map((event) => event.docs
          // then we map every doc to a cloud note
          .map((doc) => CloudNote.fromSnapShot(doc))
          // and we are interested in the notes whos ownerUserId is equal to ownerUserId provieded at the begining
          // this where function shows the notes off the current user only .
          // if we remove this then anyone could have access to all the users notes!
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNote>> getNote({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapShot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createnewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote = await document.get();

    return CloudNote(
      ownerUserId: ownerUserId,
      documentId: fetchedNote.id,
      text: '',
    );
  }

  static final FirebaseClouStorage _shared =
      FirebaseClouStorage._sharedInstance();
  FirebaseClouStorage._sharedInstance();
  factory FirebaseClouStorage() => _shared;
}
