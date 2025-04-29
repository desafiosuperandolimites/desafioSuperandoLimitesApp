part of '../../env.dart';

class AdminCadastrarKMPage extends StatefulWidget {
  final Evento evento;
  final Usuario usuario;

  const AdminCadastrarKMPage({
    super.key,
    required this.evento,
    required this.usuario,
  });

  @override
  AdminCadastrarKMPageState createState() => AdminCadastrarKMPageState();
}

class AdminCadastrarKMPageState extends State<AdminCadastrarKMPage> {
  final DadosEstatisticosUsuariosController _dadosController =
      DadosEstatisticosUsuariosController();
  final GrupoController _grupoController = GrupoController();
  final StatusDadosEstatisticosController _statusController =
      StatusDadosEstatisticosController();
  final Map<int, TextEditingController> _kmControllers = {};
  final Map<int, DadosEstatisticosUsuarios> _existingDataMap = {};

  bool _isLoading = true;
  Grupo? _grupo;
  Usuario? admin;
  int _pendingApprovals = 0;
  List<WeekInfo> _weeks = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    for (var controller in _kmControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeData() async {
    final userController = Provider.of<UserController>(context, listen: false);
    admin = userController.user;
    await _grupoController.fetchGrupoById(widget.usuario.idGrupoEvento!);
    _grupo = _grupoController.selectedGrupo;

    _calculateWeeks();

    List<DadosEstatisticosUsuarios> dadosList =
        await _dadosController.fetchDadosEstatisticosUsuario(
      widget.evento.id!,
      widget.usuario.id,
    );

    List<DadosEstatisticosUsuarios> adminDadosList = dadosList.where((dados) {
      return dados.foto == null;
    }).toList();

    for (var dados in adminDadosList) {
      if (dados.semana != null) {
        _existingDataMap[dados.semana!] = dados;
      }
    }

    for (var weekInfo in _weeks) {
      int weekNumber = weekInfo.weekNumber;
      _kmControllers[weekNumber] = TextEditingController();

      if (_existingDataMap.containsKey(weekNumber)) {
        double kmPercorrido = _existingDataMap[weekNumber]!.kmPercorrido;
        _kmControllers[weekNumber]!.text =
            kmPercorrido.toString().replaceAll('.', ',');
      }
    }

    await _fetchPendingApprovals();

    setState(() {
      _isLoading = false;
    });
  }

  void _calculateWeeks() {
    DateTime startDate = DateTime.parse(widget.evento.dataInicioEvento);
    DateTime endDate = DateTime.parse(widget.evento.dataFimEvento);

    int totalDays = endDate.difference(startDate).inDays + 1;
    int totalWeeks = (totalDays / 7).ceil();

    _weeks = [];

    for (int i = 0; i < totalWeeks; i++) {
      DateTime weekStartDate = startDate.add(Duration(days: i * 7));
      DateTime weekEndDate = weekStartDate.add(const Duration(days: 6));

      if (weekEndDate.isAfter(endDate)) {
        weekEndDate = endDate;
      }

      _weeks.add(WeekInfo(
        weekNumber: i + 1,
        startDate: weekStartDate,
        endDate: weekEndDate,
      ));
    }
  }

  Future<void> _fetchPendingApprovals() async {
    List<DadosEstatisticosUsuarios> dadosList = await _dadosController
        .fetchDadosEstatisticosUsuario(widget.evento.id!, widget.usuario.id);

    await _statusController.fetchStatusDadosEstatisticos();
    int? pendingApprovalStatusId = _statusController.statusList
        .firstWhere(
          (status) => status.chaveNome == 'PENDENTE_APROVACAO',
          orElse: () => StatusDadosEstatisticos(
              id: 0, descricao: '', chaveNome: '', situacao: false),
        )
        .id;

    _pendingApprovals = dadosList
        .where(
          (dados) => dados.idStatusDadosEstatisticos == pendingApprovalStatusId,
        )
        .length;
  }

  Future<void> _saveData() async {
    List<Map<String, dynamic>> kmDataList = [];
    List<Map<String, dynamic>> kmUpdateList = [];

    for (var weekInfo in _weeks) {
      int weekNumber = weekInfo.weekNumber;
      String text = _kmControllers[weekNumber]?.text.trim() ?? '';
      if (text.isNotEmpty) {
        double? kmValue = double.tryParse(text.replaceAll(',', '.'));
        if (kmValue != null && kmValue > 0) {
          if (_existingDataMap.containsKey(weekNumber)) {
            kmUpdateList.add({
              'ID': _existingDataMap[weekNumber]!.id,
              'KM_PERCORRIDO': kmValue,
              'ID_USUARIO_INSCRITO': widget.usuario.id,
              'DATA_ATIVIDADE':
                  _existingDataMap[weekNumber]!.dataAtividade.toIso8601String(),
              'FOTO': _existingDataMap[weekNumber]!.foto,
            });
          } else {
            kmDataList.add({
              'KM_PERCORRIDO': kmValue,
              'SEMANA': weekNumber,
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Valor inválido na semana $weekNumber')),
          );
          return;
        }
      }
    }

    if (kmDataList.isEmpty && kmUpdateList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira os valores de KM para salvar.')),
      );
      return;
    }

    try {
      final userController =
          Provider.of<UserController>(context, listen: false);
      final adminUser = userController.user!;

      for (var entry in kmUpdateList) {
        await _dadosController.editarDadosEstatisticos(
          id: entry['ID'],
          idUsuarioInscrito: entry['ID_USUARIO_INSCRITO'],
          kmPercorrido: entry['KM_PERCORRIDO'],
          dataAtividade: DateTime.parse(entry['DATA_ATIVIDADE']),
          foto: entry['FOTO'],
        );
      }

      if (kmDataList.isNotEmpty) {
        await _dadosController.registrarKMAdmin(
          idUsuarioInscrito: widget.usuario.id,
          idUsuarioCadastra: adminUser.id,
          idUsuarioAprova: adminUser.id,
          idEvento: widget.evento.id!,
          kmData: kmDataList,
        );
      }

      if (!mounted) return;

      SalvoSucessoSnackBar.show(context,
          message: 'Quilometragem salva com sucesso!');

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(screenHeight),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        _buildUserInfo(),
                        const SizedBox(height: 20),
                        _buildPendingApprovals(),
                        const SizedBox(height: 20),
                        _buildKMInputFields(),
                        _buildSaveButton(),
                        _buildBackButton(),
                      ],
                    ),
                  ),
                ),
              ],
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
            child: const Center(
              child: Text(
                'Cadastro de Dados de KM',
                style: TextStyle(
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

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoRow('Nome', widget.usuario.nome),
          _buildUserInfoRow(
              'Telefone', widget.usuario.celular ?? 'Não informado'),
          _buildUserInfoRow('E-mail', widget.usuario.email),
          _buildUserInfoRow('Grupo', _grupo?.nome ?? 'Não informado'),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    if (label == 'Telefone' && value.contains(RegExp(r'^[0-9]{11}$'))) {
      value =
          '(${value.substring(0, 2)}) ${value.substring(2, 7)}-${value.substring(7)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: '$label: ',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return GestureDetector(
      onTap: () async {
        bool? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatusAprovacaoKMPage(
              evento: widget.evento,
              usuario: widget.usuario,
            ),
          ),
        );
        if (result == true) {
          await _initializeData();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 64.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFF7801),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Aprovações Pendentes ($_pendingApprovals)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKMInputFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _weeks.length,
        itemBuilder: (context, index) {
          WeekInfo weekInfo = _weeks[index];
          int weekNumber = weekInfo.weekNumber;
          String dateRange =
              '${DateFormat('dd/MM/yyyy').format(weekInfo.startDate)} a ${DateFormat('dd/MM/yyyy').format(weekInfo.endDate)}';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              controller: _kmControllers[weekNumber],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Semana $weekNumber ($dateRange)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CustomButtonSalvar(onSave: _saveData),
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
}
