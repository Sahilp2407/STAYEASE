import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hotel_models.dart';
import '../data/hotel_data.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'room_selection_screen.dart';

// ─── Visual Identity: StayEase Boutique Luxury Palette ─────────────────────────
const Color _kBg = Color(0xFFF7F5EF); // Warm Ivory / Cream
const Color _kPrimary = Color(0xFF788A70); // Sage / Muted Olive Green
const Color _kPrimaryLight = Color(0xFFEEF2EC); // Very soft sage tint
const Color _kText = Color(0xFF292C28); // Dark Charcoal
const Color _kTextMuted = Color(0xFF697068); // Muted Gray-Green
const Color _kTextFaint = Color(0xFF9DA59C); // Faint Slate-Sage
const Color _kAccent = Color(0xFFC7A24A); // Champagne / Warm Gold
const Color _kAccentLight = Color(0xFFF6EED8); // Soft Gold tint
const Color _kCard = Color(0xFFFFFFFF); // Pure Crisp White
const Color _kBorder = Color(0xFFE5E2D8); // Thin Neutral Linen Border
const Color _kBorderActive = Color(0xFF788A70); // Active Sage Border
const Color _kError = Color(0xFFB85D43); // Refined Terracotta/Brick for errors

class AuthScreen extends StatefulWidget {
  final Hotel? targetHotel;
  final VoidCallback? onAuthenticated;

  const AuthScreen({
    super.key,
    this.targetHotel,
    this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'sahil@stayease.com');
  final _passwordController = TextEditingController(text: 'password123');

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Hotel get _activeHotel => widget.targetHotel ?? kSampleHotels.first;

  bool _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool isValid = true;

    if (email.isEmpty) {
      _emailError = 'Please enter your email address';
      isValid = false;
    } else {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
      if (!emailRegex.hasMatch(email)) {
        _emailError = 'Please enter a valid email address';
        isValid = false;
      }
    }

    if (password.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: _kError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    if (widget.targetHotel != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoomSelectionScreen(hotel: widget.targetHotel!),
        ),
      );
    } else if (widget.onAuthenticated != null) {
      widget.onAuthenticated!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleLogin({String? name, String? email}) async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final emailInput = email ?? _emailController.text.trim();
    final passwordInput = _passwordController.text;

    try {
      final cred = await AuthService.instance.signInWithEmailAndPassword(
        email: emailInput,
        password: passwordInput,
      );

      final user = cred.user;
      AppState.instance.login(
        name: user?.displayName ?? name ?? 'Sahil Pandey',
        email: user?.email ?? emailInput,
        phone: user?.phoneNumber ?? '+91 98200 12345',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      _navigateToNextScreen();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar(AuthService.getErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Authentication error: ${e.toString()}');
    }
  }

  Future<void> _onSocialAuth(String provider) async {
    if (provider == 'Google') {
      await _handleGoogleAuth();
    } else if (provider == 'Phone') {
      _openPhoneAuthModal();
    }
  }

  Future<void> _handleGoogleAuth() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final cred = await AuthService.instance.signInWithGoogle();
      if (cred == null) {
        // User cancelled Google sign-in
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final user = cred.user;
      AppState.instance.login(
        name: user?.displayName ?? 'Google Guest',
        email: user?.email ?? '',
        phone: user?.phoneNumber ?? '',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      _navigateToNextScreen();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar(AuthService.getErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Google Sign-In failed: ${e.toString()}');
    }
  }

  void _openPhoneAuthModal() {
    final phoneCtrl = TextEditingController(text: '+91 ');
    final otpCtrl = TextEditingController();
    String? verificationId;
    bool isOtpSent = false;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: _kBorder, width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 18),
                  Text(
                    isOtpSent ? 'Verify Phone Code' : 'Phone Sign In',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isOtpSent
                        ? 'Enter the 6-digit verification code sent to ${phoneCtrl.text}'
                        : 'Enter your phone number with country code to receive an OTP.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      color: _kTextMuted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!isOtpSent) ...[
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.montserrat(fontSize: 14, color: _kText),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: GoogleFonts.montserrat(color: _kTextMuted),
                        prefixIcon: const Icon(Icons.phone_rounded, color: _kPrimary, size: 20),
                        filled: true,
                        fillColor: _kBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final phone = phoneCtrl.text.trim();
                                if (phone.length < 10) {
                                  _showErrorSnackBar('Please enter a valid phone number with country code');
                                  return;
                                }
                                setModalState(() => isProcessing = true);
                                await AuthService.instance.verifyPhoneNumber(
                                  phoneNumber: phone,
                                  onCodeSent: (verId, _) {
                                    setModalState(() {
                                      verificationId = verId;
                                      isOtpSent = true;
                                      isProcessing = false;
                                    });
                                  },
                                  onVerificationCompleted: (cred) async {
                                    await FirebaseAuth.instance.signInWithCredential(cred);
                                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                    if (widget.onAuthenticated != null) widget.onAuthenticated!();
                                  },
                                  onVerificationFailed: (err) {
                                    setModalState(() => isProcessing = false);
                                    _showErrorSnackBar(AuthService.getErrorMessage(err));
                                  },
                                  onCodeAutoRetrievalTimeout: (verId) {
                                    verificationId = verId;
                                  },
                                );
                              },
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Send Verification Code',
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.montserrat(fontSize: 18, letterSpacing: 8, fontWeight: FontWeight.w700, color: _kText),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••••',
                        filled: true,
                        fillColor: _kBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final code = otpCtrl.text.trim();
                                if (code.length < 6 || verificationId == null) {
                                  _showErrorSnackBar('Please enter the 6-digit code');
                                  return;
                                }
                                setModalState(() => isProcessing = true);
                                try {
                                  final cred = await AuthService.instance.signInWithOtp(
                                    verificationId: verificationId!,
                                    smsCode: code,
                                  );
                                  final user = cred.user;
                                  AppState.instance.login(
                                    name: user?.displayName ?? 'Phone Guest',
                                    email: user?.email ?? '',
                                    phone: user?.phoneNumber ?? phoneCtrl.text.trim(),
                                  );
                                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                  _navigateToNextScreen();
                                } on FirebaseAuthException catch (e) {
                                  setModalState(() => isProcessing = false);
                                  _showErrorSnackBar(AuthService.getErrorMessage(e));
                                } catch (e) {
                                  setModalState(() => isProcessing = false);
                                  _showErrorSnackBar('Verification failed: $e');
                                }
                              },
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Verify & Continue',
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email address in the field above first.');
      return;
    }
    try {
      await AuthService.instance.sendPasswordResetEmail(email);
      _showSuccessSnackBar('Password reset instructions sent to $email.');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(AuthService.getErrorMessage(e));
    } catch (e) {
      _showErrorSnackBar('Could not send reset email: $e');
    }
  }

  void _onSignUpPrompt() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    final passCtrl = TextEditingController();
    bool isRegistering = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: _kBorder, width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 18),
                  Text(
                    'Create Your Sanctuary Account',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join StayEase to unlock curated privileges, reservations, and favorites.',
                    style: GoogleFonts.montserrat(fontSize: 12.5, color: _kTextMuted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.montserrat(fontSize: 13.5, color: _kText),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.montserrat(color: _kTextMuted),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: _kPrimary, size: 20),
                      filled: true,
                      fillColor: _kBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.montserrat(fontSize: 13.5, color: _kText),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: GoogleFonts.montserrat(color: _kTextMuted),
                      prefixIcon: const Icon(Icons.mail_outline_rounded, color: _kPrimary, size: 20),
                      filled: true,
                      fillColor: _kBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    style: GoogleFonts.montserrat(fontSize: 13.5, color: _kText),
                    decoration: InputDecoration(
                      labelText: 'Password (min. 6 characters)',
                      labelStyle: GoogleFonts.montserrat(color: _kTextMuted),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: _kPrimary, size: 20),
                      filled: true,
                      fillColor: _kBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isRegistering
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              final email = emailCtrl.text.trim();
                              final pass = passCtrl.text;
                              if (name.isEmpty || email.isEmpty || pass.length < 6) {
                                _showErrorSnackBar('Please provide name, valid email, and 6+ character password');
                                return;
                              }
                              setModalState(() => isRegistering = true);
                              try {
                                final cred = await AuthService.instance.signUpWithEmailAndPassword(
                                  name: name,
                                  email: email,
                                  password: pass,
                                );
                                final user = cred.user;
                                AppState.instance.login(
                                  name: name,
                                  email: email,
                                  phone: user?.phoneNumber ?? '',
                                );
                                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                _showSuccessSnackBar('Welcome to StayEase, $name!');
                                _navigateToNextScreen();
                              } on FirebaseAuthException catch (e) {
                                setModalState(() => isRegistering = false);
                                _showErrorSnackBar(AuthService.getErrorMessage(e));
                              } catch (e) {
                                setModalState(() => isRegistering = false);
                                _showErrorSnackBar('Registration failed: $e');
                              }
                            },
                      child: isRegistering
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Create Account & Continue',
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompactScreen = mediaQuery.size.height < 700;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: isCompactScreen ? 12 : 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Top Section: Back Button & Branding ─────────────
                      _TopHeader(
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(height: isCompactScreen ? 14 : 20),

                      // ── 2. Selected Hotel Context Card ─────────────────────
                      _HotelContextCard(hotel: _activeHotel),
                      SizedBox(height: isCompactScreen ? 18 : 24),

                      // ── 3. Login Heading & Eyebrow ─────────────────────────
                      const _LoginHeader(),
                      SizedBox(height: isCompactScreen ? 18 : 24),

                      // ── 4. Social Authentication Options ───────────────────
                      _SocialLoginButton(
                        label: 'Continue with Google',
                        icon: _GoogleLogoIcon(),
                        onPressed: () => _onSocialAuth('Google'),
                      ),
                      const SizedBox(height: 12),
                      _SocialLoginButton(
                        label: 'Continue with Phone Number',
                        icon: const Icon(
                          Icons.phone_iphone_rounded,
                          color: _kPrimary,
                          size: 20,
                        ),
                        onPressed: () => _onSocialAuth('Phone'),
                      ),
                      SizedBox(height: isCompactScreen ? 16 : 22),

                      // ── 5. Elegant Divider ─────────────────────────────────
                      const _OrDivider(),
                      SizedBox(height: isCompactScreen ? 16 : 22),

                      // ── 6. Email Input Field ───────────────────────────────
                      _AuthTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        placeholder: 'Enter your email',
                        leadingIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorMessage: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── 7. Password Input Field & Forgot Password ──────────
                      _AuthTextField(
                        label: 'Password',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        placeholder: 'Enter your password',
                        leadingIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        errorMessage: _passwordError,
                        headerTrailing: GestureDetector(
                          onTap: _onForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.montserrat(
                              color: _kPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _kTextFaint,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          splashRadius: 18,
                        ),
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                        onSubmitted: (_) {
                          if (_validateInputs()) {
                            _handleLogin();
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── 8. Custom Remember Me Checkbox ─────────────────────
                      _CustomCheckboxRow(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val),
                      ),
                      SizedBox(height: isCompactScreen ? 20 : 26),

                      // ── 9. Primary Action CTA ──────────────────────────────
                      _PrimaryLoginButton(
                        isLoading: _isLoading,
                        onPressed: () {
                          if (_validateInputs()) {
                            _handleLogin();
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // ── 10. Sign Up Prompt ─────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: _onSignUpPrompt,
                          behavior: HitTestBehavior.opaque,
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: _kTextMuted,
                              ),
                              children: [
                                const TextSpan(
                                    text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Create an account',
                                  style: GoogleFonts.montserrat(
                                    color: _kPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompactScreen ? 24 : 32),

                      // ── 11. Trust & Security Footer ────────────────────────
                      const _TrustFooter(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. TOP HEADER & MINIMAL BRANDING
// ─────────────────────────────────────────────────────────────────────────────
class _TopHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _TopHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Minimal Circular Back Button with subtle shadow
        _BounceTap(
          onTap: onBack,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kCard,
              shape: BoxShape.circle,
              border: Border.all(color: _kBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: _kText.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kText,
                size: 16,
              ),
            ),
          ),
        ),
        const Spacer(),
        // Subtle StayEase Wordmark
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kCard,
                border: Border.all(color: _kPrimary, width: 1.2),
              ),
              child: Center(
                child: Text(
                  'S',
                  style: GoogleFonts.cormorantGaramond(
                    color: _kPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'StayEase',
              style: GoogleFonts.cormorantGaramond(
                color: _kText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kAccent,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Invisible balance placeholder for true center alignment
        const SizedBox(width: 42, height: 42),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SELECTED HOTEL CONTEXT CARD (Preserves Booking Selection)
// ─────────────────────────────────────────────────────────────────────────────
class _HotelContextCard extends StatelessWidget {
  final Hotel hotel;

  const _HotelContextCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hotel Image Thumbnail (72x72 with 14px rounded corners)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.network(
                    hotel.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: _kPrimaryLight,
                      child: const Center(
                        child: Icon(Icons.hotel_rounded, color: _kPrimary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Hotel Info
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
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: _kTextFaint,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hotel.location,
                            style: GoogleFonts.montserrat(
                              color: _kTextMuted,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Rating Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kAccentLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: _kAccent,
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${hotel.rating}',
                                style: GoogleFonts.montserrat(
                                  color: _kText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Price
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(color: _kText),
                            children: [
                              TextSpan(
                                text: '₹${_formatPrice(hotel.pricePerNight)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _kPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '/night',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10.5,
                                  color: _kTextMuted,
                                ),
                              ),
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
          const SizedBox(height: 8),
          // Subtle reservation guarantee label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  color: _kPrimary,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Continuing booking for this sanctuary • Rates locked',
                    style: GoogleFonts.montserrat(
                      color: _kTextMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int p) {
    return p.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. LOGIN HEADER (Enhanced Visual Hierarchy)
// ─────────────────────────────────────────────────────────────────────────────
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow
        Row(
          children: [
            Text(
              'ALMOST THERE',
              style: GoogleFonts.montserrat(
                color: _kAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(width: 6),
            const Text('✨', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        // Two-line Sophisticated Heading
        Text(
          'Sign in to continue\nyour booking',
          style: GoogleFonts.cormorantGaramond(
            color: _kText,
            fontSize: 29,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        // Supporting Subtext
        Text(
          'Sign in securely to continue your reservation and keep your booking details in one place.',
          style: GoogleFonts.montserrat(
            color: _kTextMuted,
            fontSize: 12.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. SOCIAL AUTHENTICATION BUTTONS
// ─────────────────────────────────────────────────────────────────────────────
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _BounceTap(
      onTap: onPressed,
      child: Container(
        height: 54,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: _kText.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 22, height: 22, child: Center(child: icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  color: _kText,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _kTextFaint,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. GOOGLE LOGO VECTOR ICON
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleLogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    // Subtle simplified modern 4-color G
    final center = Offset(w / 2, h / 2);
    final rect = Rect.fromCircle(center: center, radius: w / 2);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    // Blue arc (Right)
    stroke.color = paintBlue.color;
    canvas.drawArc(rect, -0.4, 1.4, false, stroke);

    // Green arc (Bottom)
    stroke.color = paintGreen.color;
    canvas.drawArc(rect, 1.0, 1.6, false, stroke);

    // Yellow arc (Left)
    stroke.color = paintYellow.color;
    canvas.drawArc(rect, 2.6, 1.4, false, stroke);

    // Red arc (Top)
    stroke.color = paintRed.color;
    canvas.drawArc(rect, 4.0, 1.4, false, stroke);

    // Blue center bar
    final barPaint = Paint()
      ..color = paintBlue.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.5), Offset(w * 0.95, h * 0.5), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. DELICATE OR DIVIDER
// ─────────────────────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: _kBorder,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: GoogleFonts.montserrat(
              color: _kTextFaint,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: _kBorder,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. MODERN AUTH TEXT FIELD WITH INLINE VALIDATION
// ─────────────────────────────────────────────────────────────────────────────
class _AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final IconData leadingIcon;
  final bool obscureText;
  final Widget? headerTrailing;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _AuthTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.leadingIcon,
    this.obscureText = false,
    this.headerTrailing,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.errorMessage,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<_AuthTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Row (Label + optional Trailing like "Forgot Password?")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.montserrat(
                color: _kText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.headerTrailing != null) widget.headerTrailing!,
          ],
        ),
        const SizedBox(height: 7),
        // Animated Input Container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? _kError
                  : _isFocused
                      ? _kBorderActive
                      : _kBorder,
              width: _isFocused || hasError ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? _kPrimary.withValues(alpha: 0.08)
                    : _kText.withValues(alpha: 0.02),
                blurRadius: _isFocused ? 10 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              // Leading Icon
              Icon(
                widget.leadingIcon,
                color: hasError
                    ? _kError
                    : _isFocused
                        ? _kPrimary
                        : _kTextFaint,
                size: 20,
              ),
              const SizedBox(width: 12),
              // Text Field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  style: GoogleFonts.montserrat(
                    color: _kText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: GoogleFonts.montserrat(
                      color: _kTextFaint,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (widget.suffixIcon != null) widget.suffixIcon!,
              const SizedBox(width: 6),
            ],
          ),
        ),
        // Inline Validation Message (Clean, non-jarring StayEase design)
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: _kError,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                widget.errorMessage!,
                style: GoogleFonts.montserrat(
                  color: _kError,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. CUSTOM STAYEASE REMEMBER ME CHECKBOX
// ─────────────────────────────────────────────────────────────────────────────
class _CustomCheckboxRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomCheckboxRow({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? _kPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? _kPrimary : _kBorderActive,
                width: 1.5,
              ),
            ),
            child: value
                ? const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 9),
          Text(
            'Remember me',
            style: GoogleFonts.montserrat(
              color: _kText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. PRIMARY CTA LOGIN BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryLoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _BounceTap(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In & Continue',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Arrow with subtle gold micro-accent
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. TRUST & SECURITY FOOTER
// ─────────────────────────────────────────────────────────────────────────────
class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _trustItem(Icons.verified_user_outlined, 'Secure booking'),
        _dotDivider(),
        _trustItem(Icons.shield_outlined, 'Protected account'),
        _dotDivider(),
        _trustItem(Icons.support_agent_rounded, '24/7 support'),
      ],
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _kTextFaint),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.montserrat(
            color: _kTextFaint,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _dotDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: _kBorder,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 11. BOUNCE TAP ANIMATION HELPER
// ─────────────────────────────────────────────────────────────────────────────
class _BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _BounceTap({required this.child, this.onTap});

  @override
  State<_BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<_BounceTap> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}
