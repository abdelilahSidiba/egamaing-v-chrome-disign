import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/rule_template_repository.dart';
import '../../../models/enums.dart';
import '../../../models/tournament.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/efootball_ui.dart';
import '../wizard_state.dart';

String _tiebreakLabel(TiebreakCriteria c) {
  switch (c) {
    case TiebreakCriteria.points:
      return 'النقاط';
    case TiebreakCriteria.headToHead:
      return 'المواجهات المباشرة';
    case TiebreakCriteria.goalDifference:
      return 'فارق الأهداف';
    case TiebreakCriteria.goalsFor:
      return 'الأهداف المسجلة';
    case TiebreakCriteria.goalsAgainstFewest:
      return 'أقل أهداف مستقبلة';
    case TiebreakCriteria.draw:
      return 'القرعة';
  }
}

IconData _tiebreakIcon(TiebreakCriteria c) {
  switch (c) {
    case TiebreakCriteria.points:
      return Icons.emoji_events_outlined;
    case TiebreakCriteria.headToHead:
      return Icons.compare_arrows;
    case TiebreakCriteria.goalDifference:
      return Icons.track_changes_outlined;
    case TiebreakCriteria.goalsFor:
      return Icons.sports_soccer;
    case TiebreakCriteria.goalsAgainstFewest:
      return Icons.shield_outlined;
    case TiebreakCriteria.draw:
      return Icons.groups_outlined;
  }
}

String _knockoutRuleLabel(KnockoutTiebreakRule r) {
  switch (r) {
    case KnockoutTiebreakRule.directPenalties:
      return 'مباشرة إلى ركلات الترجيح';
    case KnockoutTiebreakRule.extraTimeThenPenalties:
      return 'أشواط إضافية ثم ركلات ترجيح';
    case KnockoutTiebreakRule.replayMatch:
      return 'إعادة المباراة';
  }
}

class Step5Rules extends StatelessWidget {
  const Step5Rules({super.key});

  bool _hasKnockoutStage(TournamentFormat? format) =>
      format == TournamentFormat.cup ||
      format == TournamentFormat.groupsThenKnockout ||
      format == TournamentFormat.swissThenKnockout;

  bool _hasGroups(TournamentFormat? format) =>
      format == TournamentFormat.groupsThenKnockout ||
      format == TournamentFormat.swissThenKnockout;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WizardState>();
    final format = state.selectedType == null ? null : Tournament.formatFor(state.selectedType!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _RulesLevelBanner(level: state.rulesLevel),
        const SizedBox(height: 20),

        const _SectionHeader('⚽ نظام النقاط'),
        _PointsRow(
          icon: Icons.sports_soccer,
          label: 'الفوز',
          value: state.rules.pointsForWin,
          onChanged: (v) => state.updateRules(state.rules.copyWith(pointsForWin: v)),
        ),
        _PointsRow(
          icon: Icons.handshake_outlined,
          label: 'التعادل',
          value: state.rules.pointsForDraw,
          onChanged: (v) => state.updateRules(state.rules.copyWith(pointsForDraw: v)),
        ),
        _PointsRow(
          icon: Icons.close,
          label: 'الخسارة',
          value: state.rules.pointsForLoss,
          onChanged: (v) => state.updateRules(state.rules.copyWith(pointsForLoss: v)),
        ),

        const SizedBox(height: 22),
        const _SectionHeader('🔄 ترتيب كسر التعادل (اسحب لإعادة الترتيب)'),
        _TiebreakReorderList(state: state),

        const SizedBox(height: 18),
        GlowCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('ذهاب وإياب', style: TextStyle(color: Colors.white)),
            subtitle: const Text('إنشاء مباراة ثانية لكل مواجهة', style: TextStyle(color: AppColors.textMuted)),
            value: state.rules.homeAndAway,
            activeThumbColor: AppColors.gold,
            onChanged: (v) => state.updateRules(state.rules.copyWith(homeAndAway: v)),
          ),
        ),

        if (_hasGroups(format)) ...[
          const SizedBox(height: 18),
          const _SectionHeader('عدد المتأهلين من كل مجموعة'),
          GlowCard(
            child: Row(
              children: [
                const Expanded(child: Text('عدد المتأهلين', style: TextStyle(color: Colors.white))),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.electricBlueLight),
                  onPressed: state.rules.qualifiersPerGroup > 1
                      ? () => state.updateRules(
                          state.rules.copyWith(qualifiersPerGroup: state.rules.qualifiersPerGroup - 1))
                      : null,
                ),
                Text('${state.rules.qualifiersPerGroup}',
                    style: const TextStyle(fontSize: 16, color: AppColors.gold, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.electricBlueLight),
                  onPressed: () => state.updateRules(
                      state.rules.copyWith(qualifiersPerGroup: state.rules.qualifiersPerGroup + 1)),
                ),
              ],
            ),
          ),
        ],

        if (_hasKnockoutStage(format)) ...[
          const SizedBox(height: 18),
          const _SectionHeader('🏆 نظام خروج المغلوب عند التعادل'),
          GlowCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: KnockoutTiebreakRule.values.map((rule) {
                final selected = state.rules.knockoutTiebreak == rule;
                return ListTile(
                  onTap: () => state.updateRules(state.rules.copyWith(knockoutTiebreak: rule)),
                  leading: Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: selected ? AppColors.gold : AppColors.textMuted,
                  ),
                  title: Text(_knockoutRuleLabel(rule), style: const TextStyle(color: Colors.white, fontSize: 13.5)),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 24),
        OutlineBlueButton(label: '💾 حفظ كقالب', onPressed: () => _saveAsTemplate(context, state)),
      ],
    );
  }

  Future<void> _saveAsTemplate(BuildContext context, WizardState state) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حفظ القوانين كقالب'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'مثلاً: بطولة المقهى'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await RuleTemplateRepository().save(name, state.rules);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ القالب "$name"')));
      }
    }
  }
}

class _RulesLevelBanner extends StatelessWidget {
  final RulesLevel level;
  const _RulesLevelBanner({required this.level});

  @override
  Widget build(BuildContext context) {
    late String emoji;
    late String label;
    late Color color;
    switch (level) {
      case RulesLevel.official:
        emoji = '🟢';
        label = 'رسمي 100%';
        color = AppColors.success;
        break;
      case RulesLevel.modified:
        emoji = '🟡';
        label = 'معدل';
        color = AppColors.warning;
        break;
      case RulesLevel.fullyCustom:
        emoji = '🔴';
        label = 'مخصص بالكامل';
        color = AppColors.danger;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2)),
            alignment: Alignment.center,
            child: Icon(Icons.shield, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('مستوى القوانين: $label $emoji',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Icon(Icons.check_circle, color: color, size: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white)),
    );
  }
}

class _PointsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _PointsRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: AppColors.electricBlueLight, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.electricBlueLight),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 26,
              child: Text('$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.electricBlueLight),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TiebreakReorderList extends StatelessWidget {
  final WizardState state;
  const _TiebreakReorderList({required this.state});

  @override
  Widget build(BuildContext context) {
    final order = state.rules.tiebreakOrder;
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.length,
      // ملاحظة: onReorder ما زال يعمل بشكل صحيح؛ البديل الأحدث onReorderItem
      // متوفر فقط في إصدارات Flutter المستقبلية جدًا وقد لا يكون مستقرًا بعد.
      // ignore: deprecated_member_use
      onReorder: (oldIndex, newIndex) {
        final newOrder = List<TiebreakCriteria>.from(order);
        if (newIndex > oldIndex) newIndex -= 1;
        final item = newOrder.removeAt(oldIndex);
        newOrder.insert(newIndex, item);
        state.updateRules(state.rules.copyWith(tiebreakOrder: newOrder));
      },
      itemBuilder: (context, index) {
        final criteria = order[index];
        return Padding(
          key: ValueKey(criteria),
          padding: const EdgeInsets.only(bottom: 8),
          child: GlowCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.electricBlue.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.electricBlueLight),
                  ),
                  alignment: Alignment.center,
                  child: Text('${index + 1}',
                      style: const TextStyle(fontSize: 12, color: AppColors.electricBlueLight, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Icon(_tiebreakIcon(criteria), color: AppColors.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(_tiebreakLabel(criteria), style: const TextStyle(color: Colors.white, fontSize: 13.5))),
                const Icon(Icons.drag_handle, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}
