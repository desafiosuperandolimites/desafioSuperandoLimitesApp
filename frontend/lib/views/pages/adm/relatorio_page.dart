part of '../../env.dart';

class RelatorioGeralPage extends StatefulWidget {
  final Evento evento;

  const RelatorioGeralPage({
    super.key,
    required this.evento,
  });

  @override
  RelatorioGeralPageState createState() => RelatorioGeralPageState();
}

class RelatorioGeralPageState extends State<RelatorioGeralPage> {
  // Controllers
  final InscricaoController _inscricaoController = InscricaoController();
  final UserController _usuarioController = UserController();
  final DadosEstatisticosUsuariosController _dadosEstatisticosController =
      DadosEstatisticosUsuariosController();

  // State variables
  bool _isLoading = true;
  List<InscricaoEvento> filteredInscritos = [];
  String? searchQuery = '';
  bool isAscending = false;
  bool marcarTodosEntregues = false;

  // Maps to hold data
  Map<int, Usuario> usuarioMap = {};
  Map<int, double> distanciaMap = {};
  Map<int, List<DadosEstatisticosUsuarios>> dadosEstatisticosMap = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Fetch inscriptions for the event
    await _inscricaoController.getInscricaoByEvent(eventId: widget.evento.id!);

    // Fetch users and distances
    await _fetchUsuarioseDistancias();

    setState(() {
      _isLoading = false;
      filteredInscritos = _inscricaoController.inscricaoList;
    });
  }

  Future<void> _fetchUsuarioseDistancias() async {
    for (var inscricao in _inscricaoController.inscricaoList) {
      int userId = inscricao.idUsuario;
      int eventoId = inscricao.idEvento;

      // Fetch user data if not already fetched
      if (!usuarioMap.containsKey(userId)) {
        await _usuarioController.fetchUserById(userId);
        Usuario? usuario = _usuarioController.user;
        if (usuario != null) {
          usuarioMap[userId] = usuario;
        }
      }

      // Fetch DadosEstatisticos for the user
      List<DadosEstatisticosUsuarios> dadosList =
          await _dadosEstatisticosController.fetchDadosEstatisticosUsuario(
        eventoId,
        userId,
      );

      // Store DadosEstatisticos in the map
      dadosEstatisticosMap[userId] = dadosList;

      // Calculate total distance
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
        final usuario = usuarioMap[userId];
        final matchSearchQuery = usuario?.nome
                .toLowerCase()
                .contains(searchQuery?.toLowerCase() ?? '') ??
            false;
        return matchSearchQuery;
      }).toList();
    });
  }

  Future<void> _toggleMedalhaEntregue(InscricaoEvento inscricaoEvento) async {
    int userId = inscricaoEvento.idUsuario;
    double meta = inscricaoEvento.meta.toDouble();
    double distanciaPercorrida = distanciaMap[userId] ?? 0.0;
    double completionPercentage =
        meta > 0 ? (distanciaPercorrida / meta) * 100 : 0.0;

    // Decide the new status based on the current status
    bool newStatus = !inscricaoEvento.medalhaEntregue;

    if (newStatus) {
      // Trying to set medalhaEntregue to true
      if (completionPercentage >= 100) {
        final updatedInscricao = await _inscricaoController.medalhaEntregue(
            inscricaoEvento.id!, newStatus);
        if (updatedInscricao != null) {
          setState(() {
            // Update the inscricaoEvento in the filteredInscritos list
            int index = filteredInscritos
                .indexWhere((insc) => insc.id == inscricaoEvento.id);
            if (index != -1) {
              filteredInscritos[index] = updatedInscricao;
            }
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erro ao atualizar o status da medalha.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('O usuário não completou 100% da meta.')),
        );
      }
    } else {
      // Trying to set medalhaEntregue to false
      final updatedInscricao = await _inscricaoController.medalhaEntregue(
          inscricaoEvento.id!, newStatus);
      if (updatedInscricao != null) {
        setState(() {
          // Update the inscricaoEvento in the filteredInscritos list
          int index = filteredInscritos
              .indexWhere((insc) => insc.id == inscricaoEvento.id);
          if (index != -1) {
            filteredInscritos[index] = updatedInscricao;
          }
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao atualizar o status da medalha.')),
        );
      }
    }
  }

  Future<void> _markAllMedalsAsDelivered(
      List<InscricaoEvento> inscritos, bool status) async {
    bool anyIncomplete = false;
    for (var inscricao in inscritos) {
      int userId = inscricao.idUsuario;
      double meta = inscricao.meta.toDouble();
      double distanciaPercorrida = distanciaMap[userId] ?? 0.0;
      double completionPercentage =
          meta > 0 ? (distanciaPercorrida / meta) * 100 : 0.0;

      if (status) {
        // Trying to set medalhaEntregue to true
        if (completionPercentage >= 100 && !inscricao.medalhaEntregue) {
          final updatedInscricao =
              await _inscricaoController.medalhaEntregue(inscricao.id!, status);
          if (updatedInscricao != null) {
            setState(() {
              // Update the inscricao in the filteredInscritos list
              int index = filteredInscritos
                  .indexWhere((insc) => insc.id == inscricao.id);
              if (index != -1) {
                filteredInscritos[index] = updatedInscricao;
              }
            });
          } else {
            anyIncomplete = true;
          }
        } else {
          anyIncomplete = true;
        }
      } else {
        // Trying to set medalhaEntregue to false
        if (inscricao.medalhaEntregue) {
          final updatedInscricao =
              await _inscricaoController.medalhaEntregue(inscricao.id!, status);
          if (updatedInscricao != null) {
            setState(() {
              // Update the inscricao in the filteredInscritos list
              int index = filteredInscritos
                  .indexWhere((insc) => insc.id == inscricao.id);
              if (index != -1) {
                filteredInscritos[index] = updatedInscricao;
              }
            });
          } else {
            anyIncomplete = true;
          }
        }
      }
    }

    if (anyIncomplete) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Algumas medalhas não puderam ser atualizadas.')),
      );
    }

    setState(() {
      marcarTodosEntregues = status;
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
            child: const Center(
              child: Text(
                'Relatório Geral',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
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
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _filterUsers();
              });
            },
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.filter_alt_outlined),
              labelText: 'Nome',
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
          const SizedBox(height: 10),
          // Checkbox to mark all medals as delivered
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Transform.scale(
                    scale: 1.5, // Increases the checkbox size
                    child: Checkbox(
                      side: const BorderSide(color: Colors.grey),
                      value: marcarTodosEntregues,
                      activeColor: Colors.green,
                      onChanged: (bool? value) {
                        setState(() {
                          marcarTodosEntregues = value ?? false;
                        });
                        _markAllMedalsAsDelivered(
                            filteredInscritos, marcarTodosEntregues);
                      },
                    ),
                  ),
                  const Text('Marcar todos como entregues',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ],
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
          IconButton(
            icon: Image.asset(
              isAscending ? 'assets/image/ZA.png' : 'assets/image/AZ.png',
              height: 15,
              width: 15,
            ),
            onPressed: _sortUsers,
          ),
          const Spacer(),
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
          double completionPercentage =
              meta > 0 ? (distanciaPercorrida / meta) * 100 : 0.0;
          completionPercentage =
              completionPercentage > 100 ? 100 : completionPercentage;

          return Column(
            children: [
              const SizedBox(height: 15),
              Container(
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
                      // Medal icon
                      GestureDetector(
                        onTap: () {
                          _toggleMedalhaEntregue(inscricao);
                        },
                        child: Icon(
                          Icons.workspace_premium,
                          size: 48,
                          color: inscricao.medalhaEntregue
                              ? Colors.yellow[700]
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // User info and progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and Meta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  nome,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18),
                                ),
                                Text(
                                  ' - Meta: ${meta.toStringAsFixed(0)}km',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Parcial and Progress Bar
                            Row(
                              children: [
                                const Text('Parcial:'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LinearPercentIndicator(
                                    lineHeight: 14.0,
                                    percent: completionPercentage / 100,
                                    backgroundColor: Colors.grey[300],
                                    progressColor: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${completionPercentage.toStringAsFixed(2).replaceAll('.', ',')}%',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
            Navigator.pop(context);
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
