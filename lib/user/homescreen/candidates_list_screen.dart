
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:votex/user/homescreen/candidate.dart';

class CandidatesListScreen extends StatefulWidget {
  const CandidatesListScreen({super.key});

  @override
  State<CandidatesListScreen> createState() => _CandidatesListScreenState();
}

class _CandidatesListScreenState extends State<CandidatesListScreen>
    with SingleTickerProviderStateMixin {
  List<Candidate> candidates = [];
  bool isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    fetchApprovedCandidates();
  }

  Future<void> fetchApprovedCandidates() async {
    try {
      final response = await Supabase.instance.client
          .from('candidates')
          .select()
          .eq('is_verified', true);

      final List<dynamic> dataList = response as List<dynamic>;

      final List<Candidate> data = dataList
          .map((e) => Candidate.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      setState(() {
        candidates = data;
        isLoading = false;
        _controller.forward();
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load candidates: $e')),
        );
      }
    }
  }

  Widget buildCandidateCard(Candidate candidate, int index) {
    final animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: _controller,
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: candidate.image.startsWith('http')
                          ? Image.network(
                              candidate.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 80),
                            )
                          : Image.asset(
                              candidate.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(candidate.party,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 4),
                          if (candidate.gsPost)
                            const Text('Post: General Secretary',
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w500)),
                          if (candidate.deputyGsPost)
                            const Text('Post: Deputy General Secretary',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 199, 67, 202),
                                    fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text("Age: ${candidate.age}"),
                    const SizedBox(width: 16),
                    // const Icon(Icons.badge, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(candidate.designation),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(candidate.email)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(candidate.phone),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '📜 Manifesto:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(candidate.manifesto),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗳️ Approved Candidates'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 226, 100, 215),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : candidates.isEmpty
              ? const Center(
                  child: Text('😕 No approved candidates available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    return buildCandidateCard(candidates[index], index);
                  },
                ),
    );
  }
}
