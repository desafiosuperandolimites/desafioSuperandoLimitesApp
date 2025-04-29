part of '../../../env.dart';

class DetalheNoticiaPage extends StatefulWidget {
  final FeedNoticia noticia;

  const DetalheNoticiaPage({super.key, required this.noticia});

  @override
  DetalheNoticiaPageState createState() => DetalheNoticiaPageState();
}

class DetalheNoticiaPageState extends State<DetalheNoticiaPage> {
  final FileController _fileController = FileController();
  File? _downloadedNoticiaImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNoticiaImage();
  }

  Future<void> _loadNoticiaImage() async {
    if (widget.noticia.fotoCapa != null &&
        widget.noticia.fotoCapa!.isNotEmpty) {
      try {
        await _fileController
            .downloadFileCapasNoticias(widget.noticia.fotoCapa!);
        _downloadedNoticiaImage = _fileController.downloadedFile;
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao baixar imagem da notícia: $e');
        }
        _downloadedNoticiaImage = null;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = screenHeight < 668 ? 0.85 : 1.2;
    double buttonScaleFactor = screenHeight < 668 ? 0.8 : 1.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with the title
                Stack(
                  children: [
                    Container(color: Colors.white),
                    CustomSemicirculo(
                      height: screenHeight * 0.12,
                      color: const Color(0xFFFF7801),
                    ),
                    Positioned(
                      top: screenHeight * 0.04,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: Text(
                          'Notícias',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0 * buttonScaleFactor),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 5.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: _buildNoticiaImage(screenHeight),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0 * buttonScaleFactor),
                        child: Text(
                          'Atualizada: ${_formatDateWithTime(widget.noticia.atualizadoEm)}hs - Atualizado há ${_calculateDaysSinceUpdate(widget.noticia.atualizadoEm)} dias',
                          style: TextStyle(
                            fontSize: 10 * textScaleFactor,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0 * buttonScaleFactor),
                        child: Text(
                          widget.noticia.titulo,
                          style: TextStyle(
                            fontSize: 18 * textScaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0 * buttonScaleFactor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.noticia.descricao,
                                style: TextStyle(
                                  fontSize: 13 * textScaleFactor,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBackButton(context),
              ],
            ),
      bottomNavigationBar: FutureBuilder<String?>(
        future: AuthController().getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            return const CustomBottomNavigationBar(currentIndex: 0);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildNoticiaImage(double screenHeight) {
    if (_downloadedNoticiaImage != null) {
      return Image.file(
        _downloadedNoticiaImage!,
        width: double.infinity,
        height: screenHeight * 0.22,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        widget.noticia.fotoCapa ?? 'assets/image/default_image.jpg',
        width: double.infinity,
        height: screenHeight * 0.22,
        fit: BoxFit.cover,
      );
    }
  }

  String _formatDateWithTime(DateTime? date) {
    if (date == null) return 'Data desconhecida';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text(
            'Voltar',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _calculateDaysSinceUpdate(DateTime? date) {
    if (date == null) return '0';
    final now = DateTime.now();
    return now.difference(date).inDays.toString();
  }
}
