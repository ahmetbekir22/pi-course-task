from django.contrib.auth import get_user_model
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

    def create(self, validated_data):
        user = self.context["request"].user
        validated_data["student"] = user
        return super().create(validated_data)


class LessonRequestUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = LessonRequest
        fields = ["status"]

    def validate_status(self, value: str) -> str:
        if value not in (LessonRequest.Status.APPROVED, LessonRequest.Status.REJECTED):
            raise serializers.ValidationError("status must be approved or rejected")
        return value

