// lib/models/payment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String teacherId;
  final String teacherName; // For easier display
  final double amount;
  final DateTime date;

  Payment({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.amount,
    required this.date,
  });

  factory Payment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Payment(
      id: doc.id,
      teacherId: data['teacherId'],
      teacherName: data['teacherName'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}
