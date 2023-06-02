import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_screenshot/main.dart' as app;

import 'local_file_comparator_with_threshold.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      timeDilation = 0.01;
      app.main();

      final baseDir = (goldenFileComparator as LocalFileComparator).basedir;
      goldenFileComparator = LocalFileComparatorWithThreshold(
        Uri.parse('$baseDir/any'), // only baseDir is required
      )..threshold = 0.001;

      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      final Finder fab = find.byTooltip('Increment');
      await tester.tap(fab);
      await tester.pumpAndSettle();
      // expect(find.text('1'), findsOneWidget);
      final bytes = await binding.takeScreenshot('screenshot');
      await expectLater(bytes, matchesGoldenFile('snapshots/value-1.png'));
      timeDilation = 1;
    });
  });
}
