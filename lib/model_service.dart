import 'package:tflite_v2/tflite_v2.dart';

class ModelService {
  bool _isModelLoaded = false;

  /// Loads the TFLite model and labels
  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      String? res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
      print("✅ Model loaded: $res");
      _isModelLoaded = true;
    } catch (e) {
      print("❌ Error loading model: $e");
      throw Exception("Failed to load disease detection model: $e");
    }
  }

  /// Process the image and return structured results
  Future<Map<String, dynamic>> processImage(String imagePath) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    try {
      final results = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 2,        // Set to match your model's 2 output classes
        threshold: 0.5,       // Minimum confidence threshold
        imageMean: 0.0,       // Your model is scaled to [0, 1] (rescale=1./255)
        imageStd: 1.0,        // Updated from 255.0 to 1.0 for proper normalization
      );

      if (results == null || results.isEmpty) {
        return {
          'hasDisease': false,
          'diseaseName': 'Unknown (No results)',
          'confidence': '0%',
          'treatmentSuggestion': 'Unable to analyze the image. Please try again with a clearer image of the cotton leaf.'
        };
      }

      // Get the highest confidence prediction
      final prediction = results[0];
      final label = prediction['label'] as String;
      final confidence = (prediction['confidence'] * 100).toStringAsFixed(1) + '%';

      // Parse the label to determine if it's a disease or healthy
      // Assuming format from labels.txt is like "0 Healthy" or "1 Cotton Leaf Curl Disease"
      final labelParts = label.split(' ');
      final className = labelParts.length > 1
          ? labelParts.sublist(1).join(' ')
          : label;

      final hasDisease = !className.toLowerCase().contains('healthy');

      // Determine treatment suggestion based on the detected disease
      String treatmentSuggestion = _getTreatmentSuggestion(className, hasDisease);

      return {
        'hasDisease': hasDisease,
        'diseaseName': className,
        'confidence': confidence,
        'treatmentSuggestion': treatmentSuggestion
      };
    } catch (e) {
      print("❌ Error during prediction: $e");
      throw Exception("Failed to analyze cotton leaf image: $e");
    }
  }

  /// Get treatment suggestion based on the disease name
  String _getTreatmentSuggestion(String diseaseName, bool hasDisease) {
    if (!hasDisease) {
      return 'Your cotton plant appears healthy. Continue with regular watering and fertilization. Monitor for any changes in leaf appearance.';
    }

    // Provide specific treatment suggestions based on common cotton diseases
    final lowerCaseName = diseaseName.toLowerCase();

    if (lowerCaseName.contains('leaf curl')) {
      return 'Cotton Leaf Curl Disease detected. This is caused by a virus transmitted by whiteflies. Recommended actions:\n\n'
          '1. Remove and destroy infected plants\n'
          '2. Apply appropriate insecticides to control whitefly population\n'
          '3. Use resistant cotton varieties for future planting\n'
          '4. Maintain field hygiene and eliminate weed hosts';
    }
    else if (lowerCaseName.contains('bacterial blight') || lowerCaseName.contains('boll rot')) {
      return 'Bacterial Blight detected. This bacterial disease thrives in wet conditions. Recommended actions:\n\n'
          '1. Avoid overhead irrigation\n'
          '2. Rotate crops with non-host plants\n'
          '3. Use acid delinted seeds\n'
          '4. Apply copper-based bactericides as preventative measure\n'
          '5. Improve field drainage';
    }
    else if (lowerCaseName.contains('target spot') || lowerCaseName.contains('alternaria')) {
      return 'Target Spot/Alternaria Leaf Spot detected. This fungal disease spreads in humid conditions. Recommended actions:\n\n'
          '1. Apply approved fungicides\n'
          '2. Improve air circulation between plants\n'
          '3. Avoid excessive nitrogen fertilization\n'
          '4. Maintain optimal plant spacing';
    }
    else {
      return 'Disease detected. As a precautionary measure:\n\n'
          '1. Isolate affected plants to prevent spread\n'
          '2. Consider removing severely affected leaves\n'
          '3. Apply a broad-spectrum fungicide/bactericide as appropriate\n'
          '4. Consult with a local agricultural extension agent for specific treatment options';
    }
  }

  /// Dispose of the model when no longer needed
  Future<void> disposeModel() async {
    if (_isModelLoaded) {
      await Tflite.close();
      _isModelLoaded = false;
      print("🔒 Model resources released");
    }
  }
}