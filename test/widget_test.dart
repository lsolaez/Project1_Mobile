import 'package:flutter_test/flutter_test.dart';
import 'package:project1/main.dart';

void main() {
  testWidgets('Get Started button navigates to Home screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Get Started button is present.
    expect(find.text('Get Started'), findsOneWidget);

    // Tap the Get Started button and trigger a frame.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();  // Esperar hasta que todas las animaciones se completen

    // Verify that we have navigated to the Home screen.
    expect(find.text('Healthy Recipes'), findsOneWidget);  // Ajusta este texto a lo que tengas en la pantalla Home
  });
}
