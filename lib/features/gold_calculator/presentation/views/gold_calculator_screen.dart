import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/gold_calculator_viewmodel.dart';
import 'gold_calculator_input_view.dart';

class GoldCalculatorScreen extends StatelessWidget {
  const GoldCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoldCalculatorViewModel(),
      child: const GoldCalculatorInputView(),
    );
  }
}
