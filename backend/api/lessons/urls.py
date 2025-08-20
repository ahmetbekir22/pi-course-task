from django.urls import path

from .views import LessonRequestListCreateView, LessonRequestUpdateView


urlpatterns = [
    path("lesson-requests", LessonRequestListCreateView.as_view(), name="lesson-request-list-create"),
    path("lesson-requests/<int:pk>", LessonRequestUpdateView.as_view(), name="lesson-request-update"),
]

