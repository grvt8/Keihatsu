import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../components/MainNavigationBar.dart';
import 'MangaDetailsScreen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const Color brandColor = Color(0xFFF97316); // Orange
  static const Color bgColor = Color(0xFFFFEDD5); // Cream
  int _currentIndex = 0;

  final List<Map<String, String>> mangaData = [
    {"title": "Player", "count": "239", "image": "images/player.jpg", "bgImage": "images/player.jpg"},
    {"title": "Ordeal", "count": "27", "image": "images/ordeal.png", "bgImage": "images/ordeal2.png"},
    {"title": "The Last...", "count": "15", "image": "images/adventurer.png", "bgImage": "images/adventurer.png"},
    {"title": "Return of...", "count": "118", "image": "images/sssranker.png", "bgImage": "images/sssranker.png"},
    {"title": "Bad Born...", "count": "82", "image": "images/badbornblood.jpg", "bgImage": "images/badbornblood.jpg"},
    {"title": "Latna Saga...", "count": "115", "image": "images/latnasaga.png", "bgImage": "images/latnasaga.png"},
    {"title": "Legend of...", "count": "38", "image": "images/northernblade.png", "bgImage": "images/northernblade.png"},
    {"title": "Black Sun", "count": "44", "image": "images/blacksun.png", "bgImage": "images/blacksun.png"},
    {"title": "Superhuman Battlefield...", "count": "111", "image": "images/superhumanbattlefield.png", "bgImage": "images/superhumanbattlefield2.png"},
    {"title": "Pick Me Up...", "count": "6", "image": "images/pickmeup2.png", "bgImage": "images/pickmeup.png"},
    {"title": "Swordsmaster's...", "count": "110", "image": "images/swordsmaster.png", "bgImage": "images/swordsmaster2.png"},
    {"title": "The Regressed...", "count": "143", "image": "images/mercenary.png", "bgImage": "images/mercenary.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Default',
          style: GoogleFonts.mysteryQuest(
            textStyle: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.magnifyingGlass(), color: Colors.black87)),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.funnel(), color: Colors.black87)),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.bell(), size: 40, color: Colors.black87)),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: mangaData.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaDetailsScreen(manga: mangaData[index]),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Manga Cover
                  Positioned.fill(
                    child: Image.asset(
                      mangaData[index]["image"]!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Update Badge
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: brandColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        mangaData[index]["count"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      mangaData[index]["title"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
