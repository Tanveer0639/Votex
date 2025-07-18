class Candidate {
  final String name;
  final String party;
  final String image;
  final bool isAsset;
  final bool gsPost;         // General Secretary post
  final bool deputyGsPost;   // Deputy General Secretary post

  Candidate({
    required this.name,
    required this.party,
    required this.image,
    required this.isAsset,
    this.gsPost = false,
    this.deputyGsPost = false,
  });
}

final List<Candidate> candidates = [
  Candidate(
    name: 'Rida Fatima',
    party: 'Reform Party',
    image: 'assets/girl.jpg',
    isAsset: true,
    gsPost: true,            // running for GS
  ),
  Candidate(
    name: 'Ravi Singh',
    party: 'Unity Party',
    image: 'assets/boy.jpg',
    isAsset: true,
    deputyGsPost: true,      // running for Deputy GS
  ),
  Candidate(
    name: 'Leela Patel',
    party: 'Progressive',
    image: 'assets/girl2.jpg',
    isAsset: true,
  ),
  Candidate(
    name: 'Arjun Mehta',
    party: 'Progressive',
    image: 'assets/boy2.jpg',
    isAsset: true,
    gsPost: true,
  ),
  Candidate(
    name: 'Fatima Shaikh',
    party: 'Unity Party',
    image: 'assets/girl3.jpg',
    isAsset: true,
    deputyGsPost: true,
  ),
  Candidate(
    name: 'Karan Malhotra',
    party: 'Reform Party',
    image: 'assets/boy3.jpg',
    isAsset: true,
  ),
  Candidate(
    name: 'Nisha Verma',
    party: 'Progressive',
    image: 'assets/girl4.jpg',
    isAsset: true,
  ),
];
