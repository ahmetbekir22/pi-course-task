import 'package:json_annotation/json_annotation.dart';
import 'subject.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String role;
  final TutorProfile? tutorProfile;
  final StudentProfile? studentProfile;

  User({
    required this.id,
    required this.email,
    this.name,
    this.firstName,
    this.lastName,
    required this.role,
    this.tutorProfile,
    this.studentProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class TutorProfile {
  final String? bio;
  @JsonKey(name: 'hourly_rate')
  final int hourlyRate;
  final double? rating;
  final List<Subject> subjects;

  TutorProfile({
    this.bio,
    required this.hourlyRate,
    this.rating,
    required this.subjects,
  });

  factory TutorProfile.fromJson(Map<String, dynamic> json) => _$TutorProfileFromJson(json);
  Map<String, dynamic> toJson() => _$TutorProfileToJson(this);
}

@JsonSerializable()
class StudentProfile {
  @JsonKey(name: 'grade_level')
  final String? gradeLevel;

  StudentProfile({this.gradeLevel});

  factory StudentProfile.fromJson(Map<String, dynamic> json) => _$StudentProfileFromJson(json);
  Map<String, dynamic> toJson() => _$StudentProfileToJson(this);
} 