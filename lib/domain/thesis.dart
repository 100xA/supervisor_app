class Thesis {
  final String studentId;
  final String topic;
  final String status;
  final String secondReviewer;
  final String invoiceStatus;

  Thesis({
    required this.studentId,
    required this.topic,
    required this.status,
    required this.secondReviewer,
    required this.invoiceStatus,
  });

  factory Thesis.fromMap(Map<String, dynamic> map) {
    return Thesis(
      studentId: map['studentId'] ?? '',
      topic: map['topic'] ?? '',
      status: map['status'] ?? '',
      secondReviewer: map['secondReviewer'] ?? '',
      invoiceStatus: map['invoiceStatus'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'topic': topic,
      'status': status,
      'secondReviewer': secondReviewer,
      'invoiceStatus': invoiceStatus,
    };
  }
}
