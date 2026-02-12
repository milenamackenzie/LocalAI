import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2; // Profile is selected (index 2)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String username = 'Guest';
          String email = 'guest@localai.com';

          if (state is Authenticated) {
            username = state.user.username;
            email = state.user.email;
          }

          return Column(
            children: [
              const SizedBox(height: 32),
              CircleAvatar(
                radius: 50,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.person, size: 50, color: colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildProfileTile(context, Icons.bookmark_outline, 'My Bookmarks', () => context.push('/bookmarks')),
              _buildProfileTile(context, Icons.history, 'Chat History', () => context.push('/chat-history')),
              _buildProfileTile(context, Icons.settings_outlined, 'Settings', () => context.push('/settings')),
              _buildProfileTile(context, Icons.help_outline, 'Help & Feedback', () {}),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              icon: Icons.location_city_outlined,
              label: 'Places',
              index: 0,
            ),
            _buildNavButton(
              icon: Icons.explore,
              label: 'Discover',
              index: 1,
              isCenter: true,
            ),
            _buildNavButton(
              icon: Icons.person_outline,
              label: 'Profile',
              index: 2,
            ),
          ],
        ),
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

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    if (isCenter) {
      return GestureDetector(
        onTap: () => _onNavItemTapped(index),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.grey[200] 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/localai_logo.png',
                width: 56,
                height: 56,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : Colors.grey[600],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Handle navigation based on selected index
    switch (index) {
      case 0:
        context.go('/recommendations'); // Top Rated Places page
        break;
      case 1:
        context.go('/'); // Main map page
        break;
      case 2:
        // Already on profile page
        break;
    }
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('404 - Page Not Found')));
}
