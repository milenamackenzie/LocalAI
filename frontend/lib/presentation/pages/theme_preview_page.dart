import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/custom_theme_extension.dart';
import '../blocs/theme_bloc.dart';

class ThemePreviewPage extends StatelessWidget {
  const ThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final customTheme = theme.extension<CustomThemeExtension>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalAI Theme Preview'),
        centerTitle: true,
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                  context.read<ThemeBloc>().add(ThemeChanged(newMode));
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Headline Large', style: theme.textTheme.headlineLarge),
            Text('Headline Medium', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('Body Large', style: theme.textTheme.bodyLarge),
            Text('Body Medium', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            
            const Text('Color Palette', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorChip(label: 'Primary', color: colorScheme.primary, onColor: colorScheme.onPrimary),
                _ColorChip(label: 'Secondary', color: colorScheme.secondary, onColor: colorScheme.onSecondary),
                _ColorChip(label: 'Tertiary', color: colorScheme.tertiary, onColor: colorScheme.onTertiary),
                _ColorChip(label: 'Surface', color: colorScheme.surface, onColor: colorScheme.onSurface, border: true),
                _ColorChip(label: 'Error', color: colorScheme.error, onColor: colorScheme.onError),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text('Custom Theme Extension', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                gradient: customTheme?.cardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Custom Card Gradient', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.check_circle, color: customTheme?.successColor),
                const SizedBox(width: 8),
                Text('Success Color', style: TextStyle(color: customTheme?.successColor)),
                const SizedBox(width: 24),
                Icon(Icons.warning, color: customTheme?.warningColor),
                const SizedBox(width: 8),
                Text('Warning Color', style: TextStyle(color: customTheme?.warningColor)),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text('Buttons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Filled')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text('Inputs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.visibility),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;
  final bool border;

  const _ColorChip({
    required this.label,
    required this.color,
    required this.onColor,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: border ? Border.all(color: Colors.grey.withOpacity(0.5)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: onColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
