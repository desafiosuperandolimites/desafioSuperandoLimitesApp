part of '../../env.dart';

class DetalheStatusPage extends StatefulWidget {
  final DadosEstatisticosUsuarios dadosEstatisticosUsuarios;
  final List<StatusDadosEstatisticos> statusList;

  const DetalheStatusPage({
    super.key,
    required this.dadosEstatisticosUsuarios,
    required this.statusList,
  });

  @override
  DetalheStatusPageState createState() => DetalheStatusPageState();
}

class DetalheStatusPageState extends State<DetalheStatusPage> {
  final DadosEstatisticosUsuariosController _dadosController =
      DadosEstatisticosUsuariosController();
  final FileController _fileController = FileController();

  late TextEditingController _kmController;
  late TextEditingController _dataController;
  late String statusDescricao;

  bool _isLoading = false;
  bool isReadOnly = true;
  bool showActionButtons = false;
  bool showObservacao = false;

  File? _downloadedComprovante;

  @override
  void initState() {
    super.initState();
    _kmController = TextEditingController(
        text: widget.dadosEstatisticosUsuarios.kmPercorrido.toString());
    _dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy')
          .format(widget.dadosEstatisticosUsuarios.dataAtividade),
    );

    StatusDadosEstatisticos status = widget.statusList.firstWhere(
      (s) => s.id == widget.dadosEstatisticosUsuarios.idStatusDadosEstatisticos,
      orElse: () => StatusDadosEstatisticos(
        id: -1,
        descricao: 'Desconhecido',
        chaveNome: 'desconhecido',
        situacao: false,
      ),
    );
    statusDescricao = status.descricao;

    if (statusDescricao == 'Pendente de Aprovação') {
      isReadOnly = true;
      showActionButtons = true;
    } else if (statusDescricao == 'Pendente de Correção') {
      isReadOnly = true;
      showActionButtons = false;
      showObservacao = true;
    } else if (statusDescricao == 'Cancelado') {
      isReadOnly = true;
      showActionButtons = false;
      showObservacao = true;
    } else if (statusDescricao == 'Aprovada') {
      isReadOnly = true;
      showActionButtons = false;
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

  Future<void> _approveData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userController =
          Provider.of<UserController>(context, listen: false);
      final adminUser = userController.user!;

      await _dadosController.aprovarDadosEstatisticos(
        id: widget.dadosEstatisticosUsuarios.id,
        idUsuarioAprova: adminUser.id,
      );

      if (!mounted) return;

      SalvoSucessoSnackBar.show(context,
          message: 'Dados aprovados com sucesso!');

      Navigator.pop(context, true); // Return to previous page and refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aprovar dados: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rejectData() async {
    MotivoRejeicaoOverlay.show(context, (observacao) async {
      if (observacao.isNotEmpty) {
        await _confirmRejection(observacao);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, insira o motivo da rejeição.')),
        );
      }
    });
  }

  Future<void> _confirmRejection(String observacao) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userController =
          Provider.of<UserController>(context, listen: false);
      final adminUser = userController.user!;

      await _dadosController.rejeitarDadosEstatisticos(
        id: widget.dadosEstatisticosUsuarios.id,
        idUsuarioAprova: adminUser.id,
        observacao: observacao,
      );

      if (!mounted) return;

      SalvoSucessoSnackBar.show(context,
          message: 'Dados rejeitados com sucesso!');

      Navigator.pop(context, true); // Return to previous page and refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao rejeitar dados: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(screenHeight),
                  const SizedBox(height: 10),
                  _buildPhoto(),
                  const SizedBox(height: 40),
                  _buildDataFields(),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                  const SizedBox(height: 60),
                  const CustomButtonVoltar(),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 1),
    );
  }

  Widget _buildHeader(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.14,
      child: Stack(
        children: [
          CustomSemicirculo(
            height: screenHeight * 0.12,
            color: const Color.fromARGB(255, 3, 3, 3),
          ),
          Positioned(
            top: screenHeight * 0.04,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                statusDescricao,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: showObservacao ? 200 : 300,
        width: double.infinity,
        color: Colors.grey[300],
        child: _downloadedComprovante != null
            ? GestureDetector(
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
              )
            : Center(
                child: Text(
                  'Foto da Atividade',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ),
      ),
    );
  }

  Widget _buildDataFields() {
    // Unchanged logic
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
                  readOnly:
                      true, // Verificar se vai ser readOnly ou usar variável isReadOnly para o admin poder editar o campo de KM
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _dataController,
                  decoration: InputDecoration(
                    labelText: 'Data daa Atividade',
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
                  readOnly:
                      true, // Verificar se vai ser readOnly ou usar variável isReadOnly para o admin poder editar o campo de Data da Atividade
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

  Widget _buildActionButtons() {
    // Unchanged logic (approve/reject)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: showActionButtons ? _approveData : null,
            icon: const Icon(Icons.thumb_up, color: Colors.white),
            iconAlignment: IconAlignment.end,
            label: const Text(
              'Aceitar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Tamanho do texto padrão
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: showActionButtons ? _rejectData : null,
            label: const Text(
              'Rejeitar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Tamanho do texto padrão
              ),
            ),
            icon: const Icon(Icons.thumb_down, color: Colors.white),
            iconAlignment: IconAlignment.end,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
