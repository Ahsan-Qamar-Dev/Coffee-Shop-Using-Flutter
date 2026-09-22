import 'dart:async';

import 'package:flutter/material.dart';

Duration motionDuration(BuildContext context, [int milliseconds = 220]) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

/// A small visual control with a full 48dp touch/keyboard target.
class CompactActionButton extends StatefulWidget {
  const CompactActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = true,
    this.confirmAddition = false,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool filled, confirmAddition;
  @override
  State<CompactActionButton> createState() => _CompactActionButtonState();
}

class _CompactActionButtonState extends State<CompactActionButton> {
  bool _pressed = false, _added = false;
  Timer? _feedback;
  @override
  void dispose() {
    _feedback?.cancel();
    super.dispose();
  }

  void _tap() {
    widget.onPressed();
    if (!widget.confirmAddition || !mounted) return;
    _feedback?.cancel();
    setState(() => _added = true);
    _feedback = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _added = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _tap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: AnimatedScale(
                  scale: _pressed ? .92 : 1,
                  duration: motionDuration(context, 110),
                  curve: Curves.easeOutCubic,
                  child: Ink(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.filled ? colors.primary : colors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: widget.filled
                          ? null
                          : Border.all(color: colors.outlineVariant),
                    ),
                    child: AnimatedSwitcher(
                      duration: motionDuration(context, 140),
                      child: Icon(
                        _added ? Icons.check_rounded : widget.icon,
                        key: ValueKey(_added),
                        size: 18,
                        color: widget.filled
                            ? colors.onPrimary
                            : colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedValue extends StatelessWidget {
  const AnimatedValue({super.key, required this.value, required this.child});
  final Object value;
  final Widget child;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: motionDuration(context, 160),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    child: KeyedSubtree(key: ValueKey(value), child: child),
  );
}

/// Keeps tab state/scroll offsets; only the selected tab can animate.
class MotionTabStack extends StatefulWidget {
  const MotionTabStack({
    super.key,
    required this.index,
    required this.children,
  });
  final int index;
  final List<Widget> children;
  @override
  State<MotionTabStack> createState() => _MotionTabStackState();
}

class _MotionTabStackState extends State<MotionTabStack>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, value: 1);
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = motionDuration(context);
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void didUpdateWidget(MotionTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(begin: .82, end: 1.0).animate(_curve),
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, .012),
        end: Offset.zero,
      ).animate(_curve),
      child: IndexedStack(
        index: widget.index,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            TickerMode(enabled: i == widget.index, child: widget.children[i]),
        ],
      ),
    ),
  );
}

class ShopPageTransitions extends PageTransitionsBuilder {
  const ShopPageTransitions();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curve = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(.035, 0),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}
