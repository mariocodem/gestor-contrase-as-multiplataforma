import 'dart:ui' as ui;

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:boveda_presentation/boveda_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fakes.dart';

/// Widgets rebuilt while [action] runs, using the framework's own dirty-widget hook.
Future<int> rebuildsDuring(Future<void> Function() action) async {
  var count = 0;
  debugOnRebuildDirtyWidget = (element, builtOnce) => count++;
  await action();
  debugOnRebuildDirtyWidget = null;
  return count;
}

final _vault = [
  for (var i = 0; i < 300; i++)
    VaultEntry(id: 'e$i', title: 'Cuenta ${i.toString().padLeft(3, '0')}', username: 'usuario$i@correo.es', password: 'clave-$i'),
];

Future<void> openVault(WidgetTester tester) async {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(BovedaApp(dependencies: fakeDependencies(vault: FakeVaultRepository(entries: _vault))));
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  // Budgets, not exact counts: they fail if a change makes a hot path rebuild the screen around it.
  testWidgets('the list is lazy: a big vault builds only what is on screen', (tester) async {
    await openVault(tester);
    expect(find.text('Cuenta 000'), findsOneWidget);
    expect(find.text('Cuenta 299'), findsNothing);
    expect(find.byType(KeyCap).evaluate().length, lessThan(20));
  });

  testWidgets('scrolling rebuilds rows coming into view, not the screen', (tester) async {
    await openVault(tester);
    final gesture = await tester.startGesture(const Offset(200, 500));
    await tester.pump();
    final rebuilds = await rebuildsDuring(() async {
      for (var i = 0; i < 30; i++) {
        await gesture.moveBy(const Offset(0, -2));
        await tester.pump(const Duration(milliseconds: 16));
      }
    });
    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
    // ignore: avoid_print
    print('METRIC scroll 60px: $rebuilds rebuilds');
    expect(rebuilds, lessThan(500));
  });

  testWidgets('a keystroke in the search stays cheap', (tester) async {
    await openVault(tester);
    // Typing on: the field has focus, and the same rows stay while their highlight changes.
    await tester.enterText(find.byType(TextField), 'C');
    await tester.pump(const Duration(seconds: 1));
    final rebuilds = await rebuildsDuring(() async {
      await tester.enterText(find.byType(TextField), 'Cu');
      await tester.pump();
    });
    // ignore: avoid_print
    print('METRIC keystroke: $rebuilds rebuilds');
    expect(rebuilds, lessThan(400));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a key cap costs little to paint, in a list or in flight', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: bovedaTheme(brightness: Brightness.light), home: const Center(child: KeyCap(label: 'Banco'))),
    );
    final painter = tester
        .widget<CustomPaint>(find.descendant(of: find.byType(KeyCap), matching: find.byType(CustomPaint)))
        .painter!;
    final watch = Stopwatch()..start();
    for (var i = 0; i < 2000; i++) {
      final recorder = ui.PictureRecorder();
      // A different size every time, as during the flight between the row and the detail.
      painter.paint(Canvas(recorder), Size.square(40 + i % 36));
      recorder.endRecording().dispose();
    }
    // ignore: avoid_print
    print('METRIC key cap paint: ${watch.elapsedMicroseconds / 2000} us');
    expect(tester.takeException(), isNull);
  });
}
