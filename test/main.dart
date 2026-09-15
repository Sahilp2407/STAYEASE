import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0B0E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const StayEaseApp());
}

class StayEaseApp extends StatelessWidget {
  const StayEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STAYEASE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0B0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF0A0B0E),
        ),
      ),
      home: const LuxurySplashScreen(),
    );
  }
}

class LuxurySplashScreen extends StatefulWidget {
  const LuxurySplashScreen({super.key});

  @override
  State<LuxurySplashScreen> createState() => _LuxurySplashScreenState();
}

class _LuxurySplashScreenState extends State<LuxurySplashScreen>
    with TickerProviderStateMixin {
  // Staggered entrance animation
  late AnimationController _entranceController;
  late Animation<double> _bgFadeAnimation;
  late Animation<double> _topBarFadeAnimation;
  late Animation<Offset> _topBarSlideAnimation;
  late Animation<double> _emblemScaleAnimation;
  late Animation<double> _emblemFadeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _ctaFadeAnimation;
  late Animation<Offset> _ctaSlideAnimation;
  late Animation<double> _footerFadeAnimation;

  // Continuous luxury idle animations
  late AnimationController _ambientGlowController;
  late AnimationController _shimmerController;
  late AnimationController _particlesController;
  late AnimationController _arrowBounceController;

  bool _isEnteringConcierge = false;

  @override
  void initState() {
    super.initState();

    // 1. Entrance choreography
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _bgFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _topBarFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _topBarSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    _emblemScaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutBack),
      ),
    );
    _emblemFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.65, curve: Curves.easeIn),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
      ),
    );
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 0.95, curve: Curves.easeIn),
      ),
    );

    _ctaFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );
    _ctaSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.75, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    // 2. Ambient breathing gold halo (2.8s reverse repeat)
    _ambientGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // 3. Shimmer light sweep (3.5s repeat)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    // 4. Subtle stardust particle drift (10s repeat)
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 5. Arrow gentle prompt bounce (1.4s repeat)
    _arrowBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ambientGlowController.dispose();
    _shimmerController.dispose();
    _particlesController.dispose();
    _arrowBounceController.dispose();
    super.dispose();
  }

  void _onEnterConcierge() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isEnteringConcierge = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Show luxury concierge dialog preview
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Concierge',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return const LuxuryConciergeModal();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isEnteringConcierge = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B0E),
      body: Stack(
        children: [
          // Dynamic Stardust / Luxury Particle Canvas
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: StardustLuxuryPainter(
                  progress: _particlesController.value,
                  opacity: _bgFadeAnimation.value,
                ),
              );
            },
          ),

          // Warm Ambient Halo in the upper-center
          AnimatedBuilder(
            animation: Listenable.merge([_ambientGlowController, _entranceController]),
            builder: (context, child) {
              final breath = _ambientGlowController.value;
              final scale = _bgFadeAnimation.value;
              return Positioned(
                top: size.height * 0.18,
                left: size.width * 0.5 - (160 + breath * 20),
                child: Opacity(
                  opacity: (0.45 + breath * 0.25) * scale,
                  child: Container(
                    width: (160 + breath * 20) * 2,
                    height: (160 + breath * 20) * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFC5A059).withValues(alpha: 0.28),
                          const Color(0xFF8C733E).withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Main Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // TOP BAR: Sanctuary Mode & Cities
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _topBarFadeAnimation,
                        child: SlideTransition(
                          position: _topBarSlideAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: _buildTopBar(),
                  ),

                  const Spacer(flex: 2),

                  // CENTER PIECE: Glowing Emblem with "S" Monogram
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _entranceController,
                      _ambientGlowController,
                      _shimmerController,
                    ]),
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _emblemFadeAnimation,
                        child: Transform.scale(
                          scale: _emblemScaleAnimation.value,
                          child: _buildLuxuryEmblem(
                            glowBreath: _ambientGlowController.value,
                            shimmerProgress: _shimmerController.value,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 38),

                  // BRAND TITLE: "STAYEASE"
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _titleFadeAnimation,
                        child: SlideTransition(
                          position: _titleSlideAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: _buildBrandTitle(),
                  ),

                  const SizedBox(height: 14),

                  // SUBTITLE & DIVIDERS: "CURATED LUXURY SANCTUARIES"
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _subtitleFadeAnimation,
                        child: child,
                      );
                    },
                    child: _buildSubtitleSection(),
                  ),

                  const SizedBox(height: 32),

                  // INDICATOR DOTS & GOLDEN ACCENT LINE
                  AnimatedBuilder(
                    animation: Listenable.merge([_subtitleFadeAnimation, _shimmerController]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _subtitleFadeAnimation.value,
                        child: _buildIndicators(),
                      );
                    },
                  ),

                  const Spacer(flex: 3),

                  // CTA BUTTON: "TAP TO ENTER CONCIERGE →"
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _entranceController,
                      _arrowBounceController,
                    ]),
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _ctaFadeAnimation,
                        child: SlideTransition(
                          position: _ctaSlideAnimation,
                          child: _buildConciergeButton(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // FOOTER: Craftsmanship & Destinations
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _footerFadeAnimation,
                        child: child,
                      );
                    },
                    child: _buildFooter(),
                  ),

                  SizedBox(height: padding.bottom > 0 ? 8 : 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TOP BAR WIDGET
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sanctuary Mode Indicator
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD4AF37),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD4AF37),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SANCTUARY MODE',
              style: GoogleFonts.montserrat(
                color: const Color(0xFFC5A059),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),

        // Cities & Sanctuary Beacon Icon
        Row(
          children: [
            CustomPaint(
              size: const Size(14, 14),
              painter: BeaconRingsPainter(color: const Color(0xFFC5A059)),
            ),
            const SizedBox(width: 6),
            Text(
              'Mumbai • Nagpur • Pune',
              style: GoogleFonts.montserrat(
                color: const Color(0xFFB5A995),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // EMBLEM WITH GOLDEN HEXAGONAL SHIELD & "S" MONOGRAM
  Widget _buildLuxuryEmblem({
    required double glowBreath,
    required double shimmerProgress,
  }) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Outer warm gold halo glow
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.18 + glowBreath * 0.14),
            blurRadius: 42 + glowBreath * 12,
            spreadRadius: 2 + glowBreath * 4,
          ),
          // Deep drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background dark shield disc with subtle radial gradient
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.3),
                radius: 0.85,
                colors: [
                  const Color(0xFF28292E),
                  const Color(0xFF141519),
                  const Color(0xFF0D0E12),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              border: Border.all(
                color: const Color(0xFFC5A059).withValues(alpha: 0.18),
                width: 1.0,
              ),
            ),
          ),

          // Inner Hexagonal Golden Badge & Monogram
          SizedBox(
            width: 86,
            height: 86,
            child: CustomPaint(
              painter: LuxuryHexagonBadgePainter(
                shimmerProgress: shimmerProgress,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BRAND TITLE
  Widget _buildBrandTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7EEDD),
            Color(0xFFE2D1B3),
          ],
          stops: [0.0, 0.6, 1.0],
        ).createShader(bounds);
      },
      child: Text(
        'S T A Y E A S E',
        textAlign: TextAlign.center,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          letterSpacing: 9.0,
          height: 1.1,
          color: Colors.white,
          shadows: [
            Shadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  // SUBTITLE WITH FINE GOLD HORIZONTAL DIVIDERS
  Widget _buildSubtitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left hairline divider
        Expanded(
          child: Container(
            height: 1.0,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Color(0x33C5A059),
                  Color(0xFFC5A059),
                ],
              ),
            ),
          ),
        ),

        // Subtitle Text
        Text(
          'CURATED LUXURY\nSANCTUARIES',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: const Color(0xFFD8BC86),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.8,
            height: 1.45,
          ),
        ),

        // Right hairline divider
        Expanded(
          child: Container(
            height: 1.0,
            margin: const EdgeInsets.only(left: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFC5A059),
                  Color(0x33C5A059),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3 DOTS & GOLDEN ACCENT UNDERLINE
  Widget _buildIndicators() {
    return Column(
      children: [
        // 3 Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8F7B56).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 6.5,
              height: 6.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE2C48D),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD4AF37),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8F7B56).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Fine metallic accent line
        Container(
          width: 180,
          height: 1.6,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0x33C5A059),
                Color(0xFFE6CCA0),
                Color(0xFFC5A059),
                Color(0x33C5A059),
                Colors.transparent,
              ],
              stops: [0.0, 0.2, 0.5, 0.65, 0.85, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // CONCIERGE ACTION PILL BUTTON
  Widget _buildConciergeButton() {
    final arrowOffset = _arrowBounceController.value * 4.0;

    return AnimatedScale(
      scale: _isEnteringConcierge ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF242324).withValues(alpha: 0.75),
              const Color(0xFF141315).withValues(alpha: 0.85),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFC5A059).withValues(alpha: 0.42),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC5A059).withValues(alpha: 0.09),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            highlightColor: const Color(0xFFD4AF37).withValues(alpha: 0.08),
            onTap: _onEnterConcierge,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TAP TO ENTER CONCIERGE',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFEDE4D3),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(width: 10),
                Transform.translate(
                  offset: Offset(arrowOffset, 0),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFD8BC86),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FOOTER INFORMATION
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'V2.4 • CRAFTED FOR CONNOISSEURS OF FINE LIVING',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: const Color(0xFF948A76),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'PRIVATE SUITES   •   CHÂTEAUX   •   ISLANDS',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: const Color(0xFF756E5F),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CUSTOM PAINTERS: Hexagon Badge, Monogram S, Particles & Radar
// ---------------------------------------------------------------------------

class LuxuryHexagonBadgePainter extends CustomPainter {
  final double shimmerProgress;

  LuxuryHexagonBadgePainter({required this.shimmerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create vertically oriented regular hexagon path
    Path createHexagon(double r) {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        // -pi/2 gives vertical top apex
        final angle = -math.pi / 2 + (i * math.pi / 3);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    final outerPath = createHexagon(radius - 2);
    final innerPath = createHexagon(radius - 8.5);

    // Metallic gold shader for outer hexagon border
    final goldGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFEEB8),
        Color(0xFFD4AF37),
        Color(0xFF8A6B29),
        Color(0xFFF7E2A8),
        Color(0xFFB38D3F),
      ],
      stops: [0.0, 0.3, 0.6, 0.85, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Outer Hexagon Stroke
    final outerStrokePaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(outerPath, outerStrokePaint);

    // Inner Concentric Hexagon Hairline
    final innerStrokePaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(innerPath, innerStrokePaint);

    // Draw the Luxury "S" Monogram inside
    _drawMonogramS(canvas, center, radius * 0.68, goldGradient);

    // Shimmer highlight pass across badge
    final shimmerX = -size.width + (size.width * 3 * shimmerProgress);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.28),
          Colors.transparent,
        ],
        stops: const [0.35, 0.5, 0.65],
      ).createShader(
        Rect.fromLTWH(shimmerX, 0, size.width * 0.8, size.height),
      )
      ..blendMode = BlendMode.srcATop;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPath(outerPath, outerStrokePaint);
    _drawMonogramS(canvas, center, radius * 0.68, goldGradient);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
    canvas.restore();
  }

  void _drawMonogramS(Canvas canvas, Offset center, double sSize, Shader shader) {
    // Beautiful stylized Serif 'S' matching luxury monogram aesthetics
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: GoogleFonts.cormorantGaramond(
          fontSize: sSize * 1.5,
          fontWeight: FontWeight.w700,
          foreground: Paint()..shader = shader,
          shadows: [
            Shadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textOffset = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2) - 1,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant LuxuryHexagonBadgePainter oldDelegate) {
    return oldDelegate.shimmerProgress != shimmerProgress;
  }
}

// STARDUST BACKGROUND PAINTER
class StardustLuxuryPainter extends CustomPainter {
  final double progress;
  final double opacity;

  // Fixed pseudo-random star points
  static final List<Offset> _stars = [
    const Offset(0.12, 0.08),
    const Offset(0.85, 0.12),
    const Offset(0.25, 0.22),
    const Offset(0.78, 0.28),
    const Offset(0.08, 0.38),
    const Offset(0.92, 0.45),
    const Offset(0.18, 0.58),
    const Offset(0.82, 0.65),
    const Offset(0.35, 0.72),
    const Offset(0.68, 0.78),
    const Offset(0.14, 0.88),
    const Offset(0.88, 0.92),
    const Offset(0.50, 0.15),
    const Offset(0.45, 0.85),
    const Offset(0.30, 0.40),
    const Offset(0.70, 0.42),
  ];

  StardustLuxuryPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final basePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      // Subtle twinkle oscillation
      final twinkle = (math.sin((progress * 2 * math.pi) + (i * 1.3)) + 1) / 2;
      final starOpacity = (0.15 + (twinkle * 0.45)) * opacity;

      basePaint.color = const Color(0xFFD4AF37).withValues(alpha: starOpacity);

      final dx = star.dx * size.width;
      final dy = star.dy * size.height;
      final r = (i % 3 == 0) ? 1.6 : 1.0;

      canvas.drawCircle(Offset(dx, dy), r, basePaint);

      // Fine cross sparkle on prominent stars
      if (i % 5 == 0 && twinkle > 0.6) {
        final sparklePaint = Paint()
          ..color = const Color(0xFFFFF0CA).withValues(alpha: starOpacity * 0.7)
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(dx - 3, dy), Offset(dx + 3, dy), sparklePaint);
        canvas.drawLine(Offset(dx, dy - 3), Offset(dx, dy + 3), sparklePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StardustLuxuryPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}

// TOP BAR BEACON / RADAR ICON PAINTER
class BeaconRingsPainter extends CustomPainter {
  final Color color;

  BeaconRingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Small center dot
    canvas.drawCircle(center, 1.4, Paint()..color = color);

    // Arcs
    final rect1 = Rect.fromCircle(center: center, radius: 4.5);
    final rect2 = Rect.fromCircle(center: center, radius: 8.0);

    canvas.drawArc(rect1, math.pi * 1.15, math.pi * 0.7, false, paint);
    canvas.drawArc(rect2, math.pi * 1.2, math.pi * 0.6, false, paint);
  }

  @override
  bool shouldRepaint(covariant BeaconRingsPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// LUXURY CONCIERGE MODAL PREVIEW
// ---------------------------------------------------------------------------

class LuxuryConciergeModal extends StatelessWidget {
  const LuxuryConciergeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1F24),
              Color(0xFF111215),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
              blurRadius: 36,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF32343C),
                      Color(0xFF191B20),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: Color(0xFFE5CE9F),
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'CONCIERGE SANCTUARY',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                  color: const Color(0xFFF7EEDD),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Welcome, Connoisseur. Your private estate portfolio across Mumbai, Nagpur & Pune is synchronized.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12.5,
                  height: 1.6,
                  color: const Color(0xFFABA18F),
                ),
              ),

              const SizedBox(height: 24),

              // Destination Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildSanctuaryTag('Mumbai Penthouse'),
                  _buildSanctuaryTag('Nagpur Manor'),
                  _buildSanctuaryTag('Pune Hills Chateau'),
                ],
              ),

              const SizedBox(height: 26),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A059),
                    foregroundColor: const Color(0xFF0F1014),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'PROCEED TO RESIDENCES',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSanctuaryTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AD4AF37),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x33D4AF37),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          color: const Color(0xFFE2C48D),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
