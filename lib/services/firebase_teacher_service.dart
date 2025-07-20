// lib/services/firebase_teacher_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../models/impression_model.dart';
import '../models/payment_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class FirebaseTeacherService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();
  final String _teachersCollection = 'teachers';
  final String _paymentsCollection = 'payments';
  final String _caisseCollection = 'caisse';

  Stream<List<Teacher>> getTeachers() {
    return _firestore.collection(_teachersCollection).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => Teacher.fromFirestore(doc)).toList();
    });
  }

  Stream<Teacher> getTeacherById(String id) {
    return _firestore
        .collection(_teachersCollection)
        .doc(id)
        .snapshots()
        .map((doc) => Teacher.fromFirestore(doc));
  }

  Future<void> addTeacher(String name) {
    final newTeacher = Teacher(id: '', name: name, impressions: []);
    return _firestore
        .collection(_teachersCollection)
        .add(newTeacher.toFirestore());
  }

  Future<void> updateTeacher(String id, String newName) {
    return _firestore.collection(_teachersCollection).doc(id).update({
      'name': newName,
    });
  }

  Future<void> deleteTeacher(String id) {
    return _firestore.collection(_teachersCollection).doc(id).delete();
  }

  Future<void> addImpression(
    String teacherId,
    int pageCount,
    double costPerPage,
  ) {
    final newImpression = Impression(
      id: _uuid.v4(),
      date: DateTime.now(),
      pageCount: pageCount,
      costPerPage: costPerPage,
    );
    return _firestore.collection(_teachersCollection).doc(teacherId).update({
      'impressions': FieldValue.arrayUnion([newImpression.toFirestore()]),
    });
  }

  Future<void> updateImpression(
    String teacherId,
    String impressionId,
    int newPageCount,
  ) async {
    final docRef = _firestore.collection(_teachersCollection).doc(teacherId);
    final doc = await docRef.get();
    if (doc.exists) {
      List<dynamic> impressions = doc.data()!['impressions'];
      var impressionToUpdate = impressions.firstWhere(
        (imp) => imp['id'] == impressionId,
      );
      impressionToUpdate['pageCount'] = newPageCount;
      await docRef.update({'impressions': impressions});
    }
  }

  Future<void> deleteImpression(String teacherId, String impressionId) async {
    final docRef = _firestore.collection(_teachersCollection).doc(teacherId);
    final doc = await docRef.get();
    if (doc.exists) {
      List<dynamic> impressions = doc.data()!['impressions'];
      impressions.removeWhere((imp) => imp['id'] == impressionId);
      await docRef.update({'impressions': impressions});
    }
  }

  Future<void> generateAndAddMockData() async {
    final random = Random();
    final batch = _firestore.batch();
    final teacherNames = [
      'Marie Curie',
      'Isaac Newton',
      'Albert Einstein',
      'Galileo Galilei',
      'Nikola Tesla',
      'Charles Darwin',
      'Ada Lovelace',
      'Rosalind Franklin',
      'Leonardo da Vinci',
      'Stephen Hawking',
    ];

    for (var name in teacherNames) {
      List<Impression> impressions = [];
      int numberOfImpressions = random.nextInt(5) + 1;

      for (int i = 0; i < numberOfImpressions; i++) {
        impressions.add(
          Impression(
            id: _uuid.v4(),
            date: DateTime.now().subtract(Duration(days: random.nextInt(365))),
            pageCount: random.nextInt(150) + 10,
            costPerPage: random.nextBool() ? 15.0 : 25.0,
          ),
        );
      }

      final newTeacher = Teacher(id: '', name: name, impressions: impressions);
      final docRef = _firestore.collection(_teachersCollection).doc();
      batch.set(docRef, newTeacher.toFirestore());
    }

    await batch.commit();
    notifyListeners();
  }

  Future<void> clearImpressionsForMonth(int year, int month) async {
    final batch = _firestore.batch();
    final teachersSnapshot = await _firestore
        .collection(_teachersCollection)
        .get();

    for (var doc in teachersSnapshot.docs) {
      final teacher = Teacher.fromFirestore(doc);
      final impressionsToKeep = teacher.impressions.where((imp) {
        return imp.date.year != year || imp.date.month != month;
      }).toList();

      if (impressionsToKeep.length < teacher.impressions.length) {
        final updatedImpressions = impressionsToKeep
            .map((imp) => imp.toFirestore())
            .toList();
        batch.update(doc.reference, {'impressions': updatedImpressions});
      }
    }

    await batch.commit();
    notifyListeners();
  }

  // --- Payment and Caisse Management ---

  Stream<List<Payment>> getPaymentsForTeacher(String teacherId) {
    return _firestore
        .collection(_paymentsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList(),
        );
  }

  Stream<double> getCaisseTotal() {
    return _firestore
        .collection(_caisseCollection)
        .doc('total')
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data()!.containsKey('amount')) {
            return (doc.data()!['amount'] as num).toDouble();
          }
          return 0.0;
        });
  }

  Future<void> addPayment(
    String teacherId,
    String teacherName,
    double amount,
  ) async {
    final paymentRef = _firestore.collection(_paymentsCollection).doc();
    final caisseRef = _firestore.collection(_caisseCollection).doc('total');

    final newPayment = Payment(
      id: paymentRef.id,
      teacherId: teacherId,
      teacherName: teacherName,
      amount: amount,
      date: DateTime.now(),
    );

    return _firestore.runTransaction((transaction) async {
      transaction.set(paymentRef, newPayment.toFirestore());
      transaction.set(caisseRef, {
        'amount': FieldValue.increment(amount),
      }, SetOptions(merge: true));
    });
  }
}
