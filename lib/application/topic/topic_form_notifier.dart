import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/domain/supervisor.dart';
import 'package:supervisor_app/domain/topic.dart';

class TopicFormState {
  final String title;
  final String description;
  final String email;
  final bool isSubmitting;
  final String? emailError;

  TopicFormState({
    this.title = '',
    this.description = '',
    this.email = '',
    this.isSubmitting = false,
    this.emailError,
  });

  TopicFormState copyWith({
    String? title,
    String? description,
    String? email,
    bool? isSubmitting,
    String? emailError,
  }) {
    return TopicFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailError: emailError,
    );
  }
}

// Define a StateNotifier to manage the form state
class TopicFormNotifier extends StateNotifier<TopicFormState> {
  TopicFormNotifier() : super(TopicFormState());

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  Future<void> validateEmail() async {
    final email = state.email;
    if (email.isEmpty) {
      state = state.copyWith(emailError: 'Please enter an email');
      return;
    }

    try {
      final supervisorDoc = await FirebaseFirestore.instance
          .collection('supervisors')
          .where('email', isEqualTo: email)
          .get();

      if (supervisorDoc.docs.isEmpty) {
        state =
            state.copyWith(emailError: 'No supervisor found with this email');
      } else {
        state = state.copyWith(emailError: null);
      }
    } catch (e) {
      state = state.copyWith(emailError: 'Error validating email');
    }
  }

  Future<void> submitForm() async {
    await validateEmail();
    if (state.emailError != null) return;

    state = state.copyWith(isSubmitting: true);
    try {
      final supervisorDoc = await FirebaseFirestore.instance
          .collection('supervisors')
          .where('email', isEqualTo: state.email)
          .get();

      if (supervisorDoc.docs.isEmpty) throw Exception('No supervisor found');

      double topicsCount =
          supervisorDoc.docs.first['announcedTopics'].length.toDouble();

      String name = supervisorDoc.docs.first['name'];

      final supervisor = Supervisor.fromFirestore(supervisorDoc.docs.first);

      final newTopic = Topic(
        title: state.title,

        description: state.description,
        id: 'topic_${name}_${topicsCount + 1}',
        // Add any other required fields for your Topic model
      );

      await supervisor.announceTopic(newTopic);

      // Clear the form after successful submission
      state = TopicFormState();
    } catch (e) {
      state = state.copyWith(
          isSubmitting: false, emailError: 'Failed to announce topic');
      rethrow;
    }
  }
}
