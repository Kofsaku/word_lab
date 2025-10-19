import 'package:flutter/material.dart';

class RecognitionCandidates extends StatelessWidget {
  final List<String> candidates;
  final Function(String) onCandidateSelected;
  final String? selectedText;

  const RecognitionCandidates({
    super.key,
    required this.candidates,
    required this.onCandidateSelected,
    this.selectedText,
  });

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '認識候補（タップで選択）',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: candidates.asMap().entries.map((entry) {
              final index = entry.key;
              final candidate = entry.value;
              final isSelected = selectedText == candidate;
              final confidence = _getConfidenceLevel(index);
              
              return GestureDetector(
                onTap: () => onCandidateSelected(candidate),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.blue.shade100 
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.blue.shade400 
                          : confidence.color,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        candidate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.blue.shade700 
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: confidence.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLegendItem('高確度', Colors.green),
              const SizedBox(width: 12),
              _buildLegendItem('中確度', Colors.orange),
              const SizedBox(width: 12),
              _buildLegendItem('低確度', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  ConfidenceLevel _getConfidenceLevel(int index) {
    switch (index) {
      case 0:
        return ConfidenceLevel(color: Colors.green, level: 'high');
      case 1:
        return ConfidenceLevel(color: Colors.orange, level: 'medium');
      default:
        return ConfidenceLevel(color: Colors.red, level: 'low');
    }
  }
}

class ConfidenceLevel {
  final Color color;
  final String level;

  ConfidenceLevel({required this.color, required this.level});
}