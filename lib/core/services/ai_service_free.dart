import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:convert';

class AISearchResult {
  final String name;
  final LatLng coordinates;
  final String description;
  final String address;
  final double popularityScore;
  final bool isSocialMediaPopular;
  final List<String> tags;
  final String? imageUrl;
  final String? source; // Where the data came from

  AISearchResult({
    required this.name,
    required this.coordinates,
    required this.description,
    required this.address,
    required this.popularityScore,
    required this.isSocialMediaPopular,
    required this.tags,
    this.imageUrl,
    this.source,
  });
}

class AIService {
  final Dio _dio = Dio();

  Future<List<Marker>> searchLocations(String prompt, LatLng currentLocation) async {
    try {
      // Step 1: Analyze the user's prompt locally (no API needed)
      final searchParams = _analyzePromptLocally(prompt);
      
      // Step 2: Search for locations using free APIs
      final locations = await _findLocationsWithFreeAPIs(searchParams, currentLocation);
      
      // Step 3: Enrich with social media data using web scraping
      final enrichedLocations = await _enrichWithSocialMediaScraping(locations);
      
      // Step 4: Convert to markers
      return _convertToMarkers(enrichedLocations);
      
    } catch (e) {
      print('Error in AI search: $e');
      throw Exception('Failed to search locations: $e');
    }
  }

  Map<String, dynamic> _analyzePromptLocally(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    // Extract location type
    String locationType = 'general';
    if (lowerPrompt.contains('restaurant') || lowerPrompt.contains('food') || 
        lowerPrompt.contains('eat') || lowerPrompt.contains('dinner')) {
      locationType = 'restaurant';
    } else if (lowerPrompt.contains('cafe') || lowerPrompt.contains('coffee')) {
      locationType = 'cafe';
    } else if (lowerPrompt.contains('bar') || lowerPrompt.contains('pub') || 
               lowerPrompt.contains('drink')) {
      locationType = 'bar';
    } else if (lowerPrompt.contains('park') || lowerPrompt.contains('garden')) {
      locationType = 'park';
    } else if (lowerPrompt.contains('museum') || lowerPrompt.contains('gallery')) {
      locationType = 'museum';
    } else if (lowerPrompt.contains('shop') || lowerPrompt.contains('store') || 
               lowerPrompt.contains('shopping')) {
      locationType = 'shopping';
    } else if (lowerPrompt.contains('hotel') || lowerPrompt.contains('accommodation')) {
      locationType = 'hotel';
    }

    // Extract features
    final List<String> features = [];
    if (lowerPrompt.contains('wifi') || lowerPrompt.contains('internet')) {
      features.add('wifi');
    }
    if (lowerPrompt.contains('outdoor') || lowerPrompt.contains('terrace')) {
      features.add('outdoor');
    }
    if (lowerPrompt.contains('quiet') || lowerPrompt.contains('peaceful')) {
      features.add('quiet');
    }
    if (lowerPrompt.contains('pet') || lowerPrompt.contains('dog')) {
      features.add('pet_friendly');
    }
    if (lowerPrompt.contains('music') || lowerPrompt.contains('live')) {
      features.add('live_music');
    }
    if (lowerPrompt.contains('view') || lowerPrompt.contains('scenic')) {
      features.add('view');
    }

    // Extract price range
    String priceRange = 'mid-range';
    if (lowerPrompt.contains('cheap') || lowerPrompt.contains('budget') || 
        lowerPrompt.contains('affordable')) {
      priceRange = 'budget';
    } else if (lowerPrompt.contains('luxury') || lowerPrompt.contains('expensive') || 
               lowerPrompt.contains('premium')) {
      priceRange = 'luxury';
    }

    // Extract atmosphere
    String atmosphere = 'casual';
    if (lowerPrompt.contains('formal') || lowerPrompt.contains('fancy')) {
      atmosphere = 'formal';
    } else if (lowerPrompt.contains('trendy') || lowerPrompt.contains('modern')) {
      atmosphere = 'trendy';
    } else if (lowerPrompt.contains('romantic') || lowerPrompt.contains('intimate')) {
      atmosphere = 'romantic';
    }

    // Extract distance preference
    String distancePreference = 'any';
    if (lowerPrompt.contains('walk') || lowerPrompt.contains('nearby') || 
        lowerPrompt.contains('close')) {
      distancePreference = 'walking';
    } else if (lowerPrompt.contains('drive') || lowerPrompt.contains('short')) {
      distancePreference = 'short_drive';
    }

    return {
      'locationType': locationType,
      'features': features,
      'priceRange': priceRange,
      'atmosphere': atmosphere,
      'distancePreference': distancePreference,
      'specificRequirements': []
    };
  }

  Future<List<AISearchResult>> _findLocationsWithFreeAPIs(
      Map<String, dynamic> searchParams, LatLng currentLocation) async {
    final List<AISearchResult> locations = [];
    
    try {
      // Method 1: OpenStreetMap Overpass API (free, no API key needed)
      final osmResults = await _searchOpenStreetMap(searchParams, currentLocation);
      locations.addAll(osmResults);
      
      // Method 2: Foursquare Free API (limited but no key needed for basic)
      if (locations.length < 10) {
        final foursquareResults = await _searchFoursquareFree(searchParams, currentLocation);
        locations.addAll(foursquareResults);
      }
      
      // Method 3: Google Places Alternative (using other free services)
      if (locations.length < 15) {
        final alternativeResults = await _searchAlternativeServices(searchParams, currentLocation);
        locations.addAll(alternativeResults);
      }
      
    } catch (e) {
      print('Error in API search: $e');
      // Use mock data as fallback
      locations.addAll(_getMockLocations(currentLocation, searchParams['locationType']));
    }
    
    return locations;
  }

  Future<List<AISearchResult>> _searchOpenStreetMap(
      Map<String, dynamic> searchParams, LatLng currentLocation) async {
    final locationType = searchParams['locationType'] as String;
    final radius = 5000; // 5km radius
    
    try {
      // Use Overpass API for more detailed search
      String query = '''
        [out:json][timeout:25];
        (
          node["amenity"="$locationType"](around:$radius,${currentLocation.latitude},${currentLocation.longitude});
          way["amenity"="$locationType"](around:$radius,${currentLocation.latitude},${currentLocation.longitude});
          relation["amenity"="$locationType"](around:$radius,${currentLocation.latitude},${currentLocation.longitude});
        );
        out geom;
      ''';

      final response = await _dio.post(
        'https://overpass-api.de/api/interpreter',
        data: query,
        options: Options(
          headers: {
            'Content-Type': 'text/plain',
            'User-Agent': 'LocalAI/1.0',
          },
        ),
      );

      final List<AISearchResult> locations = [];
      final data = response.data;
      
      if (data['elements'] != null) {
        for (var element in data['elements']) {
          if (element['lat'] != null && element['lon'] != null) {
            final tags = element['tags'] ?? {};
            final location = AISearchResult(
              name: tags['name'] ?? tags['brand'] ?? 'Unknown $locationType',
              coordinates: LatLng(
                element['lat'].toDouble(),
                element['lon'].toDouble(),
              ),
              description: tags['amenity'] ?? locationType,
              address: _buildAddress(tags),
              popularityScore: 0.5, // Will be updated later
              isSocialMediaPopular: false, // Will be updated later
              tags: _extractTagsFromOSM(tags),
              source: 'OpenStreetMap',
            );
            locations.add(location);
          }
        }
      }
      
      return locations;
    } catch (e) {
      print('Error searching OpenStreetMap: $e');
      return [];
    }
  }

  Future<List<AISearchResult>> _searchFoursquareFree(
      Map<String, dynamic> searchParams, LatLng currentLocation) async {
    // Foursquare has limited free access without API key
    // This is a simplified approach
    return [];
  }

  Future<List<AISearchResult>> _searchAlternativeServices(
      Map<String, dynamic> searchParams, LatLng currentLocation) async {
    // Use other free services like Yelp public data, TripAdvisor public pages, etc.
    return [];
  }

  Future<List<AISearchResult>> _enrichWithSocialMediaScraping(
      List<AISearchResult> locations) async {
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      
      try {
        // Method 1: Search Nitter (Twitter alternative)
        final nitterData = await _scrapeNitter(location.name);
        
        // Method 2: Search Instagram public pages
        final instagramData = await _scrapeInstagramPublic(location.name);
        
        // Method 3: Search Reddit for location mentions
        final redditData = await _scrapeReddit(location.name);
        
        // Combine social media data
        final combinedScore = (nitterData['popularity'] ?? 0.0) + 
                             (instagramData['popularity'] ?? 0.0) + 
                             (redditData['popularity'] ?? 0.0);
        
        final combinedTags = [...nitterData['tags'], ...instagramData['tags'], ...redditData['tags']];
        
        // Update location with social media data
        locations[i] = AISearchResult(
          name: location.name,
          coordinates: location.coordinates,
          description: location.description,
          address: location.address,
          popularityScore: combinedScore.clamp(0.0, 1.0),
          isSocialMediaPopular: combinedScore > 0.7,
          tags: [...location.tags, ...combinedTags],
          imageUrl: nitterData['imageUrl'] ?? instagramData['imageUrl'],
          source: location.source,
        );
      } catch (e) {
        print('Error enriching ${location.name} with social media: $e');
        // Keep original location if enrichment fails
      }
    }
    
    return locations;
  }

  Future<Map<String, dynamic>> _scrapeNitter(String locationName) async {
    try {
      final response = await _dio.get(
        'https://nitter.net/search?q=${Uri.encodeComponent(locationName)}&f=tweets',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );
      
      // Simple HTML parsing for engagement metrics
      final html = response.data;
      final tweetCount = _countTweetsInHTML(html);
      final hashtags = _extractHashtagsFromHTML(html);
      
      return {
        'popularity': (tweetCount / 100.0).clamp(0.0, 1.0),
        'tags': hashtags,
        'imageUrl': null,
      };
    } catch (e) {
      return {'popularity': 0.3, 'tags': [], 'imageUrl': null};
    }
  }

  Future<Map<String, dynamic>> _scrapeInstagramPublic(String locationName) async {
    try {
      // Use a public Instagram search alternative
      final response = await _dio.get(
        'https://www.instagrapi.com/search/?query=${Uri.encodeComponent(locationName)}',
        options: Options(
          headers: {'User-Agent': 'Mozilla/5.0'},
        ),
      );
      
      return {
        'popularity': 0.4, // Simulated
        'tags': ['#${locationName.toLowerCase().replaceAll(' ', '')}'],
        'imageUrl': null,
      };
    } catch (e) {
      return {'popularity': 0.2, 'tags': [], 'imageUrl': null};
    }
  }

  Future<Map<String, dynamic>> _scrapeReddit(String locationName) async {
    try {
      final response = await _dio.get(
        'https://www.reddit.com/search.json?q=${Uri.encodeComponent(locationName)}',
        options: Options(
          headers: {'User-Agent': 'LocalAI/1.0'},
        ),
      );
      
      final data = response.data;
      final posts = data['data']['children'] ?? [];
      final commentCount = posts.fold<int>(0, (sum, post) => 
          sum + (post['data']['num_comments'] ?? 0));
      
      return {
        'popularity': (commentCount / 1000.0).clamp(0.0, 1.0),
        'tags': posts.map((post) => '#${post['data']['subreddit']}').toList(),
        'imageUrl': null,
      };
    } catch (e) {
      return {'popularity': 0.1, 'tags': [], 'imageUrl': null};
    }
  }

  // Helper methods for HTML parsing and data extraction
  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    if (tags['addr:postcode'] != null) parts.add(tags['addr:postcode']);
    
    return parts.isNotEmpty ? parts.join(', ') : 'Address unknown';
  }

  List<String> _extractTagsFromOSM(Map<String, dynamic> tags) {
    final List<String> extractedTags = [];
    
    tags.forEach((key, value) {
      if (key.startsWith('amenity:') || key.startsWith('cuisine:') || 
          key.startsWith('shop:') || key.startsWith('tourism:')) {
        extractedTags.add(value.toString());
      }
    });
    
    if (tags['cuisine'] != null) {
      extractedTags.addAll(tags['cuisine'].toString().split(';'));
    }
    
    return extractedTags;
  }

  int _countTweetsInHTML(String html) {
    // Simple regex to count tweet elements
    final tweetPattern = RegExp(r'class="tweet"');
    return tweetPattern.allMatches(html).length;
  }

  List<String> _extractHashtagsFromHTML(String html) {
    final hashtagPattern = RegExp(r'#\w+');
    return hashtagPattern.allMatches(html)
        .map((match) => match.group(0)!)
        .toSet()
        .toList();
  }

  List<Marker> _convertToMarkers(List<AISearchResult> locations) {
    return locations.map((location) {
      return Marker(
        point: location.coordinates,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: location.isSocialMediaPopular ? Colors.amber : Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            location.isSocialMediaPopular ? Icons.trending_up : Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }).toList();
  }

  List<AISearchResult> _getMockLocations(LatLng currentLocation, String locationType) {
    // Generate some mock locations for testing
    final random = DateTime.now().millisecond;
    final locations = <AISearchResult>[];
    
    for (int i = 0; i < 5; i++) {
      final lat = currentLocation.latitude + (random % 200 - 100) / 10000.0;
      final lon = currentLocation.longitude + (random % 200 - 100) / 10000.0;
      
      locations.add(AISearchResult(
        name: 'Mock $locationType ${i + 1}',
        coordinates: LatLng(lat, lon),
        description: 'A nice $locationType',
        address: 'Address ${i + 1}, London',
        popularityScore: 0.5 + (i * 0.1),
        isSocialMediaPopular: i % 2 == 0,
        tags: [locationType, 'mock', 'test'],
        source: 'Mock Data',
      ));
    }
    
    return locations;
  }
}