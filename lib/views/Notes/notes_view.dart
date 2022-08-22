import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/crud/notes_services.dart';
import 'package:notes/views/Notes/notes_list_view.dart';
import '../../constants/Routs.dart';
import '../../enums/menu_action.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class Notesview extends StatefulWidget {
  const Notesview({Key? key}) : super(key: key);

  @override
  State<Notesview> createState() => _NotesviewState();
}

class _NotesviewState extends State<Notesview> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentuser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNotesRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenueAction>(onSelected: (value) async {
            switch (value) {
              case MenueAction.logout:
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout) {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                }
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: (MenueAction.logout),
                child: Text("Log out"),
              )
            ];
          })
        ],
      ),
      // this futureBuilder gets or creates a user with an email
      body: FutureBuilder(
        future: _notesService.getOrCreate(email: userEmail),
        // and builder will get a switch with the case of connectionStatebeing done.
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              //  in this case we will return a stream builder
              return StreamBuilder(
                // this stream builder has a stream of _notesService.allNotes
                // which is in notes_service file and then it builds a
                //switch case of wiating and it passes on to active.
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      // in this case we say if our snapshot has any data in it put allNotes
                      // as snapshot data in which is as the type of LIst<DatabaseNotes>
                      // and else will give a proccing animation
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DataBaseNotes>;
                        return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (notes) async {
                              await _notesService.deleteNote(id: notes.id);
                            });
                        // now this case will return a list view in which has a builder
                        // it asks how many lines this list requiers and what should it show in each line

                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
