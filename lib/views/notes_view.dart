import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/crud/notes_services.dart';
import '../constants/Routs.dart';
import '../enums/menu_action.dart';

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
        title: const Text("main UI"),
        actions: [
          PopupMenuButton<MenueAction>(onSelected: (value) async {
            switch (value) {
              case MenueAction.logout:
                final shouldLogout = await showLogOutDialog(context);
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
      body: FutureBuilder(
        future: _notesService.getOrCreate(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text("the notes are loading");
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

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text("Log out"),
          content: const Text("are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("cancle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Log ot"),
            )
          ],
        );
      })).then((value) => value ?? false);
}
