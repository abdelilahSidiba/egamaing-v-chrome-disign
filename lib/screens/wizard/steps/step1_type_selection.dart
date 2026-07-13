import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/enums.dart';
import '../../../models/tournament.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/efootball_ui.dart';
import '../wizard_state.dart';

const _nationTypes = [
  TournamentType.worldCup,
  TournamentType.africaCup,
  TournamentType.europeCup,
  TournamentType.copaAmerica,
];

const _clubTypes = [
  TournamentType.uclOldFormat,
  TournamentType.uclNewFormat,
  TournamentType.laLiga,
  TournamentType.premierLeague,
  TournamentType.serieA,
  TournamentType.bundesliga,
  TournamentType.ligue1,
];

const _customTypes = [
  TournamentType.customLeague,
  TournamentType.customCup,
  TournamentType.customGroupsKnockout,
];

String _typeDescription(TournamentType type) {
  switch (type) {
    case TournamentType.worldCup:
      return 'مجموعات ثم خروج مغلوب — 32 منتخبًا';
    case TournamentType.africaCup:
      return 'مجموعات ثم خروج مغلوب — 24 منتخبًا';
    case TournamentType.europeCup:
      return 'مجموعات ثم خروج مغلوب — 24 منتخبًا';
    case TournamentType.copaAmerica:
      return 'مجموعات ثم خروج مغلوب — 16 منتخبًا';
    case TournamentType.uclOldFormat:
      return 'مجموعات + ذهاب وإياب — 32 ناديًا';
    case TournamentType.uclNewFormat:
      return 'دوري موحد (8 مباريات) + ملحق — 36 ناديًا';
    case TournamentType.laLiga:
      return 'دوري ذهاب وإياب — 20 ناديًا';
    case TournamentType.premierLeague:
      return 'دوري ذهاب وإياب — 20 ناديًا';
    case TournamentType.serieA:
      return 'دوري ذهاب وإياب — 20 ناديًا';
    case TournamentType.bundesliga:
      return 'دوري ذهاب وإياب — 18 ناديًا';
    case TournamentType.ligue1:
      return 'دوري ذهاب وإياب — 18 ناديًا';
    case TournamentType.customLeague:
      return 'دوري بعدد فرق تحدده أنت';
    case TournamentType.customCup:
      return 'خروج مغلوب مباشر بعدد فرق تحدده أنت';
    case TournamentType.customGroupsKnockout:
      return 'مجموعات ثم خروج مغلوب بعدد فرق تحدده أنت';
  }
}

IconData _typeIcon(TournamentType type) {
  switch (type) {
    case TournamentType.worldCup:
    case TournamentType.africaCup:
    case TournamentType.europeCup:
    case TournamentType.copaAmerica:
      return Icons.public;
    case TournamentType.uclOldFormat:
    case TournamentType.uclNewFormat:
      return Icons.stars;
    case TournamentType.customLeague:
    case TournamentType.customCup:
    case TournamentType.customGroupsKnockout:
      return Icons.sports_soccer;
    default:
      return Icons.emoji_events;
  }
}

class Step1TypeSelection extends StatelessWidget {
  const Step1TypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WizardState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _SectionTitle('🌍 بطولات المنتخبات'),
        ..._nationTypes.map((t) => _TypeCard(type: t, selected: state.selectedType == t)),
        const SizedBox(height: 16),
        const _SectionTitle('🏆 بطولات الأندية'),
        ..._clubTypes.map((t) => _TypeCard(type: t, selected: state.selectedType == t)),
        const SizedBox(height: 16),
        const _SectionTitle('⚽ بطولات مخصصة'),
        ..._customTypes.map((t) => _TypeCard(type: t, selected: state.selectedType == t)),
        if (state.isCustomType) ...[
          const SizedBox(height: 12),
          _CustomTeamCountField(state: state),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final TournamentType type;
  final bool selected;
  const _TypeCard({required this.type, required this.selected});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.tournamentAccent[type.name] ?? AppColors.electricBlue;
    final count = Tournament.officialTeamCount(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        borderColor: accent,
        selected: selected,
        onTap: () => context.read<WizardState>().selectType(type),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [accent.withValues(alpha: 0.9), accent.withValues(alpha: 0.4)]),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 10)],
              ),
              child: Icon(_typeIcon(type), color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Tournament.defaultNameFor(type),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(_typeDescription(type), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Column(
                children: [
                  Text('$count', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('فريق', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomTeamCountField extends StatelessWidget {
  final WizardState state;
  const _CustomTeamCountField({required this.state});

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      child: Row(
        children: [
          const Expanded(
            child: Text('عدد الفرق في هذه البطولة:', style: TextStyle(color: Colors.white)),
          ),
          _CounterButton(
            icon: Icons.remove,
            onTap: () {
              final current = state.customTeamCount ?? 4;
              if (current > 2) state.setCustomTeamCount(current - 1);
            },
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${state.customTeamCount ?? 4}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
          ),
          _CounterButton(
            icon: Icons.add,
            onTap: () {
              final current = state.customTeamCount ?? 4;
              state.setCustomTeamCount(current + 1);
            },
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderBlue),
        ),
        child: Icon(icon, size: 18, color: AppColors.electricBlueLight),
      ),
    );
  }
}
