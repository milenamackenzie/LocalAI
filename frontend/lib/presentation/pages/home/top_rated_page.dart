import 'package:flutter/material.dart';
import '../../widgets/recommendation_card.dart';

class TopRatedPage extends StatelessWidget {
  const TopRatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Top Rated in City'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RecommendationCard(
              id: 'top_${index + 1}',
              title: 'Top Spot #${index + 1}',
              category: 'Featured',
              score: 0.99 - (index * 0.01),
              onTap: () {},
            ),

          );
        },
      ),
    );
  }
}
