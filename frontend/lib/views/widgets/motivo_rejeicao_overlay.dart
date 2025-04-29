part of '../env.dart';

class MotivoRejeicaoOverlay {
  static void show(BuildContext context, Function(String) onEnviar) {
    TextEditingController observacaoController = TextEditingController();

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        // Use MediaQuery to get the viewInsets (keyboard height)
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  overlayEntry?.remove();
                },
                child: Container(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                ),
              ),
            ),
            Positioned(
              bottom: bottomInset,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
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
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Digite o motivo:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  //color: const Color.fromARGB(255, 85, 24, 24),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextField(
                                  controller: observacaoController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey[200],
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 64.w, vertical: 8.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      String observacao =
                                          observacaoController.text.trim();
                                      overlayEntry?.remove();
                                      onEnviar(observacao);
                                    },
                                    child: const Text(
                                      'Enviar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16, // Tamanho do texto padrão
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    // Insert the overlay
    Overlay.of(context).insert(overlayEntry);

    // Listen for keyboard visibility changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlayEntry?.markNeedsBuild();
    });
  }
}
