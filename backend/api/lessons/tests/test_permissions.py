from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from subjects.models import Subject


User = get_user_model()


class LessonPermissionsTests(APITestCase):
    def setUp(self):
        self.math = Subject.objects.create(name="Math")
        self.tutor = User.objects.create_user(
            email="tutor@example.com", password="Passw0rd!", role="tutor"
        )
        self.student = User.objects.create_user(
            email="student@example.com", password="Passw0rd!", role="student"
        )

    def auth(self, email, password):
        login = reverse("token_obtain_pair")
        res = self.client.post(login, {"email": email, "password": password}, format="json")
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {res.data['access']}")

    def test_create_requires_student_role(self):
        url = reverse("lesson-request-list-create")
        payload = {
            "tutor_id": self.tutor.id,
            "subject_id": self.math.id,
            "start_time": "2025-08-21T10:00:00Z",
            "duration_minutes": 60,
        }
        # unauthenticated → 401
        res = self.client.post(url, payload, format="json")
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # tutor trying to create → 403
        self.auth("tutor@example.com", "Passw0rd!")
        res = self.client.post(url, payload, format="json")
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_update_requires_tutor_and_ownership(self):
        # create request as student
        create_url = reverse("lesson-request-list-create")
        self.auth("student@example.com", "Passw0rd!")
        res = self.client.post(
            create_url,
            {
                "tutor_id": self.tutor.id,
                "subject_id": self.math.id,
                "start_time": "2025-08-21T10:00:00Z",
                "duration_minutes": 60,
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        req_id = res.data["id"]

        update_url = reverse("lesson-request-update", kwargs={"pk": req_id})

        # student cannot update → 403
        res = self.client.patch(update_url, {"status": "approved"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

        # other tutor cannot update → 403
        other_tutor = User.objects.create_user(
            email="othertutor@example.com", password="Passw0rd!", role="tutor"
        )
        self.auth("othertutor@example.com", "Passw0rd!")
        res = self.client.patch(update_url, {"status": "approved"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

        # assigned tutor can update → 200
        self.auth("tutor@example.com", "Passw0rd!")
        res = self.client.patch(update_url, {"status": "approved"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

