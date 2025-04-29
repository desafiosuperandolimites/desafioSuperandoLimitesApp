part of '../../../../env.dart';

void _showCompletionPopup(BuildContext context, int meta) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fundo do popup
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pop-up/papel_fundo.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '',
                  ),
                  // Botão de compartilhar
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PhotoFramePage(meta: meta.toDouble()),
                        ),
                      );
                    },
                    child: Image.asset('assets/pop-up/button_compartilhar.png',
                        width: 200),
                  ),
                ],
              ),
            ),

            // Botão de fechar (substituído por círculo laranja com X branco)
            Positioned(
              top: 45,
              right: 40,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF7801),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
