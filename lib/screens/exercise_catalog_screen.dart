import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/exercise_card.dart';
import 'exercise_detail_screen.dart';

/// Каталог упражнений: поиск + фильтр по группе мышц (пока только визуально).
class ExerciseCatalogScreen extends StatelessWidget {
  const ExerciseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог упражнений')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchBar(
              hintText: 'Поиск упражнения',
              leading: Icon(Icons.search),
              elevation: WidgetStatePropertyAll(0.0),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: muscleGroups.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) => FilterChip(
                label: Text(muscleGroups[i]),
                selected: i == 0, // «Все» выбрано; работать начнёт на L4
                onSelected: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: mockExercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) => ExerciseCard(
                exercise: mockExercises[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ExerciseDetailScreen(exercise: mockExercises[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
