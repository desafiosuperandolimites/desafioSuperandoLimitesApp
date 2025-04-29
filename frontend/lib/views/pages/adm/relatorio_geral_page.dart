part of '../../env.dart';

class RelatorioGeralGraficosPage extends StatefulWidget {
  const RelatorioGeralGraficosPage({super.key});

  @override
  State<RelatorioGeralGraficosPage> createState() =>
      _RelatorioGeralGraficosPageState();
}

class _RelatorioGeralGraficosPageState
    extends State<RelatorioGeralGraficosPage> {
  bool _isLoading = true;

  // Controllers
  final GrupoController _grupoController = GrupoController();
  final EventoController _eventoController = EventoController();
  final InscricaoController _inscricaoController = InscricaoController();
  final UserController _usuarioController = UserController();
  final DadosEstatisticosUsuariosController _dadosController =
      DadosEstatisticosUsuariosController();

  // Data storage
  List<Grupo> grupos = [];
  List<Evento> eventos = [];
  List<InscricaoEvento> todasInscricoes = [];
  Map<int, double> kmPorMes = {};

  Map<int, Usuario> usuarioMap = {}; // userId -> Usuario
  Map<int, double> distanciaMap =
      {}; // userId -> total approved distance across events
  Map<String, int> faixaEtariaData = {};

  // Filtering parameters
  int? selectedGrupoId; // Filter by group
  int? selectedMes; // Filter by month
  int? selectedAno; // Filter by year
  bool? selectedSituacao; // Filter by event status

  // Aggregated results for chart
  // For each group, we will store completed and not completed counts.
  // groupId -> { 'completed': X, 'notCompleted': Y }
  Map<int, Map<String, int>> groupCompletionData = {};
  Map<int, double> kmPorAno = {2024: 0.0, 2025: 0.0, 2026: 0.0, 2027: 0.0};
  List<int> _anosDisponiveis = [];

  @override
  void initState() {
    super.initState();
    selectedAno = null; // Inicia com "Todos" selecionado
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true; // Mostra o carregamento
      });

      // 1. Fetch all groups
      await _grupoController.fetchGrupos();
      grupos = _grupoController.groupList;

      // 2. Fetch all events
      await _eventoController.fetchEventos();
      eventos = _eventoController.eventoList;

      // 3. Extrai os IDs dos eventos
      List<int> eventosIds = eventos.map((evento) => evento.id!).toList();

      // 4. Busca os anos disponíveis
      List<int> anosCalculados = await fetchAnosDisponiveis(eventosIds);
      anosCalculados.sort(); // Ordena os anos para consistência

      // Atualiza o estado dos anos disponíveis
      setState(() {
        _anosDisponiveis = anosCalculados;
        // Inicializa kmPorAno dinamicamente com os anos disponíveis
        kmPorAno = {for (int ano in anosCalculados) ano: 0.0};
      });

      // 5. Fetch all inscriptions
      for (var evento in eventos) {
        await _inscricaoController.getInscricaoByEvent(eventId: evento.id!);
        todasInscricoes.addAll(_inscricaoController.inscricaoList);
      }

      // 6. Fetch user data and compute distances
      await _fetchUsuarioseDistancias(todasInscricoes);

      // 7. Compute aggregated data for charts
      await _computeFaixaEtaria();
      await _computeKmPorAno();
      await _computeKmPorMes();

      setState(() {
        _isLoading = false; // Finaliza o carregamento
      });
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar dados iniciais: $e");
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<int>> fetchAnosDisponiveis(List<int> eventosIds) async {
    try {
      List<int> anos = [];

      for (int eventoId in eventosIds) {
        // Busca dados estatísticos para cada evento
        List<DadosEstatisticosUsuarios> dados =
            await _dadosController.fetchDadosEstatisticosEvento(eventoId);

        // Extrai os anos das datas de atividade e adiciona ao conjunto
        anos.addAll(dados.map((dado) => dado.dataAtividade.year));
      }

      // Remove duplicados e ordena os anos
      anos = anos.toSet().toList();
      anos.sort();

      return anos;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar anos disponíveis: $e");
      }
      return [];
    }
  }

// Método atualizado para retornar os anos disponíveis
  List<int> _getAnosDisponiveis() {
    return _anosDisponiveis;
  }

  Future<void> _fetchUsuarioseDistancias(
      List<InscricaoEvento> inscricoes) async {
    for (var inscricao in inscricoes) {
      int userId = inscricao.idUsuario;
      int eventoId = inscricao.idEvento;

      // Inicializa a distância como 0 se não houver dados válidos
      double totalDistanciaAprovada = 0.0;

      // Busca dados estatísticos do evento relacionado
      List<DadosEstatisticosUsuarios> dadosList =
          await _dadosController.fetchDadosEstatisticosEvento(eventoId);

      // Processa apenas os dados aprovados
      if (dadosList.isNotEmpty) {
        totalDistanciaAprovada = dadosList.fold(0.0, (sum, dados) {
          if (dados.idStatusDadosEstatisticos == 3) {
            return sum + dados.kmPercorrido; // Apenas soma dados aprovados
          }
          return sum;
        });
      }

      // Preenche o mapa com os resultados
      distanciaMap[userId] = totalDistanciaAprovada;
    }
  }

  Future<void> _computeKmPorAno() async {
    // Reinicia o mapa apenas com os anos disponíveis
    kmPorAno = {for (int ano in _anosDisponiveis) ano: 0.0};

    for (var inscricao in todasInscricoes) {
      int userId = inscricao.idUsuario;
      int eventoId = inscricao.idEvento;

      // Busca os dados do evento
      final evento = eventos.firstWhere((e) => e.id == eventoId);

      // Filtra pelo grupo se necessário
      if (selectedGrupoId != null && evento.idGrupoEvento != selectedGrupoId) {
        continue;
      }

      // Busca dados estatísticos do usuário para o evento
      List<DadosEstatisticosUsuarios> dadosList = await _dadosController
          .fetchDadosEstatisticosUsuario(eventoId, userId);

      for (var dados in dadosList) {
        if (dados.idStatusDadosEstatisticos == 3) {
          int anoAtividade =
              DateTime.parse(dados.dataAtividade.toString()).year;

          // Filtra pelo ano selecionado, se necessário
          if (selectedAno == null || anoAtividade == selectedAno) {
            if (kmPorAno.containsKey(anoAtividade)) {
              kmPorAno[anoAtividade] =
                  kmPorAno[anoAtividade]! + dados.kmPercorrido;
            }
          }
        }
      }
    }
  }

  Future<void> _computeFaixaEtaria() async {
    try {
      // Filtra as inscrições com base nos filtros de grupo e ano
      List<InscricaoEvento> filteredInscricoes =
          todasInscricoes.where((inscricao) {
        final evento = eventos.firstWhere((e) => e.id == inscricao.idEvento);

        if (selectedGrupoId != null &&
            evento.idGrupoEvento != selectedGrupoId) {
          return false; // Exclui inscrições que não correspondem ao grupo selecionado
        }

        if (selectedAno != null &&
            DateTime.parse(evento.dataInicioEvento).year != selectedAno) {
          return false; // Exclui inscrições fora do ano selecionado
        }

        return true;
      }).toList();

      // IDs únicos dos usuários
      final Set<int> userIds =
          filteredInscricoes.map((e) => e.idUsuario).toSet();

      // Busca dados atualizados de todos os usuários
      List<Usuario> usuarios = [];
      for (var userId in userIds) {
        await _usuarioController.fetchUserById(userId);
        if (_usuarioController.user != null) {
          usuarios.add(_usuarioController.user!);
        }
      }

      // Inicializa o mapa de faixas etárias
      Map<String, int> faixaEtariaMap = {
        '14-18 anos': 0,
        '18-25 anos': 0,
        '26-35 anos': 0,
        '36-50 anos': 0,
        '51 ou mais': 0,
      };

      DateTime now = DateTime.now();
      for (var user in usuarios) {
        if (user.dataNascimento != null) {
          int idade = now.year - user.dataNascimento!.year;
          if (now.month < user.dataNascimento!.month ||
              (now.month == user.dataNascimento!.month &&
                  now.day < user.dataNascimento!.day)) {
            idade--; // Ajusta se o aniversário ainda não ocorreu este ano
          }

          if (idade >= 14 && idade <= 18) {
            faixaEtariaMap['14-18 anos'] = faixaEtariaMap['14-18 anos']! + 1;
          } else if (idade > 18 && idade <= 25) {
            faixaEtariaMap['18-25 anos'] = faixaEtariaMap['18-25 anos']! + 1;
          } else if (idade > 25 && idade <= 35) {
            faixaEtariaMap['26-35 anos'] = faixaEtariaMap['26-35 anos']! + 1;
          } else if (idade > 35 && idade <= 50) {
            faixaEtariaMap['36-50 anos'] = faixaEtariaMap['36-50 anos']! + 1;
          } else if (idade > 50) {
            faixaEtariaMap['51 ou mais'] = faixaEtariaMap['51 ou mais']! + 1;
          }
        }
      }

      // Atualiza o estado com os dados calculados
      setState(() {
        faixaEtariaData = faixaEtariaMap;
      });

      if (kDebugMode) {
        print('Faixa Etária Data (filtrada): $faixaEtariaData');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao calcular faixas etárias: $e');
      }
    }
  }

  Future<void> _computeKmPorMes() async {
    // Inicializa o mapa para os meses com valores zerados
    Map<int, double> kmPorMesTemp = {
      for (int i = 1; i <= 12; i++) i: 0.0,
    };

    // Itera pelas inscrições
    for (var inscricao in todasInscricoes) {
      int userId = inscricao.idUsuario;
      int eventoId = inscricao.idEvento;

      // Encontra o evento relacionado
      final evento = eventos.firstWhere((e) => e.id == eventoId);

      // Aplica o filtro de grupo, mas sem aplicar filtro de ano por padrão
      if (selectedGrupoId != null && evento.idGrupoEvento != selectedGrupoId) {
        continue; // Ignora eventos que não correspondem ao filtro de grupo
      }

      // Busca dados estatísticos do usuário para o evento
      List<DadosEstatisticosUsuarios> dadosList = await _dadosController
          .fetchDadosEstatisticosUsuario(eventoId, userId);

      // Itera pelos dados estatísticos filtrados
      for (var dados in dadosList) {
        if (dados.idStatusDadosEstatisticos == 3) {
          DateTime dataAtividade =
              DateTime.parse(dados.dataAtividade.toString());

          // Acumula os dados de todos os anos se nenhum ano estiver selecionado
          if (selectedAno == null || dataAtividade.year == selectedAno) {
            int mes = dataAtividade.month; // Extrai o mês
            kmPorMesTemp[mes] = kmPorMesTemp[mes]! + dados.kmPercorrido;
          }
        }
      }
    }

    setState(() {
      kmPorMes = kmPorMesTemp; // Atualiza o estado com os novos dados
    });
  }

  void computeCompletionData() {
    // Inicializa os dados de conclusão por grupo
    groupCompletionData = {
      for (var g in grupos) g.id!: {'completed': 0, 'notCompleted': 0}
    };

    // Filtra os eventos com base nos parâmetros selecionados
    List<Evento> filteredEvents = eventos.where((evento) {
      bool match = true;

      if (selectedAno != null) {
        DateTime dataInicio = DateTime.parse(evento.dataInicioEvento);
        if (dataInicio.year != selectedAno) {
          match = false;
        }
      }

      if (selectedGrupoId != null && evento.idGrupoEvento != selectedGrupoId) {
        match = false;
      }

      return match;
    }).toList();

    // Mapeia eventos para grupos
    Map<int, int> eventToGroup = {
      for (var evento in filteredEvents) evento.id!: evento.idGrupoEvento
    };

    // Filtra inscrições relacionadas aos eventos selecionados
    List<InscricaoEvento> filteredInscricoes =
        todasInscricoes.where((inscricao) {
      return eventToGroup.containsKey(inscricao.idEvento);
    }).toList();

    // Calcula os dados de conclusão
    for (var inscricao in filteredInscricoes) {
      int userId = inscricao.idUsuario;
      int eventId = inscricao.idEvento;
      int groupId = eventToGroup[eventId]!;

      double distancia = distanciaMap[userId] ?? 0.0;
      double meta = inscricao.meta.toDouble();

      bool isCompleted = meta > 0 && distancia >= meta;

      if (isCompleted) {
        groupCompletionData[groupId]!['completed'] =
            groupCompletionData[groupId]!['completed']! + 1;
      } else {
        groupCompletionData[groupId]!['notCompleted'] =
            groupCompletionData[groupId]!['notCompleted']! + 1;
      }
    }
  }

  Widget _buildFaixaEtariaChart() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kmPorAno.values.every((km) => km == 0)) {
      return const Center(child: Text('Nenhum dado disponível para exibir.'));
    }
    final List<Color> faixaEtariaCores = [
      Colors.orange,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
    ];

    int total = faixaEtariaData.values.fold(0, (sum, value) => sum + value);

    List<PieChartSectionData> sections = [];
    int index = 0;

    faixaEtariaData.forEach((label, value) {
      double percentage = total > 0 ? (value / total) * 100 : 0;
      if (kDebugMode) {
        print('Faixa: $label, Valor: $value, Percentual: $percentage');
      }

      sections.add(PieChartSectionData(
        value: percentage,
        title: '$label\n${percentage.toStringAsFixed(1)}%',
        color: faixaEtariaCores[index % faixaEtariaCores.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      index++;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 0,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildKmPorMesChart(Map<int, double> kmPorMes) {
    if (kmPorMes.values.every((km) => km == 0)) {
      return const Center(
        child: Text(
          'Nenhum dado disponível para exibir.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    // Construir os grupos do gráfico
    kmPorMes.forEach((mes, km) {
      if (km > maxY) maxY = km;

      barGroups.add(
        BarChartGroupData(
          x: mes,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: km,
              width: 20,
              color: const Color(0xFFFF7801),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ],
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barGroups: barGroups,
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const meses = [
                      '',
                      'Jan',
                      'Fev',
                      'Mar',
                      'Abr',
                      'Mai',
                      'Jun',
                      'Jul',
                      'Ago',
                      'Set',
                      'Out',
                      'Nov',
                      'Dez'
                    ];
                    return Text(meses[value.toInt()],
                        style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
                show: true, border: const Border(bottom: BorderSide())),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dropdown para Ano usando CustomDropdownButton com opção "Todos"

          Expanded(
            child: CustomDropdownButtonAno(
              value: selectedAno == null ? 'Todos' : selectedAno.toString(),
              items: [
                'Todos',
                ..._getAnosDisponiveis().map((ano) => ano.toString())
              ],
              onChanged: (value) {
                setState(() {
                  selectedAno = value == 'Todos' ? null : int.tryParse(value!);
                  _applyFilters(); // Atualiza os gráficos
                });
              },
              hint: "",
            ),
          ),
          const SizedBox(width: 16), // Espaçamento entre os dropdowns

          Expanded(
            child: CustomDropdownGrupoCadastro(
              grupos: [
                Grupo(
                  id: null,
                  nome: 'Todos',
                  cnpj: '',
                  situacao: true,
                ), // Adiciona "Todos" como primeiro item
                ...grupos,
              ],
              selectedGrupo: selectedGrupoId,
              onChanged: (value) {
                setState(() {
                  selectedGrupoId = value; // null representa "Todos"
                  _applyFilters(); // Atualiza os gráficos
                });
              },
            ),
          ),

          // Dropdown para Grupo usando CustomDropdownGrupo com opção "Todos"
        ],
      ),
    );
  }

// Método para obter os anos disponíveis (dinamicamente ou estático)

  void _applyFilters() async {
    setState(() {
      _isLoading = true; // Inicia o carregamento
    });

    // Atualiza os cálculos para os filtros aplicados
    await _computeKmPorAno(); // Atualiza dados anuais
    await _computeKmPorMes(); // Atualiza dados mensais
    await _computeFaixaEtaria(); // Atualiza dados de faixa etária

    setState(() {
      _isLoading = false; // Finaliza o carregamento
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
          _buildFilters(), // Adiciona os filtros
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(),
                        const SizedBox(height: 20),
                        _buildTotalInscricoesChart(),
                        const SizedBox(height: 30),
                        _buildTitleSectionAno(),
                        const SizedBox(height: 30),
                        _buildKmPorAnoChart(),
                        const SizedBox(height: 30),
                        _buildInscritosEMetasCharts(),
                        const SizedBox(height: 30),
                        _buildTitleSectionFaixaEtaria(),
                        const SizedBox(height: 30),
                        _buildFaixaEtariaChart(),
                        const SizedBox(height: 30),
                        _buildTitleSectionKmMes(),
                        const SizedBox(height: 30),
                        _buildKmPorMesChart(kmPorMes),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 1),
    );
  }

  Widget _buildTitleSectionFaixaEtaria() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(175, 175, 175, 0.24),
      ),
      child: const Row(
        children: [
          Text(
            'Participação por faixa etária',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSectionKmMes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(175, 175, 175, 0.24),
      ),
      child: const Row(
        children: [
          Text(
            'Km\'s percorridos por Mês',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ],
      ),
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

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(175, 175, 175, 0.24),
      ),
      child: const Row(
        children: [
          Text(
            'Total de inscrições',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSectionAno() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(175, 175, 175, 0.24),
      ),
      child: const Row(
        children: [
          Text(
            'Km\'s percorridos no ano',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildKmPorAnoChart() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kmPorAno.values.every((km) => km == 0)) {
      return const Center(child: Text('Nenhum dado disponível para exibir.'));
    }

    List<BarChartGroupData> barGroups = [];
    int xIndex = 0;
    double maxY = 0;

    // Construir os grupos do gráfico
    kmPorAno.forEach((ano, km) {
      if (km > maxY) maxY = km;

      barGroups.add(
        BarChartGroupData(
          x: xIndex,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: km,
              width: 30,
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ],
        ),
      );
      xIndex++;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barGroups: barGroups,
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < kmPorAno.keys.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          kmPorAno.keys.toList()[value.toInt()].toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    // Formatar valores para "k" e "M"
                    if (value >= 1000000) {
                      return Text(
                        '${(value / 1000000).toStringAsFixed(1)}M',
                        style: const TextStyle(fontSize: 12),
                      );
                    } else if (value >= 1000) {
                      return Text(
                        '${(value / 1000).toStringAsFixed(1)}k',
                        style: const TextStyle(fontSize: 12),
                      );
                    }
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) {
                // Evitar desenhar a linha horizontal no valor máximo
                if (value >= maxY) {
                  return const FlLine(
                    color: Colors.transparent, // Torna a linha invisível
                    strokeWidth: 0,
                  );
                }
                return const FlLine(
                  color: Color(0xFFE4E5EB),
                  strokeWidth: 1,
                );
              },
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(
                show: true, border: const Border(bottom: BorderSide())),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalInscricoesChart() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Inicializa o mapa para contar as inscrições por grupo
    Map<int, int> inscricoesPorGrupo = {
      for (var g in grupos) g.id!: 0,
    };

    // Filtra as inscrições com base nos filtros aplicados (grupo e ano)
    for (var inscricao in todasInscricoes) {
      final evento = eventos.firstWhere((e) => e.id == inscricao.idEvento);

      if (selectedGrupoId != null && evento.idGrupoEvento != selectedGrupoId) {
        continue;
      }

      if (selectedAno != null &&
          DateTime.parse(evento.dataInicioEvento).year != selectedAno) {
        continue;
      }

      inscricoesPorGrupo[evento.idGrupoEvento] =
          inscricoesPorGrupo[evento.idGrupoEvento]! + 1;
    }

    // Verifica se há dados para exibir
    if (inscricoesPorGrupo.values.every((inscricoes) => inscricoes == 0)) {
      return const Center(child: Text('Nenhum dado disponível para exibir.'));
    }

    List<BarChartGroupData> barGroups = [];
    int xIndex = 0;
    double maxY = 0;

    // Constrói os dados do gráfico
    for (var g in grupos) {
      int totalInscricoes = inscricoesPorGrupo[g.id!] ?? 0;
      if (totalInscricoes > maxY) maxY = totalInscricoes.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: xIndex,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: totalInscricoes.toDouble(),
              width: 30,
              color: Colors.orange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ],
        ),
      );
      xIndex++;
    }

    maxY += 3; // Padding para o eixo Y

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            groupsSpace: 30,
            alignment: BarChartAlignment.spaceAround,
            barGroups: barGroups,
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${grupos[groupIndex].nome}\nTotal: ${rod.toY.toInt()}',
                    const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < grupos.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          grupos[value.toInt()].nome,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Color(0xFFE4E5EB),
                  strokeWidth: 1,
                );
              },
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(bottom: BorderSide()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInscritosEMetasCharts() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Barra de "Inscritos"
            Container(
              width: MediaQuery.of(context).size.width / 2 -
                  1, // Metade da largura
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              color: const Color.fromRGBO(175, 175, 175, 0.24),
              child: const Center(
                child: Text(
                  'Inscritos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            // Barra de "Metas"
            Container(
              width: MediaQuery.of(context).size.width / 2 -
                  1, // Metade da largura
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              color: const Color.fromRGBO(175, 175, 175, 0.24),
              child: const Center(
                child: Text(
                  'Metas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Gráfico de "Inscritos"
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildGraphContainer(
                  legends: [
                    _buildLegend("Bike", Colors.orange),
                    _buildLegend("Corrida", Colors.yellow),
                  ],
                  child: _buildInscritosChart(),
                  title: "",
                ),
              ),
            ),
            // Gráfico de "Metas"
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildGraphContainer(
                  legends: [
                    _buildLegend("Não Realizada", Colors.orange),
                    _buildLegend("Realizada", Colors.yellow),
                  ],
                  child: _buildMetasChart(),
                  title: "",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGraphContainer(
      {required Widget child,
      required String title,
      required List<Widget> legends}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45, // 45% da largura da tela
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: legends,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150, // Limita a altura dos gráficos
            child: child,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildInscritosChart() {
    // Filtrar inscrições com base nos filtros aplicados (grupo e ano)
    List<InscricaoEvento> filteredInscricoes =
        todasInscricoes.where((inscricao) {
      final evento = eventos.firstWhere((e) => e.id == inscricao.idEvento);

      if (selectedGrupoId != null && evento.idGrupoEvento != selectedGrupoId) {
        return false;
      }

      if (selectedAno != null &&
          DateTime.parse(evento.dataInicioEvento).year != selectedAno) {
        return false;
      }

      return true;
    }).toList();

    int totalInscritos = filteredInscricoes.length;

    if (totalInscritos == 0) {
      return const Center(
        child: Text(
          'Nenhum dado disponível para exibir.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    int bikeCount =
        filteredInscricoes.where((i) => i.idCategoriaBicicleta != null).length;
    int corridaCount = filteredInscricoes
        .where((i) => i.idCategoriaCaminhadaCorrida != null)
        .length;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: bikeCount.toDouble(),
            color: Colors.orange,
            title:
                '${((bikeCount / totalInscritos) * 100).toStringAsFixed(1)}%',
          ),
          PieChartSectionData(
            value: corridaCount.toDouble(),
            color: Colors.yellow,
            title:
                '${((corridaCount / totalInscritos) * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildMetasChart() {
    // Filtrar inscrições com base nos filtros aplicados (grupo e ano)
    List<InscricaoEvento> filteredInscricoes =
        todasInscricoes.where((inscricao) {
      final evento = eventos.firstWhere((e) => e.id == inscricao.idEvento);

      if (selectedGrupoId != null && evento.idGrupoEvento != selectedGrupoId) {
        return false;
      }

      if (selectedAno != null &&
          DateTime.parse(evento.dataInicioEvento).year != selectedAno) {
        return false;
      }

      return true;
    }).toList();

    if (filteredInscricoes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum dado disponível para exibir.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    double totalMetas = 0.0;
    double totalKmPercorridos = 0.0;

    return FutureBuilder(
      future: Future.wait(filteredInscricoes.map((inscricao) async {
        totalMetas += inscricao.meta.toDouble();

        int userId = inscricao.idUsuario;
        int eventoId = inscricao.idEvento;

        // Busca dados estatísticos aprovados para a inscrição
        List<DadosEstatisticosUsuarios> dadosList = await _dadosController
            .fetchDadosEstatisticosUsuario(eventoId, userId);

        for (var dado in dadosList) {
          if (dado.idStatusDadosEstatisticos == 3) {
            totalKmPercorridos += dado.kmPercorrido;
          }
        }
      })),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Erro ao carregar os dados.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Calcular percentual
        double percentualRealizado =
            totalMetas > 0 ? (totalKmPercorridos / totalMetas) * 100 : 0.0;

        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: percentualRealizado,
                color: Colors.yellow,
                title: '${percentualRealizado.toStringAsFixed(1)}%',
              ),
              PieChartSectionData(
                value: 100 - percentualRealizado,
                color: Colors.orange,
                title: '${(100 - percentualRealizado).toStringAsFixed(1)}%',
              ),
            ],
          ),
        );
      },
    );
  }
}
