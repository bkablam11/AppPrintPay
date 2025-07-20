// lib/screens/teacher_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/teacher_model.dart';
import '../models/payment_model.dart';
import '../services/firebase_teacher_service.dart';
import 'add_edit_impression_screen.dart';

class TeacherDetailsScreen extends StatefulWidget {
  final String teacherId;

  const TeacherDetailsScreen({Key? key, required this.teacherId})
    : super(key: key);

  @override
  _TeacherDetailsScreenState createState() => _TeacherDetailsScreenState();
}

class _TeacherDetailsScreenState extends State<TeacherDetailsScreen> {
  final _paymentFormKey = GlobalKey<FormState>();
  final _paymentAmountController = TextEditingController();

  void _navigateToAddImpression() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditImpressionScreen(teacherId: widget.teacherId),
      ),
    );
  }

  void _navigateToEditImpression(impression) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditImpressionScreen(
          teacherId: widget.teacherId,
          impression: impression,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String impressionId) {
    // This now represents deleting a mistaken entry, not a payment
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer cette impression ? Cette action est pour corriger une erreur.',
        ),
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
              ).deleteImpression(widget.teacherId, impressionId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(Teacher teacher) {
    _paymentAmountController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enregistrer un paiement'),
        content: Form(
          key: _paymentFormKey,
          child: TextFormField(
            controller: _paymentAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Montant payé'),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == null ||
                  double.parse(value) <= 0) {
                return 'Veuillez entrer un montant valide.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Enregistrer'),
            onPressed: () {
              if (_paymentFormKey.currentState!.validate()) {
                final amount = double.parse(_paymentAmountController.text);
                Provider.of<FirebaseTeacherService>(
                  context,
                  listen: false,
                ).addPayment(teacher.id, teacher.name, amount);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacherService = Provider.of<FirebaseTeacherService>(
      context,
      listen: false,
    );

    return StreamBuilder<Teacher>(
      stream: teacherService.getTeacherById(widget.teacherId),
      builder: (context, teacherSnapshot) {
        if (teacherSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!teacherSnapshot.hasData || teacherSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Erreur ou enseignant non trouvé.')),
          );
        }
        final teacher = teacherSnapshot.data!;

        return StreamBuilder<List<Payment>>(
          stream: teacherService.getPaymentsForTeacher(widget.teacherId),
          builder: (context, paymentSnapshot) {
            if (paymentSnapshot.connectionState == ConnectionState.waiting) {
              // Show a loading state but keep the teacher data if available
              return Scaffold(
                appBar: AppBar(title: Text(teacher.name)),
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final payments = paymentSnapshot.data ?? [];
            final totalPaid = payments.fold(
              0.0,
              (sum, item) => sum + item.amount,
            );
            final balance = teacher.totalPayment - totalPaid;

            return Scaffold(
              appBar: AppBar(title: Text(teacher.name)),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryColumn(
                              'Dette Totale',
                              teacher.totalPayment,
                            ),
                            _buildSummaryColumn('Total Payé', totalPaid),
                            _buildSummaryColumn(
                              'Solde Actuel',
                              balance,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Historique des Impressions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: teacher.impressions.length,
                        itemBuilder: (context, index) {
                          final impression = teacher.impressions[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                'Date: ${DateFormat.yMd().format(impression.date)}',
                              ),
                              subtitle: Text(
                                'Pages: ${impression.pageCount} | Coût: ${impression.totalCost.toStringAsFixed(2)} F',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () =>
                                        _navigateToEditImpression(impression),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        _confirmDelete(context, impression.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      heroTag: 'add_impression_fab',
                      onPressed: _navigateToAddImpression,
                      label: Text('Impression'),
                      icon: Icon(Icons.print),
                    ),
                    SizedBox(width: 16),
                    FloatingActionButton.extended(
                      heroTag: 'add_payment_fab',
                      onPressed: () => _showAddPaymentDialog(teacher),
                      label: Text('Paiement'),
                      icon: Icon(Icons.payment),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryColumn(
    String title,
    double value, {
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} F',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: isBold ? (value > 0 ? Colors.red : Colors.green) : null,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}
