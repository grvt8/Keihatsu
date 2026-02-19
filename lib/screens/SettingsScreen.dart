import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../components/CustomBackButton.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Settings',
          style: GoogleFonts.hennyPenny(
            textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.palette(),
            title: "Appearance",
            subtitle: "Themes, dark mode, display",
            onTap: () => Navigator.pushNamed(context, '/appearance'),
            textColor: textColor,
            brandColor: brandColor,
          ),
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.books(),
            title: "Library",
            subtitle: "Categories, global update, badges",
            onTap: () {},
            textColor: textColor,
            brandColor: brandColor,
          ),
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.bookOpen(),
            title: "Reader",
            subtitle: "Reading mode, display, navigation",
            onTap: () {},
            textColor: textColor,
            brandColor: brandColor,
          ),
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.downloadSimple(),
            title: "Downloads",
            subtitle: "Download location, save chapters",
            onTap: () {},
            textColor: textColor,
            brandColor: brandColor,
          ),
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.compass(),
            title: "Browse",
            subtitle: "Extensions, global search",
            onTap: () {},
            textColor: textColor,
            brandColor: brandColor,
          ),
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.arrowsClockwise(),
            title: "Tracking",
            subtitle: "Sync with services like MyAnimeList",
            onTap: () {},
            textColor: textColor,
            brandColor: brandColor,
          ),
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.shieldCheck(),
            title: "Privacy",
            subtitle: "Incognito mode, security",
            onTap: () {},
            textColor: textColor,
            brandColor: brandColor,
          ),
          _buildSettingsTile(
            context,
            icon: PhosphorIcons.command(),
            title: "Advanced",
            subtitle: "Backup, clear cache, logs",
            onTap: () {},
            textColor: textColor,
            brandColor: brandColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required PhosphorIconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color brandColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.white.withOpacity(0.05),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: brandColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: brandColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.delius(
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
        ),
        trailing: Icon(PhosphorIcons.caretRight(), color: textColor.withOpacity(0.3), size: 18),
      ),
    );
  }
}
