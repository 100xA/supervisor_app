import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/presentation/secreviewer/sec_reviewer_thesis_assignment_screen.dart';

import 'package:supervisor_app/presentation/supervisor/supervisor_topic_form.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

class SupervisorHomeScreen extends ConsumerWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          ProviderScope(child: ThesisReviewerAssignmentScreen()),
          ProviderScope(child: SupervisorTopicsForm()),
          ThesesContent(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(currentIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Assignment'),
          BottomNavigationBarItem(icon: Icon(Icons.topic), label: 'Topics'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'My Theses'),
        ],
      ),
    );
  }
}

class ThesesContent extends StatelessWidget {
  const ThesesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Theses Screen'));
  }
}
