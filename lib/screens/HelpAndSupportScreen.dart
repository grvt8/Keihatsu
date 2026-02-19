import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../components/CustomBackButton.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  final Set<int> _expandedFaqs = {};

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I add manga to my library?',
      'answer': 'Browse any extension or use the global search to find a manga. On the manga details page, tap the "Add to library" button.'
    },
    {
      'question': 'Can I read manga offline?',
      'answer': 'Yes! You can download individual chapters by tapping the download icon next to them in the chapter list. Downloaded chapters can be viewed in your Download Queue.'
    },
    {
      'question': 'What are extensions?',
      'answer': 'Extensions are external sources that provide manga content. You can enable or disable them in the Extensions tab.'
    },
    {
      'question': 'How do I change the app theme?',
      'answer': 'Go to Profile > Settings > Appearance to customize the primary brand color and switch between light and dark modes.'
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Help & Support',
          style: GoogleFonts.hennyPenny(
            textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: brandColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(PhosphorIcons.headset(), size: 48, color: brandColor),
                  const SizedBox(height: 15),
                  Text(
                    "Need more help?",
                    style: GoogleFonts.delius(
                      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Our team is here to assist you with any issues or feedback.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {}, // TODO: Launch email client
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: Icon(PhosphorIcons.envelopeSimple()),
                    label: const Text("grvt8hq@gmail.com"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Frequently Asked Questions",
              style: GoogleFonts.hennyPenny(
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 15),

            // FAQ List
            ..._faqs.asMap().entries.map((entry) {
              int index = entry.key;
              bool isExpanded = _expandedFaqs.contains(index);
              return _buildFaqItem(index, entry.value['question']!, entry.value['answer']!, isExpanded, textColor, cardColor, brandColor);
            }).toList(),

            const SizedBox(height: 30),

            // Report a Bug Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: brandColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: Icon(PhosphorIcons.bug(), color: brandColor),
                label: Text(
                  "Report a Bug",
                  style: TextStyle(color: brandColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, String answer, bool isExpanded, Color textColor, Color cardColor, Color brandColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedFaqs.remove(index);
                } else {
                  _expandedFaqs.add(index);
                }
              });
            },
            title: Text(
              question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            trailing: Icon(
              isExpanded ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
              color: brandColor,
              size: 30,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(color: textColor.withOpacity(0.7), height: 1.4),
              ),
            ),
        ],
      ),
    );
  }
}
