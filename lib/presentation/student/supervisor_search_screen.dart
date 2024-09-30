import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supervisor_app/application/search/search_notifier.dart';
import 'package:supervisor_app/data/search_repo.dart';

import 'package:supervisor_app/data/supervisor_repo.dart';
import 'package:supervisor_app/domain/search_result.dart';
import 'package:supervisor_app/domain/topic.dart';
import 'package:supervisor_app/presentation/student/supervisor_contact_form.dart';

final supervisorRepositoryProvider = Provider((ref) => SupervisorRepository());

final searchRepositoryProvider = Provider((ref) {
  final supervisorRepo = ref.watch(supervisorRepositoryProvider);
  return SearchRepository(supervisorRepo);
});

final searchProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<SearchResult>>((ref) {
  final searchRepository = ref.watch(searchRepositoryProvider);
  return SearchNotifier(searchRepository);
});

class SupervisorSearchScreen extends ConsumerWidget {
  const SupervisorSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Themensuche')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Suche nach einem Thema",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  ref.read(searchProvider.notifier).search(value),
            ),
          ),
          Expanded(
            child: searchResults.when(
              data: (results) => ListView(
                children: [
                  if (results.exactMatches.isNotEmpty) ...[
                    const ListTile(
                        title: Text('Matches',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    ...results.exactMatches
                        .map((topic) => _buildTopicTile(topic, context)),
                  ],
                  if (results.recommendations.isNotEmpty) ...[
                    const Divider(),
                    const ListTile(
                        title: Text('Recommendations',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    ...results.recommendations
                        .map((topic) => _buildTopicTile(topic, context)),
                  ],
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTile(Topic topic, BuildContext context) {
    return ListTile(
      title: Text(topic.title),
      subtitle: Text(topic.description),
      isThreeLine: true,
      trailing: ElevatedButton(
        child: const Text('Contact'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProviderScope(child: SupervisorContactForm(topic: topic)),
            ),
          );
        },
      ),
    );
  }
}
