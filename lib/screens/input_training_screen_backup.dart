import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:rive/rive.dart' hide LinearGradient, Image;
import '../data/dummy_data.dart';
import '../models/word.dart';
import '../services/database_helper.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';

class InputTrainingScreen extends StatefulWidget {
  final String stageId;

  const InputTrainingScreen({super.key, required this.stageId});

  @override
  State<InputTrainingScreen> createState() => _InputTrainingScreenState();
}

class _InputTrainingScreenState extends State<InputTrainingScreen>
    with TickerProviderStateMixin {
  List<Word> words = [];
  List<Word> memorizedWords = [];
  List<Word> reviewWords = [];
  List<Map<String, dynamic>> stackedCards = []; // {word: Word, type: 'confident'/'review'}
  int currentIndex = 0;
  final AudioService _audioService = AudioService.instance;
  
  // new_req仕様のフィールド
  bool _showMeaning = false;
  Timer? _meaningTimer;
  late AnimationController _cardAnimationController;
  late AnimationController _stackAnimationController;
  late AnimationController _characterAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<Offset> _stackAnimation;
  late Animation<double> _characterFloatAnimation;
  late Animation<double> _characterScaleAnimation;
  AnimationController? _cardPopInController;
  Animation<double>? _cardPopInAnimation;
  bool _isSwipeDetected = false;
  String _swipeDirection = '';
  bool _isUserSwiping = false;
  double _dragOffset = 0.0;
  double _dragRotation = 0.0;
  
  // Ghost trail effects
  List<Widget> _trailWidgets = [];
  List<double> _trailOpacities = [0.4, 0.25, 0.15];
  List<Offset> _trailOffsets = [Offset.zero, Offset.zero, Offset.zero];
  static const double _swipeThreshold = 96.0;
  bool _isAutoSliding = false;
  
  // アニメーション画像シーケンス
  final List<String> _animationFrames = [
    'assets/images/animations/Idle.png',
    'assets/images/animations/Walk.png',
    'assets/images/animations/Flag.png',
    'assets/images/animations/Sleep_A.png',
    'assets/images/animations/Sleep_B.png',
  ];
  int _currentFrameIndex = 0;
  Timer? _frameTimer;
  
  // Rive animation control
  StateMachineController? _riveController;
  SMITrigger? _correctStartTrigger;
  SMITrigger? _incorrectStartTrigger;
  String _currentStateMachine = 'Idle_State_Machine';
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWords();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    
    _stackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );

    _characterAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _cardPopInController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOut,
    ));

    _stackAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stackAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _cardPopInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardPopInController!,
      curve: const Cubic(0.22, 1.2, 0.36, 1), // HTML's cubic-bezier
    ));

    _characterFloatAnimation = Tween<double>(
      begin: -15.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _characterAnimationController,
      curve: Curves.easeInOut,
    ));

    _characterScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _characterAnimationController,
      curve: Curves.easeInOut,
    ));

    // 画像フレームアニメーション開始
    _startFrameAnimation();
  }

  void _startFrameAnimation() {
    _frameTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _currentFrameIndex = (_currentFrameIndex + 1) % _animationFrames.length;
        });
      }
    });
  }

  Future<void> _loadWords() async {
    try {
      final dbWords = await DatabaseHelper.instance.getWordsByStageId(widget.stageId);
      
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
        // Trigger initial pop-in animation
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _cardPopInController?.forward();
          }
        });
        _playCurrentWordAudio();
      }
    } catch (e) {
      final dummyWords = DummyData.getWordsByStageId(widget.stageId);
      setState(() {
        words = dummyWords.take(6).toList();
      });
      
      if (words.isNotEmpty) {
        // Trigger initial pop-in animation
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _cardPopInController?.forward();
          }
        });
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

  void _handleSwipe(String direction) {
    if (_isSwipeDetected || currentIndex >= words.length) return;
    
    setState(() {
      _isSwipeDetected = true;
      _swipeDirection = direction;
      _isAutoSliding = true;
    });

    final word = words[currentIndex];
    
    // Auto-slide animation with ghost trails
    _performAutoSlideAnimation(direction).then((_) {
      if (direction == 'right') {
        // 「知ってる」- カード積み上げ
        memorizedWords.add(word);
        stackedCards.add({'word': word, 'type': 'confident'});
        _stackAnimationController.forward();
        _updateWordProgress(word, true);
      } else {
        // 「念入りに学習」- 再ループ
        reviewWords.add(word);
        stackedCards.add({'word': word, 'type': 'review'});
        _updateWordProgress(word, false);
      }
      
      _moveToNextWord();
    });
  }
  
  Future<void> _performAutoSlideAnimation(String direction) async {
    final directionSign = direction == 'right' ? 1 : -1;
    final speedX = 600.0 * directionSign; // HTML: 600 * direction
    
    // Staggered trail animation exactly like HTML
    for (int i = 0; i < _trailOpacities.length; i++) {
      Future.delayed(Duration(milliseconds: i * 40), () { // HTML: delay = i * 40
        if (mounted) {
          setState(() {
            _trailOffsets[i] = Offset(speedX, 0); // Pure horizontal
            _trailOpacities[i] = 0.0;
          });
        }
      });
    }
    
    // Main card slide with HTML timing and easing
    return _cardAnimationController.forward();
  }

  void _moveToNextWord() {
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) {
        setState(() {
          currentIndex++;
          _isSwipeDetected = false;
          _swipeDirection = '';
          _isUserSwiping = false;
          _isAutoSliding = false;
          _dragOffset = 0.0;
          _dragRotation = 0.0;
          // Reset trail effects
          _trailOffsets = [Offset.zero, Offset.zero, Offset.zero];
          _trailOpacities = [0.4, 0.25, 0.15];
        });
        
        _cardAnimationController.reset();
        
        if (currentIndex < words.length) {
          // Trigger pop-in animation for new card
          _cardPopInController?.reset();
          _cardPopInController?.forward();
          _playCurrentWordAudio();
        } else {
          _checkCompletion();
        }
      }
    });
  }

  void _checkCompletion() {
    if (memorizedWords.length == words.length) {
      // 全て「知ってる」でスワイプした場合、チェックタイムへ
      _navigateToCheckTime();
    } else {
      // 復習が必要な単語がある場合、再ループまたは選択画面
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('インプット完了'),
        content: Text(
          '覚えた単語：${memorizedWords.length}語\n'
          '復習する単語：${reviewWords.length}語\n\n'
          'チェックタイムに進みますか？',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartWithReviewWords();
            },
            child: const Text('復習する'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCheckTime();
            },
            child: const Text('チェックタイムへ'),
          ),
        ],
      ),
    );
  }

  void _restartWithReviewWords() {
    setState(() {
      words = List.from(reviewWords);
      reviewWords.clear();
      currentIndex = 0;
      _showMeaning = false;
      _isUserSwiping = false;
      _dragOffset = 0.0;
      _dragRotation = 0.0;
    });
    _playCurrentWordAudio();
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

  void _updateWordProgress(Word word, bool isMemorized) {
    // ダミー実装 - 実際はデータベース更新
    word.isMemorized = isMemorized;
    word.lastStudiedAt = DateTime.now();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _stackAnimationController.dispose();
    _characterAnimationController.dispose();
    _cardPopInController?.dispose();
    _meaningTimer?.cancel();
    _frameTimer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMainContent()),
              _buildProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 28),
          ),
          const Spacer(),
          Text(
            'インプットトレーニング',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // バランス用
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        Column(
          children: [
            // 説明テキスト
            _buildInstructionText(),
            
            const SizedBox(height: 40),
            
            // キャラクターとカードスタックの横並び表示
            _buildCharacterAndStackRow(),
            
            const Spacer(),
            
            // 例文表示
            _buildExampleSection(),
            
            const SizedBox(height: 40),
          ],
        ),
        
        
      ],
    );
  }

  Widget _buildWordCard() {
    return GestureDetector(
      onPanUpdate: (details) => _handlePanUpdate(details),
      onPanEnd: (details) => _handlePanEnd(details),
      child: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _cardAnimation.value,
            child: Transform.rotate(
              angle: _isSwipeDetected 
                  ? (_swipeDirection == 'right' ? 0.1 : -0.1) 
                  : 0,
              child: Container(
                width: 280,
                height: 400,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 英単語（中央大）
                    Text(
                      words[currentIndex].english,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // 日本語訳・品詞（1秒後に表示）
                    AnimatedOpacity(
                      opacity: _showMeaning ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            words[currentIndex].japanese,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              words[currentIndex].partOfSpeech,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardStack() {\n    return Container(\n      width: 120,\n      height: 200,\n      child: Column(\n        children: [\n          Expanded(\n            child: ListView.builder(\n              reverse: true,\n              itemCount: stackedCards.length,\n              itemBuilder: (context, index) {\n                final cardData = stackedCards[index];\n                final isLatest = index == stackedCards.length - 1;\n                \n                return Container(\n                  margin: const EdgeInsets.only(bottom: 4),\n                  child: AnimatedBuilder(\n                    animation: _stackAnimationController,\n                    builder: (context, child) {\n                      if (isLatest && _stackAnimationController.isAnimating) {\n                        final t = _stackAnimationController.value;\n                        \n                        double scale, translateY, opacity;\n                        if (t <= 0.7) {\n                          final phase1 = t / 0.7;\n                          opacity = phase1;\n                          translateY = 30 * (1 - phase1) + (-6 * phase1);\n                          scale = 0.92 + (1.02 - 0.92) * phase1;\n                        } else {\n                          final phase2 = (t - 0.7) / 0.3;\n                          opacity = 1.0;\n                          translateY = -6 * (1 - phase2);\n                          scale = 1.02 - 0.02 * phase2;\n                        }\n                        \n                        return Opacity(\n                          opacity: opacity,\n                          child: Transform.translate(\n                            offset: Offset(0, translateY),\n                            child: Transform.scale(\n                              scale: scale,\n                              child: _buildStackCard(cardData),\n                            ),\n                          ),\n                        );\n                      }\n                      \n                      return _buildStackCard(cardData);\n                    },\n                  ),\n                );\n              },\n            ),\n          ),\n        ],\n      ),\n    );\n  }\n  \n  Widget _buildStackCard(Map<String, dynamic> cardData) {\n    final word = cardData['word'] as Word;\n    final type = cardData['type'] as String;\n    \n    // Color coding: confident = blue, review = red\n    final cardColor = type == 'confident' \n        ? const Color(0xFF60A5FA) // Blue\n        : const Color(0xFFF87171); // Red\n    \n    return Container(\n      width: 88,\n      height: 44,\n      decoration: BoxDecoration(\n        color: Colors.black,\n        borderRadius: BorderRadius.circular(10),\n        border: Border.all(\n          color: cardColor,\n          width: 2,\n        ),\n        boxShadow: [\n          BoxShadow(\n            color: Colors.black.withOpacity(0.25),\n            blurRadius: 20,\n            offset: const Offset(0, 8),\n          ),\n        ],\n      ),\n      child: Center(\n        child: Text(\n          word.english,\n          style: TextStyle(\n            fontSize: 12,\n            fontWeight: FontWeight.w700,\n            color: cardColor,\n          ),\n          textAlign: TextAlign.center,\n          overflow: TextOverflow.ellipsis,\n        ),\n      ),\n    );\n  }\n\n  Widget _buildCardStack() {
    return Container(
      width: 120,
      height: 140,
      child: Stack(
        children: List.generate(
          6, // Show all 6 possible cards
          (index) {
            final isActive = index < memorizedWords.length;
            final isLatest = index == memorizedWords.length - 1 && isActive;
            
            // HTML-style brick offset: alternate positioning
            final rightOffset = (index % 2 == 0) ? 0.0 : 12.0;
            
            return Positioned(
              bottom: index * 8.0 + (index > 0 ? 8.0 : 0.0), // 8px gap + 8px margin
              right: rightOffset,
              child: AnimatedBuilder(
                animation: _stackAnimationController,
                builder: (context, child) {
                  // Pop-stack animation for latest card (HTML cubic-bezier)
                  if (isLatest) {
                    final t = _stackAnimationController.value;
                    final cubicValue = _cubicBezier(0.2, 0.9, 0.22, 1.2, t);
                    
                    double scale, translateY, opacity;
                    if (t <= 0.7) {
                      // 0-70%: opacity 0->1, translateY 30px->-6px, scale 0.92->1.02
                      final phase1 = t / 0.7;
                      opacity = phase1;
                      translateY = 30 * (1 - phase1) + (-6 * phase1);
                      scale = 0.92 + (1.02 - 0.92) * phase1;
                    } else {
                      // 70-100%: opacity 1, translateY -6px->0, scale 1.02->1
                      final phase2 = (t - 0.7) / 0.3;
                      opacity = 1.0;
                      translateY = -6 * (1 - phase2);
                      scale = 1.02 - 0.02 * phase2;
                    }
                    
                    return Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(0, translateY),
                        child: Transform.scale(
                          scale: scale,
                          child: _buildStackCard(index, isActive, memorizedWords.length > index ? memorizedWords[index].english : ''),
                        ),
                      ),
                    );
                  }
                  
                  return _buildStackCard(index, isActive, memorizedWords.length > index ? memorizedWords[index].english : '');
                },
              ),
            );
          },
        ),
      ),
    );
  }
  
  // HTML cubic-bezier approximation
  double _cubicBezier(double x1, double y1, double x2, double y2, double t) {
    return (1 - t) * (1 - t) * (1 - t) * 0 + 
           3 * (1 - t) * (1 - t) * t * y1 + 
           3 * (1 - t) * t * t * y2 + 
           t * t * t * 1;
  }
  
  Widget _buildStackCard(int index, bool isActive, String word) {
    return Container(
      width: 88, // clamp(120px, 88%, 210px) - taking middle value
      height: 44,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE5E7EB) : Colors.transparent, // HTML #e5e7eb
        borderRadius: BorderRadius.circular(10),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : [],
      ),
      child: isActive ? Center(
        child: Text(
          word,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A), // HTML color
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ) : null,
    );
  }

  Widget _buildInstructionText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '自信がない単語は左スワイプ、自信がある\n単語は右スワイプ',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCharacterAndStackRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCharacterAnimation(),
          _buildCardStack(),
        ],
      ),
    );
  }

  Widget _buildExampleSection() {
    if (currentIndex >= words.length) return const SizedBox.shrink();
    
    return Column(
      children: [
        _buildSwipeableCard(),
        const SizedBox(height: 20),
        AnimatedOpacity(
          opacity: _showMeaning ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              Text(
                words[currentIndex].japanese,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  words[currentIndex].partOfSpeech,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'カードを左右にスワイプしてください',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeableCard() {
    return GestureDetector(
      onPanStart: (details) => _handlePanStart(details),
      onPanUpdate: (details) => _handlePanUpdate(details),
      onPanEnd: (details) => _handlePanEnd(details),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ghost trails (behind main card)
          ...List.generate(3, (index) => 
            AnimatedOpacity(
              opacity: _trailOpacities[index].clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 100),
              child: Transform.translate(
                offset: _trailOffsets[index],
                child: Container(
                  width: 300,
                  height: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.textPrimary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Main card with pop-in animation
          AnimatedBuilder(
            animation: _cardPopInController != null 
                ? Listenable.merge([_cardAnimation, _cardPopInController!])
                : _cardAnimation,
            builder: (context, child) {
              // Pop-in effect for new cards - safe access with fallback
              final popInValue = _cardPopInController?.isCompleted == true || _cardPopInController?.isAnimating == true 
                  ? _cardPopInAnimation?.value ?? 1.0
                  : 1.0;
              final popInScale = 0.92 + (popInValue * 0.08);
              final popInOffset = 18 * (1 - popInValue);
              final popInRotation = -0.035 * (1 - popInValue); // -2 degrees
              
              return Transform.scale(
                scale: _isAutoSliding 
                    ? 1.0 // No scale during slide
                    : popInScale,
                child: Transform.translate(
                  offset: _isAutoSliding 
                      ? Offset(
                          (_swipeDirection == 'right' ? 600 : -600),
                          0 // Pure horizontal slide
                        )
                      : Offset(_dragOffset, popInOffset),
                  child: Transform.rotate(
                    angle: _isAutoSliding 
                        ? 0.0 // No rotation during slide
                        : popInRotation, // Only pop-in rotation
                    child: AnimatedOpacity(
                      opacity: (_isAutoSliding 
                          ? 0.0 // Fade out during slide
                          : popInValue).clamp(0.0, 1.0),
                      duration: Duration(milliseconds: _isAutoSliding ? 380 : 320), // HTML slide duration
                      child: Container(
                        width: 300,
                        height: 180,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: _getCardColor(),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getBorderColor(),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // スワイプ方向インジケーター
                            if (_isUserSwiping) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 左スワイプインジケーター
                                  AnimatedOpacity(
                                    opacity: _dragOffset < -20 ? 1.0 : 0.3,
                                    duration: const Duration(milliseconds: 100),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.incorrect,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh, 
                                            color: AppColors.surface,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '念入り',
                                            style: TextStyle(
                                              color: AppColors.surface,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 右スワイプインジケーター
                                  AnimatedOpacity(
                                    opacity: _dragOffset > 20 ? 1.0 : 0.3,
                                    duration: const Duration(milliseconds: 100),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 20),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.correct,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '知ってる',
                                            style: TextStyle(
                                              color: AppColors.surface,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.check, 
                                            color: AppColors.surface,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            // 英単語
                            Text(
                              words[currentIndex].english,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCardColor() {
    if (!_isUserSwiping) return AppColors.surface;
    
    if (_dragOffset > 10) {
      final intensity = (_dragOffset / 150).clamp(0.0, 1.0);
      return Color.lerp(AppColors.surface, AppColors.correct, intensity * 0.3)!;
    } else if (_dragOffset < -10) {
      final intensity = (-_dragOffset / 150).clamp(0.0, 1.0);
      return Color.lerp(AppColors.surface, AppColors.incorrect, intensity * 0.3)!;
    }
    return AppColors.surface;
  }

  Color _getBorderColor() {
    if (!_isUserSwiping) return AppColors.textPrimary;
    
    if (_dragOffset > 20) {
      final intensity = (_dragOffset / 150).clamp(0.0, 1.0);
      return Color.lerp(AppColors.textPrimary, AppColors.correct, intensity)!;
    } else if (_dragOffset < -20) {
      final intensity = (-_dragOffset / 150).clamp(0.0, 1.0);
      return Color.lerp(AppColors.textPrimary, AppColors.incorrect, intensity)!;
    }
    return AppColors.textPrimary;
  }

  Widget _buildCharacterAnimation() {
    return _ContinuousBouncingWidget(
      child: _buildCharacterImage(),
    );
  }

  Widget _buildCharacterImage() {
    return Stack(
      children: [
        // Riveアニメーション（メイン）
        _buildRiveAnimation(),
        // 光沢効果
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: painting.RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.8],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiveAnimation() {
    return SizedBox(
      width: 120,
      height: 120,
      child: RiveAnimation.asset(
        'assets/animations/pikotan_animation.riv',
        animations: ['idle', 'walk_L', 'walk_R', 'sleep_A', 'flag_idle'],
        fit: BoxFit.contain,
        onInit: (artboard) {
          print('🎭 Rive Animation Loaded Successfully');
          print('Current animations playing: idle, walk_L, walk_R, sleep_A, flag_idle');
        },
      ),
    );
  }

  void _analyzeAndControlRive(Artboard artboard) {
    // Riveファイル詳細解析
    print('=== RIVE ANIMATION ANALYSIS ===');
    print('Artboard: ${artboard.name}');
    print('Size: ${artboard.width} x ${artboard.height}');
    
    // 利用可能なアニメーション一覧
    final animations = artboard.animations;
    print('Available Animations (${animations.length}):');
    int index = 0;
    for (final animation in animations) {
      print('  [$index] "${animation.name}"');
      index++;
    }
    
    // ステートマシン解析
    final stateMachines = artboard.stateMachines;
    print('Available State Machines (${stateMachines.length}):');
    
    StateMachineController? controller;
    final smList = stateMachines.toList();
    for (int i = 0; i < smList.length; i++) {
      final sm = smList[i];
      print('  [$i] "${sm.name}"');
      
      // 最初のステートマシンを使用
      if (i == 0) {
        try {
          controller = StateMachineController.fromArtboard(artboard, sm.name);
          if (controller != null) {
            artboard.addController(controller);
            _riveController = controller;
            print('    -> Selected as main controller');
          }
        } catch (e) {
          print('    -> Error creating controller: $e');
        }
      }
      
      // 入力パラメータ詳細
      try {
        final inputs = sm.inputs;
        final inputList = inputs.toList();
        print('    Inputs (${inputList.length}):');
        for (int j = 0; j < inputList.length; j++) {
          final input = inputList[j];
          print('      [$j] "${input.name}" (${input.runtimeType})');
        }
      } catch (e) {
        print('    -> Error reading inputs: $e');
      }
    }
    
    // 動的ステートマシン切り替えを開始
    _startDynamicStateMachineSwitching();
    
    // Flag State Machine の制御パラメータを設定
    _setupFlagControls();
    
    print('================================');
  }

  void _setupFlagControls() {
    Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Flag State Machineが選択されている場合のみトリガー実行
      if (_currentStateMachine == 'Flag_State_Machine' && _riveController != null) {
        try {
          final correctTrigger = _riveController!.findSMI<SMITrigger>('corrent_start');
          final incorrectTrigger = _riveController!.findSMI<SMITrigger>('incorrent_start');
          
          if (correctTrigger != null || incorrectTrigger != null) {
            final isCorrect = DateTime.now().millisecondsSinceEpoch % 2 == 0;
            if (isCorrect && correctTrigger != null) {
              correctTrigger.fire();
              print('🎯 Triggered: correct flag animation');
            } else if (!isCorrect && incorrectTrigger != null) {
              incorrectTrigger.fire();
              print('🚫 Triggered: incorrect flag animation');
            }
          }
        } catch (e) {
          print('Error triggering flag animation: $e');
        }
      }
    });
  }

  void _startDynamicStateMachineSwitching() {
    final stateMachines = [
      'Idle_State_Machine',
      'Walk_L_State_Machine',  
      'Walk_R_State_Machine',
      'Sleep_State_Machine',
      'Flag_State_Machine',
    ];
    
    _animationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // 次のステートマシンに切り替え
      final currentIndex = stateMachines.indexOf(_currentStateMachine);
      final nextIndex = (currentIndex + 1) % stateMachines.length;
      final nextStateMachine = stateMachines[nextIndex];
      
      print('🎭 Switching from $_currentStateMachine to $nextStateMachine');
      
      setState(() {
        _currentStateMachine = nextStateMachine;
      });
      
      // Flag State Machine の場合、トリガーも実行
      if (nextStateMachine == 'Flag_State_Machine') {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _correctStartTrigger != null && _incorrectStartTrigger != null) {
            // ランダムにcorrectまたはincorrectアニメーション実行
            final isCorrect = DateTime.now().millisecondsSinceEpoch % 2 == 0;
            if (isCorrect) {
              _correctStartTrigger!.fire();
              print('🎯 Triggered: correct animation');
            } else {
              _incorrectStartTrigger!.fire();
              print('🚫 Triggered: incorrect animation');
            }
          }
        });
      }
    });
  }

  Widget _buildSwipeHints() {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // 左スワイプヒント（念入り学習）
          Expanded(
            child: GestureDetector(
              onTap: () => _handleSwipe('left'),
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.incorrect.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: AppColors.surface, size: 20),
                    SizedBox(height: 4),
                    Text(
                      '念入り学習',
                      style: TextStyle(
                        color: AppColors.surface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 40),
          
          // 右スワイプヒント（知ってる）
          Expanded(
            child: GestureDetector(
              onTap: () => _handleSwipe('right'),
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.correct.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: AppColors.surface, size: 20),
                    SizedBox(height: 4),
                    Text(
                      '知ってる',
                      style: TextStyle(
                        color: AppColors.surface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      width: 280,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.correct, size: 64),
          SizedBox(height: 16),
          Text(
            'インプット完了！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${currentIndex.clamp(0, words.length)}/${words.length}語',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: words.isNotEmpty ? currentIndex / words.length : 0,
            backgroundColor: AppColors.surface.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isUserSwiping = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isSwipeDetected || _isAutoSliding) return;

    setState(() {
      // Horizontal-only movement (no rotation)
      final dx = details.localPosition.dx - 150; // Card center
      
      _dragOffset = dx;
      _dragRotation = 0.0; // No rotation for clean horizontal movement
      
      // Update ghost trails - only show when moving
      final th = _swipeThreshold;
      final amt = (_dragOffset.abs() / th).clamp(0.0, 1.0);
      
      for (int i = 0; i < _trailOpacities.length; i++) {
        final lag = (i + 1) * 0.18; // 18% of movement per layer
        
        if (_dragOffset.abs() > 5) { // Only show trails when actively dragging
          _trailOffsets[i] = Offset(_dragOffset * (1 - lag), 0); // Pure horizontal
          _trailOpacities[i] = ((0.18 + amt * 0.4) * (1 - i * 0.28)).clamp(0.0, 1.0);
        } else {
          // When stationary, trails perfectly overlap with main card
          _trailOffsets[i] = Offset.zero;
          _trailOpacities[i] = 0.0; // Hide when not moving
        }
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSwipeDetected || _isAutoSliding) return;

    final th = _swipeThreshold;
    final shouldSlide = _dragOffset.abs() > th;

    if (shouldSlide) {
      // HTML-style swipe detection
      if (_dragOffset > 0) {
        _handleSwipe('right');
      } else {
        _handleSwipe('left');
      }
    } else {
      // Return to center exactly like HTML
      setState(() {
        _isUserSwiping = false;
      });
      
      // Animate back to center with HTML easing
      final controller = AnimationController(
        duration: const Duration(milliseconds: 220),
        vsync: this,
      );
      
      final animation = Tween<double>(begin: 1.0, end: 0.0)
          .animate(CurvedAnimation(
            parent: controller,
            curve: const Cubic(0.2, 0.9, 0.2, 1), // HTML cubic-bezier
          ));
      
      animation.addListener(() {
        if (mounted) {
          setState(() {
            _dragOffset = _dragOffset * animation.value;
            _dragRotation = _dragRotation * animation.value;
            
            // Fade out trails
            for (int i = 0; i < _trailOpacities.length; i++) {
              _trailOffsets[i] = Offset(_trailOffsets[i].dx * animation.value, _trailOffsets[i].dy * animation.value);
              _trailOpacities[i] = (_trailOpacities[i] * animation.value).clamp(0.0, 1.0);
            }
          });
        }
      });
      
      controller.forward().then((_) {
        controller.dispose();
        if (mounted) {
          setState(() {
            _dragOffset = 0.0;
            _dragRotation = 0.0;
            for (int i = 0; i < _trailOpacities.length; i++) {
              _trailOffsets[i] = Offset.zero;
              _trailOpacities[i] = 0.0;
            }
          });
        }
      });
    }
  }
}

class _ContinuousBouncingWidget extends StatefulWidget {
  final Widget child;
  
  const _ContinuousBouncingWidget({required this.child});

  @override
  State<_ContinuousBouncingWidget> createState() => _ContinuousBouncingWidgetState();
}

class _ContinuousBouncingWidgetState extends State<_ContinuousBouncingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 無限ループ開始
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, _floatAnimation.value * 0.3),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}