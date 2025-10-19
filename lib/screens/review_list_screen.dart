import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/word.dart';
import '../theme/app_colors.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late List<Word> reviewWords;
  String filterBy = 'all';

  @override
  void initState() {
    super.initState();
    reviewWords = DummyData.getReviewWords();
  }

  List<Word> get filteredWords {
    switch (filterBy) {
      case 'noun':
        return reviewWords.where((w) => w.partOfSpeech == '名詞').toList();
      case 'verb':
        return reviewWords.where((w) => w.partOfSpeech == '動詞').toList();
      case 'adjective':
        return reviewWords.where((w) => w.partOfSpeech == '形容詞').toList();
      default:
        return reviewWords;
    }
  }

  void _removeFromReviewList(Word word) {
    setState(() {
      word.isInReviewList = false;
      reviewWords.remove(word);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${word.english} を復習リストから削除しました'),
        action: SnackBarAction(
          label: '元に戻す',
          onPressed: () {
            setState(() {
              word.isInReviewList = true;
              reviewWords.add(word);
            });
          },
        ),
      ),
    );
  }

  void _markAsMemorized(Word word) {
    setState(() {
      word.isMemorized = true;
      word.isInReviewList = false;
      reviewWords.remove(word);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${word.english} を習得済みにしました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('復習リスト'),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_filled),
            onPressed: reviewWords.isNotEmpty
                ? () => _startReviewSession()
                : null,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: filteredWords.isEmpty
                  ? _buildEmptyState()
                  : _buildWordList(),
            ),
          ],
        ),
      ),
      floatingActionButton: reviewWords.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _startReviewSession,
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.play_arrow),
              label: const Text('復習開始'),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '要復習の単語',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${reviewWords.length} 単語',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.repeat,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('すべて', 'all'),
          const SizedBox(width: 10),
          _buildChip('名詞', 'noun'),
          const SizedBox(width: 10),
          _buildChip('動詞', 'verb'),
          const SizedBox(width: 10),
          _buildChip('形容詞', 'adjective'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = filterBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          filterBy = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.orange.shade200,
      checkmarkColor: Colors.orange.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.orange.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            filterBy == 'all' 
                ? '復習する単語がありません'
                : 'この品詞の単語はありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '学習を続けましょう！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredWords.length,
      itemBuilder: (context, index) {
        final word = filteredWords[index];
        return Dismissible(
          key: Key(word.id),
          background: _buildDismissBackground(Colors.green, Icons.check, true),
          secondaryBackground: _buildDismissBackground(Colors.red, Icons.delete, false),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              _markAsMemorized(word);
            } else {
              _removeFromReviewList(word);
            }
            return false;
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(20),
              childrenPadding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorByPartOfSpeech(word.partOfSpeech),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    word.english[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                word.english,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    word.japanese,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorByPartOfSpeech(word.partOfSpeech)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      word.partOfSpeech,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getColorByPartOfSpeech(word.partOfSpeech),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => _markAsMemorized(word),
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      label: const Text(
                        '覚えた',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _removeFromReviewList(word),
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      label: const Text(
                        '削除',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground(Color color, IconData icon, bool isLeft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Color _getColorByPartOfSpeech(String partOfSpeech) {
    switch (partOfSpeech) {
      case '名詞':
        return Colors.blue;
      case '動詞':
        return Colors.green;
      case '形容詞':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _startReviewSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('復習セッション開始'),
        content: Text(
          '${reviewWords.length}個の単語を復習します。\n準備はよろしいですか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 復習モードの実装（インプットトレーニングと同様の画面を使用）
              Navigator.pushNamed(
                context,
                '/input-training',
                arguments: 'review',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('開始'),
          ),
        ],
      ),
    );
  }
}