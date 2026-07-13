import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/official_tournament_data.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/efootball_ui.dart';
import '../../../widgets/team_badge.dart';
import '../wizard_state.dart';

class Step4TeamDistribution extends StatefulWidget {
  const Step4TeamDistribution({super.key});

  @override
  State<Step4TeamDistribution> createState() => _Step4TeamDistributionState();
}

class _Step4TeamDistributionState extends State<Step4TeamDistribution> {
  final _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<WizardState>();
      if (state.teamSlots.isEmpty) _draw(state);
    });
  }

  /// يبني قائمة أسماء الفرق المتاحة: من مكتبة التطبيق للبطولات الرسمية،
  /// أو أسماء افتراضية قابلة للتعديل يدويًا للبطولات المخصصة (الفصل 3.5)
  List<OfficialTeamData> _teamPool(WizardState state) {
    if (!state.isCustomType && state.selectedType != null) {
      final officialPool = OfficialTournamentData.teamsFor(state.selectedType!);
      if (officialPool.isNotEmpty) return officialPool;
    }
    final count = state.requiredTeamCount ?? state.selectedPlayers.length;
    return List.generate(count, (i) => OfficialTeamData('فريق ${i + 1}', '#1E5FFF'));
  }

  /// يوزّع عدد فتحات الفرق على اللاعبين بعدالة (الفصل 3.10)
  List<String> _playerIdsPerSlot(WizardState state, int slotCount) {
    final players = state.selectedPlayers;
    final result = <String>[];
    for (int i = 0; i < slotCount; i++) {
      result.add(players[i % players.length].id);
    }
    return result;
  }

  /// إجراء القرعة العشوائية الكاملة (الفصل 3.9)
  void _draw(WizardState state) {
    final pool = List<OfficialTeamData>.from(_teamPool(state))..shuffle(_random);
    final slotCount = state.requiredTeamCount ?? state.selectedPlayers.length;
    final playerIds = _playerIdsPerSlot(state, slotCount)..shuffle(_random);

    final slots = <TeamSlot>[];
    for (int i = 0; i < slotCount; i++) {
      final playerId = playerIds[i];
      final player = state.selectedPlayers.firstWhere((p) => p.id == playerId);
      final teamData = pool[i % pool.length];
      slots.add(TeamSlot(
        playerId: player.id,
        playerName: player.name,
        playerColorHex: player.colorHex,
        teamName: teamData.name,
        teamColorHex: teamData.colorHex,
      ));
    }
    state.setTeamSlots(slots);
  }

  Future<void> _renameSlot(WizardState state, TeamSlot slot) async {
    final controller = TextEditingController(text: slot.teamName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل اسم الفريق'),
        content: TextField(controller: controller, autofocus: true, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      setState(() => slot.teamName = newName);
      state.setTeamSlots(state.teamSlots);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WizardState>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: _PillActionButton(
                  icon: Icons.casino_outlined,
                  label: 'إعادة القرعة',
                  selected: false,
                  onTap: state.drawConfirmed ? null : () => _draw(state),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillActionButton(
                  icon: state.drawConfirmed ? Icons.check_circle : Icons.shield_outlined,
                  label: state.drawConfirmed ? 'تم الاعتماد' : 'اعتماد القرعة',
                  selected: true,
                  onTap: state.drawConfirmed
                      ? null
                      : () {
                          state.confirmDraw();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 اكتملت القرعة!')),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.teamSlots.length} / ${state.teamSlots.length}',
                style: const TextStyle(color: AppColors.electricBlueLight, fontWeight: FontWeight.bold),
              ),
              Text(
                'الفرق الموزّعة (${state.teamSlots.length} فريقًا)',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        if (state.drawConfirmed)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'لا يمكن تعديل الفرق بعد الاعتماد.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: state.teamSlots.length,
            itemBuilder: (context, index) {
              final slot = state.teamSlots[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlowCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator, color: AppColors.textMuted, size: 18),
                      const SizedBox(width: 8),
                      TeamBadge(name: slot.teamName, colorHex: slot.teamColorHex, size: 38),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(slot.playerName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(slot.teamName,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                          ],
                        ),
                      ),
                      if (!state.drawConfirmed)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.electricBlueLight),
                          onPressed: () => _renameSlot(state, slot),
                        )
                      else
                        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PillActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _PillActionButton({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled && !selected ? 0.5 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.electricBlue.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? AppColors.electricBlueLight : AppColors.borderBlue),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.electricBlueLight : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: selected ? AppColors.electricBlueLight : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
