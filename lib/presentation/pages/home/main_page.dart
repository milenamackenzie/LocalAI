import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth_bloc.dart';
import '../../../core/database/local_database.dart';
import '../../../core/services/ai_service_mistral.dart';
import '../../../injection_container.dart' as di;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _promptController = TextEditingController();
  int _selectedIndex = 1; // Middle button (Main page) is selected
  
  // Default location (London, UK)
  LatLng _currentLocation = LatLng(51.5074, -0.1278);
  
  final List<Marker> _markers = [];
  final List<String> _searchHistory = []; // Store search prompts
  final Set<String> _bookmarkedPrompts = {}; // Store bookmarked prompts
  bool _showHistory = false; // Toggle history panel
  double _historyHeight = 200.0; // Height of history panel
  bool _isLoading = false; // Loading state for AI search
  double _searchRadius = 3000; // 3km default search radius
  bool _isLocationDetermined = false; // GPS location status
  String _locationStatus = 'Getting location...'; // Location status message
  
  late final LocalDatabase _localDatabase;
  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    _localDatabase = di.sl<LocalDatabase>();
    _aiService = AIService();
    _loadBookmarkedPrompts();
    _determineUserLocation();
  }

  Future<void> _determineUserLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permission denied';
          _isLocationDetermined = true; // Use default London location
        });
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (!mounted) return;
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationStatus = 'Location found';
        _isLocationDetermined = true;
      });
      
      // Center map on user's location with a small delay to ensure map is ready
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        try {
          _mapController.move(_currentLocation, 15.0);
        } catch (e) {
          print('Error moving map: $e');
        }
      }
      
    } catch (e) {
      print('Error getting location: $e');
      if (!mounted) return;
      setState(() {
        _locationStatus = 'Using default location (London)';
        _isLocationDetermined = true; // Use default London location
      });
    }
  }
  
  Future<void> _loadBookmarkedPrompts() async {
    final bookmarkedChats = await _localDatabase.getBookmarkedChats();
    setState(() {
      _bookmarkedPrompts.clear();
      for (var chat in bookmarkedChats) {
        _bookmarkedPrompts.add(chat['query'] as String);
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
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
        // Already on main page
        break;
      case 2:
        context.go('/profile'); // User profile
        break;
    }
  }

  Future<void> _handleAIPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isNotEmpty) {
      // Add to search history
      setState(() {
        _searchHistory.insert(0, prompt); // Add to beginning of list
        _showHistory = true; // Show the history panel
        _isLoading = true; // Show loading state
      });
      
      // Clear prompt immediately
      _promptController.clear();
      
      try {
        // Process the AI search with current radius
        final locations = await _aiService.searchLocations(
          prompt, 
          _currentLocation, 
          radius: _searchRadius
        );
        
        setState(() {
          _markers.clear();
          // Keep the current location marker (red pin)
          _markers.add(
            Marker(
              point: _currentLocation,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.my_location,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
          // Add search result markers
          _markers.addAll(locations);
          _isLoading = false;
        });
        
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${locations.length} locations matching "$prompt" in ${(_searchRadius/1000).round()}km radius'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleBookmark(String prompt) async {
    final isBookmarked = _bookmarkedPrompts.contains(prompt);
    
    try {
      // Update database
      await _localDatabase.toggleChatBookmark(prompt, !isBookmarked);
      
      // Update UI
      setState(() {
        if (isBookmarked) {
          _bookmarkedPrompts.remove(prompt);
        } else {
          _bookmarkedPrompts.add(prompt);
        }
      });
      
      // Show feedback to user
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBookmarked ? 'Bookmark removed' : 'Saved to Chat History'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling bookmark: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save bookmark'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final mapHeight = size.height - 70; // Full height minus just the prompt bar (nav bar is separate)

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // OpenStreetMap (fills to prompt bar)
          SizedBox(
            height: mapHeight,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 13.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.localai.app',
                  tileBuilder: (context, widget, tile) {
                    return ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.grey.withOpacity(0.1),
                        BlendMode.saturation,
                      ),
                      child: widget,
                    );
                  },
                ),
                // Search radius circle overlay
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentLocation,
                      radius: _searchRadius,
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.1),
                      borderColor: Colors.blue.withOpacity(0.4),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Searching locations...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // User Profile Icon with Username (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String username = 'GUEST';
                if (state is Authenticated) {
                  username = state.user.username.toUpperCase();
                }
                
                return GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Search History Panel (Swipeable)
          if (_showHistory && _searchHistory.isNotEmpty)
            Positioned(
              bottom: 70, // Above the prompt bar
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _historyHeight = (_historyHeight - details.delta.dy).clamp(100.0, 400.0);
                  });
                },
                onVerticalDragEnd: (details) {
                  // If swiped down significantly, hide the panel
                  if (details.primaryVelocity! > 500) {
                    setState(() {
                      _showHistory = false;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _historyHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Searches',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _showHistory = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      // History list
                      Expanded(
                        child: ListView.builder(
                          itemCount: _searchHistory.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final prompt = _searchHistory[index];
                            final isBookmarked = _bookmarkedPrompts.contains(prompt);
                            return ListTile(
                              leading: Icon(
                                Icons.history,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              title: Text(
                                prompt,
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  color: isBookmarked ? theme.colorScheme.primary : Colors.grey[600],
                                  size: 24,
                                ),
                                onPressed: () {
                                  _toggleBookmark(prompt);
                                },
                              ),
                              onTap: () {
                                _promptController.text = prompt;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Search Radius Control (above prompt bar)
          Positioned(
            bottom: 70, // Above the prompt bar
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${(_searchRadius/1000).round()}km',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.tune, size: 16, color: Colors.grey[600]),
                    onSelected: (String value) {
                      setState(() {
                        _searchRadius = double.parse(value);
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: '1000',
                          child: Text('1km radius'),
                        ),
                        PopupMenuItem<String>(
                          value: '3000',
                          child: Text('3km radius'),
                        ),
                        PopupMenuItem<String>(
                          value: '5000',
                          child: Text('5km radius'),
                        ),
                        PopupMenuItem<String>(
                          value: '10000',
                          child: Text('10km radius'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),

          // AI Prompt Bar (at bottom of body, right above navigation bar)
          Positioned(
            bottom: 0, // At bottom of Stack (navigation bar is separate below this)
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // History toggle button
                  if (_searchHistory.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        _showHistory ? Icons.keyboard_arrow_down : Icons.history,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _showHistory = !_showHistory;
                        });
                      },
                    ),
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: 'Where do you want to go?',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _handleAIPrompt(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.white),
                        onPressed: _handleAIPrompt,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(
              icon: Icons.location_city_outlined,
              label: 'Places',
              index: 0,
            ),
            _buildNavButton(
              icon: Icons.auto_awesome,
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
                fontSize: 9, // Smaller font
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
}
