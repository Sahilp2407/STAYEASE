# 🏨 STAYEASE — Luxury Hotel Booking Application
## Comprehensive Project Documentation, Code Explanation & Animation Architecture Guide

> **Document Purpose:** This guide is created to help explain the StayEase project in detail to professors, evaluators, and examiners. It covers the overall architecture, every screen, detailed animation mechanics (with special emphasis on the Splash Screen), Flutter code explanations, and answers to common technical viva questions.

---

# 📑 TABLE OF CONTENTS
1. [Project Overview & Philosophy](#1-project-overview--philosophy)
2. [Design System & Luxury Aesthetics](#2-design-system--luxury-aesthetics)
3. [Architecture & State Management](#3-architecture--state-management)
4. [Deep-Dive: Splash Screen & Its Animations (Special Exam Focus)](#4-deep-dive-splash-screen--its-animations)
5. [Complete Screen-by-Screen Breakdown](#5-complete-screen-by-screen-breakdown)
   - [5.1 Luxury Splash Screen](#51-luxury-splash-screen)
   - [5.2 Boutique Dashboard](#52-boutique-dashboard)
   - [5.3 Hotel Search & List (with Map Toggle)](#53-hotel-search--list-with-map-toggle)
   - [5.4 Hotel Details Screen](#54-hotel-details-screen)
   - [5.5 Context-Aware Authentication Screen](#55-context-aware-authentication-screen)
   - [5.6 Room Selection Screen](#56-room-selection-screen)
   - [5.7 Booking Details Screen (Multi-Guest Architecture)](#57-booking-details-screen-multi-guest-architecture)
   - [5.8 Luxury Payment Screen](#58-luxury-payment-screen)
   - [5.9 Booking Confirmation Screen](#59-booking-confirmation-screen)
   - [5.10 My Bookings & Itinerary Screen](#510-my-bookings--itinerary-screen)
6. [Comprehensive Catalog of All Animations in the App](#6-comprehensive-catalog-of-all-animations-in-the-app)
7. [Code Deep-Dive & Key Flutter Concepts Used](#7-code-deep-dive--key-flutter-concepts-used)
8. [Frequently Asked Questions & Viva Preparation for Ma'am](#8-frequently-asked-questions--viva-preparation-for-maam)

---

# 1. PROJECT OVERVIEW & PHILOSOPHY

### What is StayEase?
**StayEase** is a cross-platform luxury hotel discovery and reservation mobile application built using **Flutter & Dart**. Unlike generic booking applications that feel like cluttered database tables, StayEase is modeled after five-star boutique hospitality concierges (like Aman, Oberoi, and Taj).

### Core UX Principle: "Guest-First Exploration"
Most traditional apps force users to sign up immediately upon opening. StayEase uses a **contextual authentication architecture**:
1. Users can freely browse hotels, explore amenities, switch to interactive maps, and inspect room varieties **without signing in**.
2. Authentication is only required **at the moment of intent** — when the guest chooses *"Continue to Book"*.
3. Once authenticated, the app does not dump the user back to the home screen; it seamlessly resumes to **Room Selection** for that specific hotel.

---

# 2. DESIGN SYSTEM & LUXURY AESTHETICS

The visual identity follows a curated **Sage + Cream Boutique** color palette:

| Color Token | Hex Code | Purpose & Feel |
| :--- | :--- | :--- |
| **Sage Green (Primary)** | `#6F8068` | Main brand color, buttons, active highlights, luxury feel |
| **Soft Sage (Secondary)** | `#A8B5A0` | Subdued accents, secondary badges, soft borders |
| **Warm Cream (Background)** | `#F7F5EF` | Page background, relaxing organic canvas (replaces harsh stark white) |
| **Pure White (Cards)** | `#FFFFFF` | Elevates content cards with clean contrast |
| **Deep Charcoal (Text)** | `#252923` | High-contrast readability, softer than pure `#000000` |
| **Muted Terracotta (Accent)**| `#C98F65` | Price tags, ratings, luxury tags, warm metallic accents |
| **Linen Border** | `#E5E2D8` | Delicate dividers, hairline card borders |

### Typography Pairing
- **Headings & Display**: `GoogleFonts.cormorantGaramond()` — An editorial, classic serif font evoking luxury magazine styling.
- **Body & Controls**: `GoogleFonts.montserrat()` — A clean, geometric modern sans-serif font ensuring crisp legibility on high-DPI mobile screens.

---

# 3. ARCHITECTURE & STATE MANAGEMENT

### Project Structure
```
lib/
├── main.dart               # App entrypoint, theme, & LuxurySplashScreen
├── models/
│   └── hotel_models.dart   # Hotel, Room, GuestReview, Booking models
├── data/
│   └── hotel_data.dart     # Curated hotel catalog (Taj, Oberoi, Aman, etc.)
├── screens/
│   ├── dashboard_screen.dart           # Home screen with search & discovery
│   ├── hotel_list_screen.dart          # Filterable list & interactive map
│   ├── hotel_details_screen.dart       # Gallery, amenities, reviews, sticky book bar
│   ├── auth_screen.dart                # Login & signup with hotel preview
│   ├── room_selection_screen.dart      # Room tiers (Standard, Deluxe, Suite)
│   ├── booking_details_screen.dart     # Multi-guest form & special requests
│   ├── payment_screen.dart             # UPI, Card, NetBanking, Pay at Hotel
│   ├── booking_confirmation_screen.dart# Animated success ticket & itinerary
│   └── my_bookings_screen.dart         # Active & past reservation manager
└── widgets/                # Reusable UI widgets (navbars, cards, badges)
```

### State Management: Reactive Singleton `AppState`
Instead of introducing heavy external dependencies like Bloc or Redux for a clean UI assignment, the application implements Flutter’s official **`ChangeNotifier`** and **`ValueNotifier`** pattern via a centralized `AppState` singleton:
- **`isLoggedIn` / `userName` / `userEmail`**: Tracks authentication session.
- **`favorites` (`Set<String>`)**: Real-time reactive wishlist synchronization across cards.
- **`bookings` (`List<Booking>`)**: Dynamic list of reserved trips persisted in session memory.
- **`notifyListeners()`**: Triggers instant UI updates across the widget tree when favorites or bookings change.

---

# 4. DEEP-DIVE: SPLASH SCREEN & ITS ANIMATIONS
*(Ma'am is likely to ask in detail about this screen!)*

The file is located in `lib/main.dart` inside the `LuxurySplashScreen` widget.

```
       [ App Launches ]
              │
    ┌─────────┴─────────┐
    │  Entrance (2.4s)  │ ──> Staggered Fade, Slide, & Elastic Scale
    └─────────┬─────────┘
              │
    ┌─────────┴─────────┐
    │ Continuous Idle   │ ──> 1. Ambient Glow (Breathing Halo)
    │   Animations      │ ──> 2. Shimmer Sweep (Gold Border Glint)
    │                   │ ──> 3. Custom Canvas Particle Drift (10s)
    │                   │ ──> 4. Oscillating Indicator Bounce (1.4s)
    └───────────────────┘
```

### 1. `TickerProviderStateMixin`
- **Why it is used:** Standard `SingleTickerProviderStateMixin` only supports **one** `AnimationController`. Because our splash screen orchestrates **5 separate controllers** running simultaneously, we MUST use `TickerProviderStateMixin`.

### 2. The 5 Animation Controllers Explained:

#### Controller 1: `_entranceController` (Choreographed Staggered Entrance)
- **Duration:** `2400 milliseconds` (2.4 seconds)
- **Concept:** It uses **Staggered Animations** via `Interval(start, end, curve)`. The controller runs from `0.0` to `1.0`, and each UI element has a specific time slice:
  1. **Background Fade** (`0.0 - 0.4`, `Curves.easeIn`): Smooth transition from dark into warm cream.
  2. **Top Bar Slide & Fade** (`0.2 - 0.55`, `Curves.easeOutCubic`): Header drifts down from `Offset(0, -0.4)` to `Offset.zero`.
  3. **Brand Emblem Scale & Pop** (`0.25 - 0.75`, `Curves.easeOutBack`): 
     - **Key Detail:** `Curves.easeOutBack` creates an **overshoot/elastic bounce effect** (scales from 0.75 to 1.05 and settles at 1.0), making the emblem feel physically alive.
  4. **Title Slide & Fade** (`0.5 - 0.85`, `Curves.easeOutCubic`): "STAYEASE" drifts up from `Offset(0, 0.25)`.
  5. **Subtitle Fade** (`0.65 - 0.95`, `Curves.easeIn`): "A Sanctuary in Every Stay" fades in gently.
  6. **CTA Button Slide & Fade** (`0.75 - 1.0`, `Curves.easeOutCubic`): "Begin Your Journey" button glides into place.
  7. **Footer Fade** (`0.85 - 1.0`): "Crafted for Discerning Travelers" appears last.

#### Controller 2: `_ambientGlowController` (Breathing Halo Effect)
- **Duration:** `2800 milliseconds` (2.8 seconds)
- **Pattern:** `.repeat(reverse: true)` (Breathes in and out continuously)
- **Code implementation:** It drives a `RadialGradient` opacity and radius behind the logo emblem:
  ```dart
  RadialGradient(
    colors: [
      _kSecondary.withValues(alpha: 0.35 * _ambientGlowController.value),
      Colors.transparent,
    ],
    stops: const [0.0, 1.0],
  )
  ```
- **Visual Result:** Gives the feeling of a soft, luminous light gently pulsing behind the brand badge.

#### Controller 3: `_shimmerController` (Luminous Light Sweep)
- **Duration:** `3500 milliseconds` (3.5 seconds)
- **Pattern:** `.repeat()` (Continuous forward sweep)
- **Code implementation:** Moves a angled `LinearGradient` across the card borders and button using an `Alignment` sweep:
  ```dart
  LinearGradient(
    begin: Alignment(-2.0 + 4.0 * _shimmerController.value, -1.0),
    end: Alignment(-1.0 + 4.0 * _shimmerController.value, 1.0),
    colors: [Colors.transparent, _kAccent.withValues(alpha: 0.4), Colors.transparent],
  )
  ```
- **Visual Result:** A subtle golden glint passes across the metallic emblem and button, signifying luxury.

#### Controller 4: `_particlesController` with `CustomPainter` (Botanical Drift)
- **Duration:** `10 seconds` loop
- **Widget:** `CustomPaint(painter: LuxuryParticlePainter(_particlesController.value))`
- **Code implementation:** In `LuxuryParticlePainter`, a mathematical formula calculates `x` and `y` coordinates for 18 microscopic particles using sine waves:
  ```dart
  final y = (initialY - progress * height) % height;
  final x = initialX + sin(progress * 2 * pi + index) * 12.0;
  canvas.drawCircle(Offset(x, y), radius, paint);
  ```
- **Visual Result:** Floating golden and sage botanical dust slowly rises up the screen like dust motes in sunlight.

#### Controller 5: `_arrowBounceController` (Interactive Nudge)
- **Duration:** `1400 milliseconds`
- **Pattern:** `.repeat(reverse: true)` with `Curves.easeInOut`
- **Visual Result:** The explore arrow on the CTA button gently shifts horizontally by 4 pixels back and forth to invite the user to tap.

---

# 5. COMPLETE SCREEN-BY-SCREEN BREAKDOWN

---

### 5.1 Luxury Splash Screen
- **File:** [lib/main.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/main.dart) (`LuxurySplashScreen`)
- **Key Functions & Features:**
  - Full animated brand entrance and ambient animations.
  - Interactive **Concierge Preview Dialog** (`showGeneralDialog`) offering a preview of concierge services.
  - Tap *"Begin Your Journey"* transitions cleanly to `DashboardScreen` via `Navigator.pushReplacement()`.

---

### 5.2 Boutique Dashboard
- **File:** [lib/screens/dashboard_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/dashboard_screen.dart) (`DashboardScreen`)
- **Key Functions & Features:**
  - **Dynamic Greeting & Location:** Displays live location (*Mumbai, India*) and curated time-based welcome.
  - **Interactive Search Bar:** Tapping opens destination filters (*Mumbai, Udaipur, Jaipur, Goa, Bengaluru*).
  - **Hero Destination Carousel:** Visual cards of India's luxury regions with room counts.
  - **Featured Hotels ("Handpicked Sanctuaries"):** High-res photos, star rating badge, price per night, and an interactive **Wishlist Heart Icon** that toggles `AppState.toggleFavorite()`.
  - **Bottom Navigation Bar:** Seamlessly switches between *Explore*, *Wishlist (Saved)*, and *Profile (Bookings)*.

---

### 5.3 Hotel Search & List (with Map Toggle)
- **File:** [lib/screens/hotel_list_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/hotel_list_screen.dart) (`HotelListScreen`)
- **Key Functions & Features:**
  - **Category Filter Chips:** *All, 5-Star Luxury, Heritage, Beachfront, Royal Palace*.
  - **Sort Modal:** Filter by *Price (Low to High), Price (High to Low), Rating, Popularity*.
  - **View Switcher:** Toggle between **Card View** and **Interactive Simulated Map View**.
  - **Simulated Map View:** Custom painter grid displaying interactive hotel price pins (`₹15,840`). Tapping a pin highlights that hotel card at the bottom of the map.

---

### 5.4 Hotel Details Screen
- **File:** [lib/screens/hotel_details_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/hotel_details_screen.dart) (`HotelDetailsScreen`)
- **Key Functions & Features:**
  - **SliverAppBar with PageView Gallery:** Multi-image carousel with animated dot indicators and smooth image swipe.
  - **Quick Stats Bar:** Rating badge (`4.9 ★`), reviews count (`1,420 reviews`), location distance description.
  - **Amenities Grid:** Clean icons for *Free High-speed Wi-Fi, Royal Spa & Wellness, Infinity Pool, Valet Parking, Fine Dining*.
  - **Guest Reviews Section:** Genuine customer feedback with avatar, star rating, and review text.
  - **Sticky Bottom Reservation Bar:** Stays anchored at the bottom with price summary and *"Continue to Book"* button.
  - **Contextual Auth Routing:**
    ```dart
    if (!AppState.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen(selectedHotel: widget.hotel)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => RoomSelectionScreen(hotel: widget.hotel)));
    }
    ```

---

### 5.5 Context-Aware Authentication Screen
- **File:** [lib/screens/auth_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/auth_screen.dart) (`AuthScreen`)
- **Key Functions & Features:**
  - **Contextual Hotel Badge:** Displays the selected hotel thumbnail and name with the message: *"Sign in to complete your reservation at The Taj Mahal Palace"*.
  - **Tab Switcher:** Animated sliding selector between **Sign In** and **Create Account**.
  - **One-Tap Demo Login:**
    - *"Continue with Google"* (Pre-fills as *Sahil Pandey*).
    - *"Quick Demo Guest"* (Instant sign-in for testing).
  - **Form Validation:** Validates email formatting and password length with inline error styling.
  - **Navigation Flow:** On sign in, immediately redirects forward to `RoomSelectionScreen` for the user's selected hotel.

---

### 5.6 Room Selection Screen
- **File:** [lib/screens/room_selection_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/room_selection_screen.dart) (`RoomSelectionScreen`)
- **Key Functions & Features:**
  - **Room Tiers:** Displays rooms for the selected hotel:
    1. *Standard Heritage Room* (King Bed, Garden View, 2 Guests)
    2. *Deluxe Ocean Suite* (King Bed, Sea View, Balcony, 3 Guests)
    3. *Presidential Luxury Suite* (Grand Suite, Private Butler, Jacuzzi, 4 Guests)
  - **Interactive Selection:** Radio indicators highlight the chosen tier with an animated sage border.
  - **Inclusions:** Free breakfast tags, free cancellation tags, and tax breakdown.
  - **CTA Button:** *"Continue to Booking"*, passing both `Hotel` and chosen `Room` to the next screen.

---

### 5.7 Booking Details Screen (Multi-Guest Architecture)
- **File:** [lib/screens/booking_details_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/booking_details_screen.dart) (`BookingDetailsScreen`)
- **Key Functions & Features:**
  - **Stay Recap Card:** Hotel thumbnail, Room name, Check-in date (`8 Sep 2026`), Check-out date (`10 Sep 2026`), and badge (`2 Nights • 2 Adults • 1 Room`).
  - **Multi-Guest Details (`GuestInfo` List):**
    - **Guest 1 (Primary Lead):**
      - Title Chips: `Mr.`, `Ms.`, `Mrs.`
      - First Name & Last Name (cleansed from any social email tags)
      - Email address & Contact Phone Number
      - Lead badge: *"Main Contact & Invoice Recipient"*
    - **Guest 2 (Adult Companion):**
      - Title Chips: `Mr.`, `Ms.`, `Mrs.`
      - Companion First Name & Last Name
      - Subtext: *"Room key and privileges will be linked to the primary reservation"*
    - **Dynamic Guest Adder:** **`+ Add Another Guest (Companion)`** button allows adding additional guests up to room limits, with a delete button on companion cards.
  - **Special Requests Card:** Quick-tap chips (*Early Check-in, High Floor, Quiet Room, Airport Transfer, Late Check-out*) that toggle directly into the special requests notes field.
  - **Itemized Price Breakdown:** Base room rate, 18% luxury GST, boutique concierge fee, and total payable amount.

---

### 5.8 Luxury Payment Screen
- **File:** [lib/screens/payment_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/payment_screen.dart) (`PaymentScreen`)
- **Key Functions & Features:**
  - **4 Payment Methods:**
    1. **UPI / QR (Instant):** Google Pay, PhonePe, Paytm, or custom UPI ID.
    2. **Credit / Debit Cards:** Card number, expiry, CVV, and Cardholder name with live formatting.
    3. **Net Banking:** HDFC, ICICI, SBI, Axis, Kotak instant bank selectors.
    4. **Pay at Hotel:** Reserve now with 0 advance payment, pay at check-in desk.
  - **Bank Security Badge:** Displays 256-bit SSL encryption guarantee.
  - **Interactive Processing:** Shows a luxury loading spinner for 1.2s before generating the confirmation ticket.

---

### 5.9 Booking Confirmation Screen
- **File:** [lib/screens/booking_confirmation_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/booking_confirmation_screen.dart) (`BookingConfirmationScreen`)
- **Key Functions & Features:**
  - **Animated Spring Checkmark:** Uses `ScaleTransition` with `Curves.elasticOut` to give a joyful, tactile celebration pop when the booking succeeds.
  - **Boutique Reservation Voucher / Pass:**
    - Booking Reference Number (e.g. `STE-849204`).
    - Hotel name, room category, check-in & check-out dates.
    - All registered guest names listed cleanly.
    - Total paid badge with payment method indicator.
  - **Quick Action Buttons:**
    - *"View in My Bookings"* (Navigates to active trip itinerary).
    - *"Back to Home"* (Clears navigation stack to dashboard).

---

### 5.10 My Bookings & Itinerary Screen
- **File:** [lib/screens/my_bookings_screen.dart](file:///Users/sahilpandey/Desktop/STAYEASE/lib/screens/my_bookings_screen.dart) (`MyBookingsScreen`)
- **Key Functions & Features:**
  - **Tabs:** *Active / Upcoming Reservations* vs *Past Stays*.
  - **Persistent List:** Reads directly from `AppState.bookings`.
  - **Itinerary Card Actions:**
    - *View Digital Key*: Shows QR check-in code.
    - *Hotel Contact / Directions*: Triggers contact concierge dialog.
    - *Cancel Reservation*: Live status change with refund notification.

---

# 6. COMPREHENSIVE CATALOG OF ALL ANIMATIONS IN THE APP

| Animation Type | Screen(s) | Implementation Widget | Purpose / Aesthetic Value |
| :--- | :--- | :--- | :--- |
| **Staggered Entrance** | Splash Screen | `AnimationController` + `CurvedAnimation(Interval)` | Creates a theatrical, sequential reveal of background, logo, and text |
| **Breathing Halo Glow** | Splash Screen | `AnimationController.repeat(reverse: true)` + `RadialGradient` | Simulates a living, calming light source behind the brand emblem |
| **Shimmer Light Sweep**| Splash Screen | `AnimationController.repeat()` + `LinearGradient(Alignment)` | Gives metallic luster and luxury reflection to borders |
| **Particle Physics Drift**| Splash Screen | `CustomPainter` + `Canvas.drawCircle()` + `sin/cos` | Microscopic botanical particles floating upward |
| **Elastic Success Pop**| Confirmation Screen| `AnimationController` + `ScaleTransition(Curves.elasticOut)` | Tactile celebratory pop on booking confirmation |
| **Hero Image Transitions**| Dashboard ➔ Details | `Hero(tag: hotel.id)` | Seamless zoom-in of hotel image between list and detail view |
| **Implicit Container Transitions**| Room Selection, Auth, Booking Details | `AnimatedContainer(duration: 250ms)` | Smooth color, border, and elevation changes on card selection |
| **Scale & Tap Feedback**| Auth Screen, Buttons | `AnimatedScale(scale: isPressed ? 0.96 : 1.0)` | Subtle micro-interaction simulating physical button depression |
| **Page Indicator Animation**| Details Screen | `AnimatedContainer(width: isCurrent ? 24 : 6)` | Smooth morphing pill dots on hotel image slider |

---

# 7. CODE DEEP-DIVE & KEY FLUTTER CONCEPTS USED

### 1. Separation of Concerns & Data Models
- We separated immutable data into `models/hotel_models.dart`:
  - `Hotel`, `Room`, `GuestReview`, `Booking`.
  - Every field is strongly typed (`final String`, `final int`, `final double`).

### 2. Form Controllers & Memory Lifecycle
In `BookingDetailsScreen` and `AuthScreen`:
- Text fields use `TextEditingController`.
- **Crucial Best Practice:** In `dispose()`, all controllers are cleaned up to prevent memory leaks:
  ```dart
  @override
  void dispose() {
    for (final guest in _guests) {
      guest.firstNameCtrl.dispose();
      guest.lastNameCtrl.dispose();
      guest.emailCtrl?.dispose();
      guest.phoneCtrl?.dispose();
    }
    super.dispose();
  }
  ```

### 3. Responsive Layout Strategy (No Hardcoded Pixel Breaks)
- **`LayoutBuilder` & `MediaQuery`**: Adaptive padding across different screen widths.
- **`Expanded` & `Flexible`**: Used inside rows (e.g. First Name + Last Name fields) to distribute available space equally without causing overflow (`RenderFlex overflowed by X pixels`).
- **`SingleChildScrollView` + `SafeArea`**: Ensures content scrolls smoothly above the on-screen virtual keyboard when the user enters guest details.

---

# 8. FREQUENTLY ASKED QUESTIONS & VIVA PREPARATION FOR MA'AM

### Q1: "Splash screen mein konsa animation use kiya hai aur kaise banaya?"
> **Answer to tell Ma'am:**
> *"Ma'am, Splash screen mein humne ek simple timer lagane ke bajaye **5 simultaneous Animation Controllers** use kiye hain with `TickerProviderStateMixin`:*
> 1. *Pehla hai **Staggered Entrance Animation** (2.4 seconds duration) jisme `CurvedAnimation` aur `Intervals` ka use kiya hai — background pehle fade hota hai, phir emblem `Curves.easeOutBack` se spring bounce ke sath scale hota hai, aur text sequence me slide hota hai.*
> 2. *Dusra hai **Ambient Breathing Glow** jo `.repeat(reverse: true)` se emblem ke piche ek radial gradient halo ko pulse karwata hai.*
> 3. *Teesra hai **Luminous Shimmer Sweep** jo linear gradient ko repeat mode mein sweep karta hai gold reflection create karne ke liye.*
> 4. *Chautha hai **CustomPainter Particle Drift** jo canvas pe sine-wave formula se floating botanical particles render karta hai.*
> 5. *Paanchwa hai **Micro Arrow Bounce** jo CTA button par user attention draw karta hai."*

---

### Q2: "State Management ke liye kya use kiya hai?"
> **Answer to tell Ma'am:**
> *"Humne Flutter ka core **ChangeNotifier** aur **ValueNotifier** architectural pattern use kiya hai via `AppState`. Jab bhi user hotel ko wishlist karta hai ya booking complete karta hai, `AppState.notifyListeners()` call hota hai jo instantly pure app ke widget tree ko reactively update karta hai without any heavy third-party bloat."*

---

### Q3: "Sabhi guests ke details lene ke liye code mein kya architecture lagaya hai?"
> **Answer to tell Ma'am:**
> *"Humne `GuestInfo` class banayi hai jisme har guest ka Title (`Mr/Ms/Mrs`), `firstNameCtrl`, aur `lastNameCtrl` store hota hai. Lead guest ke pass additional Email aur Phone controllers hote hain. `_guests` ek dynamic list hai, jisme user `+ Add Another Guest` click karke companions add kar sakta hai aur delete icon se remove kar sakta hai. Payment hone par ye sabhi names combine hoke voucher ticket par generate hote hain."*

---

### Q4: "Hero animation kahan use hua hai?"
> **Answer to tell Ma'am:**
> *"Hotel list se Hotel Details screen par switch hone ke time hotel card image par `Hero(tag: 'hotel-img-${hotel.id}')` widget use kiya hai. Isse image screen transition ke doran seamless zoom transition create karti hai."*

---

### Q5: "App responsive kaise banayi hai?"
> **Answer to tell Ma'am:**
> *"Humne hardcoded screen widths avoid kiye hain. Content ko `Expanded` aur `Flexible` ke andar wrap kiya hai, dynamic padding `MediaQuery.of(context).size` se aati hai, aur `SingleChildScrollView` with `ClampingScrollPhysics` keyboard popping up ke time pixel overflow hone se rokta hai."*

---
*(End of StayEase Architecture Guide)*
