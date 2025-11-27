# Weather App

A Flutter mobile weather application that fetches and displays weather data from OpenWeatherMap API.

## Features

- **Search by City**: Enter any city name to get current weather conditions
- **Current Weather Display**: Shows temperature, weather description, humidity, wind speed, and weather icon
- **3-Day Forecast**: View minimum and maximum temperatures with weather conditions for the next 3 days
- **Error Handling**: Properly handles "city not found" and "no internet connection" errors
- **Local Storage**: Automatically saves your last searched city and loads it when you reopen the app
- **Mobile-Optimized UI**: Beautiful gradient design optimized for phone screens

## API Used

- **OpenWeatherMap API** (Free tier)
  - Current Weather Data API
  - 5-Day/3-Hour Forecast API
  - API Key: `create your own`

## Project Structure

The app uses a simple 3-folder structure:

```
lib/
├── main.dart           # App entry point
├── models/             # Data models
│   └── weather_model.dart
├── services/           # API service layer
│   └── weather_service.dart
└── screens/            # UI screens
    └── weather_screen.dart
```

## Dependencies

- `http: ^1.1.0` - HTTP requests to weather API
- `shared_preferences: ^2.2.2` - Local storage for last searched city
- `intl: ^0.19.0` - Date formatting

## Setup & Installation

1. Clone the repository
2. Ensure Flutter SDK is installed
3. Run `flutter pub get` to install dependencies
4. Run the app with `flutter run`

## How to Use

1. Launch the app
2. Enter a city name in the search bar
3. Press the search button or hit enter
4. View current weather and 3-day forecast
5. The app will remember your last searched city


## Error States

The app handles the following error states:
- **City Not Found**: Shows location icon with error message
- **No Internet Connection**: Shows WiFi off icon with error message
- **General API Errors**: Shows error icon with descriptive message

## Platform Support

Built with Flutter, this app supports:
- Android
- iOS
- Web (with responsive mobile view)

## Developer

Built as a mobile weather application project demonstrating:
- RESTful API integration
- State management
- Error handling
- Local data persistence
- Mobile-first UI design



