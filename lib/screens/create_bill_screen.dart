import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_settings.dart';
import '../models/bill_model.dart';
import '../services/storage_service.dart';
import '../utils/number_to_words.dart';
import '../utils/smooth_page_route.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_scaffold.dart';
import 'bill_preview_screen.dart';
import 'settings_screen.dart';

class CreateBillScreen extends StatefulWidget {
  final BillModel? existingBill;

  const CreateBillScreen({super.key, this.existingBill});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final _formKey = GlobalKey<FormState>();

  AppSettings _settings = const AppSettings();
  bool _isLoading = true;

  // Kilometer controllers
  final _totalKmCtrl = TextEditingController(text: '3000');
  final _fixedKmCtrl = TextEditingController(text: '3000');
  final _extraKmCtrl = TextEditingController(text: '0');
  final _tripKmCtrl = TextEditingController(text: '800');

  // Deduction controllers
  final _cngAmtCtrl = TextEditingController(text: '14000');
  final _absentCtrl = TextEditingController(text: '0');
  final _peneltyCtrl = TextEditingController(text: '0');
  final _advanceCtrl = TextEditingController(text: '0');

  // Metadata controllers
  final _billNoCtrl = TextEditingController();
  final _billMonthCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _vehicleNoCtrl = TextEditingController();
  final _mobNoCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _isAutoCalculatingExtraKm = true;
  bool _showDetailsSection = false;

  @override
  void initState() {
    super.initState();
    _initializeData();

    _totalKmCtrl.addListener(_onKmChanged);
    _fixedKmCtrl.addListener(_onKmChanged);
    _tripKmCtrl.addListener(_onFieldChanged);
    _cngAmtCtrl.addListener(_onFieldChanged);
    _absentCtrl.addListener(_onFieldChanged);
    _peneltyCtrl.addListener(_onFieldChanged);
    _advanceCtrl.addListener(_onFieldChanged);
  }

  void _onKmChanged() {
    if (_isAutoCalculatingExtraKm) {
      final total = double.tryParse(_totalKmCtrl.text.trim()) ?? 0.0;
      final fixed = double.tryParse(_fixedKmCtrl.text.trim()) ?? 0.0;
      final extra = total > fixed ? (total - fixed) : 0.0;
      _extraKmCtrl.text = extra == extra.roundToDouble() ? extra.toInt().toString() : extra.toStringAsFixed(1);
    }
    setState(() {});
  }

  void _onFieldChanged() {
    setState(() {});
  }

  Future<void> _initializeData() async {
    _settings = await StorageService.loadSettings();

    if (widget.existingBill != null) {
      final b = widget.existingBill!;
      _totalKmCtrl.text = b.totalKm.toString();
      _fixedKmCtrl.text = b.fixedKm.toString();
      _extraKmCtrl.text = b.extraKm.toString();
      _tripKmCtrl.text = b.tripKm.toString();
      _cngAmtCtrl.text = b.cngAmt.toString();
      _absentCtrl.text = b.absentAmt.toString();
      _peneltyCtrl.text = b.peneltyAmt.toString();
      _advanceCtrl.text = b.advanceAmt.toString();

      _billNoCtrl.text = b.billNo;
      _billMonthCtrl.text = b.billMonth;
      _vehicleNoCtrl.text = b.vehicleNo;
      _mobNoCtrl.text = b.mobNo;

      final dates = b.dateRange.split(' to ');
      if (dates.length == 2) {
        _startDateCtrl.text = dates[0].trim();
        _endDateCtrl.text = dates[1].trim();
      }
    } else {
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);

      final dateFormat = DateFormat('dd/MM/yyyy');
      _startDateCtrl.text = dateFormat.format(_startDate);
      _endDateCtrl.text = dateFormat.format(_endDate);

      _billNoCtrl.text = _settings.nextBillNo.toString();
      _billMonthCtrl.text = DateFormat('MMMM').format(now);
      _vehicleNoCtrl.text = _settings.vehicleNo;
      _mobNoCtrl.text = _settings.mobNo;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _totalKmCtrl.dispose();
    _fixedKmCtrl.dispose();
    _extraKmCtrl.dispose();
    _tripKmCtrl.dispose();
    _cngAmtCtrl.dispose();
    _absentCtrl.dispose();
    _peneltyCtrl.dispose();
    _advanceCtrl.dispose();
    _billNoCtrl.dispose();
    _billMonthCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _mobNoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              onPrimary: Colors.black,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        final format = DateFormat('dd/MM/yyyy');
        _startDateCtrl.text = format.format(picked.start);
        _endDateCtrl.text = format.format(picked.end);
        _billMonthCtrl.text = DateFormat('MMMM').format(picked.start);
      });
    }
  }

  // Calculations
  double get _totalKm => double.tryParse(_totalKmCtrl.text.trim()) ?? 0.0;
  double get _fixedKm => double.tryParse(_fixedKmCtrl.text.trim()) ?? 0.0;
  double get _extraKm => double.tryParse(_extraKmCtrl.text.trim()) ?? 0.0;
  double get _tripKm => double.tryParse(_tripKmCtrl.text.trim()) ?? 0.0;

  double get _totalKmEarning => _totalKm * _settings.totalKmRate;
  double get _tripKmEarning => _tripKm * _settings.tripKmRate;
  double get _grossAmount => _totalKmEarning + _tripKmEarning;

  double get _tdsAmount => (_totalKm * (_settings.tdsPercent / 100.0)).roundToDouble();
  double get _cngAmt => double.tryParse(_cngAmtCtrl.text.trim()) ?? 0.0;
  double get _cngCharges => (_cngAmt * (_settings.cngChargesPercent / 100.0)).roundToDouble();

  double get _absentAmt => double.tryParse(_absentCtrl.text.trim()) ?? 0.0;
  double get _peneltyAmt => double.tryParse(_peneltyCtrl.text.trim()) ?? 0.0;
  double get _advanceAmt => double.tryParse(_advanceCtrl.text.trim()) ?? 0.0;

  double get _totalDeductions =>
      _tdsAmount + _cngAmt + _cngCharges + _absentAmt + _peneltyAmt + _advanceAmt;

  double get _netTotalAmount => _grossAmount - _totalDeductions;

  BillModel _buildBillModel() {
    final dateRange = '${_startDateCtrl.text.trim()} to ${_endDateCtrl.text.trim()}';

    return BillModel.calculate(
      id: widget.existingBill?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      billNo: _billNoCtrl.text.trim(),
      billMonth: _billMonthCtrl.text.trim(),
      dateRange: dateRange,
      companyName: _settings.companyName,
      clientName: _settings.clientName,
      bankName: _settings.bankName,
      accountNo: _settings.accountNo,
      ifscCode: _settings.ifscCode,
      aadharNo: _settings.aadharNo,
      panNo: _settings.panNo,
      vehicleNo: _vehicleNoCtrl.text.trim(),
      mobNo: _mobNoCtrl.text.trim(),
      signatureTitle: _settings.signatureTitle,
      totalKm: _totalKm,
      fixedKm: _fixedKm,
      extraKm: _extraKm,
      tripKm: _tripKm,
      totalKmRate: _settings.totalKmRate,
      tripKmRate: _settings.tripKmRate,
      tdsPercent: _settings.tdsPercent,
      cngChargesPercent: _settings.cngChargesPercent,
      cngAmt: _cngAmt,
      absentAmt: _absentAmt,
      peneltyAmt: _peneltyAmt,
      advanceAmt: _advanceAmt,
    );
  }

  void _onGeneratePressed() {
    if (!_formKey.currentState!.validate()) return;

    final bill = _buildBillModel();
    Navigator.push(
      context,
      SmoothPageRoute(page: BillPreviewScreen(bill: bill)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const GlassScaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
      );
    }

    final currencyFormat = NumberFormat('#,##,###', 'en_IN');

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(widget.existingBill != null ? 'Edit Bill #${widget.existingBill!.billNo}' : 'Create Bill'),
        actions: [
          IconButton(
            tooltip: 'Settings & Rates',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                SmoothPageRoute(
                  page: SettingsScreen(
                    onSettingsSaved: () async {
                      final updated = await StorageService.loadSettings();
                      setState(() => _settings = updated);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Rates Info Glass Pill
            GlassCard(
              borderRadius: 14,
              opacity: 0.1,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rates: Total KM = ₹${_settings.totalKmRate.toInt()}/KM | Trip KM = ₹${_settings.tripKmRate.toInt()}/KM | TDS = ${_settings.tdsPercent.toInt()}% | CNG = ${_settings.cngChargesPercent.toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        SmoothPageRoute(
                          page: SettingsScreen(
                            onSettingsSaved: () async {
                              final updated = await StorageService.loadSettings();
                              setState(() => _settings = updated);
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Change', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section 1: Kilometer Entry Glass Card
            _buildGlassSection(
              title: 'Kilometers Entry',
              icon: Icons.speed,
              accentColor: const Color(0xFF38BDF8),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassInput(
                        controller: _totalKmCtrl,
                        label: 'Total KM',
                        hint: '3000',
                        suffix: 'KM',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _fixedKmCtrl,
                        label: 'Fixed KM',
                        hint: '3000',
                        suffix: 'KM',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassInput(
                        controller: _extraKmCtrl,
                        label: 'Extra KM',
                        hint: '0',
                        suffix: 'KM',
                        onChanged: (_) => _isAutoCalculatingExtraKm = false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _tripKmCtrl,
                        label: 'Trip KM',
                        hint: '800',
                        suffix: 'KM',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Auto TDS Indicator Glass Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'TDS (${_settings.tdsPercent.toInt()}% of Total KM):  ₹${_tdsAmount.toStringAsFixed(0)} (Calculated automatically)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2: Deductions Entry Glass Card
            _buildGlassSection(
              title: 'Deductions & Expenses',
              icon: Icons.money_off_rounded,
              accentColor: const Color(0xFFEC4899),
              children: [
                _buildGlassInput(
                  controller: _cngAmtCtrl,
                  label: 'CNG Amount',
                  hint: '14000',
                  prefix: '₹ ',
                ),
                const SizedBox(height: 10),
                // Auto CNG 5% indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, size: 16, color: Color(0xFF34D399)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'CNG Charges (${_settings.cngChargesPercent.toInt()}% over CNG):  ₹${_cngCharges.toStringAsFixed(0)} (Added directly)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFA7F3D0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassInput(
                        controller: _absentCtrl,
                        label: 'ABSENT',
                        hint: '0',
                        prefix: '₹ ',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _peneltyCtrl,
                        label: 'PENELTY',
                        hint: '0',
                        prefix: '₹ ',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _advanceCtrl,
                        label: 'ADVANCE',
                        hint: '0',
                        prefix: '₹ ',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3: Bill Details (Collapsible Glass Card)
            GlassCard(
              borderRadius: 20,
              opacity: 0.08,
              padding: const EdgeInsets.all(4),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _showDetailsSection,
                  onExpansionChanged: (v) => setState(() => _showDetailsSection = v),
                  leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF818CF8)),
                  title: const Text(
                    'Bill Details & Dates',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  subtitle: Text(
                    'Bill #${_billNoCtrl.text} | ${_billMonthCtrl.text} | ${_vehicleNoCtrl.text}',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassInput(
                            controller: _billNoCtrl,
                            label: 'Bill No',
                            hint: '1',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassInput(
                            controller: _billMonthCtrl,
                            label: 'Bill Month',
                            hint: 'September',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Date range selector
                    InkWell(
                      onTap: _pickDateRange,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date Range',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_startDateCtrl.text} to ${_endDateCtrl.text}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Icon(Icons.calendar_month_rounded, color: Color(0xFF38BDF8), size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassInput(
                            controller: _vehicleNoCtrl,
                            label: 'Vehicle No',
                            hint: 'MH14HU7580',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassInput(
                            controller: _mobNoCtrl,
                            label: 'Mob No',
                            hint: '9594366406',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Live Calculation Summary Glass Card
            GlassCard(
              borderRadius: 22,
              opacity: 0.12,
              tintColor: const Color(0xFF10B981),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35), width: 1.5),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Calculation Summary',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('AUTO', style: TextStyle(color: Color(0xFF34D399), fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _summaryRow(
                    'Total KM (${_totalKm.toInt()} × ₹${_settings.totalKmRate.toInt()})',
                    '₹${currencyFormat.format(_totalKmEarning)}',
                  ),
                  const SizedBox(height: 6),
                  _summaryRow(
                    'Trip KM (${_tripKm.toInt()} × ₹${_settings.tripKmRate.toInt()})',
                    '₹${currencyFormat.format(_tripKmEarning)}',
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'Gross Earnings',
                    '₹${currencyFormat.format(_grossAmount)}',
                    isBold: true,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  _summaryRow(
                    'Total Deductions (TDS + CNG + Other)',
                    '- ₹${currencyFormat.format(_totalDeductions)}',
                    textColor: const Color(0xFFF87171),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL AMOUNT',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          '₹${currencyFormat.format(_netTotalAmount)}',
                          key: ValueKey<double>(_netTotalAmount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF34D399),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'In Words: ${NumberToWords.convert(_netTotalAmount.round())}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Button: Generate Bill PNG
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _onGeneratePressed,
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 22),
                label: const Text(
                  'GENERATE & PREVIEW BILL PNG',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSection({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return GlassCard(
      borderRadius: 20,
      opacity: 0.08,
      padding: const EdgeInsets.all(16),
      border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    String? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
        suffixText: suffix,
        suffixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Required';
        if (double.tryParse(val.trim()) == null) return 'Invalid';
        return null;
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
