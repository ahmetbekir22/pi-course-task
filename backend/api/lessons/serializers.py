from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import serializers

from .models import LessonRequest
from subjects.models import Subject

User = get_user_model()


class LessonRequestSerializer(serializers.ModelSerializer):
    tutor_id = serializers.PrimaryKeyRelatedField(
        source="tutor", queryset=User.objects.all(), write_only=True
    )
    subject_id = serializers.PrimaryKeyRelatedField(source="subject", queryset=Subject.objects.all(), write_only=True)
    status = serializers.CharField(read_only=True)
    note = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    class Meta:
        model = LessonRequest
        fields = [
            "id",
            "tutor_id",
            "subject_id",
            "start_time",
            "duration_minutes",
            "note",
            "status",
            "created_at",
        ]
        read_only_fields = ["status", "created_at"]

    def validate(self, attrs):
        print(f"Validating lesson request data: {attrs}")
        try:
            # Check if tutor exists and is a tutor
            tutor = attrs.get('tutor')
            print(f"Tutor: {tutor}")
            if tutor:
                print(f"Tutor role: {tutor.role}")
                if tutor.role != 'tutor':
                    raise serializers.ValidationError("Selected user is not a tutor")
            
            # Check if subject exists
            subject = attrs.get('subject')
            print(f"Subject: {subject}")
            if not subject:
                raise serializers.ValidationError("Subject is required")
            
            # Check if start_time is in the future
            start_time = attrs.get('start_time')
            print(f"Start time: {start_time}")
            print(f"Current time: {timezone.now()}")
            if start_time:
                if start_time <= timezone.now():
                    raise serializers.ValidationError("Start time must be in the future")
            
            print("Validation passed successfully")
            return attrs
        except Exception as e:
            print(f"Validation error: {e}")
            print(f"Error type: {type(e)}")
            raise

    def to_internal_value(self, data):
        print(f"to_internal_value called with data: {data}")
        try:
            return super().to_internal_value(data)
        except Exception as e:
            print(f"to_internal_value error: {e}")
            raise

    def create(self, validated_data):
        user = self.context["request"].user
        validated_data["student"] = user
        print(f"Creating lesson request with data: {validated_data}")
        return super().create(validated_data)


class LessonRequestUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = LessonRequest
        fields = ["status"]

    def validate_status(self, value: str) -> str:
        if value not in (LessonRequest.Status.APPROVED, LessonRequest.Status.REJECTED):
            raise serializers.ValidationError("status must be approved or rejected")
        return value

