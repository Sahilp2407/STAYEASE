import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import '../services/app_state.dart';
import 'auth_screen.dart';
import 'room_selection_screen.dart';

const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kCardAlt = Color(0xFFF0EDE5); // Warm Linen Cream
const _kBg = Color(0xFFF7F5EF); // Warm Cream

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  int _currentImageIdx = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onContinueToBook() {
    final appState = AppState.instance;

    if (!appState.isLoggedIn) {
      // 🔒 Core UX Principle: Auth appears ONLY after user taps "Continue to Book"
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AuthScreen(
            targetHotel: widget.hotel,
          ),
        ),
      );
    } else {
      // Already logged in -> jump straight to Room Selection
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoomSelectionScreen(hotel: widget.hotel),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Image Carousel with Back & Favorite Buttons
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 340,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // PageView Image Gallery
                      PageView.builder(
                        controller: _pageController,
                        itemCount: hotel.images.length,
                        onPageChanged: (idx) => setState(() => _currentImageIdx = idx),
                        itemBuilder: (ctx, i) {
                          final imgWidget = Image.network(
                            hotel.images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: hotel.heroColor1,
                              child: const Center(
                                child: Icon(Icons.hotel_rounded, color: Colors.white38, size: 64),
                              ),
                            ),
                          );
                          if (i == 0) {
                            return Hero(
                              tag: 'hotel-img-${hotel.id}',
                              child: imgWidget,
                            );
                          }
                          return imgWidget;
                        },
                      ),

                      // Top Gradient Scrim
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Back Button & Favorite Action
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                  ),
                                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                ),
                              ),
                              ListenableBuilder(
                                listenable: AppState.instance,
                                builder: (ctx, _) {
                                  final isFav = AppState.instance.isFavorite(hotel.id);
                                  return GestureDetector(
                                    onTap: () => AppState.instance.toggleFavorite(hotel.id),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                      ),
                                      child: Icon(
                                        isFav ? Icons.favorite : Icons.favorite_border_rounded,
                                        color: isFav ? const Color(0xFFE57373) : Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Image Dots Indicator
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(hotel.images.length, (i) {
                            final active = i == _currentImageIdx;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 22 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active ? Colors.white : Colors.white.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Hotel Title & Summary Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                  decoration: const BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Row(
                        children: [
                          Text(
                            hotel.category,
                            style: GoogleFonts.montserrat(
                              color: _kPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: _kAccent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${hotel.rating}',
                                  style: GoogleFonts.montserrat(
                                    color: _kText,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' (${hotel.reviewsCount} reviews)',
                                  style: GoogleFonts.montserrat(
                                    color: _kTextMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Hotel Name
                      Text(
                        hotel.name,
                        style: GoogleFonts.cormorantGaramond(
                          color: _kText,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Location & Distance
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: _kPrimary, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${hotel.location} • "${hotel.distanceDescription}"',
                              style: GoogleFonts.montserrat(
                                color: _kTextMuted,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 3. About This Hotel
              SliverToBoxAdapter(
                child: _buildSectionCard(
                  title: 'About this hotel',
                  child: Text(
                    hotel.description,
                    style: GoogleFonts.montserrat(
                      color: _kTextMuted,
                      fontSize: 13.5,
                      height: 1.65,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 4. Amenities Icon-Based Grid
              SliverToBoxAdapter(
                child: _buildSectionCard(
                  title: 'Amenities',
                  child: _buildAmenitiesGrid(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 5. Available Rooms Preview
              SliverToBoxAdapter(
                child: _buildSectionCard(
                  title: 'Available Rooms',
                  subtitle: 'Select from our luxury curated suites',
                  child: Column(
                    children: hotel.rooms.map((room) {
                      return _buildRoomPreviewCard(room);
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 6. Location & Map Preview
              SliverToBoxAdapter(
                child: _buildSectionCard(
                  title: 'Location',
                  subtitle: hotel.location,
                  child: _buildLocationPreview(hotel),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 7. Guest Reviews Section
              SliverToBoxAdapter(
                child: _buildSectionCard(
                  title: 'Guest Reviews',
                  subtitle: '⭐ ${hotel.rating} based on ${hotel.reviewsCount} verified stays',
                  child: Column(
                    children: hotel.reviews.map((r) => _buildReviewCard(r)).toList(),
                  ),
                ),
              ),

              // Bottom Spacer for Sticky Booking Bar
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // 8. Sticky Bottom Booking Bar (Section 5)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
              decoration: BoxDecoration(
                color: _kCard,
                border: const Border(top: BorderSide(color: _kBorder, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF252923).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${hotel.pricePerNight}',
                            style: GoogleFonts.cormorantGaramond(
                              color: _kText,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' / night',
                            style: GoogleFonts.montserrat(
                              color: _kTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${hotel.priceInclTaxes} incl. taxes',
                        style: GoogleFonts.montserrat(
                          color: _kTextFaint,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: _kPrimary.withValues(alpha: 0.35),
                      ),
                      onPressed: _onContinueToBook,
                      child: Text(
                        'Continue to Book',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF252923).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cormorantGaramond(
              color: _kText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                color: _kTextMuted,
                fontSize: 11.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Amenities Icon Grid
  Widget _buildAmenitiesGrid() {
    final list = [
      (Icons.wifi, 'Free Wi-Fi'),
      (Icons.pool_rounded, 'Pool'),
      (Icons.restaurant_rounded, 'Breakfast'),
      (Icons.local_parking_rounded, 'Parking'),
      (Icons.fitness_center_rounded, 'Gym'),
      (Icons.dinner_dining_rounded, 'Restaurant'),
      (Icons.ac_unit_rounded, 'Air Conditioning'),
      (Icons.spa_rounded, 'Luxury Spa'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (ctx, i) {
        final item = list[i];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kCardAlt,
                shape: BoxShape.circle,
                border: Border.all(color: _kBorder),
              ),
              child: Icon(item.$1, color: _kPrimary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              item.$2,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: _kTextMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  // Room Preview Card
  Widget _buildRoomPreviewCard(Room room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _kCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.network(
                room.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(color: _kPrimary.withValues(alpha: 0.2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      room.name,
                      style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '₹${room.pricePerNight}/n',
                      style: GoogleFonts.cormorantGaramond(
                        color: _kAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, color: _kTextFaint, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${room.capacity} Guests • ${room.bedType}',
                      style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 11.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: _kPrimary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      room.breakfastIncluded ? 'Breakfast Included' : 'Breakfast available',
                      style: GoogleFonts.montserrat(color: _kPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '• ${room.cancellationPolicy}',
                      style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Location Preview Card
  Widget _buildLocationPreview(Hotel hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _kCardAlt,
              border: Border.all(color: _kBorder),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Stylized map background canvas
                CustomPaint(
                  painter: _MapCanvasPainter(),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _kPrimary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hotel.name,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.directions_walk_rounded, color: _kPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              hotel.distanceDescription,
              style: GoogleFonts.montserrat(color: _kText, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  // Review Card
  Widget _buildReviewCard(GuestReview r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(r.avatarUrl),
                backgroundColor: _kPrimary,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.author,
                    style: GoogleFonts.montserrat(color: _kText, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    r.date,
                    style: GoogleFonts.montserrat(color: _kTextFaint, fontSize: 10.5),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: _kAccent, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    '${r.rating}',
                    style: GoogleFonts.montserrat(color: _kText, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.comment,
            style: GoogleFonts.montserrat(
              color: _kTextMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Decorative Map Canvas Painter
class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFEDE9DF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.45, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.25);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(path2, roadPaint);

    final riverPaint = Paint()
      ..color = const Color(0xFFD4DEC8).withValues(alpha: 0.6)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final riverPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.95, size.width, size.height * 0.75);
    canvas.drawPath(riverPath, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
