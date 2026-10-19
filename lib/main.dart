import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryService.instance.loadHistory();
  runApp(const App());
}