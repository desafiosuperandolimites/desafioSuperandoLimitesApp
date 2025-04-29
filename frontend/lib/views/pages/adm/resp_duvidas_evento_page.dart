part of '../../env.dart';

class AdminDuvidasPage extends StatefulWidget {
  const AdminDuvidasPage({super.key});

  @override
  State<AdminDuvidasPage> createState() => _AdminDuvidasPageState();
}

class _AdminDuvidasPageState extends State<AdminDuvidasPage> {
  late DuvidaEventoController _duvidaController;
  late UserController _userController;
  final FileController _fileController = FileController(); // For user photos

  bool _isLoading = true;
  final Map<int, bool> _expandedItems = {};
  List<DuvidaEvento> _filteredDuvidas = [];
  String _searchQuery = '';
  bool? _situacaoFilter;
  bool? _ativaFilter; // null => Todas, true => Ativas, false => Inativas

  // Map to store downloaded user profile images keyed by user ID
  Map<int, File?> userPhotos = {};

  @override
  void initState() {
    super.initState();
    //_ativaFilter = true; // Filtrar somente Ativas por padrão
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _duvidaController =
          Provider.of<DuvidaEventoController>(context, listen: false);
      _userController = Provider.of<UserController>(context, listen: false);

      // Carregar dados do backend
      await _duvidaController.fetchDuvidasEventos();
      await _userController.fetchUsers();

      // Download user photos
      await _downloadUsersPhotos();

      setState(() {
        _filteredDuvidas = _duvidaController.duvidaList;

        // Ordenar pela mais recente
        _filteredDuvidas.sort((a, b) => b.criadoEm!.compareTo(a.criadoEm!));

        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar dados: $e');
      }
    }
  }

  Future<void> _downloadUsersPhotos() async {
    for (var user in _userController.userList) {
      if (user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty) {
        await _fileController.downloadFileFotosPerfil(user.fotoPerfil!);
        userPhotos[user.id] = _fileController.downloadedFile;
      } else {
        userPhotos[user.id] = null;
      }
    }
  }

  void _filterDuvidas() {
    setState(() {
      _filteredDuvidas = _duvidaController.duvidaList.where((duvida) {
        // Filtro por texto (busca)
        final matchesSearch =
            duvida.duvida.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filtro de "Respondidas" / "Não Respondidas"
        // (Aqui você usa 'duvida.situacao' para definir se está respondida ou não,
        //  mas depende de como seu back-end controla isso)
        final matchesSituacao =
            _situacaoFilter == null || duvida.situacao == _situacaoFilter;

        // Filtro de "Ativas" / "Inativas" (também baseado em duvida.situacao? Ou outra flag?)
        final matchesAtiva =
            _ativaFilter == null || duvida.situacao == _ativaFilter;

        return matchesSearch && matchesSituacao && matchesAtiva;
      }).toList();

      // Ordenar pela mais recente
      _filteredDuvidas.sort((a, b) => b.criadoEm!.compareTo(a.criadoEm!));
    });
  }

  Future<List<RespostaDuvida>> _loadRespostas(int idDuvida) async {
    try {
      final respostaController =
          Provider.of<RespostaDuvidaController>(context, listen: false);

      await respostaController.fetchRespostasDuvida(idDuvidaEvento: idDuvida);

      return respostaController.respostaList;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar respostas para a dúvida $idDuvida: $e');
      }
      return [];
    }
  }

  Future<void> _toggleDuvida(int id) async {
    try {
      await _duvidaController.toggleDuvidaEventoStatus(context, id);
      await _loadData(); // Atualiza a lista após a alteração
    } catch (e) {
      print('Erro ao desativar dúvida: $e');
    }
  }

  void _showToggleConfirmPopup(BuildContext context, DuvidaEvento duvida) {
    final bool isAtiva = duvida.situacao == true; // se 'true', está ativa
    final String acao = isAtiva ? 'Desativar' : 'Ativar';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('$acao Dúvida'),
          content: Text('Tem certeza que deseja $acao esta dúvida?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // fecha o popup
                await _toggleDuvida(duvida.id!);

                if (!mounted) return;
                // Exibe SnackBar confirmando
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Dúvida ${isAtiva ? "desativada" : "ativada"} com sucesso.')),
                );
              },
              child: Text(acao),
            ),
          ],
        );
      },
    );
  }

  void _showRespostaPopup(DuvidaEvento duvida) {
    RespDuvidaPopup.show(context, duvida.duvida, (respostaText) async {
      final userId = _userController.user?.id ?? 0;
      final novaResposta = RespostaDuvida(
        idUsuario: userId,
        idDuvidaEvento: duvida.id!,
        resposta: respostaText,
      );

      await Provider.of<RespostaDuvidaController>(context, listen: false)
          .createRespostaDuvida(context, novaResposta);

      duvida.situacao = true;
      if (!mounted) return;
      await _duvidaController.updateDuvidaEvento(context, duvida.id!, duvida);

      _filterDuvidas(); // Atualiza a lista com o filtro aplicado

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = screenHeight < 668 ? 1 : 1.2;
    final screenWidth = MediaQuery.of(context).size.width;
// Aqui consideramos um padding horizontal total de 32 (16 à esquerda + 16 à direita)
// e um pequeno espaçamento de 8 entre os dois Dropdowns
    final double spacing = 8;
    final double contentWidth = screenWidth - 32 - spacing;
// Cada Dropdown terá metade desse espaço
    final double halfWidth = contentWidth / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Semicírculo com o título
          SizedBox(
            height: screenHeight * 0.14,
            child: Stack(
              children: [
                CustomSemicirculo(
                  height: screenHeight * 0.12,
                  color: const Color(0xFF000000),
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterDuvidas();
                  },
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.search),
                    hintText: 'Buscar por conteúdo da dúvida',
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomDropdownButton(
                      value: _situacaoFilter == null
                          ? 'Todos'
                          : _situacaoFilter!
                              ? 'Respondidas'
                              : 'Não Respondidas',
                      items: const ['Todos', 'Respondidas', 'Não Respondidas'],
                      onChanged: (String? value) {
                        setState(() {
                          if (value == 'Todos') {
                            _situacaoFilter = null;
                          } else if (value == 'Respondidas') {
                            _situacaoFilter = true;
                          } else if (value == 'Não Respondidas') {
                            _situacaoFilter = false;
                          }
                          _filterDuvidas();
                        });
                      },
                      hint: '',
                      width: halfWidth,
                    ),

                    // Espaçamento entre os dois dropdowns
                    SizedBox(width: spacing),

                    CustomDropdownButton(
                      value: _ativaFilter == null
                          ? 'Todas'
                          : _ativaFilter!
                              ? 'Ativas'
                              : 'Inativas',
                      items: const ['Todas', 'Ativas', 'Inativas'],
                      onChanged: (String? value) {
                        setState(() {
                          if (value == 'Todas') {
                            _ativaFilter = null;
                          } else if (value == 'Ativas') {
                            _ativaFilter = true;
                          } else if (value == 'Inativas') {
                            _ativaFilter = false;
                          }
                          _filterDuvidas();
                        });
                      },
                      hint: '',
                      width: halfWidth,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                    'Suporte',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDuvidasList(),
          ),
          _buildBackButton(),
          const CustomBottomNavigationBarAdm(currentIndex: 2),
        ],
      ),
    );
  }

  Widget _buildDuvidasList() {
    if (_filteredDuvidas.isEmpty) {
      return const Center(child: Text('Nenhuma dúvida encontrada.'));
    }

    return ListView.builder(
      itemCount: _filteredDuvidas.length,
      itemBuilder: (context, index) {
        final duvida = _filteredDuvidas[index];
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

        final isExpanded = _expandedItems[duvida.id ?? 0] ?? false;

        // Check if user photo is downloaded
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Column(
            children: [
              ListTile(
                leading: userPhotoWidget,
                title: Text(
                  duvida.duvida,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${usuario.nome} (${_formatDate(duvida.criadoEm)})',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
                trailing: IconButton(
                  icon: Icon(isExpanded ? Icons.remove : Icons.add),
                  onPressed: () {
                    setState(() {
                      // Fecha todas as outras perguntas
                      _expandedItems.clear();
                      // Abre apenas a pergunta clicada
                      _expandedItems[duvida.id!] = !isExpanded;
                    });
                  },
                ),
              ),
              if (isExpanded) _buildRespostaSection(duvida),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRespostaSection(DuvidaEvento duvida) {
    return FutureBuilder<List<RespostaDuvida>>(
      future: _loadRespostas(duvida.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        // Conteúdo principal do Card expandido
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Se houver pelo menos uma resposta
              if (snapshot.hasData && snapshot.data!.isNotEmpty) ...[
                Text(
                  snapshot.data!.first.resposta,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Respondido em: '
                  '${_formatDate(snapshot.data!.first.criadoEm)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],

              // Agrupamos os dois botões (Responder/Respondida e Ativar/Desativar) numa única Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // BOTÃO ESQUERDO: Responder ou Respondida
                  if (snapshot.hasError ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty)
                    // Caso a dúvida ainda não tenha resposta
                    ElevatedButton(
                      onPressed: () => _showRespostaPopup(duvida),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Responder',
                          style: TextStyle(color: Colors.white)),
                    )
                  else
                    // Caso já exista resposta
                    ElevatedButton(
                      onPressed: null, // desabilitado
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Respondida',
                          style: TextStyle(color: Colors.white)),
                    ),

                  const SizedBox(width: 16), // Espaço entre os dois botões

                  // BOTÃO DIREITO: Ativar ou Desativar
                  if (duvida.situacao == true)
                    ElevatedButton(
                      onPressed: () => _showToggleConfirmPopup(context, duvida),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Desativar',
                          style: TextStyle(color: Colors.white)),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _showToggleConfirmPopup(context, duvida),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Ativar',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home-adm');
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
