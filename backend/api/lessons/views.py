from django.contrib.auth import get_user_model
from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied

from .models import LessonRequest
from .serializers import LessonRequestSerializer, LessonRequestUpdateSerializer

User = get_user_model()


class IsStudent(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "student"


class IsTutor(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "tutor"


class LessonRequestListCreateView(generics.ListCreateAPIView):
    serializer_class = LessonRequestSerializer

    def get_permissions(self):
        if self.request.method == "POST":
            return [IsStudent()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
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


class LessonRequestUpdateView(generics.UpdateAPIView):
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
