# kishan_diary

## Default local run setup (Android + Laravel)

- Backend default: `http://0.0.0.0:8000`
- Android app default API: `http://192.168.1.8:8000/api/v1`

### Run backend

```bash
cd backend_kishan
php artisan serve --host=0.0.0.0 --port=8000
```

### Run app on Android

```bash
flutter run -d RMX3998 --no-pub
```

If your laptop IP changes from `192.168.1.8`, update `_androidDefaultApiBase` in `lib/utils/api_service.dart`.
