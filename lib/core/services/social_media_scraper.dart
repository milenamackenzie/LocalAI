import 'package:dio/dio.dart';
import 'dart:convert';

class SocialMediaScraper {
  final Dio _dio = Dio();
  
  /// Demo: Scrape social media popularity without API keys
  Future<Map<String, dynamic>> getLocationPopularity(String locationName) async {
    final results = <String, dynamic>{};
    
    // Method 1: Twitter via Nitter (no API key)
    results['twitter'] = await _scrapeTwitter(locationName);
    
    // Method 2: Reddit public API (no authentication)
    results['reddit'] = await _scrapeReddit(locationName);
    
    // Method 3: Public search engines (structured data)
    results['search'] = await _scrapeSearchEngines(locationName);
    
    // Calculate combined popularity score
    final combinedScore = _calculatePopularityScore(results);
    
    return {
      'location': locationName,
      'combined_score': combinedScore,
      'is_trending': combinedScore > 0.7,
      'sources': results,
      'hashtags': _extractCombinedHashtags(results),
    };
  }
  
  Future<Map<String, dynamic>> _scrapeTwitter(String locationName) async {
    try {
      final response = await _dio.get(
        'https://nitter.net/search?q=${Uri.encodeComponent(locationName)}&f=tweets',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );
      
      // Extract engagement metrics from HTML
      final html = response.data;
      final tweetCount = _countPattern(html, 'class="tweet"');
      final likeCount = _countPattern(html, 'class="icon-heart"');
      final retweetCount = _countPattern(html, 'class="icon-retweet"');
      
      return {
        'tweets': tweetCount,
        'likes': likeCount,
        'retweets': retweetCount,
        'engagement': (tweetCount + likeCount + retweetCount) / 100.0,
        'hashtags': _extractHashtags(html),
        'status': 'success',
      };
    } catch (e) {
      return {
        'tweets': 0,
        'likes': 0, 
        'retweets': 0,
        'engagement': 0.0,
        'hashtags': [],
        'status': 'error: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> _scrapeReddit(String locationName) async {
    try {
      final response = await _dio.get(
        'https://www.reddit.com/search.json?q=${Uri.encodeComponent(locationName)}&sort=relevance&t=week',
        options: Options(
          headers: {'User-Agent': 'LocalAI/1.0'},
        ),
      );
      
      final data = json.decode(response.data);
      final posts = data['data']['children'] ?? [];
      
      int totalComments = 0;
      int totalScore = 0;
      final List<String> subreddits = [];
      final List<String> titles = [];
      
      for (var post in posts) {
        final postData = post['data'];
        totalComments += (postData['num_comments'] ?? 0) as int;
        totalScore += (postData['score'] ?? 0) as int;
        subreddits.add('r/${postData['subreddit']}');
        titles.add(postData['title'] ?? '');
      }
      
      return {
        'posts': posts.length,
        'comments': totalComments,
        'score': totalScore,
        'engagement': (totalComments + totalScore) / 1000.0,
        'subreddits': subreddits.toSet().toList(),
        'titles': titles,
        'status': 'success',
      };
    } catch (e) {
      return {
        'posts': 0,
        'comments': 0,
        'score': 0,
        'engagement': 0.0,
        'subreddits': [],
        'titles': [],
        'status': 'error: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> _scrapeSearchEngines(String locationName) async {
    try {
      // Use DuckDuckGo for instant answers (no API key needed)
      final response = await _dio.get(
        'https://duckduckgo.com/html/?q=${Uri.encodeComponent(locationName + ' reviews')}',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (compatible; LocalAI/1.0)',
          },
        ),
      );
      
      final html = response.data;
      final resultCount = _countPattern(html, 'class="result"');
      final reviews = _extractReviewStars(html);
      
      return {
        'results': resultCount,
        'review_stars': reviews,
        'engagement': (resultCount + reviews.length) / 50.0,
        'status': 'success',
      };
    } catch (e) {
      return {
        'results': 0,
        'review_stars': [],
        'engagement': 0.0,
        'status': 'error: $e',
      };
    }
  }
  
  double _calculatePopularityScore(Map<String, dynamic> sources) {
    double totalScore = 0.0;
    int validSources = 0;
    
    // Twitter engagement (weight: 0.4)
    if (sources['twitter']['status'] == 'success') {
      totalScore += sources['twitter']['engagement'] * 0.4;
      validSources++;
    }
    
    // Reddit discussions (weight: 0.4)  
    if (sources['reddit']['status'] == 'success') {
      totalScore += sources['reddit']['engagement'] * 0.4;
      validSources++;
    }
    
    // Search engine results (weight: 0.2)
    if (sources['search']['status'] == 'success') {
      totalScore += sources['search']['engagement'] * 0.2;
      validSources++;
    }
    
    // Normalize score
    if (validSources > 0) {
      return (totalScore / validSources).clamp(0.0, 1.0);
    }
    
    return 0.3; // Default low score for unknown locations
  }
  
  List<String> _extractCombinedHashtags(Map<String, dynamic> sources) {
    final Set<String> allHashtags = {};
    
    if (sources['twitter']['hashtags'] != null) {
      allHashtags.addAll(sources['twitter']['hashtags'].cast<String>());
    }
    
    if (sources['reddit']['subreddits'] != null) {
      allHashtags.addAll(sources['reddit']['subreddits'].cast<String>());
    }
    
    return allHashtags.toList();
  }
  
  // Helper methods for HTML parsing
  int _countPattern(String html, String pattern) {
    final regex = RegExp(pattern);
    return regex.allMatches(html).length;
  }
  
  List<String> _extractHashtags(String html) {
    final hashtagRegex = RegExp(r'#\w+');
    return hashtagRegex.allMatches(html)
        .map((match) => match.group(0)!)
        .toSet()
        .take(10) // Limit to top 10
        .toList();
  }
  
  List<double> _extractReviewStars(String html) {
    final starRegex = RegExp(r'(\d\.?\d*)\s*stars?');
    return starRegex.allMatches(html)
        .map((match) => double.tryParse(match.group(1)!) ?? 0.0)
        .where((rating) => rating > 0 && rating <= 5)
        .toList();
  }
}