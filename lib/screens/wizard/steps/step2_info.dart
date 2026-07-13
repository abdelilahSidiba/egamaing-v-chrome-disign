import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/efootball_ui.dart';
import '../../../widgets/team_badge.dart';
import '../wizard_state.dart';

class Step2Info extends StatefulWidget {
  const Step2Info({super.key});

  @override
  State<Step2Info> createState() => _Step2InfoState();
}

class _Step2InfoState extends State<Step2Info> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final state = context.read<WizardState>();
    _nameController = TextEditingController(text: state.name);
    _notesController = TextEditingController(text: state.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final state = context.read<WizardState>();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.tournamentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) state.updateInfo(date: picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WizardState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
              boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 16)],
            ),
            child: TeamBadge(
              name: state.name.isEmpty ? '?' : state.name,
              colorHex: state.primaryColorHex,
              size: 90,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _FieldLabel('اسم البطولة *'),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.emoji_events, color: AppColors.gold)),
          onChanged: (v) => context.read<WizardState>().updateInfo(name: v),
        ),
        const SizedBox(height: 16),
        GlowCard(
          onTap: _pickDate,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.electricBlueLight, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.tournamentDate == null
                      ? 'تاريخ البطولة (اختياري)'
                      : DateFormat('yyyy/MM/dd').format(state.tournamentDate!),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Icon(Icons.edit_calendar_outlined, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FieldLabel('ملاحظات البطولة (اختياري)'),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'مثلاً: نهائي البطولة يوم الجمعة',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
          onChanged: (v) => context.read<WizardState>().updateInfo(notes: v),
        ),
        const SizedBox(height: 20),
        _ColorPicker(state: state),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: 4),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final WizardState state;
  const _ColorPicker({required this.state});

  static const _palette = [
    '#1E5FFF', '#E74C3C', '#2ECC71', '#FFC400',
    '#7C3AED', '#0A1F44', '#FF2E93', '#00B4D8',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.palette_outlined, color: AppColors.textMuted, size: 16),
            SizedBox(width: 6),
            Text('لون البطولة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          children: _palette.map((hex) {
            final color = _hexToColor(hex);
            final isSelected = state.primaryColorHex == hex;
            return GestureDetector(
              onTap: () {
                state.primaryColorHex = hex;
                state.updateInfo();
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(width: 3, color: Colors.white) : null,
                  boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 10)] : null,
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _hexToColor(String hex) {
    var cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    return Color(int.parse(cleaned, radix: 16));
  }
}
