import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/player_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/efootball_ui.dart';
import '../../../widgets/team_badge.dart';
import '../../players/add_edit_player_screen.dart';
import '../wizard_state.dart';

class Step3Players extends StatefulWidget {
  const Step3Players({super.key});

  @override
  State<Step3Players> createState() => _Step3PlayersState();
}

class _Step3PlayersState extends State<Step3Players> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadPlayers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = context.watch<WizardState>();
    final playerProvider = context.watch<PlayerProvider>();
    final required = wizardState.requiredTeamCount;

    final filtered = playerProvider.players
        .where((p) => p.name.contains(_searchController.text.trim()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddEditPlayerScreen()),
                  );
                  if (!context.mounted) return;
                  context.read<PlayerProvider>().loadPlayers();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.electricBlue.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.electricBlueLight),
                  ),
                  child: const Icon(Icons.person_add_alt_1, color: AppColors.electricBlueLight, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'تم اختيار ',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    children: [
                      TextSpan(
                        text: required != null
                            ? '${wizardState.selectedPlayers.length} / $required'
                            : '${wizardState.selectedPlayers.length}',
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const TextSpan(text: ' لاعبًا'),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        if (required != null && wizardState.selectedPlayers.length < required)
          _ShortagePlayersBanner(selectedCount: wizardState.selectedPlayers.length, required: required),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'ابحث عن لاعب...',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: playerProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : filtered.isEmpty
                  ? const Center(
                      child: Text('لا يوجد لاعبون — أضف لاعبًا أولاً', style: TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final player = filtered[index];
                        final selected = wizardState.isPlayerSelected(player);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlowCard(
                            selected: selected,
                            onTap: () => wizardState.togglePlayer(player),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: selected,
                                  activeColor: AppColors.gold,
                                  onChanged: (_) => wizardState.togglePlayer(player),
                                ),
                                TeamBadge(
                                  name: player.name,
                                  colorHex: player.colorHex,
                                  photoPath: player.photoPath,
                                  assetPath: player.logoAssetPath,
                                  size: 40,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
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

/// رسالة الفصل 3.8: "عدد اللاعبين أقل من عدد الفرق الحقيقي"
class _ShortagePlayersBanner extends StatelessWidget {
  final int selectedCount;
  final int required;
  const _ShortagePlayersBanner({required this.selectedCount, required this.required});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'عدد اللاعبين ($selectedCount) أقل من عدد الفرق ($required). '
              'سيتحكم بعض اللاعبين بأكثر من فريق تلقائيًا في خطوة توزيع الفرق، '
              'أو يمكنك إضافة لاعبين آخرين الآن.',
              style: const TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
