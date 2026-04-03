import 'package:flutter/material.dart';
import 'package:team_g/diseases_predictor.dart';
import 'cropcure_scan_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DiseasePredictor.loadModel();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropCure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const CropCureScanPage(),
    );
  }
}