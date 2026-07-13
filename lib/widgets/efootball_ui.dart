import 'package:flutter/material.dart';
import 'app_colors.dart';

/// خلفية الاستاد الداكنة المتوهجة — تُستخدم كخلفية موحّدة لكل شاشات التطبيق
/// (مستوحاة من الفصل 9.2: "خلف البطاقة تصميم مستوحى من البطولة")
class StadiumBackground extends StatelessWidget {
  final Widget child;
  const StadiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          // توهجات ضوئية دائرية خفيفة تحاكي أضواء الاستاد
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(color: AppColors.electricBlue.withValues(alpha: 0.18), size: 260),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _GlowOrb(color: AppColors.gold.withValues(alpha: 0.08), size: 300),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

/// بطاقة "متوهجة" بحدود زرقاء أو ذهبية وظل توهج خفيف — الوحدة البصرية
/// الأساسية المتكررة في كل واجهات eFootball (بطاقات البطولات، اللاعبين...)
class GlowCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;

  const GlowCard({
    super.key,
    required this.child,
    this.borderColor = AppColors.borderBlue,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = selected ? AppColors.gold : borderColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: effectiveBorder, width: selected ? 1.6 : 1),
            boxShadow: [
              BoxShadow(
                color: effectiveBorder.withValues(alpha: selected ? 0.35 : 0.15),
                blurRadius: selected ? 16 : 8,
                spreadRadius: selected ? 1 : 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// زر إجراء ذهبي رئيسي (مثل "إنشاء بطولة"، "التالي"، "حفظ النتيجة")
class GoldButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  const GoldButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.loading = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: AppColors.goldButtonGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: disabled ? null : onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black87),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.black87, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر ثانوي بحدود زرقاء شفافة (مثل "السابق")
class OutlineBlueButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const OutlineBlueButton({super.key, required this.label, required this.onPressed, this.height = 52});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderBlue, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
