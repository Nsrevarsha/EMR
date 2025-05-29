import 'package:flutter/material.dart';
import 'package:health_app/screens/diseasesScreen.dart';
import 'package:health_app/screens/patientsScreen.dart';
import 'package:health_app/screens/predictionTestScreen.dart';
import 'package:health_app/services/firebase_services.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Stay Informed About Common Diseases',
      'subtitle': 'Know symptoms, causes, and treatments.',
      'color': Color(0xFF1565C0), // Blue
      'image': 'lib/assets/images/banner3.jpg',
    },
    {
      'title': 'AI Health Predictor',
      'subtitle':
          'Type symptoms, get instant disease insights — powered by smart AI.',
      'color': Color(0xFF2E7D32), // Green
      'image': 'lib/assets/images/banner1.jpg',
    },
    {
      'title': 'Prescription Transcripts',
      'subtitle': 'Access and review all past prescriptions saved via voice.',
      'color': Color(0xFF6A1B9A), // Purple
      'image': 'lib/assets/images/banner2.webp',
    },
  ];

  // Feature cards data
  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Common Diseases',
      'description':
          'Learn about symptoms, causes, and treatments for common diseases.',
      'icon': Icons.local_hospital,
      'color': Colors.blue[400],
      'bgColor': Color(0xFFE8F5E9),
      'route': Diseasesscreen(),
    },
    {
      'title': 'Transcripts of Prescription',
      'description':
          'Record, edit, and review doctor-patient prescriptions anytime.',
      'icon': Icons.description,
      'color': Color(0xFFFFB74D),
      'bgColor': Color(0xFFFFF8E1),
      'route': PatientListScreen(),
    },
    {
      'title': 'Clinical Decision Support System',
      'description':
          'Enter your symptoms and get instant disease predictions powered by AI.',
      'icon': Icons.favorite,
      'color': Colors.red,
      'bgColor': Color(0xFFE1F5FE),
      'route': SymptomInputScreen(),
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: _firebaseService.getUserName(),
                  builder: (context, snapshot) {
                    final name = snapshot.data ?? 'User';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Swipeable Top Banner
          SizedBox(
            height: 160, // Increased height for better visibility
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = _banners[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    children: [
                      // Background Image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(banner['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Gradient Overlay for Better Readability
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              banner['color'].withOpacity(0.6),
                              banner['color'].withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                      // Text Content Positioned in Right Corner
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(right: 16, left: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                banner['title'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner['subtitle'],
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

// Pagination Dots
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == _currentBannerIndex ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == _currentBannerIndex
                        ? Colors.blue.shade800
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),

          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'For You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Feature Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: feature['bgColor'],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => feature['route']),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: feature['color'].withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  feature['icon'],
                                  color: feature['color'],
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feature['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      feature['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black45,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
