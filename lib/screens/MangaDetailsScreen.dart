import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../data/manga_data.dart';

class MangaDetailsScreen extends StatelessWidget {
  final Map<String, String> manga;

  const MangaDetailsScreen({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.bgColor;
    final Color cardColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Blurred/Darkened Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    manga["bgImage"] ?? manga["image"]!,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          bgColor,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: Icon(PhosphorIcons.arrowLeft(), color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.downloadSimple(), color: Colors.white)),
                  IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.funnel(), color: Colors.white)),
                  IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.dotsThreeVertical(), color: Colors.white)),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Foreground Manga Cover
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                manga["image"]!,
                                height: 180,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  manga["title"]!,
                                  style: GoogleFonts.mysteryQuest(
                                    textStyle: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black,
                                          offset: Offset(2.0, 2.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(PhosphorIcons.user(), "Jong-Seok Park"),
                                const SizedBox(height: 4),
                                _buildInfoRow(PhosphorIcons.pencilLine(), "Hyeon-Jun Oh"),
                                const SizedBox(height: 4),
                                _buildInfoRow(PhosphorIcons.clock(), "Ongoing • Vortex Scans"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(PhosphorIcons.heart(PhosphorIconsStyle.fill), "In library", brandColor),
                          _buildActionButton(PhosphorIcons.hourglassHigh(), "5 days", Colors.black54),
                          _buildActionButton(PhosphorIcons.arrowsClockwise(), "Tracking", Colors.black54),
                          _buildActionButton(PhosphorIcons.globe(), "WebView", Colors.black54),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Box for Tags and Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Scrollable Tags
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildTag("# ACTION", brandColor),
                                  const SizedBox(width: 10),
                                  _buildTag("# ADVENTURE", brandColor),
                                  const SizedBox(width: 10),
                                  _buildTag("# ROMANCE", brandColor),
                                  const SizedBox(width: 10),
                                  _buildTag("# COMEDY", brandColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Description
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(color: Colors.black87, height: 1.4),
                                children: [
                                  TextSpan(text: "Through posting a \"Best Comment\", I somehow became the main character of a webtoon! Growing up in poverty, Sunny never expected anything good from life... "),
                                  TextSpan(
                                    text: "More",
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Divider(color: Colors.black12),
                            const SizedBox(height: 10),
                            // Chapters Updated Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "246 Chapters Updated",
                                      style: GoogleFonts.delius(
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    const Text("Latest update 1mth ago", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                Icon(PhosphorIcons.caretRight(), color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Chapters Preview Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text("Chapters", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(width: 5),
                                    Text("246", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("More", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    Icon(PhosphorIcons.caretRight(), color: Colors.grey, size: 16),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildChapterTile(context, 246, brandColor),
                            _buildChapterTile(context, 245, brandColor),
                            _buildChapterTile(context, 244, brandColor),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // "You may also like" Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("You may also like", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Row(
                                  children: [
                                    const Text("More", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    Icon(PhosphorIcons.caretRight(), color: Colors.grey, size: 16),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: mangaData.map((recommendation) {
                                  if (recommendation["title"] == manga["title"]) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: SizedBox(
                                      width: 100,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.asset(
                                              recommendation["image"]!,
                                              width: 100,
                                              height: 140,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            recommendation["title"]!,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Text(
                                            "Fantasy",
                                            style: TextStyle(color: Colors.grey, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Bottom padding for floating bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Download Icon
                  _buildBottomIconButton(PhosphorIcons.downloadSimple(), Colors.white),
                  const SizedBox(width: 10),
                  // Read Now Button
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          "Read now",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Checkmark Icon
                  _buildBottomIconButton(PhosphorIcons.check(), Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIconButton(PhosphorIconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildInfoRow(PhosphorIconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 5.0, color: Colors.black, offset: Offset(1.0, 1.0)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(PhosphorIconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildTag(String label, Color brandColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildChapterTile(BuildContext context, int chapterNumber, Color brandColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      leading: Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), size: 10, color: brandColor),
      title: Text("Chapter $chapterNumber", style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text("7/21/25", style: TextStyle(fontSize: 12, color: Colors.black54)),
      trailing: IconButton(
        icon: Icon(PhosphorIcons.downloadSimple(), color: Colors.black38),
        onPressed: () {},
      ),
    );
  }
}
