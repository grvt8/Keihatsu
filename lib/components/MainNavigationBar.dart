import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color brandColor;

  const MainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: const Color(0xFF1A1A1A), // Dark background matching the image
      type: BottomNavigationBarType.fixed,
      selectedItemColor: brandColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: [
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.books()),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.arrowsClockwise()),
          label: 'Updates',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.clockCounterClockwise()),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.puzzlePiece()),
          label: 'Extensions',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.user()),
          label: 'Profile',
        ),
      ],
    );
  }
}
