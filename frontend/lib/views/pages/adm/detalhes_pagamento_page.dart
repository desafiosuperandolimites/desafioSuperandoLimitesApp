part of '../../env.dart';

class DetalhesPagamento extends StatefulWidget {
  final Usuario usuario;
  final PagamentoInscricao pagamento;
  final Evento evento;
  final InscricaoEvento inscricao;
  final Grupo grupo;

  const DetalhesPagamento({
    super.key,
    required this.usuario,
    required this.pagamento,
    required this.evento,
    required this.inscricao,
    required this.grupo,
  });

  @override
  DetalhesPagamentoState createState() => DetalhesPagamentoState();
}

DateTime? parseDate(dynamic date) {
  if (date is String) {
    return DateTime.tryParse(date);
  } else if (date is DateTime) {
    return date;
  }
  return null;
}

class DetalhesPagamentoState extends State<DetalhesPagamento> {
  final FileController _fileController = FileController();

  bool _isLoading = false;
  bool hasPhoto = true;
  String? _cancelMessage;
  File? _downloadedComprovante;
  String? _comprovanteFileName;
  List<Grupo> grupos = [];

  late TextEditingController _motivoController;
  late String? motivo = widget.pagamento.motivo;

  final PremiacaoController _premiacaoController = PremiacaoController();
  Premiacao? _premiacao;
  final GrupoController _grupoController = GrupoController();

  @override
  void initState() {
    super.initState();
    _motivoController = TextEditingController();
    _loadComprovante();
    _loadPremiacaoData(widget.evento.idPremiacaoEvento);
    _loadGruposFromBackend();

    // Verifica e atualiza automaticamente o status do pagamento ao construir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndUpdatePaymentStatus(motivo);
    });
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  // Carrega o comprovante do pagamento
  void _loadComprovante() async {
    _comprovanteFileName = widget.pagamento.comprovante;
    await _fileController
        .downloadFileComprovantesPagamento(_comprovanteFileName);
    setState(() {
      _downloadedComprovante = _fileController.downloadedFile;
    });
  }

  void _checkAndUpdatePaymentStatus(String? motivo) {
    if (widget.pagamento.idStatusPagamento == 4 ||
        widget.pagamento.idStatusPagamento == 3) {
      _showAutoCancelMessage(widget.pagamento.motivo);
    }
  }

  void _showAutoCancelMessage(String? message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _cancelMessage = message;
      });
    });
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

  String getGrupoName(int? idGrupoEvento) {
    if (idGrupoEvento == null) return 'Grupo não foi informado';
    final grupo = grupos.firstWhere(
      (g) => g.id == idGrupoEvento,
      orElse: () => Grupo(
          id: 0, nome: 'Desconhecido', cnpj: '00000000000000', situacao: false),
    );
    return grupo.nome;
  }

  // Exibe a foto em tela cheia
  void _showFullScreenPhoto() {
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
                  fit: BoxFit.fill,
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

  Future<void> _approveData() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PagamentoInscricaoController>().aprovarDadosPagamento(
            id: widget.pagamento.id!,
            idUsuarioAprova: widget.usuario.id,
          );
      if (!mounted) return;

      await InscricaoController().atualizarInscricao(
        context,
        widget.inscricao.id!,
        InscricaoEvento(
          idUsuario: widget.inscricao.idUsuario,
          idCategoriaBicicleta: widget.inscricao.idCategoriaBicicleta,
          idCategoriaCaminhadaCorrida:
              widget.inscricao.idCategoriaCaminhadaCorrida,
          idStatusInscricaoTipo: 3,
          idEvento: widget.inscricao.idEvento,
          meta: widget.inscricao.meta,
          medalhaEntregue: false,
          termoCiente: widget.inscricao.termoCiente,
          criadoEm: widget.inscricao.criadoEm,
          atualizadoEm: widget.inscricao.atualizadoEm,
        ),
      );
      if (!mounted) return;

      SalvoSucessoSnackBar.show(context,
          message: 'Pagamento aprovado com sucesso!');

      // Retorna true para indicar que uma atualização foi feita
      Navigator.pop(context, true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

// Rejeita o pagamento com um motivo
  Future<void> _rejectData() async {
    MotivoRejeicaoOverlay.show(context, (motivo) async {
      if (motivo.isNotEmpty) {
        await _confirmRejection(motivo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, insira o motivo da rejeição.'),
        ));
      }
    });
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

// Confirma a rejeição com motivo
  Future<void> _confirmRejection(String motivo) async {
    setState(() => _isLoading = true);

    // Rejeita o pagamento
    await context.read<PagamentoInscricaoController>().rejeitarDadosPagamento(
          id: widget.pagamento.id!,
          idUsuarioAprova: widget.usuario.id,
          motivo: motivo,
        );
    if (!mounted) return;
    // Atualiza o status da inscrição com o novo status calculado
    await InscricaoController().atualizarInscricao(
      context,
      widget.inscricao.id!,
      InscricaoEvento(
        idUsuario: widget.inscricao.idUsuario,
        idCategoriaBicicleta: widget.inscricao.idCategoriaBicicleta,
        idCategoriaCaminhadaCorrida:
            widget.inscricao.idCategoriaCaminhadaCorrida,
        idStatusInscricaoTipo: 4,
        idEvento: widget.inscricao.idEvento,
        meta: widget.inscricao.meta,
        medalhaEntregue: false,
        termoCiente: widget.inscricao.termoCiente,
        criadoEm: widget.inscricao.criadoEm,
        atualizadoEm: DateTime.now(),
      ),
    );
    if (!mounted) return;

    SalvoSucessoSnackBar.show(context,
        message: 'Enviado para revisão com sucesso!');
    // Retorna true para indicar que uma atualização foi feita
    Navigator.pop(context, true);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Conteúdo rolável
                Positioned.fill(
                  top: screenHeight * 0.12, // Altura do header
                  bottom: 50, // Espaço para o botão Voltar
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEventDetails(),

                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min, // Ajuste a altura ao conteúdo
                            children: [
                              const Text(
                                'Situação de pagamento:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPaymentStatusButton(
                                  widget.pagamento.idStatusPagamento),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Foto acima da mensagem de cancelamento
                        if (hasPhoto) _buildPhoto(),
                        // Mensagem de cancelamento centralizada
                        if (_cancelMessage != null)
                          Center(child: _buildCancelMessage()),
                        const SizedBox(height: 20),
                        // Botões de ação
                        _buildActionButtons(
                            screenWidth, screenHeight, scaleFactor),
                        const SizedBox(height: 20),
                        _buildPaymentStatus(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildHeader(screenHeight)),
                Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildBackButton())),
              ],
            ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildPaymentStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  Widget _buildCancelMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _cancelMessage!,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Função para construir o botão de status de pagamento
  Widget _buildPaymentStatusButton(int idStatusPagamento) {
    String statusText;
    Color? statusColor;

    switch (idStatusPagamento) {
      case 1:
        statusText = 'Não Pago';
        statusColor = Colors.red;
        break;
      case 2:
        statusText = 'Pago';
        statusColor = Colors.green;
        break;
      case 3:
        statusText = 'Em revisão';
        statusColor = Colors.blue;
        break;
      case 4:
        statusText = 'Cancelado';
        statusColor = Colors.grey;
        break;
      case 5:
        statusText = 'Isento';
        statusColor = const Color(0xFFFF7801);
        break;
      case 6:
        statusText = 'Em Aprovação';
        statusColor = const Color(0xFFFF7801);
        break;
      default:
        statusText = 'Status Desconhecido';
        statusColor = Colors.black;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(statusText,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Constrói uma linha de informação com label e valor
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

  // Botão para retornar à página anterior
  Widget _buildBackButton() {
    return TextButton(
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
    );
  }

  // Constrói o cabeçalho da tela
  Widget _buildHeader(double screenHeight) {
    return Stack(
      children: [
        CustomSemicirculo(height: screenHeight * 0.12, color: Colors.black),
        Positioned(
          top: screenHeight * 0.04,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Detalhes Pagamento',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Botões de ação Aprovar e Revisar
  Widget _buildActionButtons(
      double screenWidth, double screenHeight, double scaleFactor) {
    bool canApprove = hasPhoto && widget.pagamento.idStatusPagamento == 6;
    bool canReview = hasPhoto && widget.pagamento.idStatusPagamento == 6;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: canApprove ? _approveData : null,
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('Aprovar', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            fixedSize: Size(screenWidth * 0.3, 25 * scaleFactor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: canReview ? _rejectData : null,
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Revisar', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7801),
            fixedSize: Size(screenWidth * 0.3, 25 * scaleFactor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
      ],
    );
  }

  // Exibe a foto do pagamento em tela cheia se disponível
  Widget _buildPhoto() {
    if (widget.pagamento.idStatusPagamento == 5 ||
        widget.pagamento.idStatusPagamento == 1 ||
        widget.pagamento.idStatusPagamento == 4) {
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
}
