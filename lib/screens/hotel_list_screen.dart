import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import '../data/hotel_data.dart';
import '../widgets/hotel_card.dart';
import 'hotel_details_screen.dart';

const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kCardAlt = Color(0xFFF0EDE5); // Warm Linen Cream
const _kBg = Color(0xFFF7F5EF); // Warm Cream

class HotelListScreen extends StatefulWidget {
  final String city;
  final String dateRange;
  final String guestInfo;

  const HotelListScreen({
    super.key,
    this.city = 'Mumbai',
    this.dateRange = '8 Sep – 10 Sep',
    this.guestInfo = '2 Guests • 1 Room',
  });

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  bool _isMapView = false;
  late HotelFilter _filter;
  int _selectedMapHotelIdx = 0;

  @override
  void initState() {
    super.initState();
    _filter = HotelFilter();
  }

  List<Hotel> _getFilteredHotels() {
    return kSampleHotels.where((h) {
      // Filter by min rating
      if (_filter.minRating > 0 && h.rating < _filter.minRating) return false;
      // Filter by price range
      if (h.pricePerNight < _filter.priceRange.start ||
          h.pricePerNight > _filter.priceRange.end) {
        return false;
      }
      // Filter by policies
      if (_filter.policies.contains('Free Cancellation') &&
          !h.cancellationPolicy.toLowerCase().contains('free')) {
        return false;
      }
      if (_filter.policies.contains('Breakfast Included') &&
          !h.breakfastInfo.toLowerCase().contains('breakfast')) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (_filter.sortBy == 'Price: Low to High') {
          return a.pricePerNight.compareTo(b.pricePerNight);
        } else if (_filter.sortBy == 'Price: High to Low') {
          return b.pricePerNight.compareTo(a.pricePerNight);
        } else if (_filter.sortBy == 'Highest Rated') {
          return b.rating.compareTo(a.rating);
        } else if (_filter.sortBy == 'Most Reviewed') {
          return b.reviewsCount.compareTo(a.reviewsCount);
        }
        return 0; // Recommended
      });
  }

  void _openFilterBottomSheet() {
    final tempFilter = _filter.clone();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: GoogleFonts.cormorantGaramond(
                          color: _kText,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempFilter.priceRange = const RangeValues(1000, 30000);
                            tempFilter.minRating = 0.0;
                            tempFilter.amenities.clear();
                            tempFilter.policies.clear();
                            tempFilter.sortBy = 'Recommended';
                          });
                        },
                        child: Text(
                          'Reset',
                          style: GoogleFonts.montserrat(
                            color: _kPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: _kBorder),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // 1. Sort By
                        Text(
                          'Sort By',
                          style: GoogleFonts.montserrat(
                            color: _kText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Recommended',
                            'Price: Low to High',
                            'Price: High to Low',
                            'Highest Rated',
                            'Most Reviewed',
                          ].map((s) {
                            final sel = tempFilter.sortBy == s;
                            return _filterChip(
                              label: s,
                              isSelected: sel,
                              onTap: () => setModalState(() => tempFilter.sortBy = s),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // 2. Price Range
                        Text(
                          'Price Range per night',
                          style: GoogleFonts.montserrat(
                            color: _kText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${tempFilter.priceRange.start.round()}',
                              style: GoogleFonts.cormorantGaramond(
                                color: _kAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '₹${tempFilter.priceRange.end.round()}',
                              style: GoogleFonts.cormorantGaramond(
                                color: _kAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: tempFilter.priceRange,
                          min: 1000,
                          max: 30000,
                          divisions: 29,
                          activeColor: _kPrimary,
                          inactiveColor: _kBorder,
                          onChanged: (vals) {
                            setModalState(() => tempFilter.priceRange = vals);
                          },
                        ),

                        const SizedBox(height: 16),

                        // 3. Minimum Rating
                        Text(
                          'Minimum Rating',
                          style: GoogleFonts.montserrat(
                            color: _kText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _ratingPill(4.5, tempFilter, (val) => setModalState(() => tempFilter.minRating = val)),
                            const SizedBox(width: 8),
                            _ratingPill(4.0, tempFilter, (val) => setModalState(() => tempFilter.minRating = val)),
                            const SizedBox(width: 8),
                            _ratingPill(3.5, tempFilter, (val) => setModalState(() => tempFilter.minRating = val)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 4. Hotel Type
                        Text(
                          'Property Type',
                          style: GoogleFonts.montserrat(
                            color: _kText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Hotel', 'Resort', 'Apartment', 'Villa', 'Château'].map((t) {
                            final sel = tempFilter.hotelTypes.contains(t);
                            return _filterChip(
                              label: t,
                              isSelected: sel,
                              onTap: () {
                                setModalState(() {
                                  if (sel) {
                                    tempFilter.hotelTypes.remove(t);
                                  } else {
                                    tempFilter.hotelTypes.add(t);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // 5. Amenities
                        Text(
                          'Amenities',
                          style: GoogleFonts.montserrat(
                            color: _kText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Wi-Fi', 'Swimming Pool', 'Breakfast', 'Parking', 'Gym', 'Restaurant', 'AC'].map((a) {
                            final sel = tempFilter.amenities.contains(a);
                            return _filterChip(
                              label: a,
                              isSelected: sel,
                              onTap: () {
                                setModalState(() {
                                  if (sel) {
                                    tempFilter.amenities.remove(a);
                                  } else {
                                    tempFilter.amenities.add(a);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // 6. Policies
                        Text(
                          'Policies & Offers',
                          style: GoogleFonts.montserrat(
                            color: _kText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Free Cancellation', 'Breakfast Included', 'Pay at Hotel'].map((p) {
                            final sel = tempFilter.policies.contains(p);
                            return _filterChip(
                              label: p,
                              isSelected: sel,
                              onTap: () {
                                setModalState(() {
                                  if (sel) {
                                    tempFilter.policies.remove(p);
                                  } else {
                                    tempFilter.policies.add(p);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Bottom CTA: [ Apply Filters ]
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        setState(() => _filter = tempFilter);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimary : _kCardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _kPrimary : _kBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : _kText,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _ratingPill(double r, HotelFilter filter, Function(double) onSelect) {
    final sel = filter.minRating == r;
    return GestureDetector(
      onTap: () => onSelect(sel ? 0.0 : r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? _kPrimary : _kCardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? _kPrimary : _kBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.star_rounded, size: 14, color: sel ? Colors.white : _kAccent),
            const SizedBox(width: 4),
            Text(
              '$r+',
              style: GoogleFonts.montserrat(
                color: sel ? Colors.white : _kText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotels = _getFilteredHotels();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Section Header (Section 3)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: _kCard,
                border: Border(bottom: BorderSide(color: _kBorder, width: 0.8)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kCardAlt,
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: _kText, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: _kPrimary, size: 15),
                                const SizedBox(width: 3),
                                Text(
                                  widget.city,
                                  style: GoogleFonts.cormorantGaramond(
                                    color: _kText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${widget.dateRange} • ${widget.guestInfo}',
                              style: GoogleFonts.montserrat(
                                color: _kTextMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Subtle List/Map Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: _kCardAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Row(
                          children: [
                            _viewToggleBtn(Icons.view_list_rounded, 'List', !_isMapView, () {
                              setState(() => _isMapView = false);
                            }),
                            _viewToggleBtn(Icons.map_outlined, 'Map', _isMapView, () {
                              setState(() => _isMapView = true);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // "125 hotels found" and [ Filter ] [ Sort ] Buttons
                  Row(
                    children: [
                      Text(
                        '${hotels.length} luxury stays found',
                        style: GoogleFonts.montserrat(
                          color: _kTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Filter Button
                      GestureDetector(
                        onTap: _openFilterBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _filter.policies.isNotEmpty || _filter.minRating > 0
                                ? _kPrimary.withValues(alpha: 0.12)
                                : _kCardAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _filter.policies.isNotEmpty || _filter.minRating > 0
                                  ? _kPrimary
                                  : _kBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded,
                                  color: _filter.policies.isNotEmpty || _filter.minRating > 0
                                      ? _kPrimary
                                      : _kText,
                                  size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Filter',
                                style: GoogleFonts.montserrat(
                                  color: _filter.policies.isNotEmpty || _filter.minRating > 0
                                      ? _kPrimary
                                      : _kText,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort Button
                      GestureDetector(
                        onTap: _openFilterBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _kCardAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sort_rounded, color: _kText, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Sort',
                                style: GoogleFonts.montserrat(
                                  color: _kText,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Body: List or Map View
            Expanded(
              child: _isMapView
                  ? _buildMapView(hotels)
                  : _buildListView(hotels),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewToggleBtn(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : _kTextMuted),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : _kTextMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Hotel> hotels) {
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: _kTextFaint),
            const SizedBox(height: 12),
            Text(
              'No hotels match your filters',
              style: GoogleFonts.cormorantGaramond(
                color: _kText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try clearing some filters to see available sanctuaries.',
              style: GoogleFonts.montserrat(color: _kTextMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: hotels.length,
      itemBuilder: (ctx, i) {
        final hotel = hotels[i];
        return HotelCard(
          hotel: hotel,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HotelDetailsScreen(hotel: hotel),
              ),
            );
          },
        );
      },
    );
  }

  // Interactive Luxury Map Preview
  Widget _buildMapView(List<Hotel> hotels) {
    if (hotels.isEmpty) return _buildListView(hotels);
    final activeHotel = hotels[_selectedMapHotelIdx % hotels.length];

    return Stack(
      children: [
        // Simulated map canvas
        Positioned.fill(
          child: CustomPaint(
            painter: _FullMapPainter(),
          ),
        ),

        // Interactive Hotel Pins on Map
        ...List.generate(hotels.length, (i) {
          final h = hotels[i];
          final isSelected = i == _selectedMapHotelIdx;
          final offsets = [
            const Offset(0.32, 0.28),
            const Offset(0.68, 0.35),
            const Offset(0.48, 0.52),
            const Offset(0.24, 0.65),
            const Offset(0.72, 0.68),
            const Offset(0.42, 0.80),
          ];
          final pos = offsets[i % offsets.length];

          return Positioned(
            left: MediaQuery.of(context).size.width * pos.dx - 36,
            top: (MediaQuery.of(context).size.height - 240) * pos.dy - 18,
            child: GestureDetector(
              onTap: () => setState(() => _selectedMapHotelIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? _kText : _kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _kPrimary : _kBorder,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 12, color: isSelected ? _kAccent : _kPrimary),
                    const SizedBox(width: 3),
                    Text(
                      '₹${(h.pricePerNight / 1000).toStringAsFixed(1)}K',
                      style: GoogleFonts.montserrat(
                        color: isSelected ? Colors.white : _kText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Bottom Swipeable Selected Hotel Card
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: HotelCard(
            hotel: activeHotel,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HotelDetailsScreen(hotel: activeHotel),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Full Map Canvas Painter
class _FullMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEBE6DA);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final p1 = Path()
      ..moveTo(0, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.3);
    canvas.drawPath(p1, road);

    final p2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.5, size.height);
    canvas.drawPath(p2, road);

    final water = Paint()
      ..color = const Color(0xFFD3DEC8).withValues(alpha: 0.7)
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke;

    final waterPath = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.8, size.width, size.height * 0.55);
    canvas.drawPath(waterPath, water);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
