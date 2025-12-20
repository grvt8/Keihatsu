import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../components/MainNavigationBar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color brandColor = Color(0xFFF97316);
  static const Color bgColor = Color(0xFFFFEDD5);
  static const Color bgColor2 = Color(0xFFFFF8F0);
  int _currentIndex = 4; // Profile is index 4

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'images/pic.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kaizel",
                          style: GoogleFonts.mysteryQuest (
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Text(
                          "@404khai",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPill("Edit Profile", PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPill("Share Profile", PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold), Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Sections
              _buildListTile("Profile Details", PhosphorIcons.addressBook(PhosphorIconsStyle.bold), Colors.purple),
              
              const SizedBox(height: 10),
              _buildListTile("Download Queue", PhosphorIcons.cloudArrowDown(PhosphorIconsStyle.bold), Colors.orange),
              
              const SizedBox(height: 30),
              _buildSectionHeader("Settings"),
              _buildListTile("Notifications", PhosphorIcons.bell(PhosphorIconsStyle.bold), Colors.red),
              _buildListTile("Privacy & Security", PhosphorIcons.shieldCheck(PhosphorIconsStyle.bold), Colors.teal),
              _buildListTile("Appearance", PhosphorIcons.palette(PhosphorIconsStyle.bold), Colors.pink),

              const SizedBox(height: 30),
              _buildListTile("About", PhosphorIcons.info(PhosphorIconsStyle.bold), Colors.indigo),
              _buildListTile("Help & Support", PhosphorIcons.question(PhosphorIconsStyle.bold), Colors.amber),
              _buildListTile("Donate", PhosphorIcons.tipJar(PhosphorIconsStyle.bold), Colors.deepOrange),
              
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
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

  Widget _buildPill(String label, PhosphorIconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Text(
            "View All",
            style: TextStyle(
              fontSize: 14,
              color: brandColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, PhosphorIconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor2,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, color: color),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: Icon(PhosphorIcons.caretRight(), size: 16, color: Colors.black38),
          onTap: () {},
        ),
      ),
    );
  }
}
