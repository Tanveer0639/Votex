class Candidate {
  final String id; 
  final String name;
  final String party;
  final String image;
  final bool isAsset;
  final bool gsPost;
  final bool deputyGsPost;

  final int age;
  final String email;
  final String phone;
  final String designation;
  final String manifesto;

  Candidate({
    required this.id,
    required this.name,
    required this.party,
    required this.image,
    required this.isAsset,
    this.gsPost = false,
    this.deputyGsPost = false,
    required this.age,
    required this.email,
    required this.phone,
    required this.designation,
    required this.manifesto,
  });

  factory Candidate.fromMap(Map<String, dynamic> map) {
    return Candidate(
      id: map['id']?.toString() ?? '',  // Always convert to String
      name: map['name']?.toString() ?? 'Unknown',
      party: map['party']?.toString() ?? 'Independent',
      image: map['profile_url']?.toString() ?? '',
      isAsset: false,
      gsPost: map['gs_post'] ?? false,
      deputyGsPost: map['deputy_gs_post'] ?? false,
      age: map['age'] is int
          ? map['age']
          : int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      email: map['email']?.toString() ?? 'N/A',
      phone: map['phone']?.toString() ?? 'N/A',
      designation: map['designation']?.toString() ?? 'N/A',
      manifesto: map['manifesto']?.toString() ?? '',
    );
  }
}
