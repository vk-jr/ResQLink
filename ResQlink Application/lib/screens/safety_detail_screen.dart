import 'package:flutter/material.dart';

class SafetyDetailScreen extends StatelessWidget {
  const SafetyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Precautions'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earthquake Safety Precautions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Knowing what to do when an earthquake strikes is crucial for your safety. This guide outlines immediate actions to take during an earthquake to protect yourself and those around you.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'During an Earthquake',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SafetyPoint(
              title: 'Drop, Cover, and Hold On:',
              description:
                  "Immediately drop to the ground, take cover under a sturdy desk or table, and hold on to it until the shaking stops. If there's no table or desk nearby, drop to the floor next to an interior wall and cover your head and neck with your arms.",
            ),
            SafetyPoint(
              title: 'Stay Indoors:',
              description:
                  "If you are indoors when the shaking starts, stay there. Do not run outside. Most injuries during earthquakes occur when people try to move or exit buildings.",
            ),
            SafetyPoint(
              title: 'Stay Away from Hazards:',
              description:
                  "Move away from windows, mirrors, outside doors, and anything that could fall, such as light fixtures, heavy furniture, or appliances.",
            ),
            SafetyPoint(
              title: 'If in Bed:',
              description:
                  "If you are in bed, stay there. Protect your head with a pillow. It's safer to stay in bed than to try to move to another location during intense shaking.",
            ),
            SafetyPoint(
              title: 'If Outdoors:',
              description:
                  "If you are outdoors, move to an open area away from buildings, streetlights, utility wires, and anything that could fall. Drop to the ground and cover your head and neck.",
            ),
            SafetyPoint(
              title: 'If in a Vehicle:',
              description:
                  "If you are in a moving vehicle, pull over to a clear location away from buildings, trees, overpasses, and utility poles. Stay inside with your seatbelt fastened until the shaking stops. When the shaking stops, proceed cautiously and avoid damaged roads.",
            ),
            SafetyPoint(
              title: 'Do Not Use Elevators:',
              description:
                  "Never use elevators during an earthquake. If you are in an elevator, push the button for every floor and exit as soon as the doors open.",
            ),
            SizedBox(height: 20),
            Text(
              'After the Shaking Stops',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SafetyPoint(
              description:
                  'Check yourself and others for injuries. Provide first aid if necessary.',
            ),
            SafetyPoint(
              description:
                  'Be prepared for aftershocks. Drop, Cover, and Hold On again if shaking resumes.',
            ),
            SafetyPoint(
              description:
                  'If you are in a damaged building, carefully exit when it is safe to do so and move to an open space.',
            ),
            SafetyPoint(
              description:
                  'Listen to local news and emergency services for official information and instructions.',
            ),
          ],
        ),
      ),
    );
  }
}

class SafetyPoint extends StatelessWidget {
  final String? title;
  final String description;

  const SafetyPoint({
    super.key,
    this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  if (title != null)
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
