import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();

  Weather? _currentWeather;
  List<ForecastDay>? _forecast;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLastSearchedCity();
  }

  Future<void> _loadLastSearchedCity() async {
    final lastCity = await _weatherService.getLastSearchedCity();
    if (lastCity != null) {
      _cityController.text = lastCity;
      _searchWeather();
    }
  }

  Future<void> _searchWeather() async {
    if (_cityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.getCurrentWeather(
        _cityController.text,
      );
      final forecast = await _weatherService.getForecast(_cityController.text);

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _currentWeather = null;
        _forecast = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blue.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                        onSubmitted: (_) => _searchWeather(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _searchWeather,
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _errorMessage != null
                    ? _buildErrorScreen()
                    : _currentWeather != null
                    ? _buildWeatherContent()
                    : _buildWelcomeScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny, size: 100, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Search for a city to get weather',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    IconData errorIcon;
    if (_errorMessage!.contains('internet')) {
      errorIcon = Icons.wifi_off;
    } else if (_errorMessage!.contains('not found')) {
      errorIcon = Icons.location_off;
    } else {
      errorIcon = Icons.error_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchWeather,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Weather Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _currentWeather!.cityName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMM d').format(_currentWeather!.date),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Image.network(
                      _weatherService.getIconUrl(_currentWeather!.icon),
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.cloud, size: 100);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_currentWeather!.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentWeather!.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(
                          Icons.water_drop,
                          'Humidity',
                          '${_currentWeather!.humidity.round()}%',
                        ),
                        _buildWeatherDetail(
                          Icons.air,
                          'Wind Speed',
                          '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Forecast Section
            if (_forecast != null && _forecast!.isNotEmpty) ...[
              const Text(
                '3-Day Forecast',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ..._forecast!.map((day) => _buildForecastCard(day)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildForecastCard(ForecastDay forecast) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE').format(forecast.date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(forecast.date),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.network(
                _weatherService.getIconUrl(forecast.icon),
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.cloud, size: 60);
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${forecast.maxTemp.round()}°',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${forecast.minTemp.round()}°',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
