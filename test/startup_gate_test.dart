import 'dart:async';

import 'package:billing_app/core/widgets/startup_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _homeLabel = 'Inicio de prueba';

Future<void> _pumpStartup(
  WidgetTester tester,
  Completer<void> initialization, {
  bool reducedMotion = false,
}) async {
  await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage('assets/branding/sga_logo.png'),
      tester.element(find.byType(MaterialApp)),
    );
  });
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
        child: StartupGate(
          initialize: () => initialization.future,
          child: child!,
        ),
      ),
      home: const Scaffold(body: Text(_homeLabel)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the prebuilt welcome and upright logo rise smoothly together', (
    tester,
  ) async {
    final initialization = Completer<void>()..complete();
    await _pumpStartup(tester, initialization);

    final splash = find.byType(StartupGate);
    final logo = find
        .descendant(of: splash, matching: find.byType(Image))
        .first;
    final title = find.text('Punto de venta');
    final description = find.text('Escanea un código de barras para empezar.');
    final enter = find.widgetWithText(FilledButton, 'Entrar');
    final height = tester.getSize(splash).height;
    expect(title, findsOneWidget);
    expect(tester.getTopLeft(title).dy, greaterThanOrEqualTo(height - 1));
    final titleElement = tester.element(title);
    expect(tester.widget<FilledButton>(enter).onPressed, isNull);

    final welcome = find
        .ancestor(of: title, matching: find.byType(FractionalTranslation))
        .first;
    final welcomeTravel = tester.getSize(welcome).height;
    var sawInvertedLogo = false;
    var riseFrames = 0;
    for (var frame = 0; frame < 150; frame++) {
      final logoY = tester.getCenter(logo).dy;
      final titleY = tester.getCenter(title).dy;
      final descriptionY = tester.getCenter(description).dy;
      final buttonY = tester.getCenter(enter).dy;
      await tester.pump(const Duration(milliseconds: 32));

      final image = tester.renderObject<RenderBox>(logo);
      final axis =
          image.localToGlobal(const Offset(1, 0)) -
          image.localToGlobal(Offset.zero);
      sawInvertedLogo |= axis.dx < -.99 && axis.dy.abs() < .01;
      final titleRise = titleY - tester.getCenter(title).dy;
      if (titleRise > .001) {
        final progress = titleRise / welcomeTravel;
        expect(axis.dx, greaterThan(0));
        expect(axis.dy, closeTo(0, .001));
        expect(progress, lessThan(riseFrames == 0 ? .02 : .07));
        expect(
          progress,
          closeTo((logoY - tester.getCenter(logo).dy) / (height * .20), .001),
        );
        expect(
          descriptionY - tester.getCenter(description).dy,
          closeTo(titleRise, .01),
        );
        expect(buttonY - tester.getCenter(enter).dy, closeTo(titleRise, .01));
        riseFrames++;
      }
      if (tester.widget<FilledButton>(enter).onPressed != null) break;
    }

    expect(sawInvertedLogo, isTrue);
    expect(riseFrames, greaterThanOrEqualTo(25));
    expect(tester.element(title), same(titleElement));
    expect(tester.getCenter(logo).dy, closeTo(height * .30, 1));
    expect(tester.widget<FilledButton>(enter).onPressed, isNotNull);
  });

  testWidgets(
    'Entrar scales briefly and then reveals the app with a slide and fade',
    (tester) async {
      final initialization = Completer<void>();
      await _pumpStartup(tester, initialization);
      await tester.pump(const Duration(seconds: 4));
      expect(find.text(_homeLabel), findsNothing);
      expect(
        find.widgetWithText(FilledButton, 'Entrar').hitTestable(),
        findsNothing,
      );

      initialization.complete();
      await tester.pumpAndSettle();
      expect(find.text('Punto de venta'), findsOneWidget);
      expect(
        find.text('Escanea un código de barras para empezar.'),
        findsOneWidget,
      );
      final enter = find.widgetWithText(FilledButton, 'Entrar');
      expect(enter, findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text(_homeLabel), findsNothing);

      final buttonWidth = tester.getRect(enter).width;
      await tester.tap(enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.getRect(enter).width, lessThan(buttonWidth));
      expect(tester.widget<FilledButton>(enter).onPressed, isNull);
      final home = find.text(_homeLabel);
      expect(home, findsNothing);

      for (var frame = 0; frame < 12 && home.evaluate().isEmpty; frame++) {
        await tester.pump(const Duration(milliseconds: 4));
      }
      expect(home, findsOneWidget);
      final app = find.byKey(const ValueKey('initializedApp'));
      final fade = find.ancestor(
        of: app,
        matching: find.byType(FadeTransition),
      );
      expect(
        tester.widget<FadeTransition>(fade).opacity.value,
        closeTo(0, .05),
      );
      final initialY = tester.getTopLeft(home).dy;
      expect(enter, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 160));
      final opacity = tester.widget<FadeTransition>(fade).opacity.value;
      final middleY = tester.getTopLeft(home).dy;
      expect(opacity, inExclusiveRange(0, 1));
      expect(middleY, lessThan(initialY));

      await tester.pumpAndSettle();
      final finalY = tester.getTopLeft(home).dy;
      expect(initialY - finalY, closeTo(20, 1));
      expect(middleY, greaterThan(finalY));
      expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
      expect(enter, findsNothing);
    },
  );

  testWidgets(
    'reduced motion shows a still splash and the same welcome screen',
    (tester) async {
      final initialization = Completer<void>()..complete();
      await _pumpStartup(tester, initialization, reducedMotion: true);

      final logo = find.descendant(
        of: find.byType(StartupGate),
        matching: find.byType(Image),
      );
      expect(logo, findsOneWidget);
      final center = tester.getCenter(logo);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(_homeLabel), findsNothing);
      expect(tester.getCenter(logo), center);

      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('Punto de venta'), findsOneWidget);
      expect(find.text(_homeLabel), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      expect(find.text(_homeLabel), findsOneWidget);
    },
  );
}
