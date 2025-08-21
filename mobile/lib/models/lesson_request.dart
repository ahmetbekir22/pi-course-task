import 'package:json_annotation/json_annotation.dart';

part 'lesson_request.g.dart';

@JsonSerializable()
class LessonRequest {
  final int id;
  final int student;
  final int tutor;
  final int subject;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  final String? note;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  LessonRequest({
    required this.id,
    required this.student,
    required this.tutor,
    required this.subject,
    required this.startTime,
    required this.durationMinutes,
    this.note,
    required this.status,
    required this.createdAt,
  });

  factory LessonRequest.fromJson(Map<String, dynamic> json) => _$LessonRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LessonRequestToJson(this);
}

@JsonSerializable()
class CreateLessonRequest {
  @JsonKey(name: 'tutor_id')
  final int tutorId;
  @JsonKey(name: 'subject_id')
  final int subjectId;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  final String? note;

  CreateLessonRequest({
    required this.tutorId,
    required this.subjectId,
    required this.startTime,
    required this.durationMinutes,
    this.note,
  });

  factory CreateLessonRequest.fromJson(Map<String, dynamic> json) => _$CreateLessonRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateLessonRequestToJson(this);
}

@JsonSerializable()
class UpdateLessonRequest {
  final String status;

  UpdateLessonRequest({required this.status});

  factory UpdateLessonRequest.fromJson(Map<String, dynamic> json) => _$UpdateLessonRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateLessonRequestToJson(this);
} 