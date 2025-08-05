import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'general';
  bool _isSignIn = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkRememberedUser();
  }

  Future<void> _checkRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final phone = prefs.getString('user_phone');
    if (email != null && name != null && phone != null) {
      UserSession.email = email;
      UserSession.name = name;
      UserSession.phone = phone;
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResQLinkHomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text(_isSignIn ? 'Sign In' : 'Sign Up', style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF003366)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 16),
                  if (!_isSignIn) Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: const Text('+91', style: TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.phone, color: Color(0xFF003366)),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => _isSignIn ? null : (value == null || value.isEmpty ? 'Enter your phone number' : null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isSignIn) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF003366)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF003366)),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                  ),
                  const SizedBox(height: 16),
                  if (!_isSignIn)
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.verified_user, color: Color(0xFF003366)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'representative', child: Text('Representative')),
                        DropdownMenuItem(value: 'general', child: Text('General')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _role = value);
                      },
                    ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_isSignIn) {
                            // Sign In logic
                            try {
                              final supabase = Supabase.instance.client;
                              final response = await supabase
                                  .from('users')
                                  .select()
                                  .eq('email', _emailController.text.trim())
                                  .eq('password', _passwordController.text)
                                  .maybeSingle();
                              if (response != null) {
                                UserSession.email = response['email'];
                                UserSession.name = response['name'];
                                UserSession.phone = response['phone'];
                                if (_rememberMe) {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('user_email', response['email']);
                                  await prefs.setString('user_name', response['name']);
                                  await prefs.setString('user_phone', response['phone']);
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Sign in successful!')),
                                  );
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const ResQLinkHomePage()),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid email or password.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Sign in failed: \\${e.toString()}')),
                              );
                            }
                          } else {
                            // Sign Up logic
                            try {
                              final supabase = Supabase.instance.client;
                              await supabase.from('users').insert({
                                'email': _emailController.text.trim(),
                                'phone': '+91${_phoneController.text.trim()}',
                                'name': _nameController.text.trim(),
                                'password': _passwordController.text, // In production, hash the password!
                                'role': _role,
                              });
                              UserSession.email = _emailController.text.trim();
                              UserSession.name = _nameController.text.trim();
                              UserSession.phone = '+91${_phoneController.text.trim()}';
                              if (_rememberMe) {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('user_email', _emailController.text.trim());
                                await prefs.setString('user_name', _nameController.text.trim());
                                await prefs.setString('user_phone', '+91${_phoneController.text.trim()}');
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sign up successful!')),
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const ResQLinkHomePage()),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Sign up failed: \\${e.toString()}')),
                              );
                            }
                          }
                        }
                      },
                      child: Text(_isSignIn ? 'Sign In' : 'Sign Up', style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isSignIn)
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                        const Text('Remember me / Stay signed in'),
                      ],
                    ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSignIn = !_isSignIn;
                      });
                    },
                    child: Text(
                      _isSignIn ? "Don't have an account? Sign Up" : 'Already have an account? Sign In',
                      style: const TextStyle(
                        color: Color(0xFF003366),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 