import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Guide'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '"We cannot stop natural disasters, but we can arm ourselves with knowledge."',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _GuideTile(
                    icon: Icons.medical_services,
                    color: Colors.red,
                    title: 'First Aid',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FirstAidScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _GuideTile(
                    icon: Icons.list_alt,
                    color: Colors.blue,
                    title: 'Protocols',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProtocolScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _GuideTile(
                    icon: Icons.public,
                    color: Colors.green,
                    title: 'Disaster Safety',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DisasterSafetyScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _GuideTile(
                    icon: Icons.emergency,
                    color: Colors.red,
                    title: '🆘 Emergency Consultancy',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('🚨 Emergency Mental Health Support',
                                style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'If you are facing any mental health issues or need psychological support during these difficult times, our mental health professionals are here to help.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[700],
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      elevation: 8,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Using URL launcher to open phone dialer
                                      launchUrl(Uri.parse('tel:+1800123456789'));
                                    },
                                    child: const Text(
                                      '📞 1-800-123-456-789',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _GuideTile({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }
}

// Placeholder screens for navigation
class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TextStyle? normal = Theme.of(context).textTheme.bodyLarge;
    final TextStyle bold = normal?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(title: const Text('First Aid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: normal,
              children: [
                TextSpan(text: '1. Why First Aid Is Crucial During Disasters\n', style: bold),
                const TextSpan(text: 'Disasters like floods, earthquakes, or storms often cause chaos. Roads may be blocked, medical help may take time to arrive, and people can be injured or very frightened. First aid—the simple things you do at the scene—can make a life-saving difference. It helps stop heavy bleeding, keeps airways open, and reassures people while waiting for rescuers.\n\nWhen you’re prepared and calm, you can help someone breathe easier, prevent shock, and reduce pain. Every minute counts—it can mean the difference between life and death, or a quick recovery instead of long-term injury.\n\n'),
                TextSpan(text: '2. Basic First Aid Kit: What You Really Need\n', style: bold),
                const TextSpan(text: 'You don’t need fancy gear to start saving lives. Your kit should include:\n\nClean cloths or gauze pads for dressing wounds\nStrong tape and bandages\nSmall scissors and tweezers\nDisposable gloves (to protect both sides)\nA few pain relievers (like paracetamol)\nA flashlight and batteries\n\nStore everything in a sturdy box. Check it every few months, replace expired items, and keep it in an easy-to-find spot with your family, so everyone knows where it is in an emergency.\n\n'),
                TextSpan(text: '3. What to Do First: Stay Safe, Check Quickly\n', style: bold),
                const TextSpan(text: 'Before helping, make sure it’s safe. Look around: is there jagged metal, fallen power lines, flooding? If yes, call for help first—it’s not worth risking more lives.\n\nIf it’s safe: check the person’s breathing and response. Can they talk or nod? If they\'re not breathing, call for emergency help, and start CPR: chest compressions plus rescue breaths (30:2 ratio). If you’re alone and don’t know CPR well, do hands-only chest compressions until help arrives. If they’re breathing but unconscious, gently place them on their side—this keeps their airway clear.\n\n'),
                TextSpan(text: '4. Stopping Bleeding and Protecting Wounds\n', style: bold),
                const TextSpan(text: 'Heavy bleeding must be stopped fast. Make sure you wear gloves if you have them. Press firmly and continuously with a clean cloth or gauze. If the blood soaks through, put another cloth on top—don’t remove the soaked one. Keep pressing until the bleeding slows.\n\nAfter bleeding is under control, cover the wound with a clean dressing or bandage. This helps prevent infection. If the injury is deep, the person feels dizzy, or blood spurts out, keep pressure and get professional care immediately.\n\n'),
                TextSpan(text: '5. Helping with Fractures and Sprains\n', style: bold),
                const TextSpan(text: 'If a limb looks bent unusually or the person can’t move it without severe pain, it might be broken. Don’t try to reset it. You can make a splint using sticks, rolled-up newspapers, or a stiff board. Tie it loosely above and below the injured area. Your goal is to keep the limb from moving too much and causing more damage.\n\nFor sprains—where joints swell and hurt—apply the RICE method:\nRest the injured part,\nIce to reduce swelling (wrap ice in cloth, don’t put it straight on skin),\nCompression with a bandage (not too tight),\nElevation—lift it higher than the heart if you can.\n\nThis helps reduce pain and swelling until professional care is possible.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProtocolScreen extends StatelessWidget {
  const ProtocolScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TextStyle? normal = Theme.of(context).textTheme.bodyLarge;
    final TextStyle bold = normal?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(title: const Text('Protocols')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Earthquake
          ExpansionTile(
            title: Text('Earthquake', style: bold),
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Earthquake Safety Precautions'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'Knowing what to do when an earthquake strikes is crucial for your safety. This guide outlines immediate actions to take during an earthquake to protect yourself and those around you.\n\n'
                              'During an Earthquake\n'
                              '• Drop, Cover, and Hold On: Immediately drop to the ground, take cover under a sturdy desk or table, and hold on to it until the shaking stops. If there\'s no table or desk nearby, drop to the floor next to an interior wall and cover your head and neck with your arms.\n'
                              '• Stay Indoors: If you are indoors when the shaking starts, stay there. Do not run outside. Most injuries during earthquakes occur when people try to move or exit buildings.\n'
                              '• Stay Away from Hazards: Move away from windows, mirrors, outside doors, and anything that could fall, such as light fixtures, heavy furniture, or appliances.\n'
                              '• If in Bed: If you are in bed, stay there. Protect your head with a pillow. It\'s safer to stay in bed than to try to move to another location during intense shaking.\n'
                              '• If Outdoors: If you are outdoors, move to an open area away from buildings, streetlights, utility wires, and anything that could fall. Drop to the ground and cover your head and neck.\n'
                              '• If in a Vehicle: If you are in a moving vehicle, pull over to a clear location away from buildings, trees, overpasses, and utility poles. Stay inside with your seatbelt fastened until the shaking stops. When the shaking stops, proceed cautiously and avoid damaged roads.\n'
                              '• Do Not Use Elevators: Never use elevators during an earthquake. If you are in an elevator, push the button for every floor and exit as soon as the doors open.\n\n'
                              'After the Shaking Stops\n'
                              '• Check yourself and others for injuries. Provide first aid if necessary.\n'
                              '• Be prepared for aftershocks. Drop, Cover, and Hold On again if shaking resumes.\n'
                              '• If you are in a damaged building, carefully exit when it is safe to do so and move to an open space.\n'
                              '• Listen to local news and emergency services for official information and instructions.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Safety Precautions'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Earthquake: Do's and Don'ts"),
                          content: const SingleChildScrollView(
                            child: Text(
                              'What to Do Before an Earthquake\n'
                              '• Repair deep plaster cracks in ceilings and foundations. Get expert advice if there are signs of structural defects.\n'
                              '• Anchor overhead lighting fixtures to the ceiling.\n'
                              '• Follow BIS codes relevant to your area for building standards\n'
                              '• Fasten shelves securely to walls.\n'
                              '• Place large or heavy objects on lower shelves.\n'
                              '• Store breakable items such as bottled foods, glass, and china in low, closed cabinets with latches.\n'
                              '• Hang heavy items such as pictures and mirrors away from beds, settees, and anywhere that people sit.\n'
                              '• Brace overhead light and fan fixtures.\n'
                              '• Repair defective electrical wiring and leaky gas connections. These are potential fire risks.\n'
                              '• Secure water heaters, LPG cylinders etc., by strapping them to the walls or bolting to the floor.\n'
                              '• Store weed killers, pesticides, and flammable products securely in closed cabinets with latches and on bottom shelves.\n'
                              '• Identify safe places indoors and outdoors.\n'
                              '  - Under strong dining table, bed\n  - Against an inside wall\n  - Away from where glass could shatter around windows, mirrors, pictures, or where heavy bookcases or other heavy furniture could fall over\n  - In the open, away from buildings, trees, telephone and electrical lines, flyovers and bridges\n'
                              '• Know emergency telephone numbers (such as those of doctors, hospitals, the police, etc)\n'
                              '• Educate yourself and family members\n• PSHA Table at Grid Points\n'
                              'Have a disaster emergency kit ready\n'
                              '• Battery operated torch with extra batteries\n• Battery operated radio\n• First aid kit and manual\n• Emergency food (dry items) and water (packed and sealed)\n• Candles and matches in a waterproof container\n• Knife\n• Chlorine tablets or powdered water purifiers\n• Can opener.\n• Essential medicines\n• Cash and credit cards\n• Thick ropes and cords\n• Sturdy shoes\n'
                              'Develop an emergency communication plan\n'
                              '• In case family members are separated from one another during an earthquake (a real possibility during the day when adults are at work and children are at school), develop a plan for reuniting after the disaster.\n'
                              '• Ask an out-of-state relative or friend to serve as the "family contact" after the disaster; it is often easier to call long distance. Make sure everyone in the family knows the name, address, and phone number of the contact person.\n'
                              'Help your community get ready\n'
                              '• Publish a special section in your local newspaper with emergency information on earthquakes. Localize the information by printing the phone numbers of local emergency services offices and hospitals.\n'
                              '• Conduct week-long series on locating hazards in the home.\n'
                              '• Work with local emergency services and officials to prepare special reports for people with mobility impairment on what to do during an earthquake.\n'
                              '• Provide tips on conducting earthquake drills in the home.\n'
                              '• Interview representatives of the gas, electric, and water companies about shutting off utilities.\n'
                              '• Work together in your community to apply your knowledge to building codes, retrofitting programmes, hazard hunts, and neighborhood and family emergency plans.\n\n'
                              'What to Do During an Earthquake\n'
                              '• Stay as safe as possible during an earthquake. Be aware that some earthquakes are actually foreshocks and a larger earthquake might occur. Minimize your movements to a few steps that reach a nearby safe place and stay indoors until the shaking has stopped and you are sure exiting is safe.\n'
                              'If indoors\n'
                              '• DROP to the ground; take COVER by getting under a sturdy table or other piece of furniture; and HOLD ON until the shaking stops. If there is no a table or desk near you, cover your face and head with your arms and crouch in an inside corner of the building.\n'
                              '• Protect yourself by staying under the lintel of an inner door, in the corner of a room, under a table or even under a bed.\n'
                              '• Stay away from glass, windows, outside doors and walls, and anything that could fall, (such as lighting fixtures or furniture).\n'
                              '• Stay in bed if you are there when the earthquake strikes. Hold on and protect your head with a pillow, unless you are under a heavy light fixture that could fall. In that case, move to the nearest safe place.\n'
                              '• Use a doorway for shelter only if it is in close proximity to you and if you know it is a strongly supported, load bearing doorway.\n'
                              '• Stay inside until the shaking stops and it is safe to go outside. Research has shown that most injuries occur when people inside buildings attempt to move to a different location inside the building or try to leave.\n'
                              '• Be aware that the electricity may go out or the sprinkler systems or fire alarms may turn on.\n'
                              'If outdoors\n'
                              '• Do not move from where you are. However, move away from buildings, trees, streetlights, and utility wires.\n'
                              '• If you are in open space, stay there until the shaking stops. The greatest danger exists directly outside buildings; at exits; and alongside exterior walls. Most earthquake-related casualties result from collapsing walls, flying glass, and falling objects.\n'
                              'If in a moving vehicle\n'
                              '• Stop as quickly as safety permits and stay in the vehicle. Avoid stopping near or under buildings, trees, overpasses, and utility wires.\n'
                              '• Proceed cautiously once the earthquake has stopped. Avoid roads, bridges, or ramps that might have been damaged by the earthquake.\n'
                              'If trapped under debris\n'
                              '• Do not light a match.\n'
                              '• Do not move about or kick up dust.\n'
                              '• Cover your mouth with a handkerchief or clothing.\n'
                              '• Tap on a pipe or wall so rescuers can locate you. Use a whistle if one is available. Shout only as a last resort. Shouting can cause you to inhale dangerous amounts of dust.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Do's and Don'ts"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
          // Flood
          ExpansionTile(
            title: Text('Flood', style: bold),
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Flood: Do’s & Don’ts'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'What to do before a flood\n'
                              '• Avoid building in flood prone areas unless you elevate and reinforce your home.\n'
                              '• Elevate the furnace, water heater, and electric panel if susceptible to flooding.\n'
                              '• Install "Check Valves" in sewer traps to prevent floodwater from backing up into the drains of your home.\n'
                              '• Contact community officials to find out if they are planning to construct barriers (levees, beams and floodwalls) to stop floodwater from entering the homes in your area.\n'
                              '• Seal the walls in your basement with waterproofing compounds to avoid seepage.\n\n'
                              'If a flood is likely to hit your area, you should:\n'
                              '• Listen to the radio or television for information.\n'
                              '• Be aware that flash flooding can occur. If there is any possibility of a flash flood, move immediately to higher ground. Do not wait for instructions to move.\n'
                              '• Be aware of streams, drainage channels, canyons, and other areas known to flood suddenly. Flash floods can occur in these areas with or without such typical warnings as rain clouds or heavy rain.\n\n'
                              'If you must prepare to evacuate, you should:\n'
                              '• Secure your home. If you have time, bring in outdoor furniture. Move essential items to an upper floor.\n'
                              '• Turn off utilities at the main switches or valves if instructed to do so. Disconnect electrical appliances. Do not touch electrical equipment if you are wet or standing in water.\n\n'
                              'If you have to leave your home, remember these evacuation tips:\n'
                              '• Do not walk through moving water. Six inches of moving water can make you fall. If you have to walk in water, walk where the water is not moving. Use a stick to check the firmness of the ground in front of you.\n'
                              '• Do not drive into flooded areas. If floodwaters rise around your car, abandon the car and move to higher ground if you can do so safely. You and the vehicle can be quickly swept away.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Do’s & Don’ts'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
          // Urban Flood
          ExpansionTile(
            title: Text('Urban Flood', style: bold),
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Urban Flood: Do’s & Don’ts'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'Before floods\n'
                              '• Do not litter waste, plastic bags, plastic bottles in drains\n'
                              '• Try to be at home if high tide and heavy rains occur simultaneously\n'
                              '• Listen to weather forecast at All India Radio, Doordarshan. Also, messages by Municipal bodies from time to time and act accordingly.\n'
                              '• Evacuate low lying areas and shift to safer places.\n'
                              '• Make sure that each person has lantern, torch, some edibles, drinking water, dry clothes and necessary documents while evacuating or shifting.\n'
                              '• Make sure that each family member has identity card.\n'
                              '• Put all valuables at a higher place in the house.\n\n'
                              'In the Flood Situation\n'
                              '• Obey orders by government and shift to a safer place.\n'
                              '• Be at safe place and they try to collect correct information.\n'
                              '• Switch of electrical supply and don’t touch open wires.\n'
                              '• Don’t get carried away by rumors and don not spread rumors.\n\n'
                              'After Floods\n'
                              '• Drink chlorinated or boiled water.\n'
                              '• Take clean and safe food\n'
                              '• Sprinkle insecticides in the water ponds/ stagnant water.\n'
                              '• Please cooperate with disaster survey team by giving correct information.\n\n'
                              'DO’s\n'
                              '• Switch off electrical and gas appliances, and turn off services off at the mains.\n'
                              '• Carry your emergency kit and let your friends and family know where you are going.\n'
                              '• Avoid contact with flood water it may be contaminated with sewage,oil,chemicals or other substances.\n'
                              '• If you have to walk in standing water, use a pole or stick to ensure that you do not step into deep water, open manholes or ditches.\n'
                              '• Stay away from power lines electrical current can travel through water, Report power lines that are down to the power company.\n'
                              '• Look before you step-after a flood, the ground and floors are covered with debris, which may include broken bottles, sharp objects, nails etc.Floors and stairs covered with mud and debris can be slippery.\n'
                              '• Listen to the radio or television for updates and information.\n'
                              '• If the ceiling is wet shut off electricity. Place a bucket underneath the spot and poke a small hole into the ceiling to relieve the pressure.\n'
                              '• Use buckets,clean towels and mops to remove as much of the water from the afflicted rooms as possible.\n'
                              '• Place sheets of aluminium foil between furniture wet carpet.\n\n'
                              'Don’ts\n'
                              '• Don’t walk through flowing water - currents can be deceptive, and shallow, fast moving water can knock you off your feet.\n'
                              '• Don’t swim through fast flowing water - you may get swept away or struck by an object in the water.\n'
                              '• Don’t drive through a flooded area - You may not be able to see abrupt drop - offs and only half a meter of flood water can carry a car away. Driving through flood water can also cause additional damage to nearby property.\n'
                              '• Don’t eat any food that has come into contact with flood water.\n'
                              '• Don’t reconnect your power supply until a qualified engineer has checked it. Be alert for gas leaks - do not smoke or use candles, lanterns, or open flames.\n'
                              '• Don’t scrub or brush mud and other deposits from materials, This may cause further damage.\n'
                              '• Never turn on ceiling fixtures if ceiling is wet. Stay away from ceilings those are sagging.\n'
                              '• Never use TVs, VCRS, CRT terminals or other electrical equipment while standing on wet floors, especially concrete.\n'
                              '• Don’t attempt to remove standing water using your vacuum cleaner.\n'
                              '• Don’t remove standing water in a basement too fast. If the pressure is relieved too quickly it may put undue stress on the walls.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Do’s & Don’ts'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
          // Landslide
          ExpansionTile(
            title: Text('Landslide', style: bold),
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Landslide: Do’s & Don’ts'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'Do’s\n'
                              '• Prepare tour to hilly region according to information given by weather department or news channel.\n'
                              '• Move away from landslide path or downstream valleys quickly without wasting time.\n'
                              '• Keep drains clean,\n'
                              '• Inspect drains for - litter, leaves, plastic bags, rubble etc.\n'
                              '• Keep the weep holes open.\n'
                              '• Grow more trees that can hold the soil through roots,\n'
                              '• Identify areas of rock fall and subsidence of buildings, cracks that indicate landslides and move to safer areas. Even muddy river waters indicate landslides upstream.\n'
                              '• Notice such signals and contact the nearest Tehsil or District Head Quarters.\n'
                              '• Ensure that toe of slope is not cut, remains protected, don’t uproot trees unless re-vegetation is planned.\n'
                              '• Listen for unusual sounds such as trees cracking or boulders knocking together.\n'
                              '• Stay alert, awake and active (3A’s) during the impact or probability of impact.\n'
                              '• Locate and go to shelters,\n'
                              '• Try to stay with your family and companions.\n'
                              '• Check for injured and trapped persons.\n'
                              '• Mark path of tracking so that you can’t be lost in middle of the forest.\n'
                              '• Know how to give signs or how to communicate during emergency time to flying helicopters and rescue team.\n\n'
                              'Don’ts\n'
                              '• Try to avoid construction and staying in vulnerable areas.\n'
                              '• Do not panic and loose energy by crying.\n'
                              '• Do not touch or walk over loose material and electrical wiring or pole.\n'
                              '• Do not built houses near steep slopes and near drainage path.\n'
                              '• Do not drink contaminated water directly from rivers, springs, wells but rain water if collected directly without is fine.\n'
                              '• Do not move an injured person without rendering first aid unless the casualty is in immediate danger.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Do’s & Don’ts'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
          // Cold Wave
          ExpansionTile(
            title: Text('Cold Wave', style: bold),
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cold Wave: Do’s & Don’ts'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'Dos\n'
                              '• Have adequate winter clothing. Multiple layers of clothing are also useful.\n'
                              '• Have emergency supplies ready.\n'
                              '• Stay indoor as much as possible, minimise travel to prevent exposure to cold wind.\n'
                              '• Keep dry. If wet, change clothes quickly to prevent loss of body heat.\n'
                              '• Prefer mittens over gloves; mittens provide more warmth and insulation from cold.\n'
                              '• Listen to radio, watch TV, read newspapers for weather updates.\n'
                              '• Drink hot drinks regularly.\n'
                              '• Take care of elderly people and children.\n'
                              '• Store adequate water as pipes may freeze.\n'
                              '• Watch out for symptoms of frostbite like numbness, white or pale appearance on fingers, toes, ear lobes and the tip of the nose.\n'
                              '• Put the areas affected by frostbite in warm not hot water (the temperature should be comfortable to touch for unaffected parts of the body). In the case of Hypothermia\n'
                              '• Get the person into a warm place and change his/her clothes.\n'
                              '• Warm the person’s body with skin-to-skin contact, dry layers of blankets, clothes, towels, or sheets.\n'
                              '• Give warm drinks to help increase body temperature. Do not give alcohol.\n'
                              '• Seek medical attention if the condition worsens.\n\n'
                              'Don’ts\n'
                              '• Don’t drink alcohol. It reduces your body temperature.\n'
                              '• Do not massage the frostbitten area. This can cause more damage.\n'
                              '• Do not ignore shivering. It is an important first sign that the body is losing heat and a signal to quickly return indoors.\n',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Do’s & Don’ts'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
          // Heat Wave
          ExpansionTile(
            title: Text('Heat Wave', style: bold),
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Heat Wave: Do’s & Don’ts'),
                          content: const SingleChildScrollView(
                            child: Text(
                              '• Avoid going out in the sun, especially between 12.00 noon and 3.00 p.m.\n'
                              '• Drink sufficient water and as often as possible, even if not thirsty\n'
                              '• Wear lightweight, light-coloured, loose, and porous cotton clothes. Use protective goggles, umbrella/hat, shoes or chappals while going out in sun.\n'
                              '• Avoid strenuous activities when the outside temperature is high. Avoid working outside between 12 noon and 3 p.m.\n'
                              '• While travelling, carry water with you.\n'
                              '• Avoid alcohol, tea, coffee and carbonated soft drinks, which dehydrates the body.\n'
                              '• Avoid high-protein food and do not eat stale food.\n'
                              '• If you work outside, use a hat or an umbrella and also use a damp cloth on your head, neck, face and limbs\n'
                              '• Do not leave children or pets in parked vehicles\n'
                              '• If you feel faint or ill, see a doctor immediately.\n'
                              '• Use ORS, homemade drinks like lassi, torani (rice water), lemon water, buttermilk, etc. which helps to rehydrate the body.\n'
                              '• Keep animals in shade and give them plenty of water to drink.\n'
                              '• Keep your home cool, use curtains, shutters or sunshade and open windows at night.\n'
                              '• Use fans, damp clothing and take bath in cold water frequently.\n\n'
                              'TIPS FOR TREATMENT OF A PERSON AFFECTED BY A SUNSTROKE:\n'
                              '• Lay the person in a cool place, under a shade. Wipe her/him with a wet cloth/wash the body frequently. Pour normal temperature water on the head. The main thing is to bring down the body temperature.\n'
                              '• Give the person ORS to drink or lemon sarbat/torani or whatever is useful to rehydrate the body.\n'
                              '• Take the person immediately to the nearest health centre. The patient needs immediate hospitalisation, as heat strokes could be fatal.\n\n'
                              'Acclimatisation\n'
                              'People at risk are those who have come from a cooler climate to a hot climate. You may have such a person(s) visiting your family during the heat wave season. They should not move about in open field for a period of one week till the body is acclimatized to heat and should drink plenty of water. Acclimatization is achieved by gradual exposure to the hot environment during heat wave.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Do’s & Don’ts'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class DisasterSafetyScreen extends StatelessWidget {
  const DisasterSafetyScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TextStyle? normal = Theme.of(context).textTheme.bodyLarge;
    final TextStyle bold = normal?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(title: const Text('Disaster Safety')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: normal,
              children: [
                TextSpan(text: '🛡 Disaster Safety: A Comprehensive Guide to Preparedness and Protection\n', style: bold),
                const TextSpan(text: 'In an era of climate change, urban expansion, and unforeseen global crises, disaster safety is not just a responsibility—it\'s a necessity. Whether natural or man-made, disasters can strike suddenly, leaving little time to react. Being equipped with the right knowledge and tools can make all the difference.\n\nThis guide provides a detailed, topic-wise breakdown of disaster safety strategies to help individuals, families, communities, and institutions stay resilient in the face of calamity.\n\n'),
                TextSpan(text: '1. Understanding Disasters\n', style: bold),
                const TextSpan(text: '🔍 Types of Disasters\nNatural Disasters:\n\nEarthquakes\nFloods\nCyclones and Hurricanes\nLandslides\nDroughts\nTsunamis\nWildfires\nVolcanic Eruptions\n\nMan-Made Disasters:\n\nIndustrial Accidents\nChemical Spills\nNuclear Accidents\nTransportation Accidents\nTerrorist Attacks\nCyber Attacks\n\n'),
                TextSpan(text: '🌍 Causes and Effects\n', style: bold),
                const TextSpan(text: 'Natural disasters often result from geological, meteorological, or environmental phenomena.\n\nMan-made disasters arise due to human negligence, conflict, or technological failures.\n\nEffects include loss of life, economic damage, displacement, trauma, and long-term societal disruption.\n\n'),
                TextSpan(text: '2. Disaster Preparedness\n', style: bold),
                const TextSpan(text: 'Preparedness is the first step toward reducing vulnerability. A well-thought-out plan can save lives.\n\n'),
                TextSpan(text: '🏠 Home and Family Preparedness\n', style: bold),
                const TextSpan(text: 'Create a Family Emergency Plan: Define meeting points, emergency contacts, and evacuation routes.\n\nAssemble an Emergency Kit: Include water, non-perishable food, flashlight, batteries, first-aid kit, important documents, radio, multi-tool, medications, and cash.\n\nPractice Drills Regularly: Earthquake and fire drills can build muscle memory for real scenarios.\n\nSecure Your Home: Anchor heavy furniture, retrofit structures, and install fire and smoke alarms.\n\n'),
                TextSpan(text: '🏫 School and Workplace Plans\n', style: bold),
                const TextSpan(text: 'Establish evacuation maps and designate safety coordinators.\n\nConduct regular drills and first-aid training sessions.\n\nUse public address systems for real-time communication.\n\n'),
                TextSpan(text: '3. Technology and Disaster Safety\n', style: bold),
                const TextSpan(text: 'Modern technology offers real-time alerts, early warning systems, and communication during chaos.\n\n'),
                TextSpan(text: '📲 Mobile Apps and Alerts\n', style: bold),
                const TextSpan(text: 'Government emergency apps (e.g., NDMA app in India, FEMA in the US)\n\nGoogle SOS alerts\n\nSocial media crisis response tools\n\n'),
                TextSpan(text: '🌐 Smart Systems\n', style: bold),
                const TextSpan(text: 'IoT-based disaster monitoring (flood sensors, fire detection)\n\nSatellite imagery and drones for search and rescue\n\nAI-powered hazard prediction and damage assessment\n\n'),
                TextSpan(text: '💾 Data Backups\n', style: bold),
                const TextSpan(text: 'Digitize and back up critical documents to cloud storage.\n\nMaintain encrypted backups of health, ID, and legal records.\n\n'),
                TextSpan(text: '4. During a Disaster: Immediate Response\n', style: bold),
                TextSpan(text: '🧠 Stay Calm & Assess\n', style: bold),
                const TextSpan(text: 'Check surroundings for hazards.\n\nAdminister first-aid if needed.\n\nTurn off gas, electricity, and water if safe to do so.\n\n'),
                TextSpan(text: '🧍‍♂ Shelter or Evacuate?\n', style: bold),
                TextSpan(text: 'Earthquake', style: bold),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Earthquake Safety Precautions'),
                                content: const SingleChildScrollView(
                                  child: Text(
                                    'Knowing what to do when an earthquake strikes is crucial for your safety. This guide outlines immediate actions to take during an earthquake to protect yourself and those around you.\n\n'
                                    'During an Earthquake\n'
                                    '• Drop, Cover, and Hold On: Immediately drop to the ground, take cover under a sturdy desk or table, and hold on to it until the shaking stops. If there\'s no table or desk nearby, drop to the floor next to an interior wall and cover your head and neck with your arms.\n'
                                    '• Stay Indoors: If you are indoors when the shaking starts, stay there. Do not run outside. Most injuries during earthquakes occur when people try to move or exit buildings.\n'
                                    '• Stay Away from Hazards: Move away from windows, mirrors, outside doors, and anything that could fall, such as light fixtures, heavy furniture, or appliances.\n'
                                    '• If in Bed: If you are in bed, stay there. Protect your head with a pillow. It\'s safer to stay in bed than to try to move to another location during intense shaking.\n'
                                    '• If Outdoors: If you are outdoors, move to an open area away from buildings, streetlights, utility wires, and anything that could fall. Drop to the ground and cover your head and neck.\n'
                                    '• If in a Vehicle: If you are in a moving vehicle, pull over to a clear location away from buildings, trees, overpasses, and utility poles. Stay inside with your seatbelt fastened until the shaking stops. When the shaking stops, proceed cautiously and avoid damaged roads.\n'
                                    '• Do Not Use Elevators: Never use elevators during an earthquake. If you are in an elevator, push the button for every floor and exit as soon as the doors open.\n\n'
                                    'After the Shaking Stops\n'
                                    '• Check yourself and others for injuries. Provide first aid if necessary.\n'
                                    '• Be prepared for aftershocks. Drop, Cover, and Hold On again if shaking resumes.\n'
                                    '• If you are in a damaged building, carefully exit when it is safe to do so and move to an open space.\n'
                                    '• Listen to local news and emergency services for official information and instructions.',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Safety Precautions'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Earthquake: Do's and Don'ts"),
                                content: const Text('Content coming soon.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text("Do's and Don'ts"),
                        ),
                      ],
                    ),
                  ),
                ),
                const TextSpan(text: ': Drop, cover, and hold on. Stay indoors until shaking stops.\n\n'),
                const TextSpan(text: 'Flood: Move to higher ground. Avoid walking or driving through floodwaters.\n\n'),
                const TextSpan(text: 'Fire: Evacuate immediately. Cover nose with cloth; stay low to avoid smoke.\n\n'),
                const TextSpan(text: 'Cyclone/Hurricane: Stay indoors, away from windows. Evacuate only if instructed.\n\n'),
                TextSpan(text: '🆘 Communication\n', style: bold),
                const TextSpan(text: 'Use SMS or messaging apps to conserve bandwidth.\n\nTune into emergency broadcasts on radio.\n\nNotify local authorities or emergency contacts of your status.\n\n'),
                TextSpan(text: '5. After a Disaster: Recovery and Rehabilitation\n', style: bold),
                const TextSpan(text: 'Recovery is a long-term effort, but a structured approach accelerates healing and rebuilding.\n\n'),
                TextSpan(text: '🛠 Physical Recovery\n', style: bold),
                const TextSpan(text: 'Check for structural damage before re-entering buildings.\n\nUse protective gear while cleaning debris.\n\nAvoid drinking tap water until authorities declare it safe.\n\n'),
                TextSpan(text: '💰 Financial Recovery\n', style: bold),
                const TextSpan(text: 'Contact insurance companies to report damages.\n\nApply for government aid or relief schemes.\n\nKeep receipts and documentation for claims.\n\n'),
                TextSpan(text: '💬 Mental Health Support\n', style: bold),
                const TextSpan(text: 'Post-traumatic stress is common after disasters.\n\nProvide counseling, community healing sessions, and peer support.\n\nEncourage open discussions, especially among children and the elderly.\n\n'),
                TextSpan(text: '6. Community Involvement and Volunteerism\n', style: bold),
                TextSpan(text: '🤝 Community Preparedness\n', style: bold),
                const TextSpan(text: 'Form local disaster response teams (CERTs).\n\nTrain volunteers in first-aid, firefighting, and evacuation protocols.\n\nEngage schools, colleges, and businesses in safety drills.\n\n'),
                TextSpan(text: '🧑‍🔧 Roles of Local Authorities\n', style: bold),
                const TextSpan(text: 'Develop city-wide early warning systems.\n\nConduct risk assessments and vulnerability mapping.\n\nInvest in resilient infrastructure (e.g., elevated roads, storm drains, green spaces).\n\n'),
                TextSpan(text: '7. Building a Culture of Resilience\n', style: bold),
                const TextSpan(text: 'Disaster safety isn’t just about one-time readiness—it’s about fostering a resilient mindset.\n\n'),
                TextSpan(text: '📚 Education and Awareness\n', style: bold),
                const TextSpan(text: 'Integrate disaster management into school curricula.\n\nHost awareness camps, competitions, and exhibitions.\n\nCelebrate National Disaster Reduction Day (October 13 globally).\n\n'),
                TextSpan(text: '🏗 Sustainable Development\n', style: bold),
                const TextSpan(text: 'Avoid construction in hazard-prone zones.\n\nPromote eco-friendly architecture and climate-adaptive designs.\n\nEncourage local innovations (like bamboo reinforcements, rainwater harvesting).\n\n'),
                TextSpan(text: '8. Global and National Disaster Management Frameworks\n', style: bold),
                TextSpan(text: '🌐 International Initiatives\n', style: bold),
                const TextSpan(text: 'Sendai Framework for Disaster Risk Reduction (2015–2030)\n\nUNISDR, Red Cross, World Bank Disaster Risk Initiatives\n\n'),
                TextSpan(text: '🇮🇳 India’s Disaster Management Structure\n', style: bold),
                const TextSpan(text: 'NDMA (National Disaster Management Authority)\n\nNDRF (National Disaster Response Force)\n\nState Disaster Management Authorities (SDMAs)\n\nDisaster Management Acts and Local Disaster Management Plans\n\n'),
                TextSpan(text: 'Conclusion: Safety is a Shared Responsibility\n', style: bold),
                const TextSpan(text: 'Disasters will continue to be part of our reality—but our vulnerability doesn’t have to be. With a collective effort grounded in awareness, preparation, and technology, we can minimize risk, protect lives, and build a future that\'s not only safe, but resilient.\n\nWhether you\'re a student, parent, community leader, or developer building a smart disaster detection system—your actions today shape your safety tomorrow.\n\nStay alert. Stay prepared. Stay strong.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 