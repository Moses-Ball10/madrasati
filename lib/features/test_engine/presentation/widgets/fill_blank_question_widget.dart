import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/question_model.dart';
import '../bloc/test_state.dart';

class FillBlankQuestionWidget extends StatefulWidget {
  final QuestionModel question;
  final TestState state;
  final ValueChanged<String> onSelect;

  const FillBlankQuestionWidget({
    super.key,
    required this.question,
    required this.state,
    required this.onSelect,
  });

  @override
  State<FillBlankQuestionWidget> createState() => _FillBlankQuestionWidgetState();
}

class _FillBlankQuestionWidgetState extends State<FillBlankQuestionWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _updateControllerFromState();
  }

  @override
  void didUpdateWidget(FillBlankQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question.id != oldWidget.question.id) {
      _controller.clear();
    } else {
      _updateControllerFromState();
    }
  }

  void _updateControllerFromState() {
    if (widget.state is TestInProgress) {
      final answer = (widget.state as TestInProgress).selectedAnswer as String?;
      if (answer != null && _controller.text != answer) {
        _controller.text = answer;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasRevealed = widget.state is TestAnswerRevealed;
    TestAnswerRevealed? revealedState = hasRevealed ? widget.state as TestAnswerRevealed : null;
    
    // Split sentence by '___'
    final parts = widget.question.sentence.split('___');
    final String beforeBlank = parts.isNotEmpty ? parts[0].trim() : '';
    final String afterBlank = parts.length > 1 ? parts[1].trim() : '';

    // Determine input styling based on answer state
    Color inputBorderColor = AppColors.primaryBrown;
    Color inputTextColor = AppColors.primaryBrown;
    
    if (hasRevealed) {
      if (revealedState!.isCorrect) {
        inputBorderColor = const Color(0xFF4CAF50);
        inputTextColor = const Color(0xFF4CAF50);
      } else {
        inputBorderColor = const Color(0xFFEF5350);
        inputTextColor = const Color(0xFFEF5350);
      }
    }

    // Split before and after into words for wrapping
    final beforeWords = beforeBlank.isNotEmpty ? beforeBlank.split(RegExp(r'\s+')) : <String>[];
    final afterWords = afterBlank.isNotEmpty ? afterBlank.split(RegExp(r'\s+')) : <String>[];

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'أكمل الفراغ',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBrown),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'أكمل الجملة التالية بالكلمة المناسبة:',
          style: AppTextStyles.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Inline sentence with blank
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.beigeDark),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 12,
              children: [
                // Before blank words
                ...beforeWords.map((word) => Text(
                  word,
                  style: AppTextStyles.heading2.copyWith(height: 1.8),
                )),
                
                // The blank input field
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 80),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !hasRevealed,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: inputTextColor,
                        fontFamily: 'Cairo',
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: InputBorder.none,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: inputBorderColor, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: inputBorderColor, width: 2),
                        ),
                        disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: inputBorderColor, width: 2),
                        ),
                        filled: hasRevealed,
                        fillColor: hasRevealed
                            ? (revealedState!.isCorrect 
                                ? const Color(0xFFE8F5E9) 
                                : const Color(0xFFFFEBEE))
                            : null,
                      ),
                      onChanged: widget.onSelect,
                    ),
                  ),
                ),
                
                // After blank words
                ...afterWords.map((word) => Text(
                  word,
                  style: AppTextStyles.heading2.copyWith(height: 1.8),
                )),
              ],
            ),
          ),
        ),
        
        // Show correct answer when wrong
        if (hasRevealed && !revealedState!.isCorrect) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'الإجابة الصحيحة: ${widget.question.answer}',
              style: const TextStyle(
                color: Color(0xFFEF5350),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );

    if (hasRevealed && !revealedState!.isCorrect) {
      content = content.animate().shakeX(duration: 400.ms);
    }

    return content;
  }
}
