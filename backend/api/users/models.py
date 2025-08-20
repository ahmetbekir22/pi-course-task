from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    class Roles(models.TextChoices):
        STUDENT = "student", "student"
        TUTOR = "tutor", "tutor"

    username = None
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=10, choices=Roles.choices)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    def __str__(self) -> str:
        return f"{self.email} ({self.role})"


class TutorProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="tutor_profile")
    bio = models.TextField(blank=True)
    hourly_rate = models.PositiveIntegerField(default=0)
    rating = models.DecimalField(max_digits=2, decimal_places=1, default=0)
    subjects = models.ManyToManyField("subjects.Subject", related_name="tutors", blank=True)

    def __str__(self) -> str:
        return f"TutorProfile<{self.user.email}>"


class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="student_profile")
    grade_level = models.CharField(max_length=50, blank=True)

    def __str__(self) -> str:
        return f"StudentProfile<{self.user.email}>"

# Create your models here.
