## Pi Course — Mini Full-Stack MVP (Backend)

Bu repo Pi Course için öğrencilerin eğitmenleri bulup ders talebi oluşturabildiği bir MVP'nin Backend (Django/DRF) kısmını içerir. Mobil istemci (Flutter) bir sonraki adımdır.

### İçerik
- Django + DRF API (JWT auth, rol bazlı izinler)
- OpenAPI/Swagger: `/api/docs/`
- Seed komutu ile demo veriler
- Otomatik testler (auth, izinler, ders talebi akışı)

---

## Kurulum

### Gereksinimler
- Python 3.11+
- macOS/Linux/Windows

### Adımlar
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt

cd api
python manage.py migrate
python manage.py seed_demo  # demo veriler + admin
python manage.py runserver
# http://localhost:8000 → /api/docs/ (Swagger)
```

### Demo Hesaplar
- Superuser: `admin@demo.com` / `AdminPass123!`
- Öğrenci: `student1@demo.com` / `Passw0rd!`
- Eğitmen: `tutor1@demo.com` / `Passw0rd!`

---

## Kullanılan Modeller
- `users.User`: email ile giriş, `role: student|tutor`
- `users.TutorProfile`: `bio`, `hourly_rate`, `rating`, `subjects (M2M)`
- `users.StudentProfile`: `grade_level`
- `subjects.Subject`: `name`
- `lessons.LessonRequest`: `student`, `tutor`, `subject`, `start_time`, `duration_minutes`, `note`, `status: pending|approved/rejected`, `created_at`

## Teknikler
- DRF + SimpleJWT (JWT), `IsAuthenticated` default
- Rol bazlı izinler: öğrenci talep oluşturur; eğitmen onay/ret eder
- Filtre/Arama/Sıralama: `django-filter`, `SearchFilter`, `OrderingFilter`
- Sayfalama: Limit/Offset
- OpenAPI: `drf-spectacular` → `/api/schema/`, `/api/docs/`

---

## Uç Noktalar (Özet)
- Auth: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/refresh`
- Profil: `GET /api/me`, `PATCH /api/me`
- Konular: `GET /api/subjects`
- Eğitmenler: `GET /api/tutors?subject=&ordering=&search=`, `GET /api/tutors/{user_id}`
- Talepler: `GET/POST /api/lesson-requests`, `PATCH /api/lesson-requests/{id}`

---

## Testler
Testler DRF APITestCase ile yazıldı.

### Çalıştırma
```bash
cd backend/api
source ../.venv/bin/activate
python manage.py test -v 2
```

### Kapsam
- `users/tests/test_auth.py`: Kayıt + giriş + `/api/me` akışı
- `lessons/tests/test_lessons.py`: Öğrenci talep oluşturur, eğitmen onaylar
- `users/tests/test_permissions.py`: `/api/me` için 401
- `lessons/tests/test_permissions.py`: Öğrenci olmayanın talep oluşturması 403; yanlış eğitmenin güncellemesi 403

---

## Mimari Notlar
- Katmanlar: `users`, `subjects`, `lessons` app'leri ile ayrım
- `users.User` için custom `UserManager` (email tabanlı login, superuser desteği)
- Profil oluşturma `users.signals` ile otomatik (post_save)
- Query optimizasyonu: `select_related`/`prefetch_related` kullanımı

---

## Geliştirme Notları / Sonraki Adımlar
- Flutter istemci (auth, tutor list/detail, request akışları)
- Ek testler (validasyon hataları, pagination, rate limiting opsiyonel)
- Docker Compose (opsiyonel)

