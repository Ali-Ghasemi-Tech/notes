import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:notes/services/crud/notes_services.dart';
import 'package:notes/utilities/dialogs/delete_dialog.dart';

// we are defining a function which could be called back inside NOtesListView
// and it will be called when the user says yes for deleteing a note
typedef NoteCallback = void Function(DatabaseNote note);

// the only thing this file should do is to get the list and show them
// and make them beutiful
class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // we say the length of the allNotes list will be the count of our listVIew lines
    return ListView.builder(
      itemCount: notes.length,
      // we say our item ???
      itemBuilder: (context, index) {
        final note = notes[index];
        // our item will be a title in which it takes the text within our note which the user made and
        // it shows only one line that fits into the screen and if the text inside the note file
        //is more than what is being desplayed on listView it will give it an ellipsis so the user
        //will know there are more texts in the note file .
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          // it's a widget for ListTile and it's meant for adding widgets at the end (trail) of the line
          // and the things inside it are meant for showing the delete icon and what it will do on pressed
          trailing: IconButton(
            // onPressed it will show a Deletedialog and the answer in that function will give us true or false
            // which we applied to a final named shouldDelete and then we use this final to see what should we do
            // with the users answer
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
