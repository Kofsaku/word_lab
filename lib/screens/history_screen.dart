import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // ダミーデータ：参考画像に合わせた詳細履歴
  final List<Map<String, dynamic>> dailyHistory = [
    {
      'date': DateTime.now(),
      'studySessions': 2,
      'wordsLearned': 12,
      'timeSpent': 25,
      'avgScore': 85,
      'stages': ['Stage 1', 'Stage 2'],
      'boxMovements': {
        'BOX1→2': 8,
        'BOX2→3': 3,
        'BOX3→4': 1,
      }
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'studySessions': 1,
      'wordsLearned': 6,
      'timeSpent': 15,
      'avgScore': 78,
      'stages': ['Stage 1'],
      'boxMovements': {
        'BOX1→2': 4,
        'BOX2→1': 2,
      }
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'studySessions': 3,
      'wordsLearned': 18,
      'timeSpent': 35,
      'avgScore': 92,
      'stages': ['Stage 1', 'Stage 2', 'Stage 3'],
      'boxMovements': {
        'BOX1→3': 2,
        'BOX2→3': 6,
        'BOX3→4': 4,
        'BOX4→5': 2,
      }
    },
  ];

  final Map<String, dynamic> weeklyStats = {
    'totalWords': 156,
    'memorizedWords': 89,
    'reviewWords': 23,
    'totalTime': 380, // 分
    'avgDailyTime': 54,
    'longestStreak': 7,
    'currentStreak': 3,
  };

  final List<Map<String, dynamic>> boxDistribution = [
    {'box': 1, 'count': 45, 'color': Colors.red},
    {'box': 2, 'count': 38, 'color': Colors.orange},
    {'box': 3, 'count': 25, 'color': Colors.yellow},
    {'box': 4, 'count': 18, 'color': Colors.green},
    {'box': 5, 'count': 12, 'color': Colors.blue},
    {'box': '∞', 'count': 18, 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習のあしあと'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: '今週', icon: Icon(Icons.calendar_today, size: 20)),
            Tab(text: 'BOX状況', icon: Icon(Icons.inventory, size: 20)),
            Tab(text: '詳細履歴', icon: Icon(Icons.list, size: 20)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildWeeklyTab(),
            _buildBoxStatusTab(),
            _buildDetailHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildWeeklyOverview(),
          const SizedBox(height: 20),
          _buildWeeklyChart(),
          const SizedBox(height: 20),
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '今週の学習状況',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '学習単語',
                  '${weeklyStats['totalWords']}語',
                  Icons.book,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '学習時間',
                  '${(weeklyStats['totalTime'] / 60).toStringAsFixed(1)}時間',
                  Icons.timer,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '習得単語',
                  '${weeklyStats['memorizedWords']}語',
                  Icons.check_circle,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '復習予定',
                  '${weeklyStats['reviewWords']}語',
                  Icons.refresh,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '週間学習グラフ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildChartBars(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              return Text(
                DateFormat('E', 'ja').format(date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars() {
    final weeklyData = [5, 8, 12, 6, 15, 18, 12]; // ダミーデータ
    final maxValue = weeklyData.reduce(math.max).toDouble();
    
    return weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      final height = (value / maxValue * 150).clamp(10.0, 150.0);
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 30,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.indigo.shade400,
                  Colors.indigo.shade200,
                ],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.local_fire_department, 
                    color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${weeklyStats['currentStreak']}日',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text(
                  '現在の連続学習',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: Colors.grey.shade300),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.emoji_events, 
                    color: Colors.amber, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${weeklyStats['longestStreak']}日',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const Text(
                  '最長記録',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildBoxDistribution(),
          const SizedBox(height: 20),
          _buildBoxExplanation(),
        ],
      ),
    );
  }

  Widget _buildBoxDistribution() {
    final totalWords = boxDistribution.map((e) => e['count'] as int).reduce((a, b) => a + b);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BOX別単語分布',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...boxDistribution.map((box) {
            final count = box['count'] as int;
            final percentage = (count / totalWords * 100).round();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: box['color'],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                box['box'].toString(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'BOX ${box['box']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$count語 ($percentage%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: box['color'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: count / totalWords,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(box['color']),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBoxExplanation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ライトナーシステム復習間隔',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildBoxExplanationRow('BOX 1', '12時間後', Colors.red),
          _buildBoxExplanationRow('BOX 2', '48時間後', Colors.orange),
          _buildBoxExplanationRow('BOX 3', '96時間後', Colors.yellow.shade700),
          _buildBoxExplanationRow('BOX 4', '168時間後', Colors.green),
          _buildBoxExplanationRow('BOX 5', '336時間後', Colors.blue),
          _buildBoxExplanationRow('BOX ∞', '完全定着', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildBoxExplanationRow(String box, String interval, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                box.split(' ')[1],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              box,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            interval,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: dailyHistory.length,
      itemBuilder: (context, index) {
        return _buildDailyHistoryCard(dailyHistory[index]);
      },
    );
  }

  Widget _buildDailyHistoryCard(Map<String, dynamic> dayData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日付とサマリー
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('M月d日(E)', 'ja').format(dayData['date']),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dayData['avgScore']}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 学習統計
          Row(
            children: [
              _buildDetailStat('セッション', '${dayData['studySessions']}回', Icons.play_circle),
              _buildDetailStat('単語', '${dayData['wordsLearned']}語', Icons.book),
              _buildDetailStat('時間', '${dayData['timeSpent']}分', Icons.timer),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 学習ステージ
          Wrap(
            spacing: 8,
            children: (dayData['stages'] as List<String>).map((stage) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stage,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // BOX移動詳細
          const Text(
            'BOX移動',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: (dayData['boxMovements'] as Map<String, int>)
                .entries
                .map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.key}: ${entry.value}語',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}