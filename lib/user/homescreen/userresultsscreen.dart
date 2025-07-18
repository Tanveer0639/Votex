import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserResultsScreen extends StatefulWidget {
  const UserResultsScreen({super.key});

  @override
  State<UserResultsScreen> createState() => _UserResultsScreenState();
}

class _UserResultsScreenState extends State<UserResultsScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List<Map<String, dynamic>> winners = [];

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final response = await supabase
          .from('results')
          .select('*, candidates(*)') // Join with candidates table
          .eq('result_announced', true)
          .order('created_at', ascending: false);

      setState(() {
        winners = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => loading = false);
    }
  }

  Widget resultCard(String title, String name) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.emoji_events, color: Colors.orange, size: 32),
        title: Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gsWinner = winners.firstWhere(
        (w) => w['designation'].toString().contains('General Secretary'),
        orElse: () => {});
    final dgsWinner = winners.firstWhere(
        (w) => w['designation'].toString().contains('Deputy'),
        orElse: () => {});

    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Election Results"),
        backgroundColor: const Color.fromARGB(255, 234, 154, 204),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : winners.isEmpty
              ? const Center(
                  child: Text(
                    "📢 Results are not yet announced.\nPlease check back later.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🎉 Final Winners",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 20),
                      if (gsWinner.isNotEmpty)
                        resultCard("General Secretary",
                            gsWinner['candidates']?['name'] ?? "N/A"),
                      if (dgsWinner.isNotEmpty)
                        resultCard("Deputy General Secretary",
                            dgsWinner['candidates']?['name'] ?? "N/A"),
                    ],
                  ),
                ),
    );
  }
}

