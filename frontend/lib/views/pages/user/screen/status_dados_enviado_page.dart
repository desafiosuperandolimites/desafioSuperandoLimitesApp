part of '../../../env.dart';

class StatusDadosEnviadoPage extends StatefulWidget {
  final DadosEstatisticosUsuarios dadosEstatisticosUsuarios;
  final List<StatusDadosEstatisticos> statusList;
  final Evento evento;
  final Usuario usuario;

  const StatusDadosEnviadoPage({
    super.key,
    required this.dadosEstatisticosUsuarios,
    required this.statusList,
    required this.evento,
    required this.usuario,
  });

  @override
  StatusDadosEnviadoPageState createState() => StatusDadosEnviadoPageState();
}

class StatusDadosEnviadoPageState extends State<StatusDadosEnviadoPage> {
  final DadosEstatisticosUsuariosController _dadosController =
      DadosEstatisticosUsuariosController();
  final FileController _fileController =
      FileController(); // For comprovante upload/download

  bool _isLoading = false;
  late TextEditingController _kmController;
  late TextEditingController _dataController;
  String? _comprovante; // Existing filename from original data
  File? _downloadedComprovante; // Downloaded existing comprovante image
  File?
      _newComprovanteImage; // If user chooses a new image to replace the old one

  late String statusDescricao;
  bool isReadOnly = true;
  bool showObservacao = false;
  bool canEdit = false;
  bool showUploadButton = false;
  bool showCancelarButton = false;

  @override
  void initState() {
    super.initState();
    _kmController = TextEditingController(
      text: widget.dadosEstatisticosUsuarios.kmPercorrido.toString(),
    );
    _dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy')
          .format(widget.dadosEstatisticosUsuarios.dataAtividade),
    );
    _comprovante = widget.dadosEstatisticosUsuarios.foto;

    // Get status description
    StatusDadosEstatisticos status = widget.statusList.firstWhere(
      (s) => s.id == widget.dadosEstatisticosUsuarios.idStatusDadosEstatisticos,
      orElse: () => StatusDadosEstatisticos(
        id: -1,
        chaveNome: 'desconhecido',
        situacao: false,
        descricao: 'Desconhecido',
      ),
    );
    statusDescricao = status.descricao;

    // Adjust UI based on status
    if (statusDescricao == 'Pendente de Correção') {
      isReadOnly = false;
      showObservacao = true;
      canEdit = true;
      showUploadButton = true;
    } else if (statusDescricao == 'Cancelado') {
      isReadOnly = true;
      showObservacao = true;
      canEdit = false;
    } else {
      isReadOnly = true;
      showCancelarButton = true;
      canEdit = false;
    }

    _loadComprovante();
  }

  Future<void> _loadComprovante() async {
    final foto = widget.dadosEstatisticosUsuarios.foto;
    if (foto != null && foto.isNotEmpty) {
      try {
        await _fileController.downloadFileComprovantesKm(foto);
        setState(() {
          _downloadedComprovante = _fileController.downloadedFile;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao baixar comprovante km: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _kmController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _showFullScreenPhoto() {
    if (_downloadedComprovante == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Image.file(
                  _downloadedComprovante!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectComprovante() async {
    final action = await showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Center(
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
            child: Row(
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
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: Row(
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

    if (action != null) {
      await _pickComprovanteImage(action);
    }
  }

  Future<void> _pickComprovanteImage(ImageSource source) async {
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
        _newComprovanteImage = File(pickedFile.path);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comprovante selecionado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = screenHeight < 668 ? 0.85 : 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.14,
                    child: Stack(
                      children: [
                        _buildHeaderBackground(screenHeight),
                        _buildHeaderTitle(textScaleFactor, screenHeight),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPhoto(),
                  const SizedBox(height: 20),
                  if (showUploadButton) _buildComprovanteButton(),
                  if (showUploadButton) const SizedBox(height: 20),
                  _buildDataFields(),
                  if (showCancelarButton) const SizedBox(height: 20),
                  if (showCancelarButton) _buildCancelarButton(),
                  if (canEdit) const SizedBox(height: 40),
                  if (canEdit) _buildActionButtons(),
                  SizedBox(height: canEdit ? 100 : 200),
                  _buildBackButton(),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context, true);
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

  Widget _buildHeaderBackground(double screenHeight) {
    return CustomSemicirculo(
      height: screenHeight * 0.12,
      color: const Color(0xFFFF7801),
    );
  }

  Widget _buildHeaderTitle(double textScaleFactor, double screenHeight) {
    return Positioned(
      height: screenHeight * 0.12,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          statusDescricao,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildComprovanteButton() {
    String buttonText;
    if (_newComprovanteImage != null) {
      buttonText =
          'Nova foto selecionada: ${_newComprovanteImage!.path.split('/').last}';
    } else {
      buttonText = 'Upload de nova foto';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: _selectComprovante,
        icon: const Icon(Icons.file_upload, color: Colors.white),
        label: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    Widget displayWidget;

    if (_newComprovanteImage != null) {
      // If a new image is chosen, display it
      displayWidget = GestureDetector(
        onTap: _showFullScreenPhotoNew,
        child: Stack(
          children: [
            Image.file(
              _newComprovanteImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Icon(Icons.zoom_in, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    } else if (_downloadedComprovante != null) {
      // If no new image chosen but old image exists
      displayWidget = GestureDetector(
        onTap: _showFullScreenPhoto,
        child: Stack(
          children: [
            Image.file(
              _downloadedComprovante!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Icon(Icons.zoom_in, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    } else {
      // No image at all
      displayWidget = Center(
        child: Text(
          'Foto da Atividade',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: displayWidget,
          ),
          const SizedBox(height: 10),
          if (statusDescricao != 'Pendente de Aprovação' &&
              statusDescricao != 'Cancelado')
            _buildApprovalIcons(),
        ],
      ),
    );
  }

  void _showFullScreenPhotoNew() {
    // For the new image chosen
    if (_newComprovanteImage == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Image.file(
                  _newComprovanteImage!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApprovalIcons() {
    return Icon(
      canEdit ? Icons.thumb_down : Icons.thumb_up,
      color: canEdit ? Colors.red : Colors.green,
    );
  }

  Widget _buildDataFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _kmController,
                  decoration: InputDecoration(
                    labelText: 'KM Percorrido',
                    labelStyle:
                        TextStyle(color: Colors.grey[500], fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                  ),
                  readOnly: isReadOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _dataController,
                  decoration: InputDecoration(
                    labelText: 'Data da Atividade',
                    labelStyle:
                        TextStyle(color: Colors.grey[500], fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                  ),
                  readOnly: true,
                  onTap: canEdit ? _selectDate : null,
                ),
              ),
            ],
          ),
          if (showObservacao)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextFormField(
                initialValue: widget.dadosEstatisticosUsuarios.observacao,
                decoration: InputDecoration(
                  labelText: 'Observação',
                  labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 1),
                  ),
                ),
                readOnly: true,
                maxLines: 3,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _parseDate(_formatDateString(widget.evento.dataInicioEvento)),
      lastDate: _parseDate(_formatDateString(widget.evento.dataFimEvento)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7801),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        _dataController.text = formattedDate;
      });
    }
  }

  String _formatDateString(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return ''; // Return an empty string if parsing fails
    }
  }

  DateTime _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Handle parsing error
    }
    throw FormatException('Invalid date format: $date');
  }

  Widget _buildCancelarButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: _cancelarData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        label: const Text(
          'Cancelar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16, // Tamanho do texto padrão
          ),
        ),
      ),
    );
  }

  Future<void> _cancelarData() async {
    MotivoRejeicaoOverlay.show(context, (observacao) async {
      if (observacao.isNotEmpty) {
        await _confirmarCancelamento(observacao);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, insira o motivo do seu cancelamento.')),
        );
      }
    });
  }

  Future<void> _confirmarCancelamento(String observacao) async {
    try {
      await _dadosController.cancelarDadosEstatisticos(
        widget.dadosEstatisticosUsuarios.id,
        observacao,
      );

      if (!mounted) return;

      SalvoSucessoSnackBar.show(context,
          message: 'Dados cancelados com sucesso!');

      Navigator.pop(context, true); // Return to previous page and refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao rejeitar dados: $e')),
      );
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: _resubmitData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: const Text(
          'Enviar para Revisão',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _resubmitData() async {
    // Validate inputs
    String kmText = _kmController.text.trim();
    String dataText = _dataController.text.trim();

    // If user hasn't chosen a new image and we had no original image
    // we must have at least one image
    if (_newComprovanteImage == null &&
        (_comprovante == null || _comprovante!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, adicione uma foto como comprovante.')),
      );
      return;
    }

    if (kmText.isEmpty || dataText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    double? kmValue = double.tryParse(kmText.replaceAll(',', '.'));
    if (kmValue == null || kmValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira um valor válido para KM.')),
      );
      return;
    }

    DateTime dataAtividade = DateFormat('dd/MM/yyyy').parse(dataText);

    setState(() {
      _isLoading = true;
    });

    String fotoToSend;
    if (_newComprovanteImage != null) {
      // User picked a new image, upload it
      try {
        await _fileController.uploadFileComprovantesKm(_newComprovanteImage);
        fotoToSend = _newComprovanteImage!.path.split('/').last;
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar imagem: $e')),
        );
        return;
      }
    } else {
      // No new image, use the existing one
      fotoToSend = _comprovante ?? '';
    }

    await _dadosController.editarDadosEstatisticos(
      id: widget.dadosEstatisticosUsuarios.id,
      idUsuarioInscrito: widget.usuario.id,
      kmPercorrido: kmValue,
      dataAtividade: dataAtividade,
      foto: fotoToSend,
    );

    if (!mounted) return;

    SalvoSucessoSnackBar.show(context, message: 'Enviado para revisão!');

    Navigator.pop(context, true);

    setState(() {
      _kmController.clear();
      _dataController.clear();
      _comprovante = null;
      _newComprovanteImage = null;
      _isLoading = false;
    });
  }
}
