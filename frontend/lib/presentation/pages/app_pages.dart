import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.person, size: 50, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Milena Mackenzie',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'milena@test.com',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildProfileTile(context, Icons.bookmark_outline, 'My Bookmarks', () => context.push('/bookmarks')),
          _buildProfileTile(context, Icons.history, 'Chat History', () => context.push('/chat-history')),
          _buildProfileTile(context, Icons.settings_outlined, 'Settings', () => context.push('/settings')),
          _buildProfileTile(context, Icons.help_outline, 'Help & Feedback', () {}),
        ],
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('404 - Page Not Found')));
}
