import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

// ══════════════════════════════════════════════════════════════
//  RETENZA — MERCHANT DASHBOARD
//  Tabs : QR Code | Clients | Programme | Profil
// ══════════════════════════════════════════════════════════════

abstract class _T {
  static const bg       = Color(0xFFF8F6F4);
  static const ink      = Color(0xFF18110C);
  static const inkSoft  = Color(0xFF7A6B62);
  static const accent   = Color(0xFFD73E26);
  static const accentLight = Color(0xFFFFF0EE);
  static const surface  = Color(0xFFFFFFFF);
  static const border   = Color(0xFFE5E0DA);
}

class MerchantDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MerchantDashboardScreen({super.key, required this.onLogout});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _QRTab(),
            _ClientsTab(),
            _ProgramTab(),
            _ProfilTab(onLogout: widget.onLogout),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _T.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          backgroundColor: _T.surface,
          selectedItemColor: _T.accent,
          unselectedItemColor: _T.inkSoft,
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.qr_code_rounded),
              ),
              label: 'QR Code',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.people_outline_rounded),
              ),
              label: 'Clients',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.star_outline_rounded),
              ),
              label: 'Programme',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline_rounded),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 1 : QR CODE
// ══════════════════════════════════════════════════════════════

class _QRTab extends StatefulWidget {
  @override
  State<_QRTab> createState() => _QRTabState();
}

class _QRTabState extends State<_QRTab> {
  bool _loading = true;
  String? _qrUrl;
  String? _merchantCode;
  String? _commerceName;
  int _scanCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Fetch commerce info
      final comRes = await apiClient.get('/commerces/me');
      if (comRes.statusCode == 200 && comRes.data['success']) {
        final c = comRes.data['data']['commerce'];
        _commerceName = c['name'];
        _merchantCode = c['merchantCode'];
      }

      // Fetch (or generate) QR code
      final qrRes = await apiClient.post('/merchant/qrcode');
      if (qrRes.statusCode == 200 && qrRes.data['success']) {
        final qr = qrRes.data['data']['qrCode'];
        setState(() {
          _qrUrl = qr['url'];
          _scanCount = qr['scanCount'] ?? 0;
          _loading = false;
        });
      } else {
        setState(() { _error = 'QR Code introuvable'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header
        Row(
          children: [
            Text(
              'Mon QR Code',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _T.ink,
              ),
            ),
          ],
        ),
        Text(
          _commerceName ?? '',
          style: GoogleFonts.inter(fontSize: 14, color: _T.inkSoft),
        ),
        const SizedBox(height: 32),

        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(color: _T.accent),
            ),
          )
        else if (_error != null)
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: _T.accent, size: 48),
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.inter(color: _T.inkSoft)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _load,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          )
        else ...[
          // QR Code Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _T.border),
              boxShadow: [
                BoxShadow(
                  color: _T.ink.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // QR Visual
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: _qrUrl ?? 'https://retenza.app',
                    version: QrVersions.auto,
                    size: 220,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF18110C),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF18110C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Code badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _T.accentLight,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    _merchantCode ?? '',
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _T.accent,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Montrez ce QR Code à vos clients',
                  style: GoogleFonts.inter(fontSize: 13, color: _T.inkSoft),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatCard(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scans',
                value: _scanCount.toString(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Copy URL button
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _qrUrl ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Lien copié !'),
                  backgroundColor: _T.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copier le lien'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.accent,
              side: const BorderSide(color: _T.accent),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _T.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _T.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _T.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.bricolageGrotesque(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _T.ink)),
                Text(label,
                    style: GoogleFonts.inter(fontSize: 12, color: _T.inkSoft)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 2 : CLIENTS (placeholder)
// ══════════════════════════════════════════════════════════════

class _ClientsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline_rounded,
              size: 64, color: _T.inkSoft),
          const SizedBox(height: 16),
          Text('Mes Clients',
              style: GoogleFonts.bricolageGrotesque(
                  fontSize: 24, fontWeight: FontWeight.w700, color: _T.ink)),
          const SizedBox(height: 8),
          Text('Vos clients inscrits apparaîtront ici.',
              style: GoogleFonts.inter(fontSize: 14, color: _T.inkSoft)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 3 : PROGRAMME DE FIDÉLITÉ (placeholder)
// ══════════════════════════════════════════════════════════════

class _ProgramTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_outline_rounded, size: 64, color: _T.inkSoft),
          const SizedBox(height: 16),
          Text('Mon Programme',
              style: GoogleFonts.bricolageGrotesque(
                  fontSize: 24, fontWeight: FontWeight.w700, color: _T.ink)),
          const SizedBox(height: 8),
          Text('Gérez votre programme de fidélité ici.',
              style: GoogleFonts.inter(fontSize: 14, color: _T.inkSoft)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TAB 4 : PROFIL
// ══════════════════════════════════════════════════════════════

class _ProfilTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfilTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Mon Profil',
          style: GoogleFonts.bricolageGrotesque(
              fontSize: 28, fontWeight: FontWeight.w700, color: _T.ink),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () async {
            await AuthService.logout();
            onLogout();
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Se déconnecter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _T.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
