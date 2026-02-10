import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/user_hub_bloc.dart';
import '../../widgets/map_background.dart';

class UserPreferencePage extends StatefulWidget {
  const UserPreferencePage({super.key});

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  final List<String> _categories = [
    'Fitness', 'Food', 'Technology', 'Art', 'Music', 
    'Nature', 'History', 'Sports', 'Nightlife', 'Shopping'
  ];
  final Set<String> _selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<UserHubBloc, UserHubState>(
      listener: (context, state) {
        if (state is UserHubLoaded) {
          context.go('/');
        } else if (state is UserHubError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: MapBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'What are you\ninterested in?',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select at least 3 categories to help us personalize your recommendations.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                            selectedColor: colorScheme.primaryContainer,
                            checkmarkColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? colorScheme.primary : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _selectedCategories.length >= 3
                          ? () {
                              final authState = context.read<AuthBloc>().state;
                              if (authState is Authenticated) {
                                context.read<UserHubBloc>().add(
                                  SyncPreferencesRequested(authState.user.id, _selectedCategories.toList()),
                                );
                              }
                            }
                          : null,
                      child: BlocBuilder<UserHubBloc, UserHubState>(
                        builder: (context, state) {
                          if (state is UserHubLoading) {
                            return const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            );
                          }
                          return const Text('Get Started');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Selected ${_selectedCategories.length}/3',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _selectedCategories.length >= 3 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
