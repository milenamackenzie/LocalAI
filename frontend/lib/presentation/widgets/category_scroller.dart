import 'package:flutter/material.dart';

class CategoryScroller extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Cafe', 'icon': Icons.coffee},
    {'name': 'Gym', 'icon': Icons.fitness_center},
    {'name': 'Park', 'icon': Icons.park},
    {'name': 'Tech', 'icon': Icons.computer},
    {'name': 'Art', 'icon': Icons.palette},
  ];

  final String selectedCategory;
  final Function(String) onCategorySelected;

  CategoryScroller({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name'];

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => onCategorySelected(category['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
