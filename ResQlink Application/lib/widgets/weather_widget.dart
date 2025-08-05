import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class Weather {
  final double temp;
  final String condition;
  final String iconUrl;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String windDir;
  final double pressure;
  final double precipitation;
  final double visibility;
  final double uv;

  Weather({
    required this.temp,
    required this.condition,
    required this.iconUrl,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDir,
    required this.pressure,
    required this.precipitation,
    required this.visibility,
    required this.uv,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return Weather(
      temp: current['temp_c'].toDouble(),
      condition: current['condition']['text'],
      iconUrl: 'https:${current['condition']['icon']}',
      feelsLike: current['feelslike_c'].toDouble(),
      humidity: current['humidity'].toDouble(),
      windSpeed: current['wind_kph'].toDouble(),
      windDir: current['wind_dir'],
      pressure: current['pressure_mb'].toDouble(),
      precipitation: current['precip_mm'].toDouble(),
      visibility: current['vis_km'].toDouble(),
      uv: current['uv'].toDouble(),
    );
  }
}

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Weather? _weather;
  bool _isWeatherExpanded = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  Future<void> _getCurrentLocationWeather() async {
    setState(() => _loading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      await _getWeather(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print('Error getting location weather: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _getWeather(LatLng location) async {
    try {
      final apiKey = dotenv.env['WEATHER_API_KEY'];
      if (apiKey == null) {
        return;
      }
      
      final response = await http.get(
        Uri.parse(
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${location.latitude},${location.longitude}&aqi=no'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather = Weather.fromJson(data);
        });
      }
    } catch (e) {
      print('Weather API error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_weather == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : const Text('Weather information not available'),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isWeatherExpanded = !_isWeatherExpanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_weather!.temp.round()}°C',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.network(_weather!.iconUrl, width: 32, height: 32),
                    ],
                  ),
                  Icon(
                    _isWeatherExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                  ),
                ],
              ),
              Text(
                _weather!.condition,
                style: const TextStyle(fontSize: 16),
              ),
              if (_isWeatherExpanded) ...[
                const Divider(height: 16),
                Text(
                  'Feels like: ${_weather!.feelsLike.round()}°C',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Humidity: ${_weather!.humidity.round()}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'UV Index: ${_weather!.uv.round()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wind: ${_weather!.windSpeed.round()} km/h',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Direction: ${_weather!.windDir}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Visibility: ${_weather!.visibility} km',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Pressure: ${_weather!.pressure} mb',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
