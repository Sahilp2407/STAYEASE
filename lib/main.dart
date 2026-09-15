import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF7F5EF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F5EF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6F8068),
          secondary: Color(0xFFA8B5A0),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF252923),
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

  // Continuous boutique idle animations
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

    // 2. Ambient breathing sage & terracotta halo
    _ambientGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // 3. Shimmer light sweep (3.5s repeat)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    // 4. Subtle botanical/mineral particle drift (10s repeat)
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
    if (!kIsWeb) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _isEnteringConcierge = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // Show boutique concierge dialog preview
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Concierge',
      barrierColor: const Color(0xFF252923).withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const LuxuryConciergeModal();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
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
      backgroundColor: const Color(0xFFF7F5EF),
      body: Stack(
        children: [
          // Dynamic Botanical / Soft Sage Particle Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StardustLuxuryPainter(
                    progress: _particlesController.value,
                    opacity: _bgFadeAnimation.value,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),

          // Calming Ambient Halo in the upper-center (Sage & Muted Terracotta)
          AnimatedBuilder(
            animation: Listenable.merge([_ambientGlowController, _entranceController]),
            builder: (context, child) {
              final breath = _ambientGlowController.value;
              final scale = _bgFadeAnimation.value;
              return Positioned(
                top: size.height * 0.16,
                left: size.width * 0.5 - (180 + breath * 24),
                child: Opacity(
                  opacity: (0.55 + breath * 0.25) * scale,
                  child: Container(
                    width: (180 + breath * 24) * 2,
                    height: (180 + breath * 24) * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFA8B5A0).withValues(alpha: 0.32),
                          const Color(0xFFC98F65).withValues(alpha: 0.12),
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

                  // CENTER PIECE: Boutique Emblem with "S" Monogram
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

                  // SUBTITLE & DIVIDERS: "CURATED BOUTIQUE SANCTUARIES"
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

                  // INDICATOR DOTS & SAGE ACCENT LINE
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
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6F8068),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x666F8068),
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
                color: const Color(0xFF252923),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
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
              painter: BeaconRingsPainter(color: const Color(0xFF6F8068)),
            ),
            const SizedBox(width: 6),
            Text(
              'Mumbai • Nagpur • Pune',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF60675D),
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

  // EMBLEM WITH SAGE HEXAGONAL SHIELD & "S" MONOGRAM
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
          // Outer warm sage halo glow
          BoxShadow(
            color: const Color(0xFF6F8068).withValues(alpha: 0.18 + glowBreath * 0.12),
            blurRadius: 36 + glowBreath * 12,
            spreadRadius: 2 + glowBreath * 4,
          ),
          // Clean boutique soft shadow
          BoxShadow(
            color: const Color(0xFF252923).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background crisp white shield disc
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFFFF),
              border: Border.all(
                color: const Color(0xFFA8B5A0).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC98F65).withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          // Inner Hexagonal Sage Badge & Monogram
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
    return Text(
      'S T A Y E A S E',
      textAlign: TextAlign.center,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 9.0,
        height: 1.1,
        color: const Color(0xFF252923),
        shadows: [
          Shadow(
            color: const Color(0xFF6F8068).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  // SUBTITLE WITH FINE SAGE & TERRACOTTA HORIZONTAL DIVIDERS
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
                  Color(0x336F8068),
                  Color(0xFF6F8068),
                ],
              ),
            ),
          ),
        ),

        // Subtitle Text
        Text(
          'CURATED BOUTIQUE\nSANCTUARIES',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: const Color(0xFF60675D),
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
                  Color(0xFF6F8068),
                  Color(0x336F8068),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3 DOTS & BOUTIQUE ACCENT UNDERLINE
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFA8B5A0),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 7.0,
              height: 7.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC98F65),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55C98F65),
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFA8B5A0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Fine botanical accent line
        Container(
          width: 180,
          height: 1.6,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0x336F8068),
                Color(0xFF6F8068),
                Color(0xFFC98F65),
                Color(0x336F8068),
                Colors.transparent,
              ],
              stops: [0.0, 0.25, 0.5, 0.65, 0.85, 1.0],
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6F8068),
              Color(0xFF5A6B53),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFA8B5A0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6F8068).withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            onTap: _onEnterConcierge,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TAP TO ENTER CONCIERGE',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(width: 10),
                Transform.translate(
                  offset: Offset(arrowOffset, 0),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFF7F5EF),
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
            color: const Color(0xFF60675D),
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
            color: const Color(0xFF252923),
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

    // Sage gradient for outer hexagon border
    final sageGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFA8B5A0),
        Color(0xFF6F8068),
        Color(0xFF556350),
        Color(0xFFA8B5A0),
        Color(0xFFC98F65),
      ],
      stops: [0.0, 0.35, 0.65, 0.85, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Outer Hexagon Stroke
    final outerStrokePaint = Paint()
      ..shader = sageGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(outerPath, outerStrokePaint);

    // Inner Concentric Hexagon Hairline
    final innerStrokePaint = Paint()
      ..color = const Color(0xFFA8B5A0).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(innerPath, innerStrokePaint);

    // Draw the Boutique "S" Monogram inside
    _drawMonogramS(canvas, center, radius * 0.68, sageGradient);

    // Shimmer highlight pass across badge
    final shimmerX = -size.width + (size.width * 3 * shimmerProgress);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.45),
          Colors.transparent,
        ],
        stops: const [0.35, 0.5, 0.65],
      ).createShader(
        Rect.fromLTWH(shimmerX, 0, size.width * 0.8, size.height),
      )
      ..blendMode = BlendMode.srcATop;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPath(outerPath, outerStrokePaint);
    _drawMonogramS(canvas, center, radius * 0.68, sageGradient);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
    canvas.restore();
  }

  void _drawMonogramS(Canvas canvas, Offset center, double sSize, Shader shader) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: GoogleFonts.cormorantGaramond(
          fontSize: sSize * 1.5,
          fontWeight: FontWeight.w700,
          foreground: Paint()..shader = shader,
          shadows: [
            Shadow(
              color: const Color(0xFFC98F65).withValues(alpha: 0.35),
              blurRadius: 6,
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

// STARDUST / BOTANICAL BACKGROUND PAINTER
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
      final twinkle = (math.sin((progress * 2 * math.pi) + (i * 1.3)) + 1) / 2;
      final starOpacity = (0.25 + (twinkle * 0.5)) * opacity;

      // Subtle interplay of sage green and terracotta specks
      final isAccent = (i % 3 == 0);
      final color = isAccent ? const Color(0xFFC98F65) : const Color(0xFF6F8068);
      basePaint.color = color.withValues(alpha: starOpacity * 0.7);

      final dx = star.dx * size.width;
      final dy = star.dy * size.height;
      final r = (i % 4 == 0) ? 1.8 : 1.2;

      canvas.drawCircle(Offset(dx, dy), r, basePaint);

      // Fine cross sparkle on prominent stars
      if (i % 5 == 0 && twinkle > 0.6) {
        final sparklePaint = Paint()
          ..color = const Color(0xFF6F8068).withValues(alpha: starOpacity * 0.6)
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
// BOUTIQUE CONCIERGE MODAL PREVIEW
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
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE5E2D8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6F8068).withValues(alpha: 0.15),
              blurRadius: 36,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF252923).withValues(alpha: 0.12),
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
                  color: const Color(0xFFF7F5EF),
                  border: Border.all(
                    color: const Color(0xFF6F8068).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.key_outlined,
                  color: Color(0xFF6F8068),
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
                  color: const Color(0xFF252923),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Welcome, Connoisseur. Your private estate portfolio across Mumbai, Nagpur & Pune is synchronized.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12.5,
                  height: 1.6,
                  color: const Color(0xFF60675D),
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
                    backgroundColor: const Color(0xFF6F8068),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (ctx, anim, _) => const DashboardScreen(),
                        transitionsBuilder: (ctx, anim, _, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeIn,
                            ),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
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
        color: const Color(0xFFF7F5EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x336F8068),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          color: const Color(0xFF6F8068),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
