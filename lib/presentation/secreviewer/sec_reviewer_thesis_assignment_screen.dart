import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/application/thesisAssignment/thesis_assignment_notifier.dart';
import 'package:supervisor_app/domain/supervisor.dart';
import 'package:supervisor_app/domain/thesis.dart';

final thesisAssignmentProvider =
    StateNotifierProvider<ThesisAssignmentNotifier, ThesisAssignmentState>(
        (ref) {
  return ThesisAssignmentNotifier(FirebaseFirestore.instance);
});

class ThesisReviewerAssignmentScreen extends ConsumerWidget {
  const ThesisReviewerAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(thesisAssignmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Second Reviewers'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Reviewers',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => ref
                        .read(thesisAssignmentProvider.notifier)
                        .setSearchQuery(value),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.unassignedTheses.length,
                    itemBuilder: (context, index) {
                      final thesis = state.unassignedTheses[index];
                      return ThesisCard(
                        thesis: thesis,
                        potentialReviewers: state.filteredReviewers,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class ThesisCard extends ConsumerWidget {
  final Thesis thesis;
  final List<Supervisor> potentialReviewers;

  const ThesisCard(
      {super.key, required this.thesis, required this.potentialReviewers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thesis.topic),
            const SizedBox(height: 8),
            Text('Author: ${thesis.studentId}'),
            const SizedBox(height: 8),
            Text('Primary Supervisor: ${thesis.firstReviewer}'),
            const SizedBox(height: 8),
            Text('Second Reviewer: ${thesis.secondReviewer}'),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Assign Second Reviewer'),
              onPressed: () => _showReviewerSelectionDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewerSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Second Reviewer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: potentialReviewers.length,
            itemBuilder: (context, index) {
              final reviewer = potentialReviewers[index];
              return ListTile(
                title: Text(reviewer.name),
                subtitle: Text(reviewer.email),
                onTap: () => _assignReviewer(context, ref, reviewer),
              );
            },
          ),
        ),
      ),
    );
  }

  void _assignReviewer(
      BuildContext context, WidgetRef ref, Supervisor reviewer) async {
    Navigator.of(context).pop(); // Close the dialog
    try {
      await ref
          .read(thesisAssignmentProvider.notifier)
          .assignReviewer(thesis, reviewer);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Second reviewer assigned successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign second reviewer: $e')),
        );
      }
    }
  }
}
