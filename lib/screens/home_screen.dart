import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_settings.dart';
import '../models/bill_model.dart';
import '../services/storage_service.dart';
import '../utils/smooth_page_route.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_scaffold.dart';
import 'bill_preview_screen.dart';
import 'create_bill_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<BillModel> _bills = [];
  AppSettings _settings = const AppSettings();
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: This Month, 2: High Value (>₹25k)

  final currencyFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final settings = await StorageService.loadSettings();
    final bills = await StorageService.loadBills();
    if (mounted) {
      setState(() {
        _settings = settings;
        _bills = bills;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBill(BillModel bill) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Delete Bill?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete Bill #${bill.billNo} (${bill.billMonth})?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteBill(bill.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill #${bill.billNo} deleted'),
            backgroundColor: const Color(0xFF334155),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<BillModel> get _filteredBills {
    var list = _bills;
    final now = DateTime.now();
    final currentMonthName = DateFormat('MMMM').format(now).toLowerCase();

    if (_selectedFilterIndex == 1) {
      list = list.where((b) => b.billMonth.toLowerCase().contains(currentMonthName)).toList();
    } else if (_selectedFilterIndex == 2) {
      list = list.where((b) => b.totalAmount >= 25000).toList();
    }

    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((b) {
      return b.billNo.toLowerCase().contains(q) ||
          b.billMonth.toLowerCase().contains(q) ||
          b.vehicleNo.toLowerCase().contains(q) ||
          b.dateRange.toLowerCase().contains(q);
    }).toList();
  }

  double get _totalRevenue => _bills.fold(0.0, (sum, b) => sum + b.totalAmount);
  double get _totalDistance => _bills.fold(0.0, (sum, b) => sum + b.totalKm + b.tripKm);

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : RefreshIndicator(
              color: const Color(0xFF38BDF8),
              backgroundColor: const Color(0xFF1E293B),
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // Glass Top Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFACC15).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFFACC15).withValues(alpha: 0.6),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.local_shipping, size: 14, color: Color(0xFFFACC15)),
                                          const SizedBox(width: 6),
                                          Text(
                                            _settings.companyName.toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFFFACC15),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Billing Dashboard',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Settings Button with Glass glow
                          GlassCard(
                            padding: const EdgeInsets.all(10),
                            borderRadius: 14,
                            opacity: 0.12,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                SmoothPageRoute(page: const SettingsScreen()),
                              );
                              _loadData();
                            },
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Analytics Glass Metrics Cards Row
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 104,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildMetricCard(
                            title: 'Total Revenue',
                            value: '₹${currencyFormat.format(_totalRevenue)}',
                            icon: Icons.account_balance_wallet_outlined,
                            accentColor: const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 12),
                          _buildMetricCard(
                            title: 'Total Distance',
                            value: '${_totalDistance.toInt()} KM',
                            icon: Icons.speed_rounded,
                            accentColor: const Color(0xFF38BDF8),
                          ),
                          const SizedBox(width: 12),
                          _buildMetricCard(
                            title: 'Total Bills',
                            value: '${_bills.length}',
                            icon: Icons.receipt_long_rounded,
                            accentColor: const Color(0xFFA855F7),
                          ),
                          const SizedBox(width: 12),
                          _buildMetricCard(
                            title: 'Current Rate',
                            value: '₹${_settings.totalKmRate.toInt()} / ₹${_settings.tripKmRate.toInt()}',
                            icon: Icons.currency_rupee,
                            accentColor: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 18)),

                  // Hero Glass Banner for Quick Creation
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassCard(
                        borderRadius: 22,
                        opacity: 0.12,
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                          width: 1.4,
                        ),
                        tintColor: const Color(0xFF0284C7),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.add_task_rounded, color: Color(0xFF38BDF8), size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Quick Generate',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Next: #${_settings.nextBillNo}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Client: ${_settings.clientName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'TDS: ${_settings.tdsPercent.toInt()}% • CNG: ${_settings.cngChargesPercent.toInt()}% • Total KM: ₹${_settings.totalKmRate.toInt()}/KM',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  elevation: 6,
                                  shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    SmoothPageRoute(page: const CreateBillScreen()),
                                  );
                                  _loadData();
                                },
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                label: const Text(
                                  '+ CREATE NEW BILL',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Search & Filter Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Search Input with Glass
                          GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            borderRadius: 14,
                            opacity: 0.08,
                            child: TextField(
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search bill #, month, vehicle...',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13.5),
                                prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.white60, size: 18),
                                        onPressed: () => setState(() => _searchQuery = ''),
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Filter Chips Row
                          Row(
                            children: [
                              _buildFilterChip('All Bills (${_bills.length})', 0),
                              const SizedBox(width: 8),
                              _buildFilterChip('This Month', 1),
                              const SizedBox(width: 8),
                              _buildFilterChip('High Value (>₹25k)', 2),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // Saved Bills List
                  if (_bills.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: GlassCard(
                          borderRadius: 20,
                          opacity: 0.06,
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 54, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 14),
                              const Text(
                                'No bills generated yet',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap "+ CREATE NEW BILL" above to enter KM & deductions to export your first PNG bill!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_filteredBills.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Center(
                          child: Text(
                            'No bills found matching your filter.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final bill = _filteredBills[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: _buildBillGlassCard(bill),
                          );
                        },
                        childCount: _filteredBills.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return GlassCard(
      width: 155,
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      opacity: 0.08,
      tintColor: accentColor,
      border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBillGlassCard(BillModel bill) {
    return GlassCard(
      borderRadius: 18,
      opacity: 0.09,
      padding: const EdgeInsets.all(16),
      onTap: () async {
        await Navigator.push(
          context,
          SmoothPageRoute(page: BillPreviewScreen(bill: bill, autoSave: false)),
        );
        _loadData();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Bill No & Net Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '#${bill.billNo}',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.billMonth,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bill.vehicleNo,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Net Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${currencyFormat.format(bill.totalAmount)}',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Net Payable',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 10),

          // Detail Badges
          Row(
            children: [
              _buildBadge(Icons.route, '${bill.totalKm.toInt()} Total KM'),
              const SizedBox(width: 8),
              _buildBadge(Icons.directions_car, '${bill.tripKm.toInt()} Trip KM'),
              const SizedBox(width: 8),
              _buildBadge(Icons.local_gas_station, 'CNG: ₹${currencyFormat.format(bill.cngAmt)}'),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 20),
                onPressed: () => _deleteBill(bill),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    SmoothPageRoute(page: CreateBillScreen(existingBill: bill)),
                  );
                  _loadData();
                },
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text('Edit', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    SmoothPageRoute(page: BillPreviewScreen(bill: bill, autoSave: false)),
                  );
                  _loadData();
                },
                icon: const Icon(Icons.share_rounded, size: 15),
                label: const Text('Share PNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
