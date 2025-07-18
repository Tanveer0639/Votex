import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';
import 'dart:async';

class VerifyCandidates extends StatefulWidget {
  const VerifyCandidates({super.key});

  @override
  State<VerifyCandidates> createState() => _VerifyCandidatesState();
}

class _VerifyCandidatesState extends State<VerifyCandidates> {
  List<Map<String, dynamic>> candidates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUnverifiedCandidates();
  }

  Future<void> fetchUnverifiedCandidates() async {
    final stopwatch = Stopwatch()..start();
    setState(() => isLoading = true);

    try {
      final data = await Supabase.instance.client
          .from('candidates')
          .select('id, name, user_id, manifesto, profile_url')
          .eq('is_verified', false)
          .order('created_at', ascending: false)
          .limit(20);

      candidates = List<Map<String, dynamic>>.from(data);
    } catch (error) {
      log('❌ Error fetching candidates: $error');
      candidates = [];
    } finally {
      stopwatch.stop();
      log('⏱️ Load time: ${stopwatch.elapsedMilliseconds} ms');
      setState(() => isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

void _approveCandidate(int index) async {
  bool confirm = await _showConfirmationDialog(
    title: "Approve Candidate",
    content: "Are you sure you want to approve ${candidates[index]['name']}?",
    confirmText: "Approve",
    confirmColor: Colors.green,
  );

  if (!confirm) return;

  final candidate = candidates[index];
  final id = candidate['id'];
  final name = candidate['name'];
  final userId = candidate['user_id'];

  try {
    await Supabase.instance.client
        .from('candidates')
        .update({'is_verified': true})
        .eq('id', id)
        .select();

    await Supabase.instance.client
        .from('notifications')
        .insert({
          'user_id': userId,
          'title': '🎉 Selected as Candidate',
          'message': 'Congratulations $name, your application has been approved!',
          'created_at': DateTime.now().toIso8601String(),
        });

    if (!mounted) return;
    setState(() {
      candidates.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Approved $name')),
    );
  } catch (e) {
    log('❌ Error approving candidate: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: Could not approve candidate\n$e')),
    );
  }
}




 void _rejectCandidate(int index) async {
  bool confirm = await _showConfirmationDialog(
    title: "Reject Candidate",
    content: "Are you sure you want to reject ${candidates[index]['name']}?",
    confirmText: "Reject",
    confirmColor: Colors.red,
  );

  if (!confirm) return;

  final candidate = candidates[index];
  final id = candidate['id'];
  final name = candidate['name'];
  final userId = candidate['user_id'];

  try {
    await Supabase.instance.client
        .from('notifications')
        .insert({
          'user_id': userId,
          'title': '❌ Application Rejected',
          'message': 'Sorry $name, your application was not accepted.',
          'created_at': DateTime.now().toIso8601String(),
        });

    await Supabase.instance.client
        .from('candidates')
        .delete()
        .eq('id', id);

    if (!mounted) return;
    setState(() {
      candidates.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Rejected $name')),
    );
  } catch (e) {
    log('❌ Error rejecting candidate: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: Could not reject candidate\n$e')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Candidates"),
        centerTitle: true,
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.pink.shade300))
            : candidates.isEmpty
                ? Center(
                    child: Text(
                      "🎉 All candidates have been reviewed!",
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: CandidateCard(
                                name: candidate['name'],
                                manifesto: candidate['manifesto'],
                                imagePath: candidate['profile_url'] ?? '',
                                onApprove: () => _approveCandidate(index),
                                onReject: () => _rejectCandidate(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class CandidateCard extends StatelessWidget {
  final String name;
  final String manifesto;
  final String imagePath;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const CandidateCard({
    super.key,
    required this.name,
    required this.manifesto,
    required this.imagePath,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF1F1), Color(0xFFFFF9F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Hero(
              tag: name,
              child: CircleAvatar(
                radius: 35,
                backgroundImage: imagePath.startsWith("http")
                    ? NetworkImage(imagePath) as ImageProvider
                    : AssetImage(imagePath),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    manifesto,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text("Approve"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text("Reject"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
