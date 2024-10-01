import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supervisor_app/domain/supervisor.dart';
import 'package:supervisor_app/domain/thesis.dart';
import 'package:supervisor_app/domain/topic.dart';
import 'dart:developer' as developer;

class SupervisorRepository {
  final CollectionReference _supervisorsCollection =
      FirebaseFirestore.instance.collection('supervisors');

  Future<List<Topic>> searchTopics(String query) async {
    QuerySnapshot snapshot = await _supervisorsCollection.get();
    List<Supervisor> supervisors =
        snapshot.docs.map((doc) => Supervisor.fromFirestore(doc)).toList();

    var test = supervisors
        .expand((supervisor) => supervisor.topics)
        .where((topic) =>
            topic.title.toLowerCase().contains(query.toLowerCase()) ||
            topic.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    developer.log('searchTopics: $test');
    return test;
  }
}

final supervisorProvider =
    StreamProvider.autoDispose.family<Supervisor, String>((ref, supervisorId) {
  return FirebaseFirestore.instance
      .collection('supervisors')
      .doc(supervisorId)
      .snapshots()
      .map((snapshot) => Supervisor.fromFirestore(snapshot));
});

// Helper provider to get thesis status counts for supervised theses
final supervisedThesisStatusCountsProvider =
    Provider.family<Map<String, int>, Supervisor>((ref, supervisor) {
  return _getStatusCounts(supervisor.supervisedTheses);
});

// Helper provider to get thesis status counts for second reviewer theses
final secondReviewerThesisStatusCountsProvider =
    Provider.family<Map<String, int>, Supervisor>((ref, supervisor) {
  return _getStatusCounts(supervisor.thesesAsSecondReviewer);
});

Map<String, int> _getStatusCounts(List<Thesis> theses) {
  final counts = {
    'In Discussion': 0,
    'Registered': 0,
    'Submitted': 0,
    'Colloquium Held': 0,
  };

  for (var thesis in theses) {
    switch (thesis.status) {
      case 'in_discussion':
        counts['In Discussion'] = (counts['In Discussion'] ?? 0) + 1;
        break;
      case 'registered':
        counts['Registered'] = (counts['Registered'] ?? 0) + 1;
        break;
      case 'submitted':
        counts['Submitted'] = (counts['Submitted'] ?? 0) + 1;
        break;
      case 'colloquium_held':
        counts['Colloquium Held'] = (counts['Colloquium Held'] ?? 0) + 1;
        break;
    }
  }

  return counts;
}
