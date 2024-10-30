import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
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
  Future<List<String>>? _categoriesFuture; // Future pour les catégories
  String _selectedCategory = 'HTML'; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _fetchScoreDistribution();
    _categoriesFuture = _scoreService.getAllCategories(); // Récupérer les catégories
  }

  Future<void> _fetchScoreDistribution() async {
    final distribution = await _graphService.getScoreDistribution(_selectedCategory);
    setState(() {
      _scoreDistribution = Future.value(distribution);
    });
  }

  void _onCategoryChanged(String? newCategory) {
    setState(() {
      _selectedCategory = newCategory!;
      _fetchScoreDistribution(); // Recharger les données avec la nouvelle catégorie
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All User Scores')),
      body: FutureBuilder<List<String>>(
        future: _categoriesFuture, // Utiliser le future pour les catégories
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (categorySnapshot.hasError) {
            return Center(child: Text('Error: ${categorySnapshot.error}'));
          }

          final categories = categorySnapshot.data;

          return Column(
            children: [
              // RadioList des catégories
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: categories!.map((category) {
                    return RadioListTile<String>(
                      title: Text(category),
                      value: category,
                      groupValue: _selectedCategory,
                      onChanged: _onCategoryChanged,
                    );
                  }).toList(),
                ),
              ),
              // Afficher le graphique
              Expanded(
                child: FutureBuilder<List<int>>(
                  future: _scoreDistribution,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final scoreCounts = snapshot.data;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 350,
                        height: 200,
                        child: Chart(
                          data: scoreCounts!.asMap().entries.map((entry) {
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
                              size: SizeEncode(value: 15), // Largeur des barres
                              color: ColorEncode(value: Colors.blueAccent),
                              elevation: ElevationEncode(value: 1),
                              label: LabelEncode(
                                encoder: (tuple) => Label(
                                  tuple['count'].toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Liste des scores des utilisateurs
              Expanded(
                flex: 2,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _scoreService.getAllUserScore(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final scores = snapshot.data;

                    if (scores == null || scores.isEmpty) {
                      return const Center(child: Text('No scores available'));
                    }

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
                              return Center(child: Text('Error: ${userSnapshot.error}'));
                            }

                            final userData = userSnapshot.data;
                            final userName = userData?['firstName'] ?? 'Unknown';
                            final userSurname = userData?['name'] ?? 'User';

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
                                    Text(
                                      'Score: ${scoreData['score']} / ${scoreData['quizLength']}',
                                    ),
                                    Text(
                                      'Date: ${scoreData['createdAt'] ?? 'N/A'}',
                                    ),
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
