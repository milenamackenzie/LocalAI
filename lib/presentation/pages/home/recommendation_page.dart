import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_bottom_navigation.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> 
    with SingleTickerProviderStateMixin {
  int _selectedTab = 1; // Middle tab (User Favourites) selected by default
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TOP RATED PLACES'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Removes default back arrow
      ),
      body: Column(
        children: [
          // Tab Buttons - Spread across width
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Places Tab (left)
                _buildTabButton(
                  'PLACES',
                  0,
                  Icons.location_city_outlined,
                  _selectedTab == 0,
                  () => setState(() => _selectedTab = 0),
                ),
                // User Favourites Tab (middle - default)
                _buildTabButton(
                  'USER FAVOURITES',
                  1,
                  Icons.favorite,
                  _selectedTab == 1,
                  () => setState(() => _selectedTab = 1),
                ),
                // Events Tab (right)
                _buildTabButton(
                  'EVENTS',
                  2,
                  Icons.event,
                  _selectedTab == 2,
                  () => setState(() => _selectedTab = 2),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Content Area
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                // Places Tab Content
                _buildPlacesContent(),
                // User Favourites Tab Content  
                _buildFavouritesContent(),
                // Events Tab Content
                _buildEventsContent(),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar - Same as main page
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

  Widget _buildTabButton(
    String title,
    int index,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10, // Smaller font as requested
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesContent() {
    final places = [
      {
        'title': 'Sky Garden Rooftop Bar',
        'location': 'City of London',
        'category': 'Bar',
        'score': 4.8,
        'description': 'Stunning rooftop bar with panoramic city views',
        'features': ['Rooftop', 'City Views', 'Cocktails'],
        'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80',
      },
      {
        'title': 'Borough Market',
        'location': 'Southwark',
        'category': 'Market',
        'score': 4.6,
        'description': 'Historic food market with diverse local products',
        'features': ['Food Stalls', 'Local Products', 'Weekend'],
        'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
      },
      {
        'title': 'Thames Riverside Walk',
        'location': 'South Bank',
        'category': 'Park',
        'score': 4.5,
        'description': 'Scenic riverside walking path with iconic views',
        'features': ['River Views', 'Walking Path', 'Tourist Spot'],
        'image': 'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?w=800&q=80',
      },
      {
        'title': 'Covent Garden Piazza',
        'location': 'Covent Garden',
        'category': 'Tourist',
        'score': 4.7,
        'description': 'Historic market square with street performers',
        'features': ['Historic', 'Photos', 'Landmark'],
        'image': 'https://images.unsplash.com/photo-1549918864-48ac978761a4?w=800&q=80',
      },
      {
        'title': 'Camden Market',
        'location': 'Camden Town',
        'category': 'Market',
        'score': 4.4,
        'description': 'Alternative market with unique crafts and street food',
        'features': ['Alternative', 'Street Food', 'Crafts'],
        'image': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
      },
      {
        'title': 'The Ledbury',
        'location': 'Notting Hill',
        'category': 'Restaurant',
        'score': 4.9,
        'description': 'Michelin-starred fine dining restaurant',
        'features': ['Fine Dining', 'British Cuisine', 'Wine Bar'],
        'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('TOP RATED PLACES', Icons.star),
          const SizedBox(height: 12),
          ...places.map((place) => _buildPlaceListCard(place)).toList(),
        ],
      ),
    );
  }

  Widget _buildFavouritesContent() {
    final favourites = [
      {
        'title': 'Hyde Park',
        'location': 'Central London',
        'category': 'Park',
        'score': 4.8,
        'description': 'Massive green space perfect for relaxation and recreation',
        'features': ['Green Space', 'Lakes', 'Recreation', 'Events'],
        'visits': '2M+ visits/year',
        'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80',
      },
      {
        'title': 'The British Museum',
        'location': 'Bloomsbury',
        'category': 'Museum',
        'score': 4.9,
        'description': 'World-famous museum with extensive historical collections',
        'features': ['Historic', 'Free Entry', 'Educational', 'World Class'],
        'visits': '5M+ visits/year',
        'image': 'https://images.unsplash.com/photo-1565299999261-28ba859020f2?w=800&q=80',
      },
      {
        'title': 'Dishoom',
        'location': 'Multiple Locations',
        'category': 'Restaurant',
        'score': 4.7,
        'description': 'Everyone\'s favorite Bombay-style cafe',
        'features': ['Indian Cuisine', 'Cocktails', 'Trendy', 'Popular'],
        'visits': '1M+ visits/year',
        'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
      },
      {
        'title': 'Tower Bridge',
        'location': 'Tower Hamlets',
        'category': 'Tourist',
        'score': 4.8,
        'description': 'Iconic London landmark and tourist attraction',
        'features': ['Landmark', 'Photos', 'Historic', 'Views'],
        'visits': '3M+ visits/year',
        'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80',
      },
      {
        'title': 'Shoreditch',
        'location': 'East London',
        'category': 'Nightclub',
        'score': 4.6,
        'description': 'Vibrant nightlife district loved by everyone',
        'features': ['Nightlife', 'Bars', 'Clubs', 'Trendy'],
        'visits': '500K+ visits/year',
        'image': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=800&q=80',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('EVERYONE\'S TOP FAVOURITES', Icons.favorite),
          const SizedBox(height: 12),
          ...favourites.map((fav) => _buildPlaceListCard(fav)).toList(),
        ],
      ),
    );
  }

  Widget _buildEventsContent() {
    final events = [
      {
        'title': 'Summer Music Festival',
        'date': 'July 15-22',
        'location': 'Hyde Park',
        'category': 'Music',
        'attendees': 15000,
        'image': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&q=80',
        'price': '£45-120',
      },
      {
        'title': 'Food & Wine Festival',
        'date': 'August 3-6',
        'location': 'Borough Market',
        'category': 'Food',
        'attendees': 8500,
        'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
        'price': '£25-65',
      },
      {
        'title': 'Art Gallery Opening',
        'date': 'July 28',
        'location': 'Tate Modern',
        'category': 'Art',
        'attendees': 500,
        'image': 'https://images.unsplash.com/photo-1577083552431-6e5fd01988ec?w=800&q=80',
        'price': 'Free',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('UPCOMING EVENTS', Icons.event),
          const SizedBox(height: 12),
          
          // Event Cards
          ...events.map((event) => _buildEventCard(event)).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceGrid(List<Map<String, dynamic>> places) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildPlaceCard(place);
      },
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 2,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(place['category'] as String),
                      _getCategoryColor(place['category'] as String).withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(place['category'] as String),
                    size: 48,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            
            // Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Score
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place['title'] ?? 'Unknown Place',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(place['score'] as double),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            place['score'].toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Category and Features
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            place['category'] ?? 'General',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Features Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (place['features'] as List<dynamic>?)
                              ?.map((feature) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      feature.toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ))
                              .toList() ?? [],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: event['image'] != null
                  ? Image.network(
                      event['image'],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to gradient if image fails
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepPurple,
                                Colors.deepPurple.shade300,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.event,
                              size: 48,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple,
                            Colors.deepPurple.shade300,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.event,
                          size: 48,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
            ),
          ),
          
          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['title'] ?? 'Event',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          event['date'] ?? 'Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          event['price'] ?? 'Price',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Location and Category
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      event['location'] ?? 'Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Attendees
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${event['attendees'] ?? 0} attending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceListCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Place Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: place['image'] != null
                  ? Image.network(
                      place['image'],
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to gradient if image fails
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getCategoryColor(place['category'] as String),
                                _getCategoryColor(place['category'] as String).withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(place['category'] as String),
                              size: 48,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCategoryColor(place['category'] as String),
                            _getCategoryColor(place['category'] as String).withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(place['category'] as String),
                          size: 48,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
            ),
          ),
          
          // Place Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Score
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place['title'] ?? 'Place',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getScoreColor(place['score'] as double),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            place['score'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description
                if (place['description'] != null)
                  Text(
                    place['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 8),
                
                // Location
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      place['location'] ?? 'Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (place['visits'] != null) ...[
                      const Spacer(),
                      Text(
                        place['visits'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Features Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (place['features'] as List<dynamic>?)
                          ?.map((feature) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(place['category'] as String).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  feature.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _getCategoryColor(place['category'] as String),
                                  ),
                                ),
                              ))
                          .toList() ?? [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.7) return Colors.amber;
    if (score >= 4.3) return Colors.blue;
    return Colors.grey;
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isSelected = 0 == index; // Always select current page (recommendations = 0)
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

  void _onNavItemTapped(int index) {
    // Handle navigation based on selected index
    switch (index) {
      case 0:
        // Already on recommendations page
        break;
      case 1:
        // Discover - go to main page
        context.go('/');
        break;
      case 2:
        // Profile
        context.go('/profile');
        break;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'nightclub':
      case 'bar':
        return Colors.purple;
      case 'restaurant':
        return Colors.orange;
      case 'cafe':
        return Colors.brown;
      case 'park':
        return Colors.green;
      case 'museum':
        return Colors.indigo;
      case 'tourist':
        return Colors.blue;
      case 'market':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'nightclub':
      case 'bar':
        return Icons.nightlife;
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'park':
        return Icons.park;
      case 'museum':
        return Icons.museum;
      case 'tourist':
        return Icons.explore;
      case 'market':
        return Icons.shopping_bag;
      default:
        return Icons.place;
    }
  }
}