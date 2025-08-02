import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// This widget represents a single tab. It is responsible for its own appearance.
class GrufioTab extends StatelessWidget {
  final String iconPath;
  final bool isActive;
  final VoidCallback onTap;

  const GrufioTab({
    super.key,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 41.0,
        // The active tab's white background covers the border from the flexibleSpace.
        // Inactive tabs are transparent, allowing the background to show through.
        color: isActive ? Colors.white : Colors.transparent,
        child: Container(
          width: 41.0,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: kBordersColor,
                width: 1.0,
              ),
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GrufioTabsAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GrufioTabsAppBar({super.key});

  @override
  State<GrufioTabsAppBar> createState() => _GrufioTabsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(41.0);
}

class _GrufioTabsAppBarState extends State<GrufioTabsAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 41.0,
      // The AppBar itself is transparent.
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      // The flexibleSpace is drawn BEHIND the title, containing the background
      // color and the continuous bottom border.
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: kBordersColor,
              width: 1.0,
            ),
          ),
        ),
      ),
      // The title contains the tabs, which are drawn ON TOP of the flexibleSpace.
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Home Tab
          GrufioTab(
            isActive: true,
            iconPath: 'assets/icons/32/home.svg',
            onTap: () {},
          ),
          // Other tabs will be added here.
        ],
      ),
    );
  }
}
