part of '../../../../env.dart';

Widget _buildNewsCard(double textScaleFactor, Function(int) updateCurrentPage) {
  if (_isLoadingNoticias) {
    return const Center(child: CircularProgressIndicator());
  }

  if (noticias.isEmpty) {
    return const Center(child: Text('Nenhuma notícia disponível.'));
  }

  return Column(
    children: [
      GestureDetector(
        onPanDown: (_) => _stopAutoPlay(),
        onPanEnd: (_) => _startAutoPlay(),
        child: SizedBox(
          height: 100 * textScaleFactor,
          child: PageView.builder(
            controller: _pageController,
            itemCount: noticias.length,
            onPageChanged: (index) {
              updateCurrentPage(index); // Chama o callback
            },
            itemBuilder: (context, index) {
              final noticia = noticias[index];

              Widget noticiaImage;
              if (downloadedNoticiasImages.containsKey(noticia.id) &&
                  downloadedNoticiasImages[noticia.id] != null) {
                noticiaImage = Image.file(
                  downloadedNoticiasImages[noticia.id]!,
                  height: 100 * textScaleFactor,
                  width: 100 * textScaleFactor,
                  fit: BoxFit.cover,
                );
              } else {
                noticiaImage = Image.asset(
                  noticia.fotoCapa ?? 'assets/image/default_image.jpg',
                  height: 100 * textScaleFactor,
                  width: 100 * textScaleFactor,
                  fit: BoxFit.cover,
                );
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetalheNoticiaPage(noticia: noticia),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(10.0),
                          ),
                          child: noticiaImage,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      noticia.titulo,
                                      style: TextStyle(
                                        fontSize: 13 * textScaleFactor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print('Compartilhar notícia');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    child: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                noticia.descricao,
                                style: TextStyle(
                                  fontSize: 11 * textScaleFactor,
                                  color: Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(noticias.length, (index) {
          return GestureDetector(
            onTap: () {
              updateCurrentPage(index); // Chama o callback
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index ? Colors.orange : Colors.grey[400],
              ),
            ),
          );
        }),
      ),
    ],
  );
}
