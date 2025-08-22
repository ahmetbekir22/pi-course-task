from django.db import models
from django.conf import settings


class LessonRequest(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "pending"
        APPROVED = "approved", "approved"
        REJECTED = "rejected", "rejected"

    student = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="lesson_requests_sent"
    )
    tutor = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="lesson_requests_received"
    )
    subject = models.ForeignKey("subjects.Subject", on_delete=models.PROTECT, related_name="lesson_requests")
    start_time = models.DateTimeField()
    duration_minutes = models.PositiveIntegerField()
    note = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.PENDING)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"LessonRequest<{self.student_id}->{self.tutor_id} {self.subject_id} {self.status}>"
