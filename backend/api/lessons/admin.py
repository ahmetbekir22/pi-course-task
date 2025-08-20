from django.contrib import admin

from .models import LessonRequest


@admin.register(LessonRequest)
class LessonRequestAdmin(admin.ModelAdmin):
    list_display = ("id", "student", "tutor", "subject", "status", "start_time", "duration_minutes")
    list_filter = ("status", "subject")
    search_fields = ("student__email", "tutor__email")

# Register your models here.
