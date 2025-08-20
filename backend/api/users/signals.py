from django.contrib.auth import get_user_model
from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import StudentProfile, TutorProfile

User = get_user_model()


@receiver(post_save, sender=User)
def create_user_profiles(sender, instance: User, created: bool, **kwargs):
    if not created:
        return
    if instance.role == "student":
        StudentProfile.objects.get_or_create(user=instance)
    elif instance.role == "tutor":
        TutorProfile.objects.get_or_create(user=instance)

