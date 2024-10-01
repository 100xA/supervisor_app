import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/application/topic/topic_form_notifier.dart';

final topicFormProvider =
    StateNotifierProvider<TopicFormNotifier, TopicFormState>((ref) {
  return TopicFormNotifier();
});

class SupervisorTopicsForm extends ConsumerWidget {
  const SupervisorTopicsForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(topicFormProvider);
    final formNotifier = ref.read(topicFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announce New Topic'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  errorText: formState.emailError,
                ),
                onChanged: formNotifier.setEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter the title of your topic',
                ),
                onChanged: formNotifier.setTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Describe your topic',
                ),
                maxLines: 5,
                onChanged: formNotifier.setDescription,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: formState.isSubmitting
                    ? null
                    : () async {
                        try {
                          await formNotifier.submitForm();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Topic announced successfully!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Failed to announce topic. Please try again.')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: formState.isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Announce Topic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
