import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

const _splashDurationMs = 3050;
const _logoArrival = 1000 / _splashDurationMs;

class StartupGate extends StatefulWidget {
  const StartupGate({required this.initialize, required this.child, super.key});

  final Future<void> Function() initialize;
  final Widget child;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate>
    with SingleTickerProviderStateMixin {
  static const _logo = AssetImage('assets/branding/sga_logo.png');
  static const _stillSplashDuration = Duration(milliseconds: 450);
  static const _appKey = ValueKey('initializedApp');
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _splashDurationMs),
  );

  bool _welcomeReady = false;
  bool _showApp = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final binding = WidgetsBinding.instance;
    // Keep the native launch screen visible until Flutter has the same logo.
    binding.deferFirstFrame();
    binding.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_start());
      } else {
        binding.allowFirstFrame();
      }
    });
  }

  Future<void> _start() async {
    final binding = WidgetsBinding.instance;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final initialization = _initialize();
    try {
      await precacheImage(_logo, context);
    } finally {
      binding.allowFirstFrame();
    }
    await binding.endOfFrame;
    if (!mounted || _failed) return;

    try {
      if (reducedMotion) {
        await Future<void>.delayed(_stillSplashDuration);
      } else {
        await _motion.animateTo(_logoArrival).orCancel;
      }
      if (!await initialization || !mounted) return;
      if (!reducedMotion) await _motion.forward().orCancel;
      if (mounted) setState(() => _welcomeReady = true);
    } on TickerCanceled {
      // Disposing the gate cancels any unfinished animation.
    }
  }

  Future<bool> _initialize() async {
    try {
      await widget.initialize();
      return true;
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          context: ErrorDescription('al iniciar SGA'),
        ),
      );
      if (mounted) setState(() => _failed = true);
      return false;
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  static Widget _enterTransition(Widget child, Animation<double> animation) {
    if (child.key != _appKey) return child;

    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, page) => IgnorePointer(
          ignoring: !animation.isCompleted,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: page,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: _enterTransition,
      child: _showApp
          ? KeyedSubtree(key: _appKey, child: widget.child)
          : _StartupArtwork(
              logo: _logo,
              motion: reducedMotion
                  ? AlwaysStoppedAnimation(_welcomeReady ? 1.0 : _logoArrival)
                  : _motion,
              failed: _failed,
              onEnter: _welcomeReady
                  ? () => setState(() => _showApp = true)
                  : null,
            ),
    );
  }
}

class _StartupArtwork extends StatelessWidget {
  const _StartupArtwork({
    required this.logo,
    required this.motion,
    required this.failed,
    required this.onEnter,
  });

  static const _entryStart = 325 / _splashDurationMs;
  static const _turnEnd = 1600 / _splashDurationMs;
  static const _logoReturnStart = 1750 / _splashDurationMs;
  static const _riseStart = 2150 / _splashDurationMs;

  final ImageProvider logo;
  final Animation<double> motion;
  final bool failed;
  final VoidCallback? onEnter;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: LayoutBuilder(
        builder: (context, bounds) {
          final logoSize = math.min(
            bounds.maxWidth * .612,
            bounds.maxHeight * .32,
          );
          final waitSize = math.min(120.0, logoSize);
          final waitLogo = Image(
            image: logo,
            width: waitSize,
            height: waitSize,
            excludeFromSemantics: true,
          );
          if (failed) {
            return Material(
              color: AppTheme.launchViolet,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      waitLogo,
                      const SizedBox(height: 24),
                      const Text(
                        'No se pudo iniciar SGA. Cierra la app y vuelve a abrirla.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Lay out the welcome panel before it enters the viewport.
          final welcome = RepaintBoundary(
            child: _WelcomeContent(onEnter: onEnter),
          );
          return Semantics(
            label: onEnter == null ? 'Iniciando SGA' : 'SGA',
            child: AnimatedBuilder(
              animation: motion,
              child: RepaintBoundary(
                child: Image(
                  image: logo,
                  width: logoSize,
                  height: logoSize,
                  excludeFromSemantics: true,
                ),
              ),
              builder: (context, animatedLogo) {
                final time = motion.value;
                final fade = const Interval(
                  0,
                  _entryStart,
                  curve: Curves.easeInOut,
                ).transform(time);
                final entry = const Interval(
                  _entryStart,
                  _logoArrival,
                  curve: Curves.easeInOutBack,
                ).transform(time);
                final turn = const Interval(
                  _logoArrival,
                  _turnEnd,
                  curve: Curves.easeInOutBack,
                ).transform(time);
                final straighten = const Interval(
                  _logoReturnStart,
                  _riseStart,
                  curve: Curves.easeInOutCubic,
                ).transform(time);
                final rise = const Interval(
                  _riseStart,
                  1,
                  curve: Curves.easeInOut,
                ).transform(time);
                final offset =
                    -(bounds.maxHeight + logoSize) * .5 * (1 - entry) -
                    bounds.maxHeight * .20 * rise;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.launchGradient,
                      ),
                    ),
                    Center(
                      child: Transform.translate(
                        offset: Offset(0, offset),
                        child: Transform.rotate(
                          angle: math.pi * (straighten - turn),
                          child: Transform.scale(
                            scale: 1 - .277 * rise,
                            child: animatedLogo,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      top: bounds.maxHeight * .487,
                      child: ClipRect(
                        child: FractionalTranslation(
                          translation: Offset(0, 1 - rise),
                          child: welcome,
                        ),
                      ),
                    ),
                    if (fade < 1)
                      Opacity(
                        opacity: 1 - fade,
                        child: ColoredBox(
                          color: AppTheme.launchBlue,
                          child: Center(child: waitLogo),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeContent extends StatefulWidget {
  const _WelcomeContent({required this.onEnter});

  final VoidCallback? onEnter;

  @override
  State<_WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<_WelcomeContent> {
  bool _pressed = false;

  void _press() {
    final onEnter = widget.onEnter;
    if (onEnter == null || _pressed) return;

    if (MediaQuery.disableAnimationsOf(context)) {
      onEnter();
    } else {
      setState(() => _pressed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = widget.onEnter != null && !_pressed;
    return ExcludeSemantics(
      excluding: !enabled,
      child: IgnorePointer(
        ignoring: !enabled,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Punto de venta',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Escanea un código de barras para empezar.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFF1F3FF),
                      ),
                    ),
                    const SizedBox(height: 26),
                    AnimatedScale(
                      scale: _pressed ? .96 : 1,
                      duration: const Duration(milliseconds: 80),
                      curve: Curves.easeOut,
                      onEnd: _pressed ? widget.onEnter : null,
                      child: FilledButton(
                        onPressed: enabled ? _press : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.launchViolet,
                          disabledBackgroundColor: Colors.white,
                          disabledForegroundColor: AppTheme.launchViolet,
                          minimumSize: const Size(0, 48),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Entrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
