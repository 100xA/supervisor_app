import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/application/contact/contact_form_notifier.dart';
import 'package:supervisor_app/domain/topic.dart';

final contactFormProvider =
    StateNotifierProvider<ContactFormNotifier, ContactFormState>((ref) {
  return ContactFormNotifier();
});

class SupervisorContactForm extends ConsumerWidget {
  final Topic topic;

  const SupervisorContactForm({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(contactFormProvider);
    final formNotifier = ref.read(contactFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Supervisor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Topic: ${topic.title}',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: formState.name,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: formNotifier.updateName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: formState.email,
                decoration: const InputDecoration(
                  labelText: 'Your Email',
                  border: OutlineInputBorder(),
                ),
                onChanged: formNotifier.updateEmail,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: formState.message,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                onChanged: formNotifier.updateMessage,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickPDF(formNotifier),
                icon: const Icon(Icons.upload_file),
                label: Text(
                    formState.pdfFile != null ? 'PDF Selected' : 'Upload PDF'),
              ),
              if (formState.pdfFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      'Selected file: ${formState.pdfFile!.path.split('/').last}'),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: formState.submissionState.isLoading
                    ? null
                    : () => _submitForm(context, formNotifier),
                child: formState.submissionState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Send Message'),
              ),
              if (formState.submissionState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Error: ${formState.submissionState.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPDF(ContactFormNotifier formNotifier) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      formNotifier.updatePdfFile(File(result.files.single.path!));
    }
  }

  void _submitForm(BuildContext context, ContactFormNotifier formNotifier) {
    // Here you would typically validate the form
    // Since we're not using a Form with a GlobalKey, we'll just submit
    formNotifier.submitForm(topic).then((_) async {
      if (!formNotifier.state.submissionState.hasError) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form submitted successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error submitting form')),
          );
        }
      }
    });
  }
}
