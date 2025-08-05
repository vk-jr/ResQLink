import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'widgets/action_icon_button.dart';
import 'widgets/alert_card.dart';
import 'widgets/alert_notification.dart';
import 'community_screen.dart';
import 'map_page.dart';
import 'guide_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as realtime;
import 'screens/profile_screen.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'mm32_chat_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/medical_chat_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/weather_widget.dart';
import 'user_session.dart';
import 'dart:async';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Loading .env file...');
  await dotenv.load(fileName: '.env');
  print('dotenv loaded: ${dotenv.env['OPENROUTE_API_KEY'] != null}');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  print('Supabase initialized');
  runApp(const ResQLinkApp());
}

class ResQLinkApp extends StatefulWidget {
  const ResQLinkApp({super.key});

  @override
  State<ResQLinkApp> createState() => _ResQLinkAppState();
}

class _ResQLinkAppState extends State<ResQLinkApp> {
  bool _showAlert = false;
  Timer? _alertTimer;
  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _startAlertListener();
  }

  void _startAlertListener() {
    _client.channel('public:users').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'users',
      callback: (payload) {
        if (payload.newRecord['alert'] == 'yes') {
          setState(() => _showAlert = true);
          _alertTimer?.cancel();
          _alertTimer = Timer(const Duration(seconds: 10), () {
            if (mounted) {
              setState(() => _showAlert = false);
            }
          });
        }
      },
    ).subscribe();
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ Link',
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => child!,
            ),
            if (_showAlert)
              OverlayEntry(
                builder: (context) => const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AlertNotification(
                    message: "⚠️ Emergency Alert: Danger detected in your area!",
                  ),
                ),
              ),
          ],
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF003366),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ResQLinkHomePage extends StatefulWidget {
  const ResQLinkHomePage({super.key});

  @override
  State<ResQLinkHomePage> createState() => _ResQLinkHomePageState();
}

class _ResQLinkHomePageState extends State<ResQLinkHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavKey = GlobalKey();

  String? _notificationMsg;
  bool _notificationLoading = true;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Stream<List<Map<String, dynamic>>>? _alertStream;
  Timer? _locationResetTimer;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchNotification();
    _initializeNotifications();
    _listenToEmergencyAlert();
  }

  @override
  void dispose() {
    _locationResetTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                  'This app needs location access to show the map and your position.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _fetchNotification() async {
    try {
      final supabase = Supabase.instance.client;
      // Fetch the latest notification (assuming table 'notification' with 'msg' and 'created_at')
      final response = await supabase
          .from('notification')
          .select('msg')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      setState(() {
        _notificationMsg = response != null ? response['msg'] as String? : null;
        _notificationLoading = false;
      });
    } catch (e) {
      setState(() {
        _notificationMsg = null;
        _notificationLoading = false;
      });
    }
  }

  void _listenToEmergencyAlert() {
    final supabase = Supabase.instance.client;
    _alertStream = supabase.from('alerts').stream(primaryKey: ['id']);
    _alertStream!.listen((data) {
      if (data.isNotEmpty && data.last['alert'] == 'yes') {
        _emergencyAlert();
      }
    });
    // Listen to sensor_data table for alert column
    final sensorStream =
        supabase.from('sensor_data').stream(primaryKey: ['id']);
    sensorStream.listen((data) {
      if (data.isNotEmpty &&
          (data.last['alert'] == true ||
              data.last['alert'] == 'true' ||
              data.last['alert'] == 1)) {
        _emergencyAlert();
      }
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _emergencyAlert() async {
    // Vibration
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500);
    }
    // Flashlight blinking
    try {
      for (int i = 0; i < 5; i++) {
        await TorchLight.enableTorch();
        await Future.delayed(const Duration(milliseconds: 200));
        await TorchLight.disableTorch();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {}
    // Emergency ringtone
    final player = AudioPlayer();
    try {
      await player.setAsset('assets/warning.mp3');
      await player.play();
    } catch (e) {}
    // Notification permission (Android 13+)
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {}
    // Red notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Channel for emergency check alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: Colors.red,
      colorized: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    try {
      await _notificationsPlugin.show(
        0,
        'Emergency Check',
        'All emergency functions triggered!',
        platformChannelSpecifics,
      );
    } catch (e) {}
  }

  Future<void> _onSosPressed() async {
    // Get location
    Position? position;
    String locationMsg = '';
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (serviceEnabled &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse)) {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        locationMsg = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      } else {
        locationMsg = 'Location permission denied or service disabled.';
      }
    } catch (e) {
      locationMsg = 'Failed to get location.';
    }
    // Show dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert Sent!'),
        content: Text('Your location: $locationMsg'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    // Send alert to Supabase
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('alerts').insert({
        'alert': 'yes',
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Supabase alerts table error (ignored): $e');
    }
    // Save location to user table
    if (position != null && UserSession.email != null) {
      try {
        await supabase.from('users').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }).eq('email', UserSession.email as String);
        // Set timer to reset location after 1 hour
        _locationResetTimer?.cancel();
        _locationResetTimer = Timer(const Duration(hours: 1), () async {
          try {
            await supabase.from('users').update({
              'latitude': null,
              'longitude': null,
            }).eq('email', UserSession.email as String);
            print('User location reset to null after 1 hour');
          } catch (e) {
            print('Error resetting user location: $e');
          }
        });
      } catch (e) {
        print('Error updating user location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    void openMedicalCamAI() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MedicalChatScreen(),
        ),
      );
    }

    Widget bodyWidget;
    print('Building with _selectedIndex: $_selectedIndex');
    if (_selectedIndex == 1) {
      print('Building CommunityScreen');
      bodyWidget = const CommunityScreen(key: ValueKey('community'));
    } else if (_selectedIndex == 2) {
      print('Building MapPage');
      bodyWidget = const MapPage(key: ValueKey('map'));
    } else if (_selectedIndex == 3) {
      print('Building GuidePage');
      bodyWidget = const GuidePage(key: ValueKey('guide'));
    } else if (_selectedIndex == 4) {
      print('Building ProfileScreen');
      bodyWidget = const ProfileScreen(key: ValueKey('profile'));
    } else {
      print('Building HomePage');
      bodyWidget = SafeArea(
        key: const ValueKey('home'),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _notificationLoading
                    ? const AlertCard(
                        backgroundColor: Color(0xFF003366),
                        icon: Icons.notifications_active_outlined,
                        text: "Loading notification...",
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      )
                    : AlertCard(
                        backgroundColor: const Color(0xFF003366),
                        icon: Icons.notifications_active_outlined,
                        text: _notificationMsg ?? "No notifications.",
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                const SizedBox(height: 12),
                const WeatherWidget()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: -0.2),
                const SizedBox(height: 28),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? 240 : 300, // Enlarged
                        maxHeight: isSmallScreen ? 240 : 300), // Enlarged
                    child: Material(
                      color: Colors.red,
                      shape: const CircleBorder(),
                      elevation: 8,
                      shadowColor: Colors.redAccent.withOpacity(0.6),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _onSosPressed,
                        child: Padding(
                          padding: const EdgeInsets.all(36), // Enlarged padding
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 96, // Enlarged icon
                                semanticLabel: 'Warning triangle icon',
                              ),
                              const SizedBox(height: 18), // More space
                              Text(
                                'SOS',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium! // Larger text
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 48), // Increased space above SOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionIconButton(
                      backgroundColor: Colors.deepPurple,
                      icon: Icons.message,
                      label: 'MM32',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                      iconSize: 40,
                      avatarRadius: 36,
                    ),
                    ActionIconButton(
                      backgroundColor: Colors.grey,
                      icon: Icons.camera_alt,
                      label: 'MedicalCam AI',
                      onTap: openMedicalCamAI,
                      iconSize: 40,
                      avatarRadius: 36,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideY(begin: 0.5),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 50,
        ),
        leading: null, // Removed the menu icon
      ),
      body: bodyWidget,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavKey,
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.people, size: 30, color: Colors.white),
          Icon(Icons.map, size: 30, color: Colors.white),
          Icon(Icons.menu_book, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: const Color(0xFF003366),
        buttonBackgroundColor: const Color(0xFF003366),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
