import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String apiKey = '665b4046c9fae75b33950e9d22418c2e';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String lastCityKey = 'last_searched_city';

  // Fetch current weather by city name
  Future<Weather> getCurrentWeather(String cityName) async {
    final url = Uri.parse(
      '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveLastSearchedCity(cityName);
        return Weather.fromJson(data, cityName);
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection');
      }
      rethrow;
    }
  }

  // Fetch 3-day forecast
  Future<List<ForecastDay>> getForecast(String cityName) async {
    final url = Uri.parse(
      '$baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric&cnt=24',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];

        // Group by day and get min/max temps
        Map<String, List<ForecastDay>> groupedByDay = {};

        for (var item in forecastList) {
          final forecast = ForecastDay.fromJson(item);
          final dateKey = forecast.date.toIso8601String().split('T')[0];

          if (!groupedByDay.containsKey(dateKey)) {
            groupedByDay[dateKey] = [];
          }
          groupedByDay[dateKey]!.add(forecast);
        }

        // Get 3 days forecast with min/max temps
        List<ForecastDay> dailyForecasts = [];
        int count = 0;

        for (var entry in groupedByDay.entries) {
          if (count >= 3) break;

          final dayForecasts = entry.value;
          final minTemp = dayForecasts
              .map((f) => f.minTemp)
              .reduce((a, b) => a < b ? a : b);
          final maxTemp = dayForecasts
              .map((f) => f.maxTemp)
              .reduce((a, b) => a > b ? a : b);

          dailyForecasts.add(
            ForecastDay(
              date: dayForecasts[0].date,
              minTemp: minTemp,
              maxTemp: maxTemp,
              description: dayForecasts[0].description,
              icon: dayForecasts[0].icon,
            ),
          );

          count++;
        }

        return dailyForecasts;
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection');
      }
      rethrow;
    }
  }

  // Save last searched city to local storage
  Future<void> saveLastSearchedCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastCityKey, cityName);
  }

  // Get last searched city from local storage
  Future<String?> getLastSearchedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastCityKey);
  }

  // Get weather icon URL
  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}
