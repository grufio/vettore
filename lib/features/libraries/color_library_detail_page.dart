import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/vendor_color_provider.dart';

class ColorLibraryDetailPage extends ConsumerWidget {
  const ColorLibraryDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorsAsync = ref.watch(vendorColorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schmincke Norma'),
      ),
      body: colorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (colors) {
          if (colors.isEmpty) {
            return const Center(child: Text('No colors found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Changed from 4 to 3 for wider cards
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.6, // Adjusted for more height
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final colorWithVariants = colors[index];
              final color = colorWithVariants.color;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3, // Give more space to the image
                      child: Image.asset(
                        color.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2, // Give less space to the text details
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Left-align text
                          children: [
                            Text(
                              color.name,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            ...colorWithVariants.variants.map((variant) {
                              return Text(
                                '${variant.size}ml - Stock: ${variant.stock}',
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
