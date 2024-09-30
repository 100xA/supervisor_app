import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/domain/topic.dart';

class ContactFormState {
  final String name;
  final String email;
  final String message;
  final File? pdfFile;
  final AsyncValue<void> submissionState;

  ContactFormState({
    this.name = '',
    this.email = '',
    this.message = '',
    this.pdfFile,
    this.submissionState = const AsyncValue.data(null),
  });

  ContactFormState copyWith({
    String? name,
    String? email,
    String? message,
    File? pdfFile,
    AsyncValue<void>? submissionState,
  }) {
    return ContactFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      pdfFile: pdfFile ?? this.pdfFile,
      submissionState: submissionState ?? this.submissionState,
    );
  }
}

class ContactFormNotifier extends StateNotifier<ContactFormState> {
  ContactFormNotifier() : super(ContactFormState());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateMessage(String message) {
    state = state.copyWith(message: message);
  }

  void updatePdfFile(File? file) {
    state = state.copyWith(pdfFile: file);
  }

  Future<void> submitForm(Topic topic) async {
    state = state.copyWith(submissionState: const AsyncValue.loading());
    try {
      // Upload PDF to Firebase Storage if provided
      String? pdfUrl;
      if (state.pdfFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'expose/${topic.title}_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await storageRef.putFile(state.pdfFile!);
        pdfUrl = await storageRef.getDownloadURL();
      }

      // Save form data to Firestore
      await FirebaseFirestore.instance.collection('proposals').add({
        'name': state.name,
        'email': state.email,
        'message': state.message,
        'topicId': topic.id,
        'topicTitle': topic.title,
        'expose': pdfUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(submissionState: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(submissionState: AsyncValue.error(e, stack));
    }
  }
}
