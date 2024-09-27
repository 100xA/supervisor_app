import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:supervisor_app/domain/supervisor.dart';
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
