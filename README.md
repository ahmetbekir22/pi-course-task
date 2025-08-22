## Pi Course — Mini Full-Stack MVP (Backend + Mobile)

Pi Course is a small MVP where students can discover tutors and create lesson requests. This repository contains both the Backend (Django/DRF) and the Mobile (Flutter) app.

### Overview
- Backend (Django + DRF)
  - JWT authentication (drf-simplejwt)
  - Role-based permissions (student/tutor)
  - Tutor listing (filter/search/order)
  - Lesson request creation / listing / approve-reject
  - OpenAPI/Swagger documentation
  - Demo data seed command
  - Automated tests
- Mobile (Flutter)
  - Riverpod for state management
  - Dio HTTP client + token refresh
  - Secure Storage (JWT persistence)
  - Screens: Login/Register, Tutors List, Tutor Detail, Create Lesson Request, My Requests, Profile Edit

---

## 1) Backend

### Requirements
- Python 3.11+
- macOS/Linux/Windows

### Setup & Run
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt

cd api
python manage.py migrate
python manage.py seed_demo  # demo users, subjects, profiles
python manage.py runserver 8001
# http://127.0.0.1:8001/api/docs/  (Swagger)
```

### Demo Accounts
- Superuser: admin@demo.com / AdminPass123!
- Student:  student1@demo.com / Passw0rd!
- Tutor:    tutor1@demo.com   / Passw0rd!

### Models (Summary)
- `users.User`: email-based login, `role: student|tutor`
- `users.TutorProfile`: `bio`, `hourly_rate`, `rating`, `subjects (M2M)`
- `users.StudentProfile`: `grade_level`
- `subjects.Subject`: `name`
- `lessons.LessonRequest`: `student`, `tutor`, `subject`, `start_time`, `duration_minutes`, `note`, `status: pending|approved|rejected`, `created_at`

### API Endpoints (Summary)
- Auth: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/refresh`
- Profile: `GET /api/me`, `PATCH /api/me`
- Subjects: `GET /api/subjects`
- Tutors: `GET /api/tutors?subject=&ordering=&search=`, `GET /api/tutors/{user_id}`
- Requests: `GET/POST /api/lesson-requests?role=&status=`, `PATCH /api/lesson-requests/{id}`

### Technical Notes
- JWT (drf-simplejwt) access/refresh flow
- Role-based permissions: students create requests; only the assigned tutor can approve/reject
- Filter/Search/Ordering via django-filter, SearchFilter, OrderingFilter
- Query optimization with `select_related` and `prefetch_related`
- OpenAPI with drf-spectacular → `/api/schema/`, `/api/docs/`

### Tests
Tests are written using DRF's `APITestCase`.

Run:
```bash
cd backend/api
source ../.venv/bin/activate
python manage.py test -v 2
```
Coverage (examples):
- `users/tests/test_auth.py`: Register + login + `/api/me`
- `users/tests/test_permissions.py`: 401 scenarios for `/api/me`
- `lessons/tests/test_lessons.py`: student creates request, tutor approves
- `lessons/tests/test_permissions.py`: non-student creation forbidden (403); wrong tutor update forbidden (403)

---

## 2) Mobile (Flutter)

### Requirements
- Flutter SDK (3.x)
- iOS/Android dev environment

### Setup & Run
```bash
cd mobile
flutter pub get
flutter run --debug
```
The app uses `http://127.0.0.1:8001/api` as the backend base URL. This works out-of-the-box on the iOS simulator. On Android emulator, you may need to switch to `10.0.2.2` if required.

### Key Packages
- `flutter_riverpod`: State management
- `dio`: HTTP client (interceptor attaches tokens and refreshes automatically)
- `flutter_secure_storage`: Persist tokens
- `json_serializable`: JSON models

### Screens & Flows
- Auth: Login/Register (JWT), loads profile via `/api/me` after login
- Tutors List: Subject filter, search/order (backend-supported)
- Tutor Detail: Info + "Create Lesson Request" button
- Create Lesson Request: Subject, date/time (classic dial time picker), duration, optional note
- My Requests: Student (sent), Tutor (incoming) + approve/reject
- Profile Edit: Student `grade_level`, Tutor `bio` and `hourly_rate`

### Mobile Notes
- Token refresh: on 401, refresh token is used and the request is retried; if refresh fails, app clears tokens
- Error/UX: user-friendly messages based on `DioException`
- Time picker: classic dial UI in 24-hour format

---

## 3) Common Pitfalls
- Base URL: Backend should run at `http://127.0.0.1:8001/api`.
- Demo data: don't forget to run `seed_demo`.
- Token expiry: access token auto-refreshes; if refresh is invalid, user must re-login.

---

## 4) Tech Stack
- Backend: Django, Django REST Framework, drf-simplejwt, drf-spectacular, django-filter
- Mobile: Flutter, Riverpod, Dio, flutter_secure_storage, json_serializable

---
