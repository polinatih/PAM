import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/session_card.dart';
import 'session_form_screen.dart';

/// Дневник тренировок: сессии в хронологическом порядке (новые сверху).
class WorkoutDiaryScreen extends StatelessWidget {
  const WorkoutDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник тренировок'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: mockSessions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) => SessionCard(
          session: mockSessions[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionFormScreen(session: mockSessions[i]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SessionFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Новая сессия'),
      ),
    );
  }
}
