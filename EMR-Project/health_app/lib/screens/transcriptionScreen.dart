import 'package:flutter/material.dart';
import 'package:health_app/screens/patientTranscriptDetails.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';

class TranscriptionScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const TranscriptionScreen({Key? key, required this.data}) : super(key: key);

  @override
  _TranscriptionScreenState createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  TextEditingController _textController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeechRecognition();
  }

  Future<void> _initializeSpeechRecognition() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Speech recognition not available")),
        );
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please enable microphone permission in settings")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Microphone permission denied")),
      );
    }
  }

  void _startListening() async {
    if (!_speechToText.isAvailable || _isListening) return;

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      },
      listenMode: stt.ListenMode.dictation,
    );

    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Save transcript to Firestore
  Future<void> _saveTranscription() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot save empty transcript")),
      );
      return;
    }

    final patID = widget.data['patID']; // Patient ID from passed data

    // Add a new document to the "transcripts" collection
    final transcriptsRef = firestore.collection('transcripts');

    // Get the last transcript number
    QuerySnapshot querySnapshot =
        await transcriptsRef.where('patID', isEqualTo: patID).get();

    int nextIndex =
        querySnapshot.docs.isEmpty ? 1 : querySnapshot.docs.length + 1;

    await transcriptsRef.add({
      'patID': patID,
      'transcript': _textController.text,
      'transcriptID': 't$nextIndex', // t1, t2, t3, etc.
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Saved as transcript $nextIndex"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Patient Transcription",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                theme.primaryColor.withOpacity(0.2),
                            radius: 24,
                            child: Icon(
                              Icons.person,
                              color: theme.primaryColor,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${data['name']}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "PID: ${data['patID']}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoItem(
                              Icons.phone, "Phone", "${data['phone']}"),
                          SizedBox(width: 24),
                          _buildInfoItem(Icons.calendar_today, "Age",
                              "${data['age']} years"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Transcription",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 5),
              // Editable Transcription Field
              Expanded(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Start speaking or type here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8),

              // Mic Button and Action Buttons
              Row(
                children: [
                  // Mic Button
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.redAccent : Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _isListening
                                ? Colors.redAccent.withOpacity(0.3)
                                : theme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Action Buttons
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveTranscription,
                          icon: Icon(Icons.save),
                          label: Text("Save"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientTranscriptDetailsScreen(
                                    patID: data['patID']),
                              ),
                            );
                          }, // to be done later
                          icon: Icon(Icons.history),
                          label: Text("History"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
