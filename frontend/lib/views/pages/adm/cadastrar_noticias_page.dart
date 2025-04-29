// ignore_for_file: deprecated_member_use

part of '../../env.dart';

class CriarNoticiaPage extends StatefulWidget {
  final FeedNoticia? noticia;

  const CriarNoticiaPage({super.key, this.noticia});

  @override
  CriarNoticiaPageState createState() => CriarNoticiaPageState();
}

class CriarNoticiaPageState extends State<CriarNoticiaPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  final FeedNoticiaController _feedNoticiaController = FeedNoticiaController();
  final FileController _fileController = FileController();

  File? _noticiaImage; // Newly chosen image before upload
  File? _downloadedNoticiaImage; // Downloaded image if editing existing noticia
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.noticia != null) {
      _tituloController.text = widget.noticia!.titulo;
      _textoController.text = widget.noticia!.descricao;
      _loadExistingNoticiaImage();
    }
  }

  Future<void> _loadExistingNoticiaImage() async {
    if (widget.noticia?.fotoCapa != null &&
        widget.noticia!.fotoCapa!.isNotEmpty) {
      try {
        await _fileController
            .downloadFileCapasNoticias(widget.noticia!.fotoCapa!);
        setState(() {
          _downloadedNoticiaImage = _fileController.downloadedFile;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao baixar imagem da notícia: $e');
        }
        // You can show an error message if needed
      }
    }
  }

  // Pick an image from camera or gallery
  Future<void> _pickNoticiaImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      } else {
        await Permission.photos.request();
      }
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _noticiaImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    final action = await showDialog<ImageSource>(
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
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            child: const Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.black,
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
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: const Row(
              children: [
                Icon(
                  Icons.photo,
                  color: Colors.black,
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
    if (action != null) {
      await _pickNoticiaImage(action);
    }
  }

  Future<void> _salvarNoticia() async {
    if (_isSaving) return; // Previne cliques adicionais enquanto salva
    setState(() => _isSaving = true);

    if (_tituloController.text.isEmpty || _textoController.text.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de salvar.'),
        ),
      );
      return;
    }

    // Verifica se uma imagem foi selecionada
    if (_noticiaImage == null && _downloadedNoticiaImage == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma imagem antes de salvar.'),
        ),
      );
      return;
    }

    // Upload image if a new one was chosen
    String? uploadedFileName;
    if (_noticiaImage != null) {
      try {
        await _fileController.uploadFileCapasNoticias(_noticiaImage);
        uploadedFileName = _noticiaImage!.path.split('/').last;
      } catch (e) {
        setState(() => _isSaving = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar imagem: $e')),
        );
        return;
      }
    } else {
      // If no new image chosen and we are editing, keep existing one
      // If creating new and no image chosen, set this according to your logic
      uploadedFileName = widget.noticia?.fotoCapa;
    }

    FeedNoticia noticia = FeedNoticia(
      id: widget.noticia?.id, // Mantém o ID para edição
      idUsuario: 1, // Substituir pelo ID do usuário logado
      categoria:
          'Geral', // Categoria fixa, pode ser alterada conforme necessário
      titulo: _tituloController.text,
      descricao: _textoController.text,
      fotoCapa: uploadedFileName,
    );

    try {
      if (widget.noticia == null) {
        if (!mounted) return;
        // Criar nova notícia
        await _feedNoticiaController.createFeedNoticia(context, noticia);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notícia criada com sucesso!')),
        );
      } else {
        if (!mounted) return;
        // Atualizar notícia existente
        await _feedNoticiaController.updateFeedNoticia(
          context,
          widget.noticia!.id!,
          noticia,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notícia atualizada com sucesso!')),
        );
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/gestao_noticias');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar notícia: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildNoticiaImage() {
    // Priority: if a new image is chosen, show it
    if (_noticiaImage != null) {
      return Image.file(_noticiaImage!, fit: BoxFit.cover, height: 100);
    }

    // If editing and have a downloaded image, show it
    if (_downloadedNoticiaImage != null) {
      return Image.file(_downloadedNoticiaImage!,
          fit: BoxFit.cover, height: 100);
    }

    // Otherwise, no image to show
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

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
      ratio = 1.1;
    } else if (isBigScreen) {
      //tablet
      ratio = 1.4;
    } else if (isPixelScreen) {
      //pixel fold
      ratio = 1.2;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(color: Colors.white),
          CustomSemicirculo(
            height: screenHeight * 0.12,
            color: Colors.black,
          ),
          Positioned(
            top: screenHeight * 0.04,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.noticia != null ? 'Editar Notícia' : 'Criar Notícia',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.14,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: ListView(
                children: [
                  _buildTextField(
                    'Título',
                    _tituloController,
                    screenWidth,
                    scaleFactor: scaleFactor,
                    maxLength: 50,
                  ),
                  _buildTextField(
                    'Texto da notícia',
                    _textoController,
                    screenWidth,
                    scaleFactor: scaleFactor,
                    maxLength: 1000,
                    maxLines: 20,
                  ),
                  _buildImageButton(screenWidth, screenHeight, ratio),
                  Text(
                    'Tam: 100Kb a 2Mb',
                    style: TextStyle(color: Colors.grey, fontSize: 11 * ratio),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  _buildNoticiaImage() == true
                      ? const SizedBox(height: 30)
                      : const SizedBox(height: 0),
                  Center(
                    child: _buildNoticiaImage(),
                  ),
                  _buildSaveButton(screenWidth, screenHeight, scaleFactor,
                      widget.noticia != null),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildImageButton(
      double screenWidth, double screenHeight, double ratio) {
    String buttonText;

    buttonText = 'Selecionar Imagem';

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.045,
          child: ElevatedButton(
            onPressed: _showImageSourceDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade200,
              padding:
                  EdgeInsets.symmetric(horizontal: screenWidth * 0.04 * ratio),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4 * ratio),
              ),
              fixedSize: Size(ratio * 200, 600 * ratio),
            ),
            child: Text(
              buttonText,
              style: TextStyle(color: Colors.white, fontSize: 15 * ratio),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    double screenWidth, {
    int maxLines = 1,
    required double scaleFactor,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildSaveButton(double screenWidth, double screenHeight,
      double scaleFactor, bool isEditing) {
    return SizedBox(
      height: screenHeight * 0.10,
      child: Center(
        child: ElevatedButton(
          onPressed:
              _isSaving ? null : _salvarNoticia, // Desabilita enquanto salva
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSaving ? Colors.grey : Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(
                  color: Colors.white) // Indicador de carregamento
              : Text(
                  isEditing ? 'Salvar' : 'Publicar',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Voltar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _textoController.dispose();
    super.dispose();
  }
}
