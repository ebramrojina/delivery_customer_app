# Delivery Customer App (Flutter) — MVP

## Setup

```bash
flutter pub get
flutter run
```

## Point it at your backend

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

- Android emulator → keep `10.0.2.2`
- iOS simulator → `http://localhost:5000/api`
- Physical device → your machine's LAN IP, e.g. `http://192.168.1.x:5000/api`
- Production → your deployed backend URL

## Flow

1. **Register / Login** — customers self-sign-up via `POST /api/auth/register` (role hard-coded to `customer`), or log in via `POST /api/auth/login`. Login rejects non-customer accounts, mirroring the Driver App's role check.
2. **Orders List (home)** — `GET /api/orders/customer/:customerId`, newest first. Empty state shows a "Create your first order" CTA instead of just text; once there's at least one order, a floating "New Order" button takes over.
3. **Create Order** — posts `pickupAddress`/`deliveryAddress` as `{ label, lat, lng }` to `POST /api/orders`. Currently plain text fields for the address label (no lat/lng yet) — see the note at the top of `create_order_screen.dart` for exactly where to swap in a map picker later without touching anything downstream.
4. **Track Order** — `GET /api/orders/:id`, shown as a 5-step progress stepper (Created → Assigned → Picked Up → Out for Delivery → Delivered) with timestamps, plus a driver contact card (name + tap-to-call) that appears once a driver is assigned.

## Consistency with the backend

`OrderStatus` in `models/order.dart` maps 1:1 to the backend's five status strings, including `out_for_delivery`. `orderStatusSequence` drives the tracking stepper so all five steps always render in the correct order, whether or not a status has been reached yet.

## Empty & error states

- **No orders yet**: friendly message + a prominent "Create your first order" button (not a dead end)
- **Load failure**: separate error state with a **Retry** button, distinct from "no orders"
- Both support pull-to-refresh, same as the loaded state

## Built for real-time (not wired up yet)

`OrderProvider.applyServerUpdate(order)` is the single point where any fresher order data gets pushed into the UI — used today after every tracking-screen refresh, and the exact same method a future Socket.IO listener would call on an `order:statusUpdated` event. No screen needs to change when that's added; only `main.dart` (to start the socket connection after login) and `providers/order_provider.dart` (to add the listener) would touch.

## Known limitation

Same as the Driver App: this sandbox has no Flutter/Dart SDK and can't reach pub.dev, so this hasn't been run through `flutter analyze` or compiled. I reviewed it manually and verified bracket/paren balance across every file. Please run `flutter pub get && flutter analyze` first and let me know if anything comes up.
