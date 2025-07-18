// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:votex/user/homescreen/candidate.dart';

// class MyVoteScreen extends StatefulWidget {
//   const MyVoteScreen({super.key});

//   @override
//   _MyVoteScreenState createState() => _MyVoteScreenState();
// }

// class _MyVoteScreenState extends State<MyVoteScreen> {
//   List<Candidate> candidates = [];
//   bool isLoading = true;
//   String? votedCandidateId; // changed from int? to String?
//   String? currentUserId;
//   String electionStatus = 'loading';

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = Supabase.instance.client.auth.currentUser?.id;
//     fetchElectionStatusAndData();
//   }

//   Future<void> fetchElectionStatusAndData() async {
//     try {
//       final statusResponse = await Supabase.instance.client
//           .from('election_status')
//           .select('status')
//           .eq('id', 1)
//           .single();

//       electionStatus = statusResponse['status'];

//       if (electionStatus == 'active') {
//         await fetchData();
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching election status: $e')),
//         );
//       }
//     }
//   }

//   Future<bool> showVoteConfirmationDialog(BuildContext context) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             title: Row(
//               children: [
//                 Icon(Icons.how_to_vote,
//                     color: const Color.fromARGB(255, 224, 76, 234), size: 28),
//                 const SizedBox(width: 12),
//                 const Text('Confirm Your Vote',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//             content: const Text(
//               'Once you cast your vote, you won’t be able to change or revoke it.\n\nAre you sure you want to proceed?',
//               style: TextStyle(fontSize: 16),
//             ),
//             actionsPadding:
//                 const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.grey[700],
//                   textStyle:
//                       const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                       const Color.fromARGB(255, 68, 234, 110),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   textStyle: const TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.white),
//                 ),
//                 child: const Text('Vote'),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> fetchData() async {
//     try {
//       final candidatesResponse = await Supabase.instance.client
//           .from('candidates')
//           .select()
//           .eq('is_verified', true);

//       final List<dynamic> candidatesList =
//           candidatesResponse as List<dynamic>;

//       final loadedCandidates = candidatesList
//           .map((e) => Candidate.fromMap(Map<String, dynamic>.from(e)))
//           .toList();

//       final votesResponse = await Supabase.instance.client
//           .from('votes')
//           .select()
//           .eq('user_id', currentUserId!)
//           .maybeSingle();

//       setState(() {
//         candidates = loadedCandidates;
//         votedCandidateId =
//             votesResponse != null ? votesResponse['candidate_id'] : null;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading data: $e')),
//         );
//       }
//     }
//   }

//   Future<void> voteForCandidate(String candidateId) async {
//   if (votedCandidateId != null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('You have already voted!')),
//     );
//     return;
//   }

//   bool confirmed = await showVoteConfirmationDialog(context);
//   if (!confirmed) return;

//   try {
//     await Supabase.instance.client.from('votes').insert({
//       'user_id': currentUserId,
//       'candidate_id': candidateId, // pass String UUID directly here
//     });
//     setState(() {
//       votedCandidateId = candidateId;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Vote cast successfully!')),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to cast vote: $e')),
//     );
//   }
// }


//   Widget buildCandidateCard(Candidate candidate) {
//     final bool isVotedCandidate = candidate.id == votedCandidateId;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: candidate.image.startsWith('http')
//               ? NetworkImage(candidate.image)
//               : AssetImage(candidate.image) as ImageProvider,
//         ),
//         title: Text(candidate.name),
//         subtitle: Text(candidate.party),
//         trailing: votedCandidateId == null
//             ? ElevatedButton(
//                 onPressed: () => voteForCandidate(candidate.id.toString()),
//                 child: const Text('Vote'),
//               )
//             : isVotedCandidate
//                 ? const Text('Voted',
//                     style: TextStyle(
//                         color: Colors.green, fontWeight: FontWeight.bold))
//                 : const Text('Disabled'),
//       ),
//     );
//   }

//   Widget buildStatusMessage(String message) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Text(
//           message,
//           style: const TextStyle(fontSize: 18, color: Colors.grey),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Vote'),
//         backgroundColor: const Color.fromARGB(255, 223, 86, 220),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : (electionStatus == 'not_started')
//               ? buildStatusMessage('🕒 Election has not started yet.')
//               : (electionStatus == 'paused')
//                   ? buildStatusMessage('⏸️ Election is currently paused.')
//                   : (electionStatus == 'ended')
//                       ? buildStatusMessage('🛑 Election has ended.')
//                       : candidates.isEmpty
//                           ? const Center(
//                               child: Text('No approved candidates available.'))
//                           : ListView.builder(
//                               itemCount: candidates.length,
//                               itemBuilder: (context, index) {
//                                 return buildCandidateCard(
//                                     candidates[index]);
//                               },
//                             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:votex/user/homescreen/candidate.dart';

class MyVoteScreen extends StatefulWidget {
  const MyVoteScreen({super.key});

  @override
  _MyVoteScreenState createState() => _MyVoteScreenState();
}

class _MyVoteScreenState extends State<MyVoteScreen>
    with SingleTickerProviderStateMixin {
  List<Candidate> candidates = [];
  bool isLoading = true;
  String? votedCandidateId;
  String? currentUserId;
  String electionStatus = 'loading';
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fetchElectionStatusAndData();
  }

  Future<void> fetchElectionStatusAndData() async {
    try {
      final statusResponse = await Supabase.instance.client
          .from('election_status')
          .select('status')
          .eq('id', 1)
          .single();

      electionStatus = statusResponse['status'];

      if (electionStatus == 'active') {
        await fetchData();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching election status: $e')),
        );
      }
    }
  }

  Future<void> fetchData() async {
    try {
      final candidatesResponse = await Supabase.instance.client
          .from('candidates')
          .select()
          .eq('is_verified', true);

      final loadedCandidates = (candidatesResponse as List<dynamic>)
          .map((e) => Candidate.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      final votesResponse = await Supabase.instance.client
          .from('votes')
          .select()
          .eq('user_id', currentUserId!)
          .maybeSingle();

      setState(() {
        candidates = loadedCandidates;
        votedCandidateId =
            votesResponse != null ? votesResponse['candidate_id'] : null;
        isLoading = false;
        _controller.forward();
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<bool> showVoteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.how_to_vote,
                    color: Colors.purple[300], size: 28),
                const SizedBox(width: 12),
                const Text('Confirm Your Vote',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Once you cast your vote, you won’t be able to change or revoke it.\n\nAre you sure you want to proceed?',
              style: TextStyle(fontSize: 16),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400]),
                child: const Text('Vote'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> voteForCandidate(String candidateId) async {
    if (votedCandidateId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already voted!')),
      );
      return;
    }

    bool confirmed = await showVoteConfirmationDialog(context);
    if (!confirmed) return;

    try {
      await Supabase.instance.client.from('votes').insert({
        'user_id': currentUserId,
        'candidate_id': candidateId,
      });

      setState(() {
        votedCandidateId = candidateId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Vote cast successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cast vote: $e')),
      );
    }
  }

  Widget buildCandidateCard(Candidate candidate, int index) {
    final isVoted = candidate.id == votedCandidateId;
    final animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1 * index, 0.7 + 0.1 * index, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: animation,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: candidate.image.startsWith('http')
                    ? NetworkImage(candidate.image)
                    : AssetImage(candidate.image) as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidate.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(candidate.party,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 6),
                    if (candidate.gsPost)
                      const Text('Post: General Secretary',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500)),
                    if (candidate.deputyGsPost)
                      const Text('Post: Deputy General Secretary',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              votedCandidateId == null
                  ? ElevatedButton(
                      onPressed: () =>
                          voteForCandidate(candidate.id.toString()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent),
                      child: const Text('Vote'))
                  : isVoted
                      ? const Text('✔️ Voted',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold))
                      : const Text('—', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatusMessage(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗳️ My Vote'),
        backgroundColor: const Color.fromARGB(255, 223, 86, 220),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (electionStatus == 'not_started')
              ? buildStatusMessage(
                  '🕒 Election has not started yet.', Icons.access_time)
              : (electionStatus == 'paused')
                  ? buildStatusMessage(
                      '⏸️ Election is currently paused.', Icons.pause_circle)
                  : (electionStatus == 'ended')
                      ? buildStatusMessage('🛑 Election has ended.',
                          Icons.block_flipped)
                      : candidates.isEmpty
                          ? buildStatusMessage('No candidates available.',
                              Icons.people_alt_outlined)
                          : ListView.builder(
                              itemCount: candidates.length,
                              itemBuilder: (context, index) {
                                return buildCandidateCard(
                                    candidates[index], index);
                              },
                            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
