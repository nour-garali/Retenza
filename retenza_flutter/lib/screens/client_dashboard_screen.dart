import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_provider.dart';
import '../services/auth_service.dart';

// ══════════════════════════════════════════════════════════════
//  RETENZA — CLIENT DASHBOARD
//  Tableau de bord mobile (Carte, Cadeaux, Profil)
// ══════════════════════════════════════════════════════════════

class ClientDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ClientDashboardScreen({super.key, required this.onLogout});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFEB), // Beige chaud (bg)
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _CarteTab(),
            _CadeauxTab(),
            _ProfilTab(onLogout: widget.onLogout),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEDE5DF), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFD73E26), // Grenadier
          unselectedItemColor: const Color(0xFF9C8B82), // Ink-40
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.credit_card_rounded),
              ),
              label: 'Carte',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.card_giftcard_rounded),
              ),
              label: 'Cadeaux',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_rounded),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  ONGLET 1 : CARTE
// ──────────────────────────────────────────────────────────────
class _CarteTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(clientDashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD73E26))),
      error: (e, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFD73E26), size: 40),
            const SizedBox(height: 16),
            Text('Erreur de chargement', style: GoogleFonts.bricolageGrotesque(fontSize: 18)),
            Text(e.toString(), style: GoogleFonts.inter(fontSize: 12)),
            TextButton(
              onPressed: () => ref.invalidate(clientDashboardProvider),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
      data: (data) {
        final accounts = List<dynamic>.from(data['loyaltyAccounts'] ?? []);
        final transactions = List<dynamic>.from(data['lastTransactions'] ?? []);

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(clientDashboardProvider),
          color: const Color(0xFFD73E26),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (accounts.isEmpty)
                  _buildEmptyCard()
                else
                  ...accounts.map((acc) => _WalletCard(account: acc)),

                const SizedBox(height: 24),
                Text(
                  'Activité récente',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B100C),
                  ),
                ),
                const SizedBox(height: 12),
                
                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Aucune activité récente.', style: GoogleFonts.inter(color: const Color(0xFF9C8B82))),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDE5DF)),
                    ),
                    child: Column(
                      children: transactions.map((tx) => _TransactionTile(tx: tx)).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE5DF)),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFF9C8B82)),
          const SizedBox(height: 16),
          Text(
            'Aucune carte',
            style: GoogleFonts.bricolageGrotesque(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Scannez un QR code chez un commerçant partenaire pour ajouter votre première carte.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6E5B52)),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final dynamic account;
  const _WalletCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final commerceName = account['commerce']?['name'] ?? 'Commerce inconnu';
    final points = account['points'] ?? 0;
    final stamps = account['stamps'] ?? 0;
    
    // Pour l'exemple, supposons 10 tampons max
    final maxStamps = 10;
    final double progress = (stamps / maxStamps).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFD73E26), Color(0xFFA82C18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD73E26).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40, top: -40,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    commerceName,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'RETENZA',
                      style: GoogleFonts.spaceMono(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    points.toString(),
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'points · $stamps/$maxStamps tampons',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plus que ${maxStamps - stamps} tampons',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (points >= 100) // Exemple: VIP si > 100 pts
                    Text(
                      '★ VIP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final dynamic tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final type = tx['type'] ?? 'earn';
    final amount = tx['amount'] ?? 0;
    final commerceName = tx['commerce']?['name'] ?? '';
    final dateStr = tx['createdAt'];
    
    String title = '';
    String sign = '';
    Color valueColor = const Color(0xFF1B100C);
    
    if (type == 'earn') {
      title = 'Achat $commerceName';
      sign = '+';
      valueColor = const Color(0xFF3F8E84); // Regular green
    } else if (type == 'redeem') {
      title = 'Offre utilisée $commerceName';
      sign = '-';
    } else {
      title = 'Transaction $commerceName';
    }

    // Simplistic date format
    String dateLabel = 'Récent';
    if (dateStr != null) {
      dateLabel = dateStr.toString().substring(0, 10);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEDE5DF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B100C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF9C8B82),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign$amount pts',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  ONGLET 2 : CADEAUX
// ──────────────────────────────────────────────────────────────
class _CadeauxTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B100C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  'Récompenses',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Débloquez vos cadeaux avec vos points',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildRewardItem('100 pts', 'Café offert', true),
          _buildRewardItem('150 pts', 'Pâtisserie au choix', true),
          _buildRewardItem('300 pts', 'Menu complet', false),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String pts, String title, bool available) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE5DF)),
        boxShadow: const [BoxShadow(color: Color(0x0A1B100C), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: available ? const Color(0xFFFCE7DD) : const Color(0xFFF4EFEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                available ? '🎁' : '🔒',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: available ? const Color(0xFF1B100C) : const Color(0xFF9C8B82),
                  ),
                ),
                Text(
                  available ? 'Disponible — $pts' : 'Verrouillée — $pts',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9C8B82),
                  ),
                ),
              ],
            ),
          ),
          if (available)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD73E26),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Échanger', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE5DF),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Bientôt',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9C8B82),
                ),
              ),
            )
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  ONGLET 3 : PROFIL
// ──────────────────────────────────────────────────────────────
class _ProfilTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfilTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64, color: Color(0xFFD73E26)),
          const SizedBox(height: 24),
          Text(
            'Mon Profil',
            style: GoogleFonts.bricolageGrotesque(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await AuthService.logout();
              onLogout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD73E26),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          )
        ],
      ),
    );
  }
}
