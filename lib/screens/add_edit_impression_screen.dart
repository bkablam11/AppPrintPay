// lib/screens/add_edit_impression_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/impression_model.dart';
import '../services/firebase_teacher_service.dart';

class AddEditImpressionScreen extends StatefulWidget {
  final String teacherId;
  final Impression? impression;

  AddEditImpressionScreen({required this.teacherId, this.impression});

  @override
  _AddEditImpressionScreenState createState() =>
      _AddEditImpressionScreenState();
}

class _AddEditImpressionScreenState extends State<AddEditImpressionScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _pageCount;
  double _costPerPage = 15.0; // Default cost

  @override
  void initState() {
    super.initState();
    _pageCount = widget.impression?.pageCount ?? 0;
    // If we are editing, use the existing cost. Otherwise, default to 15.
    _costPerPage = widget.impression?.costPerPage ?? 15.0;
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final teacherService = Provider.of<FirebaseTeacherService>(
        context,
        listen: false,
      );

      if (widget.impression == null) {
        // Mode Ajout
        teacherService.addImpression(
          widget.teacherId,
          _pageCount,
          _costPerPage,
        );
      } else {
        // Mode Modification
        // Note: We don't allow changing the cost per page on an existing impression in this UI
        teacherService.updateImpression(
          widget.teacherId,
          widget.impression!.id,
          _pageCount,
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.impression == null
              ? 'Ajouter une impression'
              : 'Modifier une impression',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _pageCount.toString(),
                decoration: InputDecoration(labelText: 'Nombre de pages'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre de pages valide.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _pageCount = int.parse(value!);
                },
              ),
              SizedBox(height: 20),
              // Only show cost selection when adding a new impression
              if (widget.impression == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coût par page:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Radio<double>(
                          value: 15.0,
                          groupValue: _costPerPage,
                          onChanged: (value) {
                            setState(() {
                              _costPerPage = value!;
                            });
                          },
                        ),
                        Text('15'),
                        Radio<double>(
                          value: 25.0,
                          groupValue: _costPerPage,
                          onChanged: (value) {
                            setState(() {
                              _costPerPage = value!;
                            });
                          },
                        ),
                        Text('25'),
                      ],
                    ),
                  ],
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
