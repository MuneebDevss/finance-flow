# 📱 FinanceFlow

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.6-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License" />
</p>

**FinanceFlow** is a cross-platform personal finance management app built with **Flutter**. It helps users take control of their financial life by tracking income and expenses, planning budgets, managing debts, setting savings goals, and calculating applicable Zakat — all in one place. Real-time crypto and stock tracking via the **CoinGecko API**, combined with rich visual analytics, make financial management simple and insightful.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🧾 **Income & Expense Tracking** | Log and categorize all your income and expenditure |
| 📊 **Budget Planning** | Set monthly budgets and monitor spending against them |
| 🏦 **Savings Goals** | Define goals and track progress toward reaching them |
| 💳 **Debt Management** | Keep track of money owed and money borrowed |
| 🧾 **Bill Reminders** | Never miss a payment with bill tracking |
| 💸 **Zakat Calculator** | Automatically calculate your Zakat obligation based on assets |
| 🪙 **Crypto Tracking** | Live cryptocurrency prices and portfolio value via CoinGecko API |
| 📈 **Stock Investments** | Monitor your stock portfolio in real time |
| 📊 **Visual Analytics** | Interactive charts for a clear picture of your finances |
| 🔒 **Secure Cloud Sync** | Data stored securely with Firebase Firestore and Authentication |
| 📱 **Cross-Platform** | Runs on Android and iOS from a single codebase |

---

## 🧠 Tech Stack

| Layer | Technology |
|---|---|
| **UI Framework** | Flutter / Dart |
| **State Management** | Provider, GetX |
| **Cloud Backend** | Firebase Firestore, Firebase Authentication |
| **Data Visualization** | fl_chart |
| **Crypto API** | CoinGecko REST API |
| **Local Storage** | Shared Preferences |
| **Architecture** | Clean Architecture (Feature-first), SOLID principles |

---

## 🗂️ Project Structure

```
lib/
├── Core/                  # Shared utilities, theme, constants, formatters
│   ├── DeviceUtils/
│   ├── HelpingFunctions/
│   ├── Theme/
│   ├── UrlHandler/
│   ├── constants/
│   └── formatter/
└── Features/              # Feature modules (Clean Architecture)
    ├── Auth/              # Authentication (login, register)
    ├── BudgetPlanning/    # Budget creation and tracking
    ├── Debts/             # Debt management
    ├── Expense/           # Expense logging
    ├── Income/            # Income logging
    ├── SavingGoals/       # Savings goal tracking
    ├── Settings/          # App settings and profile
    ├── bill/              # Bill reminders
    ├── stocks/            # Stock portfolio tracking
    └── zakat/             # Zakat calculation
```

Each feature module follows Clean Architecture layers:
- **Domain** — entities, repository interfaces, use cases
- **Data** — repository implementations, data sources
- **Presentation** — UI screens and widgets

---

## 🛠️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **≥ 3.6.0**
- A Firebase project with **Firestore** and **Authentication** enabled
- An Android or iOS emulator / physical device

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/muneebdevss/finance-flow.git
cd finance-flow

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
#    Download google-services.json (Android) and/or GoogleService-Info.plist (iOS)
#    from your Firebase project console and place them in the respective platform folders:
#      android/app/google-services.json
#      ios/Runner/GoogleService-Info.plist

# 4. Run the app
flutter run
```

### Build for release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Cloud database |
| `fl_chart` | Charts and data visualization |
| `provider` | Lightweight state management |
| `get` | Navigation and additional state utilities |
| `http` | REST API calls (CoinGecko) |
| `shared_preferences` | Local key-value storage |
| `connectivity_plus` | Network connectivity detection |
| `image_picker` | Profile photo selection |
| `intl` | Date/number formatting |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m "feat: add your feature"`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.


