import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_sqlite/database/database.dart';
import 'package:todo_sqlite/models/note_model.dart';

import 'home_screen.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;

  AddNoteScreen({this.note, this.updateNoteList});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dateController = TextEditingController();
  String _title = "";
  String _priority = "Low";
  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");
  final List<String> _priorities = ["Low", "Medium", "High"];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;
      setState(() {
        btnText = "Update Note";
        titleText = "Update Note";
      });
    } else {
      setState(() {
        btnText = "Add Note";
        titleText = "Add Note";
      });
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  DateTime _date = DateTime.now();
  String btnText = "Add note";
  String titleText = "Add note";

  _datePickerHandler() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteNote(widget.note!.id!);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen()));
    widget.updateNoteList!();
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print("$_title, $_date, $_priority");

      Note note = Note(
        title: _title,
        date: _date,
        priority: _priority,
      );
      if (widget.note == null) {
        note.status = 0;
        DatabaseHelper.instance.insertNote(note);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;
        DatabaseHelper.instance.updateNote(note);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }
      widget.updateNoteList!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffbeeac),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 80.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    size: 30.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  titleText,
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Form(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: GoogleFonts.roboto(
                            fontSize: 18.0,
                          ),
                          decoration: InputDecoration(
                            labelText: "Title",
                            labelStyle: GoogleFonts.roboto(
                              fontSize: 18.0,
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? "Please enter a title"
                              : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          onTap: _datePickerHandler,
                          style: GoogleFonts.roboto(
                            fontSize: 18.0,
                          ),
                          decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: GoogleFonts.roboto(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: GoogleFonts.roboto(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                            );
                          }).toList(),
                          style: GoogleFonts.roboto(fontSize: 18.0),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: "Priority",
                            labelStyle: GoogleFonts.roboto(fontSize: 18.0),
                          ),
                          validator: (input) => _priority == null
                              ? "Please select the priority level"
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value.toString();
                            });
                          },
                          value: _priority,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            btnText,
                            style: GoogleFonts.roboto(
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                      widget.note != null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 20.0),
                              height: 60.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: ElevatedButton(
                                onPressed: _delete,
                                child: Text(
                                  "Delete note",
                                  style: GoogleFonts.roboto(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                  key: _formKey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
