import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supervisor_app/domain/thesis.dart';
import 'package:supervisor_app/domain/topic.dart';

class Supervisor {
  final String id;
  final String name;
  final String email;
  final List<String> researchInterests;
  List<Topic> topics;
  final List<Thesis> supervisedTheses;

  Supervisor({
    required this.id,
    required this.name,
    required this.email,
    required this.researchInterests,
    required this.topics,
    required this.supervisedTheses,
  });

  factory Supervisor.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Supervisor(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      researchInterests: List<String>.from(data['researchInterests'] ?? []),
      topics: (data['announcedTopics'] as List? ?? [])
          .map((topic) => Topic.fromMap(topic))
          .toList(),
      supervisedTheses: (data['supervisedTheses'] as List? ?? [])
          .map((thesis) => Thesis.fromMap(thesis))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'researchInterests': researchInterests,
      'announcedTopics': topics.map((topic) => topic.toMap()).toList(),
      'supervisedTheses':
          supervisedTheses.map((thesis) => thesis.toMap()).toList(),
    };
  }

  // New method to announce a topic
  Future<void> announceTopic(Topic newTopic) async {
    // Add the new topic to the list
    topics.add(newTopic);

    // Update the Firestore document
    try {
      await FirebaseFirestore.instance
          .collection('supervisors')
          .doc(id)
          .update({
        'announcedTopics': topics.map((topic) => topic.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
