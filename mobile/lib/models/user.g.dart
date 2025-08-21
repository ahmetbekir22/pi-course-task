// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      name: json['name'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] as String,
      tutorProfile: json['tutorProfile'] == null
          ? null
          : TutorProfile.fromJson(json['tutorProfile'] as Map<String, dynamic>),
      studentProfile: json['studentProfile'] == null
          ? null
          : StudentProfile.fromJson(
              json['studentProfile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'tutorProfile': instance.tutorProfile,
      'studentProfile': instance.studentProfile,
    };

TutorProfile _$TutorProfileFromJson(Map<String, dynamic> json) => TutorProfile(
      bio: json['bio'] as String?,
      hourlyRate: (json['hourly_rate'] as num).toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      subjects: (json['subjects'] as List<dynamic>)
          .map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TutorProfileToJson(TutorProfile instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'hourly_rate': instance.hourlyRate,
      'rating': instance.rating,
      'subjects': instance.subjects,
    };

StudentProfile _$StudentProfileFromJson(Map<String, dynamic> json) =>
    StudentProfile(
      gradeLevel: json['grade_level'] as String?,
    );

Map<String, dynamic> _$StudentProfileToJson(StudentProfile instance) =>
    <String, dynamic>{
      'grade_level': instance.gradeLevel,
    };
