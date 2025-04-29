part of '../../env.dart';

class GestaoQuilometragemPage extends StatefulWidget {
  final Evento? evento;

  const GestaoQuilometragemPage({
    super.key,
    this.evento,
  });

  @override
  GestaoQuilometragemPageState createState() => GestaoQuilometragemPageState();
}

class GestaoQuilometragemPageState extends State<GestaoQuilometragemPage> {
  final InscricaoController _inscricaoController = InscricaoController();
  final GrupoController _grupoController = GrupoController();
  final UserController _usuarioController = UserController();
  final DadosEstatisticosUsuariosController _dadosEstatisticosController =
      DadosEstatisticosUsuariosController();
  final EventoController _eventoController = EventoController();
  final FileController _fileController = FileController();

  bool _isLoading = true;
  List<InscricaoEvento> filteredInscritos = [];
  int? selectedGroup;
  String? selectedStatus = 'Todos';
  String? searchQuery = '';
  bool isAscending = false;
  bool mostrarPendentes = false;
  Grupo? grupo;
  List<Evento> eventos = [];
  List<dynamic> filteredEventos = [];

  Map<int, Usuario> usuarioMap = {};
  Map<int, double> distanciaMap = {};
  Map<int, List<DadosEstatisticosUsuarios>> dadosEstatisticosMap = {};
  Map<int, File?> userPhotos = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadEventosFromBackend();
  }

  Future<void> _loadEventosFromBackend() async {
    await _eventoController.fetchEventos(); // Fetch users from backend

    setState(() {
      eventos = _eventoController.eventoList;
      filteredEventos = List.from(eventos);
    });
  }

  Future<void> _loadInitialData() async {
    if (widget.evento != null) {
      await _inscricaoController.getInscricaoByEvent(
          eventId: widget.evento!.id!);
    }
    await _grupoController.fetchGrupoById(widget.evento!.idGrupoEvento);
    await _fetchUsuarioseDistancias();
    await _downloadUsersPhotos();

    setState(() {
      _isLoading = false;
      filteredInscritos = _inscricaoController.inscricaoList;
      grupo = _grupoController.selectedGrupo!;
    });
  }

  Future<void> _fetchUsuarioseDistancias() async {
    for (var inscricao in _inscricaoController.inscricaoList) {
      int userId = inscricao.idUsuario;
      int eventoId = inscricao.idEvento;
      if (!usuarioMap.containsKey(userId)) {
        await _usuarioController.fetchUserById(userId);
        Usuario? usuario = _usuarioController.user;
        if (usuario != null) {
          usuarioMap[userId] = usuario;
        }
      }
      List<DadosEstatisticosUsuarios> dadosList =
          await _dadosEstatisticosController.fetchDadosEstatisticosUsuario(
        eventoId,
        userId,
      );

      dadosEstatisticosMap[userId] = dadosList;

      double totalDistancia = dadosList.fold(0.0, (total, dados) {
        if (dados.idStatusDadosEstatisticos == 3) {
          return total + dados.kmPercorrido;
        } else {
          return total;
        }
      });
      distanciaMap[userId] = totalDistancia;
    }
  }

  Future<void> _downloadUsersPhotos() async {
    for (var userEntry in usuarioMap.entries) {
      final Usuario usuario = userEntry.value;
      if (usuario.fotoPerfil != null && usuario.fotoPerfil!.isNotEmpty) {
        await _fileController.downloadFileFotosPerfil(usuario.fotoPerfil!);
        userPhotos[usuario.id] = _fileController.downloadedFile;
      } else {
        userPhotos[usuario.id] = null;
      }
    }
  }

  void _sortUsers() {
    setState(() {
      if (isAscending) {
        filteredInscritos.sort((a, b) {
          String nomeA = usuarioMap[a.idUsuario]?.nome.toLowerCase() ?? '';
          String nomeB = usuarioMap[b.idUsuario]?.nome.toLowerCase() ?? '';
          return nomeA.compareTo(nomeB);
        });
      } else {
        filteredInscritos.sort((a, b) {
          String nomeA = usuarioMap[a.idUsuario]?.nome.toLowerCase() ?? '';
          String nomeB = usuarioMap[b.idUsuario]?.nome.toLowerCase() ?? '';
          return nomeB.compareTo(nomeA);
        });
      }
      isAscending = !isAscending;
    });
  }

  void _filterUsers() {
    setState(() {
      filteredInscritos = _inscricaoController.inscricaoList.where((inscricao) {
        int userId = inscricao.idUsuario;
        final dadosList = dadosEstatisticosMap[userId] ?? [];
        // Check if the user has any pending DadosEstatisticos
        final hasPendente =
            dadosList.any((dados) => dados.idStatusDadosEstatisticos == 1);
        final matchPendentes = !mostrarPendentes || hasPendente;
        final usuario = usuarioMap[userId];
        final matchSearchQuery = usuario?.nome
                .toLowerCase()
                .contains(searchQuery?.toLowerCase() ?? '') ??
            false;
        return matchPendentes && matchSearchQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(screenHeight),
          const SizedBox(height: 10),

          _buildSearchAndFilters(),
          const SizedBox(height: 10),
          _buildSortingHeader(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildListOfInscritos(),
          //_buildRelatorioGeralButton(),
          _buildBackButton(),
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
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Gestão de Km\'s',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${grupo?.nome}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text('Km\'s pendentes', style: TextStyle(fontSize: 16)),
                  Checkbox(
                    value: mostrarPendentes,
                    activeColor: Colors.green,
                    onChanged: (bool? value) {
                      setState(() {
                        mostrarPendentes = value ?? false;
                        _filterUsers();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _filterUsers();
              });
            },
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.search),
              labelText: 'Buscar por nome',
              labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scaleFactor),
                borderSide:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scaleFactor),
                borderSide:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scaleFactor),
                borderSide:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortingHeader() {
    return Container(
      padding: const EdgeInsets.all(1.0),
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
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
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'Todos (${filteredInscritos.length})',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.query_stats,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RelatorioGeralPage(
                    evento: widget.evento!,
                  ),
                ),
              );
            },
          ),
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

  Widget _buildListOfInscritos() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredInscritos.length,
        itemBuilder: (context, index) {
          var inscricao = filteredInscritos[index];
          int userId = inscricao.idUsuario;
          Usuario? usuario = usuarioMap[userId];

          String nome = usuario?.nome ?? 'Nome não disponível';
          double meta = inscricao.meta.toDouble();
          double distanciaPercorrida = distanciaMap[userId] ?? 0.0;
          double completionPercentage = meta > 0
              ? (distanciaPercorrida / meta > 1
                      ? 1
                      : distanciaPercorrida / meta) *
                  100
              : 0.0;
          int maxChars = 15;
          String nomeExibicao = nome.length > maxChars
              ? '${nome.substring(0, maxChars)}...'
              : nome;

          // Check if user photo is downloaded
          File? userPhoto = userPhotos[userId];

          Widget userPhotoWidget;
          if (userPhoto != null) {
            // Show downloaded file
            userPhotoWidget = CircleAvatar(
              radius: 24,
              backgroundImage: FileImage(userPhoto),
            );
          } else {
            // Fallback to default asset if no photo
            userPhotoWidget = const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/image/Logo.png'),
            );
          }

          return Column(
            children: [
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  if (usuario == null || widget.evento == null) return;
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminCadastrarKMPage(
                        evento: widget.evento!,
                        usuario: usuario,
                      ),
                    ),
                  );
                  if (result == true) {
                    await _loadInitialData();
                    await _loadEventosFromBackend();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: userPhotoWidget,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomeExibicao,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Meta: ${meta.toStringAsFixed(0)}km',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${completionPercentage.toStringAsFixed(2).replaceAll('.', ',')}%',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Text(
                                    'Concluída',
                                    style: TextStyle(fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              true,
            );
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
