from rest_framework import generics, permissions
from drf_spectacular.utils import extend_schema

from .models import Subject
from .serializers import SubjectSerializer


@extend_schema(summary="Konu listesi")
class SubjectListView(generics.ListAPIView):
    queryset = Subject.objects.all().order_by("name")
    serializer_class = SubjectSerializer
    permission_classes = [permissions.AllowAny]

from django.shortcuts import render

# Create your views here.
