import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';

export 'profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String phone = '';
  String email = '';
  String location = 'Unknown';
  String? avatarUrl;
  bool loading = true;
  final _picker = ImagePicker();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      if (_currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            location = '${place.locality}, ${place.administrativeArea}';
          });
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchUserData() async {
    final supabase = Supabase.instance.client;
    final userEmail = UserSession.email;
    if (userEmail == null) {
      setState(() {
        name = UserSession.name ?? '';
        phone = UserSession.phone ?? '';
        email = '';
        loading = false;
      });
      return;
    }
    final response = await supabase
        .from('users')
        .select()
        .eq('email', userEmail)
        .maybeSingle();
    if (response != null) {
      setState(() {
        name = response['name'] ?? UserSession.name ?? '';
        phone = response['phone'] ?? UserSession.phone ?? '';
        email = response['email'] ?? userEmail;
        avatarUrl = response['avatar_url'];
        loading = false;
      });
    } else {
      setState(() {
        name = UserSession.name ?? '';
        phone = UserSession.phone ?? '';
        email = userEmail;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_email');
              await prefs.remove('user_name');
              await prefs.remove('user_phone');
              UserSession.email = null;
              UserSession.name = null;
              UserSession.phone = null;
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: avatarUrl != null
                                ? MemoryImage(
                                    base64Decode(avatarUrl!.split(',')[1]))
                                : null,
                            child: avatarUrl == null
                                ? const Icon(Icons.person,
                                    size: 64, color: Colors.white70)
                                : null,
                          ).animate().fadeIn(duration: 600.ms).scale(),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.add_circle,
                                  color: Colors.blue[700], size: 32),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 200.ms)
                                .scale(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name.isNotEmpty ? name : 'Your Name',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideY(begin: 0.2),
                    const SizedBox(height: 32),
                    _profile3DBox(
                        'Name', name.isNotEmpty ? name : '---', Icons.person),
                    const SizedBox(height: 18),
                    _profile3DBox(
                        'Phone', phone.isNotEmpty ? phone : '---', Icons.phone),
                    const SizedBox(height: 18),
                    _profile3DBox(
                        'Gmail', email.isNotEmpty ? email : '---', Icons.email),
                    const SizedBox(height: 18),
                    _profile3DBox(
                        'Location',
                        location.isNotEmpty ? location : '---',
                        Icons.location_on),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Home',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          ElevatedButton(
                            onPressed: _showEditDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Edit',
                                style: TextStyle(color: Colors.white)),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideX(begin: 0.2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _updateProfile(
      String newName, String newPhone, String newEmail) async {
    setState(() {
      loading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userEmail = UserSession.email;

      if (userEmail != null) {
        // First check if this email already exists for a different user
        if (newEmail != userEmail) {
          final existing = await supabase
              .from('users')
              .select()
              .eq('email', newEmail)
              .maybeSingle();

          if (existing != null) {
            throw 'Email already in use';
          }
        }

        // Update the user record using the current email as identifier
        await supabase.from('users').update({
          'name': newName,
          'phone': newPhone,
        }).eq('email', userEmail);

        // If email is being changed, update it separately
        if (newEmail != userEmail) {
          await supabase.from('users').update({
            'email': newEmail,
          }).eq('email', userEmail);
        }

        UserSession.name = newName;
        UserSession.phone = newPhone;
        UserSession.email = newEmail;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', newName);
        await prefs.setString('user_phone', newPhone);
        await prefs.setString('user_email', newEmail);

        setState(() {
          name = newName;
          phone = newPhone;
          email = newEmail;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800, // Limit image size
        maxHeight: 800,
      );
      if (image == null) return;

      // Show loading indicator
      setState(() {
        loading = true;
      });

      // Print file information for debugging
      print('Original file path: ${image.path}');
      print('File name: ${image.name}');

      final supabase = Supabase.instance.client;
      final bytes = await image.readAsBytes();

      // Ensure we're using a supported image type
      final String mimeType;
      if (image.mimeType?.toLowerCase().contains('png') ?? false) {
        mimeType = 'image/png';
      } else {
        mimeType = 'image/jpeg';
      }
      print('Using MIME type: $mimeType');

      // Determine file extension from MIME type
      final fileExt = mimeType == 'image/png' ? 'png' : 'jpg';

      // Generate a clean filename
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}.$fileExt';
      print('Generated filename: $fileName');

      // Convert image to base64
      final base64Image = base64Encode(bytes);
      final imageUri = 'data:$mimeType;base64,$base64Image';

      // Update user record with the base64 image data
      await supabase.from('users').update({
        'avatar_url': imageUri,
      }).eq('email', email);

      print('Image converted to base64');

      // Update the UI
      if (mounted) {
        setState(() {
          avatarUrl = imageUri;
        });
      }
      print('Profile photo updated successfully');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _showEditDialog() {
    final TextEditingController nameController =
        TextEditingController(text: name);
    final TextEditingController phoneController =
        TextEditingController(text: phone);
    final TextEditingController emailController =
        TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Validate inputs
              final newName = nameController.text.trim();
              final newPhone = phoneController.text.trim();
              final newEmail = emailController.text.trim();

              if (newName.isEmpty || newPhone.isEmpty || newEmail.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }

              // Basic email validation
              if (!newEmail.contains('@') || !newEmail.contains('.')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid email address')),
                );
                return;
              }

              // Basic phone validation (at least 10 digits)
              if (newPhone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid phone number')),
                );
                return;
              }

              Navigator.pop(context);
              await _updateProfile(newName, newPhone, newEmail);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _profile3DBox(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
            color: const Color(0xFF003366).withOpacity(0.08), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF003366).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: const Color(0xFF003366), size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }
}
