part of '../env.dart';

class SalvandoSnackBar {
  static OverlayEntry show(BuildContext context) {
    // Create a function that returns an OverlayEntry
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        clipBehavior: Clip.none,
        children: [
          // Transparent background for the whole screen
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255)
                  .withOpacity(0.8), // Semi-transparent background
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0, // Shadow appears above the top border of SnackBar
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 5, // Blur radius for shadow softness
                          spreadRadius: 5, // Spread of the shadow
                          offset: const Offset(0, 0), // Offset upwards
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24), // Rounded top corners
                    ),
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height /
                        3, // Take up 1/3rd of screen height
                    width: double.infinity, // Full width
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Salvando....',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(overlayEntry);

    return overlayEntry;
  }
}
