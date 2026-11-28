import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/billing/presentation/pages/home_page.dart';
import 'package:billing_app/features/billing/presentation/widgets/exit_confirmation_dialog.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _UnusedProductRepository implements ProductRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('system back asks before closing the point of sale', (
    tester,
  ) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    var exitCalls = 0;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') exitCalls++;
      return null;
    });
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.steenbakker.mobile_scanner/scanner/method'),
      (call) async => switch (call.method) {
        'state' => 0,
        'request' => false,
        _ => null,
      },
    );
    for (final name in ['event', 'deviceOrientation']) {
      messenger.setMockMethodCallHandler(
        MethodChannel('dev.steenbakker.mobile_scanner/scanner/$name'),
        (_) async => null,
      );
    }

    final billing = BillingBloc(
      getProductByBarcodeUseCase: GetProductByBarcodeUseCase(
        _UnusedProductRepository(),
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomePage()),
        GoRoute(
          path: '/detail',
          builder: (_, _) => const Scaffold(body: Text('Detalle')),
        ),
      ],
    );
    addTearDown(billing.close);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider.value(
        value: billing,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    billing.add(
      AddProductToCartEvent(
        const Product(id: '1', name: 'Arroz', barcode: '1', price: 2),
      ),
    );
    await tester.pumpAndSettle();

    router.push<void>('/detail');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsNothing);
    final dialog = find.byType(ExitConfirmationDialog);
    expect(dialog, findsNothing);
    expect(exitCalls, 0);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(dialog, findsOneWidget);
    expect(find.text('El pedido actual se perderá.'), findsOneWidget);

    final cancel = find.widgetWithText(OutlinedButton, 'Cancelar');
    final normalWidth = tester.getRect(cancel).width;
    final press = await tester.startGesture(tester.getCenter(cancel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getRect(cancel).width, lessThan(normalWidth));
    await press.up();
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(billing.state.cartItems.single.quantity, 1);
    expect(exitCalls, 0);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(exitCalls, 0);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Salir'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(exitCalls, 1);
  });

  testWidgets('the exit actions fit on a narrow screen with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(300, 480);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2), disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  ExitConfirmationDialog.show(context, hasItems: true),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final cancel = find.widgetWithText(OutlinedButton, 'Cancelar');
    final exit = find.widgetWithText(FilledButton, 'Salir');
    expect(cancel.hitTestable(), findsOneWidget);
    expect(exit.hitTestable(), findsOneWidget);
    expect(tester.getCenter(exit).dy, greaterThan(tester.getCenter(cancel).dy));
    expect(tester.takeException(), isNull);
  });
}
