part of '../../env.dart';

class GestaoPagamentoPage extends StatefulWidget {
  const GestaoPagamentoPage({super.key});

  @override
  GestaoPagamentoPageState createState() => GestaoPagamentoPageState();
}

class GestaoPagamentoPageState extends State<GestaoPagamentoPage> {
  final EventoController _eventoController = EventoController();
  final InscricaoController _inscricaoController = InscricaoController();
  final UserController _userController = UserController();
  final GrupoController _grupoController = GrupoController();
  final PagamentoInscricaoController _pagamentoController =
      PagamentoInscricaoController();
  final StatusPagamentoController _statusPagamentoController =
      StatusPagamentoController();
  final FileController _fileController = FileController();

  late final Evento evento;
  late final Usuario user;
  List<InscricaoEvento> inscricoes = [];
  List<Evento> eventos = [];
  List<Grupo> grupos = [];
  List<Usuario> users = [];
  List<PagamentoInscricao> pagamentos = [];
  List<StatusPagamento> statusPagamentoList = [];
  List<Map<String, dynamic>> userPaymentList = [];

  bool isAscending = false;

  /// Variável de controle para exibir a lista só depois do delay
  bool _showUserList = false;

  int? selectedGroup;
  String? selectedStatus = 'Todos';
  String searchQuery = '';
  Map<int, File?> userPhotos = {};

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend().then((_) {});

    // Esse Future.delayed controla QUANDO a lista será exibida
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showUserList = true; // Depois de 2 segundos, mostra a lista
        });
      }
    });
  }

  Future<void> _loadDataFromBackend() async {
    await Future.wait([
      _loadUsersFromBackend(),
      _loadGruposFromBackend(),
      _loadPagamentosFromBackend(),
      _loadStatusPagamentoFromBackend(),
      _loadEventosFromBackend(),
      _loadInscricoesFromBackend(),
    ]);
    await _checkAndUpdatePaymentStatuses();
    await _downloadUsersPhotos();

    _generateUserPaymentList();
    _filterUsers();
  }

  Future<void> _loadInscricoesFromBackend() async {
    await _inscricaoController.fetchInscricoes();
    setState(() {
      inscricoes = _inscricaoController.inscricaoList;
    });
  }

  Future<void> _loadEventosFromBackend() async {
    await _eventoController.fetchEventos(); // Fetch eventos from backend
    setState(() {
      eventos = _eventoController.eventoList;
    });
  }

  Future<void> _loadStatusPagamentoFromBackend() async {
    await _statusPagamentoController.fetchStatusPagamento();
    setState(() {
      statusPagamentoList = _statusPagamentoController.statusPagamentoList;
    });
  }

  Future<void> _loadUsersFromBackend() async {
    await _userController.fetchUsers();
    setState(() {
      users = _userController.userList;
    });
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
  }

  Future<void> _loadPagamentosFromBackend() async {
    await _pagamentoController.fetchPagamentosInscricoes();
    setState(() {
      pagamentos = _pagamentoController.pagamentoList;
    });
  }

  Future<void> _downloadUsersPhotos() async {
    for (var usuario in users) {
      if (userPhotos[usuario.id] != null) {
        continue;
      }
      if (usuario.fotoPerfil != null && usuario.fotoPerfil!.isNotEmpty) {
        await _fileController.downloadFileFotosPerfil(usuario.fotoPerfil!);
        userPhotos[usuario.id] = _fileController.downloadedFile;
      } else {
        userPhotos[usuario.id] = null;
      }
    }
  }

  DateTime? parseDate(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is DateTime) {
      return date;
    }
    return null;
  }

  Future<void> _checkAndUpdatePaymentStatuses() async {
    final DateTime currentDate = DateTime.now();

    for (var pagamento in pagamentos) {
      final usuario = users.firstWhere((u) => u.id == pagamento.idUsuario);
      // Get the inscription associated with the payment
      final inscricao = inscricoes.firstWhere(
        (i) => i.id == pagamento.idInscricaoEvento,
        orElse: () => throw Exception(
            'InscricaoEvento not found for id: ${pagamento.idInscricaoEvento}'),
      );

      // Get the event associated with the inscription
      final evento = eventos.firstWhere(
        (e) => e.id == inscricao.idEvento,
        orElse: () =>
            throw Exception('Evento not found for id: ${inscricao.idEvento}'),
      );

      final DateTime? dataFimInscricao = parseDate(evento.dataFimInscricoes);

      if (dataFimInscricao != null) {
        if ((pagamento.idStatusPagamento == 1 ||
                pagamento.idStatusPagamento == 3) &&
            currentDate.isAfter(dataFimInscricao)) {
          // Update status to "Cancelado" (4)
          await _pagamentoController.updatePagamentoInscricao(
            context,
            pagamento.id!,
            PagamentoInscricao(
              id: pagamento.id,
              idUsuario: usuario.id,
              idStatusPagamento: 4,
              idInscricaoEvento: pagamento.idInscricaoEvento,
              idDadosBancariosAdm: pagamento.idDadosBancariosAdm,
              comprovante: pagamento.comprovante,
              dataPagamento: pagamento.dataPagamento,
              motivo:
                  "Cancelamento automático - falta de pagamento. Inscrições encerradas",
            ),
          );
        }
      }
    }
  }

  void _sortUsers() {
    setState(() {
      if (isAscending) {
        userPaymentList.sort(
          (a, b) => (a['usuario'] as Usuario)
              .nome
              .toLowerCase()
              .compareTo((b['usuario'] as Usuario).nome.toLowerCase()),
        );
      } else {
        userPaymentList.sort(
          (a, b) => (b['usuario'] as Usuario)
              .nome
              .toLowerCase()
              .compareTo((a['usuario'] as Usuario).nome.toLowerCase()),
        );
      }
      isAscending = !isAscending;
    });
  }

  void _generateUserPaymentList() {
    setState(() {
      userPaymentList = [];
      for (var pagamento in pagamentos) {
        final usuario = users.firstWhere((u) => u.id == pagamento.idUsuario);

        // Find the inscription
        final inscricao = inscricoes.firstWhere(
          (i) => i.id == pagamento.idInscricaoEvento,
          orElse: () => throw Exception(
              'InscricaoEvento not found for id: ${pagamento.idInscricaoEvento}'),
        );
        // Find the event
        final evento = eventos.firstWhere(
          (e) => e.id == inscricao.idEvento,
          orElse: () =>
              throw Exception('Evento not found for id: ${inscricao.idEvento}'),
        );
        // Find the group
        final grupo = grupos.firstWhere(
          (g) => g.id == usuario.idGrupoEvento,
          orElse: () => throw Exception(
              'Grupo not found for id: ${usuario.idGrupoEvento}'),
        );

        userPaymentList.add({
          'usuario': usuario,
          'pagamento': pagamento,
          'inscricao': inscricao,
          'evento': evento,
          'grupo': grupo,
        });
      }
    });
  }

  String getStatusDescriptionById(int idStatusPagamento) {
    switch (idStatusPagamento) {
      case 1:
        return 'Não Pago';
      case 2:
        return 'Pago';
      case 3:
        return 'Em Revisão';
      case 4:
        return 'Cancelado';
      case 5:
        return 'Isento';
      case 6:
        return 'Em Aprovação';
      default:
        return 'Status Desconhecido';
    }
  }

  Color getColorByStatus(int idStatusPagamento) {
    switch (idStatusPagamento) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.yellow;
      case 6:
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  void _filterUsers() {
    setState(() {
      _generateUserPaymentList();
      userPaymentList = userPaymentList.where((userMap) {
        final Usuario user = userMap['usuario'];
        final PagamentoInscricao pagamento = userMap['pagamento'];

        bool matchGroup =
            selectedGroup == null || user.idGrupoEvento == selectedGroup;

        bool matchStatus = selectedStatus == 'Todos' ||
            getStatusDescriptionById(pagamento.idStatusPagamento)
                    .toLowerCase() ==
                selectedStatus!.toLowerCase();

        bool matchNameOrCpf = searchQuery.isEmpty ||
            user.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (user.cpf != null && user.cpf!.contains(searchQuery));

        return matchGroup && matchStatus && matchNameOrCpf;
      }).toList();
    });
  }

  Widget _buildSortingHeader() {
    return Container(
      padding: const EdgeInsets.all(1.0),
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Todos (${userPaymentList.length})',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Image.asset(
              isAscending ? 'assets/image/ZA.png' : 'assets/image/AZ.png',
              height: 15,
              width: 15,
            ),
            onPressed: _sortUsers,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomSemicirculo(
            height: screenHeight * 0.12,
            color: Colors.black,
          ),
          Positioned(
            top: screenHeight * 0.04,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Gestão de Pagamentos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              SizedBox(height: screenHeight * 0.14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSearchField(scaleFactor),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildFilters(scaleFactor),
              ),
              _buildSortingHeader(),
              const SizedBox(height: 15),

              /// Aqui chamamos o método que só vai exibir a lista se `_showUserList` for true
              _buildUserList(scaleFactor),

              const CustomButtonVoltar(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildSearchField(double scaleFactor) {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
          _filterUsers();
        });
      },
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.search),
        labelText: 'Buscar nome ou CPF',
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
      ),
    );
  }

  Widget _buildFilters(double scaleFactor) {
    return Row(
      children: [
        Expanded(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int?>(
                isExpanded: true,
                icon: const Icon(null),
                value: selectedGroup,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.filter_alt_outlined),
                  hintText: 'Grupo',
                  filled: true,
                  fillColor: Colors.white,
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
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('Todos')),
                  ...grupos.map((grupo) {
                    return DropdownMenuItem<int?>(
                        value: grupo.id, child: Text(grupo.nome));
                  }),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    selectedGroup = newValue;
                    _filterUsers();
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                icon: const Icon(null),
                value: selectedStatus,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.filter_alt_outlined),
                  hintText: 'Status',
                  filled: true,
                  fillColor: Colors.white,
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
                items: [
                  'Todos',
                  'Pago',
                  'Não Pago',
                  'Em Revisão',
                  'Em Aprovação',
                  'Isento',
                  'Cancelado'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue;
                    _filterUsers();
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList(double scaleFactor) {
    // Se _showUserList ainda estiver falso, podemos exibir um loading
    // ou um Container vazio, dependendo do que você preferir.
    if (!_showUserList) {
      // Opção 1: mostrar um indicador de progresso
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
      /*
      // Opção 2: simplesmente não mostra nada ainda
      return Expanded(child: Container());
      */
    }

    // Se _showUserList == true, renderiza normalmente a ListView
    return Expanded(
      child: ListView.builder(
        itemCount: userPaymentList.length,
        itemBuilder: (context, index) {
          final userMap = userPaymentList[index];
          final Usuario user = userMap['usuario'];
          final PagamentoInscricao pagamento = userMap['pagamento'];
          final int idStatusPagamento = pagamento.idStatusPagamento;

          // Get user photo if downloaded
          File? userPhoto = userPhotos[user.id];

          Widget userPhotoWidget;
          if (userPhoto != null) {
            userPhotoWidget = CircleAvatar(
              backgroundImage: FileImage(userPhoto),
            );
          } else {
            userPhotoWidget = const CircleAvatar(
              backgroundImage: AssetImage('assets/image/Logo.png'),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange,
                        width: 3.0,
                      ),
                    ),
                    child: userPhotoWidget,
                  ),
                  title: Text(user.nome),
                  subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: getColorByStatus(idStatusPagamento),
                      ),
                      const SizedBox(width: 5),
                      Text(getStatusDescriptionById(idStatusPagamento)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final evento = userMap['evento'];
                    final grupo = userMap['grupo'];
                    final inscricao = userMap['inscricao'];
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalhesPagamento(
                          usuario: user,
                          pagamento: pagamento,
                          inscricao: inscricao,
                          evento: evento,
                          grupo: grupo,
                        ),
                      ),
                    );

                    // Recarrega os dados se a página de detalhes retornou uma atualização
                    if (updated == true) {
                      await _loadDataFromBackend();
                    }
                  },
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }
}
