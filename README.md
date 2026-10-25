# Aarya Roadlines — Transport Billing App

A cross-platform Flutter application (Android & iOS) designed for transport and fleet logistics billing, featuring a **Glassmorphism UI**, real-time calculations, settings customization, and instant **high-resolution PNG invoice generation and sharing**.

---

## 🌟 Key Features

### 1. Transport Bill Generation
- **Exact Spreadsheet / Invoice Format**: Generates bills matching standard transport invoices:
  - Header: **AARYA ROADLINES** (Yellow banner)
  - Sub-header: **M/S SAI POOJA TRAVELS**
  - Banking details: Bank Name, A/c No, IFSC Code, Aadhar Card No, PAN Card No.
  - Invoice details: Date range, Bill No, Bill Month, Vehicle No, Mobile No.
  - Authorized Signature box.
- **Itemized Calculation Table**:
  1. **Total KM**: User entered (e.g. 3,000 KM)
  2. **Fixed KM**: User entered (e.g. 3,000 KM)
  3. **Extra KM**: Auto-calculated (`Total KM - Fixed KM`, e.g. 0 KM)
  4. **Trip KM**: User entered (e.g. 800 KM)
  5. **T.D.S. 1%**: Auto-calculated as 1% of Total KM (e.g. ₹30)
  6. **CNG Amount**: User entered (e.g. ₹14,000)
  7. **CNG Charges 5%**: Auto-calculated as 5% over CNG Amount (e.g. ₹700)
  8. **Absent**: User entered deduction
  9. **Penalty**: User entered deduction
  10. **Advance**: User entered deduction
- **Net Calculation Formula**:
  $$\text{Gross} = (\text{Total KM} \times \text{Rate}) + (\text{Trip KM} \times \text{Rate})$$
  $$\text{Deductions} = \text{TDS} + \text{CNG Amount} + \text{CNG Charges} + \text{Absent} + \text{Penalty} + \text{Advance}$$
  $$\text{TOTAL AMOUNT} = \text{Gross} - \text{Deductions}$$
- **Amount in Words**: Converted automatically to Indian English words (*e.g., "Thirty Seven Thousand Six Hundred Seventy"*).

### 2. PNG Invoice Export & Instant Sharing
- Uses Flutter's `RepaintBoundary` rendering at 3.5× pixel density for ultra-sharp borders and text.
- One-tap sharing via WhatsApp, Gmail, Drive, or local storage using `share_plus`.
- Interactive pinch-to-zoom preview canvas.

### 3. Glassmorphic UI & Smooth Transitions
- Deep atmospheric night background with neon glowing ambient orbs.
- Frosted acrylic glass cards with backdrop filter blur (`sigma: 16`), translucent gradients, and glowing borders.
- Custom `SmoothPageRoute` with synchronized slide, scale, and fade transitions (`Curves.easeOutCubic`).

### 4. Customizable Settings & History
- Configurable **Total KM Rate** (default: ₹14/KM), **Trip KM Rate** (default: ₹13/KM), **TDS %**, and **CNG %**.
- Configurable Company, Client, Vehicle, and Banking defaults.
- Saved Bills History with search and filtering.

---

## 🚀 Building the Project

### Prerequisites
- Flutter SDK (3.27+)
- Android SDK (API 34/35) or Xcode (for iOS)

### Run Locally
```bash
flutter pub get
flutter run
```

### Build Android APK
```bash
flutter build apk --release
```
The output file will be at `build/app/outputs/flutter-apk/app-release.apk`.
