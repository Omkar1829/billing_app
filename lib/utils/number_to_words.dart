class NumberToWords {
  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];

  static String convert(int n) {
    if (n == 0) return 'Zero';
    if (n < 0) return 'Minus ${convert(-n)}';

    return _convertHelper(n).trim();
  }

  static String _convertHelper(int n) {
    if (n < 20) {
      return _units[n];
    }
    if (n < 100) {
      final unit = n % 10;
      return '${_tens[n ~/ 10]}${unit != 0 ? ' ${_units[unit]}' : ''}';
    }
    if (n < 1000) {
      final rem = n % 100;
      return '${_units[n ~/ 100]} Hundred${rem != 0 ? ' ${_convertHelper(rem)}' : ''}';
    }
    if (n < 100000) {
      final rem = n % 1000;
      return '${_convertHelper(n ~/ 1000)} Thousand${rem != 0 ? ' ${_convertHelper(rem)}' : ''}';
    }
    if (n < 10000000) {
      final rem = n % 100000;
      return '${_convertHelper(n ~/ 100000)} Lakh${rem != 0 ? ' ${_convertHelper(rem)}' : ''}';
    }
    final rem = n % 10000000;
    return '${_convertHelper(n ~/ 10000000)} Crore${rem != 0 ? ' ${_convertHelper(rem)}' : ''}';
  }
}
