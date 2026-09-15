import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import '../services/app_state.dart';

// Color tokens matching StayEase Sage + Cream Luxury System
const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kCardAlt = Color(0xFFF0EDE5); // Warm Linen Cream

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  final bool isCompact; // For horizontal lists

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
    this.isCompact = false,
  });

  String _formatPrice(int price) {
    if (price >= 1000) {
      final formatted = (price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1);
      return '${formatted.replaceAll('.0', '')}K';
    }
    return '$price';
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    }
    return _buildStandardCard(context);
  }

  // ── Standard Full-Width Luxury Card ───────────────────────────────────────
  Widget _buildStandardCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF252923).withValues(alpha: 0.05),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hotel Image with Favorite and Badge
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo with fallback gradient (Hero animation for smooth transition)
                      Hero(
                        tag: 'hotel-img-${hotel.id}',
                        child: Image.network(
                          hotel.images.first,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: _kCardAlt,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _kPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stack) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [hotel.heroColor1, hotel.heroColor2],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.apartment_rounded,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Gradient scrim over image bottom for contrast
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF252923).withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Optional Badge: "Top Rated" / "Best Value" / "Popular"
                      if (hotel.badge.isNotEmpty)
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252923).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: _kAccent, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  hotel.badge,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ❤️ Favorite Button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ListenableBuilder(
                          listenable: AppState.instance,
                          builder: (context, _) {
                            final isFav = AppState.instance.isFavorite(hotel.id);
                            return GestureDetector(
                              onTap: () => AppState.instance.toggleFavorite(hotel.id),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF252923).withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border_rounded,
                                    color: isFav ? const Color(0xFFE57373) : Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Hotel Information Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotel.category,
                            style: GoogleFonts.montserrat(
                              color: _kPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: _kAccent, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                '${hotel.rating}',
                                style: GoogleFonts.montserrat(
                                  color: _kText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                ' (${hotel.reviewsCount})',
                                style: GoogleFonts.montserrat(
                                  color: _kTextMuted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Hotel Name
                    Text(
                      hotel.name,
                      style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Location & Distance
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: _kPrimary, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${hotel.location} • "${hotel.distanceDescription}"',
                            style: GoogleFonts.montserrat(
                              color: _kTextMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Amenities (Wi-Fi • Pool • Breakfast • Parking)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: hotel.amenities.take(4).map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kCardAlt,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Text(
                            a,
                            style: GoogleFonts.montserrat(
                              color: _kTextMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Room & Offer Information Pills
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hotel.defaultRoomType,
                            style: GoogleFonts.montserrat(
                              color: _kPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hotel.cancellationPolicy,
                            style: GoogleFonts.montserrat(
                              color: _kPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(color: _kBorder, height: 1),
                    const SizedBox(height: 12),

                    // Pricing & Single Primary CTA: [ View Details ]
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Pricing info
                        Column(
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
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' / night',
                                  style: GoogleFonts.montserrat(
                                    color: _kTextMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${hotel.priceInclTaxes} incl. taxes',
                              style: GoogleFonts.montserrat(
                                color: _kTextFaint,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Primary CTA: [ View Details ]
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            shadowColor: _kPrimary.withValues(alpha: 0.3),
                          ),
                          onPressed: onTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Details',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Compact Horizontal Luxury Card ────────────────────────────────────────
  Widget _buildCompactCard(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14, bottom: 8),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF252923).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with Favorite and Badge
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        hotel.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: hotel.heroColor1,
                        ),
                      ),
                      if (hotel.badge.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252923).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hotel.badge,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252923).withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: _kAccent, size: 11),
                              const SizedBox(width: 2),
                              Text(
                                '${hotel.rating}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 10,
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

              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: GoogleFonts.cormorantGaramond(
                        color: _kText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hotel.location,
                      style: GoogleFonts.montserrat(
                        color: _kTextMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${_formatPrice(hotel.pricePerNight)}',
                          style: GoogleFonts.cormorantGaramond(
                            color: _kText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' /night',
                          style: GoogleFonts.montserrat(
                            color: _kTextFaint,
                            fontSize: 10.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
