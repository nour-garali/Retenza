import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../providers/admin_provider.dart';
import '../services/admin_service.dart';

// ══════════════════════════════════════════════════════════════
//  RETENZA — ADMIN DASHBOARD  (v2 · Brand-True Redesign)
// ══════════════════════════════════════════════════════════════

// ── Design Tokens ─────────────────────────────────────────────
abstract class _C {
  static const grenadier   = Color(0xFFD73E26);
  static const grenadierDp = Color(0xFFA82C18);
  static const ember       = Color(0xFFF2774E);
  static const emberSoft   = Color(0xFFFCE7DD);
  static const ink         = Color(0xFF1B100C);
  static const ink60       = Color(0xFF6E5B52);
  static const ink40       = Color(0xFF9C8B82);
  static const line        = Color(0xFFEDE5DF);
  static const bg          = Color(0xFFF4EFEB);
  static const white       = Color(0xFFFFFFFF);
  static const regular     = Color(0xFF3F8E84);
  static const risk        = Color(0xFFE8902A);
  static const lost        = Color(0xFFB0A39B);
}

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogout;
  const AdminDashboardScreen({super.key, required this.onLogout});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _TopBar(onLogout: widget.onLogout, pulse: _pulse),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _body(),
            ),
          ),
          _BottomNav(
            selected: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_tab) {
      case 0: return _OverviewTab(key: const ValueKey(0));
      case 1: return _MerchantsTab(key: const ValueKey(1));
      case 2: return _ClientsTab(key: const ValueKey(2));
      case 3: return _PendingTab(key: const ValueKey(3));
      default: return _OverviewTab(key: const ValueKey(0));
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  TOP BAR
// ══════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final VoidCallback onLogout;
  final Animation<double> pulse;
  const _TopBar({required this.onLogout, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _C.white,
            border: Border(bottom: BorderSide(color: _C.line)),
          ),
          child: Row(
            children: [
              _LogoMark(size: 32),
              const SizedBox(width: 9),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.ink,
                      letterSpacing: -0.03),
                  children: [
                    const TextSpan(text: 'retenza'),
                    const TextSpan(text: '.', style: TextStyle(color: _C.grenadier)),
                  ],
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: pulse,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.emberSoft,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Opacity(
                      opacity: 0.3 + 0.7 * pulse.value,
                      child: Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: _C.grenadier, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('LIVE',
                        style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: _C.grenadierDp,
                            letterSpacing: 0.04)),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.line),
                  ),
                  child: const Icon(Icons.logout_rounded, size: 15, color: _C.ink60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 0 — VUE D'ENSEMBLE
// ══════════════════════════════════════════════════════════════
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _C.grenadier)),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (stats) {
        final totalScans = stats['activity']?['totalQrScans'] ?? 0;
        final totalClients = stats['users']?['clients'] ?? 0;
        final activeMerchants = stats['commerces']?['active'] ?? 0;
        final pendingCount = stats['commerces']?['pending'] ?? 0;
        final totalTransactions = stats['activity']?['totalLoyaltyTransactions'] ?? 0;

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminStatsProvider.future),
          color: _C.grenadier,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Greeting(),
              const SizedBox(height: 16),
              _HeroCard(
                merchants: activeMerchants.toString(),
                clients: totalClients.toString(),
                scans: totalScans.toString(),
                transactions: totalTransactions.toString(),
              ),
              const SizedBox(height: 14),
              _KpiRow(stats: stats),
              const SizedBox(height: 14),
              _TwoCol(
                left: _ActivityChart(),
                right: _DonutCard(),
              ),
              const SizedBox(height: 14),
              _TopClientsCard(),
              const SizedBox(height: 14),
              if (pendingCount > 0)
                GestureDetector(
                  onTap: () {
                    // Could navigate to pending tab here by updating state in parent
                  },
                  child: _PendingBanner(count: pendingCount),
                ),
            ]),
          ),
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aperçu de la plateforme Retenza Connect.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _C.ink60,
          ),
        ),
      ],
    );
  }
}
class _HeroCard extends StatelessWidget {
  final String merchants;
  final String clients;
  final String scans;
  final String transactions;

  const _HeroCard({required this.merchants, required this.clients, required this.scans, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFD73E26), Color(0xFFA82C18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.grenadier.withValues(alpha: 0.30),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(children: [
        Positioned(
          right: -50, top: -50,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('PLATEFORME RETENZA',
                style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.05)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('ADMIN',
                  style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 0.04)),
            ),
          ]),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(transactions,
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: _C.white,
                    letterSpacing: -0.03,
                    height: 1)),
          ]),
          const SizedBox(height: 4),
          Text('Transactions globales traitées',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.82))),

          const SizedBox(height: 18),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(children: [
            _HeroMeta(label: 'Commerçants', value: merchants),
            const SizedBox(width: 20),
            _HeroMeta(label: 'Clients', value: clients),
            const SizedBox(width: 20),
            _HeroMeta(label: 'Scans', value: scans),
          ]),
        ]),
      ]),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  final String label, value;
  const _HeroMeta({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.white,
              letterSpacing: -0.02)),
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.75))),
    ]);
  }
}

class _KpiRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _KpiRow({required this.stats});
  
  @override
  Widget build(BuildContext context) {
    final active = stats['commerces']?['active'] ?? 0;
    final scans = stats['activity']?['totalQrScans'] ?? 0;
    final loyaltyTxs = stats['activity']?['totalLoyaltyTransactions'] ?? 0;

    final kpis = [
      _KD('Points émis', '${loyaltyTxs * 10}', '↑ +12%', true), // Mock calculation based on real tx
      _KD('Scans totaux', '$scans', '↑ +5%', true),
      _KD('Transactions', '$loyaltyTxs', '↑ +8%', true),
      _KD('Partenaires', '$active', '↑ +2', true),
    ];
    return Row(
      children: kpis
          .map((k) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: kpis.indexOf(k) < kpis.length - 1 ? 10 : 0),
                  child: _KpiCard(data: k),
                ),
              ))
          .toList(),
    );
  }
}

class _KD {
  final String label, value, delta;
  final bool up;
  const _KD(this.label, this.value, this.delta, this.up);
}

class _KpiCard extends StatelessWidget {
  final _KD data;
  const _KpiCard({required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data.label,
            style: GoogleFonts.inter(fontSize: 10, color: _C.ink60), maxLines: 1, overflow: TextOverflow.ellipsis,),
        const SizedBox(height: 5),
        Text(data.value,
            style: GoogleFonts.bricolageGrotesque(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.ink,
                letterSpacing: -0.02)),
        const SizedBox(height: 4),
        Text(data.delta,
            style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: data.up ? _C.regular : _C.risk,
                letterSpacing: 0.02)),
      ]),
    );
  }
}

class _TwoCol extends StatelessWidget {
  final Widget left, right;
  const _TwoCol({required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: left),
      const SizedBox(width: 12),
      Expanded(flex: 4, child: right),
    ]);
  }
}

class _ActivityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mocked for now since backend doesn't provide time-series data
    final vals = [45, 78, 55, 92, 68, 110, 88, 134, 105, 122, 145, 98];
    final labels = ['J','F','M','A','M','J','J','A','S','O','N','D'];
    final peak = vals.reduce(math.max).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Activité · Scans',
            style: GoogleFonts.bricolageGrotesque(
                fontSize: 14, fontWeight: FontWeight.w700, color: _C.ink)),
        Text('Mois par mois · 2026',
            style: GoogleFonts.inter(fontSize: 10, color: _C.ink40)),
        const SizedBox(height: 14),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(vals.length, (i) {
              final h = (vals[i] / peak) * 80;
              final isPeak = vals[i] == vals.reduce(math.max);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    height: h,
                    decoration: BoxDecoration(
                      color: isPeak ? _C.grenadier : _C.emberSoft,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(5)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: labels
              .map((l) => Expanded(
                    child: Text(l,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceMono(
                            fontSize: 8, color: _C.ink40)),
                  ))
              .toList(),
        ),
      ]),
    );
  }
}

class _DonutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Also mocked since backend lacks segment breakdown
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Clients',
            style: GoogleFonts.bricolageGrotesque(
                fontSize: 14, fontWeight: FontWeight.w700, color: _C.ink)),
        Text('Répartition',
            style: GoogleFonts.inter(fontSize: 10, color: _C.ink40)),
        const SizedBox(height: 14),
        Center(
          child: SizedBox(
            width: 90, height: 90,
            child: CustomPaint(painter: _DonutPainter()),
          ),
        ),
        const SizedBox(height: 12),
        const _Legend('VIP',      '28 %', _C.grenadier),
        const _Legend('Régulier', '42 %', _C.regular),
        const _Legend('À risque', '12 %', _C.risk),
        const _Legend('Perdu',    '18 %', _C.lost),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final String name, value;
  final Color color;
  const _Legend(this.name, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(name,
              style: GoogleFonts.inter(fontSize: 11, color: _C.ink60)),
        ),
        Text(value,
            style: GoogleFonts.spaceMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _C.ink)),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 10;
    const stroke = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final segs = [
      [_C.grenadier, 0.28],
      [_C.regular, 0.42],
      [_C.risk, 0.12],
      [_C.lost, 0.18],
    ];

    double start = -math.pi / 2;
    for (final s in segs) {
      final sweep = (s[1] as double) * 2 * math.pi - 0.08;
      paint.color = s[0] as Color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start, sweep, false, paint,
      );
      start += (s[1] as double) * 2 * math.pi;
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _TopClientsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(adminClientsProvider);
    
    return _WhiteCard(
      title: 'Classement clients',
      subtitle: 'Par points cumulés (Réel)',
      child: clientsAsync.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _C.grenadier))),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (clients) {
          if (clients.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Aucun client trouvé."),
            );
          }
          final topClients = clients.take(4).toList();
          return Column(
            children: topClients.map((c) {
              final user = c['user'];
              final name = user != null ? '${user['firstName']} ${user['lastName']}' : 'Client Inconnu';
              final pts = '${c['loyaltyPoints']} pts';
              final isActive = user != null ? user['isActive'] : false;
              
              return _ClientRowW(
                data: _CR(
                  name, 
                  pts, 
                  isActive ? 'Actif' : 'Inactif', 
                  isActive ? _C.regular : _C.lost, 
                  Colors.white
                )
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CR {
  final String name, pts, tag;
  final Color tagBg, tagText;
  const _CR(this.name, this.pts, this.tag, this.tagBg, this.tagText);
}

class _ClientRowW extends StatelessWidget {
  final _CR data;
  const _ClientRowW({required this.data});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
              color: _C.emberSoft, shape: BoxShape.circle),
          child: Center(
            child: Text(data.name.isNotEmpty ? data.name[0] : '?',
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.grenadierDp)),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.name,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _C.ink)),
            Text(data.pts,
                style: GoogleFonts.spaceMono(fontSize: 10, color: _C.ink40)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: data.tagBg,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(data.tag,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: data.tagText)),
        ),
      ]),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  final int count;
  const _PendingBanner({required this.count});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.emberSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.grenadier.withValues(alpha: 0.18)),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _C.grenadier,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.pending_actions_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$count demandes en attente',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.grenadierDp)),
            Text('Partenariats à approuver',
                style: GoogleFonts.inter(fontSize: 11, color: _C.ink60)),
          ],
        )),
        const Icon(Icons.chevron_right_rounded, color: _C.grenadier, size: 20),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 1 — COMMERÇANTS
// ══════════════════════════════════════════════════════════════
class _MerchantsTab extends ConsumerWidget {
  const _MerchantsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commercesAsync = ref.watch(adminCommercesProvider);

    return commercesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _C.grenadier)),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (commerces) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminCommercesProvider.future),
          color: _C.grenadier,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _TabTitle('Commerçants', '${commerces.length} partenaires actifs'),
              const SizedBox(height: 16),
              if (commerces.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Aucun commerçant actif trouvé."),
                ),
              ...commerces.map((m) {
                final clientCount = m['clients']?.length ?? 0;
                return _MerchCard(
                  m: _Merch(m['name'], m['category'] ?? 'Commerce', '$clientCount clients', m['status'] == 'active'),
                );
              }),
            ]),
          ),
        );
      },
    );
  }
}

class _Merch {
  final String name, cat, clients;
  final bool active;
  const _Merch(this.name, this.cat, this.clients, this.active);
}

class _MerchCard extends StatelessWidget {
  final _Merch m;
  const _MerchCard({required this.m});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.grenadier, _C.grenadierDp],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(m.name.isNotEmpty ? m.name[0] : '?',
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.name,
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.ink)),
            Text(m.cat,
                style: GoogleFonts.inter(fontSize: 12, color: _C.ink60)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
                color: m.active ? _C.regular : _C.lost,
                shape: BoxShape.circle),
          ),
          const SizedBox(height: 4),
          Text(m.clients,
              style: GoogleFonts.spaceMono(fontSize: 10, color: _C.ink60)),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 2 — CLIENTS CRM
// ══════════════════════════════════════════════════════════════
class _ClientsTab extends ConsumerWidget {
  const _ClientsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(adminClientsProvider);

    return clientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _C.grenadier)),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (clients) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminClientsProvider.future),
          color: _C.grenadier,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _TabTitle('Clients', '${clients.length} membres affichés'),
              const SizedBox(height: 16),
              if (clients.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Aucun client trouvé."),
                ),
              if (clients.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _C.line),
                  ),
                  child: Column(
                    children: clients.asMap().entries.map((e) {
                      final c = e.value;
                      final user = c['user'];
                      final name = user != null ? '${user['firstName']} ${user['lastName']}' : 'Client Inconnu';
                      final pts = '${c['loyaltyPoints']} pts';
                      final isActive = user != null ? user['isActive'] : false;
                      
                      return _CrmRow(
                        cl: _CL(
                          name, 
                          pts, 
                          isActive ? 'Actif' : 'Inactif', 
                          isActive ? _C.regular : _C.lost, 
                          Colors.white
                        ),
                        isLast: e.key == clients.length - 1,
                      );
                    }).toList(),
                  ),
                ),
            ]),
          ),
        );
      },
    );
  }
}

class _CL {
  final String name, pts, tag;
  final Color tagBg, tagText;
  const _CL(this.name, this.pts, this.tag, this.tagBg, this.tagText);
}

class _CrmRow extends StatelessWidget {
  final _CL cl;
  final bool isLast;
  const _CrmRow({required this.cl, required this.isLast});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: _C.line)),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
              color: _C.emberSoft, shape: BoxShape.circle),
          child: Center(
            child: Text(cl.name.isNotEmpty ? cl.name[0] : '?',
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.grenadierDp)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cl.name,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _C.ink)),
            Text(cl.pts,
                style: GoogleFonts.spaceMono(fontSize: 10, color: _C.ink40)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: cl.tagBg, borderRadius: BorderRadius.circular(100)),
          child: Text(cl.tag,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cl.tagText)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 3 — DEMANDES EN ATTENTE
// ══════════════════════════════════════════════════════════════
class _PendingTab extends ConsumerWidget {
  const _PendingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(adminPendingProvider);

    return pendingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _C.grenadier)),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (requests) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminPendingProvider.future),
          color: _C.grenadier,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _TabTitle('Demandes partenariat',
                  '${requests.length} dossier(s) en attente'),
              const SizedBox(height: 16),
              if (requests.isEmpty)
                const _EmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Aucune demande',
                    sub: 'Tout est à jour.')
              else
                ...requests.map((r) {
                  final user = r['owner'];
                  final ownerName = user != null ? '${user['firstName']} ${user['lastName']}' : 'Inconnu';
                  final email = user != null ? user['email'] : 'Inconnu';
                  final date = r['createdAt'] != null ? r['createdAt'].toString().substring(0, 10) : 'Récent';

                  return _PendingCard(
                    r: _PR(r['_id'], r['name'], ownerName, r['category'] ?? 'Commerce', email, date),
                    onApprove: () async {
                      try {
                        await AdminService.approveCommerce(r['_id']);
                        ref.invalidate(adminPendingProvider);
                        ref.invalidate(adminStatsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${r['name']} approuvé ✓'),
                            backgroundColor: _C.regular,
                          ));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: _C.grenadierDp,
                          ));
                        }
                      }
                    },
                    onReject: () async {
                       try {
                        await AdminService.rejectCommerce(r['_id']);
                        ref.invalidate(adminPendingProvider);
                        ref.invalidate(adminStatsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${r['name']} rejeté'),
                            backgroundColor: _C.grenadierDp,
                          ));
                        }
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: _C.grenadierDp,
                          ));
                        }
                      }
                    },
                  );
                }),
            ]),
          ),
        );
      },
    );
  }
}

class _PR {
  final String id, name, owner, cat, email, time;
  const _PR(this.id, this.name, this.owner, this.cat, this.email, this.time);
}

class _PendingCard extends StatelessWidget {
  final _PR r;
  final VoidCallback onApprove, onReject;
  const _PendingCard(
      {required this.r, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_C.grenadier, _C.grenadierDp],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(r.name.isNotEmpty ? r.name[0] : '?',
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.name,
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.ink)),
              Text(r.owner,
                  style: GoogleFonts.inter(fontSize: 12, color: _C.ink60)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _C.emberSoft,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text('En attente',
                style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: _C.grenadierDp,
                    letterSpacing: 0.03)),
          ),
        ]),
        const SizedBox(height: 14),
        _InfoRow(Icons.category_rounded, r.cat),
        const SizedBox(height: 5),
        _InfoRow(Icons.email_outlined, r.email),
        const SizedBox(height: 5),
        _InfoRow(Icons.access_time_rounded, 'Soumis le ${r.time}'),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: _ActionBtn(
                label: 'Rejeter',
                filled: false,
                onTap: onReject),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionBtn(
                label: 'Approuver',
                filled: true,
                onTap: onApprove),
          ),
        ]),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13, color: _C.ink40),
      const SizedBox(width: 7),
      Expanded(
          child: Text(text,
              style: GoogleFonts.inter(fontSize: 12, color: _C.ink60))),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: filled ? _C.grenadier : _C.bg,
          borderRadius: BorderRadius.circular(11),
          border: filled ? null : Border.all(color: _C.line),
          boxShadow: filled
              ? [BoxShadow(
                  color: _C.grenadier.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )]
              : null,
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : _C.ink60)),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED UTILITIES
// ══════════════════════════════════════════════════════════════
class _WhiteCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _WhiteCard(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.bricolageGrotesque(
                fontSize: 14, fontWeight: FontWeight.w700, color: _C.ink)),
        Text(subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: _C.ink40)),
        const SizedBox(height: 2),
        child,
      ]),
    );
  }
}

class _TabTitle extends StatelessWidget {
  final String title, sub;
  const _TabTitle(this.title, this.sub);
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: GoogleFonts.bricolageGrotesque(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _C.ink,
              letterSpacing: -0.6)),
      const SizedBox(height: 3),
      Text(sub,
          style: GoogleFonts.inter(fontSize: 13, color: _C.ink60)),
    ]);
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const _EmptyState({required this.icon, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: _C.emberSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _C.regular, size: 28),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: GoogleFonts.bricolageGrotesque(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.ink)),
          const SizedBox(height: 4),
          Text(sub,
              style: GoogleFonts.inter(fontSize: 13, color: _C.ink60)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  LOGO MARK
// ══════════════════════════════════════════════════════════════
class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.27),
        gradient: const LinearGradient(
          colors: [_C.grenadier, _C.grenadierDp],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.grenadier.withValues(alpha: 0.28),
            blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: CustomPaint(painter: _LogoPainter(size: size)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double size;
  const _LogoPainter({required this.size});
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = s.width * (5.5 / 36)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final cx = s.width / 2, cy = s.height / 2, r = s.width * 0.30;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.0, 311.5 * math.pi / 180, false, p);
    final ax = s.width * 0.72, ay1 = s.height * 0.14, ay2 = s.height * 0.33;
    canvas.drawPath(Path()
      ..moveTo(ax, ay1)
      ..lineTo(ax, ay2)
      ..lineTo(ax - s.width * 0.19, ay2), p);
  }
  @override bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════
//  BOTTOM NAVIGATION
// ══════════════════════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.grid_view_rounded,     Icons.grid_view_rounded,    'Aperçu'),
      (Icons.store_rounded,         Icons.store_outlined,        'Commerçants'),
      (Icons.people_rounded,        Icons.people_outline_rounded,'Clients'),
      (Icons.pending_actions_rounded,Icons.pending_outlined,     'Demandes'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        border: Border(top: BorderSide(color: _C.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final active = i == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? _C.grenadier.withValues(alpha: 0.09)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        active ? e.value.$1 : e.value.$2,
                        size: 22,
                        color: active ? _C.grenadier : _C.ink40,
                      ),
                      const SizedBox(height: 3),
                      Text(e.value.$3,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: active ? _C.grenadier : _C.ink40)),
                    ]),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
