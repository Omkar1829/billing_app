import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/bill_model.dart';

class StorageService {
  static const String _keySettings = 'app_settings';
  static const String _keyBills = 'saved_bills';

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySettings);
    if (jsonStr == null) {
      final defaultSettings = const AppSettings();
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
    try {
      return AppSettings.fromJson(jsonStr);
    } catch (_) {
      return const AppSettings();
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, settings.toJson());
  }

  static Future<List<BillModel>> loadBills() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyBills);
    if (list == null) return [];
    final bills = <BillModel>[];
    for (final item in list) {
      try {
        bills.add(BillModel.fromJson(item));
      } catch (_) {}
    }
    // Sort descending by date
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  static Future<void> saveBill(BillModel bill) async {
    final prefs = await SharedPreferences.getInstance();
    final bills = await loadBills();
    // Replace if id exists, or add to front
    final index = bills.indexWhere((b) => b.id == bill.id);
    if (index >= 0) {
      bills[index] = bill;
    } else {
      bills.insert(0, bill);
    }

    final stringList = bills.map((b) => b.toJson()).toList();
    await prefs.setStringList(_keyBills, stringList);

    // Also advance next bill number in settings if appropriate
    final settings = await loadSettings();
    final currentBillNum = int.tryParse(bill.billNo) ?? 0;
    if (currentBillNum >= settings.nextBillNo) {
      await saveSettings(settings.copyWith(nextBillNo: currentBillNum + 1));
    }
  }

  static Future<void> deleteBill(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bills = await loadBills();
    bills.removeWhere((b) => b.id == id);
    final stringList = bills.map((b) => b.toJson()).toList();
    await prefs.setStringList(_keyBills, stringList);
  }
}
