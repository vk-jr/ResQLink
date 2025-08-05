import 'package:flutter/material.dart';
import 'region_details_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);
  final List<String> regions = const [
    'Thiruvananthapuram',
    'Ernakulam',
    'Kollam',
    'Kottayam',
    'Alappuzha',
    'Thrissur',
    'Kozhikode',
    'Kannur',
    'Pathanamthitta',
    'Idukki',
    'Malappuram',
    'Palakkad',
    'Kasaragod',
    'Wayanad',
  ];

  @override
  Widget build(BuildContext context) {
    void onNavItemTapped(int index) {
      Navigator.pop(context); // Go back to region list
      // Optionally, you can use a callback to update the main navigation
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Connect'),
        leading: Navigator.canPop(context)
            ? const BackButton()
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1656A6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Stay safe, stay alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: regions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      regions[index],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegionDetailsScreen(
                            regionName: regions[index],
                            selectedIndex: 1,
                            onNavItemTapped: onNavItemTapped,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 