import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class UserProfileSheet extends StatelessWidget {
  final String username;
  final String userImage;

  const UserProfileSheet({
    super.key,
    required this.username,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner & Profile Pic Area
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
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
              // Drag Handle
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Profile Picture
              Positioned(
                bottom: -40,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage(userImage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          // User Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Badges
                Row(
                  children: [
                    _buildBadge(context, PhosphorIcons.sealCheck(PhosphorIconsStyle.fill), "", Colors.blue),
                    const SizedBox(width: 8),
                    _buildBadge(context, PhosphorIcons.sword(), "Keyboard Warrior", Colors.brown[400]!),
                    const SizedBox(width: 8),
                    _buildBadge(context, PhosphorIcons.discordLogo(), "$username.9611", const Color(0xFF5865F2)),
                  ],
                ),
                const SizedBox(height: 12),
                // Views
                Row(
                  children: [
                    Icon(PhosphorIcons.eye(), size: 16, color: textColor.withOpacity(0.5)),
                    const SizedBox(width: 5),
                    Text("119", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 25),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem("711", "Reputation", textColor),
                    _buildStatItem("460", "Comments", textColor),
                    _buildStatItem("96", "Manga Read", textColor),
                    _buildStatItem("#127", "Highest Rank", textColor),
                  ],
                ),
                const SizedBox(height: 30),
                // View Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("View profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 10),
                        Icon(PhosphorIcons.caretRight(), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, PhosphorIconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5))),
      ],
    );
  }
}
