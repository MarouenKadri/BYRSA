class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? address;
  final String userType; // 'client' or 'freelancer'
  final double? hourlyRate;
  final bool isVerified;
  final List<String> serviceCategories; // e.g. ['plomberie', 'jardinage']

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.address,
    required this.userType,
    this.hourlyRate,
    this.isVerified = false,
    this.serviceCategories = const [],
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isFreelancer => userType == 'freelancer';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        address: json['address'] as String?,
        userType: json['user_type'] as String? ?? 'client',
        hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
        isVerified: json['is_verified'] as bool? ?? false,
        serviceCategories: List<String>.from(json['service_categories'] as List? ?? []),
      );

  Map<String, dynamic> toUpdateJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'bio': bio,
        'address': address,
        if (hourlyRate != null) 'hourly_rate': hourlyRate,
      };

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? address,
    double? hourlyRate,
    List<String>? serviceCategories,
  }) =>
      UserProfile(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        address: address ?? this.address,
        userType: userType,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        isVerified: isVerified,
        serviceCategories: serviceCategories ?? this.serviceCategories,
      );
}
