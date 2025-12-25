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
    {'box': 1, 'count': 45, 'color': AppColors.incorrect},
    {'box': 2, 'count': 38, 'color': AppColors.warning},
    {'box': 3, 'count': 25, 'color': AppColors.warning.withOpacity(0.7)},
    {'box': 4, 'count': 18, 'color': AppColors.correct},
    {'box': 5, 'count': 12, 'color': AppColors.accent},
    {'box': '∞', 'count': 18, 'color': AppColors.primary},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 4技能タブ（インデックス2）への遷移を制限
    _tabController.addListener(() {
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        _tabController.index = 1; // 習得単語タブへ強制的に戻す
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('4技能分析機能は現在準備中です。'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
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
        backgroundColor: AppColors.background, // 全てベージュに統一
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textPrimary.withOpacity(0.6),
          tabs: [
            Tab(text: 'BOX状況', icon: Icon(Icons.inventory, size: 20)),
            Tab(text: '習得単語', icon: Icon(Icons.library_books, size: 20)),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 20, color: AppColors.textPrimary.withOpacity(0.2)),
                  Text(
                    '4技能',
                    style: TextStyle(
                      fontSize: 14, // 他のタブと合わせる
                      color: AppColors.textPrimary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
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
            _buildBoxStatusTab(),
            _buildMasteredWordsTab(),
            _buildComingSoonTab(), // 4技能を準備中画面へ
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
        color: AppColors.surface,
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
              color: AppColors.textPrimary,
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
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '学習時間',
                  '${(weeklyStats['totalTime'] / 60).toStringAsFixed(1)}時間',
                  Icons.timer,
                  AppColors.correct,
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
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '復習予定',
                  '${weeklyStats['reviewWords']}語',
                  Icons.refresh,
                  AppColors.primary,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20), // アイコンのみ色を戻す
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary.withOpacity(0.6),
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
        color: AppColors.surface,
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
              color: AppColors.textPrimary,
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
                  color: AppColors.textPrimary.withOpacity(0.6),
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
                  AppColors.accent,
                  AppColors.accent.withOpacity(0.3),
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
        color: AppColors.surface,
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
                    color: AppColors.warning, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${weeklyStats['currentStreak']}日',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  '現在の連続学習',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary.withOpacity(0.3)),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: AppColors.textPrimary.withOpacity(0.3)),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.emoji_events, 
                    color: AppColors.warning, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${weeklyStats['longestStreak']}日',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  '最長記録',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary.withOpacity(0.3)),
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
          _buildOverallProgress(),
          const SizedBox(height: 20),
          _buildBoxDistribution(),
          const SizedBox(height: 20),
          _buildBoxExplanation(),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    // ホーム画面と共通の進捗計算（ダミー）
    const progress = 0.45; 
    const percentage = (progress * 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '学習の進み具合',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '中1レベル 全10ステージ中 4ステージ完了',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxDistribution() {
    final totalWords = boxDistribution.map((e) => e['count'] as int).reduce((a, b) => a + b);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
            'BOX別単語分布（中1レベル）',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...boxDistribution.map((box) {
            final count = box['count'] as int;
            final percentage = (count / totalWords * 100).round();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _showBoxWordsDialog(box['box'], box['color']),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: box['color'].withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: box['color'].withOpacity(0.2),
                      width: 1,
                    ),
                  ),
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
                                      color: AppColors.surface,
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
                          Row(
                            children: [
                              Text(
                                '$count語',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.textPrimary.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: count / totalWords,
                        backgroundColor: AppColors.surface.withOpacity(0.6),
                        valueColor: AlwaysStoppedAnimation<Color>(box['color']),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
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
        color: AppColors.surface,
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildBoxExplanationRow('BOX 1', '12時間後', AppColors.incorrect),
          _buildBoxExplanationRow('BOX 2', '48時間後', AppColors.warning),
          _buildBoxExplanationRow('BOX 3', '96時間後', AppColors.warning.withOpacity(0.7)),
          _buildBoxExplanationRow('BOX 4', '168時間後', AppColors.correct),
          _buildBoxExplanationRow('BOX 5', '336時間後', AppColors.accent),
          _buildBoxExplanationRow('BOX ∞', '完全定着', AppColors.primary),
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
              color: AppColors.textPrimary.withOpacity(0.6),
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
        color: AppColors.surface,
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
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.correct.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dayData['avgScore']}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
                  color: AppColors.accent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
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
              color: AppColors.textPrimary,
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
                  color: AppColors.warning.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.key}: ${entry.value}語',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
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
          Icon(icon, size: 16, color: AppColors.textPrimary.withOpacity(0.6)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBoxWordsDialog(dynamic boxNumber, Color boxColor) {
    // ダミーデータ：BOX別の単語リスト
    final Map<dynamic, List<Map<String, dynamic>>> boxWords = {
      1: [
        {'english': 'apple', 'japanese': 'りんご', 'accuracy': 45},
        {'english': 'book', 'japanese': '本', 'accuracy': 67},
        {'english': 'cat', 'japanese': '猫', 'accuracy': 33},
        {'english': 'dog', 'japanese': '犬', 'accuracy': 78},
        {'english': 'egg', 'japanese': '卵', 'accuracy': 56},
      ],
      2: [
        {'english': 'beautiful', 'japanese': '美しい', 'accuracy': 82},
        {'english': 'happy', 'japanese': '幸せな', 'accuracy': 75},
        {'english': 'study', 'japanese': '勉強する', 'accuracy': 69},
        {'english': 'friend', 'japanese': '友達', 'accuracy': 88},
      ],
      3: [
        {'english': 'computer', 'japanese': 'コンピューター', 'accuracy': 91},
        {'english': 'important', 'japanese': '重要な', 'accuracy': 85},
        {'english': 'develop', 'japanese': '開発する', 'accuracy': 79},
      ],
      4: [
        {'english': 'innovation', 'japanese': '革新', 'accuracy': 94},
        {'english': 'technology', 'japanese': '技術', 'accuracy': 87},
      ],
      5: [
        {'english': 'comprehensive', 'japanese': '包括的な', 'accuracy': 96},
        {'english': 'collaborate', 'japanese': '協力する', 'accuracy': 93},
      ],
      '∞': [
        {'english': 'run', 'japanese': '走る', 'accuracy': 100},
        {'english': 'water', 'japanese': '水', 'accuracy': 100},
        {'english': 'school', 'japanese': '学校', 'accuracy': 100},
      ],
    };

    final words = boxWords[boxNumber] ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        boxNumber.toString(),
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BOX $boxNumber の単語',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${words.length}語',
                          style: TextStyle(
                            fontSize: 14,
                            color: boxColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 単語リスト
              Expanded(
                child: ListView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: boxColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word['english'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  word['japanese'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getAccuracyColor(word['accuracy']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getAccuracyColor(word['accuracy']),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${word['accuracy']}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getAccuracyColor(word['accuracy']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 90) return AppColors.correct;
    if (accuracy >= 70) return AppColors.warning;
    return AppColors.incorrect;
  }


  Widget _buildSkillsTab() {
    // ダミーデータ：4技能評価
    final skillsData = [
      {'skill': 'Reading', 'score': 85, 'color': AppColors.primary},
      {'skill': 'Listening', 'score': 72, 'color': AppColors.accent},
      {'skill': 'Speaking', 'score': 68, 'color': AppColors.warning},
      {'skill': 'Writing', 'score': 79, 'color': AppColors.correct},
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 4技能概要
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                  '4技能評価',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 技能別グラフ
                ...skillsData.map((skill) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              skill['skill'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${skill['score'] as int}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: skill['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (skill['score'] as int) / 100,
                          backgroundColor: AppColors.surface.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(skill['color'] as Color),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteredWordsTab() {
    // ダミーデータ：習得した単語
    final masteredWords = [
      {'english': 'run', 'japanese': '走る', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'water', 'japanese': '水', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'school', 'japanese': '学校', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'comprehensive', 'japanese': '包括的な', 'accuracy': 96, 'category': 'BOX5'},
      {'english': 'collaborate', 'japanese': '協力する', 'accuracy': 93, 'category': 'BOX5'},
      {'english': 'innovation', 'japanese': '革新', 'accuracy': 94, 'category': 'BOX4'},
      {'english': 'technology', 'japanese': '技術', 'accuracy': 87, 'category': 'BOX4'},
      {'english': 'apple', 'japanese': 'りんご', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'beautiful', 'japanese': '美しい', 'accuracy': 98, 'category': 'BOX5'},
      {'english': 'challenge', 'japanese': '挑戦', 'accuracy': 92, 'category': 'BOX4'},
      {'english': 'development', 'japanese': '開発', 'accuracy': 95, 'category': 'BOX5'},
      {'english': 'education', 'japanese': '教育', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'future', 'japanese': '未来', 'accuracy': 90, 'category': 'BOX4'},
      {'english': 'generation', 'japanese': '世代', 'accuracy': 88, 'category': 'BOX4'},
      {'english': 'history', 'japanese': '歴史', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'information', 'japanese': '情報', 'accuracy': 94, 'category': 'BOX5'},
      {'english': 'journey', 'japanese': '旅', 'accuracy': 91, 'category': 'BOX4'},
      {'english': 'knowledge', 'japanese': '知識', 'accuracy': 97, 'category': 'BOX5'},
      {'english': 'language', 'japanese': '言語', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'mountain', 'japanese': '山', 'accuracy': 93, 'category': 'BOX4'},
      {'english': 'negative', 'japanese': '否定的な', 'accuracy': 89, 'category': 'BOX4'},
      {'english': 'opportunity', 'japanese': '機会', 'accuracy': 96, 'category': 'BOX5'},
      {'english': 'practice', 'japanese': '練習', 'accuracy': 100, 'category': 'BOX∞'},
      {'english': 'question', 'japanese': '質問', 'accuracy': 92, 'category': 'BOX4'},
      {'english': 'responsible', 'japanese': '責任がある', 'accuracy': 94, 'category': 'BOX5'},
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 習得単語概要
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                  '習得した単語（BOX４以上）',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
                  children: [
                    Container(
                      constraints: const BoxConstraints(minWidth: 160),
                      child: _buildStatCard(
                        '習得した単語数',
                        '${masteredWords.length}語',
                        Icons.star,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 単語クラウド（タグ表示）
          Container(
            padding: const EdgeInsets.all(4),
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: masteredWords.map((word) {
                return ActionChip(
                  elevation: 0,
                  pressElevation: 2,
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.textPrimary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  label: Text(
                    word['english'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onPressed: () {
                    // タップ時に詳細ダイアログを表示（オプション）
                    _showWordDetailDialog(word);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: AppColors.textPrimary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'COMING SOON',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary.withOpacity(0.3),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '4技能分析機能は今後のアップデートで追加予定です',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showWordDetailDialog(Map<String, dynamic> word) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word['english'] as String,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                word['japanese'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  word['category'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
