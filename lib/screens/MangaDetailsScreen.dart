import 'package:flutter/material.dart';

class MangaDetailsScreen extends StatelessWidget {
  final Map<String, String> manga;

  const MangaDetailsScreen({super.key, required this.manga});

  static const Color brandColor = Color(0xFFF97316); // Orange
  static const Color bgColor = Color(0xFFFFEDD5); // Cream

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: bgColor,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined, color: Colors.black87)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Colors.black87)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.black87)),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          manga["image"]!,
                          height: 180,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manga["title"]!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(Icons.person_outline, size: 16, color: Colors.black54),
                                SizedBox(width: 5),
                                Expanded(child: Text("Jong-Seok Park", style: TextStyle(color: Colors.black54))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16, color: Colors.black54),
                                SizedBox(width: 5),
                                Expanded(child: Text("Hyeon-Jun Oh", style: TextStyle(color: Colors.black54))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.black54),
                                SizedBox(width: 5),
                                Text("Ongoing • Vortex Scans", style: TextStyle(color: Colors.black54)),
                              ],
                            ),
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
                      _buildActionButton(Icons.favorite, "In library", brandColor),
                      _buildActionButton(Icons.hourglass_empty, "5 days", Colors.black54),
                      _buildActionButton(Icons.sync, "Tracking", Colors.black54),
                      _buildActionButton(Icons.public, "WebView", Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Through posting a \"Best Comment\", I somehow became the main character of a webtoon!",
                    style: TextStyle(color: Colors.black87, height: 1.4),
                  ),
                  const Center(child: Icon(Icons.keyboard_arrow_down, color: Colors.black54)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildTag("Manhwa"),
                      const SizedBox(width: 10),
                      _buildTag("Action"),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "246 chapters",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildChapterTile(245 - index);
              },
              childCount: 10, // Preview chapters
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brandColor,
        onPressed: () {},
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text("Resume", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black87)),
    );
  }

  Widget _buildChapterTile(int chapterNumber) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: const Icon(Icons.circle, size: 10, color: brandColor),
      title: Text("Chapter $chapterNumber", style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text("7/21/25", style: TextStyle(fontSize: 12, color: Colors.black54)),
      trailing: IconButton(
        icon: const Icon(Icons.download_for_offline_outlined, color: Colors.black38),
        onPressed: () {},
      ),
    );
  }
}
