class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final DateTime date;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.date,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String cityName) {
    return Weather(
      cityName: cityName,
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: json['main']['temp_min'].toDouble(),
      maxTemp: json['main']['temp_max'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}
