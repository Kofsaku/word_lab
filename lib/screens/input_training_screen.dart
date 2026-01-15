import 'dart:async';
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
  bool _isSwipeDetected = false;
  String _swipeDirection = '';
  bool _isUserSwiping = false;
  double _dragOffset = 0.0;
  double _dragRotation = 0.0;
  
  // Ghost trail effects
  List<double> _trailOpacities = [0.0, 0.0, 0.0];
  List<Offset> _trailOffsets = [Offset.zero, Offset.zero, Offset.zero];
  static const double _swipeThreshold = 96.0;
  
  // Stacked cards with types  
  List<Map<String, dynamic>> stackedCards = [];
  
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _stackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _characterAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _cardAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));

    _stackAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stackAnimationController,
      curve: Curves.elasticOut,
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
        _playCurrentWordAudio();
      }
    } catch (e) {
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

  void _handleSwipe(String direction) {
    if (_isSwipeDetected || currentIndex >= words.length) return;
    
    setState(() {
      _isSwipeDetected = true;
      _swipeDirection = direction;
    });

    final word = words[currentIndex];
    
    _cardAnimationController.forward().then((_) {
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

  void _moveToNextWord() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          currentIndex++;
          _isSwipeDetected = false;
          _swipeDirection = '';
          _isUserSwiping = false;
          _dragOffset = 0.0;
          _dragRotation = 0.0;
          // Reset trails
          for (int i = 0; i < _trailOpacities.length; i++) {
            _trailOffsets[i] = Offset.zero;
            _trailOpacities[i] = 0.0;
          }
        });
        
        _cardAnimationController.reset();
        
        if (currentIndex < words.length) {
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
        actionsAlignment: MainAxisAlignment.center,
        actions: [
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
      // Include all words that need review (from stackedCards)
      final reviewOnlyWords = stackedCards
          .where((card) => card['type'] == 'review')
          .map((card) => card['word'] as Word)
          .toList();
      
      words = reviewOnlyWords.isNotEmpty ? reviewOnlyWords : List.from(reviewWords);
      reviewWords.clear();
      stackedCards.clear(); // Reset for new round
      memorizedWords.clear(); // Reset memorized words
      currentIndex = 0;
      _showMeaning = false;
      _isUserSwiping = false;
      _dragOffset = 0.0;
      _dragRotation = 0.0;
      // Reset trails
      for (int i = 0; i < _trailOpacities.length; i++) {
        _trailOffsets[i] = Offset.zero;
        _trailOpacities[i] = 0.0;
      }
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
    return Column(
      children: [
        // 説明テキスト
        _buildInstructionText(),
        
        const SizedBox(height: 10),
        
        // キャラクターとカードスタック（横並び）
        _buildCharacterAndStackRow(),
        
        const SizedBox(height: 20),
        
        // 例文表示（カード本体）
        Expanded(child: _buildExampleSection()),
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
                              color: const Color(0xFFE1F5FE), // 爽やかな水色
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFB3E5FC),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              words[currentIndex].partOfSpeech,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0288D1), // 鮮やかな青
                                fontWeight: FontWeight.bold,
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

  Widget _buildCardStack() {
    return SizedBox(
      width: 120,
      height: 160, // 220 -> 160
      child: Stack(
        children: List.generate(
          6, // Show all 6 possible card positions
          (index) {
            final hasCard = index < stackedCards.length;
            final cardData = hasCard ? stackedCards[index] : null;
            final isLatest = hasCard && index == stackedCards.length - 1;
            
            return Positioned(
              bottom: index * 24.0, // 32.0 -> 24.0
              right: 0,
              child: AnimatedBuilder(
                animation: _stackAnimationController,
                builder: (context, child) {
                  if (hasCard) {
                    final word = cardData!['word'] as Word;
                    final type = cardData['type'] as String;
                    final cardColor = type == 'confident' 
                        ? const Color(0xFF60A5FA) // Blue
                        : const Color(0xFFF87171); // Red
                    
                    // Pop-stack animation for latest card
                    if (isLatest && _stackAnimationController.isAnimating) {
                      final t = _stackAnimationController.value;
                      
                      double scale, translateY, opacity;
                      if (t <= 0.7) {
                        final phase1 = t / 0.7;
                        opacity = phase1;
                        translateY = 30 * (1 - phase1) + (-6 * phase1);
                        scale = 0.92 + (1.02 - 0.92) * phase1;
                      } else {
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
                            child: _buildStackCard(word, cardColor),
                          ),
                        ),
                      );
                    }
                    
                    return _buildStackCard(word, cardColor);
                  } else {
                    // Empty placeholder
                    return _buildStackCard(null, Colors.black87);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildStackCard(Word? word, Color cardColor) {
    return Container(
      width: 70, // Smaller size to fit all 6 cards
      height: 28,  // Smaller height
      decoration: BoxDecoration(
        color: word != null ? Colors.white : Colors.transparent, // 背景色は白のまま
        borderRadius: BorderRadius.circular(8),
        border: word != null ? Border.all(
          color: cardColor,
          width: 2,
        ) : null,
        boxShadow: word != null ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: word != null ? Center(
        child: Text(
          word.english,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cardColor,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // キャラクター（左側）
          _buildCharacterAnimation(),
          
          // カードスタック（右側）
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
        const SizedBox(height: 10), // 20 -> 10
        AnimatedOpacity(
          opacity: _showMeaning ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              Text(
                words[currentIndex].japanese,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE), // 爽やかな水色
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB3E5FC),
                    width: 1,
                  ),
                ),
                child: Text(
                  words[currentIndex].partOfSpeech,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0288D1), // 鮮やかな青
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
          // Ghost trails (behind main card) - HTML style
          ...List.generate(3, (index) => 
            Opacity(
              opacity: _trailOpacities[index],
              child: Transform.translate(
                offset: _trailOffsets[index],
                child: Container(
                  width: 300,
                  height: 150, // 180 -> 150
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white, // HTML var(--card)
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18), // HTML shadow
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Main card
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: Container(
            width: 300,
            height: 150, // 180 -> 150
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
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _dragOffset < -20 
                              ? AppColors.incorrect 
                              : AppColors.incorrect.withOpacity(0.3),
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
                      // 右スワイプインジケーター
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _dragOffset > 20 
                              ? AppColors.correct 
                              : AppColors.correct.withOpacity(0.3),
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
          ), // Transform.translate close
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
        // シンプルに 'idle' アニメーションのみを再生リストに指定
        animations: const ['idle'],
        fit: BoxFit.contain,
        // コントローラーによる制御を削除し、純粋なアニメーション再生のみにする
      ),
    );
  }

  void _analyzeAndControlRive(Artboard artboard) {
    // シンプル再生に変更したため、複雑な解析・制御ロジックは無効化
    print('Simple animation mode: Playing "idle"');
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
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
      child: Column(
        children: [
          const Text(
            'カードを左右にスワイプしてください',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54, // 少し薄くして控えめに
            ),
          ),
          const SizedBox(height: 12),
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
    if (_isSwipeDetected) return;

    setState(() {
      final dx = details.localPosition.dx - 150; // Card center
      final dy = details.localPosition.dy - 90; // Card vertical center
      
      _dragOffset = dx;
      _dragRotation = 0.0; // No rotation - horizontal only
      
      // Update ghost trails exactly like HTML
      final th = _swipeThreshold;
      final amt = (_dragOffset.abs() / th).clamp(0.0, 1.0);
      
      for (int i = 0; i < _trailOpacities.length; i++) {
        final lag = (i + 1) * 0.18; // 18% of movement per layer
        _trailOffsets[i] = Offset(_dragOffset * (1 - lag), dy * (1 - lag));
        _trailOpacities[i] = ((0.18 + amt * 0.4) * (1 - i * 0.28)).clamp(0.0, 1.0);
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSwipeDetected) return;

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
      // Return to center like HTML
      setState(() {
        _isUserSwiping = false;
        _dragOffset = 0.0;
        _dragRotation = 0.0;
        // Reset trails
        for (int i = 0; i < _trailOpacities.length; i++) {
          _trailOffsets[i] = Offset.zero;
          _trailOpacities[i] = 0.0;
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
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
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