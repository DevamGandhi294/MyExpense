import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/app/theme/app_colors.dart';

/// Central toast helper using Flutter Overlay — never interferes with navigation.
///
/// Usage:
///   AppToast.success('Expense saved successfully.');
///   AppToast.error('Save failed', 'Something went wrong.');
///   AppToast.warning('Missing title', 'Please enter what you spent on.');
abstract class AppToast {
  static OverlayEntry? _current;

  // ── private core ──────────────────────────────────────────────────────────
  static void _show({
    required String title,
    required String message,
    required Color background,
    required IconData iconData,
    Duration duration = const Duration(seconds: 3),
    bool fromTop = false,
  }) {
    // Remove any existing toast
    _current?.remove();
    _current = null;

    // Use the root navigator overlay — always available after app starts
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        title: title,
        message: message,
        background: background,
        iconData: iconData,
        fromTop: fromTop,
        duration: duration,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  // ── public API ────────────────────────────────────────────────────────────

  /// Green toast — action succeeded.
  static void success(String title, [String message = '']) => _show(
        title: title,
        message: message,
        background: const Color(0xFF0E9F6E),
        iconData: Icons.check_circle_rounded,
      );

  /// Red toast — something went wrong.
  static void error(String title, [String message = '']) => _show(
        title: title,
        message: message,
        background: AppColors.error,
        iconData: Icons.error_rounded,
      );

  /// Amber toast — validation / warning.
  static void warning(String title, [String message = '']) => _show(
        title: title,
        message: message,
        background: const Color(0xFFF59E0B),
        iconData: Icons.warning_rounded,
      );

  /// Blue toast — neutral information.
  static void info(String title, [String message = '']) => _show(
        title: title,
        message: message,
        background: AppColors.info,
        iconData: Icons.info_rounded,
        fromTop: true,
      );
}

// ── Internal animated overlay widget ─────────────────────────────────────────
class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.title,
    required this.message,
    required this.background,
    required this.iconData,
    required this.fromTop,
    required this.duration,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final Color background;
  final IconData iconData;
  final bool fromTop;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slide = Tween<double>(begin: widget.fromTop ? -1 : 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPad = mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: widget.fromTop ? null : bottomPad + 24,
      top: widget.fromTop ? mediaQuery.padding.top + 12 : null,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, _slide.value),
              end: Offset.zero,
            ).animate(_ctrl),
            child: child,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.background.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon bubble
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(widget.iconData, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (widget.message.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
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
