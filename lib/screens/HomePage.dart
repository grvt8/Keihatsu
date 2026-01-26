import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../data/manga_data.dart';
import '../theme_provider.dart';
import 'MangaDetailsScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.5);
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Keihatsu',
          style: GoogleFonts.hennyPenny(
            textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.magnifyingGlass(), color: textColor)),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.bell(), color: textColor)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Continue Reading Section
            _buildSectionHeader("Continue Reading", textColor, onSeeMore: () {
              Navigator.pushReplacementNamed(context, '/library');
            }),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final manga = mangaData[index];
                  return _buildMangaCard(context, manga, brandColor, textColor, cardColor);
                },
              ),
            ),

            const SizedBox(height: 30),

            // You Might Like Section
            _buildSectionHeader("You might like", textColor),
            _buildHorizontalMangaList(context, mangaData.skip(5).take(6).toList(), brandColor, textColor, cardColor),

            const SizedBox(height: 30),

            // Your Friends Read Section
            _buildSectionHeader("Your friends read", textColor),
            _buildHorizontalMangaList(context, mangaData.skip(11).take(6).toList(), brandColor, textColor, cardColor),

            const SizedBox(height: 30),

            // Most Bookmarked Section
            _buildSectionHeader("Most bookmarked", textColor),
            _buildHorizontalMangaList(context, mangaData.reversed.take(6).toList(), brandColor, textColor, cardColor),

            const SizedBox(height: 100), // Space for navigation bar
          ],
        ),
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor, {VoidCallback? onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.hennyPenny(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          if (onSeeMore != null)
            IconButton(
              onPressed: onSeeMore,
              icon: Icon(PhosphorIcons.arrowRight(), color: textColor.withOpacity(0.6), size: 20),
            )
          else
            Icon(PhosphorIcons.caretRight(), color: textColor.withOpacity(0.4), size: 18),
        ],
      ),
    );
  }

  Widget _buildHorizontalMangaList(BuildContext context, List<Map<String, String>> data, Color brandColor, Color textColor, Color cardColor) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final manga = data[index];
          return _buildMangaCard(context, manga, brandColor, textColor, cardColor, compact: true);
        },
      ),
    );
  }

  Widget _buildMangaCard(BuildContext context, Map<String, String> manga, Color brandColor, Color textColor, Color cardColor, {bool compact = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MangaDetailsScreen(manga: manga)),
        );
      },
      child: Container(
        width: compact ? 110 : 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Image.asset(
                      manga["image"]!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (!compact)
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga["title"]!,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!compact)
                    Text(
                      manga["chapter"] ?? "Ch. 1",
                      style: TextStyle(fontSize: 11, color: brandColor, fontWeight: FontWeight.bold),
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
