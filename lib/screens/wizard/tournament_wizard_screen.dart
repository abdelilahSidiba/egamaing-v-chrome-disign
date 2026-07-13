import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/efootball_ui.dart';
import 'wizard_state.dart';
import 'steps/step1_type_selection.dart';
import 'steps/step2_info.dart';
import 'steps/step3_players.dart';
import 'steps/step4_team_distribution.dart';
import 'steps/step5_rules.dart';
import 'steps/step6_review.dart';

const List<String> _stepTitles = [
  'اختيار البطولة',
  'المعلومات',
  'اللاعبون',
  'توزيع الفرق',
  'القوانين',
  'المراجعة',
];

/// معالج إنشاء البطولة بخطواته الست، بتصميم eFootball (الفصل 3.2)
class TournamentWizardScreen extends StatelessWidget {
  const TournamentWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WizardState(),
      child: const _WizardBody(),
    );
  }
}

class _WizardBody extends StatefulWidget {
  const _WizardBody();

  @override
  State<_WizardBody> createState() => _WizardBodyState();
}

class _WizardBodyState extends State<_WizardBody> {
  int _currentStep = 0;
  final _pageController = PageController();

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    final state = context.read<WizardState>();
    if (!state.canProceedFromStep(_currentStep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال هذه الخطوة قبل المتابعة.')),
      );
      return;
    }
    if (_currentStep < _stepTitles.length - 1) _goToStep(_currentStep + 1);
  }

  void _back() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _WizardTopBar(onClose: () => Navigator.of(context).pop()),
            _ProgressHeader(currentStep: _currentStep, onStepTap: _goToStep),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  Step1TypeSelection(),
                  Step2Info(),
                  Step3Players(),
                  Step4TeamDistribution(),
                  Step5Rules(),
                  Step6Review(),
                ],
              ),
            ),
            _NavigationBar(
              currentStep: _currentStep,
              totalSteps: _stepTitles.length,
              onBack: _back,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _WizardTopBar extends StatelessWidget {
  final VoidCallback onClose;
  const _WizardTopBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted),
            onPressed: onClose,
          ),
          const Spacer(),
          const Text(
            'إنشاء بطولة',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.add_circle, color: AppColors.gold, size: 22),
          const Spacer(),
          const SizedBox(width: 40), // موازنة بصرية مع زر الإغلاق
        ],
      ),
    );
  }
}

/// شريط تقدم الخطوات الست — دوائر مرقّمة متصلة بخط (الفصل 3.2)
class _ProgressHeader extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepTap;
  const _ProgressHeader({required this.currentStep, required this.onStepTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WizardState>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlue),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_stepTitles.length, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep && state.canProceedFromStep(index);
            final isLast = index == _stepTitles.length - 1;

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (index <= currentStep) onStepTap(index);
                  },
                  child: Column(
                    children: [
                      _StepCircle(isActive: isActive, isCompleted: isCompleted, number: index + 1),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 62,
                        child: Text(
                          _stepTitles[index],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? AppColors.electricBlueLight
                                : (isCompleted ? AppColors.success : AppColors.textMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 20,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: isCompleted ? AppColors.success : AppColors.borderBlue,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  final int number;
  const _StepCircle({required this.isActive, required this.isCompleted, required this.number});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.electricBlue.withValues(alpha: 0.2) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.electricBlueLight : AppColors.borderBlue,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: AppColors.electricBlue.withValues(alpha: 0.5), blurRadius: 10)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          color: isActive ? AppColors.electricBlueLight : AppColors.textMuted,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavigationBar({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          if (!isLastStep)
            Expanded(
              flex: 2,
              child: GoldButton(label: 'التالي', icon: Icons.arrow_back, onPressed: onNext),
            ),
          if (currentStep > 0) ...[
            const SizedBox(width: 12),
            Expanded(child: OutlineBlueButton(label: 'السابق', onPressed: onBack)),
          ],
        ],
      ),
    );
  }
}
