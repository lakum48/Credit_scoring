import 'package:flutter/material.dart';
import 'features/predict/presentation/predict_screen.dart';

void main() {
  runApp(const CreditApp());
}

class CreditApp extends StatelessWidget {
  const CreditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Scoring',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PredictScreen(),
    );
  }
}

