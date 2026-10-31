import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hacktoberfest/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mobile onboarding leads to student and teacher entry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SabiApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('On avance ensemble'), findsOneWidget);
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour !'), findsOneWidget);

    await tester.tap(find.text('Je suis enseignant'));
    await tester.pumpAndSettle();
    expect(find.text('Espace enseignant'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('desktop dashboard links to competencies and remediation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SabiApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Bonjour, enseignant·e !'), findsOneWidget);
    await tester.tap(find.text('Compétences').first);
    await tester.pumpAndSettle();
    expect(find.text('Carte de la classe'), findsOneWidget);

    await tester.tap(find.text('Factorisation').last);
    await tester.pumpAndSettle();
    expect(find.text('Préparer une séance'), findsOneWidget);
  });

  testWidgets('student can finish a lesson and see the mastered state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SabiApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer').last);
    await tester.pumpAndSettle();
    expect(find.text('On demande aux grands'), findsOneWidget);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Découvrons ton niveau'), findsOneWidget);
    await tester.tap(find.text('Démarrer'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 sur 10'), findsOneWidget);

    for (var question = 0; question < 9; question++) {
      await tester.ensureVisible(find.text('Question suivante'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Question suivante'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Question 10 sur 10'), findsOneWidget);
    await tester.ensureVisible(find.text('Voir mon parcours'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voir mon parcours'));
    await tester.pumpAndSettle();

    expect(find.text('Ton point de départ'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'placement result layout');
    await tester.scrollUntilVisible(
      find.text('Voir mon parcours'),
      350,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voir mon parcours'));
    await tester.pumpAndSettle();
    expect(find.text('Ton parcours'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'home layout');

    await tester.tap(find.text('Les identités remarquables'));
    await tester.pumpAndSettle();
    expect(find.text('Les identités'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'lesson layout');
    await tester.scrollUntilVisible(
      find.text('S’entraîner'),
      350,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('S’entraîner'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'exercise layout');

    await tester.enterText(find.byType(TextField).last, '(x - 7)(x + 7)');
    await tester.tap(find.text('Vérifier ma réponse'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'correction layout');
    expect(find.text('Bravo ! Bien joué !'), findsOneWidget);

    await tester.tap(find.text('Compétence maîtrisée !'));
    await tester.pumpAndSettle();
    expect(find.text('Compétence maîtrisée !'), findsOneWidget);
    expect(find.text('Continuer mon parcours'), findsOneWidget);
  });
}
