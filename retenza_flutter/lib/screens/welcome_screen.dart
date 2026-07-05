import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════
//  RETENZA WELCOME SCREEN
//  Entry point: after onboarding, before login
//  Customer-first, with a discreet merchant path at the bottom
// ══════════════════════════════════════════════════════════════

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onBecomeMerchant;

  const WelcomeScreen({
    super.key,
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onBecomeMerchant,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),

                  // ── Logo ──────────────────────────────────────
                  Center(child: _RetenzaLogo()),
                  const SizedBox(height: 36),

                  // ── Title ─────────────────────────────────────
                  Text(
                    'Bienvenue sur\nRetenza Connect',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF18110C),
                      letterSpacing: -1.0,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Subtitle ──────────────────────────────────
                  Text(
                    'Cumulez des points, débloquez des avantages\net restez fidèle à ce qui vous inspire.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7A6B62),
                      height: 1.6,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Primary: Sign In ──────────────────────────
                  _PrimaryButton(
                    label: 'Se connecter',
                    onTap: widget.onSignIn,
                  ),
                  const SizedBox(height: 12),

                  // ── Secondary: Create Account ─────────────────
                  _SecondaryButton(
                    label: 'Créer un compte',
                    onTap: widget.onCreateAccount,
                  ),

                  const Spacer(flex: 3),

                  // ── Merchant section ──────────────────────────
                  _MerchantFooter(onTap: widget.onBecomeMerchant),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo ────────────────────────────────────────────────────────
class _RetenzaLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFD73E26), Color(0xFFA82C18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD73E26).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * (5.0 / 72.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final sx = size.width / 72;
    final sy = size.height / 72;

    final arc = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset(36 * sx, 36 * sy), radius: 22 * sx),
        0.0,
        311.5 * math.pi / 180,
        true,
      );
    canvas.drawPath(arc, paint);

    final arrow = Path()
      ..moveTo(52 * sx, 10 * sy)
      ..lineTo(52 * sx, 24 * sy)
      ..lineTo(38 * sx, 24 * sy);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => false;
}

// ── Primary Button ───────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _pressed ? const Color(0xFFA82C18) : const Color(0xFFD73E26),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFFD73E26).withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Secondary Button ─────────────────────────────────────────────
class _SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _pressed
                ? const Color(0xFFEDE4DE)
                : const Color(0xFFFFFFFF),
            border: Border.all(
              color: const Color(0xFFEAE4DF),
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF18110C),
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Merchant Footer ──────────────────────────────────────────────
class _MerchantFooter extends StatefulWidget {
  final VoidCallback onTap;
  const _MerchantFooter({required this.onTap});

  @override
  State<_MerchantFooter> createState() => _MerchantFooterState();
}

class _MerchantFooterState extends State<_MerchantFooter> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Subtle divider
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: const Color(0xFFEAE4DF)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Vous avez un commerce ?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFB0A49C),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: const Color(0xFFEAE4DF)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Discreet text button
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Devenir Partenaire Retenza',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7A6B62),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: Color(0xFF7A6B62),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
