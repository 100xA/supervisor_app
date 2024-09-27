import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:supervisor_app/domain/student.dart';

class StudentRepository {
  final CollectionReference _studentsCollection =
      FirebaseFirestore.instance.collection('students');

  Future<List<Student>> searchStudents(String query) async {
    QuerySnapshot snapshot = await _studentsCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
  }

  Future<void> addStudent(Student student) async {
    await _studentsCollection.add(student.toMap());
  }

  Future<void> updateStudent(Student student) async {
    await _studentsCollection.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String studentId) async {
    await _studentsCollection.doc(studentId).delete();
  }

  Stream<List<Student>> streamAllStudents() {
    return _studentsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    });
  }
}
