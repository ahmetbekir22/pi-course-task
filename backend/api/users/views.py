from django.contrib.auth import get_user_model
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from .serializers import (
    MeUpdateSerializer,
    RegisterSerializer,
    TutorListSerializer,
    UserSerializer,
)
from .models import TutorProfile

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class MeView(APIView):
    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = MeUpdateSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(UserSerializer(user).data)


class TutorListView(generics.ListAPIView):
    serializer_class = TutorListSerializer
    permission_classes = [permissions.AllowAny]
    queryset = TutorProfile.objects.select_related("user").prefetch_related("subjects").all()
    filterset_fields = {"subjects": ["exact"]}
    search_fields = ["user__first_name", "user__last_name", "bio"]
    ordering_fields = ["rating", "hourly_rate"]
    ordering = ["-rating"]

    def get_queryset(self):
        qs = super().get_queryset()
        subject_id = self.request.query_params.get("subject")
        if subject_id:
            qs = qs.filter(subjects__id=subject_id)
        return qs


class TutorDetailView(generics.RetrieveAPIView):
    serializer_class = TutorListSerializer
    permission_classes = [permissions.AllowAny]

    def get_object(self):
        user_id = self.kwargs.get("user_id")
        return (
            TutorProfile.objects.select_related("user")
            .prefetch_related("subjects")
            .get(user__id=user_id)
        )

from django.shortcuts import render

# Create your views here.
