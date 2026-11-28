import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog._({required this.hasItems});

  final bool hasItems;

  static Future<bool> show(
    BuildContext context, {
    required bool hasItems,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final route = RawDialogRoute<bool>(
      barrierColor: Colors.black54,
      barrierDismissible: false,
      pageBuilder: (_, _, _) =>
          SafeArea(child: ExitConfirmationDialog._(hasItems: hasItems)),
      transitionDuration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, _, child) {
        final progress = animation.drive(
          CurveTween(curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: progress,
          child: ScaleTransition(
            scale: progress.drive(Tween(begin: .94, end: 1.0)),
            child: child,
          ),
        );
      },
    );

    final confirmed = await navigator.push(route);
    await route.completed;
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    void close(bool confirmed) {
      if (ModalRoute.isCurrentOf(context) == true) {
        Navigator.of(context).pop(confirmed);
      }
    }

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      constraints: const BoxConstraints(maxWidth: 360),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      scrollable: true,
      icon: CircleAvatar(
        radius: 26,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: const Icon(Icons.logout_rounded),
      ),
      title: const Text('¿Salir del punto de venta?'),
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      content: hasItems
          ? const Text(
              'El pedido actual se perderá.',
              textAlign: TextAlign.center,
            )
          : null,
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsOverflowButtonSpacing: 8,
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        _ExitAction(label: 'Cancelar', onPressed: () => close(false)),
        _ExitAction(
          label: 'Salir',
          onPressed: () => close(true),
          primary: true,
        ),
      ],
    );
  }
}

class _ExitAction extends StatefulWidget {
  const _ExitAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  State<_ExitAction> createState() => _ExitActionState();
}

class _ExitActionState extends State<_ExitAction> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(116, 48)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final label = Text(widget.label);
    final button = widget.primary
        ? FilledButton(
            statesController: _states,
            style: style.copyWith(
              backgroundColor: const WidgetStatePropertyAll(
                AppTheme.launchViolet,
              ),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: widget.onPressed,
            child: label,
          )
        : OutlinedButton(
            statesController: _states,
            style: style.copyWith(
              foregroundColor: const WidgetStatePropertyAll(
                AppTheme.launchViolet,
              ),
            ),
            onPressed: widget.onPressed,
            child: label,
          );

    return ValueListenableBuilder(
      valueListenable: _states,
      child: button,
      builder: (context, states, child) => AnimatedScale(
        duration: reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        scale: !reducedMotion && states.contains(WidgetState.pressed) ? .96 : 1,
        child: child,
      ),
    );
  }
}
