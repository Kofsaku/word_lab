import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../data/dummy_data.dart';
import '../models/word.dart';
import '../services/database_helper.dart';
import '../services/audio_service.dart';

class InputTrainingScreen extends StatefulWidget {
  final String stageId;

  const InputTrainingScreen({super.key, required this.stageId});

  @override
  State<InputTrainingScreen> createState() => _InputTrainingScreenState();
}

class _InputTrainingScreenState extends State<InputTrainingScreen> {
  List<Word> words = [];
  late CardSwiperController controller;
  List<Word> memorizedWords = [];
  List<Word> reviewWords = [];
  int currentIndex = 0;
  final AudioService _audioService = AudioService.instance;
  
  // new_req仕様の追加フィールド
  bool _showMeaning = false;
  Timer? _meaningTimer;

  @override
  void initState() {
    super.initState();
    _loadWords();
    controller = CardSwiperController();
  }

  Future<void> _loadWords() async {
    try {
      final dbWords = await DatabaseHelper.instance.getWordsByStageId(widget.stageId);
      
      // データベースが空の場合はダミーデータを使用
      if (dbWords.isEmpty) {
        final dummyWords = DummyData.getWordsByStageId(widget.stageId);
        setState(() {
          words = dummyWords.take(6).toList();
        });
      } else {
        setState(() {
          words = dbWords.take(6).toList();
        });
      }
      
      if (words.isNotEmpty) {
        _playCurrentWordAudio();
      }
    } catch (e) {
      // エラーが発生した場合はダミーデータを使用
      final dummyWords = DummyData.getWordsByStageId(widget.stageId);
      setState(() {
        words = dummyWords.take(6).toList();
      });
      
      if (words.isNotEmpty) {
        _playCurrentWordAudio();
      }
    }
  }

  void _playCurrentWordAudio() {
    if (currentIndex < words.length) {
      _audioService.playWordAudio(words[currentIndex].english);
      
      // 1秒後に意味・品詞を表示（new_req仕様）
      _meaningTimer?.cancel();
      setState(() => _showMeaning = false);
      
      _meaningTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _showMeaning = true);
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _meaningTimer?.cancel();
    super.dispose();
  }

  void _navigateToCheckTime() {
    Navigator.pushReplacementNamed(
      context,
      '/check-time',
      arguments: {
        'stageId': widget.stageId,
        'words': words,
      },
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex >= words.length) return false;
    
    final word = words[previousIndex];
    
    if (direction == CardSwiperDirection.right) {
      memorizedWords.add(word);
      word.isMemorized = true;
      _updateWordProgress(word, true);
    } else if (direction == CardSwiperDirection.left) {
      reviewWords.add(word);
      word.isInReviewList = true;
      _updateWordProgress(word, false);
    }
    
    setState(() {
      this.currentIndex = (currentIndex ?? words.length);
    });
    
    if (currentIndex != null && currentIndex < words.length) {
      _playCurrentWordAudio();
    }
    
    // すべてのカードを処理したらチェックタイムへ遷移
    if (previousIndex == words.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _navigateToCheckTime();
        }
      });
    }
    
    return true;
  }

  Future<void> _updateWordProgress(Word word, bool isMemorized) async {
    await DatabaseHelper.instance.updateWordProgressAfterAnswer(
      'default_user',
      int.parse(word.id),
      isMemorized,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final displayIndex = currentIndex >= words.length ? words.length : currentIndex + 1;
    final progress = words.isNotEmpty ? currentIndex / words.length : 0.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(progress, displayIndex),
              Expanded(
                child: Stack(
                  children: [
                    _buildSwiper(),
                    _buildSwipeIndicators(),
                  ],
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double progress, int displayIndex) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                '$displayIndex / ${words.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
          ),
        ],
      ),
    );
  }


  Widget _buildSwiper() {
    return Center(
      child: SizedBox(
        height: 500,
        child: CardSwiper(
          controller: controller,
          cardsCount: words.length,
          numberOfCardsDisplayed: 3,
          backCardOffset: const Offset(20, 20),
          padding: const EdgeInsets.all(20),
          onSwipe: _onSwipe,
          cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
            if (index >= words.length) {
              return const SizedBox.shrink();
            }
            
            final word = words[index];
            
            return _buildWordCard(word);
          },
        ),
      ),
    );
  }

  Widget _buildWordCard(Word word) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              word.partOfSpeech,
              style: TextStyle(
                color: Colors.purple.shade700,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            word.english,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 100,
            height: 2,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 30),
          Text(
            word.japanese,
            style: TextStyle(
              fontSize: 28,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.volume_up,
                  color: Colors.grey.shade600,
                  size: 30,
                ),
                onPressed: () {
                  _audioService.playWordAudio(word.english);
                },
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.bookmark_border,
                color: Colors.grey.shade400,
                size: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    return Stack(
      children: [
        Positioned(
          left: 40,
          top: MediaQuery.of(context).size.height * 0.25,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.orange,
              size: 30,
            ),
          ),
        ),
        Positioned(
          right: 40,
          top: MediaQuery.of(context).size.height * 0.25,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.green,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            label: '要復習',
            color: Colors.orange,
            onPressed: () => controller.swipe(CardSwiperDirection.left),
          ),
          _buildActionButton(
            icon: Icons.refresh,
            label: '戻る',
            color: Colors.grey,
            onPressed: () => controller.undo(),
          ),
          _buildActionButton(
            icon: Icons.check,
            label: '覚えた',
            color: Colors.green,
            onPressed: () => controller.swipe(CardSwiperDirection.right),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}