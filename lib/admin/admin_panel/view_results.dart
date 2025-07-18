import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';

class AdminResultsScreen extends StatefulWidget {
  const AdminResultsScreen({super.key});

  @override
  State<AdminResultsScreen> createState() => _AdminResultsScreenState();
}

class _AdminResultsScreenState extends State<AdminResultsScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> voteData = [];
  bool loading = false;
  bool resultAnnounced = false;

  @override
  void initState() {
    super.initState();
    fetchVoteCounts();
    checkResultStatus();
  }

  Future<void> fetchVoteCounts() async {
    setState(() => loading = true);
    try {
      final response = await supabase.from('candidate_vote_counts').select();

      voteData = (response as List)
          .map((candidate) => {
                'id': candidate['candidate_id'],
                'name': candidate['candidate_name'],
                'party': candidate['party'],
                'designation': candidate['designation'],
                'vote_count': candidate['vote_count'],
              })
          .toList();

      voteData.sort((a, b) => b['vote_count'].compareTo(a['vote_count']));
      setState(() => loading = false);
    } catch (e) {
      print('❌ Error fetching vote counts: $e');
      setState(() => loading = false);
    }
  }

  Future<void> checkResultStatus() async {
    final response = await supabase.from('results').select().maybeSingle();
    if (response != null && response['result_announced'] == true) {
      setState(() => resultAnnounced = true);
    }
  }

  Future<void> announceWinnersViaRPC() async {
    try {
      final response = await supabase.rpc('announce_results');

      if (response != null && response is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ $response')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ No response from server.')),
        );
      }

      setState(() => resultAnnounced = true);
      fetchVoteCounts();
    } catch (e) {
      print('❌ RPC error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ RPC error: $e')),
      );
    }
  }

  Widget animatedCard(Map<String, dynamic> candidate, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.pink.shade100,
        color: Colors.pink.shade50,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: Colors.pinkAccent,
            child: Text(
              candidate['vote_count'].toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            candidate['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${candidate['party']}', style: const TextStyle(fontSize: 14)),
                Text('${candidate['designation']}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text("Admin Panel - Final Results"),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : voteData.isEmpty
              ? const Center(
                  child: Text(
                    "No vote data available.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : Column(
                  children: [
                    if (!resultAnnounced)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BounceInDown(
                          duration: const Duration(milliseconds: 600),
                          child: ElevatedButton.icon(
                            onPressed: announceWinnersViaRPC,
                            icon: const Icon(Icons.announcement, color: Colors.white),
                            label: const Text("📢 Announce Results"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.pink.shade200,
                              elevation: 10,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: voteData.length,
                        itemBuilder: (context, index) {
                          final candidate = voteData[index];
                          return animatedCard(candidate, index);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}