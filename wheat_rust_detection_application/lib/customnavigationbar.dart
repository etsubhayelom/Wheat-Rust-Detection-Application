import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
        color: Colors.grey[300], // Background color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildNavItem(0, "assets/rice-icon.svg",
                  "Home"), // Replace with your SVG asset
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(1, "assets/camera.svg", 'Know the disease'),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(2, "assets/person.svg", 'You'),
              label: '',
            ),
          ],
          currentIndex: widget.selectedIndex,
          selectedItemColor: Colors.green, // Active item color
          unselectedItemColor: Colors.grey, // Inactive item color
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          backgroundColor: Colors.grey[300],
          elevation: 1,
          type: BottomNavigationBarType.fixed,
          onTap: widget.onItemTapped,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    bool isSelected = widget.selectedIndex == index;
    Color iconColor = isSelected ? Colors.green : Colors.black;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SvgPicture.asset(
            iconPath,
            height: 30.0,
            width: 30.0,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: iconColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
