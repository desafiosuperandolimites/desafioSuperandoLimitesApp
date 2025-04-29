part of '../../../env.dart';

class MinhaInscricaoPage extends StatefulWidget {
  final Usuario usuario;
  final Evento evento;
  final InscricaoEvento inscricao;

  const MinhaInscricaoPage({
    super.key,
    required this.usuario,
    required this.evento,
    required this.inscricao,
  });

  @override
  MinhaInscricaoPageState createState() => MinhaInscricaoPageState();
}

class MinhaInscricaoPageState extends State<MinhaInscricaoPage> {
  Premiacao? _premiacao;
  bool hasPhoto = true;
  bool _isLoading = true;
  int? idPagamento;
  List<Grupo> grupos = [];
  List<PagamentoInscricao> pagamentos = [];
  String statusInscricaoText = '';
  late bool observacao = false;
  PagamentoInscricao? pagamento;

  // For image handling
  final FileController _fileController = FileController();
  File? _downloadedComprovante; // Comprovante image
  String? _comprovanteFileName;

  File? _downloadedEventoImage; // Downloaded event image

  final PagamentoInscricaoController _pagamentoController =
      PagamentoInscricaoController();
  final PremiacaoController _premiacaoController = PremiacaoController();
  final GrupoController _grupoController = GrupoController();
  final PagamentoInscricaoController _pagamentoInscricaoController =
      PagamentoInscricaoController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadPremiacaoData(widget.evento.idPremiacaoEvento);
    await _loadGruposFromBackend();
    await _loadPagamentoForInscricao(widget.inscricao.id!);
    await _loadPagamentosFromBackend();
    await _loadEventoImage(); // Download the event image if available
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadEventoImage() async {
    // Download event image if capaEvento is available
    if (widget.evento.capaEvento != null &&
        widget.evento.capaEvento!.isNotEmpty) {
      try {
        await _fileController
            .downloadFileCapasEvento(widget.evento.capaEvento!);
        _downloadedEventoImage = _fileController.downloadedFile;
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao baixar imagem do evento: $e');
        }
        _downloadedEventoImage = null;
      }
    }
  }

  void _atualizarCancelamentoAutomaticoNoFront() {
    final DateTime currentDate = DateTime.now();
    final DateTime? dataFimInscricao =
        parseDate(widget.evento.dataFimInscricoes);

    if (dataFimInscricao != null &&
        (widget.inscricao.idStatusInscricaoTipo == 1 ||
            widget.inscricao.idStatusInscricaoTipo == 4) &&
        currentDate.isAfter(dataFimInscricao)) {
      statusInscricaoText = 'Cancelado';
      _verificarCancelamentoAutomatico();
    }
  }

  Future<void> _verificarCancelamentoAutomatico() async {
    final DateTime currentDate = DateTime.now();
    final DateTime? dataFimInscricao =
        parseDate(widget.evento.dataFimInscricoes);

    if (dataFimInscricao != null &&
        (widget.inscricao.idStatusInscricaoTipo == 1 ||
            widget.inscricao.idStatusInscricaoTipo == 4) &&
        currentDate.isAfter(dataFimInscricao)) {
      await InscricaoController().atualizarInscricao(
        context,
        widget.inscricao.id!,
        InscricaoEvento(
          idUsuario: widget.inscricao.idUsuario,
          idCategoriaBicicleta: widget.inscricao.idCategoriaBicicleta,
          idCategoriaCaminhadaCorrida:
              widget.inscricao.idCategoriaCaminhadaCorrida,
          idStatusInscricaoTipo: 5,
          idEvento: widget.inscricao.idEvento,
          meta: widget.inscricao.meta,
          medalhaEntregue: false,
          termoCiente: widget.inscricao.termoCiente,
          criadoEm: widget.inscricao.criadoEm,
          atualizadoEm: widget.inscricao.atualizadoEm,
        ),
      );
      setState(() {
        statusInscricaoText = 'Cancelado';
      });
    }
  }

  // Obtém nome da modalidade com base no ID.
  String getModalidadeName(int? idModalidadeEvento) {
    if (idModalidadeEvento == null) return 'Modalidade não informada';

    switch (idModalidadeEvento) {
      case 1:
        return 'Bicicleta';
      case 2:
        return 'Corrida';
      case 3:
        return 'Caminhada';
      default:
        return 'Modalidade desconhecida';
    }
  }

  Future<void> _loadPagamentosFromBackend() async {
    try {
      await _pagamentoController.fetchPagamentosInscricoes();
      setState(() {
        pagamentos = _pagamentoController.pagamentoList;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar pagamentos: $e');
      }
    }
  }

  Future<void> _loadPagamentoForInscricao(int idInscricao) async {
    try {
      await _pagamentoInscricaoController.fetchPagamentosInscricoes();
      pagamento = _pagamentoInscricaoController.pagamentoList
          .firstWhere((p) => p.idInscricaoEvento == idInscricao);
      _comprovanteFileName = pagamento?.comprovante;
      if (_comprovanteFileName != null && _comprovanteFileName!.isNotEmpty) {
        await _fileController
            .downloadFileComprovantesPagamento(_comprovanteFileName!);
        setState(() {
          _downloadedComprovante = _fileController.downloadedFile;
        });
      }
      setState(() {
        idPagamento = pagamento?.id;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar pagamento para inscrição: $e');
      }
    }
  }

  Future<void> _loadPremiacaoData(int? idPremiacao) async {
    if (idPremiacao == null) return;
    try {
      await _premiacaoController.fetchPremiacaoById(idPremiacao);
      setState(() {
        _premiacao = _premiacaoController.selectedPremiacao;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados da premiação.')),
      );
    }
  }

  Future<void> _loadGruposFromBackend() async {
    try {
      await _grupoController.fetchGrupos();
      setState(() {
        grupos = _grupoController.groupList;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar grupos: $e');
      }
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getGrupoName(int? idGrupoEvento) {
    if (idGrupoEvento == null) return 'Grupo não foi informado';
    final grupo = grupos.firstWhere(
      (g) => g.id == idGrupoEvento,
      orElse: () => Grupo(
          id: 0, nome: 'Desconhecido', cnpj: '00000000000000', situacao: false),
    );
    return grupo.nome;
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

  Widget _buildPhoto(InscricaoEvento inscricaoEvento) {
    bool isentoPagamento = widget.evento.isentoPagamento;

    if (isentoPagamento ||
        (inscricaoEvento.idStatusInscricaoTipo == 1 ||
            inscricaoEvento.idStatusInscricaoTipo == 3 ||
            inscricaoEvento.idStatusInscricaoTipo == 5)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: _showFullScreenPhoto,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: hasPhoto
                  ? Center(
                      child: _downloadedComprovante != null
                          ? Image.file(
                              _downloadedComprovante!,
                              fit: BoxFit.fill,
                            )
                          : Text('Nenhuma foto disponível',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[700])),
                    )
                  : Center(
                      child: Text('Nenhuma foto disponível',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey[700]))),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Icon(Icons.zoom_in, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenHeight) {
    return Stack(
      children: [
        CustomSemicirculo(
            height: screenHeight * 0.12, color: const Color(0xFFFF7801)),
        Positioned(
          top: screenHeight * 0.04,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Minha Inscriação',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventImage(double screenHeight) {
    Widget eventImage;
    if (_downloadedEventoImage != null) {
      eventImage = Image.file(
        _downloadedEventoImage!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      eventImage = Image.asset(
        widget.evento.capaEvento ?? 'assets/image/foto01.jpg',
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: eventImage,
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(widget.evento.nome,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          _buildDetailText('Descrição:', widget.evento.descricao),
          _buildDetailText('Premiação:', _premiacao?.nome ?? 'N/A'),
          _buildDetailText('Local:', widget.evento.local),
          _buildDetailText(
              'Valor:',
              widget.evento.isentoPagamento
                  ? 'Isento'
                  : 'R\$ ${widget.evento.valorEvento}'),
          _buildDetailText(
            'Período de Inscrição:',
            '${formatDate(parseDate(widget.evento.dataInicioInscricoes))} a ${formatDate(parseDate(widget.evento.dataFimInscricoes))}',
          ),
          _buildDetailText(
            'Duração do Evento:',
            '${formatDate(parseDate(widget.evento.dataInicioEvento))} a ${formatDate(parseDate(widget.evento.dataFimEvento))}',
          ),
          _buildDetailText(
              'Data da Inscrição:', formatDate(widget.inscricao.criadoEm)),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const SizedBox(height: 16),
          _buildDetailText('Nome: ', widget.usuario.nome),
          _buildDetailText(
              'Grupo: ', getGrupoName(widget.usuario.idGrupoEvento)),
          const SizedBox(height: 2),
          _buildDetailText(
              'Modalidade:',
              widget.inscricao.idCategoriaBicicleta != null
                  ? 'Bicicleta'
                  : 'Caminhada/Corrida'),
          _buildDetailText('Meta:', '${widget.inscricao.meta} km'),
          _buildDetailText(
              'Telefone: ', widget.usuario.celular ?? 'Não disponível'),
          const SizedBox(height: 2),
          _buildDetailText('E-mail: ', widget.usuario.email),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14),
        children: [
          TextSpan(
              text: '$label ', style: const TextStyle(color: Colors.black)),
          TextSpan(text: value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButton(double screenWidth, double screenHeight) {
    switch (widget.inscricao.idStatusInscricaoTipo) {
      case 1:
        statusInscricaoText = 'Pendente de Pagamento';
        break;
      case 2:
        statusInscricaoText = 'Pendente de Aprovação';
        break;
      case 3:
        statusInscricaoText = 'Paga';
        break;
      case 4:
        statusInscricaoText = 'Aguardando Revisão';
        observacao = true;
        break;
      case 5:
        statusInscricaoText = 'Cancelado';
        break;
      case 6:
        statusInscricaoText = 'Movido do Grupo';
        break;
      case 7:
        statusInscricaoText = 'Isento';
        break;
      default:
        statusInscricaoText = 'Desconhecido';
        break;
    }
    _atualizarCancelamentoAutomaticoNoFront();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Situação da Inscrição:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0))),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text(statusInscricaoText,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white)),
                ],
              ),
            ),
            if (observacao)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  initialValue: pagamento?.motivo,
                  decoration: InputDecoration(
                    labelText: 'Observação',
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
                  maxLines: 3,
                ),
              ),
            if (statusInscricaoText == 'Pendente de Pagamento' ||
                statusInscricaoText == 'Aguardando Revisão')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: _navigateToPayments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    fixedSize: Size(screenWidth * 0.40, screenHeight * 0.045),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: const Text('Ir para pagamento',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Voltar',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }

  void _navigateToPayments() {
    if (widget.inscricao.id != null && idPagamento != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PagamentoPage(
            inscricaoEventoId: widget.inscricao.id!,
            pagamentoId: idPagamento!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erro: ID da inscrição ou do pagamento não encontrado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildHeader(screenHeight),
                Column(
                  children: [
                    SizedBox(height: screenHeight * 0.14),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEventImage(screenHeight),
                            _buildEventDetails(),
                            const SizedBox(height: 16),
                            _buildActionButton(screenWidth, screenHeight),
                            const SizedBox(height: 16),
                            _buildPhoto(widget.inscricao),
                            _buildPaymentStatus(),
                          ],
                        ),
                      ),
                    ),
                    _buildBackButton(),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}
