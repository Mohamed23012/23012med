import 'package:flutter/material.dart';
import 'package:internet/services/network_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  _ComplaintsScreenState createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  double _currentRating = 0.0;
  final TextEditingController _complaintController = TextEditingController();
  final List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints(); // Load saved complaints on startup
  }

  // Save complaints to SharedPreferences
  Future<void> _saveComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final complaintsJson = jsonEncode(_complaints); // Convert to JSON
    await prefs.setString('complaints', complaintsJson); // Save
  }

  // Load saved complaints from SharedPreferences
  Future<void> _loadComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final complaintsJson = prefs.getString('complaints');
    if (complaintsJson != null) {
      final loadedComplaints =
          List<Map<String, dynamic>>.from(jsonDecode(complaintsJson));
      setState(() {
        _complaints.addAll(loadedComplaints); // Add loaded complaints
      });
    }
  }

  void _submitComplaint() async {
    if (_currentRating > 0 || _complaintController.text.isNotEmpty) {
      // Show a loading indicator while data is being stored
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Add the complaint to local storage
      setState(() {
        _complaints.add({
          'date': DateTime.now().toIso8601String(),
          'rating': _currentRating,
          'complaint': _complaintController.text,
        });
        _complaintController.clear();
        _currentRating = 0.0;
      });

      // Save the complaints locally
      await _saveComplaints();
      final networkProvider = Provider.of<NetworkProvider>(context, listen: false);

      // Prepare and store data to the backend
      try {
        networkProvider.storeData(); // Call your storeData function
        Navigator.pop(context); // Close the loading dialog
      } catch (e) {
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit complaint: $e")),
        );
      }
    } else {
      // Show an error if the rating or complaint is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide a rating and enter your complaint."),
        ),
      );
    }
  }

  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString()}\n${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  void _showComplaintDetails(String complaint) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Complaint Details"),
          content: Text(complaint),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStars() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (index) {
      return IconButton(
        icon: Icon(
          index < _currentRating
              ? Icons.star
              : Icons.star_border, // Étoile pleine ou vide
          color: Colors.amber,
          size: 50,
        ),
        onPressed: () {
          setState(() {
            if (_currentRating == index + 1) {
              _currentRating = index.toDouble();
            } else {
              _currentRating = index + 1.0;
            }
          });
        },
        highlightColor: Colors.transparent, // Désactiver la couleur du surlignage
      );
    }),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("PLAINTS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notification functionality here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Section
            Column(
              children: [
                _buildStars(),
                const SizedBox(height: 8),
                const Text(
                  "Rate your experience, it is important for us",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Complaint Input
            TextField(
              controller: _complaintController,
              decoration: InputDecoration(
                labelText: "",
                labelStyle: const TextStyle(
                  color: Colors.blue,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2.0,
                  ),
                ),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitComplaint,
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(60, 50),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Complaints History Title
            const Text(
              "Historique",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),

            // Complaints History Table
            Expanded(
              child: _complaints.isEmpty
                  ? const Center(
                      child: Text(
                        "No complaints yet.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table Header
                        Container(
                          color: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Date",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child:
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _complaints.length > 5 ? 5 : _complaints.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: Colors.black12,
                              thickness: 1,
                              height: 3,
                            ),
                            itemBuilder: (context, index) {
                              final complaint = _complaints[_complaints.length - index - 1];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        _formatDateTime(complaint['date']),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          
                                          const SizedBox(width: 4),
                                          Text(
                                            complaint['rating'].toInt().toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () => _showComplaintDetails(
                                            complaint['complaint']),
                                        child: Text(
                                          complaint['complaint'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
