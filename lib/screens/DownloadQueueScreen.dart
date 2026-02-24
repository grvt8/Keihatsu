import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../theme_provider.dart';
import '../components/CustomBackButton.dart';
import '../providers/download_provider.dart';
import '../models/local_models.dart';

class DownloadQueueScreen extends StatefulWidget {
  const DownloadQueueScreen({super.key});

  @override
  State<DownloadQueueScreen> createState() => _DownloadQueueScreenState();
}

class _DownloadQueueScreenState extends State<DownloadQueueScreen> {
  final Set<String> _expandedMangaIds = {};

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode
        ? Colors.white10
        : Colors.white.withOpacity(0.5);

    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        final queue = provider.queue;
        final groupedByExtension = groupBy(
          queue,
              (DownloadQueueItem i) => i.extensionName,
        );

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: const CustomBackButton(),
            title: Text(
              'Download Queue',
              style: GoogleFonts.hennyPenny(
                textStyle: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  provider.isGlobalPaused
                      ? PhosphorIcons.play()
                      : PhosphorIcons.pause(),
                  color: textColor,
                ),
                onPressed: () {
                  provider.toggleGlobalPause();
                },
                tooltip: provider.isGlobalPaused ? 'Resume All' : 'Pause All',
              ),
              IconButton(
                icon: Icon(PhosphorIcons.trash(), color: textColor),
                onPressed: () {
                  // TODO: Clear finished?
                },
              ),
            ],
          ),
          body: queue.isEmpty
              ? _buildEmptyState(textColor)
              : ListView(
            padding: const EdgeInsets.all(20),
            children: groupedByExtension.entries.map((entry) {
              return _buildExtensionGroup(
                entry.key,
                entry.value,
                brandColor,
                textColor,
                cardColor,
                provider,
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => provider.toggleGlobalPause(),
            backgroundColor: brandColor,
            child: Icon(
              provider.isGlobalPaused
                  ? PhosphorIcons.play()
                  : PhosphorIcons.pause(),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.cloudArrowDown(),
            size: 80,
            color: textColor.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
          Text(
            'No active downloads',
            style: GoogleFonts.delius(
              textStyle: TextStyle(
                color: textColor.withOpacity(0.4),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionGroup(
      String extensionName,
      List<DownloadQueueItem> items,
      Color brandColor,
      Color textColor,
      Color cardColor,
      DownloadProvider provider,
      ) {
    // Group items by manga
    // We need to maintain the order based on the priority of the first chapter of each manga
    // 1. Group by mangaId
    final groupedByManga = groupBy(items, (DownloadQueueItem i) => i.mangaId);

    // 2. Sort groups by priority (min priority of items in group)
    final sortedMangaKeys = groupedByManga.keys.toList()
      ..sort((a, b) {
        final priorityA = groupedByManga[a]!.map((i) => i.priority).min;
        final priorityB = groupedByManga[b]!.map((i) => i.priority).min;
        return priorityA.compareTo(priorityB);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                extensionName,
                style: GoogleFonts.hennyPenny(
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                  ),
                ),
              ),
              // Option to pause extension could go here
            ],
          ),
        ),
        ...sortedMangaKeys.asMap().entries.map((entry) {
          final index = entry.key;
          final mangaId = entry.value;
          final mangaItems = groupedByManga[mangaId]!
            ..sort((a, b) => a.priority.compareTo(b.priority));

          return _buildMangaCard(
            mangaId,
            mangaItems,
            brandColor,
            textColor,
            cardColor,
            provider,
            index, // Index of manga in this extension
            sortedMangaKeys.length,
            items.first.sourceId,
          );
        }),
      ],
    );
  }

  Widget _buildMangaCard(
      String mangaId,
      List<DownloadQueueItem> items,
      Color brandColor,
      Color textColor,
      Color cardColor,
      DownloadProvider provider,
      int mangaIndex,
      int totalMangas,
      String sourceId,
      ) {
    final firstItem = items.first;
    final isExpanded = _expandedMangaIds.contains(mangaId);
    final downloadingCount = items
        .where((i) => i.status == 1 || i.status == 0)
        .length;
    final failedCount = items.where((i) => i.status == 3).length;
    final isPaused = items.every((i) => i.status == 4);

    String statusText;
    if (isPaused) {
      statusText = "Paused";
    } else if (failedCount > 0) {
      statusText = "$downloadingCount downloading, $failedCount failed";
    } else {
      statusText = "$downloadingCount chapters downloading";
    }

    return Container(
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
                  _expandedMangaIds.remove(mangaId);
                } else {
                  _expandedMangaIds.add(mangaId);
                }
              });
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildThumbnail(firstItem.mangaThumbnail),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem.mangaTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPaused || failedCount > 0
                              ? Colors.orange
                              : textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Manga Actions
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: textColor),
                  onSelected: (value) {
                    if (value == 'pause') {
                      provider.togglePauseManga(sourceId, mangaId);
                    } else if (value == 'top') {
                      provider.reorderMangasOfExtension(
                        sourceId,
                        mangaIndex,
                        0,
                      );
                    } else if (value == 'up' && mangaIndex > 0) {
                      provider.reorderMangasOfExtension(
                        sourceId,
                        mangaIndex,
                        mangaIndex - 1,
                      );
                    } else if (value == 'down' &&
                        mangaIndex < totalMangas - 1) {
                      provider.reorderMangasOfExtension(
                        sourceId,
                        mangaIndex,
                        mangaIndex + 1,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pause',
                      child: Text(isPaused ? 'Resume' : 'Pause'),
                    ),
                    const PopupMenuItem(
                      value: 'top',
                      child: Text('Move to Top'),
                    ),
                    if (mangaIndex > 0)
                      const PopupMenuItem(value: 'up', child: Text('Move Up')),
                    if (mangaIndex < totalMangas - 1)
                      const PopupMenuItem(
                        value: 'down',
                        child: Text('Move Down'),
                      ),
                  ],
                ),
                Icon(
                  isExpanded
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: textColor.withOpacity(0.5),
                  size: 30,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 30, color: Colors.white10),
            // Use ReorderableListView for chapters
            // Note: ReorderableListView inside ListView needs shrinkWrap and physics
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) {
                provider.reorderChaptersOfManga(
                  sourceId,
                  mangaId,
                  oldIndex,
                  newIndex,
                );
              },
              itemBuilder: (context, index) {
                final chapter = items[index];
                return Padding(
                  key: ValueKey(
                    chapter.chapterId,
                  ), // Important for ReorderableListView
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chapter.chapterName,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildStatusBadge(chapter, brandColor),
                          IconButton(
                            icon: Icon(
                              chapter.status == 4
                                  ? Icons.play_arrow
                                  : Icons.pause,
                              size: 20,
                              color: textColor.withOpacity(0.7),
                            ),
                            onPressed: () {
                              if (chapter.status == 4) {
                                provider.resumeDownload(chapter.chapterId);
                              } else {
                                provider.pauseDownload(chapter.chapterId);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.red[300],
                            ),
                            onPressed: () {
                              provider.removeFromQueue(chapter.chapterId);
                            },
                          ),
                          // Drag handle is implicit on right for ReorderableListView
                        ],
                      ),
                      if (chapter.status == 1 || chapter.status == 3) ...[
                        // Downloading or Failed
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: chapter.status == 3 ? 1.0 : chapter.progress,
                            backgroundColor: Colors.white10,
                            color: chapter.status == 3
                                ? Colors.red
                                : brandColor,
                            minHeight: 6,
                          ),
                        ),
                        if (chapter.status == 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              chapter.error ?? "Failed",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? path) {
    if (path == null) {
      return Container(
        width: 50,
        height: 70,
        color: Colors.grey[800],
        child: const Icon(Icons.image, color: Colors.white24),
      );
    }

    // Check if it's a URL (http/https)
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 50,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 50,
          height: 70,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white24),
        ),
      );
    }

    // Otherwise treat as local file
    return Image.file(
      File(path),
      width: 50,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 50,
        height: 70,
        color: Colors.grey[800],
        child: const Icon(Icons.image_not_supported, color: Colors.white24),
      ),
    );
  }

  Widget _buildStatusBadge(DownloadQueueItem item, Color brandColor) {
    String text;
    Color color;

    switch (item.status) {
      case 0:
        text = "Queued";
        color = Colors.grey;
        break;
      case 1:
        text = "Downloading";
        color = brandColor;
        break;
      case 2:
        text = "Completed";
        color = Colors.green;
        break;
      case 3:
        text = "Failed";
        color = Colors.red;
        break;
      case 4:
        text = "Paused";
        color = Colors.orange;
        break;
      default:
        text = "";
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
