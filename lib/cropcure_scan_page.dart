import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'cottondiseaseresultPage.dart';
class CropCureScanPage extends StatelessWidget {
  const CropCureScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              _buildLogo(),
              const SizedBox(height: 16),
              // App Name
              const Text(
                'CROPCURE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),
              // Subtitle
              const Text(
                'Choose Your Scan Option',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 50),
              // Grid of options
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ScanOptionCard(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () => _takePicture(context),
                    ),
                    ScanOptionCard(
                      icon: Icons.cloud_upload_outlined,
                      label: 'Storage',
                      onTap: () => _pickFromGallery(context),
                    ),
                    const ScanOptionCard(
                      icon: Icons.eco_outlined,
                      label: 'Plants',
                    ),
                    const ScanOptionCard(
                      icon: Icons.bookmark_border_outlined,
                      label: 'Bookmarks',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CottonDiseaseResultPage(
            imagePath: image.path,
          ),
        ),
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CottonDiseaseResultPage(
            imagePath: image.path,
          ),
        ),
      );
    }
  }

  Widget _buildLogo() {
    return Container(
      height: 70,
      width: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Image.asset(
        'assets/cropcure_logo.png',
        errorBuilder: (context, error, stackTrace) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.green.shade100,
              child: Icon(
                Icons.spa,
                size: 40,
                color: Colors.green.shade700,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ScanOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ScanOptionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            // Default action if no onTap is provided
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label option coming soon')),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}