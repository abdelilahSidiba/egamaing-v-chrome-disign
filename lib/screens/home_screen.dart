import 'package:flutter/material.dart';
import '../screens/hall_of_fame/hall_of_fame_screen.dart';
import '../screens/players/players_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/tournament/tournaments_list_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/efootball_ui.dart';

/// الشاشة الرئيسية — شريط تنقل سفلي بتصميم eFootball (بطاقات مؤطرة، تمييز ذهبي
/// للقسم النشط) بدل شريط التنقل الافتراضي.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    TournamentsListScreen(),
    PlayersListScreen(),
    HallOfFameScreen(),
    SettingsScreen(),
  ];

  static const _items = [
    (Icons.emoji_events, 'البطولات'),
    (Icons.groups, 'اللاعبون'),
    (Icons.workspace_premium, 'قاعة الشرف'),
    (Icons.settings, 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: StadiumBackground(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderBlue),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final (icon, label) = _items[index];
              final selected = index == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.gold.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.gold : Colors.transparent,
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: selected ? AppColors.gold : AppColors.textMuted, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? AppColors.gold : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
