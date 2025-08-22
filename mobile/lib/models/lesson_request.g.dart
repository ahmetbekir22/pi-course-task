// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonRequest _$LessonRequestFromJson(Map<String, dynamic> json) =>
    LessonRequest(
      id: (json['id'] as num).toInt(),
      student: (json['student'] as num?)?.toInt(),
      tutor: (json['tutor'] as num?)?.toInt(),
      subject: (json['subject'] as num?)?.toInt(),
      startTime: DateTime.parse(json['start_time'] as String),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      note: json['note'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LessonRequestToJson(LessonRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'tutor': instance.tutor,
      'subject': instance.subject,
      'start_time': instance.startTime.toIso8601String(),
      'duration_minutes': instance.durationMinutes,
      'note': instance.note,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };

CreateLessonRequest _$CreateLessonRequestFromJson(Map<String, dynamic> json) =>
    CreateLessonRequest(
      tutorId: (json['tutor_id'] as num).toInt(),
      subjectId: (json['subject_id'] as num).toInt(),
      startTime: DateTime.parse(json['start_time'] as String),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CreateLessonRequestToJson(
        CreateLessonRequest instance) =>
    <String, dynamic>{
      'tutor_id': instance.tutorId,
      'subject_id': instance.subjectId,
      'start_time': CreateLessonRequest._dateTimeToJson(instance.startTime),
      'duration_minutes': instance.durationMinutes,
      'note': instance.note,
    };

UpdateLessonRequest _$UpdateLessonRequestFromJson(Map<String, dynamic> json) =>
    UpdateLessonRequest(
      status: json['status'] as String,
    );

Map<String, dynamic> _$UpdateLessonRequestToJson(
        UpdateLessonRequest instance) =>
    <String, dynamic>{
      'status': instance.status,
    };
