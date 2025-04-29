part of '../../../env.dart';

class AcompanharDadosPage extends StatefulWidget {
  final Evento evento;
  final Usuario usuario;

  const AcompanharDadosPage({
    super.key,
    required this.evento,
    required this.usuario,
  });

  @override
  AcompanharDadosPageState createState() => AcompanharDadosPageState();
}

class AcompanharDadosPageState extends State<AcompanharDadosPage> {
  final DadosEstatisticosUsuariosController _dadosController =
      DadosEstatisticosUsuariosController();
  final StatusDadosEstatisticosController _statusController =
      StatusDadosEstatisticosController();

  List<DadosEstatisticosUsuarios> _dadosList = [];
  List<DadosEstatisticosUsuarios> _filteredDadosList = [];
  List<StatusDadosEstatisticos> _statusList = [];

  String? _selectedStatus = 'Todos';
  bool _isLoading = true;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchStatusList();
    await _fetchDadosList();
    _filterByStatus(_selectedStatus);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchStatusList() async {
    await _statusController.fetchStatusDadosEstatisticos();
    _statusList = _statusController.statusList;
  }

  Future<void> _fetchDadosList() async {
    _dadosList = await _dadosController.fetchDadosEstatisticosUsuario(
      widget.evento.id!,
      widget.usuario.id,
    );
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
      if (status == null || status == 'Todos') {
        _filteredDadosList = List.from(_dadosList);
      } else {
        int statusId = _statusList.firstWhere((s) => s.descricao == status).id;
        _filteredDadosList = _dadosList
            .where((d) => d.idStatusDadosEstatisticos == statusId)
            .toList();
      }
    });
  }

  void _sortDadosList() {
    setState(() {
      _filteredDadosList.sort((a, b) => _isAscending
          ? a.kmPercorrido.compareTo(b.kmPercorrido)
          : b.kmPercorrido.compareTo(a.kmPercorrido));
      _isAscending = !_isAscending;
    });
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
                _buildHeaderBackground(screenHeight),
                _buildHeaderTitle(textScaleFactor, screenHeight),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildDropdownFilter(),
          const SizedBox(height: 10),
          _buildListHeader(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDadosList(),
          _buildBackButton(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildHeaderBackground(double screenHeight) {
    return CustomSemicirculo(
      height: screenHeight * 0.12,
      color: const Color(0xFFFF7801),
    );
  }

  Widget _buildHeaderTitle(double textScaleFactor, double screenHeight) {
    return Positioned(
      height: screenHeight * 0.12,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'Acompanhar Dados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  dropdownColor: Colors.white,
                  onChanged: (value) {
                    _filterByStatus(value);
                  },
                  items: [
                    const DropdownMenuItem(
                      value: 'Todos',
                      child: Text('Todos'),
                    ),
                    ..._statusList.map((status) {
                      return DropdownMenuItem(
                        value: status.descricao,
                        child: Text(status.descricao),
                      );
                    }),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle:
                        TextStyle(color: Colors.grey[500], fontSize: 16),
                    suffixIcon: const Icon(Icons.filter_alt_outlined),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
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
              'Todos (${_filteredDadosList.length})',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const Spacer(),
          const Text(
            'Km',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          IconButton(
            icon:
                Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: _sortDadosList,
          ),
        ],
      ),
    );
  }

  Widget _buildDadosList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _filteredDadosList.length,
        itemBuilder: (context, index) {
          var dados = _filteredDadosList[index];
          var status = _statusList
              .firstWhere(
                (s) => s.id == dados.idStatusDadosEstatisticos,
                orElse: () => StatusDadosEstatisticos(
                  id: -1,
                  descricao: 'Desconhecido',
                  chaveNome: 'desconhecido',
                  situacao: false,
                ),
              )
              .descricao;

          return Column(
            children: [
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatusDadosEnviadoPage(
                        dadosEstatisticosUsuarios: dados,
                        statusList: _statusList,
                        evento: widget.evento,
                        usuario: widget.usuario,
                      ),
                    ),
                  );
                  if (result == true) {
                    _initializeData();
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
                        vertical: 14.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${dados.kmPercorrido.toString().replaceAll('.', ',')} km - $status',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
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
