# Pi Course — Full-Stack MVP (Backend + Mobile)

A comprehensive MVP for a tutoring platform where students can discover tutors and create lesson requests. This repository contains both the Backend (Django/DRF) and Mobile (Flutter) applications.

## 🎯 Project Overview

Pi Course is a tutoring platform MVP that enables:
- **Students**: Discover tutors, filter by subjects, create lesson requests
- **Tutors**: Manage incoming requests, approve/reject lessons, set subjects and rates
- **Real-time**: JWT authentication, role-based permissions, responsive design

## 🏗️ Architecture & Technology Choices

### Backend (Django/DRF)

#### **Why Django & DRF?**
- **Rapid Development**: Django's "batteries-included" approach speeds up MVP development
- **Admin Interface**: Built-in admin panel for data management and debugging
- **Security**: Django's security features (CSRF, SQL injection protection, XSS prevention)
- **Scalability**: Django's ORM and caching capabilities support future growth
- **Community**: Extensive documentation and community support

#### **Key Technologies:**
- **Django 5.0.7**: Web framework with built-in admin and ORM
- **Django REST Framework**: Powerful API framework with serializers, viewsets, and permissions
- **drf-simplejwt**: JWT authentication with access/refresh token flow
- **drf-spectacular**: Automatic OpenAPI/Swagger documentation generation
- **django-filter**: Advanced filtering capabilities for API endpoints
- **PostgreSQL/SQLite**: Database (SQLite for development, PostgreSQL for production)

#### **Architecture Patterns:**
- **Generic Views**: `ListCreateAPIView`, `RetrieveAPIView` for consistent API patterns
- **Custom Permissions**: Role-based access control (`IsStudent`, `IsTutor`)
- **Serializer Method Fields**: Custom data transformation and nested serialization
- **Query Optimization**: `select_related` and `prefetch_related` for efficient database queries

### Mobile (Flutter)

#### **Why Flutter?**
- **Cross-Platform**: Single codebase for iOS and Android
- **Performance**: Native compilation for smooth 60fps animations
- **Hot Reload**: Rapid development and testing cycles
- **Rich Ecosystem**: Extensive package ecosystem and community support
- **Material Design**: Built-in Material Design components

#### **Why Riverpod?**
- **Type Safety**: Compile-time safety for state management
- **Provider Pattern**: Clean dependency injection and state management
- **Performance**: Efficient rebuilds and memory management
- **Testing**: Easy to test and mock providers
- **Future-Proof**: Modern alternative to Provider with better architecture

#### **Key Technologies:**
- **Flutter 3.x**: Cross-platform UI framework
- **Riverpod**: State management with dependency injection
- **Dio**: HTTP client with interceptors for authentication
- **flutter_secure_storage**: Secure token storage
- **json_serializable**: Type-safe JSON serialization
- **intl**: Internationalization and date formatting

#### **Architecture Patterns:**
- **StateNotifier Pattern**: Immutable state management with proper error handling
- **Provider Pattern**: Dependency injection and state sharing
- **Repository Pattern**: Clean separation between data and business logic
- **Responsive Design**: Dynamic sizing based on screen dimensions

## 📱 Features

### Core Functionality
- ✅ **Authentication**: JWT-based login/register with role selection
- ✅ **Tutor Discovery**: Filter by subjects, search by name/bio, sort by rating/price
- ✅ **Lesson Requests**: Create, view, approve/reject lesson requests
- ✅ **Profile Management**: Edit student grade level, tutor bio and hourly rate
- ✅ **Subject Management**: Tutors can select multiple subjects they teach

### Advanced Features
- ✅ **Role-Based Access**: Students create requests, tutors approve/reject
- ✅ **Real-time Validation**: Client-side validation with server-side verification
- ✅ **Responsive UI**: Dynamic sizing for different screen sizes
- ✅ **Error Handling**: User-friendly error messages and graceful degradation
- ✅ **Token Refresh**: Automatic JWT refresh with fallback to re-login

## 🚀 Quick Start

### Backend Setup

```bash
# Clone and setup
cd backend
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# Database and demo data
cd api
python manage.py migrate
python manage.py seed_demo  # Creates demo users and subjects
python manage.py runserver 8001

# API Documentation
# http://127.0.0.1:8001/api/docs/  (Swagger UI)
# http://127.0.0.1:8001/api/schema/ (OpenAPI Schema)
```

### Mobile Setup

```bash
# Setup and run
cd mobile
flutter pub get
flutter run --debug

# Backend URL Configuration
# Default: http://127.0.0.1:8001/api
# Android Emulator: http://10.0.2.2:8001/api (if needed)
```

### Demo Accounts

| Role | Email | Password | Description |
|------|-------|----------|-------------|
| Admin | admin@demo.com | AdminPass123! | Superuser access |
| Student | student1@demo.com | Passw0rd! | Can create lesson requests |
| Tutor | tutor1@demo.com | Passw0rd! | Can approve/reject requests |

## 🗄️ Data Models

### User Management
```python
# Custom User Model
class User(AbstractUser):
    email = models.EmailField(unique=True)  # Primary identifier
    role = models.CharField(choices=[('student', 'student'), ('tutor', 'tutor')])
    
# Profile Models
class TutorProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    bio = models.TextField(blank=True)
    hourly_rate = models.PositiveIntegerField(default=0)
    rating = models.DecimalField(max_digits=2, decimal_places=1, default=0)
    subjects = models.ManyToManyField('subjects.Subject')

class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    grade_level = models.CharField(max_length=50, blank=True)
```

### Core Business Logic
```python
# Lesson Request Model
class LessonRequest(models.Model):
    student = models.ForeignKey(User, related_name='lesson_requests_sent')
    tutor = models.ForeignKey(User, related_name='lesson_requests_received')
    subject = models.ForeignKey('subjects.Subject', on_delete=models.PROTECT)
    start_time = models.DateTimeField()
    duration_minutes = models.PositiveIntegerField()
    note = models.TextField(blank=True, null=True)
    status = models.CharField(choices=[
        ('pending', 'pending'),
        ('approved', 'approved'),
        ('rejected', 'rejected')
    ], default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration with role selection
- `POST /api/auth/login` - JWT token authentication
- `POST /api/auth/refresh` - Token refresh endpoint

### User Management
- `GET /api/me` - Get current user profile
- `PATCH /api/me` - Update user profile (role-specific fields)

### Content
- `GET /api/subjects` - List available subjects
- `GET /api/tutors` - List tutors with filtering/searching/ordering
- `GET /api/tutors/{id}` - Get specific tutor details

### Lesson Requests
- `GET /api/lesson-requests?role=&status=` - List user's requests
- `POST /api/lesson-requests` - Create new lesson request (students only)
- `PATCH /api/lesson-requests/{id}` - Update request status (assigned tutor only)

## 🧪 Testing

### Backend Tests
```bash
cd backend/api
source ../.venv/bin/activate
python manage.py test --verbosity=2
```

**Test Coverage:**
-  Authentication flow (register, login, token refresh)
-  Permission-based access control
-  Lesson request creation and approval workflow
-  Role-based API access restrictions
-  Data validation and error handling

### Test Structure
```
backend/api/
├── users/tests/
│   ├── test_auth.py      # Authentication flow tests
│   └── test_permissions.py # Permission tests
└── lessons/tests/
    ├── test_lessons.py   # Business logic tests
    └── test_permissions.py # API permission tests
```

## 🔧 Configuration

### Environment Variables
```bash
# Backend (.env)
SECRET_KEY=your-secret-key
DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3  # or PostgreSQL URL

# Mobile (lib/services/api_client.dart)
static const String baseUrl = 'http://127.0.0.1:8001/api';
```

### Database Configuration
- **Development**: SQLite (file-based, no setup required)
- **Production**: PostgreSQL (recommended for scalability)

## 📊 Performance Optimizations

### Backend
- **Database Queries**: `select_related` and `prefetch_related` for efficient joins
- **Caching**: Django's caching framework for frequently accessed data
- **Pagination**: API responses are paginated for large datasets
- **Filtering**: Database-level filtering to reduce data transfer

### Mobile
- **State Management**: Riverpod's efficient rebuild system
- **Image Caching**: Automatic image caching and optimization
- **Network**: Dio's connection pooling and request optimization
- **Memory**: Proper disposal of controllers and listeners

## 🔒 Security Features

### Backend Security
- **JWT Authentication**: Secure token-based authentication
- **Role-Based Permissions**: Granular access control
- **Input Validation**: Comprehensive server-side validation
- **SQL Injection Protection**: Django ORM prevents SQL injection
- **XSS Protection**: Automatic content escaping
- **CSRF Protection**: Built-in CSRF token validation

### Mobile Security
- **Secure Storage**: JWT tokens stored in secure storage
- **Network Security**: HTTPS enforcement and certificate pinning
- **Input Validation**: Client-side validation with server verification
- **Token Refresh**: Automatic token refresh with secure fallback

## 🎨 UI/UX Design

### Design Principles
- **Material Design**: Consistent with Google's Material Design guidelines
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Accessibility**: Proper contrast ratios and touch targets
- **User Feedback**: Loading states, error messages, and success confirmations

### Key UI Components
- **Dynamic Sizing**: All UI elements scale based on screen dimensions
- **Error Handling**: User-friendly error messages with retry options
- **Loading States**: Skeleton screens and progress indicators
- **Form Validation**: Real-time validation with visual feedback

## 🚀 Deployment

### Backend Deployment
```bash
# Production setup
pip install -r requirements.txt
python manage.py collectstatic
python manage.py migrate
gunicorn api.wsgi:application --bind 0.0.0.0:8000
```

### Mobile Deployment
```bash
# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```


### Scalability Considerations
- **Microservices**: Break down into smaller, focused services
- **Caching Layer**: Redis for session and data caching
- **Load Balancing**: Multiple server instances with load balancing
- **CDN**: Content delivery network for static assets
- **Database Sharding**: Horizontal scaling for database
