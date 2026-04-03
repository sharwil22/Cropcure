import 'package:tflite_v2/tflite_v2.dart';

class DiseasePredictor {
  /// Loads the TFLite model and labels
  static Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
      print("✅ Model loaded: $res");
    } catch (e) {
      print("❌ Error loading model: $e");
    }
  }

  /// Takes image path and prints prediction result
  static Future<Map<String, String>> predict(String imagePath) async {
    try {
      final results = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 2, // ✅ Match your model's output classes
        threshold: 0.5,
        imageMean: 0.0, // Scaled to [0, 1]
        imageStd: 1.0,  // Correct for 1./255 normalization
      );

      if (results != null && results.isNotEmpty) {
        print("🧾 Prediction Result:");
        final result = results.first; // take top result
        print(
          "🔹 ${result['label']} - ${(result['confidence'] * 100).toStringAsFixed(2)}%",
        );
        return {
          "diseaseName": result['label'] ?? "Unknown",
          "confidence": ((result['confidence'] ?? 0.0) * 100).toStringAsFixed(2)
        };
      } else {
        print("❌ No prediction results.");
        return {"error": "No prediction results"};
      }
    } catch (e) {
      print("❌ Error during prediction: $e");
      return {"error": e.toString()};
    }
  }


  /// Optional: Close the model when done
  static Future<void> disposeModel() async {
    await Tflite.close();
  }
}
