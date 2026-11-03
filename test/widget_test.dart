import 'package:flutter_test/flutter_test.dart';
import 'package:psivh_school_system/main.dart';

void main() {
  testWidgets('PSI-VH App Root Gate mounts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PsiVhSchoolApp());
    expect(find.byType(PsiVhSchoolApp), findsOneWidget);
  });
}
