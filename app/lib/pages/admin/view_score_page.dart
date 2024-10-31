import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/score_service.dart';
import '/services/user_service.dart';
import '/services/graph_service.dart';

class ViewAllScoresPage extends StatefulWidget {
  @override
  _ViewAllScoresPageState createState() => _ViewAllScoresPageState();
}

class _ViewAllScoresPageState extends State<ViewAllScoresPage> {
  final GraphService _graphService = GraphService();
  final ScoreService _scoreService = ScoreService();
  final UserService _userService = UserService();

  Future<List<int>>? _scoreDistribution;
  Future<List<String>>? _categoriesFuture;
  Future<List<Map<String, dynamic>>>? _scoresFuture;
  String _selectedCategory = 'HTML';

  @override
  void initState() {
    super.initState();
    // Récupération initiale des catégories disponibles
    _categoriesFuture = _scoreService.getAllCategories();
    _updateCategoryData(_selectedCategory);
  }

  // Méthode pour mettre à jour les données selon la catégorie
  void _updateCategoryData(String category) {
    setState(() {
      _selectedCategory = category;
      _scoresFuture = _scoreService.getScoreByCategory(category);
      _scoreDistribution = _graphService.getScoreDistribution(category);
    });
  }

  void _onCategoryChanged(String? newCategory) {
    if (newCategory != null) {
      _updateCategoryData(newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All User Scores')),
      body: FutureBuilder<List<String>>(
        future: _categoriesFuture,
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (categorySnapshot.hasError) {
            print("Error fetching categories: ${categorySnapshot.error}");
            return Center(child: Text('Error: ${categorySnapshot.error}'));
          }

          final categories = categorySnapshot.data ?? [];

          return Column(
            children: [
              // Sélection de catégorie avec RadioListTile
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: categories.map((category) {
                    return RadioListTile<String>(
                      title: Text(category),
                      value: category,
                      groupValue: _selectedCategory,
                      onChanged: _onCategoryChanged,
                    );
                  }).toList(),
                ),
              ),
              // Graphique pour la catégorie sélectionnée
              Expanded(
                child: FutureBuilder<List<int>>(
                  future: _scoreDistribution,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print("Error fetching score distribution: ${snapshot.error}");
                      return Center(child: Text('Error fetching score distribution: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available for this category.'));
                    }

                    final scoreCounts = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Chart(
                        data: scoreCounts.asMap().entries.map((entry) {
                          return {
                            'score': entry.key.toString(),
                            'count': entry.value,
                          };
                        }).toList(),
                        variables: {
                          'score': Variable(
                            accessor: (Map<String, dynamic> row) => row['score'] as String,
                          ),
                          'count': Variable(
                            accessor: (Map<String, dynamic> row) => row['count'] as int,
                          ),
                        },
                        marks: [
                          IntervalMark(
                            size: SizeEncode(value: 15),
                            color: ColorEncode(value: Colors.blueAccent),
                            elevation: ElevationEncode(value: 1),
                            label: LabelEncode(
                              encoder: (tuple) => Label(tuple['count'].toString()),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Liste des scores pour la catégorie sélectionnée
              Expanded(
                flex: 2,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _scoresFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print("Error fetching scores: ${snapshot.error}");
                      return Center(child: Text('Error fetching scores: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No scores available for this category.'));
                    }

                    final scores = snapshot.data!;
                    return ListView.builder(
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        var scoreData = scores[index];
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: _userService.getUserData(scoreData['user']),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (userSnapshot.hasError) {
                              print("Error fetching user data: ${userSnapshot.error}");
                              return const Center(child: Text('User data unavailable'));
                            }
                            if (userSnapshot.data == null) {
                              return const Center(child: Text('User data not found'));
                            }

                            final userData = userSnapshot.data!;
                            final userName = userData['firstName'] ?? 'Unknown';
                            final userSurname = userData['name'] ?? 'User';

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User: $userName $userSurname',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Category: ${scoreData['category']}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text('Score: ${scoreData['score']} / ${scoreData['quizLength']}'),
                                    Text('Date: ${scoreData['createdAt'] ?? 'N/A'}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
