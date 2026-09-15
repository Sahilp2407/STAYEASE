# 🏨 StayEase — Luxury Boutique Hotel Booking Experience

A modern, high-end cross-platform hotel discovery and reservation application crafted with **Flutter, Material 3, and Dart**. Designed with a bespoke **Sage & Cream** luxury boutique aesthetic (`#6F8068` Sage Green, `#F7F5EF` Warm Cream, `#C98F65` Muted Terracotta), **StayEase** elevates mobile hospitality with micro-interactions, explicit animations, and an intuitive guest-first booking workflow.

---

## ✨ Key Features

- **Guest-First Exploration**: Browse sanctuaries, explore destinations, view hotel galleries, amenities, and guest reviews without requiring immediate login.
- **Context-Aware Authentication**: Sign-in is requested seamlessly only when intent is signaled (*Continue to Book*). The app instantly resumes the reservation without losing context.
- **Interactive Map & Card View**: Toggle smoothly between rich visual hotel cards and an interactive simulated map view with custom canvas price pins.
- **Multi-Guest Details Management**: Comprehensive guest registration architecture (`GuestInfo`), supporting Lead Guest contact details, companion guests, dynamic guest count management, and quick-tap special requests.
- **End-to-End Booking Workflow**:
  `Dashboard` ➔ `Hotel List / Map` ➔ `Hotel Details` ➔ `Room Selection` ➔ `Multi-Guest Booking Details` ➔ `Payment (UPI / Card / NetBanking / At Hotel)` ➔ `Animated Booking Confirmation Voucher` ➔ `My Bookings Manager`.
- **Choreographed Luxury Animations**:
  - **Staggered Entrance Animation**: Orchestrated 2.4s sequence with `Interval` and `CurvedAnimation`.
  - **Ambient Breathing Glow**: Continuous pulsating radial gradient halo behind brand emblem.
  - **Luminous Shimmer Sweep**: Metallic gradient sweeps across cards and call-to-action buttons.
  - **Custom Particle Physics**: Microscopic botanical particle drift rendered via `CustomPainter` with trigonometric formulas.
  - **Elastic Success Pop**: Tactile spring celebration checkmark on confirmation screen (`Curves.elasticOut`).
  - **Hero Transitions**: Smooth element image transitions between list cards and hotel detail views.

---

## 🎨 Color System & Aesthetics

| Token | Hex | Role |
| :--- | :--- | :--- |
| **Sage Green** | `#6F8068` | Primary luxury brand tone & prominent controls |
| **Soft Sage** | `#A8B5A0` | Secondary accents, chip borders & soft highlights |
| **Warm Cream** | `#F7F5EF` | Organic canvas background (softer than stark white) |
| **Pure White** | `#FFFFFF` | Crisp card and elevated surface background |
| **Deep Charcoal** | `#252923` | High-contrast typography & icons |
| **Muted Terracotta** | `#C98F65` | Price tags, star ratings, and warm metallic accents |

**Typography**:
- *Headings*: `GoogleFonts.cormorantGaramond` (Editorial Luxury Serif)
- *Body & Controls*: `GoogleFonts.montserrat` (Clean Modern Sans-Serif)

---

## 📂 Project Architecture

```
lib/
├── main.dart               # Entrypoint, theme, and LuxurySplashScreen
├── models/
│   └── hotel_models.dart   # Hotel, Room, GuestReview, Booking, and AppState
├── data/
│   └── hotel_data.dart     # Curated 5-star hotel catalog (Taj, Oberoi, Aman, etc.)
├── screens/
│   ├── dashboard_screen.dart           # Discovery dashboard with date/guest pickers
│   ├── hotel_list_screen.dart          # Filterable list & simulated canvas map
│   ├── hotel_details_screen.dart       # Gallery slider, amenities, reviews, sticky CTA
│   ├── auth_screen.dart                # Contextual authentication gate
│   ├── room_selection_screen.dart      # Tiered rooms (Standard, Deluxe, Suite)
│   ├── booking_details_screen.dart     # Multi-guest registration & requests
│   ├── payment_screen.dart             # Multi-method payment gateway (UPI, Card, Hotel)
│   ├── booking_confirmation_screen.dart# Animated voucher ticket
│   └── my_bookings_screen.dart         # Active and completed trip itinerary
├── widgets/
│   └── hotel_card.dart                 # Reusable luxury hotel card with Hero animation
└── services/
    └── app_state.dart                  # Centralized reactive ChangeNotifier session
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+ recommended)
- Dart SDK
- Google Chrome (for Web) or iOS Simulator / Android Emulator

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Sahilp2407/STAYEASE.git
   cd STAYEASE
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (Web)**:
   ```bash
   flutter run -d chrome
   ```

4. **Run on Mobile Simulator / Device**:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
