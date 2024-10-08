import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/presentation/student/supervisor_search_screen.dart';
import 'package:supervisor_app/presentation/supervisor/supervisor_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Text(
                'Betreuer-App',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            Image.asset(
              'assets/images/logo.png',
              width: 400,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ProviderScope(
                            child: SupervisorHomeScreen())));
                  },
                  child: Text(
                    "Betreuer",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ProviderScope(
                            child: SupervisorSearchScreen())));
                  },
                  child: Text(
                    "Student",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
