from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class UserPermissionsTests(APITestCase):
    def test_me_requires_authentication(self):
        url = reverse("me")
        res = self.client.get(url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

