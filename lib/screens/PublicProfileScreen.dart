import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../data/manga_data.dart';

class PublicProfileScreen extends StatefulWidget {
  final String username;
  final String userImage;

  const PublicProfileScreen({
    super.key,
    required this.username,
    required this.userImage,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 130) {
        if (!_showTitle) setState(() => _showTitle = true);
      } else {
        if (_showTitle) setState(() => _showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: bgColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: _showTitle ? textColor : Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: _showTitle
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(widget.userImage),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.username,
                            style: GoogleFonts.denkOne(
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('images/profileBg.jpeg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                    ),
                    // Profile Picture
                    Positioned(
                      bottom: 10,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            widget.userImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Profile Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: GoogleFonts.mysteryQuest(
                                textStyle: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const Text(
                              "25, Artist, Avid Bookworm",
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(PhosphorIcons.calendarDots(), size: 18, color: Colors.grey),
                                const SizedBox(width: 5),
                                const Text("Member since 2023", style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 20),
                                Icon(PhosphorIcons.mapPinArea(), size: 18, color: Colors.grey),
                                const SizedBox(width: 5),
                                const Text("Canada", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: brandColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(PhosphorIcons.shareNetwork(), color: brandColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem("45h", "Of Reading", textColor),
                          Container(height: 40, width: 1, color: textColor.withOpacity(0.1)),
                          _buildStatItem("192", "Manhwas Read", textColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: brandColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: textColor.withOpacity(0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.all(10),
                  tabs: const [
                    Tab(text: "Library"),
                    Tab(text: "Activity"),
                  ],
                ),
                bgColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLibraryTab(context, textColor, brandColor),
            _buildActivityTab(context, textColor, brandColor, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        Text(label, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12)),
      ],
    );
  }

  Widget _buildLibraryTab(BuildContext context, Color textColor, Color brandColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: mangaData.length,
      itemBuilder: (context, index) {
        final manga = mangaData[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(manga["image"]!, width: 80, height: 110, fit: BoxFit.cover),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manga["title"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Text("Brent Bristol", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(PhosphorIcons.bookOpen(), size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        const Text("157 chapters", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(PhosphorIcons.hourglassHigh(), size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        const Text("4 days", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab(BuildContext context, Color textColor, Color brandColor, Color cardColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 15, backgroundImage: AssetImage(widget.userImage)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(PhosphorIcons.chatCircleDots(), size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          const Text("Replied to Izzy", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 40, top: 5),
                child: Text("I love the concept behind the Midgal-El talent :)", style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(mangaData[index % mangaData.length]["image"]!, width: 40, height: 40, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ch 101", style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(mangaData[index % mangaData.length]["title"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const Text("Brent Bristol", style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.bgColor);

  final TabBar _tabBar;
  final Color bgColor;

  @override
  double get minExtent => _tabBar.preferredSize.height + 20;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bgColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
