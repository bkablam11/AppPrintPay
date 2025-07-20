// lib/screens/add_edit_teacher_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/teacher_model.dart';
import '../services/firebase_teacher_service.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  AddEditTeacherScreen({this.teacher});

  @override
  _AddEditTeacherScreenState createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.teacher?.name ?? '';
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final teacherService = Provider.of<FirebaseTeacherService>(
        context,
        listen: false,
      );

      if (widget.teacher == null) {
        // Mode Ajout
        teacherService.addTeacher(_name);
      } else {
        // Mode Modification
        teacherService.updateTeacher(widget.teacher!.id, _name);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.teacher == null
              ? 'Ajouter un enseignant'
              : 'Modifier un enseignant',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nom de l\'enseignant'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom ne peut pas être vide.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveForm, child: Text('Enregistrer')),
            ],
          ),
        ),
      ),
    );
  }
}
