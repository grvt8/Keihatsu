import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keihatsu/screens/AboutScreen.dart';
import 'package:keihatsu/screens/DonateScreen.dart';
import 'package:keihatsu/screens/HelpAndSupportScreen.dart';
import 'package:keihatsu/screens/InboxScreen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../theme_provider.dart';
import 'SettingsScreen.dart';
import 'StatsScreen.dart';
import 'DownloadQueueScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Profile is index 4
  late ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 120) {
        if (!_showTitle) setState(() => _showTitle = true);
      } else {
        if (_showTitle) setState(() => _showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final Color cardColor = themeProvider.pureBlackDarkMode ? Colors.white10 : Colors.white.withOpacity(0.55);
    final Color textColor = themeProvider.pureBlackDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            title: _showTitle
                ? Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage('images/user1.jpeg'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Kaizel",
                          style: GoogleFonts.denkOne(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildTopIcons(brandColor, isScrolled: true),
                    ],
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                clipBehavior: Clip.none,
                children: [
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
                  if (!_showTitle)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: _buildTopIcons(brandColor),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
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
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, 10),
              child: Column(
                children: [
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
                                  style: GoogleFonts.hennyPenny(
                                    textStyle: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(Icons.edit_rounded, size: 20, color: textColor.withOpacity(0.6)),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageBadge('images/badge1.png', "Night Owl", textColor),
                          _buildImageBadge('images/badge2.png', "Touch Grass", textColor),
                          _buildImageBadge('images/badge3.png', "Offline Samurai", textColor),
                          _buildImageBadge('images/badge4.png', "Keyboard Warrior", textColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildSingleTile("Download Queue", PhosphorIcons.cloudArrowDown(), cardColor, textColor, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DownloadQueueScreen()),
                          );
                        }),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            children: [
                              _buildGroupTile("Settings", Icons.settings_rounded, true, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                );
                              }, textColor),
                              _buildGroupTile("Inbox", PhosphorIcons.mailbox(), true, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InboxScreen()),
                                );
                              }, textColor),
                              _buildGroupTile("Stats", PhosphorIcons.chartLineUp(), false, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                                );
                              }, textColor),
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
                              _buildGroupTile("Help & Support", PhosphorIcons.question(), true, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HelpAndSupportScreen()),
                                );
                              }, textColor),
                              _buildGroupTile("Donate", PhosphorIcons.tipJar(), true, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DonateScreen()),
                                );
                              }, textColor),
                              _buildGroupTile("About", PhosphorIcons.info(), false, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                                );
                              }, textColor),
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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }

  Widget _buildTopIcons(Color brandColor, {bool isScrolled = false}) {
    final Color iconColor = isScrolled ? (Provider.of<ThemeProvider>(context).pureBlackDarkMode ? Colors.white : Colors.black87) : Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Icon(Icons.notifications, color: iconColor, size: 28),
            Positioned(
              right: 0,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: Icon(PhosphorIcons.gear(), color: iconColor, size: 28),
        ),
      ],
    );
  }

  Widget _buildImageBadge(String imagePath, String name, Color textColor) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: textColor.withOpacity(0.1)),
            ),
            child: ClipOval(
              child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(PhosphorIcons.medal(), color: textColor.withOpacity(0.2))),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7)),
          ),
        ],
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

  Widget _buildSingleTile(String title, PhosphorIconData icon, Color color, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildGroupTile(String title, IconData icon, bool showDivider, VoidCallback onTap, Color textColor) {
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
