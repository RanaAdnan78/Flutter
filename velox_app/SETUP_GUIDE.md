# 💜 VELOX Flutter App — Complete Setup Guide

## What This App Does
A **native Flutter mobile app** that connects to your PHP MySQL database via the REST API. Works on Android + iOS. Full e-commerce features: browse products, search, cart, wishlist, checkout, order tracking.

---

## 📁 Project File Structure

```
velox_flutter/
├── lib/
│   ├── main.dart                   ← App entry point + routing + bottom nav
│   ├── config/
│   │   └── api_config.dart         ← ⚙️ Change your server URL here!
│   ├── models/
│   │   └── models.dart             ← Product, User, Order, Cart data classes
│   ├── services/
│   │   └── api_service.dart        ← All HTTP calls to your PHP REST API
│   ├── providers/
│   │   ├── auth_provider.dart      ← Login/logout state management
│   │   └── cart_provider.dart      ← Cart state management
│   ├── screens/
│   │   ├── splash_screen.dart      ← Animated launch screen
│   │   ├── home_screen.dart        ← Homepage with categories + products
│   │   ├── products_screen.dart    ← Product grid with sorting
│   │   ├── product_detail_screen.dart ← Full product page + add to cart
│   │   ├── cart_screen.dart        ← Shopping cart + coupon
│   │   ├── auth_screens.dart       ← Login + Register
│   │   └── other_screens.dart      ← Checkout, Orders, Profile, Search
│   ├── providers/
│   ├── utils/
│   │   └── theme.dart              ← App colors, theme, formatters
│   └── widgets/
│       └── widgets.dart            ← ProductCard, buttons, shimmer, etc.
├── pubspec.yaml                    ← Dependencies
└── android/
    └── .../network_security_config.xml ← Allow HTTP for local testing
```

---

## 🚀 STEP-BY-STEP SETUP

### Step 1 — Install Flutter SDK

**Windows:**
1. Go to https://flutter.dev/docs/get-started/install/windows
2. Download Flutter SDK (zip)
3. Extract to `C:\flutter\`
4. Add `C:\flutter\bin` to your **System PATH** environment variable
5. Open new Command Prompt and run: `flutter doctor`

**You should see Android SDK ✓ — fix any issues it reports**

---

### Step 2 — Install Android Studio

1. Download from https://developer.android.com/studio
2. During install, include **Android SDK** and **Android Virtual Device**
3. Open Android Studio → SDK Manager → Install Android 14 (API 34)
4. In Flutter, run: `flutter doctor --android-licenses` and accept all

---

### Step 3 — Create a New Flutter Project

Open VS Code or Android Studio terminal:

```bash
# Create the project
flutter create velox_flutter

# Go into folder
cd velox_flutter

# Open in VS Code
code .
```

---

### Step 4 — Replace Files

Replace the auto-generated files with the ones from this project:

| Replace | With |
|---------|------|
| `lib/main.dart` | provided `main.dart` |
| `pubspec.yaml`  | provided `pubspec.yaml` |

Then create these new folders & files:
```
lib/config/api_config.dart
lib/models/models.dart
lib/services/api_service.dart
lib/providers/auth_provider.dart
lib/providers/cart_provider.dart
lib/utils/theme.dart
lib/widgets/widgets.dart
lib/screens/splash_screen.dart
lib/screens/home_screen.dart
lib/screens/products_screen.dart
lib/screens/product_detail_screen.dart
lib/screens/cart_screen.dart
lib/screens/auth_screens.dart
lib/screens/other_screens.dart
```

Add the network config:
```
android/app/src/main/res/xml/network_security_config.xml
```

---

### Step 5 — Set Your Server URL (CRITICAL!)

Open `lib/config/api_config.dart` and change:

```dart
// Find your PC's IP: open CMD → type ipconfig → find IPv4 Address
static const String baseUrl = 'http://192.168.1.100/velox';
//                                   ^^^^^^^^^^^^^ Change this!
```

**IMPORTANT:** Your phone and PC must be on the **same WiFi network!**

To find your IP:
- Windows: open CMD → type `ipconfig` → look for **IPv4 Address**
- Usually looks like: `192.168.1.X`

---

### Step 6 — Also Copy api.php to Your VELOX Server

The REST API file must be in your XAMPP velox folder:
```
C:\xampp\htdocs\velox\api\api.php   ← copy from provided files
```

Test it works: open browser → `http://localhost/velox/api/api.php?endpoint=products`
You should see JSON data with your products list.

---

### Step 7 — Install Dependencies

```bash
flutter pub get
```

---

### Step 8 — Add Network Security Config to AndroidManifest

Open `android/app/src/main/AndroidManifest.xml` and in the `<application>` tag add:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

---

### Step 9 — Connect Your Android Phone

1. On your phone: **Settings → About Phone → tap Build Number 7 times**
2. Go to **Settings → Developer Options → turn on USB Debugging**
3. Connect phone to PC with USB cable
4. Accept the "Allow USB Debugging" prompt on your phone

---

### Step 10 — Run the App!

Make sure XAMPP Apache + MySQL are running, then:

```bash
# Check your device is connected
flutter devices

# Run the app (it will install on your phone!)
flutter run
```

The app will build and launch on your phone. First build takes ~2-3 minutes.

---

## 📦 BUILD RELEASE APK

To create an APK file you can share with anyone:

```bash
# Build release APK
flutter build apk --release

# Find the APK at:
# build/app/outputs/flutter-apk/app-release.apk
```

Share this `.apk` file — anyone with an Android phone can install it!

---

## 📱 SCREENS & FEATURES

| Screen | What It Does |
|--------|-------------|
| Splash | Animated VELOX logo with brand colors |
| Home | Categories, featured products, sale banner, new arrivals |
| Shop | Full product grid with sorting (newest/popular/price) |
| Search | Real-time search with 3-character minimum |
| Product Detail | Gallery, size/color picker, quantity, add to cart, rating |
| Cart | Items with swipe to delete, coupon code, order summary |
| Checkout | Delivery form + 4 payment methods |
| Order Success | Confirmation with order number |
| My Orders | Order history with status badges |
| Profile | User info, menu items, logout |
| Login | Email + password with validation |
| Register | Full registration form |

---

## 🔌 API ENDPOINTS USED

All these call your `api.php` file automatically:

```
GET  ?endpoint=products         → Product list
GET  ?endpoint=products&q=...   → Search
GET  ?endpoint=categories       → Categories
GET  ?endpoint=product&slug=... → Single product
POST ?endpoint=login            → Login (returns token)
POST ?endpoint=register         → Register
GET  ?endpoint=me               → Current user
GET  ?endpoint=cart             → Cart items
POST ?endpoint=cart             → Add to cart
DEL  ?endpoint=cart             → Remove/clear
GET  ?endpoint=wishlist         → Wishlist
POST ?endpoint=wishlist         → Toggle wishlist
POST ?endpoint=orders           → Place order
GET  ?endpoint=orders           → Order history
POST ?endpoint=reviews          → Submit review
POST ?endpoint=coupon           → Apply coupon code
```

---

## 🛠️ COMMON ERRORS & FIXES

| Error | Fix |
|-------|-----|
| `Connection refused` | Make sure XAMPP is running |
| `Failed host lookup` | Wrong IP in `api_config.dart` |
| `Cleartext not permitted` | Add `network_security_config.xml` |
| `No devices found` | Enable USB Debugging on phone |
| `Gradle build failed` | Run `flutter clean` then `flutter pub get` |
| `SDK not found` | Run `flutter doctor` and follow instructions |
| Products not loading | Test API URL in browser first |
| Images not showing | Check `ApiConfig.imgUrl` has correct server IP |

---

## 🌐 FOR LIVE/ONLINE SERVER

Once you host VELOX on a real web server:

1. Change in `api_config.dart`:
```dart
static const String baseUrl = 'https://yoursite.com';
```

2. Remove network security config (HTTPS is always allowed)

3. Build release APK:
```bash
flutter build apk --release
```

4. Submit to **Google Play Store** if desired!

---

*VELOX Flutter App — Built with Flutter 3.x, Provider, Cached Network Image*
*Connects to PHP/MySQL via REST API — Works on Android 5.0+ (API 21+)*
