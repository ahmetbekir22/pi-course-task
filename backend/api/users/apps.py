from django.apps import AppConfig


class UsersConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "users"

    def ready(self):
        # Ensure profiles are created automatically on user creation (signal)
        from . import signals  # noqa: F401
