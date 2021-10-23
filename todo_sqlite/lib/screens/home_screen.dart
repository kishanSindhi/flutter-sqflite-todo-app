import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_sqlite/database/database.dart';
import 'package:todo_sqlite/models/note_model.dart';

import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _noteList;
  final DateFormat _dateFormat = DateFormat("MMM dd, yyyy");
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildNote(Note note) {
      return Padding(
        child: Column(
          children: [
            ListTile(
              title: Text(
                note.title!,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  decoration: note.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                "${_dateFormat.format(note.date!)} - ${note.priority!}",
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  decoration: note.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              trailing: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  note.status = value! ? 1 : 0;
                  DatabaseHelper.instance.updateNote(note);
                  _updateNoteList();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()));
                },
                value: note.status == 1 ? true : false,
              ),
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => AddNoteScreen(
                    updateNoteList: _updateNoteList(),
                    note: note,
                  ),
                ),
              ),
            ),
            Divider(),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 25.0,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xfffbeeac),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => AddNoteScreen(
                        updateNoteList: _updateNoteList,
                      )));
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _noteList,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completeNoteCount = snapshot.data!
              .where((Note note) => note.status == 1)
              .toList()
              .length;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 80.0),
            itemCount: int.parse(snapshot.data!.length.toString()) + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My notes",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 40.0,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "$completeNoteCount of ${snapshot.data!.length}",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 20.0,
                  ),
                );
              }
              return _buildNote(snapshot.data![index - 1]);
            },
          );
        },
      ),
    );
  }
}
