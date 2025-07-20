import 'package:cloud_firestore/cloud_firestore.dart';
import 'impression_model.dart';

class Teacher {
  String id;
  String name;
  List<Impression> impressions;

  Teacher({required this.id, required this.name, List<Impression>? impressions})
    : this.impressions = impressions ?? [];

  int get totalImpressions {
    if (impressions.isEmpty) return 0;
    return impressions.map((e) => e.pageCount).reduce((a, b) => a + b);
  }

  double get totalPayment {
    if (impressions.isEmpty) return 0.0;
    return impressions.map((e) => e.totalCost).reduce((a, b) => a + b);
  }

  // Firestore conversion
  factory Teacher.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    var impressionsData = data['impressions'] as List<dynamic>? ?? [];
    List<Impression> impressionList = impressionsData
        .map((impData) => Impression.fromMap(impData))
        .toList();

    return Teacher(id: doc.id, name: data['name'], impressions: impressionList);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'impressions': impressions.map((imp) => imp.toFirestore()).toList(),
    };
  }
}
