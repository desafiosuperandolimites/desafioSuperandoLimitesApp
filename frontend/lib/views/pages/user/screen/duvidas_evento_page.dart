part of '../../../env.dart';

class TodasDuvidasPage extends StatefulWidget {
  const TodasDuvidasPage({super.key});

  @override
  TodasDuvidasPageState createState() => TodasDuvidasPageState();
}

class TodasDuvidasPageState extends State<TodasDuvidasPage> {
  late DuvidaEventoController _duvidaController;
  late RespostaDuvidaController _respostaController;
  late UserController _userController;

  final FileController _fileController = FileController();
  final Map<int, bool> _expandedItems = {};

  bool _isLoading = true;
  bool isAscending = false;
  List<DuvidaEvento> duvidas = [];
  List<DuvidaEvento> filteredDuvidas = [];
  String searchQuery = '';
  bool? _situacaoFilter;
  Map<int, File?> userPhotos = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadDuvidasFromBackend();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return ''; // Caso a data seja nula
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _loadDuvidasFromBackend() async {
    await _duvidaController.fetchDuvidasEventos();
    setState(() {
      duvidas = _duvidaController.duvidaList;
      // Ordenar pela mais recente
      duvidas.sort((a, b) => b.criadoEm!.compareTo(a.criadoEm!));
      filteredDuvidas = List.from(duvidas);
    });
  }

  Future<void> _loadData() async {
    try {
      _duvidaController =
          Provider.of<DuvidaEventoController>(context, listen: false);
      _respostaController =
          Provider.of<RespostaDuvidaController>(context, listen: false);
      _userController = Provider.of<UserController>(context, listen: false);

      await _userController.fetchUsers();
      await _duvidaController.fetchDuvidasEventos();

      // Filtra apenas dúvidas ativas
      setState(() {
        duvidas = _duvidaController.duvidaList
            .where((duvida) => duvida.situacao == true)
            .toList();
        duvidas.sort((a, b) => b.criadoEm!.compareTo(a.criadoEm!));
        filteredDuvidas = List.from(duvidas);
      });

      await _downloadUsersPhotos();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar dados: $e');
      }
    }
  }

  Future<void> _downloadUsersPhotos() async {
    for (var usuario in _userController.userList) {
      if (usuario.fotoPerfil != null && usuario.fotoPerfil!.isNotEmpty) {
        await _fileController.downloadFileFotosPerfil(usuario.fotoPerfil!);
        userPhotos[usuario.id] = _fileController.downloadedFile;
      } else {
        userPhotos[usuario.id] = null;
      }
    }
  }

  void _filterDuvidas() {
    setState(() {
      filteredDuvidas = _duvidaController.duvidaList.where((duvida) {
        final matchesDuvida =
            duvida.duvida.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesSituacao =
            _situacaoFilter == null || duvida.situacao == _situacaoFilter;

        return matchesDuvida && matchesSituacao;
      }).toList();

      filteredDuvidas.sort((a, b) => b.criadoEm!.compareTo(a.criadoEm!));
    });
  }

  Future<List<RespostaDuvida>> _loadRespostas(int idDuvida) async {
    try {
      await _respostaController.fetchRespostasDuvida(idDuvidaEvento: idDuvida);
      return _respostaController.respostaList;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar respostas: $e');
      }
      return [];
    }
  }

  Future<void> _saveDuvida(String duvidaText) async {
    try {
      final userId = _userController.user?.id ?? 0;

      if (userId == 0) {
        throw Exception('Usuário não autenticado.');
      }

      final newDuvida = DuvidaEvento(
        idUsuario: userId,
        duvida: duvidaText,
        situacao: false,
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      final createdDuvida =
          await _duvidaController.createDuvidaEvento(context, newDuvida);

      setState(() {
        duvidas.insert(0, createdDuvida);
        filteredDuvidas.insert(0, createdDuvida);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar dúvida: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar a dúvida. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDuvidaPopup() async {
    DuvidaPopup.show(context, (duvidaText) async {
      await _saveDuvida(duvidaText); // Função que salva a dúvida no banco
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double textScaleFactor = screenHeight < 668 ? 1 : 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.14,
            child: Stack(
              children: [
                CustomSemicirculo(
                  height: screenHeight * 0.12,
                  color: const Color(0xFFFF7801),
                ),
                Positioned(
                  top: screenHeight * 0.04,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Central de Ajuda',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) {
                    searchQuery = value;
                    _filterDuvidas();
                  },
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.search),
                    hintText: 'Buscar por conteúdo da dúvida',
                    labelStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
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
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Alinha para a direita
                  children: [
                    CustomDropdownButton(
                      value: _situacaoFilter == null
                          ? 'Todos'
                          : _situacaoFilter!
                              ? 'Respondidas'
                              : 'Não Respondidas', // Define o valor selecionado
                      items: const [
                        'Todos',
                        'Respondidas',
                        'Não Respondidas'
                      ], // Opções
                      onChanged: (String? value) {
                        setState(() {
                          if (value == 'Todos') {
                            _situacaoFilter = null;
                          } else if (value == 'Respondidas') {
                            _situacaoFilter = true;
                          } else if (value == 'Não Respondidas') {
                            _situacaoFilter = false;
                          }
                          _filterDuvidas(); // Atualiza o filtro
                        });
                      },
                      hint: '', // Placeholder
                      width: 200, // Define a largura
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
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
            child: const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Dúvidas Frequentes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDuvidasList(),
          ),
          _buildSaveButton(screenWidth, screenHeight, textScaleFactor),
          const CustomBottomNavigationBar(
              currentIndex: 1), // Adiciona os botões no rodapé
        ],
      ),
    );
  }

  Widget _buildDuvidasList() {
    if (filteredDuvidas.isEmpty) {
      return const Center(child: Text('Nenhuma dúvida encontrada.'));
    }

    return ListView.builder(
      itemCount: filteredDuvidas.length,
      itemBuilder: (context, index) {
        final duvida = filteredDuvidas[index];
        return _buildDuvidaCard(duvida);
      },
    );
  }

  Widget _buildSaveButton(
      double screenWidth, double screenHeight, double scaleFactor) {
    return SizedBox(
      height: screenHeight * 0.070,
      child: Center(
        child: CustomButtonSalvar(
          onSave: _showDuvidaPopup,
          child: const Text(
            'Enviar Minha Dúvida',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuvidaCard(DuvidaEvento duvida) {
    final bool isExpanded = _expandedItems[duvida.id ?? 0] ?? false;

    final usuario = _userController.userList.firstWhere(
      (user) => user.id == duvida.idUsuario,
      orElse: () => Usuario(
        id: 0,
        nome: "Usuário não encontrado",
        email: "",
        situacao: false,
        cadastroPendente: false,
        pagamentoPendente: false,
      ),
    );

    File? userPhoto = userPhotos[usuario.id];

    Widget userPhotoWidget;
    if (userPhoto != null) {
      userPhotoWidget = ClipOval(
        child: Image.file(
          userPhoto,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } else {
      userPhotoWidget = ClipOval(
        child: Image.asset(
          'assets/image/Logo.png',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: userPhotoWidget,
            title: Text(
              duvida.duvida,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${usuario.nome} (${_formatDate(duvida.criadoEm)})',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.remove : Icons.add,
              ),
              onPressed: () {
                if (duvida.id == null) {
                  return;
                }
                setState(() {
                  // Fechar todas as dúvidas abertas
                  _expandedItems.clear();
                  _expandedItems[duvida.id!] = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            FutureBuilder<List<RespostaDuvida>>(
              future: _loadRespostas(duvida.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhuma resposta encontrada.'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!.map((resposta) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Texto da resposta
                            Text(
                              resposta.resposta,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.5), // Justificado
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 8),
                            // Data da resposta
                            Text(
                              'Respondido em: ${_formatDate(resposta.criadoEm)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
