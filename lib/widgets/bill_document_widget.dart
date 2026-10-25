import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';

class BillDocumentWidget extends StatelessWidget {
  final BillModel bill;
  final double width;

  const BillDocumentWidget({
    super.key,
    required this.bill,
    this.width = 720,
  });

  String _formatAmount(double amount, {bool showBlankIfZero = false}) {
    if (showBlankIfZero && amount == 0) return '';
    final formatter = NumberFormat('#,##,###', 'en_IN');
    if (amount == amount.roundToDouble()) {
      return formatter.format(amount.toInt());
    }
    return formatter.format(amount);
  }

  String _formatKm(double km) {
    if (km == km.roundToDouble()) {
      return km.toInt().toString();
    }
    return km.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    const borderSide = BorderSide(color: Colors.black, width: 1.5);
    const thinBorder = BorderSide(color: Colors.black, width: 1.0);

    const cellBoldStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Roboto',
      height: 1.25,
    );

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Yellow Banner: Company Name
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFF00), // Pure excel yellow
              border: Border(bottom: borderSide),
            ),
            child: Text(
              bill.companyName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
          ),

          // 2. Subheader: Client Name
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: borderSide),
            ),
            child: Text(
              bill.clientName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.black,
              ),
            ),
          ),

          // 3. Header Info Split (Bank info left, Invoice/Vehicle info right)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: Bank Details
                Expanded(
                  flex: 11,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      border: Border(right: borderSide),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoRow('Bank Name', bill.bankName),
                        const SizedBox(height: 3),
                        _infoRow('A/c No', bill.accountNo),
                        const SizedBox(height: 3),
                        _infoRow('IFSC Code', bill.ifscCode),
                        const SizedBox(height: 3),
                        _infoRow('Aadhar Card No', bill.aadharNo),
                        const SizedBox(height: 3),
                        _infoRow('Pan Card No', bill.panNo),
                      ],
                    ),
                  ),
                ),

                // Right Column: Date, Bill No, Vehicle, Mobile
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoRow('Date', bill.dateRange),
                        const SizedBox(height: 3),
                        _infoRow('Bill No', bill.billNo),
                        const SizedBox(height: 3),
                        _infoRow('Bill Month', bill.billMonth),
                        const SizedBox(height: 3),
                        _infoRow('Vehicle No', bill.vehicleNo),
                        const SizedBox(height: 3),
                        _infoRow('Mob No', bill.mobNo),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Double line separator above table
          Container(
            height: 4,
            decoration: const BoxDecoration(
              border: Border(
                top: borderSide,
                bottom: borderSide,
              ),
            ),
          ),

          // 4. Table Header
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: borderSide),
            ),
            child: Row(
              children: [
                _tableCell('Sr. No:', width: 75, isHeader: true, align: TextAlign.center),
                Expanded(
                  child: _tableCell('PARTICULARS', isHeader: true, align: TextAlign.center),
                ),
                _tableCell('AMOUNT', width: 170, isHeader: true, align: TextAlign.center),
              ],
            ),
          ),

          // 5. Data Rows
          _dataRow(1, 'Total KM', _formatKm(bill.totalKm)),
          _dataRow(2, 'Fixed KM', _formatKm(bill.fixedKm)),
          _dataRow(3, 'Extra KM', _formatKm(bill.extraKm)),
          _dataRow(4, 'Trip KM', _formatKm(bill.tripKm)),
          _dataRow(5, 'T.D.S. ${bill.tdsPercent.toInt()}%', _formatAmount(bill.tdsAmount)),
          _dataRow(6, 'CNG Amt', _formatAmount(bill.cngAmt)),
          _dataRow(7, 'CNG Charges ${bill.cngChargesPercent.toInt()}%', _formatAmount(bill.cngCharges)),
          _dataRow(8, 'ABSENT', _formatAmount(bill.absentAmt, showBlankIfZero: true)),
          _dataRow(9, 'PENELTY', _formatAmount(bill.peneltyAmt, showBlankIfZero: true)),
          _dataRow(10, 'ADVANCE', _formatAmount(bill.advanceAmt, showBlankIfZero: true)),

          // 6. Total Amount Row
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: borderSide,
                bottom: borderSide,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text('TOTAL AMOUNT', style: cellBoldStyle),
                  ),
                ),
                Container(
                  width: 170,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  alignment: Alignment.centerRight,
                  decoration: const BoxDecoration(
                    border: Border(left: thinBorder),
                  ),
                  child: Text(
                    _formatAmount(bill.totalAmount),
                    style: cellBoldStyle,
                  ),
                ),
              ],
            ),
          ),

          // Double separator below total row
          Container(
            height: 3,
            decoration: const BoxDecoration(
              border: Border(bottom: borderSide),
            ),
          ),

          // 7. Amount in Words Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: borderSide),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
                children: [
                  const TextSpan(
                    text: 'AMOUNT(IN WORDS):   ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: bill.amountInWords,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 8. Bottom Signature Box
          SizedBox(
            height: 100,
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    border: Border(left: borderSide),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border(top: thinBorder),
                        ),
                        child: Text(
                          bill.signatureTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _tableCell(
    String text, {
    double? width,
    bool isHeader = false,
    TextAlign align = TextAlign.left,
    bool hasLeftBorder = true,
  }) {
    const thinBorder = BorderSide(color: Colors.black, width: 1.0);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        border: hasLeftBorder ? const Border(left: thinBorder) : null,
      ),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _dataRow(int srNo, String particular, String amount) {
    const thinBorder = BorderSide(color: Colors.black, width: 1.0);
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: thinBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 75,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
            alignment: Alignment.center,
            child: Text(
              srNo.toString(),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: const BoxDecoration(
                border: Border(left: thinBorder),
              ),
              child: Text(
                particular,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            width: 170,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            alignment: Alignment.centerRight,
            decoration: const BoxDecoration(
              border: Border(left: thinBorder),
            ),
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
