import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/models/bill_model.dart';
import 'package:billing_app/utils/number_to_words.dart';
import 'package:billing_app/widgets/bill_document_widget.dart';

void main() {
  group('Bill Calculation & In-Words Tests', () {
    test('Matches user bill exact numbers and deductions', () {
      final bill = BillModel.calculate(
        id: 'test-1',
        billNo: '1',
        billMonth: 'September',
        dateRange: '01/09/2026 to 30/09/2026',
        companyName: 'AARYA ROADLINES',
        clientName: 'M/S SAI POOJA TRAVELS',
        bankName: 'Abhyudaya Co-Op. Bank Ltd.',
        accountNo: '067011100006806',
        ifscCode: 'ABHY0065045',
        aadharNo: '358438409380',
        panNo: 'EDEPB7194D',
        vehicleNo: 'MH14HU7580',
        mobNo: '9594366406',
        totalKm: 3000,
        fixedKm: 3000,
        extraKm: 0,
        tripKm: 800,
        totalKmRate: 14.0,
        tripKmRate: 13.0,
        tdsPercent: 1.0,
        cngChargesPercent: 5.0,
        cngAmt: 14000,
        absentAmt: 0,
        peneltyAmt: 0,
        advanceAmt: 0,
      );

      // TDS is 1% of Total KM = 30
      expect(bill.tdsAmount, 30.0);
      // CNG charges = 5% of 14,000 = 700
      expect(bill.cngCharges, 700.0);
      // Gross = (3000 * 14) + (800 * 13) = 42000 + 10400 = 52400
      expect(bill.grossAmount, 52400.0);
      // Deductions = 30 + 14000 + 700 = 14730
      expect(bill.totalDeductions, 14730.0);
      // Net Total = 52400 - 14730 = 37670
      expect(bill.totalAmount, 37670.0);
      // Amount in words
      expect(bill.amountInWords, 'Thirty Seven Thousand Six Hundred Seventy');
    });

    test('NumberToWords converts Indian values correctly', () {
      expect(NumberToWords.convert(37670), 'Thirty Seven Thousand Six Hundred Seventy');
      expect(NumberToWords.convert(500), 'Five Hundred');
      expect(NumberToWords.convert(100000), 'One Lakh');
      expect(NumberToWords.convert(1550250), 'Fifteen Lakh Fifty Thousand Two Hundred Fifty');
    });

    testWidgets('BillDocumentWidget renders properly', (WidgetTester tester) async {
      final bill = BillModel.calculate(
        id: 'test-2',
        billNo: '1',
        billMonth: 'September',
        dateRange: '01/09/2026 to 30/09/2026',
        companyName: 'AARYA ROADLINES',
        clientName: 'M/S SAI POOJA TRAVELS',
        bankName: 'Abhyudaya Co-Op. Bank Ltd.',
        accountNo: '067011100006806',
        ifscCode: 'ABHY0065045',
        aadharNo: '358438409380',
        panNo: 'EDEPB7194D',
        vehicleNo: 'MH14HU7580',
        mobNo: '9594366406',
        totalKm: 3000,
        fixedKm: 3000,
        extraKm: 0,
        tripKm: 800,
        totalKmRate: 14.0,
        tripKmRate: 13.0,
        tdsPercent: 1.0,
        cngChargesPercent: 5.0,
        cngAmt: 14000,
        absentAmt: 0,
        peneltyAmt: 0,
        advanceAmt: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BillDocumentWidget(bill: bill),
            ),
          ),
        ),
      );

      expect(find.text('AARYA ROADLINES'), findsOneWidget);
      expect(find.text('M/S SAI POOJA TRAVELS'), findsOneWidget);
      expect(find.text('Total KM'), findsOneWidget);
      expect(find.text('Trip KM'), findsOneWidget);
      expect(find.text('TOTAL AMOUNT'), findsOneWidget);
      expect(find.text('37,670'), findsOneWidget);
      expect(find.text('Authorised Singature'), findsOneWidget);
    });
  });
}
