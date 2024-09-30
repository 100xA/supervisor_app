import 'package:cloud_firestore/cloud_firestore.dart';

class Thesis {
  final String studentId;
  final String topic;
  final String status;
  final String firstReviewer;
  final String secondReviewer;
  final String secondReviewerId;
  final String invoiceStatus;

  Thesis({
    required this.studentId,
    required this.topic,
    required this.status,
    required this.secondReviewer,
    required this.firstReviewer,
    required this.secondReviewerId,
    required this.invoiceStatus,
  });

  factory Thesis.fromMap(Map<String, dynamic> map) {
    return Thesis(
      studentId: map['studentId'] ?? '',
      topic: map['topic'] ?? '',
      status: map['status'] ?? '',
      firstReviewer: map['firstReviewer'] ?? '',
      secondReviewer: map['secondReviewer'] ?? '',
      secondReviewerId: map['secondReviewerId'] ?? '',
      invoiceStatus: map['invoiceStatus'] ?? '',
    );
  }

  factory Thesis.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Thesis(
      studentId: doc.id,
      topic: data['topic'] ?? '',
      status: data['status'] ?? '',
      firstReviewer: data['firstReviewer'] ?? '',
      secondReviewer: data['secondReviewer'] ?? '',
      secondReviewerId: data['secondReviewerId'] ?? '',
      invoiceStatus: data['invoiceStatus'] ?? '',
    );
  }

  Thesis copyWith({
    String? studentId,
    String? topic,
    String? status,
    String? firstReviewer,
    String? secondReviewer,
    String? secondReviewerId,
    String? invoiceStatus,
  }) {
    return Thesis(
      studentId: studentId ?? this.studentId,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      firstReviewer: firstReviewer ?? this.firstReviewer,
      secondReviewer: secondReviewer ?? this.secondReviewer,
      secondReviewerId: secondReviewerId ?? this.secondReviewerId,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'topic': topic,
      'status': status,
      'firstReviewer': firstReviewer,
      'secondReviewer': secondReviewer,
      'secondReviewerId': secondReviewerId,
      'invoiceStatus': invoiceStatus,
    };
  }
}
