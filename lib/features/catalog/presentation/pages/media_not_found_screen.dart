import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MediaNotFoundScreen extends StatelessWidget {
  final int mediaId;
  final String mediaType;

  const MediaNotFoundScreen({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Média introuvable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hide_image_outlined,
                size: 72,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Ce média n\'est plus disponible.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'ID: $mediaId • Type: $mediaType',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.goNamed('catalog'),
                icon: const Icon(Icons.movie_outlined),
                label: const Text('Retour au catalogue'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.goNamed('home');
                  }
                },
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
