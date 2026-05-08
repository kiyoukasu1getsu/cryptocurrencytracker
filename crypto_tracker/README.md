# Crypto Tracker - Cryptocurrency Price Tracking App

A cross-platform mobile application built with Flutter (Dart) for tracking cryptocurrency prices and managing a virtual portfolio.

## Features

- **Real-time Price Tracking**: View current prices of top 50 cryptocurrencies by market cap
- **24h Price Changes**: See percentage changes in the last 24 hours with color indicators
- **Portfolio Management**: 
  - Add coins to your abstract portfolio with custom amounts and buy prices
  - Track profit/loss for each coin since purchase
  - View total portfolio value, invested amount, and overall returns
  - Edit or remove coins from portfolio
  - Data persists locally using SharedPreferences
- **Pull to Refresh**: Update prices manually
- **Responsive UI**: Material Design 3 with adaptive layouts

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **API**: CoinGecko API (free, no key required)
- **Local Storage**: SharedPreferences
- **HTTP Client**: http package

## Project Structure

```
crypto_tracker/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models.dart                  # Data models (CryptoCoin, PortfolioItem)
│   ├── api_service.dart             # CoinGecko API integration
│   ├── portfolio_provider.dart      # State management for portfolio
│   ├── home_screen.dart             # Main UI with tabs
│   └── add_to_portfolio_dialog.dart # Dialog for adding/editing coins
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or emulator

### Installation

1. Navigate to the project directory:
   ```bash
   cd crypto_tracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Usage

1. **View Prices**: The "Prices" tab shows the top 50 cryptocurrencies with their current prices and 24h changes.

2. **Add to Portfolio**: Tap on any coin to open the dialog where you can:
   - Enter the amount you own
   - Set your buy price
   - See a summary before confirming

3. **Manage Portfolio**: The "Portfolio" tab displays:
   - Total portfolio value
   - Total invested amount
   - Overall profit/loss (in USD and percentage)
   - Individual coin performance
   - Swipe left to remove a coin
   - Tap to edit amount or buy price

## API Information

This app uses the [CoinGecko API](https://www.coingecko.com/en/api) which:
- Is free to use
- Does not require an API key for basic usage
- Has rate limits (10-50 calls/minute depending on endpoint)
- Provides data for 10,000+ cryptocurrencies

## Dependencies

- `flutter`: SDK
- `http`: ^1.1.0 - HTTP client for API calls
- `provider`: ^6.1.1 - State management
- `shared_preferences`: ^2.2.2 - Local storage
- `intl`: ^0.18.1 - Internationalization (optional, for future localization)

## Future Enhancements

- [ ] Price alerts/notifications
- [ ] Historical price charts
- [ ] Multiple currency support (EUR, GBP, etc.)
- [ ] Search functionality
- [ ] Coin details page
- [ ] Export/import portfolio
- [ ] Dark mode toggle
- [ ] Biometric authentication

## License

This project is open source and available under the MIT License.

## Disclaimer

This app is for educational and informational purposes only. Cryptocurrency investments are subject to market risks. Always do your own research before making investment decisions.
