from typing import Any

from django.contrib.auth import get_user_model
from rest_framework import serializers

from .models import StudentProfile, TutorProfile

User = get_user_model()


class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentProfile
        fields = ["grade_level"]


class TutorProfileSerializer(serializers.ModelSerializer):
    subjects = serializers.SerializerMethodField()

    class Meta:
        model = TutorProfile
        fields = ["bio", "hourly_rate", "rating", "subjects"]
        read_only_fields = ["rating"]

    def get_subjects(self, obj: TutorProfile) -> list[dict[str, Any]]:
        return [{"id": s.id, "name": s.name} for s in obj.subjects.all()]


class UserSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()
    role = serializers.CharField(read_only=True)
    tutor_profile = TutorProfileSerializer(read_only=True)
    student_profile = StudentProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "name",
            "first_name",
            "last_name",
            "role",
            "tutor_profile",
            "student_profile",
        ]

    def get_name(self, obj: User) -> str:
        full_name = (obj.first_name or "").strip() + " " + (obj.last_name or "").strip()
        return full_name.strip() or obj.email


class RegisterSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    role = serializers.ChoiceField(choices=[("student", "student"), ("tutor", "tutor")])
    first_name = serializers.CharField(required=False, allow_blank=True)
    last_name = serializers.CharField(required=False, allow_blank=True)

    def validate_email(self, value: str) -> str:
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("Email already registered")
        return value

    def create(self, validated_data: dict[str, Any]) -> User:
        role = validated_data.pop("role")
        password = validated_data.pop("password")
        user = User(**validated_data, role=role)
        user.set_password(password)
        user.save()
        # Profiles are created by post_save signal; no explicit create here
        return user


class MeUpdateSerializer(serializers.Serializer):
    # Student
    grade_level = serializers.CharField(required=False, allow_blank=True)
    # Tutor
    bio = serializers.CharField(required=False, allow_blank=True)
    hourly_rate = serializers.IntegerField(required=False)

    def validate_hourly_rate(self, value: int) -> int:
        if value is not None and value < 0:
            raise serializers.ValidationError("hourly_rate must be >= 0")
        return value

    def save(self, **kwargs: Any) -> User:
        user: User = self.context["request"].user
        if user.role == "student":
            profile = user.student_profile
            if "grade_level" in self.validated_data:
                profile.grade_level = self.validated_data["grade_level"]
            profile.save()
        elif user.role == "tutor":
            profile = user.tutor_profile
            if "bio" in self.validated_data:
                profile.bio = self.validated_data["bio"]
            if "hourly_rate" in self.validated_data:
                profile.hourly_rate = self.validated_data["hourly_rate"]
            profile.save()
        return user


class TutorListSerializer(serializers.ModelSerializer):
    id = serializers.SerializerMethodField()
    name = serializers.SerializerMethodField()
    subjects = serializers.SerializerMethodField()

    class Meta:
        model = TutorProfile
        fields = ["id", "name", "subjects", "hourly_rate", "rating", "bio"]

    def get_id(self, obj: TutorProfile) -> int:
        return obj.user.id

    def get_name(self, obj: TutorProfile) -> str:
        full_name = (obj.user.first_name or "").strip() + " " + (obj.user.last_name or "").strip()
        return full_name.strip() or obj.user.email

    def get_subjects(self, obj: TutorProfile) -> list[dict[str, Any]]:
        return [{"id": s.id, "name": s.name} for s in obj.subjects.all()]

