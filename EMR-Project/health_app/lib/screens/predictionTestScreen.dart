import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SymptomInputScreen extends StatefulWidget {
  @override
  _SymptomInputScreenState createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _symptomController = TextEditingController();
  String _prediction = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // List of common symptoms
  final List<String> _commonSymptoms = [
    'fever',
    'runny nose',
    'skin rash',
    'vomiting',
    'headache',
    'nausea',
    'fatigue',
    'diarrhea',
    'cough',
    'chest pain',
    'dizziness',
    'sore throat',
    'joint pain',
    'abdominal pain',
    'chills',
    'muscle ache'
  ];

  // Selected symptoms
  Set<String> _selectedSymptoms = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }

      // Update the text field with selected symptoms
      _symptomController.text = _selectedSymptoms.join(', ');
    });
  }

  void _addTypedSymptoms() {
    if (_symptomController.text.isNotEmpty) {
      List<String> typedSymptoms = _symptomController.text
          .toLowerCase()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      setState(() {
        _selectedSymptoms.addAll(typedSymptoms);
        _symptomController.text = _selectedSymptoms.join(', ');
      });
    }
  }

  Future<void> predictDisease(List<String> symptoms) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.162.84:5000/predict');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptoms': symptoms}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _prediction = json['predicted_disease'] ?? 'Unknown';
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        setState(() {
          _prediction = 'Failed to get prediction';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Clinical Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('About Disease Predictor'),
                  content: Text(
                    'This app provides preliminary disease predictions based on symptoms. '
                    'Please consult with a healthcare professional for proper diagnosis.',
                    style: TextStyle(height: 1.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header illustration
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE0F7FA),
                        Color.fromARGB(255, 57, 117, 209)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Symptom Analyzer',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Get preliminary disease predictions based on your symptoms.',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Colors.black.withOpacity(1),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Input section
                Text(
                  'Your Symptoms',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Type or select symptoms below.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16),

                // Enhanced input field with clear button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _symptomController,
                    decoration: InputDecoration(
                      hintText: 'Type symptoms here...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_symptomController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _symptomController.clear();
                                  _selectedSymptoms.clear();
                                });
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.add_circle,
                                color: Color.fromARGB(255, 18, 148, 209)),
                            onPressed: _addTypedSymptoms,
                          ),
                        ],
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 16),
                    maxLines: 2,
                    minLines: 1,
                    onSubmitted: (_) => _addTypedSymptoms(),
                  ),
                ),
                SizedBox(height: 24),

                // Common symptoms section
                Text(
                  'Common Symptoms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),

                // Symptom chips
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: _commonSymptoms.map((symptom) {
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return GestureDetector(
                      onTap: () => _toggleSymptom(symptom),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.green : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              symptom,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isSelected) ...[
                              SizedBox(width: 6),
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 32),

                // Selected symptoms summary
                if (_selectedSymptoms.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Selected Symptoms (${_selectedSymptoms.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSymptoms.clear();
                                  _symptomController.clear();
                                });
                              },
                              child: Text('Clear All'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedSymptoms.map((symptom) {
                            return Chip(
                              label: Text(symptom),
                              onDeleted: () {
                                setState(() {
                                  _selectedSymptoms.remove(symptom);
                                  _symptomController.text =
                                      _selectedSymptoms.join(', ');
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.medical_services),
                    label: Text(
                      _isLoading ? 'Analyzing...' : 'Predict Disease',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _isLoading || _selectedSymptoms.isEmpty
                        ? null
                        : () {
                            predictDisease(_selectedSymptoms.toList());
                          },
                  ),
                ),
                SizedBox(height: 32),

                // Result section
                if (_prediction.isNotEmpty)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.medical_information,
                                  color: Color(0xFF00BFA5),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Prediction Result',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006064),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _prediction,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00796B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFF006064).withOpacity(0.7),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This is a preliminary prediction. Please consult with a healthcare professional for proper diagnosis.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF006064).withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _prediction = '';
                                _selectedSymptoms.clear();
                                _symptomController.clear();
                              });
                            },
                            child: Text('Start New Prediction'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF00BFA5),
                              side: BorderSide(color: Color(0xFF00BFA5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
