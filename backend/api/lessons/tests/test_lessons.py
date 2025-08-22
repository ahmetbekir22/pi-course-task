from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from subjects.models import Subject


User = get_user_model()


class LessonRequestFlowTests(APITestCase):
    def setUp(self):
        self.math = Subject.objects.create(name="Math")
        self.tutor = User.objects.create_user(
            email="tutor@example.com", password="Passw0rd!", role="tutor", first_name="Tu", last_name="Tor"
        )
        self.tutor.tutor_profile.subjects.add(self.math)
        self.student = User.objects.create_user(
            email="student@example.com", password="Passw0rd!", role="student", first_name="Stu", last_name="Dent"
        )

    def auth(self, email, password):
        url = reverse("token_obtain_pair")
        res = self.client.post(url, {"email": email, "password": password}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {res.data['access']}")

    def test_student_create_and_tutor_approve(self):
        # student creates
        self.auth("student@example.com", "Passw0rd!")
        create_url = reverse("lesson-request-list-create")
        payload = {
            "tutor_id": self.tutor.id,
            "subject_id": self.math.id,
            "start_time": "2025-12-25T10:00:00Z",
            "duration_minutes": 60,
            "note": "Test lesson",
        }
        res = self.client.post(create_url, payload, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        req_id = res.data["id"]

        # tutor approves
        self.auth("tutor@example.com", "Passw0rd!")
        update_url = reverse("lesson-request-update", kwargs={"pk": req_id})
        res = self.client.patch(update_url, {"status": "approved"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data["status"], "approved")

