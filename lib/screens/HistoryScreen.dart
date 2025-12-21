import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../data/manga_data.dart';
import '../components/MainNavigationBar.dart';
import '../theme_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 2; // History is index 2

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.bgColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'History',
          style: GoogleFonts.mysteryQuest(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              )
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.magnifyingGlass(), color: Colors.black87)),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.trash(), color: Colors.black87)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mangaData.length,
        itemBuilder: (context, index) {
          final manga = mangaData[index];
          bool showDate = index == 0 || mangaData[index]["date"] != mangaData[index - 1]["date"];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDate)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    manga["date"]!,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        manga["image"]!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manga["title"]!,
                            style: GoogleFonts.mysteryQuest(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black
                              )
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${manga["chapter"]} - ${manga["time"]}",
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.heart(), size: 20)),
                    IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.trash(), size: 20)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/library');
          if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
