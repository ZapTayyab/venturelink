import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _badgeOpacity;
  late Animation<double> _statsOpacity;
  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _orbitAnim;

  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      icon: Icons.rocket_launch_rounded,
      title: 'Launch Your Startup',
      subtitle:
          'Connect with top-tier investors and raise the capital you need to scale fast.',
      gradient: AppColors.primaryGradient,
    ),
    _OnboardPage(
      icon: Icons.trending_up_rounded,
      title: 'Invest in the Future',
      subtitle:
          'Discover high-potential startups and diversify your portfolio with confidence.',
      gradient: AppColors.greenGradient,
    ),
    _OnboardPage(
      icon: Icons.link,
      title: 'Blockchain Secured',
      subtitle:
          'Every investment is recorded immutably on the Ethereum blockchain for full transparency.',
      gradient: AppColors.blockchainGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _setupAnimations();
    _masterController.forward();
  }

  void _setupAnimations() {
    _logoScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.45),
    ));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    ));

    _badgeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.55, 0.78, curve: Curves.easeIn),
      ),
    );

    _statsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.72, 0.92, curve: Curves.easeIn),
      ),
    );

    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.78, 1.0, curve: Curves.easeInOut),
      ),
    );

    _pulseAnim = Tween<double>(begin: 0.94, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _orbitAnim = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _orbitController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _masterController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToApp() {
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) {
      context.go(RouteNames.dashboard);
    } else {
      context.go(RouteNames.login);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Grid background
            CustomPaint(painter: _GridPainter(), size: size),

            // Particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: size,
              ),
            ),

            // Glow orbs
            Positioned(
              top: size.height * 0.04,
              right: -70,
              child: _GlowOrb(
                  size: 280,
                  color: const Color(0xFF1A73E8).withOpacity(0.18)),
            ),
            Positioned(
              bottom: size.height * 0.12,
              left: -90,
              child: _GlowOrb(
                  size: 320,
                  color: const Color(0xFF00C896).withOpacity(0.12)),
            ),
            Positioned(
              top: size.height * 0.38,
              right: size.width * 0.1,
              child: _GlowOrb(
                  size: 160,
                  color: const Color(0xFF7B2FBE).withOpacity(0.10)),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // ── Top section: logo + brand ──────────────
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _masterController,
                      _pulseController,
                      _orbitController,
                    ]),
                    builder: (_, __) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _LogoWithOrbit(
                          pulseScale: _pulseAnim.value,
                          orbitAngle: _orbitAnim.value,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Brand name
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => FadeTransition(
                      opacity: _taglineOpacity,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: Column(
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Venture',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Link',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A73E8),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.tagline,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                                letterSpacing: 3,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Badges
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => Opacity(
                      opacity: _badgeOpacity.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _Badge(
                              icon: Icons.link,
                              label: 'Blockchain',
                              gradient: AppColors.blockchainGradient),
                          SizedBox(width: 8),
                          _Badge(
                              icon: Icons.shield_outlined,
                              label: 'Secure',
                              gradient: AppColors.greenGradient),
                          SizedBox(width: 8),
                          _Badge(
                              icon: Icons.bolt,
                              label: 'Fast',
                              gradient: AppColors.goldGradient),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats bar
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => Opacity(
                      opacity: _statsOpacity.value,
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 28),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem('500+', 'Startups'),
                            _VertDivider(),
                            _StatItem('\$2M+', 'Raised'),
                            _VertDivider(),
                            _StatItem('1K+', 'Investors'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Onboarding pages ───────────────────────
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => Opacity(
                      opacity: _statsOpacity.value,
                      child: SizedBox(
                        height: 160,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          itemCount: _pages.length,
                          itemBuilder: (_, i) =>
                              _OnboardCard(page: _pages[i]),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Page dots
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => Opacity(
                      opacity: _statsOpacity.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            width: _currentPage == i ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: _currentPage == i
                                  ? const Color(0xFF1A73E8)
                                  : Colors.white.withOpacity(0.25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Bottom navigation buttons ──────────────
                  AnimatedBuilder(
                    animation: _masterController,
                    builder: (_, __) => Opacity(
                      opacity: _statsOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                        child: Row(
                          children: [
                            // Skip button
                            GestureDetector(
                              onTap: _navigateToApp,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.07),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Next / Get Started button
                            GestureDetector(
                              onTap: _nextPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient:
                                      AppColors.primaryGradient,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1A73E8)
                                          .withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentPage ==
                                              _pages.length - 1
                                          ? 'Get Started'
                                          : 'Next',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _currentPage ==
                                              _pages.length - 1
                                          ? Icons.arrow_forward_rounded
                                          : Icons.chevron_right,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
  }
}

// ── Onboard data ─────────────────────────────────────────────

class _OnboardPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

// ── Onboard card ─────────────────────────────────────────────

class _OnboardCard extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardCard({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: page.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.colors.first.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(page.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  page.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo with orbit ───────────────────────────────────────────

class _LogoWithOrbit extends StatelessWidget {
  final double pulseScale;
  final double orbitAngle;

  const _LogoWithOrbit({
    required this.pulseScale,
    required this.orbitAngle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer orbit
          Transform.rotate(
            angle: orbitAngle,
            child: Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1A73E8).withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 6,
                    left: 68,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00C896),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00C896),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Inner orbit
          Transform.rotate(
            angle: -orbitAngle * 1.6,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7B2FBE).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
          // Pulse glow
          Transform.scale(
            scale: pulseScale,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1A73E8).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Core logo
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Color(0x661A73E8),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  const _Badge(
      {required this.icon, required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 11),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      );
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                color: Color(0xFF1A73E8),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              )),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45), fontSize: 11)),
        ],
      );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 28, color: Colors.white.withOpacity(0.1));
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 35; i++) {
      final x =
          (i * 137.508 % size.width + progress * ((i % 7) - 3) * 12) %
              size.width;
      final y =
          (i * 97.3 % size.height + progress * ((i % 5) - 2) * 8) %
              size.height;
      final opacity = 0.08 + (i % 5) * 0.06;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    const spacing = 44.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}