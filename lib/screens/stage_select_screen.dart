import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/stage.dart';
import '../theme/app_colors.dart';

class StageSelectScreen extends StatelessWidget {
  const StageSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ステージ選択'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                '学習するステージを選んでください',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: DummyData.stages.length,
                itemBuilder: (context, index) {
                  final stage = DummyData.stages[index];
                  return _buildStageCard(context, stage, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageCard(BuildContext context, Stage stage, int index) {
    final isLocked = index > 0 && !DummyData.stages[index - 1].isCleared;
    final wordsInStage = DummyData.getWordsByStageId(stage.id);
    final memorizedCount = wordsInStage.where((w) => w.isMemorized).length;
    final progress = wordsInStage.isNotEmpty 
        ? memorizedCount / wordsInStage.length 
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked 
              ? null 
              : () {
                  Navigator.pushNamed(
                    context,
                    '/input-training',
                    arguments: stage.id,
                  );
                },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isLocked ? AppColors.textSecondary.withOpacity(0.3) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isLocked 
                      ? AppColors.textSecondary.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isLocked 
                            ? AppColors.textSecondary
                            : _getStageColor(stage.level),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Level ${stage.level}',
                        style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isLocked)
                      const Icon(
                        Icons.lock,
                        color: AppColors.textSecondary,
                        size: 24,
                      )
                    else if (stage.isCleared)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.correct,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.textOnPrimary,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  stage.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stage.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLocked ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(
                      Icons.book,
                      size: 16,
                      color: isLocked ? AppColors.textSecondary : AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${wordsInStage.length} 単語',
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked ? AppColors.textSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: isLocked ? AppColors.textSecondary : AppColors.correct,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$memorizedCount 習得済み',
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked ? AppColors.textSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLocked ? AppColors.textSecondary : _getStageColor(stage.level),
                    ),
                  ),
                ),
                if (stage.isCleared && stage.score != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'スコア: ${stage.score!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStageColor(int level) {
    switch (level) {
      case 1:
        return AppColors.accent;
      case 2:
        return AppColors.primary;
      case 3:
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }
}