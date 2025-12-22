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
    final bgColor = themeProvider.effectiveBgColor;
    final Color cardColor = themeProvider.pureBlackDarkMode ? Colors.white10 : Colors.white.withOpacity(0.55);
    final Color textColor = themeProvider.pureBlackDarkMode ? Colors.white : Colors.black87;

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
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('images/profileBg.jpeg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                // Top Icons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            Icon(PhosphorIcons.bell(), color: Colors.white, size: 28),
                            Positioned(
                              right: 0,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: brandColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                    "4",
                                    style: GoogleFonts.denkOne(
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Colors.white
                                        ),
                                    ),
                                ),
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
                              textStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(PhosphorIcons.pencilLine(), size: 20, color: textColor.withOpacity(0.6)),
                        ],
                      ),
                      Text(
                        "Water is good, Lloyd is water",
                        style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(PhosphorIcons.calendarDots(), size: 18, color: textColor.withOpacity(0.4)),
                          const SizedBox(width: 5),
                          Text("Member since 2025", style: TextStyle(color: textColor.withOpacity(0.4))),
                          const SizedBox(width: 20),
                          Icon(PhosphorIcons.mapPinArea(), size: 18, color: textColor.withOpacity(0.4)),
                          const SizedBox(width: 5),
                          Text("Switzerland", style: TextStyle(color: textColor.withOpacity(0.4))),
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
                    child: Icon(PhosphorIcons.shareNetwork(), color: textColor),
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
                    _buildStatItem("143", "in Library", textColor),
                    _buildDivider(textColor),
                    _buildStatItem("5h", "reading", textColor),
                    _buildDivider(textColor),
                    _buildStatItem("7", "read", textColor),
                    _buildDivider(textColor),
                    _buildStatItem("3", "comments", textColor),
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
                  _buildSingleTile("Download Queue", PhosphorIcons.cloudArrowDown(), cardColor, textColor),
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
                        }, textColor),
                        _buildGroupTile("Inbox", PhosphorIcons.mailbox(), false, () {}, textColor),
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
                        _buildSwitchTile("Dark Mode", PhosphorIcons.sun(), themeProvider.pureBlackDarkMode, (val) {
                          themeProvider.setPureBlackDarkMode(val);
                        }, textColor),
                        _buildGroupTile("Help & Support", PhosphorIcons.question(), true, () {}, textColor),
                        _buildGroupTile("Donate", PhosphorIcons.tipJar(), false, () {}, textColor),
                        _buildGroupTile("About", PhosphorIcons.info(), false, () {}, textColor)
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

  Widget _buildStatItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.denkOne(
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: textColor
              ),
            ),
        ),
        Text(label, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider(Color textColor) {
    return Container(height: 40, width: 1, color: textColor.withOpacity(0.1));
  }

  Widget _buildSingleTile(String title, PhosphorIconData icon, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: textColor),
          const SizedBox(width: 15),
          Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGroupTile(String title, PhosphorIconData icon, bool showDivider, VoidCallback onTap, Color textColor) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(icon, size: 28, color: textColor),
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor)),
        ),
        if (showDivider) Divider(height: 1, indent: 60, endIndent: 20, color: textColor.withOpacity(0.1)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, PhosphorIconData icon, bool value, Function(bool) onChanged, Color textColor) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(icon, size: 28, color: textColor),
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor)),
          trailing: Switch(
            value: value,
            activeColor: Provider.of<ThemeProvider>(context, listen: false).brandColor,
            onChanged: onChanged,
          ),
        ),
        Divider(height: 1, indent: 60, endIndent: 20, color: textColor.withOpacity(0.1)),
      ],
    );
  }
}
