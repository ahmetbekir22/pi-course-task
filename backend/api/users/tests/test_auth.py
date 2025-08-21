from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


User = get_user_model()


class AuthFlowTests(APITestCase):
    def test_register_and_login_happy_path(self):
        register_url = reverse("register")
        login_url = reverse("token_obtain_pair")
        me_url = reverse("me")

        payload = {
            "email": "test_student@example.com",
            "password": "Passw0rd!",
            "role": "student",
            "first_name": "Test",
            "last_name": "Student",
        }
        res = self.client.post(register_url, payload, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        res = self.client.post(
            login_url, {"email": payload["email"], "password": payload["password"]}, format="json"
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn("access", res.data)

        # Authenticated me endpoint
        access = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")
        res = self.client.get(me_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data["email"], payload["email"])
        self.assertEqual(res.data["role"], payload["role"])

