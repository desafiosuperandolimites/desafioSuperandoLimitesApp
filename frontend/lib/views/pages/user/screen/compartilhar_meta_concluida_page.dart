part of '../../../env.dart';

class PhotoFramePage extends StatefulWidget {
  final double meta;
  const PhotoFramePage({super.key, required this.meta});

  @override
  PhotoFramePageState createState() => PhotoFramePageState();
}

class PhotoFramePageState extends State<PhotoFramePage> {
  File? _selfieImage;
  File? _previewImageFile;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _canvasKey = GlobalKey();

  final String _defaultSelfiePath = 'assets/image/self_padrao.png';
  final String _molduraPath = 'assets/image/moldura_pub_geral.png';
  final String _medalhaPath = 'assets/image/medalha_padrao.png';

  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _scale = 1.0;
  double _previousScale = 1.0;
  Size? _molduraSize; // Alterado para ser opcional
  bool _isMolduraLoaded = false; // Controle de carregamento da moldura

  @override
  void initState() {
    super.initState();
    _getMolduraSize();
  }

  // Função para obter o tamanho da moldura
  // Função para obter o tamanho da moldura
  Future<void> _getMolduraSize() async {
    final image = Image.asset(_molduraPath);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          _molduraSize =
              Size(info.image.width.toDouble(), info.image.height.toDouble());
          _isMolduraLoaded = true; // Marca que a moldura foi carregada
        });
      }),
    );
  }

  void _centerImage() {
    setState(() {
      final screenWidth = MediaQuery.of(context).size.width;
      // Centralizar a imagem no container
      _offsetX =
          (screenWidth - (_selfieImage != null ? screenWidth * _scale : 0)) / 2;
      _offsetY =
          (screenWidth - (_selfieImage != null ? screenWidth * _scale : 0)) / 2;
      _scale = 1.0; // Redefine a escala para o valor padrão
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selfieImage = File(pickedFile.path);
      });
      _centerImage(); // Centraliza a imagem carregada
    }
  }

  Future<void> _generateFinalImage() async {
    try {
      // Captura o widget atual como imagem com a escala apropriada
      final RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // ignore: deprecated_member_use
      final double devicePixelRatio = ui.window.devicePixelRatio;
      final ui.Image image =
          await boundary.toImage(pixelRatio: devicePixelRatio);

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception("Falha ao gerar byteData da imagem.");
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Salva a imagem capturada
      final tempDir = await getTemporaryDirectory();
      final File outputFile = File('${tempDir.path}/montagem_final.png');
      await outputFile.writeAsBytes(pngBytes);

      setState(() {
        _previewImageFile = outputFile;
      });
    } catch (e) {
      debugPrint("Erro ao gerar imagem final: $e");
    }
  }

  Future<void> _shareFinalImage() async {
    if (_previewImageFile != null) {
      try {
        await Share.shareXFiles([XFile(_previewImageFile!.path)],
            text: "Confira minha montagem!");
      } catch (e) {
        debugPrint("Erro ao compartilhar imagem: $e");
      }
    } else {
      debugPrint("Nenhuma imagem gerada para compartilhar.");
    }
  }

  void _showPreviewDialog(BuildContext context) {
    if (_previewImageFile != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            titlePadding:
                const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "#CompartilharMetaBatida:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            content: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(_previewImageFile!),
            ),
            contentPadding: const EdgeInsets.all(16.0),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 16.0),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareFinalImage();
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  "Compartilhar",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  shadowColor: Colors.black38,
                  elevation: 5.0,
                ),
              ),
            ],
          );
        },
      );
    } else {
      debugPrint("Nenhuma imagem gerada para preview.");
    }
  }

  void _showPickImageDialog(BuildContext context) {
    showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Center(
          child: Text(
            'Selecione uma opção',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(); // fecha o modal
              _pickImage(ImageSource.camera);
            },
            child: const Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.orange,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Tirar Foto',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(); // fecha o modal
              _pickImage(ImageSource.gallery);
            },
            //onPressed: () => _pickImage(ImageSource.gallery),
            //onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: const Row(
              children: [
                Icon(
                  Icons.photo,
                  color: Colors.orange,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Escolher da Galeria',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exibe um indicador de carregamento até que a moldura tenha sido carregada
    if (!_isMolduraLoaded) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator()), // Indicador de carregamento
      );
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final bool isSmallScreen = screenWidth <= 400;
    final bool isMidScreen = screenWidth > 400 && screenWidth < 600;
    final bool isBigScreen = screenWidth > 600 && screenWidth < 850;
    final bool isPixelScreen = screenWidth > 850;

    // Ajustar fatores de escala conforme o tamanho
    double ratio = 0;
    if (isSmallScreen) {
      //small
      ratio = 0.9;
    } else if (isMidScreen) {
      //rexible
      ratio = 1;
    } else if (isBigScreen) {
      //tablet
      ratio = 1.4;
    } else if (isPixelScreen) {
      //pixel fold
      ratio = 1.2;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header com o semicirculo e título
          SizedBox(
            height: screenHeight * 0.14,
            child: Stack(
              children: [
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
                      '#MetaBatida',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FittedBox(
              child: RepaintBoundary(
                key: _canvasKey,
                child: GestureDetector(
                  onTapDown: (details) {
                    // Se ainda não temos selfie, abre o modal
                    if (_selfieImage == null) {
                      _showPickImageDialog(context);
                    }
                  },
                  onScaleStart: (details) {
                    _previousScale = _scale;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale =
                          (_previousScale * details.scale).clamp(0.025, 6.0);
                      _offsetX += details.focalPointDelta.dx;
                      _offsetY += details.focalPointDelta.dy;
                    });
                  },
                  child: Container(
                    //width: _molduraSize!.width, // Usando o tamanho da moldura
                    //height: _molduraSize!.height, // Usando o tamanho da moldura
                    color: Colors.white,
                    child: Stack(
                      children: [
                        // Selfie (com limite de 1080x1080 e movimentação)
                        ClipRect(
                          child: Transform.translate(
                            offset: Offset(_offsetX, _offsetY),
                            child: Transform.scale(
                              scale: _scale,
                              child: Stack(
                                children: [
                                  // Se NÃO tiver foto escolhida, mostra default + overlay clique‐ável
                                  if (_selfieImage == null) ...[
                                    Image.asset(
                                      _defaultSelfiePath,
                                      fit: BoxFit.contain,
                                      width: _molduraSize!.width,
                                      height: _molduraSize!.height,
                                    ),
                                    // Botão invisível ocupando todo o espaço
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () =>
                                              _showPickImageDialog(context),
                                          child:
                                              Container(), // invisível, mas clicável
                                        ),
                                      ),
                                    )
                                  ] else ...[
                                    // Se tiver foto, exibe normalmente
                                    Image.file(
                                      _selfieImage!,
                                      fit: BoxFit.contain,
                                      width: _molduraSize!.width,
                                      height: _molduraSize!.height,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: _molduraSize!
                                .width, // Usando o tamanho da moldura
                            height: _molduraSize!
                                .height, // Usando o tamanho da moldura
                            child: Image.asset(
                              _molduraPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        Positioned(
                          //top: screenHeight *
                          //0.1, // Ajuste a posição vertical conforme necessário
                          //left: screenWidth *
                          //0.1, // Ajusta a posição horizontal para a esquerda
                          child: SizedBox(
                            width: _molduraSize!
                                .width, // Usando o tamanho da moldura
                            height: _molduraSize!
                                .height, // Usando o tamanho da moldura
                            child: Image.asset(
                              _medalhaPath, // Caminho para a imagem da medalha
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Texto dinâmico na medalha
                        Positioned(
                          top: 400.2, // Ajusta a posição vertical do texto
                          left: 0, // Centraliza horizontalmente
                          right: 703.8, // Caso a tela não seja pequena
                          child: Align(
                            alignment: Alignment
                                .center, // Centraliza o texto horizontal e verticalmente
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      8.0), // Ajusta o padding se necessário
                              //width: screenWidth *
                              //0.45, // Largura proporcional do texto
                              //height: screenWidth *
                              //0.1, // Altura proporcional ao tamanho do texto
                              child: FittedBox(
                                fit: BoxFit
                                    .scaleDown, // Garante que o texto se ajuste ao tamanho do container
                                child: Text(
                                  "${widget.meta.toInt()} km", // Texto dinâmico da quilometragem
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 70, // Tamanho da fonte ajustável
                                    fontWeight: FontWeight.bold, // Negrito
                                    color: Colors.black, // Cor do texto
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_selfieImage != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Alterar Foto",
                        style: TextStyle(
                          color: const ui.Color.fromARGB(255, 0, 0, 0),
                          fontSize: 18 * ratio,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Colors.orange,
                        iconSize: 35 * ratio,
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      IconButton(
                        color: Colors.orange,
                        iconSize: 35 * ratio,
                        icon: const Icon(Icons.photo),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _generateFinalImage();
                      // ignore: use_build_context_synchronously
                      _showPreviewDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 15 * ratio),
                      fixedSize: Size(ratio * 180, 40 * ratio),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * ratio),
                      ),
                    ),
                    child: Text(
                      'Compartilhar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18 * ratio,
                      ),
                    ),
                  ),
                ),
                const CustomButtonVoltar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
