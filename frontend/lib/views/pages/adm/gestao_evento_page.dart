part of '../../env.dart';

class GestaoEventosPage extends StatefulWidget {
  const GestaoEventosPage({super.key});

  @override
  GestaoEventosPageState createState() => GestaoEventosPageState();
}

class GestaoEventosPageState extends State<GestaoEventosPage> {
  final EventoController _eventoController = EventoController();
  final GrupoController _grupoController = GrupoController();

  bool isAscending = false;
  List<Evento> eventos = [];
  List<Evento> filteredEventos = [];
  String searchQuery = '';
  int? selectedGroup;
  List<Grupo> grupos = [];
  String? selectedSituacao = "Ativo"; // Definindo "Ativo" como valor padrão

  @override
  void initState() {
    super.initState();
    _loadEventosFromBackend();
    _loadGruposFromBackend();
  }

  Future<void> _loadEventosFromBackend() async {
    await _eventoController.fetchEventos(); // Fetch users from backend

    setState(() {
      eventos = _eventoController.eventoList;
      // Aplica o filtro para mostrar apenas eventos ativos por padrão
      _filterEventos();
    });
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
  }

  void _filterEventos() {
    setState(() {
      filteredEventos = eventos.where((evento) {
        bool matchesQuery =
            evento.nome.toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesGroup =
            selectedGroup == null || evento.idGrupoEvento == selectedGroup;

        // Filtro de situação: se selectedSituacao for "Ativo" ou "Inativo", filtramos por situacao
        bool matchesSituacao = selectedSituacao == null ||
            (selectedSituacao == "Ativo" && evento.situacao) ||
            (selectedSituacao == "Inativo" && !evento.situacao);

        return matchesQuery && matchesGroup && matchesSituacao;
      }).toList();
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

  Widget _buildFilters(double scaleFactor) {
    return Row(
      children: [
        Expanded(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int?>(
                icon: const Icon(null), // Remove o ícone de seta para baixo
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
                    _filterEventos();
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
              child: DropdownButtonFormField<String?>(
                icon: const Icon(null), // Remove o ícone de seta para baixo
                value: selectedSituacao,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.filter_alt_outlined),
                  hintText: 'Situação',
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
                items: const [
                  DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                  DropdownMenuItem<String?>(
                      value: 'Ativo', child: Text('Ativo')),
                  DropdownMenuItem<String?>(
                      value: 'Inativo', child: Text('Inativo')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSituacao = newValue;
                    _filterEventos();
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 20.0), // Ajuste para mover o botão mais para cima
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePageAdm()),
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
            child: Center(
              child: Text(
                'Gestão de Eventos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            _filterEventos();
                          });
                        },
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.search),
                          hintText: 'Buscar por evento',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CadastrarEventoPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Mantenha o mesmo raio da borda
                          ),
                        ),
                        child: const Text(
                          '+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildFilters(scaleFactor),
              ),
              const SizedBox(height: 10),
              // Retângulo com sombra contendo "Todos" e ícone de ordenação
              Container(
                padding: const EdgeInsets.all(1.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.zero, // Remove os cantos arredondados
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
                        'Todos (${filteredEventos.length})',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                    ),
                    const Spacer(),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Lista de eventos
              Expanded(
                child: ListView.builder(
                  itemCount: filteredEventos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CadastrarEventoPage(
                                evento: filteredEventos[index],
                                isEditing: true),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            // Título do evento e data (caso o evento esteja inativo)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredEventos[index].nome,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  if (!filteredEventos[index]
                                      .situacao) // Exibe a data se o evento estiver inativo
                                    Text(
                                      '${DateTime.parse(filteredEventos[index].dataInicioEvento).day}/'
                                      '${DateTime.parse(filteredEventos[index].dataInicioEvento).month}/'
                                      '${DateTime.parse(filteredEventos[index].dataInicioEvento).year}'
                                      ' - '
                                      '${DateTime.parse(filteredEventos[index].dataFimEvento).day}/'
                                      '${DateTime.parse(filteredEventos[index].dataFimEvento).month}/'
                                      '${DateTime.parse(filteredEventos[index].dataFimEvento).year}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),

                            // Ícone de seta para editar o evento (opcional)
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CadastrarEventoPage(
                                      evento: filteredEventos[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildBackButton(), // Botão Voltar adicionado aqui
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }
}
