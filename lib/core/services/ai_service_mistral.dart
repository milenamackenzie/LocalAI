import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math';

class AISearchResult {
  final String name;
  final LatLng coordinates;
  final String description;
  final String address;
  final double popularityScore;
  final bool isSocialMediaPopular;
  final List<String> tags;

  AISearchResult({
    required this.name,
    required this.coordinates,
    required this.description,
    required this.address,
    required this.popularityScore,
    required this.isSocialMediaPopular,
    required this.tags,
  });
}

class AIService {
  final Dio _dio = Dio();
  
  // Mistral 7B API configuration (you'll need to add your API key)
  static const String _mistralApiKey = 'your-mistral-api-key-here';
  
  Future<List<Marker>> searchLocations(String prompt, LatLng currentLocation, {double radius = 3000}) async {
    try {
      // Step 1: Analyze the user's prompt with Mistral 7B
      final searchParams = await _analyzePromptWithMistral(prompt);
      
      // Add the original prompt to search params for location extraction
      searchParams['prompt'] = prompt;
      
      // Step 2: Check if user specified a specific location
      final hasSpecificLocation = _hasSpecificLocation(prompt, searchParams);
      
      // Step 3: Search for locations based on analysis
      final locations = await _findLocationsReal(searchParams, currentLocation, radius, !hasSpecificLocation);
      
      // Step 4: Enrich with social media data
      final enrichedLocations = await _enrichWithSocialData(locations);
      
      // Step 5: Convert to markers
      return _convertToMarkers(enrichedLocations);
      
    } catch (e) {
      print('Error in AI search: $e');
      // Fallback to mock data
      return _convertToMarkers(_getMockLocations(currentLocation, prompt, radius));
    }
  }

  Future<Map<String, dynamic>> _analyzePromptWithMistral(String prompt) async {
    // If no API key, use local analysis
    if (_mistralApiKey == 'your-mistral-api-key-here') {
      return _analyzePromptLocally(prompt);
    }
    
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
              'content': '''You are a location analysis AI. Extract from the user's query:
1. location_type: restaurant, cafe, bar, park, museum, shop, hotel, etc.
2. specific_location: if they mentioned a specific city/area/place
3. features: wifi, outdoor_seating, pet_friendly, live_music, etc.
4. price_range: budget, mid_range, luxury
5. atmosphere: casual, formal, trendy, romantic, quiet
6. search_intent: general_search vs specific_place_search

Respond with JSON format only.'''
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return _parseMistralResponse(content);
    } catch (e) {
      print('Error with Mistral API: $e');
      return _analyzePromptLocally(prompt);
    }
  }

  Map<String, dynamic> _parseMistralResponse(String content) {
    try {
      // Extract JSON from the response
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = content.substring(jsonStart, jsonEnd + 1);
        // Simple JSON parsing - in production use dart:convert
        final Map<String, dynamic> result = {};
        
        if (content.contains('restaurant')) result['location_type'] = 'restaurant';
        else if (content.contains('cafe')) result['location_type'] = 'cafe';
        else if (content.contains('bar')) result['location_type'] = 'bar';
        else if (content.contains('park')) result['location_type'] = 'park';
        else if (content.contains('shop')) result['location_type'] = 'shop';
        else result['location_type'] = 'general';
        
        result['specific_location'] = content.contains('specific_place_search');
        result['features'] = [];
        result['price_range'] = 'mid_range';
        result['atmosphere'] = 'casual';
        result['search_intent'] = content.contains('general_search') ? 'general_search' : 'specific_place_search';
        
        return result;
      }
    } catch (e) {
      print('Error parsing Mistral response: $e');
    }
    
    return _analyzePromptLocally(content);
  }

  Map<String, dynamic> _analyzePromptLocally(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    String locationType = 'general';
    List<String> alternativeTypes = [];
    
    if (lowerPrompt.contains('restaurant') || lowerPrompt.contains('food') || 
        lowerPrompt.contains('eat') || lowerPrompt.contains('dinner')) {
      locationType = 'restaurant';
    } else if (lowerPrompt.contains('cafe') || lowerPrompt.contains('coffee')) {
      locationType = 'cafe';
    } else if (lowerPrompt.contains('club') || lowerPrompt.contains('nightclub')) {
      locationType = 'nightclub';
      alternativeTypes = ['bar', 'pub'];
    } else if (lowerPrompt.contains('bar') || lowerPrompt.contains('pub') || 
               lowerPrompt.contains('drink')) {
      locationType = 'bar';
      alternativeTypes = ['pub', 'nightclub'];
    } else if (lowerPrompt.contains('park') || lowerPrompt.contains('garden')) {
      locationType = 'park';
    } else if (lowerPrompt.contains('shop') || lowerPrompt.contains('store') || 
               lowerPrompt.contains('shopping')) {
      locationType = 'shop';
    } else if (lowerPrompt.contains('museum')) {
      locationType = 'museum';
    } else if (lowerPrompt.contains('hotel') || lowerPrompt.contains('accommodation')) {
      locationType = 'hotel';
    }

    return {
      'location_type': locationType,
      'alternative_types': alternativeTypes,
      'specific_location': _hasSpecificLocation(lowerPrompt, {}),
      'features': [],
      'price_range': 'mid_range',
      'atmosphere': 'casual',
      'search_intent': 'general_search',
    };
  }

  bool _hasSpecificLocation(String prompt, Map<String, dynamic> searchParams) {
    final lowerPrompt = prompt.toLowerCase();
    
    // Check for specific city/area/place names
    final specificLocations = [
      'london', 'manchester', 'birmingham', 'leeds', 'glasgow',
      'paris', 'new york', 'tokyo', 'sydney', 'dubai',
      'soho', 'camden', 'shoreditch', 'covent garden'
    ];
    
    return specificLocations.any((location) => lowerPrompt.contains(location));
  }

  Future<List<AISearchResult>> _findLocationsReal(
      Map<String, dynamic> searchParams, LatLng currentLocation, double radius, bool useRadius) async {
    final locationType = searchParams['location_type'] as String;
    final alternativeTypes = (searchParams['alternative_types'] as List<dynamic>?) ?? [];
    
    try {
      // Build Overpass query with multiple amenity types
      String query;
      
      // Search within radius of current location (simpler, always works)
      final queryParts = <String>[];
      
      // Add main type
      queryParts.add('node["amenity"="$locationType"](around:$radius,${currentLocation.latitude},${currentLocation.longitude});');
      queryParts.add('way["amenity"="$locationType"](around:$radius,${currentLocation.latitude},${currentLocation.longitude});');
      
      // Add alternative types
      for (final altType in alternativeTypes) {
        queryParts.add('node["amenity"="$altType"](around:$radius,${currentLocation.latitude},${currentLocation.longitude});');
        queryParts.add('way["amenity"="$altType"](around:$radius,${currentLocation.latitude},${currentLocation.longitude});');
      }
      
      query = '''[out:json][timeout:25];
(
  ${queryParts.join('\n  ')}
);
out body center;''';

      print('Overpass Query:\n$query');
      
      final response = await _dio.post(
        'https://overpass-api.de/api/interpreter',
        data: query,
        options: Options(
          headers: {
            'Content-Type': 'text/plain',
            'User-Agent': 'LocalAI/1.0',
          },
          validateStatus: (status) => status! < 500, // Accept all responses < 500
        ),
      );

      if (response.statusCode != 200) {
        print('Overpass API error: ${response.statusCode}');
        print('Response: ${response.data}');
        return [];
      }

      final List<AISearchResult> locations = [];
      final data = response.data;
      
      if (data['elements'] != null && data['elements'].isNotEmpty) {
        for (var element in data['elements'].take(20)) {
          double lat = 0.0;
          double lon = 0.0;
          
          if (element['lat'] != null && element['lon'] != null) {
            lat = element['lat'].toDouble();
            lon = element['lon'].toDouble();
          } else if (element['center'] != null) {
            lat = element['center']['lat'].toDouble();
            lon = element['center']['lon'].toDouble();
          }
          
          if (lat != 0.0 && lon != 0.0) {
            final tags = element['tags'] ?? {};
            locations.add(AISearchResult(
              name: tags['name'] ?? tags['brand'] ?? '$locationType ${locations.length + 1}',
              coordinates: LatLng(lat, lon),
              description: tags['amenity'] ?? locationType,
              address: _buildAddress(tags),
              popularityScore: 0.5,
              isSocialMediaPopular: false,
              tags: _extractTags(tags),
            ));
          }
        }
      }
      
      print('Found ${locations.length} real locations for $locationType');
      return locations;
    } catch (e) {
      print('Error in real search: $e');
      return [];
    }
  }

  String _extractSpecificLocation(String prompt) {
    // Extract location name from prompt
    final lowerPrompt = prompt.toLowerCase();
    final locations = [
      'london', 'manchester', 'birmingham', 'leeds', 'glasgow',
      'paris', 'new york', 'tokyo', 'sydney', 'dubai',
      'soho', 'camden', 'shoreditch', 'covent garden'
    ];
    
    for (final location in locations) {
      if (lowerPrompt.contains(location)) {
        return location;
      }
    }
    
    return '';
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    if (tags['addr:postcode'] != null) parts.add(tags['addr:postcode']);
    
    return parts.isNotEmpty ? parts.join(', ') : 'Address unknown';
  }

  List<String> _extractTags(Map<String, dynamic> tags) {
    final List<String> extractedTags = [];
    
    tags.forEach((key, value) {
      if (key.contains('amenity') || key.contains('cuisine') || 
          key.contains('shop') || key.contains('tourism')) {
        extractedTags.add(value.toString());
      }
    });
    
    if (tags['cuisine'] != null) {
      extractedTags.addAll(tags['cuisine'].toString().split(';'));
    }
    
    return extractedTags;
  }

  Future<List<AISearchResult>> _enrichWithSocialData(List<AISearchResult> locations) async {
    // Simulate social media data for now
    final random = DateTime.now().millisecond;
    
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      
      // Calculate popularity based on location type and name
      double baseScore = 0.3;
      if (location.name.toLowerCase().contains('cafe')) baseScore = 0.6;
      else if (location.name.toLowerCase().contains('restaurant')) baseScore = 0.5;
      else if (location.name.toLowerCase().contains('bar') || location.name.toLowerCase().contains('club')) baseScore = 0.7;
      
      final socialScore = (baseScore + ((random + i * 100) % 400) / 1000.0).clamp(0.0, 1.0);
      
      locations[i] = AISearchResult(
        name: location.name,
        coordinates: location.coordinates,
        description: location.description,
        address: location.address,
        popularityScore: socialScore,
        isSocialMediaPopular: socialScore > 0.7,
        tags: [...location.tags, if (socialScore > 0.7) 'trending', 'social_proof'],
      );
    }
    
    return locations;
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

  List<AISearchResult> _getMockLocations(LatLng currentLocation, String prompt, double radius) {
    // Generate realistic mock locations around user's position
    final List<AISearchResult> locations = [];
    final seed = DateTime.now().millisecondsSinceEpoch;
    
    // Generate locations in a realistic pattern
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0) * pi / 180.0; // Every 30 degrees
      final distance = (radius / 2000000.0) + (i * 0.0003); // Realistic spacing
      final lat = currentLocation.latitude + distance * cos(angle);
      final lon = currentLocation.longitude + distance * sin(angle);
      
      final locationNames = [
        'The Crown Pub', 'Blue Mountain Coffee', 'Green Park Cafe', 
        'Starlight Restaurant', 'Urban Garden', 'Riverside Bar',
        'Cozy Corner Cafe', 'Sky Lounge', 'Street Food Market',
        'Hidden Gem Bistro', 'Central Park Plaza', 'Metro Station Cafe'
      ];
      
      final popularityScore = 0.3 + ((seed + i * 123) % 700) / 1000.0;
      final nameIndex = i % locationNames.length;
      
      locations.add(AISearchResult(
        name: locationNames[nameIndex],
        coordinates: LatLng(lat, lon),
        description: 'Popular local spot with great reviews',
        address: '${(lat * 1000).round()}m ${(lon * 1000).round()}m from center',
        popularityScore: popularityScore.clamp(0.0, 1.0),
        isSocialMediaPopular: popularityScore > 0.7,
        tags: ['local_favourite', if (popularityScore > 0.7) 'trending', 'highly_rated'],
      ));
    }
    
    return locations;
  }
}