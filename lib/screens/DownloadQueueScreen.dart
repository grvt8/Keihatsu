import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class DownloadQueueScreen extends StatefulWidget {
  const DownloadQueueScreen({super.key});

  @override
  State<DownloadQueueScreen> createState() => _DownloadQueueScreenState();
}

class _DownloadQueueScreenState extends State<DownloadQueueScreen> {
  // Track expanded state for each manga group
  final Set<int> _expandedIndices = {0}; // Start with the first one expanded

  // Static mock data for reference
  final List<Map<String, dynamic>> _downloads = [
    {
      'extension': 'ManhuaTop',
      'manga': 'Solo Leveling',
      'thumbnail': 'images/sololvl.png',
      'chapters': [
        {'name': 'Chapter 178', 'progress': 0.8, 'status': 'Downloading'},
        {'name': 'Chapter 177', 'progress': 1.0, 'status': 'Completed'},
      ]
    },
    {
      'extension': 'WeebCentral',
      'manga': 'One Piece',
      'thumbnail': 'images/keihatsu.png', // Fallback or placeholder
      'chapters': [
        {'name': 'Chapter 1105', 'progress': 0.3, 'status': 'Downloading'},
        {'name': 'Chapter 1104', 'progress': 0.0, 'status': 'Queued'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Download Queue',
          style: GoogleFonts.hennyPenny(
            textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.playPause(), color: textColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(PhosphorIcons.trash(), color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: _downloads.isEmpty
          ? _buildEmptyState(textColor)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _downloads.length,
              itemBuilder: (context, index) {
                final group = _downloads[index];
                return _buildDownloadGroup(index, group, brandColor, textColor, cardColor);
              },
            ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.cloudArrowDown(), size: 80, color: textColor.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            'No active downloads',
            style: GoogleFonts.delius(
              textStyle: TextStyle(color: textColor.withOpacity(0.4), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadGroup(int index, Map<String, dynamic> group, Color brandColor, Color textColor, Color cardColor) {
    final bool isExpanded = _expandedIndices.contains(index);
    final int downloadingCount = (group['chapters'] as List).where((c) => c['status'] == 'Downloading').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 10),
          child: Text(
            group['extension'],
            style: GoogleFonts.hennyPenny(
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandColor),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedIndices.remove(index);
                    } else {
                      _expandedIndices.add(index);
                    }
                  });
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        group['thumbnail'],
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 70,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported, color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['manga'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$downloadingCount chapters downloading",
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                      color: textColor.withOpacity(0.5),
                      size: 30,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 30, color: Colors.white10),
                ...((group['chapters'] as List).map((chapter) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              chapter['name'],
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              chapter['status'],
                              style: TextStyle(
                                color: chapter['status'] == 'Completed' ? Colors.green : brandColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: chapter['progress'],
                            backgroundColor: Colors.white10,
                            color: chapter['status'] == 'Completed' ? Colors.green : brandColor,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
