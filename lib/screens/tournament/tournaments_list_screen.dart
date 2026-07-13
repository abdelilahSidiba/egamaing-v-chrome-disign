import 'package:flutter/material.dart';
import '../../data/tournament_repository.dart';
import '../../models/enums.dart';
import '../../models/tournament.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/efootball_ui.dart';
import '../../widgets/team_badge.dart';
import '../archive/tournament_archive_detail_screen.dart';
import '../wizard/tournament_wizard_screen.dart';
import 'tournament_dashboard_screen.dart';

/// صفحة "البطولات" بتصميم eFootball: عنوان مع كأس ذهبية، تبويبان مؤطران
/// (الجارية / الأرشيف)، وحالة فارغة بكأس متوهجة كبيرة (الفصل 3.2 / 8.2)
class TournamentsListScreen extends StatefulWidget {
  const TournamentsListScreen({super.key});

  @override
  State<TournamentsListScreen> createState() => _TournamentsListScreenState();
}

class _TournamentsListScreenState extends State<TournamentsListScreen> {
  final _repository = TournamentRepository();
  bool _showArchive = false;

  List<Tournament> _activeTournaments = [];
  List<Tournament> _archivedTournaments = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final active = await _repository.getAll();
    final archived = await _repository.getAll(
      status: TournamentStatus.finished,
      searchQuery: _searchController.text,
    );
    setState(() {
      _activeTournaments = active.where((t) => t.status != TournamentStatus.finished).toList();
      _archivedTournaments = archived;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                '🏆 البطولات',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SegmentedTabs(
                showArchive: _showArchive,
                onChanged: (v) => setState(() => _showArchive = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : (_showArchive ? _buildArchiveList() : _buildActiveList()),
            ),
          ],
        ),
      ),
      floatingActionButton: _activeTournaments.isNotEmpty && !_showArchive
          ? FloatingActionButton.extended(
              onPressed: _openWizard,
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black87,
              icon: const Icon(Icons.add),
              label: const Text('إنشاء بطولة', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildActiveList() {
    if (_activeTournaments.isEmpty) return _EmptyTrophyState(onCreate: _openWizard);
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.gold,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 4),
        itemCount: _activeTournaments.length,
        itemBuilder: (context, index) {
          final t = _activeTournaments[index];
          return _TournamentCard(
            tournament: t,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TournamentDashboardScreen(tournamentId: t.id)),
              );
              _load();
            },
          );
        },
      ),
    );
  }

  Widget _buildArchiveList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'ابحث باسم البطولة...',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
            ),
            onChanged: (_) => _load(),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _archivedTournaments.isEmpty
              ? const Center(
                  child: Text('🏛️ لا توجد بطولات منتهية بعد', style: TextStyle(color: AppColors.textMuted)),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.gold,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: _archivedTournaments.length,
                    itemBuilder: (context, index) {
                      final t = _archivedTournaments[index];
                      return _TournamentCard(
                        tournament: t,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TournamentArchiveDetailScreen(tournamentId: t.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _openWizard() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TournamentWizardScreen()),
    );
    _load();
  }
}

/// تبويبان مؤطران (الجارية / الأرشيف) — نفس أسلوب الصورة المرجعية
class _SegmentedTabs extends StatelessWidget {
  final bool showArchive;
  final ValueChanged<bool> onChanged;
  const _SegmentedTabs({required this.showArchive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderBlue),
      ),
      child: Row(
        children: [
          _TabButton(
            label: '🏛️ الأرشيف',
            selected: showArchive,
            onTap: () => onChanged(true),
          ),
          _TabButton(
            label: 'الجارية',
            selected: !showArchive,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: AppColors.gold) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.gold : AppColors.textMuted,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// الحالة الفارغة: كأس متوهجة كبيرة + دعوة لإنشاء أول بطولة (مطابقة للصورة المرجعية)
class _EmptyTrophyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyTrophyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.electricBlue.withValues(alpha: 0.35), Colors.transparent],
                ),
              ),
              child: const Icon(Icons.emoji_events, size: 100, color: AppColors.electricBlueLight),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد بطولات جارية بعد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'أنشئ أول بطولة لك خلال أقل من دقيقة',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: GoldButton(label: 'إنشاء بطولة', icon: Icons.add, onPressed: onCreate),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onTap;
  const _TournamentCard({required this.tournament, required this.onTap});

  String get _statusLabel {
    switch (tournament.status) {
      case TournamentStatus.notStarted:
        return '🟡 لم تبدأ';
      case TournamentStatus.ongoing:
        return '🟢 جارية';
      case TournamentStatus.finished:
        return '🔵 انتهت';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.colorFromHex(tournament.primaryColorHex);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: GlowCard(
        borderColor: color,
        onTap: onTap,
        child: Row(
          children: [
            TeamBadge(name: tournament.name, colorHex: tournament.primaryColorHex, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tournament.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(_statusLabel, style: TextStyle(color: color, fontSize: 12)),
                  if (tournament.totalRounds > 0)
                    Text(
                      '${tournament.currentRound} / ${tournament.totalRounds} جولة',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
