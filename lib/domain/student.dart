import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final String proposedTopic;
  final String thesisStatus;
  final DateTime proposalSubmissionDate;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.proposedTopic,
    required this.thesisStatus,
    required this.proposalSubmissionDate,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      proposedTopic: data['proposedTopic'] ?? '',
      thesisStatus: data['thesisStatus'] ?? '',
      proposalSubmissionDate:
          (data['proposalSubmissionDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'proposedTopic': proposedTopic,
      'thesisStatus': thesisStatus,
      'proposalSubmissionDate': Timestamp.fromDate(proposalSubmissionDate),
    };
  }
}
