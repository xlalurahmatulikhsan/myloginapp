class Profile {
  final String username;
  final String email;
  final String nama;
  final String alamat;
  final String kelamin;
  final String nohp;
  final String photo;

  const Profile({
    required this.username,
    required this.email,
    required this.nama,
    required this.alamat,
    required this.kelamin,
    required this.nohp,
    required this.photo,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    print("JSON");
    print(json);
    return switch (json) {
      {
        'username': String? username,
        'email': String? email,
        'nama_lengkap': String? nama,
        'alamat': String? alamat,
        'jenis_kelamin': String? kelamin,
        'nohp': String? nohp,
        'photo': String? photo,
      } =>
        Profile(
          username: username ?? '',
          email: email ?? '',
          nama: nama ?? '',
          alamat: alamat ?? '',
          kelamin: kelamin ?? '',
          nohp: nohp ?? '',
          photo: photo ?? 'default.jpg',
        ),
      _ => throw const FormatException('Failed to load user profile.'),
    };
  }
}
