import 'package:flutter/material.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  double _distance = 5.0;
  double _minRating = 4.0;
  final List<String> _vibes = ['Quiet', 'Social', 'Productive', 'Active', 'Romantic'];
  final Set<String> _selectedVibes = {'Quiet'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Refine Search',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          Text('Distance: ${_distance.toInt()} km', style: theme.textTheme.titleSmall),
          Slider(
            value: _distance,
            min: 1,
            max: 50,
            onChanged: (val) => setState(() => _distance = val),
          ),
          
          const SizedBox(height: 16),
          Text('Minimum Rating: $_minRating', style: theme.textTheme.titleSmall),
          Slider(
            value: _minRating,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (val) => setState(() => _minRating = val),
          ),
          
          const SizedBox(height: 16),
          Text('Vibe', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _vibes.map((vibe) {
              final isSelected = _selectedVibes.contains(vibe);
              return FilterChip(
                label: Text(vibe),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedVibes.add(vibe);
                    } else {
                      _selectedVibes.remove(vibe);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
