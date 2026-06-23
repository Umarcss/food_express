# Food Express

Food Express is a Flutter food delivery app with a production-shaped foundation:
Firebase authentication/data services, Paystack checkout boundaries, a modern
warm glassmorphic UI, cart/order state, notifications, and map-based delivery
tracking with simulated driver movement.

## Current Status

Implemented:

- Modern warm premium UI with glass surfaces, soft shadows, food cards, auth,
  home, detail, cart, checkout, delivery, profile, settings, and notifications.
- Provider-based architecture split into auth, menu, cart, orders, and
  notifications.
- Firestore-backed repositories with local seed menu fallback in debug builds.
- Firebase Auth profile creation and session gate.
- Paystack client flow wired through callable Cloud Functions.
- Google Maps delivery screen with real user location request and simulated
  driver marker.
- Android/iOS permissions for location, notifications, phone links, and maps.
- Analyzer-clean Dart code and basic tests.

Still requires project setup:

- A valid Firebase project for Android/iOS.
- Deployed Cloud Functions.
- Paystack secret key stored only as a Firebase Functions secret before
  production deploy.
- Google Maps API key in Android local properties and iOS app configuration.

## Architecture

Core app state lives in `lib/providers`:

- `AuthProvider`: Firebase session, login, signup, logout, profile data.
- `MenuProvider`: menu stream from Firestore with debug seed fallback.
- `CartProvider`: cart items, quantities, add-ons, totals in kobo.
- `OrderProvider`: order creation, payment orchestration, demo order fallback.
- `NotificationProvider`: read-only notification state and provider-owned
  mutation methods.

Main data and service boundaries:

- `MenuRepository.watchMenu()`
- `OrderRepository.createOrder()`
- `NotificationRepository.watchUserNotifications()`
- `AuthService.signIn()` / `AuthService.signUp()`
- `PaymentService.initialize()` / `launch()` / `verify()`

Money is stored as integer kobo and displayed as Nigerian naira.

## Firebase Collections

- `users/{uid}`: `displayName`, `email`, `phone`, `photoUrl`,
  `defaultAddress`, `createdAt`, `updatedAt`
- `menuItems/{id}`: `name`, `description`, `category`, `imageUrl`,
  `priceKobo`, `addons`, `isAvailable`, `sortOrder`
- `orders/{id}`: `userId`, `items`, `subtotalKobo`, `deliveryFeeKobo`,
  `totalKobo`, `status`, `paymentStatus`, `paystackReference`,
  `deliveryAddress`, `driver`, `createdAt`, `updatedAt`
- `notifications/{id}`: `userId`, `title`, `body`, `type`, `isRead`,
  `createdAt`, `data`

## Local Setup

Install Flutter dependencies:

```bash
flutter pub get
```

Run checks:

```bash
flutter analyze
flutter test
```

Run the app:

```bash
flutter run
```

The Paystack test public key is configured in the app. Override it when needed
with `--dart-define=PAYSTACK_PUBLIC_KEY=pk_test_your_key`.

For Android maps, add this to `android/local.properties`:

```properties
MAPS_API_KEY=your_google_maps_key
```

## Cloud Functions

Install dependencies in the functions folder:

```bash
cd functions
npm install
```

Set the Paystack secret key:

```bash
firebase functions:secrets:set PAYSTACK_SECRET_KEY
```

Deploy:

```bash
firebase deploy --only functions
```

The Flutter app calls:

- `initializePaystackPayment(orderId)`
- `verifyPaystackPayment(reference)`

## Notes

- The delivery map is real, but driver movement is currently simulated.
- Debug builds use a local seed menu if Firestore is empty or unavailable.
- The checkout screen has a demo delivery fallback so UI development can
  continue before Firebase Functions and Paystack are deployed.


<!-- Email: test@example.com
Password: password123 -->

