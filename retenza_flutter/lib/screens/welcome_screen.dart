import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════
//  RETENZA WELCOME SCREEN — Premium Fintech Edition
//  Entry point: right after the 3 onboarding screens, before login.
//  Design language: Revolut-grade clarity, Apple-grade restraint,
//  Linear-grade precision — built on the existing Retenza brand
//  tokens (brick red #D73E26, warm cream surfaces, Bricolage
//  Grotesque + Inter typography).
// ══════════════════════════════════════════════════════════════

class _Palette {
  static const primary = Color(0xFFD73E26);
  static const primaryDark = Color(0xFFA82C18);
  static const background = Color(0xFFFBF8F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfacePressed = Color(0xFFEDE4DE);
  static const border = Color(0xFFEAE4DF);
  static const ink = Color(0xFF18110C);
  static const inkSoft = Color(0xFF6E5B52);
  static const inkMuted = Color(0xFF9C8B82);
  static const success = Color(0xFF3F7E78);
}

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
  late final AnimationController _ctrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _trustFade;
  late final Animation<double> _actionsFade;
  late final Animation<Offset> _actionsSlide;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoFade = _interval(0.00, 0.45, Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = _interval(0.15, 0.60, Curves.easeOut);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
    ));

    _subtitleFade = _interval(0.25, 0.70, Curves.easeOut);
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
    ));

    _trustFade = _interval(0.35, 0.75, Curves.easeOut);

    _actionsFade = _interval(0.45, 0.90, Curves.easeOut);
    _actionsSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
    ));

    _footerFade = _interval(0.60, 1.00, Curves.easeOut);

    _ctrl.forward();
  }

  Animation<double> _interval(double start, double end, Curve curve) {
    return CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: curve),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final size = MediaQuery.of(context).size;
    final isCompactHeight = size.height < 700;

    return Scaffold(
      backgroundColor: _Palette.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: isCompactHeight ? 20 : 48),

                                // ── Brand mark ──────────────────
                                FadeTransition(
                                  opacity: reduceMotion
                                      ? const AlwaysStoppedAnimation(1.0)
                                      : _logoFade,
                                  child: ScaleTransition(
                                    scale: reduceMotion
                                        ? const AlwaysStoppedAnimation(1.0)
                                        : _logoScale,
                                    child: const Center(
                                      child: _BrandMark(),
                                    ),
                                  ),
                                ),

                                SizedBox(height: isCompactHeight ? 28 : 40),

                                // ── Headline ─────────────────────
                                _AnimatedIn(
                                  fade: _titleFade,
                                  slide: _titleSlide,
                                  reduceMotion: reduceMotion,
                                  child: Text(
                                    'Votre fidélité,\nenfin récompensée.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.bricolageGrotesque(
                                      fontSize: isCompactHeight ? 28 : 33,
                                      fontWeight: FontWeight.w800,
                                      color: _Palette.ink,
                                      letterSpacing: -1.0,
                                      height: 1.14,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // ── Subtitle ─────────────────────
                                _AnimatedIn(
                                  fade: _subtitleFade,
                                  slide: _subtitleSlide,
                                  reduceMotion: reduceMotion,
                                  child: Text(
                                    'Cumulez des points chez vos commerces préférés et débloquez des avantages exclusifs, automatiquement.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: _Palette.inkSoft,
                                      height: 1.55,
                                    ),
                                  ),
                                ),

                                SizedBox(height: isCompactHeight ? 24 : 32),

                                // ── Trust strip ──────────────────
                                FadeTransition(
                                  opacity: reduceMotion
                                      ? const AlwaysStoppedAnimation(1.0)
                                      : _trustFade,
                                  child: const _TrustStrip(),
                                ),

                                const Spacer(),
                                SizedBox(height: isCompactHeight ? 20 : 28),

                                // ── Primary actions ──────────────
                                _AnimatedIn(
                                  fade: _actionsFade,
                                  slide: _actionsSlide,
                                  reduceMotion: reduceMotion,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _PrimaryButton(
                                        label: 'Se connecter',
                                        onTap: widget.onSignIn,
                                      ),
                                      const SizedBox(height: 12),
                                      _SecondaryButton(
                                        label: 'Créer un compte',
                                        onTap: widget.onCreateAccount,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: isCompactHeight ? 20 : 28),

                                // ── Merchant section ─────────────
                                FadeTransition(
                                  opacity: reduceMotion
                                      ? const AlwaysStoppedAnimation(1.0)
                                      : _footerFade,
                                  child:
                                      _MerchantFooter(onTap: widget.onBecomeMerchant),
                                ),

                                SizedBox(height: isCompactHeight ? 16 : 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared entrance animation wrapper ──────────────────────────────
class _AnimatedIn extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final bool reduceMotion;
  final Widget child;

  const _AnimatedIn({
    required this.fade,
    required this.slide,
    required this.reduceMotion,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) return child;
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ── Ambient background — soft brand-colored glows ──────────────────
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmbientPainter(),
      child: Container(),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = RadialGradient(colors: [
        _Palette.primary.withOpacity(0.07),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.04),
        radius: size.width * 0.65,
      ));
    canvas.drawRect(Offset.zero & size, topGlow);

    final bottomGlow = Paint()
      ..shader = RadialGradient(colors: [
        _Palette.success.withOpacity(0.05),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.1, size.height * 0.92),
        radius: size.width * 0.7,
      ));
    canvas.drawRect(Offset.zero & size, bottomGlow);
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) => false;
}

// ── Brand mark ──────────────────────────────────────────────────────
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_Palette.primary, _Palette.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _Palette.primary.withOpacity(0.28),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CustomPaint(painter: _LogoPainter()),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'retenza',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _Palette.ink,
                  letterSpacing: -0.4,
                ),
              ),
              TextSpan(
                text: '.',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _Palette.primary,
                ),
              ),
            ],
          ),
        ),
      ],
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

// ── Trust strip — quiet reassurance signals ─────────────────────────
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.lock_rounded, 'Données protégées'),
      (Icons.bolt_rounded, 'Points instantanés'),
      (Icons.storefront_rounded, 'Multi-commerces'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Palette.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(
              width: 1,
              height: 28,
              color: _Palette.border,
            );
          }
          final item = items[i ~/ 2];
          return Expanded(
            child: Semantics(
              label: item.$2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, size: 18, color: _Palette.primary),
                  const SizedBox(height: 6),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _Palette.inkSoft,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
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

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _pressed ? _Palette.primaryDark : _Palette.primary,
              boxShadow: _pressed
                  ? []
                  : [
                      BoxShadow(
                        color: _Palette.primary.withOpacity(0.24),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
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

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _pressed ? _Palette.surfacePressed : _Palette.surface,
              border: Border.all(color: _Palette.border),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: _Palette.ink,
                  letterSpacing: 0.1,
                ),
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
        Row(
          children: [
            Expanded(child: Container(height: 1, color: _Palette.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Vous avez un commerce ?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _Palette.inkMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: _Palette.border)),
          ],
        ),
        const SizedBox(height: 14),
        Semantics(
          button: true,
          label: 'Devenir Partenaire Retenza',
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              opacity: _pressed ? 0.6 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Devenir Partenaire Retenza',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _Palette.inkSoft,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: _Palette.inkSoft,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
