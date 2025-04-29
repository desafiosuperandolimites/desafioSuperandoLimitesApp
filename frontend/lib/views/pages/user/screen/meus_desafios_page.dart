part of '../../../env.dart';

class MeusDesafiosPage extends StatefulWidget {
  const MeusDesafiosPage({super.key});

  @override
  MeusDesafiosPageState createState() => MeusDesafiosPageState();
}

class MeusDesafiosPageState extends State<MeusDesafiosPage> {
  final EventoController _eventoController = EventoController();
  final InscricaoController _inscricaoController = InscricaoController();

  List<Evento> allEventos = [];
  List<Evento> eventos = [];
  List<Evento> filteredEventos = [];
  bool isAscending = false;
  bool _isLoading = true;
  String searchQuery = '';
  String selectedStatus = 'Todos';
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();
  }

  Future<void> _loadDataFromBackend() async {
    await Future.wait([
      _loadAllEventos(),
      _loadUserInscricoes(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadAllEventos() async {
    // Fetch all events
    await _eventoController.fetchEventos();
    allEventos = _eventoController.eventoList;
  }

  Future<void> _loadUserInscricoes() async {
    await Provider.of<UserController>(context, listen: false)
        .fetchCurrentUser();

    if (!mounted) return;

    int userId = Provider.of<UserController>(context, listen: false).user!.id;

    // Fetch the subscriptions
    await _inscricaoController.fetchInscricoes();

    // Filter subscriptions for the current user
    List<InscricaoEvento> userInscricoes = _inscricaoController.inscricaoList
        .where((inscricao) => inscricao.idUsuario == userId)
        .toList();

    // Extract event IDs from the subscriptions
    List<int> subscribedEventIds =
        userInscricoes.map((inscricao) => inscricao.idEvento).toList();

    // Filter allEventos to include only subscribed events
    eventos = allEventos
        .where((evento) => subscribedEventIds.contains(evento.id))
        .toList();

    // Initialize filteredEventos
    filteredEventos = List.from(eventos);
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
        bool matchesName =
            evento.nome.toLowerCase().contains(searchQuery.toLowerCase());
        bool matchesStatus = selectedStatus == 'Todos' ||
            (selectedStatus == 'Ativo' &&
                !isEventoFinalizado(evento.dataFimEvento)) ||
            (selectedStatus == 'Inativo' &&
                isEventoFinalizado(evento.dataFimEvento));
        return matchesName && matchesStatus;
      }).toList();
    });
  }

  bool isEventoFinalizado(String dataFimEvento) {
    DateTime dataFim = DateTime.parse(dataFimEvento);
    DateTime dataAtual = DateTime.now();
    return dataFim.isBefore(dataAtual);
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
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = screenHeight < 668 ? 0.85 : 1.2;

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
                  color: const Color(0xFFFF7801), // Cor laranja
                ),
                Positioned(
                  top: screenHeight * 0.04,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Meus Desafios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22 * textScaleFactor, // Escala do texto
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSearchFilterFields(),
          const SizedBox(height: 20),
          _buildControlBar(),
          const SizedBox(height: 10),
          _buildChallengeContent(),
          const SizedBox(height: 10),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildSearchFilterFields() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Name Search Field
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Nome',
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterEventos();
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          // Status Filter Field
          Expanded(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  isExpanded: false,
                  icon: const Icon(null),
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.filter_alt_outlined),
                    fillColor: Colors.white,
                    hintText: 'Situação',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                  ),
                  value: selectedStatus,
                  items: ['Todos', 'Ativo', 'Inativo']
                      .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                      _filterEventos();
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          IconButton(
            icon: Image.asset(
              isAscending ? 'assets/image/ZA.png' : 'assets/image/AZ.png',
              height: 15,
              width: 15,
            ),
            onPressed: _sortEventos,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.grid_view,
            ),
            onPressed: () {
              setState(() {
                isGridView = true;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.view_list,
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

  Widget _buildChallengeContent() {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (filteredEventos.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Nenhum desafio encontrado.')),
      );
    } else {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: isGridView ? _buildChallengeGrid() : _buildChallengeList(),
        ),
      );
    }
  }

  Widget _buildChallengeGrid() {
    final double screenHeight = MediaQuery.of(context).size.height;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenHeight * 0.01,
        mainAxisSpacing: screenHeight * 0.02,
      ),
      itemCount: filteredEventos.length,
      itemBuilder: (context, index) {
        return _buildChallengeCard(filteredEventos[index], context);
      },
    );
  }

  Widget _buildChallengeList() {
    return ListView.builder(
      itemCount: filteredEventos.length,
      itemBuilder: (context, index) {
        return _buildChallengeListItem(filteredEventos[index], context);
      },
    );
  }

  Widget _buildChallengeCard(Evento evento, BuildContext context) {
    bool finalizado = isEventoFinalizado(evento.dataFimEvento);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              evento.capaEvento ??
                  'assets/image/foto01.jpg', // Replace with your image logic
              height: 72,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            evento.nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Date Range
          Text(
            '${_formatDateString(evento.dataInicioEvento)} - ${_formatDateString(evento.dataFimEvento)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          // Status Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeuDesafioPage(evento: evento),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: finalizado ? Colors.grey : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(150, 20),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
              child: Text(
                finalizado ? 'Finalizado' : 'Acessar',
                style: TextStyle(
                  height: screenHeight * 0.003,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeListItem(Evento evento, BuildContext context) {
    bool finalizado = isEventoFinalizado(evento.dataFimEvento);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      color: Colors.grey[100],
      child: ListTile(
        leading: Image.asset(
          evento.capaEvento ??
              'assets/image/foto01.jpg', // Replace with your image logic
          height: 40,
          width: 70,
          fit: BoxFit.cover,
        ),
        title: Text(
          evento.nome,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
            '${_formatDateString(evento.dataInicioEvento)} - ${_formatDateString(evento.dataFimEvento)}'),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeuDesafioPage(evento: evento),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: finalizado ? Colors.grey : Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(100, 20),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
          ),
          child: Text(
            finalizado ? 'Finalizado' : 'Acessar',
            style: TextStyle(
              height: screenHeight * 0.003,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
