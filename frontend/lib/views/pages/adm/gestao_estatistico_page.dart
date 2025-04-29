part of '../../env.dart';

class GestaoDeKms extends StatefulWidget {
  const GestaoDeKms({super.key, this.isAdminMode = true});

  final bool isAdminMode; // Modo administrador

  @override
  GestaoDeKmsState createState() => GestaoDeKmsState();
}

class GestaoDeKmsState extends State<GestaoDeKms> {
  final EventoController _eventoController = EventoController();
  final GrupoController _grupoController = GrupoController();
  final FileController _fileController = FileController(); // For event images

  List<Grupo> grupos = [];
  List<Evento> eventos = [];
  List<Evento> filteredEventos = [];
  bool isAscending = false;
  bool _isLoading = true; // Estado de carregamento
  int? selectedGroup;
  String? selectedStatus = 'Todos';
  String searchQuery = '';
  bool isGridView = true; // Alternar visualização

  Map<int, File?> downloadedEventoImages =
      {}; // Stores downloaded images keyed by event ID

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();
  }

  Future<void> _loadEventosFromBackend() async {
    await _eventoController.fetchEventos();
    eventos = _eventoController.eventoList;
    filteredEventos = List.from(eventos);
    // After fetching events, download their images
    await _downloadEventoImages();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _downloadEventoImages() async {
    for (var evento in eventos) {
      if (evento.capaEvento != null && evento.capaEvento!.isNotEmpty) {
        try {
          await _fileController.downloadFileCapasEvento(evento.capaEvento!);
          downloadedEventoImages[evento.id!] = _fileController.downloadedFile;
        } catch (e) {
          downloadedEventoImages[evento.id!] = null;
          if (kDebugMode) {
            print('Erro ao baixar imagem do evento ${evento.id}: $e');
          }
        }
      } else {
        downloadedEventoImages[evento.id!] = null;
      }
    }
  }

  Future<void> _loadDataFromBackend() async {
    // Fetch eventos e grupos
    await Future.wait([
      _loadGruposFromBackend(),
      _loadEventosFromBackend(),
    ]);
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
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

  void _filterEventos() {
    setState(() {
      filteredEventos = eventos.where((evento) {
        final matchGroup =
            selectedGroup == null || evento.idGrupoEvento == selectedGroup;
        final matchStatus = selectedStatus == 'Todos' ||
            (selectedStatus == 'Ativo' && evento.situacao == true) ||
            (selectedStatus == 'Inativo' && evento.situacao == false);

        return matchGroup && matchStatus;
      }).toList();
    });
  }

  void _filterEventosNome() {
    setState(() {
      filteredEventos = eventos.where((evento) {
        return evento.nome.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  String getGrupoName(int? idGrupoEvento) {
    if (idGrupoEvento == null) {
      return 'Grupo não foi informado';
    }
    final grupo = grupos.firstWhere(
      (g) => g.id == idGrupoEvento,
      orElse: () => Grupo(
          id: 0, nome: 'Desconhecido', cnpj: '00000000000000', situacao: false),
    );
    return grupo.nome;
  }

  String _formatDateString(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return ''; // Return an empty string if parsing fails
    }
  }

  // Function to check if the event has ended
  bool isEventoFinalizado(String dataFimEvento) {
    DateTime dataFim = DateTime.parse(dataFimEvento);
    DateTime dataAtual = DateTime.now();
    return dataFim.isBefore(dataAtual);
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenHeight < 720 || screenWidth < 400;

    double textScaleFactor = isSmallScreen ? 0.8 : 1.0;
    double buttonScaleFactor = isSmallScreen ? 1 : 1.2;

    return Scaffold(
      backgroundColor: Colors.white, // Background color
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
                'Gestão de Km\'s',
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    Expanded(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<int?>(
                            value: selectedGroup,
                            icon: const Icon(null),
                            dropdownColor: Colors.white,
                            isExpanded: false,
                            decoration: InputDecoration(
                              suffixIcon: const Icon(Icons.filter_alt_outlined),
                              hintText: 'Grupo',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenHeight * 0.015),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Todos',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal)),
                              ),
                              ...grupos.map((grupo) {
                                return DropdownMenuItem<int?>(
                                  value: grupo.id,
                                  child: Text(grupo.nome,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                );
                              }),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedGroup = newValue;
                                _filterEventos();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            icon: const Icon(null),
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            decoration: InputDecoration(
                              suffixIcon: const Icon(Icons.filter_alt_outlined),
                              hintText: 'Status',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenHeight * 0.015),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                            ),
                            items: ['Todos', 'Ativo', 'Inativo']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal)),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedStatus = newValue;
                                _filterEventos();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Search field
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _filterEventosNome();
                    });
                  },
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.search),
                    hintText: 'Buscar por evento',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.015),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.005),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Todos (${filteredEventos.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    IconButton(
                      icon: Image.asset(
                        isAscending
                            ? 'assets/image/ZA.png'
                            : 'assets/image/AZ.png',
                        height: 15,
                        width: 15,
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
              ),
              SizedBox(height: screenHeight * 0.015),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isGridView
                          ? _buildChallengeGrid(filteredEventos, context,
                              buttonScaleFactor, textScaleFactor)
                          : _buildChallengeList(context, buttonScaleFactor),
                ),
              ),
              _buildBackButton(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  // Function to generate challenge cards dynamically
  Widget _buildChallengeGrid(List<Evento> eventos, BuildContext context,
      double buttonScaleFactor, double textScaleFactor) {
    if (eventos.isEmpty) {
      return const Center(
        child: Text('Nenhum evento encontrado.'),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10 * buttonScaleFactor,
        mainAxisSpacing: 12 * buttonScaleFactor,
        childAspectRatio: 1, // Proporção ajustada
      ),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        return _buildChallengeCard(
          eventos[index],
          context,
          textScaleFactor,
          buttonScaleFactor,
        );
      },
    );
  }

  // Function to build back button
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

  Widget _buildChallengeList(BuildContext context, double buttonScaleFactor) {
    if (filteredEventos.isEmpty) {
      return const Center(child: Text('Nenhum evento encontrado.'));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredEventos.length,
      itemBuilder: (context, index) {
        return _buildChallengeListItem(
          filteredEventos[index],
          context,
          buttonScaleFactor,
        );
      },
    );
  }

  Widget _buildChallengeListItem(
      Evento evento, BuildContext context, double buttonScaleFactor) {
    bool finalizado = isEventoFinalizado(evento.dataFimEvento);

    Widget eventImageWidget;
    if (downloadedEventoImages.containsKey(evento.id) &&
        downloadedEventoImages[evento.id] != null) {
      eventImageWidget = Image.file(
        downloadedEventoImages[evento.id]!,
        height: 40,
        width: 70,
        fit: BoxFit.cover,
      );
    } else {
      eventImageWidget = Image.asset(
        evento.capaEvento ?? 'assets/image/foto01.jpg',
        height: 40,
        width: 70,
        fit: BoxFit.cover,
      );
    }

    return Card(
      color: Colors.grey[100],
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: eventImageWidget,
        ),
        title: Text(
          evento.nome,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${_formatDateString(evento.dataInicioEvento)} - ${_formatDateString(evento.dataFimEvento)}',
          style: TextStyle(fontSize: 10, color: Colors.grey[700]),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GestaoQuilometragemPage(
                  evento: evento,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: finalizado ? Colors.grey : Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: Size(80 * buttonScaleFactor, 30),
            padding: EdgeInsets.symmetric(horizontal: 20.0 * buttonScaleFactor),
          ),
          child: Text(
            finalizado ? 'Finalizado' : 'Acessar',
            style: const TextStyle(
                fontWeight: FontWeight.normal, color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Evento evento, BuildContext context,
      double textScaleFactor, double buttonScaleFactor) {
    bool finalizado = isEventoFinalizado(evento.dataFimEvento);

    Widget eventImageWidget;
    if (downloadedEventoImages.containsKey(evento.id) &&
        downloadedEventoImages[evento.id] != null) {
      eventImageWidget = Image.file(
        downloadedEventoImages[evento.id]!,
        height: 72 * textScaleFactor,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      eventImageWidget = Image.asset(
        evento.capaEvento ?? 'assets/image/foto01.jpg',
        height: 72 * textScaleFactor,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: eventImageWidget,
          ),
          const SizedBox(height: 5),
          Text(
            evento.nome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13 * textScaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_formatDateString(evento.dataInicioEvento)} - ${_formatDateString(evento.dataFimEvento)}',
            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 200 * buttonScaleFactor,
            height: 40 * buttonScaleFactor,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestaoQuilometragemPage(
                      evento: evento,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: finalizado ? Colors.grey : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                finalizado ? 'Finalizado' : 'Acessar',
                style: TextStyle(
                  fontSize: 13 * textScaleFactor,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
