import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../test_engine/domain/question_model.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';

class AddQuestionDialog extends StatefulWidget {
  final String categoryId;
  final String levelId;
  final QuestionModel? questionToEdit;

  const AddQuestionDialog({
    super.key,
    required this.categoryId,
    required this.levelId,
    this.questionToEdit,
  });

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  late TeacherBloc _teacherBloc;
  
  QuestionType _selectedType = QuestionType.qcm;
  final _orderController = TextEditingController();

  // QCM controllers
  final _questionTextController = TextEditingController();
  final List<TextEditingController> _optionsControllers = [
    TextEditingController(text: 'خيار ١'),
    TextEditingController(text: 'خيار ٢'),
  ];
  int _correctOptionIndex = 0;

  // Fill in the blank state
  final _sentenceController = TextEditingController();
  List<String> _words = [];
  int? _selectedWordIndex;
  String? _fillBlankError;

  @override
  void initState() {
    super.initState();
    _teacherBloc = context.read<TeacherBloc>();
    
    if (widget.questionToEdit != null) {
      final q = widget.questionToEdit!;
      _selectedType = q.type;
      _orderController.text = q.order.toString();
      
      if (q.type == QuestionType.qcm) {
        _questionTextController.text = q.question;
        _correctOptionIndex = q.correctIndex;
        _optionsControllers.clear();
        for (var option in q.options) {
          _optionsControllers.add(TextEditingController(text: option));
        }
      } else {
        // Restore fill blank
        final originalSentence = q.sentence.replaceFirst('___', q.answer);
        _sentenceController.text = originalSentence;
        _words = originalSentence.split(RegExp(r'\s+'));
        _selectedWordIndex = q.wordIndex;
      }
    }
    
    _sentenceController.addListener(_onSentenceChanged);
  }

  @override
  void dispose() {
    _orderController.dispose();
    _questionTextController.dispose();
    for (var controller in _optionsControllers) {
      controller.dispose();
    }
    _sentenceController.removeListener(_onSentenceChanged);
    _sentenceController.dispose();
    super.dispose();
  }

  void _onSentenceChanged() {
    final text = _sentenceController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _words = [];
        _selectedWordIndex = null;
      } else {
        _words = text.split(RegExp(r'\s+'));
        // Reset selection if it's out of bounds
        if (_selectedWordIndex != null && _selectedWordIndex! >= _words.length) {
          _selectedWordIndex = null;
        }
      }
      _fillBlankError = null;
    });
  }

  void _addOption() {
    setState(() {
      _optionsControllers.add(TextEditingController(text: 'خيار ${_optionsControllers.length + 1}'));
    });
  }

  void _removeOption(int index) {
    if (_optionsControllers.length <= 2) return;
    setState(() {
      _optionsControllers[index].dispose();
      _optionsControllers.removeAt(index);
      if (_correctOptionIndex >= _optionsControllers.length) {
        _correctOptionIndex = _optionsControllers.length - 1;
      }
    });
  }

  void _submit() {
    final order = int.tryParse(_orderController.text.trim()) ?? 0;
    
    QuestionModel question;
    if (_selectedType == QuestionType.qcm) {
      question = QuestionModel(
        id: widget.questionToEdit?.id ?? '',
        levelId: widget.levelId,
        type: QuestionType.qcm,
        question: _questionTextController.text.trim(),
        options: _optionsControllers.map((c) => c.text.trim()).toList(),
        correctIndex: _correctOptionIndex,
        order: order,
      );
    } else {
      // Validate fill-in-the-blank
      if (_words.isEmpty) {
        setState(() => _fillBlankError = 'يرجى كتابة الجملة أولاً');
        return;
      }
      if (_selectedWordIndex == null) {
        setState(() => _fillBlankError = 'يرجى تحديد الكلمة المخفية');
        return;
      }

      final answer = _words[_selectedWordIndex!];
      final sentenceWithBlank = List<String>.from(_words);
      sentenceWithBlank[_selectedWordIndex!] = '___';
      final sentenceStr = sentenceWithBlank.join(' ');

      question = QuestionModel(
        id: widget.questionToEdit?.id ?? '',
        levelId: widget.levelId,
        type: QuestionType.fillBlank,
        question: 'أكمل الفراغ',
        sentence: sentenceStr,
        answer: answer,
        wordIndex: _selectedWordIndex!,
        order: order,
      );
    }

    if (widget.questionToEdit != null) {
      _teacherBloc.add(UpdateQuestion(widget.categoryId, question));
    } else {
      _teacherBloc.add(AddQuestion(widget.categoryId, question));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.questionToEdit != null ? 'تعديل السؤال' : 'إضافة سؤال جديد'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<QuestionType>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'نوع السؤال'),
                      items: const [
                        DropdownMenuItem(
                          value: QuestionType.qcm,
                          child: Text('اختيار من متعدد'),
                        ),
                        DropdownMenuItem(
                          value: QuestionType.fillBlank,
                          child: Text('أكمل الفراغ'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _orderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الترتيب (مثال: 1)'),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              if (_selectedType == QuestionType.qcm) ..._buildQCMFields(),
              if (_selectedType == QuestionType.fillBlank) ..._buildFillBlankFields(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.questionToEdit != null ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }

  List<Widget> _buildQCMFields() {
    return [
      TextField(
        controller: _questionTextController,
        decoration: const InputDecoration(labelText: 'نص السؤال'),
        maxLines: 2,
      ),
      const SizedBox(height: 16),
      const Text('الخيارات:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...List.generate(_optionsControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Radio<int>(
                value: index,
                groupValue: _correctOptionIndex,
                activeColor: AppColors.primaryBrown,
                onChanged: (val) {
                  if (val != null) setState(() => _correctOptionIndex = val);
                },
              ),
              Expanded(
                child: TextField(
                  controller: _optionsControllers[index],
                  decoration: InputDecoration(
                    labelText: 'خيار ${index + 1}',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              if (_optionsControllers.length > 2)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => _removeOption(index),
                ),
            ],
          ),
        );
      }),
      TextButton.icon(
        onPressed: _addOption,
        icon: const Icon(Icons.add),
        label: const Text('إضافة خيار'),
      ),
    ];
  }

  List<Widget> _buildFillBlankFields() {
    return [
      // Step 1: Sentence input
      TextField(
        controller: _sentenceController,
        decoration: const InputDecoration(
          labelText: 'اكتب الجملة الكاملة',
          hintText: 'مثال: الصلاة هي الركن الثاني من أركان الإسلام',
        ),
        maxLines: 2,
        textDirection: TextDirection.rtl,
      ),
      const SizedBox(height: 20),

      // Step 2: Word chips
      if (_words.isNotEmpty) ...[
        const Text('اضغط على الكلمة التي تريد إخفاءها:', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_words.length, (index) {
              final isSelected = _selectedWordIndex == index;
              return ChoiceChip(
                label: Text(
                  _words[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primaryBrown,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryBrown,
                backgroundColor: AppColors.beige,
                onSelected: (_) {
                  setState(() {
                    _selectedWordIndex = isSelected ? null : index;
                    _fillBlankError = null;
                  });
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 20),

        // Step 4: Live preview
        if (_selectedWordIndex != null) ...[
          const Text('معاينة ما سيراه الطالب:', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBrown)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.beige.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBrown.withOpacity(0.3)),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 8,
                children: List.generate(_words.length, (index) {
                  if (index == _selectedWordIndex) {
                    return Container(
                      constraints: const BoxConstraints(minWidth: 80),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primaryBrown, width: 2),
                        ),
                      ),
                      child: const Text(
                        '       ',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Text(
                    _words[index],
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  );
                }),
              ),
            ),
          ),
        ],
      ],

      // Error message
      if (_fillBlankError != null) ...[
        const SizedBox(height: 12),
        Text(
          _fillBlankError!,
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      ],
    ];
  }
}
