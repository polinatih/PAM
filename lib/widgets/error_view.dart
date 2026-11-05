import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Экран ошибки с повтором (C8): ошибка никогда не молчит и всегда имеет retry.
/// Используется на каждом экране, который загружает данные через модель.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          radius: 32,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 40, color: scheme.error),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: text.bodyLarge,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
