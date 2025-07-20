// lib/screens/caisse_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/firebase_teacher_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaisseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teacherService = Provider.of<FirebaseTeacherService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Caisse Virtuelle')),
      body: Column(
        children: [
          // Total Caisse Card
          StreamBuilder<double>(
            stream: teacherService.getCaisseTotal(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final totalAmount = snapshot.data!;
              return Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Total en Caisse',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${totalAmount.toStringAsFixed(2)} F',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Payment History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Historique des Paiements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('payments')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final paymentDocs = snapshot.data!.docs;
                if (paymentDocs.isEmpty) {
                  return Center(child: Text('Aucun paiement enregistré.'));
                }
                return ListView.builder(
                  itemCount: paymentDocs.length,
                  itemBuilder: (context, index) {
                    final payment = Payment.fromFirestore(
                      paymentDocs[index]
                          as DocumentSnapshot<Map<String, dynamic>>,
                    );
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Icon(Icons.payment, color: Colors.green),
                        title: Text(
                          '${payment.teacherName} - ${payment.amount.toStringAsFixed(2)} F',
                        ),
                        subtitle: Text(
                          DateFormat.yMd().add_jm().format(payment.date),
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
    );
  }
}
