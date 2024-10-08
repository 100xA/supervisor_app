import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/data/supervisor_repo.dart';

import 'package:supervisor_app/domain/thesis.dart';

class SupervisorOverviewScreen extends ConsumerWidget {
  final String supervisorId;

  const SupervisorOverviewScreen({super.key, required this.supervisorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supervisorAsyncValue = ref.watch(supervisorProvider(supervisorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thesis Overview'),
      ),
      body: supervisorAsyncValue.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (supervisor) {
          final supervisedStatusCounts =
              ref.watch(supervisedThesisStatusCountsProvider(supervisor));
          final secondReviewerStatusCounts =
              ref.watch(secondReviewerThesisStatusCountsProvider(supervisor));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thesis Overview for ${supervisor.name}',
                ),
                const SizedBox(height: 16),
                _buildThesisSection(
                  ref,
                  context,
                  'Supervised Theses',
                  supervisor.supervisedTheses,
                  supervisedStatusCounts,
                ),
                const Divider(height: 32, thickness: 2),
                _buildThesisSection(
                  ref,
                  context,
                  'Second Reviewer Theses',
                  supervisor.thesesAsSecondReviewer,
                  secondReviewerStatusCounts,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThesisSection(WidgetRef ref, BuildContext context, String title,
      List<Thesis> theses, Map<String, int> statusCounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
        ),
        const SizedBox(height: 8),
        Text(
          'Total Theses: ${theses.length}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 16),
        Text(
          'Recent Theses:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: theses.length,
          itemBuilder: (context, index) {
            final thesis = theses[index];
            final List<String> statusOptions = [
              "written out",
              "started",
              "handed in",
              "invoiced",
              "paid",
            ];
            if (thesis.status.isNotEmpty &&
                !statusOptions.contains(thesis.status)) {
              statusOptions.add(thesis.status);
            }

            return ListTile(
              title: Text(thesis.topic,
                  style: Theme.of(context).textTheme.bodyMedium),
              subtitle: Text('Status: ${_formatStatus(thesis.status)}'),
              trailing: DropdownButton<String>(
                value: thesis.status,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    ref
                        .read(supervisorProvider(thesis.firstReviewer))
                        .whenData((supervisor) {
                      supervisor.changeThesisStatus(thesis.topic, newValue);
                    });

                    ref.refresh(supervisorProvider(supervisorId));
                  }
                },
                items:
                    statusOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_formatStatus(value)),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
