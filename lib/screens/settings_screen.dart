import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onSettingsSaved;

  const SettingsScreen({super.key, this.onSettingsSaved});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _totalKmRateCtrl;
  late TextEditingController _tripKmRateCtrl;
  late TextEditingController _tdsPercentCtrl;
  late TextEditingController _cngChargesPercentCtrl;

  late TextEditingController _companyNameCtrl;
  late TextEditingController _clientNameCtrl;
  late TextEditingController _bankNameCtrl;
  late TextEditingController _accountNoCtrl;
  late TextEditingController _ifscCodeCtrl;
  late TextEditingController _aadharNoCtrl;
  late TextEditingController _panNoCtrl;
  late TextEditingController _vehicleNoCtrl;
  late TextEditingController _mobNoCtrl;
  late TextEditingController _nextBillNoCtrl;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await StorageService.loadSettings();
    _totalKmRateCtrl = TextEditingController(text: s.totalKmRate.toString());
    _tripKmRateCtrl = TextEditingController(text: s.tripKmRate.toString());
    _tdsPercentCtrl = TextEditingController(text: s.tdsPercent.toString());
    _cngChargesPercentCtrl = TextEditingController(text: s.cngChargesPercent.toString());

    _companyNameCtrl = TextEditingController(text: s.companyName);
    _clientNameCtrl = TextEditingController(text: s.clientName);
    _bankNameCtrl = TextEditingController(text: s.bankName);
    _accountNoCtrl = TextEditingController(text: s.accountNo);
    _ifscCodeCtrl = TextEditingController(text: s.ifscCode);
    _aadharNoCtrl = TextEditingController(text: s.aadharNo);
    _panNoCtrl = TextEditingController(text: s.panNo);
    _vehicleNoCtrl = TextEditingController(text: s.vehicleNo);
    _mobNoCtrl = TextEditingController(text: s.mobNo);
    _nextBillNoCtrl = TextEditingController(text: s.nextBillNo.toString());

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _totalKmRateCtrl.dispose();
    _tripKmRateCtrl.dispose();
    _tdsPercentCtrl.dispose();
    _cngChargesPercentCtrl.dispose();
    _companyNameCtrl.dispose();
    _clientNameCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNoCtrl.dispose();
    _ifscCodeCtrl.dispose();
    _aadharNoCtrl.dispose();
    _panNoCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _mobNoCtrl.dispose();
    _nextBillNoCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = AppSettings(
      totalKmRate: double.tryParse(_totalKmRateCtrl.text.trim()) ?? 14.0,
      tripKmRate: double.tryParse(_tripKmRateCtrl.text.trim()) ?? 13.0,
      tdsPercent: double.tryParse(_tdsPercentCtrl.text.trim()) ?? 1.0,
      cngChargesPercent: double.tryParse(_cngChargesPercentCtrl.text.trim()) ?? 5.0,
      companyName: _companyNameCtrl.text.trim(),
      clientName: _clientNameCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim(),
      accountNo: _accountNoCtrl.text.trim(),
      ifscCode: _ifscCodeCtrl.text.trim(),
      aadharNo: _aadharNoCtrl.text.trim(),
      panNo: _panNoCtrl.text.trim(),
      vehicleNo: _vehicleNoCtrl.text.trim(),
      mobNo: _mobNoCtrl.text.trim(),
      nextBillNo: int.tryParse(_nextBillNoCtrl.text.trim()) ?? 1,
    );

    await StorageService.saveSettings(updated);
    widget.onSettingsSaved?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _resetDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Reset to Defaults?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will reset all rates and company details to sample defaults.',
          style: TextStyle(color: Colors.white70),
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      const def = AppSettings();
      await StorageService.saveSettings(def);
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset to defaults'),
            backgroundColor: Color(0xFF334155),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const GlassScaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
      );
    }

    return GlassScaffold(
      appBar: GlassAppBar(
        title: const Text('Settings & Rates'),
        actions: [
          IconButton(
            tooltip: 'Reset to Defaults',
            icon: const Icon(Icons.restore_rounded),
            onPressed: _resetDefaults,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Section 1: Billing Rates
            _buildGlassSection(
              title: 'Billing Rates & Deductions',
              icon: Icons.calculate_outlined,
              accentColor: const Color(0xFF38BDF8),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassInput(
                        controller: _totalKmRateCtrl,
                        label: 'Total KM Rate (₹/KM)',
                        hint: '14.0',
                        prefixText: '₹ ',
                        isNumeric: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _tripKmRateCtrl,
                        label: 'Trip KM Rate (₹/KM)',
                        hint: '13.0',
                        prefixText: '₹ ',
                        isNumeric: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassInput(
                        controller: _tdsPercentCtrl,
                        label: 'TDS Rate (%)',
                        hint: '1.0',
                        suffixText: '%',
                        isNumeric: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _cngChargesPercentCtrl,
                        label: 'CNG Charges (%)',
                        hint: '5.0',
                        suffixText: '%',
                        isNumeric: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Section 2: Default Business & Vehicle Info
            _buildGlassSection(
              title: 'Default Business & Vehicle Info',
              icon: Icons.business_rounded,
              accentColor: const Color(0xFF818CF8),
              children: [
                _buildGlassInput(
                  controller: _companyNameCtrl,
                  label: 'Company Name (Yellow Banner)',
                  hint: 'AARYA ROADLINES',
                ),
                const SizedBox(height: 14),
                _buildGlassInput(
                  controller: _clientNameCtrl,
                  label: 'Client Name (Sub-header)',
                  hint: 'M/S SAI POOJA TRAVELS',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassInput(
                        controller: _vehicleNoCtrl,
                        label: 'Vehicle No',
                        hint: 'MH14HU7580',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _mobNoCtrl,
                        label: 'Mobile No',
                        hint: '9594366406',
                        isNumeric: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildGlassInput(
                  controller: _nextBillNoCtrl,
                  label: 'Next Bill Number',
                  hint: '1',
                  isNumeric: true,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Section 3: Banking & Details
            _buildGlassSection(
              title: 'Banking & Identification',
              icon: Icons.account_balance_rounded,
              accentColor: const Color(0xFF34D399),
              children: [
                _buildGlassInput(
                  controller: _bankNameCtrl,
                  label: 'Bank Name',
                  hint: 'Abhyudaya Co-Op. Bank Ltd.',
                ),
                const SizedBox(height: 14),
                _buildGlassInput(
                  controller: _accountNoCtrl,
                  label: 'Account Number',
                  hint: '067011100006806',
                ),
                const SizedBox(height: 14),
                _buildGlassInput(
                  controller: _ifscCodeCtrl,
                  label: 'IFSC Code',
                  hint: 'ABHY0065045',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassInput(
                        controller: _aadharNoCtrl,
                        label: 'Aadhar Card No',
                        hint: '358438409380',
                        isNumeric: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildGlassInput(
                        controller: _panNoCtrl,
                        label: 'PAN Card No',
                        hint: 'EDEPB7194D',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saveSettings,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text(
                  'SAVE SETTINGS',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.8),
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
    String? prefixText,
    String? suffixText,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
        suffixText: suffixText,
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
        return null;
      },
    );
  }
}
