import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControlElection extends StatefulWidget {
  const ControlElection({super.key});

  @override
  State<ControlElection> createState() => _ControlElectionState();
}

class _ControlElectionState extends State<ControlElection> {
  final supabase = Supabase.instance.client;

  String status = "Loading...";
  String rawStatus = "";
  bool isLoading = true;

  int totalUsers = 0;
  int totalCandidates = 0;

  @override
  void initState() {
    super.initState();
    _fetchElectionData();
  }

  Future<void> _fetchElectionData() async {
    try {
      // Fetch election status
      final statusResponse = await supabase
          .from('election_status')
          .select()
          .eq('id', 1)
          .maybeSingle();

      // Fetch user and candidate counts
      final usersResponse = await supabase.from('users_list').select('id');
      final candidatesResponse = await supabase
          .from('candidates')
          .select('id')
          .eq('is_verified', true);

      final currentStatus = statusResponse != null
          ? statusResponse['status'] ?? 'not_started'
          : 'not_started';

      setState(() {
        rawStatus = currentStatus;
        status = _mapStatusToLabel(currentStatus);
        totalUsers = usersResponse.length;
        totalCandidates = candidatesResponse.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        status = "❌ Error fetching data";
      });
      _showSnack("Error loading data: ${e.toString()}", Colors.red);
    }
  }

  String _mapStatusToLabel(String code) {
    switch (code) {
      case 'active':
        return '✅ Election is Active';
      case 'paused':
        return '⏸️ Election is Paused';
      case 'ended':
        return '🛑 Election has Ended';
      default:
        return '📋 Election has Not Started';
    }
  }

  Future<void> _updateStatus(String newStatus, String msg, Color color) async {
    try {
      await supabase.from('election_status').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', 1);

      await _fetchElectionData();
      _showSnack(msg, color);
    } catch (e) {
      _showSnack("Error: ${e.toString()}", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.pink.shade100;
    final bool isActive = rawStatus == "active";
    final bool isPaused = rawStatus == "paused";

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗳️ Control Election'),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "College General Elections 2025",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "📅 20th June 2025 • 🕒 9:00 AM - 5:00 PM",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isActive ? Colors.green : Colors.red,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive ? Icons.check_circle : Icons.pause_circle,
                              color: isActive ? Colors.green : Colors.red,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Control Buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Start Election"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: !isActive ? () => _updateStatus("active", "✅ Election started!", Colors.green) : null,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.pause),
                            label: const Text("Pause Election"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: isActive ? () => _updateStatus("paused", "⏸️ Election paused", Colors.orange) : null,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.stop),
                            label: const Text("End Election"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: (isActive || isPaused)
                                ? () => _updateStatus("ended", "🛑 Election ended", Colors.red)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Divider(thickness: 1),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "📊 Election Summary",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text("Registered Voters: $totalUsers"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.how_to_vote, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text("Candidates Participating: $totalCandidates"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.av_timer, color: Colors.teal),
                          SizedBox(width: 8),
                          Text("Estimated Voting Time: ~2 mins/user"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
