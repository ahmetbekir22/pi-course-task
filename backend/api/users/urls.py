from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import MeView, RegisterView, TutorDetailView, TutorListView


urlpatterns = [
    path("auth/register", RegisterView.as_view(), name="register"),
    path("auth/login", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("auth/refresh", TokenRefreshView.as_view(), name="token_refresh"),
    path("me", MeView.as_view(), name="me"),
    path("tutors", TutorListView.as_view(), name="tutor-list"),
    path("tutors/<int:user_id>", TutorDetailView.as_view(), name="tutor-detail"),
]

