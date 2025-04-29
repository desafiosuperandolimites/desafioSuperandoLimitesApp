part of '../../../../env.dart';

void _openVideoDialog(BuildContext context, String videoId) {
  final youtubeController = YoutubePlayerController(
    initialVideoId: videoId,
    flags: const YoutubePlayerFlags(
      autoPlay: true, // Inicia o vídeo automaticamente ao abrir o Dialog
      mute: false,
    ),
  );

  // Permite todas as orientações ao abrir o vídeo em tela cheia
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: //Container(
            //    width: MediaQuery.of(context).size.width * 0.9,
            //  height: MediaQuery.of(context).size.height * 0.5,
            //  child:
            Stack(
          children: [
            YoutubePlayer(
              controller: youtubeController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.orange,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        // ),
      );
    },
  ).then((_) {
    // Restaura o modo retrato ao fechar o Dialog
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  });
}

Widget _buildDepoimentosContent(depoimentos, _isLoadingDepoimentos) {
  // Unchanged logic
  if (_isLoadingDepoimentos) {
    return const Center(child: CircularProgressIndicator());
  }

  if (depoimentos.isEmpty) {
    return const Center(child: Text('Nenhum depoimento disponível.'));
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: depoimentos.length,
    itemBuilder: (context, index) {
      final depoimento = depoimentos[index];
      final videoId = YoutubePlayer.convertUrlToId(depoimento.link);

      if (videoId == null) {
        return const Center(child: Text('URL de vídeo inválida.'));
      }

      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: GestureDetector(
                      onTap: () {
                        _openVideoDialog(context, videoId);
                      },
                      child: Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Depoimento ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
