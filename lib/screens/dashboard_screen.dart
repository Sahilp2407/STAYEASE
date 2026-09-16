import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import '../data/hotel_data.dart';
import '../services/app_state.dart';
import '../widgets/hotel_card.dart';
import 'hotel_details_screen.dart';
import 'hotel_list_screen.dart';
import 'my_bookings_screen.dart';
import 'auth_screen.dart';
import 'plans/plans_hub_screen.dart';

// ─── Color Palette: Sage + Cream Boutique ──────────────────────────────────
const kBg = Color(0xFFF7F5EF); // Warm Cream
const kCard = Color(0xFFFFFFFF); // Pure White
const kCardAlt = Color(0xFFF0EDE5); // Warm Linen Cream
const kPrimary = Color(0xFF6F8068); // Sage Green
const kSecondary = Color(0xFFA8B5A0); // Soft Sage
const kAccent = Color(0xFFC98F65); // Muted Terracotta
const kAccentLight = Color(0xFFDFC0A4);
const kText = Color(0xFF252923); // Deep Charcoal
const kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const kBorderSage = Color(0x336F8068);
const kBorderAccent = Color(0x33C98F65);

// Compatibility aliases for primary styling
const kGold = kPrimary;
const kGoldLight = kSecondary;
const kGoldDark = Color(0xFF556350);
const kBorderGold = kBorderSage;

// ─── Data Models ─────────────────────────────────────────────────────────────
class Destination {
  final String city;
  final String state;
  final int hotels;
  final String emoji;
  final Color accent;

  const Destination({
    required this.city,
    required this.state,
    required this.hotels,
    required this.emoji,
    required this.accent,
  });
}

class LuxuryProperty {
  final String name;
  final String subtitle;
  final String location;
  final double rating;
  final int reviews;
  final int pricePerNight;
  final List<String> tags;
  final Color heroColor1;
  final Color heroColor2;
  final String category;

  const LuxuryProperty({
    required this.name,
    required this.subtitle,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.pricePerNight,
    required this.tags,
    required this.heroColor1,
    required this.heroColor2,
    required this.category,
  });
}

// ─── Static Data: Boutique Sanctuaries ─────────────────────────────────────────
final _destinations = [
  const Destination(city: 'Udaipur', state: 'Rajasthan', hotels: 62, emoji: '🏰', accent: Color(0xFFC98F65)),
  const Destination(city: 'Jaipur', state: 'Rajasthan', hotels: 54, emoji: '🕌', accent: Color(0xFFB57C58)),
  const Destination(city: 'Goa', state: 'North Goa', hotels: 78, emoji: '🌴', accent: Color(0xFF6F8068)),
  const Destination(city: 'Shimla', state: 'Himachal', hotels: 41, emoji: '🏔️', accent: Color(0xFF5D737E)),
  const Destination(city: 'Coorg', state: 'Karnataka', hotels: 35, emoji: '☕', accent: Color(0xFF627357)),
  const Destination(city: 'Mussoorie', state: 'Uttarakhand', hotels: 29, emoji: '🌿', accent: Color(0xFF7A8B73)),
];

final _featuredProperty = const LuxuryProperty(
  name: 'The Oberoi Udaivilas',
  subtitle: 'Palace Resort',
  location: 'Udaipur, Rajasthan',
  rating: 4.91,
  reviews: 1261,
  pricePerNight: 48500,
  tags: ['Private Pool', 'Lake View', 'Butler Service'],
  heroColor1: Color(0xFF6F8068),
  heroColor2: Color(0xFF4C5847),
  category: 'Palace Resort',
);

final _recommendedStays = [
  const LuxuryProperty(
    name: 'Taj Lake Palace',
    subtitle: 'Floating Heritage',
    location: 'Lake Pichola, Udaipur',
    rating: 4.9,
    reviews: 870,
    pricePerNight: 56000,
    tags: ['Private Suites', 'Royal Boat Transfer'],
    heroColor1: Color(0xFFC98F65),
    heroColor2: Color(0xFF8B5E3C),
    category: 'FREE CANCELLATION',
  ),
  const LuxuryProperty(
    name: 'Amanbagh Luxury Oasis',
    subtitle: 'Desert Sanctuary',
    location: 'Ajabgarh, Sikar',
    rating: 4.8,
    reviews: 325,
    pricePerNight: 64200,
    tags: ['Ayurvedic Spa', 'Private Pool Villa'],
    heroColor1: Color(0xFF7E8D77),
    heroColor2: Color(0xFF505F4A),
    category: 'BREAKFAST INCLUDED',
  ),
  const LuxuryProperty(
    name: 'Wildflower Hall',
    subtitle: 'An Oberoi Resort',
    location: 'Mashobra, Shimla',
    rating: 4.85,
    reviews: 612,
    pricePerNight: 38000,
    tags: ['Heated Infinity Pool', 'Mountain Rails'],
    heroColor1: Color(0xFF5A7265),
    heroColor2: Color(0xFF384940),
    category: '',
  ),
];

final _recentlyViewed = [
  const LuxuryProperty(
    name: 'Rambagh Palace',
    subtitle: 'Taj Hotels',
    location: 'Jaipur',
    rating: 4.9,
    reviews: 982,
    pricePerNight: 52000,
    tags: [],
    heroColor1: Color(0xFFB57C58),
    heroColor2: Color(0xFF7A4B2E),
    category: '',
  ),
  const LuxuryProperty(
    name: 'The Leela Palace',
    subtitle: 'New Delhi',
    location: 'New Delhi',
    rating: 4.8,
    reviews: 741,
    pricePerNight: 48000,
    tags: [],
    heroColor1: Color(0xFF6F8068),
    heroColor2: Color(0xFF43503E),
    category: '',
  ),
  const LuxuryProperty(
    name: 'RAAS Jodhpur',
    subtitle: 'Heritage Haveli',
    location: 'Jodhpur, Rajasthan',
    rating: 4.75,
    reviews: 430,
    pricePerNight: 32000,
    tags: [],
    heroColor1: Color(0xFF8F7B6B),
    heroColor2: Color(0xFF5C4B3E),
    category: '',
  ),
];

// ─── Dashboard Screen ─────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;
  int _selectedDestIdx = 0;
  final _searchController = TextEditingController();
  bool _searchFocused = false;

  DateTime _checkIn = DateTime.now().add(const Duration(days: 2));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 5));
  int _adults = 2;
  int _suites = 1;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 5, 222, 229),
              onPrimary: Colors.white,
              surface: kCard,
              onSurface: kText,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: kBg),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut.isBefore(_checkIn.add(const Duration(days: 1)))) {
            _checkOut = _checkIn.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_checkIn)) {
            _checkOut = picked;
          }
        }
      });
    }
  }

  void _showGuestPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GuestPickerSheet(
        adults: _adults,
        suites: _suites,
        onChanged: (a, s) => setState(() {
          _adults = a;
          _suites = s;
        }),
      ),
    );
  }

  Hotel _findHotel(String name) {
    return kSampleHotels.firstWhere(
      (h) =>
          h.name.toLowerCase().contains(name.toLowerCase()) ||
          name.toLowerCase().contains(h.name.toLowerCase()),
      orElse: () => kSampleHotels.first,
    );
  }

  void _openHotelList({String? initialCity}) {
    final city = initialCity ?? _destinations[_selectedDestIdx].city;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelListScreen(
          city: city,
          dateRange: '${_formatDate(_checkIn)} – ${_formatDate(_checkOut)}',
          guestInfo: '$_adults Adults • $_suites Suite${_suites > 1 ? 's' : ''}',
        ),
      ),
    );
  }

  void _onSearch() {
    _openHotelList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return const PlansHubScreen();
      case 3:
        return _buildSavedTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  // ── HOME TAB ─────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar
        SliverToBoxAdapter(child: _buildAppBar()),

        // Search Section
        SliverToBoxAdapter(child: _buildSearchSection()),

        // Popular Escapes
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Popular Escapes',
            subtitle: 'Handpicked boutique destinations for this season',
          ),
        ),
        SliverToBoxAdapter(child: _buildDestinationsRow()),

        // Featured Sanctuary
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Featured Sanctuary',
            subtitle: "Curator's Pick",
            trailing: 'VIEW ALL',
            onTrailingTap: () => _openHotelList(),
          ),
        ),
        SliverToBoxAdapter(child: _buildFeaturedCard()),

        // Popular Hotels (Horizontal Carousel)
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Popular Hotels',
            subtitle: 'Trending luxury destinations this week',
            trailing: 'VIEW ALL',
            onTrailingTap: () => _openHotelList(),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 295,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: kSampleHotels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (ctx, i) {
                final h = kSampleHotels[i];
                return HotelCard(
                  hotel: h,
                  isCompact: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HotelDetailsScreen(hotel: h),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Recommended Stays
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Recommended Stays',
            subtitle: 'Unmatched comfort and personalised boutique service',
            trailing: 'VIEW ALL',
            onTrailingTap: () => _openHotelList(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final h = kSampleHotels[i % kSampleHotels.length];
              return HotelCard(
                hotel: h,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HotelDetailsScreen(hotel: h),
                  ),
                ),
              );
            },
            childCount: 3,
          ),
        ),

        // Hotels Near You
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Hotels Near You',
            subtitle: 'Prime sanctuary stays within easy reach',
            trailing: 'VIEW ALL',
            onTrailingTap: () => _openHotelList(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final h = kSampleHotels[(i + 3) % kSampleHotels.length];
              return HotelCard(
                hotel: h,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HotelDetailsScreen(hotel: h),
                  ),
                ),
              );
            },
            childCount: 2,
          ),
        ),

        // Best Rated Sanctuaries
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Best Rated Sanctuaries',
            subtitle: 'Properties boasting 4.8+ stellar guest reviews',
            trailing: 'VIEW ALL',
            onTrailingTap: () => _openHotelList(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final highRated =
                  kSampleHotels.where((h) => h.rating >= 4.8).toList();
              final h = highRated[i % highRated.length];
              return HotelCard(
                hotel: h,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HotelDetailsScreen(hotel: h),
                  ),
                ),
              );
            },
            childCount: math.min(
                3, kSampleHotels.where((h) => h.rating >= 4.8).length),
          ),
        ),

        // Recently Viewed
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            'Recently Viewed',
            subtitle: 'Because you left off here',
            trailing: '♡',
          ),
        ),
        SliverToBoxAdapter(child: _buildRecentlyViewed()),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 16),
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo + Brand
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kCard,
                      border: Border.all(color: kPrimary, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style: GoogleFonts.cormorantGaramond(
                          color: kPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'StayEase',
                    style: GoogleFonts.cormorantGaramond(
                      color: kText,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Notification Bell
              _iconBtn(Icons.notifications_outlined, () {
                _showComingSoon('Notifications');
              }),
              const SizedBox(width: 10),
              // Profile Avatar
              GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = 4),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kCard,
                    border: Border.all(color: kPrimary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF252923).withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'S',
                      style: GoogleFonts.montserrat(
                        color: kPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Good morning, Sahil 👋',
            style: GoogleFonts.montserrat(
              color: kTextMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Where would you like\nto escape?',
            style: GoogleFonts.cormorantGaramond(
              color: kText,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Location chip
          GestureDetector(
            onTap: () => _showDestinationPicker(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF252923).withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, color: kPrimary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${_destinations[_selectedDestIdx].city}, ${_destinations[_selectedDestIdx].state}',
                    style: GoogleFonts.montserrat(
                      color: kText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: kTextFaint, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH SECTION ────────────────────────────────────────────────────────
  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _searchFocused ? kPrimary : kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF252923).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search TextField
          Focus(
            onFocusChange: (v) => setState(() => _searchFocused = v),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.montserrat(color: kText, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search boutique hotels, châteaux & villas...',
                hintStyle: GoogleFonts.montserrat(color: kTextFaint, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: kPrimary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: kTextMuted, size: 18),
                        onPressed: () => setState(() => _searchController.clear()),
                      )
                    : null,
                filled: true,
                fillColor: kCardAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() {}),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(height: 12),

          // Dates Row
          Row(
            children: [
              Expanded(
                child: _dateChip(
                  icon: Icons.flight_land_outlined,
                  label: 'CHECK IN',
                  value: _formatDate(_checkIn),
                  onTap: () => _pickDate(isCheckIn: true),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: kBorder,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _dateChip(
                  icon: Icons.flight_takeoff_outlined,
                  label: 'CHECK OUT',
                  value: _formatDate(_checkOut),
                  onTap: () => _pickDate(isCheckIn: false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Guests Row
          GestureDetector(
            onTap: _showGuestPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kCardAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: kPrimary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '$_adults Adults • $_suites Suite${_suites > 1 ? 's' : ''}',
                    style: GoogleFonts.montserrat(
                      color: kText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.tune, color: kTextFaint, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Search CTA
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                shadowColor: kPrimary.withValues(alpha: 0.35),
              ),
              onPressed: _onSearch,
              icon: const Icon(Icons.search, size: 18),
              label: Text(
                'Search Stays',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DATE CHIP ─────────────────────────────────────────────────────────────
  Widget _dateChip({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kCardAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimary, size: 13),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: kTextFaint,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.cormorantGaramond(
                color: kText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title,
      {String? subtitle, String? trailing, VoidCallback? onTrailingTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cormorantGaramond(
                    color: kText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      color: kTextMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap ?? () => _openHotelList(),
              child: Text(
                trailing,
                style: GoogleFonts.montserrat(
                  color: kPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── DESTINATIONS ROW ─────────────────────────────────────────────────────
  Widget _buildDestinationsRow() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _destinations.length,
        itemBuilder: (ctx, i) {
          final d = _destinations[i];
          final selected = i == _selectedDestIdx;
          return GestureDetector(
            onTap: () => setState(() => _selectedDestIdx = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? kPrimary : kBorder,
                  width: selected ? 1.8 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? kPrimary.withValues(alpha: 0.22)
                        : const Color(0xFF252923).withValues(alpha: 0.04),
                    blurRadius: selected ? 12 : 6,
                    spreadRadius: selected ? 1 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 5),
                  Text(
                    d.city,
                    style: GoogleFonts.montserrat(
                      color: selected ? kPrimary : kText,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${d.hotels} Stays',
                    style: GoogleFonts.montserrat(
                      color: kTextFaint,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── FEATURED CARD ─────────────────────────────────────────────────────────
  Widget _buildFeaturedCard() {
    final p = _featuredProperty;
    return GestureDetector(
      onTap: () => _openPropertyDetail(p),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.heroColor1, p.heroColor2],
          ),
          boxShadow: [
            BoxShadow(
              color: p.heroColor1.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative arches
            Positioned.fill(
              child: CustomPaint(painter: _PalacePainter(color: p.heroColor1)),
            ),
            // Rating Badge
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF252923).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: kAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${p.rating}',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '  ${_formatReviews(p.reviews)} Reviews',
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Wishlist
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF252923).withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
              ),
            ),
            // Bottom Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF252923).withValues(alpha: 0.88),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tag(p.subtitle),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      p.location,
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${_formatPrice(p.pricePerNight)}',
                          style: GoogleFonts.cormorantGaramond(
                            color: kAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' /night',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFFE5E2D8),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        _exploreBtn(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── RECENTLY VIEWED ───────────────────────────────────────────────────────
  Widget _buildRecentlyViewed() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recentlyViewed.length,
        itemBuilder: (ctx, i) {
          final p = _recentlyViewed[i];
          return GestureDetector(
            onTap: () => _openPropertyDetail(p),
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF252923).withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [p.heroColor1, p.heroColor2],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PalacePainter(color: p.heroColor1),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: kAccent, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  '${p.rating}',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: GoogleFonts.cormorantGaramond(
                            color: kText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '₹${_formatPrice(p.pricePerNight)}',
                          style: GoogleFonts.montserrat(
                            color: kAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.explore_outlined, Icons.explore, 'Explore'),
      (Icons.map_outlined, Icons.map, 'Plans'),
      (Icons.favorite_border, Icons.favorite, 'Saved'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        border: const Border(top: BorderSide(color: kBorder, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF252923).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == _selectedNavIndex;
              final item = items[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedNavIndex = i),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.$2 : item.$1,
                        color: selected ? kPrimary : kTextFaint,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        style: GoogleFonts.montserrat(
                          color: selected ? kPrimary : kTextFaint,
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── EXPLORE TAB ───────────────────────────────────────────────────────────
  Widget _buildExploreTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 16),
            color: kBg,
            child: Text(
              'Explore',
              style: GoogleFonts.cormorantGaramond(
                color: kText,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final all = [..._recommendedStays, ..._recentlyViewed];
                final p = all[i % all.length];
                return GestureDetector(
                  onTap: () => _openPropertyDetail(p),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [p.heroColor1, p.heroColor2],
                      ),
                      border: Border.all(color: kBorder),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF252923).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _PalacePainter(color: p.heroColor1),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF252923).withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: GoogleFonts.cormorantGaramond(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '₹${_formatPrice(p.pricePerNight)}/night',
                                  style: GoogleFonts.montserrat(
                                    color: kAccent,
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
                );
              },
              childCount: 8,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // ── SAVED TAB ─────────────────────────────────────────────────────────────
  Widget _buildSavedTab() {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final savedHotels =
            kSampleHotels.where((h) => appState.isFavorite(h.id)).toList();

        if (savedHotels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, color: kAccent, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Your Wishlist',
                  style: GoogleFonts.cormorantGaramond(
                    color: kText,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save properties to revisit later',
                  style: GoogleFonts.montserrat(color: kTextMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  onPressed: () => setState(() => _selectedNavIndex = 0), // Home
                  child: Text(
                    'Explore Properties',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Sanctuaries',
                      style: GoogleFonts.cormorantGaramond(
                        color: kText,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${savedHotels.length} luxury stays in your wishlist',
                      style: GoogleFonts.montserrat(
                        color: kTextMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final h = savedHotels[i];
                  return HotelCard(
                    hotel: h,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetailsScreen(hotel: h),
                      ),
                    ),
                  );
                },
                childCount: savedHotels.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        );
      },
    );
  }

  // ── PROFILE TAB ───────────────────────────────────────────────────────────
  Widget _buildProfileTab() {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 24, 20, 24),
                decoration: const BoxDecoration(
                  color: kCard,
                  border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kCardAlt,
                        border: Border.all(color: kPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          appState.userName.isNotEmpty
                              ? appState.userName[0].toUpperCase()
                              : 'G',
                          style: GoogleFonts.cormorantGaramond(
                            color: kPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.userName,
                            style: GoogleFonts.cormorantGaramond(
                              color: kText,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            appState.isLoggedIn
                                ? 'Connoisseur Member • Boutique Tier'
                                : 'Guest Explorer',
                            style: GoogleFonts.montserrat(
                              color: kAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            appState.userEmail,
                            style: GoogleFonts.montserrat(
                              color: kTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _profileTile(
                  Icons.card_travel_outlined,
                  'My Bookings',
                  '${appState.bookings.length} reservations • View & manage',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyBookingsScreen(),
                    ),
                  ),
                ),
                _profileTile(
                  Icons.favorite_outline,
                  'Wishlist',
                  '${appState.favoriteHotelIds.length} saved sanctuaries',
                  onTap: () => setState(() => _selectedNavIndex = 3), // Saved
                ),
                _profileTile(
                  Icons.loyalty_outlined,
                  'Rewards',
                  '4,200 points available',
                ),
                _profileTile(
                  Icons.settings_outlined,
                  'Settings',
                  'Preferences & notifications',
                ),
                _profileTile(
                  Icons.help_outline,
                  'Concierge Support',
                  '24/7 personal assistance',
                ),
                if (appState.isLoggedIn)
                  _profileTile(
                    Icons.logout_outlined,
                    'Sign Out',
                    'Switch to guest browsing mode',
                    isDestructive: true,
                    onTap: () {
                      appState.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Signed out. You are now browsing as Guest.',
                            style: GoogleFonts.montserrat(color: kBg),
                          ),
                          backgroundColor: kText,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  )
                else
                  _profileTile(
                    Icons.login_outlined,
                    'Sign In',
                    'Access your bookings and member perks',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AuthScreen(),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _profileTile(
    IconData icon,
    String title,
    String sub, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? (isDestructive ? null : () => _showComingSoon(title)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: kCard,
          border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.redAccent : kPrimary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      color: isDestructive ? Colors.redAccent : kText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      style: GoogleFonts.montserrat(
                        color: kTextMuted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.arrow_forward_ios, color: kTextFaint, size: 14),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF252923).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _exploreBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Explore',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kCard,
          shape: BoxShape.circle,
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF252923).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: kText, size: 18),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K'
          .replaceAll('.0K', 'K');
    }
    return '$price';
  }

  String _formatReviews(int r) {
    if (r >= 1000) return '${(r / 1000).toStringAsFixed(1)}K';
    return '$r';
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature — Coming soon!',
          style: GoogleFonts.montserrat(color: kBg, fontSize: 12),
        ),
        backgroundColor: kText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openPropertyDetail(LuxuryProperty p) {
    final hotel = _findHotel(p.name);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelDetailsScreen(hotel: hotel),
      ),
    );
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: kBorder, width: 1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Choose Destination',
                style: GoogleFonts.cormorantGaramond(
                    color: kText, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _destinations.length,
                itemBuilder: (ctx, i) {
                  final d = _destinations[i];
                  final isSelected = i == _selectedDestIdx;
                  return ListTile(
                    leading: Text(d.emoji,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(d.city,
                        style: GoogleFonts.montserrat(
                            color: isSelected ? kPrimary : kText,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600)),
                    subtitle: Text('${d.state} • ${d.hotels} boutique stays',
                        style: GoogleFonts.montserrat(
                            color: kTextMuted, fontSize: 11)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: kPrimary, size: 20)
                        : null,
                    onTap: () {
                      setState(() => _selectedDestIdx = i);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guest Picker Sheet ───────────────────────────────────────────────────────
class _GuestPickerSheet extends StatefulWidget {
  final int adults;
  final int suites;
  final void Function(int adults, int suites) onChanged;

  const _GuestPickerSheet({
    required this.adults,
    required this.suites,
    required this.onChanged,
  });

  @override
  State<_GuestPickerSheet> createState() => _GuestPickerSheetState();
}

class _GuestPickerSheetState extends State<_GuestPickerSheet> {
  late int _adults;
  late int _suites;

  @override
  void initState() {
    super.initState();
    _adults = widget.adults;
    _suites = widget.suites;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: kBorder, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Guests & Rooms',
            style: GoogleFonts.cormorantGaramond(
              color: kText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _counterRow('Adults', _adults, min: 1, max: 10,
              onDec: () => setState(() => _adults = math.max(1, _adults - 1)),
              onInc: () => setState(() => _adults = math.min(10, _adults + 1))),
          const Divider(color: kBorder, height: 24),
          _counterRow('Suites', _suites, min: 1, max: 5,
              onDec: () => setState(() => _suites = math.max(1, _suites - 1)),
              onInc: () => setState(() => _suites = math.min(5, _suites + 1))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                widget.onChanged(_adults, _suites);
                Navigator.pop(context);
              },
              child: Text(
                'Apply',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _counterRow(String label, int value,
      {required int min,
      required int max,
      required VoidCallback onDec,
      required VoidCallback onInc}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              color: kText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _counterBtn(Icons.remove, value > min ? onDec : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$value',
            style: GoogleFonts.cormorantGaramond(
              color: kText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _counterBtn(Icons.add, value < max ? onInc : null),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null ? kPrimary.withValues(alpha: 0.12) : kBg,
          border: Border.all(
            color: onTap != null ? kPrimary : kBorder,
          ),
        ),
        child: Icon(icon,
            color: onTap != null ? kPrimary : kTextFaint, size: 16),
      ),
    );
  }
}

// ─── Palace Painter (decorative boutique line art) ────────────────────────────
class _PalacePainter extends CustomPainter {
  final Color color;
  _PalacePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Large decorative arc
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.2),
        width: size.width * 1.4,
        height: size.width * 1.4,
      ),
      math.pi * 0.2,
      math.pi * 0.6,
      false,
      stroke,
    );

    // Small circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.1 + i * 0.2),
          size.height * 0.15,
        ),
        6 + i * 2.0,
        paint,
      );
    }

    // Bottom gradient overlay lines
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(0, size.height * (0.6 + i * 0.12)),
        Offset(size.width, size.height * (0.6 + i * 0.12)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_PalacePainter old) => old.color != color;
}
