// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/teacher_model.dart';
import '../services/firebase_teacher_service.dart';
import '../services/firebase_auth_service.dart';
import 'add_edit_teacher_screen.dart';
import 'teacher_details_screen.dart';
import 'reports/global_report_screen.dart';
import 'reports/monthly_report_screen.dart';
import '../screens/caisse_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';

  void _navigateToAddTeacher() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddEditTeacherScreen()));
  }

  void _navigateToEditTeacher(Teacher teacher) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditTeacherScreen(teacher: teacher)),
    );
  }

  void _confirmDelete(BuildContext context, String teacherId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cet enseignant ?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Provider.of<FirebaseTeacherService>(
                context,
                listen: false,
              ).deleteTeacher(teacherId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => MonthlyReportScreen()));
            },
            tooltip: 'Rapport Mensuel',
          ),
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => GlobalReportScreen()));
            },
            tooltip: 'Rapport Global',
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => CaisseScreen()));
            },
            tooltip: 'Caisse',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<FirebaseAuthService>(
                context,
                listen: false,
              ).signOut();
            },
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher un enseignant...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<List<Teacher>>(
              builder: (context, teachers, child) {
                if (teachers.isEmpty) {
                  return Center(
                    child: Text('Aucun enseignant trouvé. Ajoutez-en un !'),
                  );
                }

                final filteredTeachers = teachers.where((teacher) {
                  return teacher.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }).toList();

                if (filteredTeachers.isEmpty && _searchQuery.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Aucun enseignant trouvé pour "$_searchQuery".',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTeachers.length,
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          teacher.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${teacher.totalImpressions} impressions | ${teacher.totalPayment.toStringAsFixed(2)} FCFA',
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TeacherDetailsScreen(teacherId: teacher.id),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _navigateToEditTeacher(teacher),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmDelete(context, teacher.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTeacher,
        child: Icon(Icons.add),
        tooltip: 'Ajouter un enseignant',
      ),
    );
  }
}
