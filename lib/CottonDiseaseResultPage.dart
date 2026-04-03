import 'package:flutter/material.dart';
import 'package:team_g/diseases_predictor.dart';
import 'dart:io';

// Import the model service
import 'model_service.dart';

class CottonDiseaseResultPage extends StatefulWidget {
  final String imagePath;

  const CottonDiseaseResultPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<CottonDiseaseResultPage> createState() => _CottonDiseaseResultPageState();
}

class _CottonDiseaseResultPageState extends State<CottonDiseaseResultPage> {
  bool _isLoading = true;
  bool _hasDisease = false;
  String _diseaseName = '';
  String _confidenceLevel = '';
  String _treatmentSuggestion = '';
  late ModelService _modelService;

  @override
  void initState() {
    super.initState();
    _modelService = ModelService();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // Initialize the model
      await _modelService.loadModel();

      // Process the image
      final result = await DiseasePredictor.predict(widget.imagePath);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasDisease = result['diseaseName'] != "Healthy";
          _diseaseName = result['diseaseName']== "Healthy" ? "Healthy" : "Cotton leaf curl disease (CLCuD)" ;
          _confidenceLevel = result['confidence']!;
          _treatmentSuggestion = result['treatmentSuggestion'] != "Healthy" ? "No" : "yes";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _diseaseName = 'Error analyzing image';
          _confidenceLevel = 'N/A';
          _treatmentSuggestion = 'Please try again with a different image. If the problem persists, contact support.';
        });
      }
      print('Error in image analysis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        backgroundColor: Colors.green.shade500,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image display
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),

            // Results section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? _buildLoadingState()
                  : _buildResultsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing Cotton Leaf...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Our AI is examining the leaf for signs of disease',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Disease status heading
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hasDisease ? Colors.red.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _hasDisease ? Icons.warning_amber_rounded : Icons.check_circle,
                color: _hasDisease ? Colors.red.shade700 : Colors.green.shade700,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _diseaseName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _hasDisease ? Colors.red.shade800 : Colors.green.shade800,
                      ),
                    ),
                    Text(
                      'Confidence: $_confidenceLevel',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Detailed information
        const Text(
          'Analysis Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailItem(
          Icons.bug_report,
          'Disease Status',
          _hasDisease ? 'Infected' : 'Healthy',
        ),
        _buildDetailItem(
          Icons.healing,
          'Treatment Needed',
          _hasDisease ? 'Yes' : 'No',
        ),
        _buildDetailItem(
          Icons.calendar_today,
          'Scan Date',
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        ),

        const SizedBox(height: 24),

        // Treatment suggestion
        const Text(
          'Recommended Action',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _treatmentSuggestion,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Note: This is a preliminary analysis. For critical decisions, please consult with an agricultural expert.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: label == 'Disease Status' && value == 'Infected'
                  ? Colors.red.shade700
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}