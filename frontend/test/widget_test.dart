import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/view_models/interview_view_model.dart';

void main() {
  testWidgets('smartMock app smoke test loads welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InterviewViewModel()),
        ],
        child: const SmartMockApp(),
      ),
    );

    expect(find.text('smartMock'), findsOneWidget);
    expect(find.text('Start smartMock Interview'), findsOneWidget);
  });
}
