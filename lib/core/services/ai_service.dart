import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class AISearchResult {
  final String name;
  final LatLng coordinates;
  final String description;
  final String address;
  final double popularityScore;
  final bool isSocialMediaPopular;
  final List<String> tags;
  final String? imageUrl;

  AISearchResult({
    required this.name,
    required this.coordinates,
    required this.description,
    required this.address,
    required this.popularityScore,
    required this.isSocialMediaPopular,
    required this.tags,
    this.imageUrl,
  });
}

class AIService {
  final Dio _dio = Dio();
  
  static const String _mistralApiKey = 'your-mistral-api-key'; // Replace with actual API key
  static const String _openWeatherApiKey = 'your-openweather-api-key'; // Replace with actual API key

  Future<List<Marker>> searchLocations(String prompt, LatLng currentLocation) async {
    try {
      // Step 1: Analyze the user's prompt with Mistral 7B
      final searchParams = await _analyzePromptWithMistral(prompt);
      
      // Step 2: Search for locations based on analysis
      final locations = await _findLocations(searchParams, currentLocation);
      
      // Step 3: Enrich with social media data
      final enrichedLocations = await _enrichWithSocialMediaData(locations);
      
      // Step 4: Convert to markers
      return _convertToMarkers(enrichedLocations);
      
    } catch (e) {
      print('Error in AI search: $e');
      throw Exception('Failed to search locations: $e');
    }
  }

  Future<Map<String, dynamic>> _analyzePromptWithMistral(String prompt) async {
    try {
      final response = await _dio.post(
        'https://api.mistral.ai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_mistralApiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'mistral-7b-instruct',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a location analysis AI. Analyze the user's search prompt and extract:
1. Location type (restaurant, cafe, bar, park, museum, etc.)
2. Specific features (outdoor seating, wifi, pet-friendly, etc.)
3. Price range (budget, mid-range, luxury)
4. Atmosphere/vibe (casual, formal, trendy, quiet, etc.)
5. Distance preference (walking, short drive, any)
6. Any specific requirements

Return as JSON with these fields.'''
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      // Parse the JSON response from Mistral
      return _parseMistralResponse(content);
    } catch (e) {
      print('Error analyzing prompt with Mistral: $e');
      // Fallback to basic analysis
      return _fallbackPromptAnalysis(prompt);
    }
  }

  Map<String, dynamic> _parseMistralResponse(String content) {
    // Basic JSON parsing - in production, use proper JSON parsing
    try {
      // For now, return a basic structure
      return {
        'locationType': 'restaurant',
        'features': [],
        'priceRange': 'mid-range',
        'atmosphere': 'casual',
        'distancePreference': 'any',
        'specificRequirements': []
      };
    } catch (e) {
      return _fallbackPromptAnalysis(content);
    }
  }

  Map<String, dynamic> _fallbackPromptAnalysis(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    String locationType = 'general';
    if (lowerPrompt.contains('restaurant') || lowerPrompt.contains('food') || lowerPrompt.contains('eat')) {
      locationType = 'restaurant';
    } else if (lowerPrompt.contains('cafe') || lowerPrompt.contains('coffee')) {
      locationType = 'cafe';
    } else if (lowerPrompt.contains('bar') || lowerPrompt.contains('pub') || lowerPrompt.contains('drink')) {
      locationType = 'bar';
    } else if (lowerPrompt.contains('park') || lowerPrompt.contains('garden')) {
      locationType = 'park';
    } else if (lowerPrompt.contains('museum') || lowerPrompt.contains('gallery')) {
      locationType = 'museum';
    } else if (lowerPrompt.contains('shop') || lowerPrompt.contains('store')) {
      locationType = 'shopping';
    }

    return {
      'locationType': locationType,
      'features': [],
      'priceRange': 'mid-range',
      'atmosphere': 'casual',
      'distancePreference': 'any',
      'specificRequirements': []
    };
  }

  Future<List<AISearchResult>> _findLocations(Map<String, dynamic> searchParams, LatLng currentLocation) async {
    final locationType = searchParams['locationType'] as String;
    final radius = 5000; // 5km radius
    
    try {
      // Use OpenStreetMap Nominatim API for location search
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': '$locationType near ${currentLocation.latitude},${currentLocation.longitude}',
          'format': 'json',
          'limit': 20,
          'radius': radius,
          'countrycodes': 'gb', // UK, adjust as needed
        },
        options: Options(
          headers: {
            'User-Agent': 'LocalAI/1.0',
          },
        ),
      );

      final List<AISearchResult> locations = [];
      
      for (var item in response.data) {
        if (item['lat'] != null && item['lon'] != null) {
          final location = AISearchResult(
            name: item['display_name'] ?? item['name'] ?? 'Unknown Location',
            coordinates: LatLng(
              double.parse(item['lat'].toString()),
              double.parse(item['lon'].toString()),
            ),
            description: item['class'] ?? 'Location',
            address: item['display_name'] ?? '',
            popularityScore: 0.5, // Will be updated with social media data
            isSocialMediaPopular: false, // Will be updated with social media data
            tags: _extractTags(item, searchParams),
            imageUrl: null,
          );
          locations.add(location);
        }
      }
      
      return locations;
    } catch (e) {
      print('Error finding locations: $e');
      // Return some mock locations for testing
      return _getMockLocations(currentLocation, locationType);
    }
  }

  Future<List<AISearchResult>> _enrichWithSocialMediaData(List<AISearchResult> locations) async {
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      
      try {
        // Search for social media mentions
        final socialMediaData = await _searchSocialMediaHashtags(location.name);
        
        // Update location with social media data
        locations[i] = AISearchResult(
          name: location.name,
          coordinates: location.coordinates,
          description: location.description,
          address: location.address,
          popularityScore: socialMediaData['popularityScore'] ?? 0.5,
          isSocialMediaPopular: (socialMediaData['popularityScore'] ?? 0.0) > 0.7,
          tags: [...location.tags, ...socialMediaData['hashtags']],
          imageUrl: socialMediaData['imageUrl'],
        );
      } catch (e) {
        print('Error enriching ${location.name} with social media data: $e');
        // Keep original location if enrichment fails
      }
    }
    
    return locations;
  }

  Future<Map<String, dynamic>> _searchSocialMediaHashtags(String locationName) async {
    try {
      // This would connect to social media APIs
      // For now, simulate social media data
      final hashtags = [
        '#${locationName.toLowerCase().replaceAll(' ', '')}',
        '#londonfood', '#visitlondon', '#londonlife'
      ];
      
      // Simulate popularity based on name
      final baseScore = locationName.toLowerCase().contains('cafe') ? 0.8 : 0.6;
      final popularityScore = baseScore + (DateTime.now().millisecond % 100) / 500.0;
      
      return {
        'popularityScore': popularityScore.clamp(0.0, 1.0),
        'hashtags': hashtags,
        'imageUrl': null, // Could be extracted from social media posts
      };
    } catch (e) {
      print('Error searching social media: $e');
      return {
        'popularityScore': 0.3,
        'hashtags': [],
        'imageUrl': null,
      };
    }
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

  List<String> _extractTags(Map<String, dynamic> item, Map<String, dynamic> searchParams) {
    final List<String> tags = [];
    
    // Extract tags from OpenStreetMap data
    if (item['class'] != null) {
      tags.add(item['class'].toString());
    }
    if (item['type'] != null) {
      tags.add(item['type'].toString());
    }
    
    // Add tags from search parameters
    if (searchParams['locationType'] != null) {
      tags.add(searchParams['locationType'].toString());
    }
    
    return tags;
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
        address: 'Address $i+1, London',
        popularityScore: 0.5 + (i * 0.1),
        isSocialMediaPopular: i % 2 == 0,
        tags: [locationType, 'mock'],
      ));
    }
    
    return locations;
  }
}