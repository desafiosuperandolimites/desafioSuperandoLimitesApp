part of '../../../env.dart';

class PagamentoPage extends StatefulWidget {
  final int inscricaoEventoId;
  final int pagamentoId; // Adicione este parâmetro

  const PagamentoPage(
      {super.key, required this.inscricaoEventoId, required this.pagamentoId});

  @override
  PagamentoPageState createState() => PagamentoPageState();
}

class PagamentoPageState extends State<PagamentoPage>
    with SingleTickerProviderStateMixin {
  DadosBancarios? _dadosBancarios;
  double? valorEvento;
  bool _isLoading = true;
  String? _nomeBanco;
  InscricaoEvento? _inscricaoEvento;
  Usuario? _usuario;
  PagamentoInscricao? _pagamentoInscricao;

  final DadosBancariosController _dadosBancariosController =
      DadosBancariosController();
  final EventoController _eventoController = EventoController();
  final InscricaoController _inscricaoController = InscricaoController();
  final PagamentoInscricaoController _pagamentoInscricaoController =
      PagamentoInscricaoController();
  final UserController _userController = UserController();

  // New variables for comprovante logic
  final FileController _fileController = FileController();
  File? _comprovanteImage; // Image selected by user
  File? downloadedComprovante; // Image downloaded from storage
  String? _comprovanteFileName;
  final ImagePicker _picker = ImagePicker();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadDados();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadComprovanteImage();
  }

  Future<void> _loadDados() async {
    await Future.wait([
      _loadDadosBancarios(),
      _loadInscricaoEvento(),
      _loadPagamentoEvento(),
    ]);

    if (_inscricaoEvento != null) {
      await _loadValorEvento();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDadosBancarios() async {
    await _dadosBancariosController.fetchDadosBancariosByUsuario(1);
    setState(() {
      _dadosBancarios = _dadosBancariosController.dadosBancarios;
    });

    String? codigoBanco = _dadosBancarios?.banco;
    if (codigoBanco != null) {
      String? nomeBanco = await getNomeBancoLocal(codigoBanco);
      if (nomeBanco == 'Banco não encontrado') {
        nomeBanco = await getNomeBanco(codigoBanco);
      }
      setState(() {
        _nomeBanco = nomeBanco;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      await _userController.fetchCurrentUser();
      setState(() {
        _usuario = _userController.user;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar dados do usuário: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados do usuário.')),
      );
    }
  }

  Future<void> _loadInscricaoEvento() async {
    await _inscricaoController.fetchInscricaoById(widget.inscricaoEventoId);
    setState(() {
      _inscricaoEvento = _inscricaoController.inscricao;
    });
  }

  Future<void> _loadPagamentoEvento() async {
    await _pagamentoInscricaoController
        .fetchPagamentoInscricaoById(widget.pagamentoId);
    setState(() {
      _pagamentoInscricao = _pagamentoInscricaoController.selectedPagamento;
    });
  }

  Future<void> _loadValorEvento() async {
    if (_inscricaoEvento != null) {
      int eventoId = _inscricaoEvento!.idEvento;
      await _eventoController.fetchEventoById(eventoId);
      setState(() {
        valorEvento = _eventoController.evento?.valorEvento;
      });
    }
  }

  // Load existing comprovante image if available
  Future<void> _loadComprovanteImage() async {
    // Suppose the comprovante filename is stored in the pagamento record
    final pagamento = _pagamentoInscricao;
    if (pagamento != null && pagamento.comprovante.isNotEmpty) {
      _comprovanteFileName = pagamento.comprovante;
      await _fileController
          .downloadFileComprovantesPagamento(_comprovanteFileName!);
      setState(() {
        downloadedComprovante = _fileController.downloadedFile;
      });
    }
  }

  Widget _buildBackButton() {
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

  Widget _buildTipoContaWidget() {
    return const Row(
      children: [
        Text(
          'Tipo de Conta:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Conta Corrente',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 668;

    double textScaleFactor = isSmallScreen ? 0.85 : 1.2;
    double iconScaleFactor = isSmallScreen ? 0.8 : 1.0;
    double buttonScaleFactor = isSmallScreen ? 0.8 : 1.0;
    double semicircleHeight =
        isSmallScreen ? screenHeight * 0.12 : screenHeight * 0.15;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.14,
              child: Stack(
                children: [
                  CustomSemicirculo(
                    height: semicircleHeight,
                    color: const Color(0xFFFF7801),
                  ),
                  Positioned(
                    top: screenHeight * 0.04,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Pagamento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Escolha o tipo de pagamento:',
              style: TextStyle(
                fontSize: 16 * textScaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.0 * buttonScaleFactor),
              child: TabContainer(
                controller: _tabController,
                tabEdge: TabEdge.top,
                tabsStart: 0,
                tabsEnd: 1,
                borderRadius: BorderRadius.circular(1 * buttonScaleFactor),
                tabBorderRadius: BorderRadius.circular(10 * buttonScaleFactor),
                childPadding: EdgeInsets.all(20 * buttonScaleFactor),
                selectedTextStyle: TextStyle(
                  color: const Color(0xFFFF7801),
                  fontSize: 15.0 * textScaleFactor,
                ),
                unselectedTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 15 * textScaleFactor,
                ),
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade300,
                ],
                tabs: [
                  Text(
                    'Transferência',
                    style: TextStyle(fontSize: 15 * textScaleFactor),
                  ),
                  Text(
                    'PIX',
                    style: TextStyle(fontSize: 15 * textScaleFactor),
                  ),
                ],
                children: [
                  _buildTransferenciaBancariaOption(
                      textScaleFactor, iconScaleFactor, buttonScaleFactor),
                  _buildPixOption(
                      textScaleFactor, iconScaleFactor, buttonScaleFactor),
                ],
              ),
            ),
            _buildBackButton(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildTransferenciaBancariaOption(double textScaleFactor,
      double iconScaleFactor, double buttonScaleFactor) {
    String contaFormatada = _dadosBancarios?.conta ?? 'N/A';
    if (contaFormatada.length > 1) {
      final digitoConta = contaFormatada[contaFormatada.length - 1];
      final numeroConta =
          contaFormatada.substring(0, contaFormatada.length - 1);
      contaFormatada = '$numeroConta-$digitoConta';
    }

    return _dadosBancarios != null
        ? Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.symmetric(
                horizontal: 16 * buttonScaleFactor, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance,
                  size: 100 * iconScaleFactor,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                Text(
                  'Transferência Bancária',
                  style: TextStyle(
                    fontSize: 16 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Valor R\$ ${valorEvento?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(fontSize: 18 * textScaleFactor),
                ),
                const SizedBox(height: 40),
                _buildTipoContaWidget(),
                const SizedBox(height: 8),
                _buildCopyableRow(
                    context, 'Agência', _dadosBancarios?.agencia ?? 'N/A'),
                const SizedBox(height: 8),
                _buildCopyableRow(context, 'Conta', contaFormatada),
                const SizedBox(height: 8),
                _buildNonCopyableRow(
                    'Titular', _dadosBancarios?.titular ?? 'N/A'),
                const SizedBox(height: 8),
                _buildNonCopyableRow('Banco', _nomeBanco ?? 'Carregando...'),
                const SizedBox(height: 104),
                _buildEnviarComprovanteButton(buttonScaleFactor),
                const SizedBox(height: 10),
                _buildComprovanteSection(textScaleFactor, buttonScaleFactor),
                _buildTamanhoImagem(buttonScaleFactor),
              ],
            ),
          )
        : const Center(child: Text('Erro ao carregar dados bancários.'));
  }

  Widget _buildPixOption(double textScaleFactor, double iconScaleFactor,
      double buttonScaleFactor) {
    String pixCode = '';
    if (_dadosBancarios != null && valorEvento != null) {
      String pixKey = _dadosBancarios!.pix ?? '';

      if (pixKey.contains(RegExp(r'^\d{11}$')) ||
          pixKey.contains(RegExp(r'^\d{14}$'))) {
        pixKey = pixKey.replaceAll(RegExp(r'\D'), '');
      }

      PixFlutter pixFlutter = PixFlutter(
        payload: Payload(
          pixKey: pixKey,
          description: 'Pagamento de Evento',
          merchantName: _dadosBancarios!.titular,
          merchantCity: 'Brasilia',
          txid: '12345678901234567890',
          amount: valorEvento!.toStringAsFixed(2),
        ),
      );

      pixCode = pixFlutter.getQRCode();
    }

    return _dadosBancarios?.pix != null
        ? Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.symmetric(
                horizontal: 16 * buttonScaleFactor, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.pix,
                    size: 100 * iconScaleFactor, color: Colors.green),
                const SizedBox(height: 10),
                Text(
                  'Transferência Via PIX',
                  style: TextStyle(
                    fontSize: 16 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Valor R\$ ${valorEvento?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(fontSize: 18 * textScaleFactor),
                ),
                const SizedBox(height: 10),
                QrImageView(data: pixCode, size: 150.0),
                const SizedBox(height: 10),
                _buildCopyableRow(
                    context, 'Chave Pix', _dadosBancarios?.pix ?? 'N/A'),
                const SizedBox(height: 8),
                _buildNonCopyableRow(
                    'Titular', _dadosBancarios?.titular ?? 'N/A'),
                const SizedBox(height: 8),
                _buildNonCopyableRow('Banco', _nomeBanco ?? 'Carregando...'),
                const SizedBox(height: 30),
                _buildEnviarComprovanteButton(buttonScaleFactor),
                _buildTamanhoImagem(buttonScaleFactor),
                const SizedBox(height: 10),
                _buildComprovanteSection(textScaleFactor, buttonScaleFactor),
              ],
            ),
          )
        : const Center(child: Text('Erro ao carregar dados do Pix.'));
  }

// Show and edit the comprovante section
  Widget _buildComprovanteSection(
      double textScaleFactor, double buttonScaleFactor) {
    bool isButtonEnabled = _comprovanteImage != null;
    return Column(
      children: [
        const SizedBox(height: 10),
        /*Container(
          width: 100 * buttonScaleFactor,
          height: 100 * buttonScaleFactor,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: const Color(0xFF24A749),
              width: 2.0 * buttonScaleFactor,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: _buildComprovanteImage(),
          ),
        ),*/
        SizedBox(height: 2 * buttonScaleFactor),
        ElevatedButton.icon(
          onPressed: isButtonEnabled
              ? () async {
                  await _enviarComprovante();
                }
              : null,
          label: Text(
            'ENVIAR',
            style: TextStyle(
                color: Colors.white, fontSize: 16 * buttonScaleFactor),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isButtonEnabled ? Colors.green : Colors.grey.shade400,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24 * buttonScaleFactor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8 * buttonScaleFactor),
            ),
          ),
        ),
      ],
    );
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

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        // Just set the image locally. Do not upload yet.
        _comprovanteImage = File(pickedFile.path);
      });
    }
  }

// "Enviar Comprovante" only enabled if a new image is selected
  Widget _buildEnviarComprovanteButton(double buttonScaleFactor) {
    String buttonText;
    if (_comprovanteImage != null) {
      buttonText =
          'Foto selecionada: ${_comprovanteImage!.path.split('/').last}';
    } else {
      buttonText = 'Enviar comprovante';
    }
    return Padding(
      padding: EdgeInsets.only(top: 20 * buttonScaleFactor),
      child: ElevatedButton.icon(
        onPressed: () async {
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
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.camera),
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
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.gallery),
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

          if (action != null) {
            await _pickComprovanteImage(action);
          }
        },
        label: Text(
          buttonText,
          style:
              TextStyle(color: Colors.white, fontSize: 16 * buttonScaleFactor),
        ),
        icon: Icon(
          Icons.file_upload,
          size: 16 * buttonScaleFactor,
          color: const Color.fromARGB(255, 252, 252, 252),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade600,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24 * buttonScaleFactor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * buttonScaleFactor),
          ),
        ),
      ),
    );
  }

  Future<void> _enviarComprovante() async {
    if (_comprovanteImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nenhum comprovante selecionado para enviar.')),
      );
      return;
    }

    try {
      // Now upload and update backend on send
      await _fileController.uploadFileComprovantePagamento(_comprovanteImage);
      String newComprovanteFilename = _comprovanteImage!.path.split('/').last;

      // Update pagamento
      int pagamentoId = widget.pagamentoId;
      if (!mounted) return;
      await _pagamentoInscricaoController.updatePagamentoInscricao(
        context,
        pagamentoId,
        PagamentoInscricao(
          id: pagamentoId,
          idUsuario: _usuario!.id,
          idStatusPagamento: 6,
          idInscricaoEvento: widget.inscricaoEventoId,
          idDadosBancariosAdm: _dadosBancarios?.id ?? 0,
          comprovante: newComprovanteFilename,
          dataPagamento: DateTime.now(),
        ),
      );

      if (!mounted) return;

      // Update inscrição do evento
      await InscricaoController().atualizarInscricao(
        context,
        _inscricaoEvento!.id!,
        InscricaoEvento(
          idUsuario: _inscricaoEvento!.idUsuario,
          idCategoriaBicicleta: _inscricaoEvento!.idCategoriaBicicleta,
          idCategoriaCaminhadaCorrida:
              _inscricaoEvento!.idCategoriaCaminhadaCorrida,
          idStatusInscricaoTipo: 2,
          idEvento: _inscricaoEvento!.idEvento,
          meta: _inscricaoEvento!.meta,
          medalhaEntregue: false,
          termoCiente: _inscricaoEvento!.termoCiente,
          criadoEm: _inscricaoEvento!.criadoEm,
          atualizadoEm: _inscricaoEvento!.atualizadoEm,
        ),
      );

      // Refresh the local downloaded image
      _comprovanteFileName = newComprovanteFilename;
      await _fileController
          .downloadFileComprovantesPagamento(_comprovanteFileName!);
      setState(() {
        downloadedComprovante = _fileController.downloadedFile;
        _comprovanteImage =
            null; // Reset the chosen image after successful upload
      });

      // Navigate to next page
      final EventoController eventoController = EventoController();
      await eventoController.fetchEventoById(_inscricaoEvento!.idEvento);
      final Evento? evento = eventoController.evento;

      if (!mounted) return;

      if (evento != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeuDesafioPage(
              evento: evento,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao carregar informações do evento.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar comprovante: $e')),
      );
    }
  }

  Widget _buildTamanhoImagem(double buttonScaleFactor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 12.0 * buttonScaleFactor),
        child: const Text(
          '.jpg .png (Max.: 5Mb)',
          style: TextStyle(
              color: Color.fromARGB(255, 151, 151, 151), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCopyableRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
        SizedBox(
          height: 20,
          width: 20,
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value)).then((_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copiado!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            },
            child: const Icon(
              Icons.copy,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNonCopyableRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
