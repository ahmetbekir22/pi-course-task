# Pi Course — Full-Stack MVP (Backend + Mobile)

A comprehensive MVP for a tutoring platform where students can discover tutors and create lesson requests. This repository contains both the Backend (Django/DRF) and Mobile (Flutter) applications.

## 🎯 Project Overview

Pi Course is a tutoring platform MVP that enables:
- **Students**: Discover tutors, filter by subjects, create lesson requests
- **Tutors**: Manage incoming requests, approve/reject lessons, set subjects and rates
- **Real-time**: JWT authentication, role-based permissions, responsive design

## 🏗️ Repository Structure

**Monorepo Structure:**
```
pi_course_task/
├── backend/          # Django/DRF API
│   ├── api/         # Django project
│   ├── requirements.txt
│   └── manage.py
└── mobile/          # Flutter app
    ├── lib/         # Source code
    ├── pubspec.yaml
    └── main.dart
```

## 🚀 Quick Start

### Backend Setup

#### **Prerequisites**
- **Python 3.8+** installed on your system
- **Git** for cloning the repository

#### **Setup Instructions**

**1. Clone the Repository**
```bash
git clone https://github.com/ahmetbekir22/pi-course-task.git
cd pi_course_task
```

**2. Backend Setup**

**macOS/Linux:**
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Windows (Command Prompt):**
```cmd
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

**Windows (PowerShell):**
```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

**3. Database Setup**
```bash
# Navigate to API directory
cd api

# Activate virtual environment (if not already activated)
# macOS/Linux: source ../.venv/bin/activate
# Windows: ..\\.venv\Scripts\activate

# Run migrations
python manage.py migrate

# Create demo data
python manage.py seed_demo

# Start development server
python manage.py runserver 8001
```

**4. API Documentation**
- **Swagger UI**: http://127.0.0.1:8001/api/docs/
- **OpenAPI Schema**: http://127.0.0.1:8001/api/schema/

### Mobile Setup

#### **Prerequisites**
- **Flutter SDK** (3.2.3+) installed
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)

#### **Setup Instructions**

**1. Install Dependencies**
```bash
cd mobile
flutter pub get
```

**2. Run the App**

**Android:**
```bash
# Ensure Android emulator is running or device is connected
flutter run --debug
```

**iOS (macOS only):**
```bash
# Ensure iOS simulator is running or device is connected
flutter run --debug
```

**3. Backend URL Configuration**
- **Default**: http://127.0.0.1:8001/api
- **Android Emulator**: http://10.0.2.2:8001/api
- **iOS Simulator**: http://127.0.0.1:8001/api

**Note**: If you're running the backend on a different port or IP, update the `baseUrl` in `mobile/lib/services/api_client.dart`

### Platform-Specific Notes

#### **macOS**
- ✅ Full support for both iOS and Android development
- ✅ Xcode required for iOS development
- ✅ Python virtual environment works natively

#### **Linux**
- ✅ Full support for Android development
- ❌ No iOS development support
- ✅ Python virtual environment works natively

#### **Windows**
- ✅ Full support for Android development
- ❌ No iOS development support
- ⚠️ Python virtual environment activation differs
- ⚠️ Use Command Prompt or PowerShell (not Git Bash for venv activation)

### Troubleshooting

#### **Common Issues**

**1. Virtual Environment Activation Fails**
- **Windows**: Ensure you're using Command Prompt or PowerShell, not Git Bash
- **Path Issues**: Use full path: `C:\path\to\project\.venv\Scripts\activate`

**2. Flutter Dependencies**
```bash
# Clear Flutter cache if needed
flutter clean
flutter pub get
```

**3. Backend Connection Issues**
- Check if backend server is running on port 8001
- Verify firewall settings
- For Android emulator, use 10.0.2.2 instead of 127.0.0.1

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

#### **Running Tests**

**macOS/Linux:**
```bash
cd backend/api
source ../.venv/bin/activate
python manage.py test --verbosity=2
```

**Windows (Command Prompt):**
```cmd
cd backend\api
..\\.venv\Scripts\activate
python manage.py test --verbosity=2
```

**Windows (PowerShell):**
```powershell
cd backend\api
..\\.venv\Scripts\Activate.ps1
python manage.py test --verbosity=2
```

#### **Expected Output:**
```bash
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
test_create_requires_student_role (lessons.tests.test_permissions.LessonPermissionsTests) ... ok
test_student_create_and_tutor_approve (lessons.tests.test_lessons.LessonRequestFlowTests) ... ok
test_update_requires_tutor_and_ownership (lessons.tests.test_permissions.LessonPermissionsTests) ... ok
test_register_and_login_happy_path (users.tests.test_auth.AuthFlowTests) ... ok

----------------------------------------------------------------------
Ran 4 tests in 1.234s

OK
Destroying test database for alias 'default'...
```

#### **Test Coverage:**
- ✅ Authentication flow (register, login, token refresh)
- ✅ Permission-based access control
- ✅ Lesson request creation and approval workflow
- ✅ Role-based API access restrictions
- ✅ Data validation and error handling

### Mobile Tests

#### **Running Tests**

**All Platforms:**
```bash
cd mobile
flutter test
```

**Expected Output:**
```bash
00:00 +0: loading /Users/.../mobile/test/widget_test.dart
00:00 +1: All tests passed!
```

## 👥 Demo Accounts

| Role | Email | Password | Description |
|------|-------|----------|-------------|
| Admin | admin@demo.com | AdminPass123! | Superuser access |
| Student | student1@demo.com | Passw0rd! | Can create lesson requests |
| Tutor | tutor1@demo.com | Passw0rd! | Can approve/reject requests |

**Note**: These accounts are created automatically when you run `python manage.py seed_demo`
