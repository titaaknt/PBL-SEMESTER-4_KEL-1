class UserModel {
  final String id;
  final String nim;
  final String nama;
  final String role;
  final String? email;
  final String? fotoUrl;

  UserModel({
    required this.id,
    required this.nim,
    required this.nama,
    required this.role,
    this.email,
    this.fotoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      nim: map['nim']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Mahasiswa',
      email: map['email']?.toString(),
      fotoUrl: map['foto_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nim': nim,
      'nama': nama,
      'role': role,
      'email': email,
      'foto_url': fotoUrl,
    };
  }
}
