import 'dart:convert';

class AppSettings {
  final double totalKmRate;
  final double tripKmRate;
  final double tdsPercent;
  final double cngChargesPercent;
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
  final int nextBillNo;

  const AppSettings({
    this.totalKmRate = 14.0,
    this.tripKmRate = 13.0,
    this.tdsPercent = 1.0,
    this.cngChargesPercent = 5.0,
    this.companyName = 'AARYA ROADLINES',
    this.clientName = 'M/S SAI POOJA TRAVELS',
    this.bankName = 'Abhyudaya Co-Op. Bank Ltd.',
    this.accountNo = '067011100006806',
    this.ifscCode = 'ABHY0065045',
    this.aadharNo = '358438409380',
    this.panNo = 'EDEPB7194D',
    this.vehicleNo = 'MH14HU7580',
    this.mobNo = '9594366406',
    this.signatureTitle = 'Authorised Singature',
    this.nextBillNo = 1,
  });

  AppSettings copyWith({
    double? totalKmRate,
    double? tripKmRate,
    double? tdsPercent,
    double? cngChargesPercent,
    String? companyName,
    String? clientName,
    String? bankName,
    String? accountNo,
    String? ifscCode,
    String? aadharNo,
    String? panNo,
    String? vehicleNo,
    String? mobNo,
    String? signatureTitle,
    int? nextBillNo,
  }) {
    return AppSettings(
      totalKmRate: totalKmRate ?? this.totalKmRate,
      tripKmRate: tripKmRate ?? this.tripKmRate,
      tdsPercent: tdsPercent ?? this.tdsPercent,
      cngChargesPercent: cngChargesPercent ?? this.cngChargesPercent,
      companyName: companyName ?? this.companyName,
      clientName: clientName ?? this.clientName,
      bankName: bankName ?? this.bankName,
      accountNo: accountNo ?? this.accountNo,
      ifscCode: ifscCode ?? this.ifscCode,
      aadharNo: aadharNo ?? this.aadharNo,
      panNo: panNo ?? this.panNo,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      mobNo: mobNo ?? this.mobNo,
      signatureTitle: signatureTitle ?? this.signatureTitle,
      nextBillNo: nextBillNo ?? this.nextBillNo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalKmRate': totalKmRate,
      'tripKmRate': tripKmRate,
      'tdsPercent': tdsPercent,
      'cngChargesPercent': cngChargesPercent,
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
      'nextBillNo': nextBillNo,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      totalKmRate: (map['totalKmRate'] as num?)?.toDouble() ?? 14.0,
      tripKmRate: (map['tripKmRate'] as num?)?.toDouble() ?? 13.0,
      tdsPercent: (map['tdsPercent'] as num?)?.toDouble() ?? 1.0,
      cngChargesPercent: (map['cngChargesPercent'] as num?)?.toDouble() ?? 5.0,
      companyName: map['companyName'] as String? ?? 'AARYA ROADLINES',
      clientName: map['clientName'] as String? ?? 'M/S SAI POOJA TRAVELS',
      bankName: map['bankName'] as String? ?? 'Abhyudaya Co-Op. Bank Ltd.',
      accountNo: map['accountNo'] as String? ?? '067011100006806',
      ifscCode: map['ifscCode'] as String? ?? 'ABHY0065045',
      aadharNo: map['aadharNo'] as String? ?? '358438409380',
      panNo: map['panNo'] as String? ?? 'EDEPB7194D',
      vehicleNo: map['vehicleNo'] as String? ?? 'MH14HU7580',
      mobNo: map['mobNo'] as String? ?? '9594366406',
      signatureTitle: map['signatureTitle'] as String? ?? 'Authorised Singature',
      nextBillNo: (map['nextBillNo'] as num?)?.toInt() ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) =>
      AppSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
