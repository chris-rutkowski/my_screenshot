import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class LocalFileComparatorWithThreshold extends LocalFileComparator {
  late double threshold;

  LocalFileComparatorWithThreshold(Uri testFile) : super(testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= threshold) {
      var message = ' - difference ${(result.diffPercent * 100).toStringAsFixed(3)}%';
      message += ' (threshold ${(threshold * 100).toStringAsFixed(3)}%)';
      debugPrint(message);

      return true;
    }

    if (!result.passed) {
      final pathSegments = basedir.pathSegments.toList();
      pathSegments.add('snapshots_failures');

      final goldenPathSegments = golden.pathSegments.toList();
      goldenPathSegments.removeWhere((e) => e == '..' || e == 'snapshots');
      goldenPathSegments.removeLast(); // filename
      pathSegments.addAll(goldenPathSegments);

      final dir = basedir.replace(pathSegments: pathSegments);
      throw await generateFailureOutput(result, golden, dir);
    }

    return result.passed;
  }
}
