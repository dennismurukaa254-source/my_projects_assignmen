class FamilyMember {
  final String id;
  final String fullName;
  final String? gender;       // "Male" or "Female"
  final String? photoUrl;
  final String? phone;
  final String? email;
  final String? branch;
  final String? location;
  final String? occupation;
  final String? biography;
  final String? parentId;
  final List<String>? childrenIds;

  FamilyMember({
    required this.id,
    required this.fullName,
    this.gender,
    this.photoUrl,
    this.phone,
    this.email,
    this.branch,
    this.location,
    this.occupation,
    this.biography,
    this.parentId,
    this.childrenIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'gender': gender,
      'photoUrl': photoUrl,
      'phone': phone,
      'email': email,
      'branch': branch,
      'location': location,
      'occupation': occupation,
      'biography': biography,
      'parentId': parentId,
      'childrenIds': childrenIds,
    };
  }

  factory FamilyMember.fromMap(String id, Map<String, dynamic> map) {
    return FamilyMember(
      id: id,
      fullName: map['fullName'] ?? '',
      gender: map['gender'],
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      email: map['email'],
      branch: map['branch'],
      location: map['location'],
      occupation: map['occupation'],
      biography: map['biography'],
      parentId: map['parentId'],
      childrenIds: map['childrenIds'] != null ? List<String>.from(map['childrenIds']) : null,
    );
  }
}