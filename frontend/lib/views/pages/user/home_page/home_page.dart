part of '../../../env.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final EventoController _eventoController = EventoController();
  final GrupoController _grupoController = GrupoController();
  final FeedNoticiaController _feedNoticiaController = FeedNoticiaController();
  final InscricaoController _inscricaoController = InscricaoController();
  final UserController _userController = UserController();
  final DadosEstatisticosUsuariosController _dadosEstatisticosController =
      DadosEstatisticosUsuariosController();
  //final FileController _fileController = FileController();

  late TabController _tabController = TabController(length: 2, vsync: this);
  late PageController _pageController;

  bool isAscending = false;
  bool _isLoading = true;
  int? selectedGroup;
  String? selectedStatus = 'Todos';
  String searchQuery = '';
  bool isGridView = true;
  int? _idGrupoUsuarioLogado;
  int? _idGrupoUsuarioLogados;
  List<Depoimento> depoimentos = [];
  bool _isLoadingDepoimentos = true;
  int totalEventosInscritos = 0;
  double totalKmPercorrido = 0.0;
  int totalMedalhas = 0;

  @override
  void initState() {
    super.initState();

    // Bloqueia a rotação para modo retrato ao iniciar a HomePage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _loadDataFromBackend();
    _startAutoPlay();
    _loadDepoimentosFromBackend();
    _tabController = TabController(length: 2, vsync: this);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Periodic check
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndShowCompletionPopup();
    });

    // Initial check
    _checkAndShowCompletionPopup();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNoticiasFromBackend() async {
    await _feedNoticiaController.fetchFeedNoticias();
    if (mounted) {
      noticias = _feedNoticiaController.feedNoticiaList;
      await _downloadNoticiasImages();
      setState(() {
        _isLoadingNoticias = false;
      });
    }
  }

  void _checkAndShowCompletionPopup() async {
    final userId = _userController.user?.id;
    if (userId == null) return;

    await _inscricaoController.fetchInscricoes();
    final inscricoesUsuario = _inscricaoController.inscricaoList
        .where((inscricao) => inscricao.idUsuario == userId)
        .toList();

    for (final inscricao in inscricoesUsuario) {
      final dadosEstatisticos = await _dadosEstatisticosController
          .fetchDadosEstatisticosUsuario(inscricao.idEvento, userId);
      final kmPercorridos = dadosEstatisticos.fold<double>(
        0.0,
        (total, dados) => dados.idStatusDadosEstatisticos == 3
            ? total + dados.kmPercorrido
            : total,
      );

      if (kmPercorridos >= inscricao.meta) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'meta_concluida_${inscricao.id}';
        final alreadyShown = prefs.getBool(key) ?? false;
        if (!mounted) return;
        if (!alreadyShown) {
          _showCompletionPopup(context, inscricao.meta);
          await prefs.setBool(key, true);
        }
      }
    }
  }

  Future<void> _loadDataFromBackend() async {
    await _loadGruposFromBackend(); // Carrega os grupos
    await _loadEventosFromBackend(); // Carrega os eventos após carregar as inscrições
    await _loadUserInscricoes(); // Carrega as inscrições do usuário

    await _loadNoticiasFromBackend();
    await _fetchDynamicData();
    await _loadDepoimentosFromBackend();

    if (mounted) {
      setState(() {
        // Após carregar os dados, filtra os eventos
        _filterEventos(
            setState, selectedStatus, _idGrupoUsuarioLogado, searchQuery);
      });
    }
  }

  Future<void> _loadDepoimentosFromBackend() async {
    final DepoimentoController depoimentoController = DepoimentoController();
    await depoimentoController.fetchDepoimentos();

    setState(() {
      depoimentos = depoimentoController.depoimentoList
          .where((depoimento) => depoimento.situacao)
          .toList();
      _isLoadingDepoimentos = false;
    });
  }

  Future<void> _loadUserInscricoes() async {
    await _userController.fetchCurrentUser();
    if (!mounted) return;
    int userId = _userController.user!.id;
    _idGrupoUsuarioLogado = _userController.user?.idGrupoEvento;
    await _inscricaoController.fetchInscricoes();
    List<InscricaoEvento> userInscricoes = _inscricaoController.inscricaoList
        .where((inscricao) => inscricao.idUsuario == userId)
        .toList();

    List<int> subscribedEventIds =
        userInscricoes.map((inscricao) => inscricao.idEvento).toList();

    setState(() {
      for (var evento in eventos) {
        evento.isSubscribed = subscribedEventIds.contains(evento.id);
      }
    });
  }

  Future<void> _fetchDynamicData() async {
    if (_userController.user == null) {
      if (kDebugMode) {
        print("Erro: Usuário não carregado.");
      }
      return;
    }
    int userId = _userController.user!.id;

    await _inscricaoController.fetchInscricoes();
    List<InscricaoEvento> userInscricoes = _inscricaoController.inscricaoList
        .where((inscricao) => inscricao.idUsuario == userId)
        .toList();

    setState(() {
      totalEventosInscritos = userInscricoes.length;
    });

    double kmSum = 0.0;
    int medalhasCount = 0;

    for (var inscricao in userInscricoes) {
      List<DadosEstatisticosUsuarios> dadosList =
          await _dadosEstatisticosController.fetchDadosEstatisticosUsuario(
        inscricao.idEvento,
        userId,
      );

      for (var dados in dadosList) {
        if (dados.idStatusDadosEstatisticos == 3) {
          kmSum += dados.kmPercorrido;
        }
      }

      if (inscricao.medalhaEntregue) {
        medalhasCount++;
      }
    }

    setState(() {
      totalKmPercorrido = kmSum;
      totalMedalhas = medalhasCount;
    });
  }

  Future<void> _loadEventosFromBackend() async {
    try {
      await _eventoController.fetchEventosGrupoHomePage(
          filtroGrupoHomePage: _idGrupoUsuarioLogado);
      eventos = _eventoController.eventoList;

      await _userController.fetchCurrentUser();

      //int userIda = _userController.user!.id;
      _idGrupoUsuarioLogados = _userController.user?.idGrupoEvento;

      // Filtrando os eventos que pertencem ao grupo do usuário
      eventos = eventos
          .where((evento) => evento.idGrupoEvento == _idGrupoUsuarioLogados)
          .toList();

      print('ID DO USUARIO ABAIXO');
      print(_idGrupoUsuarioLogado);

      await _downloadEventosImages();

      if (mounted) {
        setState(() => filteredEventos = List.from(eventos));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar eventos: $e");
      }
    }
  }

  Widget _buildSearchFilterFields(double textScaleFactor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: _inputDecoration("Nome"),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterEventos(setState, selectedStatus,
                      _idGrupoUsuarioLogado, searchQuery);
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomDropdownButton(
              value: selectedStatus,
              items: const ['Todos', 'Inscrito', 'Inscrever', 'Finalizados'],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                  _filterEventos(setState, selectedStatus,
                      _idGrupoUsuarioLogado, searchQuery);
                });
              },
              hint: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(double textScaleFactor, double buttonScaleFactor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      decoration: const BoxDecoration(
        color: Colors.white,
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
          Text(
            'Todos (${filteredEventos.length})',
            style: TextStyle(fontSize: 15 * textScaleFactor),
          ),
          IconButton(
            icon: Image.asset(
              isAscending ? 'assets/image/ZA.png' : 'assets/image/AZ.png',
              height: 14 * textScaleFactor,
              width: 14 * textScaleFactor,
            ),
            onPressed: _sortEventos,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.grid_view_rounded,
              size: 20 * buttonScaleFactor,
            ),
            onPressed: () {
              setState(() {
                isGridView = true;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.view_list,
              size: 22 * buttonScaleFactor,
            ),
            onPressed: () {
              setState(() {
                isGridView = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeContent(
      double textScaleFactor, double buttonScaleFactor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (filteredEventos.isEmpty) {
      return const Center(child: Text('Nenhum desafio encontrado.'));
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isGridView
            ? _buildChallengeGrid(textScaleFactor, buttonScaleFactor)
            : _buildChallengeList(textScaleFactor),
      );
    }
  }

  Widget _buildChallengeList(double textScaleFactor) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredEventos.length,
      itemBuilder: (context, index) {
        return _buildChallengeListItem(
            filteredEventos[index], context, textScaleFactor);
      },
    );
  }

  Widget _buildChallengeListItem(
      Evento evento, BuildContext context, double textScaleFactor) {
    bool finalizado = isEventoFinalizado(evento.dataFimInscricoes);
    final double screenHeight = MediaQuery.of(context).size.height;

    String taxaEvento = evento.isentoPagamento == true
        ? 'Evento Isento'
        : 'Valor R\$ ${evento.valorEvento.toStringAsFixed(2)}';

    // Check if we have a downloaded image
    Widget imageWidget;
    if (downloadedEventosImages.containsKey(evento.id) &&
        downloadedEventosImages[evento.id] != null) {
      imageWidget = Image.file(
        downloadedEventosImages[evento.id]!,
        height: 40 * textScaleFactor,
        width: 70 * textScaleFactor,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        evento.capaEvento ?? 'assets/image/foto01.jpg',
        height: 40 * textScaleFactor,
        width: 70 * textScaleFactor,
        fit: BoxFit.cover,
      );
    }

    return Card(
      color: Colors.grey[100],
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
        title: Text(
          evento.nome,
          style: TextStyle(
            fontSize: 13 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inscrições: ${_formatDateString(evento.dataInicioInscricoes)} a ${_formatDateString(evento.dataFimInscricoes)}',
              style: TextStyle(
                fontSize: 10 * textScaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              taxaEvento,
              style: TextStyle(
                fontSize: 11 * textScaleFactor,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            if (evento.isSubscribed) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeuDesafioPage(evento: evento),
                ),
              );
            } else if (!finalizado) {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InscricaoPage(
                    manualEventId: evento.id!,
                  ),
                ),
              );
              if (result == true) {
                await _loadUserInscricoes();
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: finalizado
                ? Colors.grey
                : (evento.isSubscribed ? Colors.blue : Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(100, 20),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
          ),
          child: Text(
            finalizado
                ? (evento.isSubscribed ? 'Finalizado' : '')
                : (evento.isSubscribed ? 'Acessar' : 'Inscrever-se'),
            style: TextStyle(
              height: screenHeight * 0.003,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    if (mounted) {
      setState(() {
        grupos = _grupoController.groupList;
      });
    }
  }

  void _sortEventos() {
    setState(() {
      if (isAscending) {
        filteredEventos.sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      } else {
        filteredEventos.sort(
            (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
      }
      isAscending = !isAscending;
    });
  }

  Widget _buildNoticias(double textScaleFactor, double buttonScaleFactor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
          decoration: const BoxDecoration(
            color: Colors.white,
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
              Text(
                'Notícias',
                style: TextStyle(fontSize: 16 * textScaleFactor),
              ),
            ],
          ),
        ),
        SizedBox(height: 5 * textScaleFactor),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: Colors.grey.withOpacity(0.1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 11 * textScaleFactor),
              _buildNewsCard(textScaleFactor, (index) {
                setState(() {
                  currentPage = index;
                });
              }),
            ],
          ),
        ),
        SizedBox(height: 10 * textScaleFactor),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenHeight < 720 || screenWidth < 400;

    double textScaleFactor = isSmallScreen ? 0.8 : 1.0;
    double buttonScaleFactor = isSmallScreen ? 1 : 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInstataneoMensal(textScaleFactor, buttonScaleFactor,
                  totalKmPercorrido, totalEventosInscritos, totalMedalhas),
              _buildNoticias(textScaleFactor, buttonScaleFactor),
              _buildTabs(textScaleFactor, buttonScaleFactor),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildTabs(double textScaleFactor, double buttonScaleFactor) {
    // Unchanged logic
    return TabContainer(
      controller: _tabController,
      tabEdge: TabEdge.top,
      tabsStart: 0,
      tabsEnd: 1,
      borderRadius: BorderRadius.circular(1),
      tabBorderRadius: BorderRadius.circular(10),
      selectedTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 15 * textScaleFactor,
      ),
      unselectedTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 15 * textScaleFactor,
      ),
      colors: [
        Colors.grey[100] ?? Colors.grey,
        Colors.grey[100] ?? Colors.grey,
      ],
      tabs: [
        Text(
          'Desafios',
          style: TextStyle(fontSize: 16 * textScaleFactor),
        ),
        Text(
          'Depoimentos',
          style: TextStyle(fontSize: 16 * textScaleFactor),
        ),
      ],
      children: [
        _buildDesafiosContent(textScaleFactor, buttonScaleFactor),
        _buildDepoimentosContent(depoimentos, _isLoadingDepoimentos),
      ],
    );
  }

  Widget _buildDesafiosContent(
      double textScaleFactor, double buttonScaleFactor) {
    // Unchanged logic
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildSearchFilterFields(textScaleFactor),
        const SizedBox(height: 10),
        _buildControlBar(textScaleFactor, buttonScaleFactor),
        const SizedBox(height: 10),
        _buildChallengeContent(textScaleFactor, buttonScaleFactor),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChallengeGrid(double textScaleFactor, double buttonScaleFactor) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Definir um breakpoint simples (ex.: se for menor que 600 de largura, consideramos "pequeno")
    final bool isSmallScreen = screenWidth < 600;
    //final bool isBigScreen = screenWidth > 600;
    //final bool isMobileScreen = screenWidth < 1150;

    // Ajustar fatores de escala conforme o tamanho
    double ratio = 0;
    if (isSmallScreen) {
      ratio = 1.03;
    } else {
      ratio = 1.3;
    }

    // Unchanged logic, just using downloadedEventosImages in _buildChallengeCard
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10 * buttonScaleFactor,
        mainAxisSpacing: 15 * buttonScaleFactor,
        childAspectRatio: ratio,
      ),
      itemCount: filteredEventos.length,
      itemBuilder: (context, index) {
        return _buildChallengeCard(filteredEventos[index], context,
            textScaleFactor, buttonScaleFactor);
      },
    );
  }

  Widget _buildChallengeCard(Evento evento, BuildContext context,
      double textScaleFactor, double buttonScaleFactor) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Definir um breakpoint simples (ex.: se for menor que 600 de largura, consideramos "pequeno")
    final bool isSmallScreen = screenWidth < 600;
    //final bool isBigScreen = screenWidth > 600;
    //final bool isMobileScreen = screenWidth < 1150;

    // Ajustar fatores de escala conforme o tamanho
    double ratio = 0;
    if (isSmallScreen) {
      ratio = 0.85;
    } else {
      ratio = 1.7;
    }

    double ratio2 = 0;
    if (isSmallScreen) {
      ratio2 = 0.85;
    } else {
      ratio2 = 1.2;
    }

    bool finalizado = isEventoFinalizado(evento.dataFimInscricoes);
    String taxaEvento = evento.isentoPagamento == true
        ? 'Evento Isento'
        : 'Valor R\$ ${evento.valorEvento.toStringAsFixed(2)}';

    Widget eventoImage;
    if (downloadedEventosImages.containsKey(evento.id) &&
        downloadedEventosImages[evento.id] != null) {
      eventoImage = Image.file(
        downloadedEventosImages[evento.id]!,
        height: 72 * ratio,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      eventoImage = Image.asset(
        evento.capaEvento ?? 'assets/image/foto01.jpg',
        height: 72 * ratio,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Container(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: eventoImage,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    evento.nome,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13 * ratio,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Inscrições: ${_formatDateString(evento.dataInicioInscricoes)} a ${_formatDateString(evento.dataFimInscricoes)}',
                    style: TextStyle(fontSize: 11 * ratio),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    taxaEvento,
                    style: TextStyle(fontSize: 11 * ratio),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 200 * ratio2,
                    height: 50 * ratio2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (evento.isSubscribed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MeuDesafioPage(evento: evento),
                            ),
                          );
                        } else if (!finalizado) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InscricaoPage(
                                manualEventId: evento.id!,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: finalizado
                            ? Colors.grey
                            : (evento.isSubscribed
                                ? Colors.blue
                                : Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        finalizado
                            ? (evento.isSubscribed ? 'Finalizado' : '')
                            : (evento.isSubscribed
                                ? 'Acessar'
                                : 'Inscrever-se'),
                        style: TextStyle(
                          fontSize: 17 * ratio2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
