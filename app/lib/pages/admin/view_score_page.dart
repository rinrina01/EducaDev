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

  @override
  void initState() {
    super.initState();
    _fetchScoreDistribution();
  }

  Future<void> _fetchScoreDistribution() async {
    final distribution = await _graphService.getScoreDistribution('HTML');
    setState(() {
      _scoreDistribution = Future.value(distribution);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All User Scores')),
      body: FutureBuilder<List<int>>(
        future: _scoreDistribution,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final scoreCounts = snapshot.data;

          return Column(
            children: [
              // Graphique en barres avec graduations et style
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: 350,
                    height: 200,
                    child: Stack(
                      children: [ Chart(
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
                      ],
                    ),
                  ),
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
