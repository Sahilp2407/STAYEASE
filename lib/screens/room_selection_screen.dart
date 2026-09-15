import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_models.dart';
import 'booking_details_screen.dart';

const _kPrimary = Color(0xFF6F8068); // Sage Green
const _kAccent = Color(0xFFC98F65); // Muted Terracotta
const _kText = Color(0xFF252923); // Deep Charcoal
const _kTextMuted = Color(0xFF60675D); // Olive/Charcoal Muted
const _kTextFaint = Color(0xFF8F988A); // Faint Sage Charcoal
const _kBorder = Color(0xFFE5E2D8); // Linen Warm Border
const _kCard = Color(0xFFFFFFFF); // Pure White
const _kCardAlt = Color(0xFFF0EDE5); // Warm Linen Cream
const _kBg = Color(0xFFF7F5EF); // Warm Cream

class RoomSelectionScreen extends StatefulWidget {
  final Hotel hotel;

  const RoomSelectionScreen({super.key, required this.hotel});

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  late Room _selectedRoom;

  @override
  void initState() {
    super.initState();
    // Default to Deluxe King Room or first room
    _selectedRoom = widget.hotel.rooms.length > 1
        ? widget.hotel.rooms[1]
        : widget.hotel.rooms.first;
  }

  void _onProceedToBooking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          hotel: widget.hotel,
          selectedRoom: _selectedRoom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Choose your room',
          style: GoogleFonts.cormorantGaramond(
            color: _kText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hotel Info Bar at top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: _kCard,
              border: Border(bottom: BorderSide(color: _kBorder, width: 0.8)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.network(
                      hotel.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(color: _kPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: GoogleFonts.cormorantGaramond(
                          color: _kText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${hotel.location} • 8 Sep – 10 Sep (2 Nights)',
                        style: GoogleFonts.montserrat(
                          color: _kTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rooms List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: hotel.rooms.length,
              itemBuilder: (ctx, i) {
                final room = hotel.rooms[i];
                final isSelected = room.id == _selectedRoom.id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedRoom = room),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _kCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? _kPrimary : _kBorder,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? _kPrimary.withValues(alpha: 0.15)
                              : const Color(0xFF252923).withValues(alpha: 0.04),
                          blurRadius: isSelected ? 16 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  room.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    color: hotel.heroColor1,
                                    child: const Center(
                                      child: Icon(Icons.bed_rounded, color: Colors.white38, size: 48),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _kPrimary,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Selected',
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontSize: 10.5,
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

                        // Room Info
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      room.name,
                                      style: GoogleFonts.cormorantGaramond(
                                        color: _kText,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${room.pricePerNight}',
                                        style: GoogleFonts.cormorantGaramond(
                                          color: _kAccent,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '/ night',
                                        style: GoogleFonts.montserrat(
                                          color: _kTextFaint,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Capacity & Bed
                              Row(
                                children: [
                                  const Icon(Icons.people_alt_outlined, color: _kPrimary, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${room.capacity} Guests',
                                    style: GoogleFonts.montserrat(
                                      color: _kTextMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Icon(Icons.bed_rounded, color: _kPrimary, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    room.bedType,
                                    style: GoogleFonts.montserrat(
                                      color: _kTextMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Amenities List
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: room.amenities.map((amenity) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check, color: _kPrimary, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        amenity,
                                        style: GoogleFonts.montserrat(
                                          color: _kTextMuted,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),

                              // Cancellation Policy pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _kCardAlt,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  room.cancellationPolicy,
                                  style: GoogleFonts.montserrat(
                                    color: _kPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // [ Select Room ] CTA
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: isSelected
                                    ? ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _kPrimary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: _onProceedToBooking,
                                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                        label: Text(
                                          'Proceed with this Room',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      )
                                    : OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _kPrimary,
                                          side: const BorderSide(color: _kPrimary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() => _selectedRoom = room);
                                        },
                                        child: Text(
                                          'Select Room',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
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
          ),
        ],
      ),
      // Sticky Bottom Summary Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: _kCard,
          border: const Border(top: BorderSide(color: _kBorder)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF252923).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedRoom.name,
                  style: GoogleFonts.montserrat(
                    color: _kText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '₹${_selectedRoom.pricePerNight * 2} for 2 nights',
                  style: GoogleFonts.cormorantGaramond(
                    color: _kAccent,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _onProceedToBooking,
                child: Text(
                  'Continue',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
