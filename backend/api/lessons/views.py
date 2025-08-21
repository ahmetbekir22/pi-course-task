from django.contrib.auth import get_user_model
from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiTypes

from .models import LessonRequest
from .serializers import LessonRequestSerializer, LessonRequestUpdateSerializer

User = get_user_model()


class IsStudent(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "student"


class IsTutor(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "tutor"


@extend_schema(
    summary="Taleplerimi listele / talep oluştur",
    description="GET: role=student|tutor ve status filtreleriyle kendi taleplerini getir. POST: yalnızca öğrenci talep oluşturur.",
    parameters=[
        OpenApiParameter(name="role", type=OpenApiTypes.STR, description="Listeleme için: student veya tutor"),
        OpenApiParameter(name="status", type=OpenApiTypes.STR, description="pending|approved|rejected"),
    ],
)
class LessonRequestListCreateView(generics.ListCreateAPIView):
    serializer_class = LessonRequestSerializer

    def get_permissions(self):
        if self.request.method == "POST":
            return [IsStudent()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        if getattr(self, "swagger_fake_view", False):
            return LessonRequest.objects.none()
        user = self.request.user
        status_param = self.request.query_params.get("status")
        role_param = self.request.query_params.get("role")

        qs = LessonRequest.objects.select_related("student", "tutor", "subject")
        if role_param == "student":
            qs = qs.filter(student=user)
        else:
            qs = qs.filter(tutor=user)
        if status_param in (LessonRequest.Status.PENDING, LessonRequest.Status.APPROVED, LessonRequest.Status.REJECTED):
            qs = qs.filter(status=status_param)
        return qs


@extend_schema(summary="Talebi onayla/ret et", description="Yalnızca ilgili eğitmen PATCH ile approved|rejected yapabilir.")
class LessonRequestUpdateView(generics.UpdateAPIView):
    http_method_names = ["patch", "options", "head"]
    serializer_class = LessonRequestUpdateSerializer
    queryset = LessonRequest.objects.all()

    def get_permissions(self):
        return [IsTutor()]

    def perform_update(self, serializer):
        obj = self.get_object()
        if obj.tutor_id != self.request.user.id:
            raise PermissionDenied("Only the assigned tutor can update the request")
        serializer.save()

from django.shortcuts import render

# Create your views here.
