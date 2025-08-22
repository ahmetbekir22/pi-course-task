from django.contrib.auth import get_user_model
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.generics import GenericAPIView
from rest_framework_simplejwt.views import TokenObtainPairView
from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiParameter, OpenApiTypes

from .serializers import (
    MeUpdateSerializer,
    RegisterSerializer,
    TutorListSerializer,
    UserSerializer,
)
from .models import TutorProfile

User = get_user_model()


@extend_schema(
    summary="Kayıt ol",
    description="Yeni kullanıcı kaydı. Gövde: email, password, role (student|tutor), opsiyonel first_name, last_name.",
)
class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class MeView(GenericAPIView):
    serializer_class = UserSerializer
    @extend_schema(summary="Profilimi getir", responses=UserSerializer)
    def get(self, request):
        return Response(UserSerializer(request.user).data)

    @extend_schema(summary="Profilimi güncelle", request=MeUpdateSerializer, responses=UserSerializer)
    def patch(self, request):
        serializer = MeUpdateSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(UserSerializer(user).data)


@extend_schema(
    summary="Eğitmen listesi",
    description="Filtre/arama/sıralama ile eğitmenleri listeleyin.",
    parameters=[
        OpenApiParameter(name="subject", type=OpenApiTypes.INT, description="Subject id ile filtre"),
        OpenApiParameter(name="search", type=OpenApiTypes.STR, description="Ad veya bio içinde arama"),
        OpenApiParameter(name="ordering", type=OpenApiTypes.STR, description="Sıralama: rating veya -rating, hourly_rate veya -hourly_rate"),
    ],
)
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


@extend_schema(summary="Eğitmen detayı")
class TutorDetailView(generics.RetrieveAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.AllowAny]

    def get_object(self):
        user_id = self.kwargs.get("id")
        return User.objects.select_related("tutor_profile", "student_profile").prefetch_related("tutor_profile__subjects").get(id=user_id, role="tutor")

from django.shortcuts import render

# Create your views here.
