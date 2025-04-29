part of '../../../env.dart';

class EnviarDadosPage extends StatefulWidget {
  final Evento evento;
  final Usuario usuario;
  const EnviarDadosPage({
    super.key,
    required this.evento,
    required this.usuario,
  });

  @override
  EnviarDadosPageState createState() => EnviarDadosPageState();
}

class EnviarDadosPageState extends State<EnviarDadosPage> {
  final DadosEstatisticosUsuariosController _dadosController =
      DadosEstatisticosUsuariosController();
  final MaskedTextController _kmController = Mascaras.kmPercorrido();
  final TextEditingController _dataController = TextEditingController();
  final FileController _fileController = FileController();

  File? _comprovanteImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _kmController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _sendData() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    String kmText = _kmController.text.trim();
    String dataText = _dataController.text.trim();

    if (_comprovanteImage == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, adicione uma foto como comprovante.')),
      );
      return;
    }

    if (kmText.isEmpty || dataText.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    double? kmValue = double.tryParse(kmText.replaceAll(',', '.'));
    if (kmValue == null || kmValue <= 0) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira um valor válido para KM.')),
      );
      return;
    }

    DateTime dataAtividade = DateFormat('dd/MM/yyyy').parse(dataText);

    // First upload the image
    try {
      await _fileController.uploadFileComprovantesKm(_comprovanteImage);
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar imagem: $e')),
      );
      return;
    }

    // The filename after upload
    String newComprovanteFilename = _comprovanteImage!.path.split('/').last;

    try {
      await _dadosController.adicionarDadosEstatisticos(
        idUsuarioInscrito: widget.usuario.id,
        idUsuarioCadastra: widget.usuario.id,
        idEvento: widget.evento.id!,
        kmPercorrido: kmValue,
        dataAtividade: dataAtividade,
        foto: newComprovanteFilename,
      );

      if (!mounted) return;
      SalvoSucessoSnackBar.show(context,
          message: 'Dados enviados com sucesso!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AcompanharDadosPage(
              evento: widget.evento, usuario: widget.usuario),
        ),
      );

      setState(() {
        _kmController.clear();
        _dataController.clear();
        _comprovanteImage = null;
        _isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar dados: $e')),
      );
    }
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
        _comprovanteImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _parseDate(_formatDateString(widget.evento.dataInicioEvento)),
      lastDate: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = screenHeight < 668 ? 0.85 : 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 20),
            _buildComprovanteButton(),
            const SizedBox(height: 40),
            _buildDataFields(),
            const SizedBox(height: 40),
            _buildActionButtons(),
            SizedBox(height: screenHeight * 0.4),
            const CustomButtonVoltar(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
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
          'Enviar Dados',
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
    if (_comprovanteImage != null) {
      buttonText =
          'Foto selecionada: ${_comprovanteImage!.path.split('/').last}';
    } else {
      buttonText = 'Upload de foto';
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
            fontSize: 16, // Tamanho do texto padrão
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildDataFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // KM Percorrido Field
          Expanded(
            child: TextFormField(
              controller: _kmController,
              decoration: InputDecoration(
                labelText: 'Km Percorrido Ex.: 00.00',
                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal:
                      true), // Verificar se vai ser readOnly ou usar variável isReadOnly para o admin poder editar o campo de KM
            ),
          ),
          const SizedBox(width: 16),
          // Data Atividade Field
          Expanded(
            child: TextFormField(
              controller: _dataController,
              decoration: InputDecoration(
                labelText: 'Data',
                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
                suffixIcon: Icon(Icons.calendar_today,
                    color: Colors.grey.withOpacity(0.5)),
              ),
              onTap: _selectDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Enviar Button
          CustomButtonSalvar(
            onSave: _sendData,
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Enviar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
