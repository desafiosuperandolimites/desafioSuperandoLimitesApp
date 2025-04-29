part of '../env.dart';

class SalvoSucessoSnackBar {
  static void show(BuildContext context,
      {String message = 'Salvo com Sucesso'}) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
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
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 5,
                          offset: const Offset(0, 0),
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
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/image/IconSalvo.png',
                          height: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: const TextStyle(
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

    // Automatically remove the overlay after the duration
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
