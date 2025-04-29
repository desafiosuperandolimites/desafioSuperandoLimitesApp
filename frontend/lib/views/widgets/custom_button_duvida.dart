part of '../env.dart';

class DuvidaPopup {
  static OverlayEntry show(BuildContext context, Function(String) onSend) {
    final TextEditingController duvidaController = TextEditingController();
    final ValueNotifier<int> charCountNotifier = ValueNotifier<int>(0);
    const int maxChars = 75; // Limite de caracteres

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
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
                        const Text(
                          'Escreva sua dúvida:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Colors.grey[200],
                                ),
                                child: TextField(
                                  controller: duvidaController,
                                  maxLength: maxChars,
                                  maxLines: 5,
                                  onChanged: (value) {
                                    charCountNotifier.value = value.length;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Digite sua dúvida aqui...',
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
                                    counterText: '', // Remove o contador padrão
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<int>(
                                valueListenable: charCountNotifier,
                                builder: (context, count, child) {
                                  return Text(
                                    '$count/$maxChars caracteres',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: count > maxChars
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ],
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
                                final duvidaText =
                                    duvidaController.text.trim();
                                if (duvidaText.isNotEmpty &&
                                    duvidaText.length <= maxChars) {
                                  onSend(duvidaText);
                                  overlayEntry.remove();

                                  SalvoSucessoSnackBar.show(
                                    context,
                                    message: 'Dúvida enviada com sucesso!',
                                  );
                                } else if (duvidaText.length > maxChars) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Sua dúvida excedeu o limite de caracteres permitido.'),
                                      backgroundColor: Colors.red,
                                    ),
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
      },
    );

    Overlay.of(context).insert(overlayEntry);

    return overlayEntry;
  }
}
