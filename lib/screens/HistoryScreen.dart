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
  final int _currentIndex = 2; // History is index 2
  final Set<int> _selectedIndices = {};
  bool _isSelectionMode = false;

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIndices.add(index);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIndices.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelected() {
    setState(() {
      _selectedIndices.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Selected items deleted (Visual only for now)")),
    );
  }

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
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: Icon(PhosphorIcons.x(), color: textColor),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(
          _isSelectionMode ? "${_selectedIndices.length} selected" : 'History',
          style: GoogleFonts.hennyPenny(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              )
          ),
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              onPressed: _deleteSelected,
              icon: Icon(PhosphorIcons.trash(), color: textColor),
            )
          else ...[
            IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.magnifyingGlass(), color: textColor)),
            IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.trash(), color: textColor)),
          ],
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mangaData.length,
        itemBuilder: (context, index) {
          final manga = mangaData[index];
          final isSelected = _selectedIndices.contains(index);
          bool showDate = index == 0 || mangaData[index]["date"] != mangaData[index - 1]["date"];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDate)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    manga["date"]!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withOpacity(0.6)),
                  ),
                ),
              InkWell(
                onLongPress: () => _toggleSelection(index),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(index);
                  } else {
                    // Normal tap behavior
                  }
                },
                child: Container(
                  color: isSelected ? brandColor.withOpacity(0.1) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Stack(
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
                          if (isSelected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manga["title"]!,
                              style: GoogleFonts.hennyPenny(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                )
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${manga["chapter"]} - ${manga["time"]}",
                              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (!_isSelectionMode) ...[
                        IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.heart(), size: 20, color: textColor)),
                        IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.trash(), size: 20, color: textColor)),
                      ] else
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(index),
                          activeColor: brandColor,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }
}
