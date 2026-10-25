import 'dart:convert';
import '../utils/number_to_words.dart';

class BillModel {
  final String id;
  final String billNo;
  final String billMonth;
  final String dateRange;
  final String companyName;
  final String clientName;
  final String bankName;
  final String accountNo;
  final String ifscCode;
  final String aadharNo;
  final String panNo;
  final String vehicleNo;
  final String mobNo;
  final String signatureTitle;

  final double totalKm;
  final double fixedKm;
  final double extraKm;
  final double tripKm;

  final double totalKmRate;
  final double tripKmRate;
  final double tdsPercent;
  final double cngChargesPercent;

  final double tdsAmount;
  final double cngAmt;
  final double cngCharges;
  final double absentAmt;
  final double peneltyAmt;
  final double advanceAmt;

  final double grossAmount;
  final double totalDeductions;
  final double totalAmount;
  final String amountInWords;
  final DateTime createdAt;

  BillModel({
    required this.id,
    required this.billNo,
    required this.billMonth,
    required this.dateRange,
    required this.companyName,
    required this.clientName,
    required this.bankName,
    required this.accountNo,
    required this.ifscCode,
    required this.aadharNo,
    required this.panNo,
    required this.vehicleNo,
    required this.mobNo,
    this.signatureTitle = 'Authorised Singature',
    required this.totalKm,
    required this.fixedKm,
    required this.extraKm,
    required this.tripKm,
    required this.totalKmRate,
    required this.tripKmRate,
    required this.tdsPercent,
    required this.cngChargesPercent,
    required this.tdsAmount,
    required this.cngAmt,
    required this.cngCharges,
    required this.absentAmt,
    required this.peneltyAmt,
    required this.advanceAmt,
    required this.grossAmount,
    required this.totalDeductions,
    required this.totalAmount,
    required this.amountInWords,
    required this.createdAt,
  });

  factory BillModel.calculate({
    required String id,
    required String billNo,
    required String billMonth,
    required String dateRange,
    required String companyName,
    required String clientName,
    required String bankName,
    required String accountNo,
    required String ifscCode,
    required String aadharNo,
    required String panNo,
    required String vehicleNo,
    required String mobNo,
    String signatureTitle = 'Authorised Singature',
    required double totalKm,
    required double fixedKm,
    double? extraKm,
    required double tripKm,
    required double totalKmRate,
    required double tripKmRate,
    required double tdsPercent,
    required double cngChargesPercent,
    required double cngAmt,
    required double absentAmt,
    required double peneltyAmt,
    required double advanceAmt,
    DateTime? createdAt,
  }) {
    final computedExtraKm = extraKm ?? (totalKm > fixedKm ? totalKm - fixedKm : 0.0);
    // TDS is 1% of Total KM as per business rule (e.g. 3000 * 1% = 30)
    final tdsAmount = (totalKm * (tdsPercent / 100.0)).roundToDouble();
    // CNG Charges is 5% over CNG amount (e.g. 14000 * 5% = 700)
    final cngCharges = (cngAmt * (cngChargesPercent / 100.0)).roundToDouble();

    // Gross = Total KM * rate + Trip KM * rate
    final grossAmount = (totalKm * totalKmRate) + (tripKm * tripKmRate);

    // Total deductions = TDS + CNG Amount + CNG Charges + Absent + Penelty + Advance
    final totalDeductions = tdsAmount +
        cngAmt +
        cngCharges +
        absentAmt +
        peneltyAmt +
        advanceAmt;

    final totalAmount = grossAmount - totalDeductions;
    final int roundedTotal = totalAmount.round();
    final words = NumberToWords.convert(roundedTotal);

    return BillModel(
      id: id,
      billNo: billNo,
      billMonth: billMonth,
      dateRange: dateRange,
      companyName: companyName,
      clientName: clientName,
      bankName: bankName,
      accountNo: accountNo,
      ifscCode: ifscCode,
      aadharNo: aadharNo,
      panNo: panNo,
      vehicleNo: vehicleNo,
      mobNo: mobNo,
      signatureTitle: signatureTitle,
      totalKm: totalKm,
      fixedKm: fixedKm,
      extraKm: computedExtraKm,
      tripKm: tripKm,
      totalKmRate: totalKmRate,
      tripKmRate: tripKmRate,
      tdsPercent: tdsPercent,
      cngChargesPercent: cngChargesPercent,
      tdsAmount: tdsAmount,
      cngAmt: cngAmt,
      cngCharges: cngCharges,
      absentAmt: absentAmt,
      peneltyAmt: peneltyAmt,
      advanceAmt: advanceAmt,
      grossAmount: grossAmount,
      totalDeductions: totalDeductions,
      totalAmount: totalAmount,
      amountInWords: words,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billNo': billNo,
      'billMonth': billMonth,
      'dateRange': dateRange,
      'companyName': companyName,
      'clientName': clientName,
      'bankName': bankName,
      'accountNo': accountNo,
      'ifscCode': ifscCode,
      'aadharNo': aadharNo,
      'panNo': panNo,
      'vehicleNo': vehicleNo,
      'mobNo': mobNo,
      'signatureTitle': signatureTitle,
      'totalKm': totalKm,
      'fixedKm': fixedKm,
      'extraKm': extraKm,
      'tripKm': tripKm,
      'totalKmRate': totalKmRate,
      'tripKmRate': tripKmRate,
      'tdsPercent': tdsPercent,
      'cngChargesPercent': cngChargesPercent,
      'tdsAmount': tdsAmount,
      'cngAmt': cngAmt,
      'cngCharges': cngCharges,
      'absentAmt': absentAmt,
      'peneltyAmt': peneltyAmt,
      'advanceAmt': advanceAmt,
      'grossAmount': grossAmount,
      'totalDeductions': totalDeductions,
      'totalAmount': totalAmount,
      'amountInWords': amountInWords,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as String,
      billNo: map['billNo'] as String? ?? '1',
      billMonth: map['billMonth'] as String? ?? '',
      dateRange: map['dateRange'] as String? ?? '',
      companyName: map['companyName'] as String? ?? 'AARYA ROADLINES',
      clientName: map['clientName'] as String? ?? 'M/S SAI POOJA TRAVELS',
      bankName: map['bankName'] as String? ?? '',
      accountNo: map['accountNo'] as String? ?? '',
      ifscCode: map['ifscCode'] as String? ?? '',
      aadharNo: map['aadharNo'] as String? ?? '',
      panNo: map['panNo'] as String? ?? '',
      vehicleNo: map['vehicleNo'] as String? ?? '',
      mobNo: map['mobNo'] as String? ?? '',
      signatureTitle: map['signatureTitle'] as String? ?? 'Authorised Singature',
      totalKm: (map['totalKm'] as num?)?.toDouble() ?? 0.0,
      fixedKm: (map['fixedKm'] as num?)?.toDouble() ?? 0.0,
      extraKm: (map['extraKm'] as num?)?.toDouble() ?? 0.0,
      tripKm: (map['tripKm'] as num?)?.toDouble() ?? 0.0,
      totalKmRate: (map['totalKmRate'] as num?)?.toDouble() ?? 14.0,
      tripKmRate: (map['tripKmRate'] as num?)?.toDouble() ?? 13.0,
      tdsPercent: (map['tdsPercent'] as num?)?.toDouble() ?? 1.0,
      cngChargesPercent: (map['cngChargesPercent'] as num?)?.toDouble() ?? 5.0,
      tdsAmount: (map['tdsAmount'] as num?)?.toDouble() ?? 0.0,
      cngAmt: (map['cngAmt'] as num?)?.toDouble() ?? 0.0,
      cngCharges: (map['cngCharges'] as num?)?.toDouble() ?? 0.0,
      absentAmt: (map['absentAmt'] as num?)?.toDouble() ?? 0.0,
      peneltyAmt: (map['peneltyAmt'] as num?)?.toDouble() ?? 0.0,
      advanceAmt: (map['advanceAmt'] as num?)?.toDouble() ?? 0.0,
      grossAmount: (map['grossAmount'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (map['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountInWords: map['amountInWords'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory BillModel.fromJson(String source) =>
      BillModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
