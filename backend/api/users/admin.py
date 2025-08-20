from django.contrib import admin
from django.contrib.auth import get_user_model

from .models import StudentProfile, TutorProfile

User = get_user_model()


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("id", "email", "role", "first_name", "last_name")
    search_fields = ("email", "first_name", "last_name")
    list_filter = ("role",)


@admin.register(TutorProfile)
class TutorProfileAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "hourly_rate", "rating")
    search_fields = ("user__email", "user__first_name", "user__last_name")
    filter_horizontal = ("subjects",)


@admin.register(StudentProfile)
class StudentProfileAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "grade_level")

# Register your models here.
