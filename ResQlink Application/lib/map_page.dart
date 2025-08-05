import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'widgets/camp_marker.dart';
import 'widgets/user_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

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

class SearchResult {
  final String name;
  final LatLng location;

  SearchResult({
    required this.name,
    required this.location,
  });
}

class Survivor {
  final String id;
  final LatLng location;
  final DateTime timestamp;
  final bool needsHelp;

  Survivor({
    required this.id,
    required this.location,
    required this.timestamp,
    required this.needsHelp,
  });

  factory Survivor.fromJson(Map<String, dynamic> json) {
    return Survivor(
      id: json['id'],
      location: LatLng(json['latitude'], json['longitude']),
      timestamp: DateTime.parse(json['created_at']),
      needsHelp: json['alert'] == 'yes',
    );
  }
}

class Camp {
  final String name;
  final String type;
  final LatLng location;
  final String status;
  final int capacity;

  Camp({
    required this.name,
    required this.type,
    required this.location,
    required this.status,
    required this.capacity,
  });
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _loading = false;
  List<LatLng> _routePoints = [];
  Camp? _selectedCamp;
  String? _routeDistance;
  String? _routeDuration;
  bool _isCalculatingRoute = false;

  // State variables
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Weather? _weather;
  bool _isWeatherExpanded = true;
  bool _isWeatherCompact = false;
  List<Survivor> _survivors = [];
  Timer? _survivorUpdateTimer;
  LatLng? _selectedSearchLocation;
  LatLng? _lastTappedLocation;
  String? _locationName;
  String? _stateName;
  String? _disasterRisk;
  String? _exactPlaceName;

  Future<void> _getLocationDetails(LatLng point) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _locationName = data['name'] ??
              data['display_name']?.split(',')[0] ??
              'Unknown Location';
          _stateName = data['address']?['state'] ?? 'Unknown State';
          final address = data['address'] ?? {};
          _exactPlaceName = address['road'] ??
              address['village'] ??
              address['town'] ??
              address['suburb'] ??
              address['city'] ??
              address['hamlet'];
          // Dummy logic for disaster risk based on location
          final random = point.latitude.abs() % 4;
          _disasterRisk = random < 1
              ? 'Low'
              : random < 2
                  ? 'Medium'
                  : random < 3
                      ? 'High'
                      : 'Very High';
        });
      }
    } catch (e) {
      print('Error getting location details: $e');
    }
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    setState(() {
      _lastTappedLocation = point;
    });
    _getWeather(point);
    _getLocationDetails(point);
  }

  Future<void> _refreshMap() async {
    setState(() => _loading = true);
    await Future.wait([
      _getCurrentLocation(),
      _updateSurvivors(),
      if (_lastTappedLocation != null) _getWeather(_lastTappedLocation!),
    ]);
    setState(() => _loading = false);
  }

  // Kerala relief camps and emergency centers
  final List<Camp> camps = [
    Camp(
      name: 'Thiruvananthapuram Medical Camp',
      type: 'Medical',
      location: const LatLng(8.5241, 76.9366),
      status: 'Active',
      capacity: 500,
    ),
    Camp(
      name: 'Kochi Emergency Center',
      type: 'Emergency',
      location: const LatLng(9.9312, 76.2673),
      status: 'Active',
      capacity: 400,
    ),
    Camp(
      name: 'Kozhikode Relief Camp',
      type: 'Shelter',
      location: const LatLng(11.2588, 75.7804),
      status: 'Active',
      capacity: 300,
    ),
    Camp(
      name: 'Alappuzha Flood Relief',
      type: 'Shelter',
      location: const LatLng(9.4981, 76.3388),
      status: 'Active',
      capacity: 250,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startSurvivorUpdates();
  }

  @override
  void dispose() {
    _survivorUpdateTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getWeather(LatLng location) async {
    try {
      final apiKey = dotenv.env['WEATHER_API_KEY'];
      if (apiKey == null) {
        _showSnackBar('Weather API key not found');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${location.latitude},${location.longitude}&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather = Weather.fromJson(data);
        });
      } else {
        print('Weather API error: ${response.statusCode} - ${response.body}');
        _showSnackBar('Unable to fetch weather information');
      }
    } catch (e) {
      print('Weather API error: $e');
      _showSnackBar('Error loading weather data');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openrouteservice.org/geocode/search?api_key=${dotenv.env['OPENROUTE_API_KEY']}&text=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        setState(() {
          _searchResults = features.map((feature) {
            final coordinates = feature['geometry']['coordinates'] as List;
            return SearchResult(
              name: feature['properties']['label'],
              location: LatLng(coordinates[1], coordinates[0]),
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Search API error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(SearchResult result) {
    setState(() {
      _selectedSearchLocation = result.location;
      _searchResults = [];
      _searchController.text = result.name;
    });

    _mapController.move(result.location, 15.0);
    _getWeather(result.location);
    _getLocationDetails(result.location);
    _getRoute(result.location);
  }

  Future<void> _startSurvivorUpdates() async {
    // Initial load
    await _updateSurvivors();

    // Set up periodic updates
    _survivorUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateSurvivors(),
    );
  }

  Future<void> _updateSurvivors() async {
    try {
      final supabase = Supabase.instance.client;
      // Fetch users who have location data and are not the current user
      final response = await supabase
          .from('users')
          .select('id, latitude, longitude, name, created_at')
          .not('latitude', 'is', null)
          .not('longitude', 'is', null)
          .neq('email', UserSession.email ?? '')
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _survivors = (response as List)
            .map((data) => Survivor(
                  id: data['id'].toString(),
                  location: LatLng(data['latitude'], data['longitude']),
                  timestamp: DateTime.parse(data['created_at']),
                  needsHelp: true,
                ))
            .toList();
      });
    } catch (e) {
      print('Supabase error: $e');
      setState(() {
        _survivors = [];
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      });
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentPosition == null) {
      _showSnackBar('Current location not available');
      return;
    }

    setState(() => _isCalculatingRoute = true);
    final apiKey = dotenv.env['OPENROUTE_API_KEY'];

    if (apiKey == null) {
      _showSnackBar('API key not found');
      return;
    }

    final start = [_currentPosition!.longitude, _currentPosition!.latitude];
    final end = [destination.longitude, destination.latitude];

    final body = {
      "coordinates": [start, end],
      "instructions": true,
      "preference": 'driving-car', // Default to driving-car
      "units": "km",
      "language": "en"
    };

    try {
      final url = Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(body),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List;
        final summary = data['routes'][0]['summary'];

        final distance = summary['distance']; // in meters
        final duration = summary['duration']; // in seconds

        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          // Format distance
          _routeDistance = distance > 1000
              ? '${(distance / 1000).toStringAsFixed(1)} km'
              : '${distance.toStringAsFixed(0)} m';

          // Format duration
          if (duration > 3600) {
            _routeDuration = '${(duration / 3600).toStringAsFixed(1)} hours';
          } else if (duration > 60) {
            _routeDuration = '${(duration / 60).toStringAsFixed(0)} minutes';
          } else {
            _routeDuration = '${duration.toStringAsFixed(0)} seconds';
          }

          // Center map to show entire route
          _fitRoute();
        });
      } else {
        print('Error Response: ${response.body}');
        _showSnackBar('Error calculating route: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while calculating route: $e');
      _showSnackBar('Error: Unable to calculate route');
    } finally {
      setState(() => _isCalculatingRoute = false);
    }
  }

  void _fitRoute() {
    if (_routePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
    );
  }

  void _selectCamp(Camp camp) {
    setState(() {
      _selectedCamp = camp;
      _getRoute(camp.location);
    });

    _mapController.move(camp.location, 15.0);
  }

  Widget _buildRouteInfo() {
    if (_routeDistance == null || _routeDuration == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      left: 16,
      right: 80,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance: $_routeDistance',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: $_routeDuration',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampInfo() {
    if (_selectedCamp == null) return const SizedBox.shrink();

    return Positioned(
      top: _routeDistance != null ? 120 : 16,
      left: 16,
      right: 80,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCamp!.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Type: ${_selectedCamp!.type}'),
              Text('Status: ${_selectedCamp!.status}'),
              Text('Capacity: ${_selectedCamp!.capacity}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => _searchLocation(value),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result.name),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    if (_weather == null) return const SizedBox.shrink();

    return Positioned(
      top: 80,
      right: 16,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_isWeatherExpanded) {
              _isWeatherExpanded = false;
              _isWeatherCompact = true;
            } else if (_isWeatherCompact) {
              _isWeatherExpanded = true;
              _isWeatherCompact = false;
            }
          });
        },
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(12),
              child: _isWeatherExpanded
                  ? _buildExpandedWeatherSafe()
                  : _buildCompactWeatherSafe(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactWeatherSafe() {
    final temp = _weather?.temp.round() ?? '--';
    final iconUrl = _weather?.iconUrl ?? '';
    final condition = _weather?.condition ?? '';
    final location = _locationName ?? 'Unknown Location';
    final state = _stateName ?? '';
    final exactPlace = _exactPlaceName ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$temp°C',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (iconUrl.isNotEmpty)
              Image.network(
                iconUrl,
                width: 32,
                height: 32,
              ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              turns: _isWeatherExpanded ? 0.5 : 0,
              child: const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          condition,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        if (exactPlace.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Text(
              exactPlace,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (state.isNotEmpty)
          Text(
            state,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildExpandedWeatherSafe() {
    final temp = _weather?.temp.round() ?? '--';
    final iconUrl = _weather?.iconUrl ?? '';
    final condition = _weather?.condition ?? '';
    final location = _locationName ?? 'Unknown Location';
    final state = _stateName ?? '';
    final exactPlace = _exactPlaceName ?? '';
    final feelsLike = _weather?.feelsLike.round() ?? '--';
    final humidity = _weather?.humidity.round() ?? '--';
    final windSpeed = _weather?.windSpeed.round() ?? '--';
    final windDir = _weather?.windDir ?? '';
    final uv = _weather?.uv.round() ?? '--';
    final visibility = _weather?.visibility ?? '--';
    final pressure = _weather?.pressure ?? '--';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$temp°C',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (iconUrl.isNotEmpty)
              Image.network(
                iconUrl,
                width: 32,
                height: 32,
              ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              turns: _isWeatherExpanded ? 0.5 : 0,
              child: const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          condition,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        if (exactPlace.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Text(
              exactPlace,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (state.isNotEmpty)
          Text(
            state,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        const Divider(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Feels like: $feelsLike°C',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Humidity: $humidity%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Wind: $windSpeed km/h $windDir',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'UV: $uv',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visibility: $visibility km',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Pressure: $pressure mb',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: const LatLng(10.8505, 76.2711), // Kerala center
              zoom: 8.0,
              onTap: _onMapTapped,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.resq_link',
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      width: 30,
                      height: 45,
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      child: const UserLocationMarker(),
                    ),
                  if (_lastTappedLocation != null)
                    Marker(
                      width: 30,
                      height: 30,
                      point: _lastTappedLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),
                  ...camps.map(
                    (camp) => Marker(
                      width: 30,
                      height: 30,
                      point: camp.location,
                      child: CampMarker(
                        isSelected: _selectedCamp == camp,
                        onTap: () => _selectCamp(camp),
                      ),
                    ),
                  ),
                  if (_selectedSearchLocation != null)
                    Marker(
                      width: 60,
                      height: 60,
                      point: _selectedSearchLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                ],
              ),
              // Survivor markers
              MarkerLayer(
                markers: _survivors
                    .map((survivor) => Marker(
                          width: 60,
                          height: 60,
                          point: survivor.location,
                          child: GestureDetector(
                            onTap: () {
                              _showSnackBar(
                                  'SOS Alert from ${survivor.timestamp.toString()}');
                              _getRoute(survivor.location);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 45,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                  child: const Text(
                                    'SOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          _buildSearchBar(),
          if (_weather != null) _buildWeatherInfo(),
          _buildRouteInfo(),
          _buildCampInfo(),
          if (_loading || _isCalculatingRoute || _isSearching)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _refreshMap,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
