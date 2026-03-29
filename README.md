# kishan_diary

Kishan Diary is a Flutter + Laravel project for farm bookkeeping.

## Current Modules

### Farmer
- Land management
- Income / expense / crop / labor / upad entries
- Dashboard and reports

### Agro Center
- Role-based login (`agro_center`)
- Add, edit, delete farmer contacts (name + mobile)
- Bill upload with image/date/payment status
- Dashboard, manage bills, farmer list, reports
- Agro user drawer with profile update

## Tech Stack

- Frontend: Flutter
- Backend API: Laravel (PHP)
- Database: MySQL

## Project Structure (Important Parts)

### Frontend
- `lib/screens/home_screen.dart` Farmer main screen
- `lib/screens/agro_owner_screen.dart` Agro container screen
- `lib/screens/agro/agro_dashboard_tab.dart` Agro dashboard tab
- `lib/screens/agro/agro_manage_bills_tab.dart` Agro manage bills tab
- `lib/screens/agro/agro_farmers_tab.dart` Agro farmers tab
- `lib/screens/agro/agro_report_tab.dart` Agro reports tab
- `lib/utils/api_service.dart` API methods
- `lib/utils/localization.dart` EN/GU localization

### Backend
- `backend_kishan/routes/api.php` API routes
- `backend_kishan/app/Http/Controllers/Api/AgroCenterController.php` Agro APIs
- `backend_kishan/app/Http/Controllers/Api/AuthController.php` Auth + role login
- `backend_kishan/app/Http/Controllers/Api/ProfileController.php` Profile APIs
- `backend_kishan/app/Models/AgroBill.php` Agro bill model
- `backend_kishan/app/Models/AgroFarmerContact.php` Agro farmer contact model

## Local Run Setup

### 1. Backend

```bash
cd backend_kishan
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. Flutter app

```bash
flutter pub get
flutter run -d RMX3998 --no-pub
```

If your local IP changes, update Android default API base in `lib/utils/api_service.dart`.

## Notes

- Agro farmer records are stored in dedicated table `agro_farmer_contacts`.
- Agro added farmers are not created as login users.
- Keep backend and app running together for API access.
