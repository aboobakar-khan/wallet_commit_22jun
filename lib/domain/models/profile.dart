class Profile {
  final String id;
  final String displayName;
  final String timezone;

  const Profile({
    required this.id,
    required this.displayName,
    required this.timezone,
  });

  Profile copyWith({String? displayName, String? timezone}) => Profile(
        id: id,
        displayName: displayName ?? this.displayName,
        timezone: timezone ?? this.timezone,
      );
}
