import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Profile is index 4

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.bgColor;
    final Color cardColor = Colors.white.withOpacity(0.7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner Image
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/profileBg.jpeg'), // Using an existing asset as banner
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Top Icons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            Icon(PhosphorIcons.bell(), color: Colors.white, size: 28),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: brandColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Text("4", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Icon(PhosphorIcons.gear(), color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
                // Profile Picture (overlapping)
                Positioned(
                  bottom: -50,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/user1.jpeg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            // User Info & Share Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Kaizel",
                            style: GoogleFonts.mysteryQuest(
                              textStyle: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(PhosphorIcons.pencilLine(), size: 20, color: Colors.black54),
                        ],
                      ),
                      const Text(
                        "Water is good, Lloyd is water",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(PhosphorIcons.calendarBlank(), size: 18, color: Colors.black38),
                          const SizedBox(width: 5),
                          const Text("Member since 2025", style: TextStyle(color: Colors.black38)),
                          const SizedBox(width: 20),
                          Icon(PhosphorIcons.mapPin(), size: 18, color: Colors.black38),
                          const SizedBox(width: 5),
                          const Text("Switzerland", style: TextStyle(color: Colors.black38)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(PhosphorIcons.shareNetwork(), color: brandColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("143", "in Library"),
                    _buildDivider(),
                    _buildStatItem("5h", "reading"),
                    _buildDivider(),
                    _buildStatItem("7", "read"),
                    _buildDivider(),
                    _buildStatItem("3", "comments"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Menu Groups
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSingleTile("Download Queue", PhosphorIcons.cloudArrowDown(), cardColor),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        _buildGroupTile("Settings", PhosphorIcons.gear(), true, () {
                          Navigator.pushNamed(context, '/appearance');
                        }),
                        _buildGroupTile("Inbox", PhosphorIcons.envelopeSimple(), false, () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile("Night Mode", PhosphorIcons.sun(), themeProvider.themeMode == ThemeMode.dark, (val) {
                          themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                        }),
                        _buildGroupTile("Help & Support", PhosphorIcons.question(), true, () {}),
                        _buildGroupTile("Donate", PhosphorIcons.tipJar(), false, () {}),
                        _buildGroupTile("About", PhosphorIcons.info(), false, () {})
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {},
              child: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/library');
          if (index == 2) Navigator.pushReplacementNamed(context, '/history');
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontFamily: GoogleFonts.denkOne, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.black45, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.black12);
  }

  Widget _buildSingleTile(String title, PhosphorIconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGroupTile(String title, PhosphorIconData icon, bool showDivider, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(icon, size: 28),
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        if (showDivider) const Divider(height: 1, indent: 60, endIndent: 20, color: Colors.black12),
      ],
    );
  }

  Widget _buildSwitchTile(String title, PhosphorIconData icon, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(icon, size: 28),
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          trailing: Switch(
            value: value,
            activeColor: Provider.of<ThemeProvider>(context, listen: false).brandColor,
            onChanged: onChanged,
          ),
        ),
        const Divider(height: 1, indent: 60, endIndent: 20, color: Colors.black12),
      ],
    );
  }
}
