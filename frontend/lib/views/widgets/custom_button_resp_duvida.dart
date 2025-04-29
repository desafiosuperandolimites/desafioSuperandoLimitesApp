part of '../env.dart';

class RespDuvidaPopup {
  static OverlayEntry show(
      BuildContext context, String duvidaTexto, Function(String) onSend) {
    final TextEditingController respostaController = TextEditingController();

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(builder: (context) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final screenHeight = MediaQuery.of(context).size.height;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: keyboardHeight > 0 ? keyboardHeight : 0,
            left: 0,
            right: 0,
            child: Material(
              color: const Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SizedBox(
                height: screenHeight / 2.5,
                width: double.infinity,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '"$duvidaTexto"',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Colors.grey[200],
                          ),
                          child: TextField(
                            controller: respostaController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Digite sua resposta aqui...',
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              overlayEntry.remove();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final respostaText =
                                  respostaController.text.trim();
                              if (respostaText.isNotEmpty) {
                                onSend(respostaText);
                                overlayEntry.remove();

                                SalvoSucessoSnackBar.show(
                                  context,
                                  message: 'Resposta enviada com sucesso!',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Enviar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
          ),
        ],
      );
    });

    Overlay.of(context).insert(overlayEntry);

    return overlayEntry;
  }
}
