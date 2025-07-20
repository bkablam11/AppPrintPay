import 'package:cloud_firestore/cloud_firestore.dart';

class Impression {
  String id;
  final DateTime date;
  int pageCount;
  final double costPerPage;

  Impression({
    required this.id,
    required this.date,
    required this.pageCount,
    required this.costPerPage,
  });

  double get totalCost => pageCount * costPerPage;

  // Firestore conversion
  factory Impression.fromMap(Map<String, dynamic> data) {
    return Impression(
      id: data['id'],
      date: (data['date'] as Timestamp).toDate(),
      pageCount: data['pageCount'],
      costPerPage: (data['costPerPage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'pageCount': pageCount,
      'costPerPage': costPerPage,
    };
  }
}
