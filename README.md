# 🌾 Farmers Market App

Mobile POS application for the Farmers Market Platform - Built with Flutter.

## 📋 Description

Flutter mobile application for POS operators to manage farmer transactions, product catalog, and debt repayments.

## 🛠️ Tech Stack

- **Flutter** 3.x
- **Dart** 3.x
- **Provider** (state management)
- **HTTP** (API communication)
- **Shared Preferences** (token storage)

## ✅ Features

- 🔐 Login with Sanctum token authentication
- 👨‍🌾 Farmer search by ID or phone number
- ➕ Create new farmer profiles
- 📦 Browse products by nested categories
- 🛒 Place orders with cash or credit payment
- 💰 View farmer debt summary
- 🌾 Record commodity repayments

## ⚙️ Requirements

- Flutter 3.x
- Dart 3.x
- Laravel API running on `http://127.0.0.1:8000`

## 🚀 Installation

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/farmers-market-app.git
cd farmers-market-app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure API URL

Edit `lib/services/api_service.dart`:
```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// For Windows/Web
static const String baseUrl = 'http://127.0.0.1:8000/api';
```

### 4. Run the app
```bash
# On Windows
flutter run -d windows

# On Chrome
flutter run -d chrome

# On Android emulator
flutter run -d android
```

## 📱 Screens

| Screen | Description |
|--------|-------------|
| Login | Authenticate with email and password |
| Home | Main menu with quick actions |
| Farmer Search | Search farmer by ID or phone |
| Create Farmer | Register new farmer profile |
| Farmer Detail | View farmer info and actions |
| Product List | Browse products by category |
| Checkout | Place order with payment method |
| Debt Screen | View debts and record repayments |

## 🔑 Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Operator | operator@test.com | 123456 |
| Supervisor | supervisor@test.com | 123456 |
| Admin | admin@test.com | 123456 |