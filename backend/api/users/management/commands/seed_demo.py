from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

from subjects.models import Subject
from users.models import TutorProfile


class Command(BaseCommand):
    help = "Seed demo data: subjects, tutors, students, superuser"

    def handle(self, *args, **options):
        User = get_user_model()

        # Subjects
        subject_names = ["Matematik", "Fizik", "Kimya"]
        subjects = []
        for name in subject_names:
            subj, _ = Subject.objects.get_or_create(name=name)
            subjects.append(subj)
        self.stdout.write(self.style.SUCCESS(f"Subjects: {[s.name for s in subjects]}"))

        # Superuser
        if not User.objects.filter(is_superuser=True).exists():
            User.objects.create_superuser(
                email="admin@demo.com", password="AdminPass123!", first_name="Admin", last_name="User"
            )
            self.stdout.write(self.style.SUCCESS("Superuser created: admin@demo.com / AdminPass123!"))
        else:
            self.stdout.write("Superuser already exists")

        # Tutors
        tutor_data = [
            ("tutor1@demo.com", "Ayşe", "Demir", 500, 4.8, ["Matematik", "Fizik"]),
            ("tutor2@demo.com", "Mehmet", "Yıldız", 400, 4.5, ["Kimya"]),
        ]
        for email, first_name, last_name, rate, rating, subs in tutor_data:
            tutor, created = User.objects.get_or_create(
                email=email,
                defaults={
                    "first_name": first_name,
                    "last_name": last_name,
                    "role": "tutor",
                },
            )
            if created:
                tutor.set_password("Passw0rd!")
                tutor.save()
            profile = tutor.tutor_profile
            profile.hourly_rate = rate
            profile.rating = rating
            profile.bio = f"{first_name} {last_name} — Experienced tutor"
            profile.save()
            profile.subjects.set(Subject.objects.filter(name__in=subs))

        self.stdout.write(self.style.SUCCESS("Tutors ensured"))

        # Students
        student_data = [
            ("student1@demo.com", "Ali", "Kaya", "10th Grade"),
            ("student2@demo.com", "Zeynep", "Koç", "11th Grade"),
        ]
        for email, first_name, last_name, grade in student_data:
            student, created = User.objects.get_or_create(
                email=email,
                defaults={
                    "first_name": first_name,
                    "last_name": last_name,
                    "role": "student",
                },
            )
            if created:
                student.set_password("Passw0rd!")
                student.save()
            student.student_profile.grade_level = grade
            student.student_profile.save()

        self.stdout.write(self.style.SUCCESS("Students ensured"))
        self.stdout.write(self.style.SUCCESS("Seeding completed."))

