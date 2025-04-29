part of '../../../env.dart';

class MeuDesafioPage extends StatefulWidget {
  final Evento evento;

  const MeuDesafioPage({super.key, required this.evento});

  @override
  MeuDesafioPageState createState() => MeuDesafioPageState();
}

class MeuDesafioPageState extends State<MeuDesafioPage> {
  final InscricaoController _inscricaoController = InscricaoController();
  final DadosEstatisticosUsuariosController _dadosController =
      DadosEstatisticosUsuariosController();
  late UserController _userController;
  final FileController _fileController =
      FileController(); // For downloading event image

  bool _isLoading = true;
  Usuario? _usuario;
  InscricaoEvento? _inscricaoEvento;
  List<DadosEstatisticosUsuarios> _dadosEstatisticos = [];
  double _totalKmPercorrido = 0.0;
  double _meta = 0.0;
  int _percentageCompleted = 0;
  int _percentageRemaining = 100;
  Map<int, double> _weeklyKm = {};
  int _maxWeekNumber = 0;
  int? _idStatusPagamento;

  File? _downloadedEventoImage; // Downloaded event image

  @override
  void initState() {
    super.initState();
    _userController = Provider.of<UserController>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await _userController.fetchCurrentUser();
    if (!mounted) return;

    _usuario = _userController.user;

    _inscricaoEvento = await _inscricaoController.getInscricaoByUserAndEvent(
      userId: _usuario!.id,
      eventId: widget.evento.id!,
    );

    List<DadosEstatisticosUsuarios> allDadosEstatisticos =
        await _dadosController.fetchDadosEstatisticosUsuario(
      widget.evento.id!,
      _usuario!.id,
    );

    _dadosEstatisticos = allDadosEstatisticos
        .where((dados) => dados.idStatusDadosEstatisticos == 3)
        .toList();

    _calculateProgress();

    _idStatusPagamento = null;
    if (_inscricaoEvento != null && _inscricaoEvento!.id != null) {
      try {
        _idStatusPagamento = await PagamentoInscricaoController()
            .fetchPagamentoPorInscricao(_inscricaoEvento!.id!);
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao buscar status do pagamento: $e');
        }
      }
    }

    // Download event image if capaEvento is available
    if (widget.evento.capaEvento != null &&
        widget.evento.capaEvento!.isNotEmpty) {
      try {
        await _fileController
            .downloadFileCapasEvento(widget.evento.capaEvento!);
        _downloadedEventoImage = _fileController.downloadedFile;
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao baixar imagem do evento: $e');
        }
        _downloadedEventoImage = null;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showCompletionPopup(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Fundo do popup
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/pop-up/papel_fundo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '',
                    ),
                    // Botão de compartilhar
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoFramePage(meta: _meta),
                          ),
                        );
                      },
                      child: Image.asset(
                          'assets/pop-up/button_compartilhar.png',
                          width: 200),
                    ),
                  ],
                ),
              ),

              // Botão de fechar (substituído por círculo laranja com X branco)
              Positioned(
                top: 45,
                right: 40,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7801),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculateProgress() {
    _totalKmPercorrido = _dadosEstatisticos.fold(
      0.0,
      (sum, item) => sum + item.kmPercorrido,
    );

    _meta = _inscricaoEvento?.meta.toDouble() ?? 0.0;

    if (_meta > 0) {
      _percentageCompleted = ((_totalKmPercorrido / _meta) * 100).round();
      _percentageCompleted =
          _percentageCompleted > 100 ? 100 : _percentageCompleted;
      _percentageRemaining = 100 - _percentageCompleted;
      if (_percentageCompleted == 100) {
        _showCompletionPopup(context);
      }
    }

    _weeklyKm = {};
    for (var data in _dadosEstatisticos) {
      int weekNumber = data.semana ?? 0;
      _weeklyKm[weekNumber] = (_weeklyKm[weekNumber] ?? 0) + data.kmPercorrido;
      if (weekNumber > _maxWeekNumber) {
        _maxWeekNumber = weekNumber;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidht = MediaQuery.of(context).size.width;
    double textScaleFactor = screenHeight < 668 ? 0.85 : 1.2;
    double titleScaleFactor = screenWidht < 470 ? 0.85 : 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildChallengeImage(),
                        _buildChallengeTitle(titleScaleFactor),
                        _buildParticipantInfo(),
                        const Divider(),
                        _buildProgressVisualization(),
                        _buildActionButtons(screenWidht),
                        const SizedBox(height: 20),
                        _buildBackButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
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
          'Meu Desafio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeImage() {
    Widget imageWidget;
    if (_downloadedEventoImage != null) {
      imageWidget = Image.file(
        _downloadedEventoImage!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        widget.evento.capaEvento ?? 'assets/image/foto01.jpg',
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: imageWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTitle(double titleScaleFactor) {
    //bool isButtonEnabled = _idStatusPagamento == 2 || _idStatusPagamento == 5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.evento.nome,
            style: TextStyle(
              fontSize: 20 * titleScaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildParticipantInfo() {
    bool isButtonEnabled = _idStatusPagamento == 2 || _idStatusPagamento == 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MinhaInscricaoPage(
                    evento: widget.evento,
                    inscricao: _inscricaoEvento!,
                    usuario: _usuario!,
                  ),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Ver Inscrição',
                style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                _inscricaoEvento!.medalhaEntregue ? 'Entregue' : 'Não entregue',
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.workspace_premium,
                color: _inscricaoEvento!.medalhaEntregue
                    ? Colors.yellow[700]
                    : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressVisualization() {
    return Column(
      children: [
        _buildWeeklyProgressBarGraph(),
        const Divider(),
        _buildGoalProgressBar(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWeeklyProgressBarGraph() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gráfico Semanal: Total Percorrido ${_totalKmPercorrido.toStringAsFixed(1)}km',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 10),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          maxY: _getMaxY(),
          barGroups: _getBarGroups(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 0.5,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String km = '${rod.toY}';
                return BarTooltipItem(km, const TextStyle(color: Colors.black));
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getBottomTitles,
                reservedSize: 42,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                interval: _getInterval(),
                reservedSize: 40,
                getTitlesWidget: _getLeftTitles,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: false,
            checkToShowHorizontalLine: (value) => true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  double _getMaxY() {
    double maxY = 0;
    _weeklyKm.forEach((key, value) {
      if (value > maxY) maxY = value;
    });
    return (maxY + 20);
  }

  double _getInterval() {
    double maxY = _getMaxY();
    return maxY / 5;
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= _maxWeekNumber; i++) {
      double km = _weeklyKm[i] ?? 0;
      barGroups.add(
        BarChartGroupData(
          showingTooltipIndicators: [0],
          x: i,
          barRods: [
            BarChartRodData(
              toY: km,
              color: const Color(0xFFFF7801),
              width: 30,
              borderRadius: BorderRadius.circular(1),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );
    String text = 'Sem ${value.toInt()}';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    if (value == 0) return Container();
    return Text('${value.toInt()}km', style: const TextStyle(fontSize: 12));
  }

  Widget _buildGoalProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Minha Meta: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                '${_meta.toStringAsFixed(0).replaceAll('.', ',')}km',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              // const Spacer(),
              // IconButton(
              //   icon: const Icon(Icons.share, color: Colors.black),
              //   onPressed: () {
              //     // Implement share functionality if needed
              //   },
              // ),
            ],
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 30.0,
            percent: _percentageCompleted / 100,
            backgroundColor: Colors.red,
            progressColor: Colors.green,
            animation: true,
            animationDuration: 2000,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.green),
                  const SizedBox(width: 5),
                  Text('Concluída - $_percentageCompleted%'),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.red),
                  const SizedBox(width: 5),
                  Text('Restante - $_percentageRemaining%'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double screenWidth) {
    // Convertendo a string dataFimEvento para DateTime
    DateTime endDate = DateTime.parse(widget.evento.dataFimEvento);
    DateTime now = DateTime.now();

    // Verifica se a dataFimEvento já passou (endDate < now)
    // Se passou, isEventoAtivo é false; caso contrário, true.
    bool isEventoAtivo = now.isAfter(endDate) ? false : true;

    // Verifica se o pagamento está concluído (2) ou é isento (5)
    bool isPagamentoOk = _idStatusPagamento == 2 || _idStatusPagamento == 5;

    // O botão fica habilitado somente se o evento estiver ativo e o pagamento OK
    bool isButtonEnabled = isEventoAtivo && isPagamentoOk;

    final buttons = [
      ElevatedButton.icon(
        onPressed: isButtonEnabled
            ? () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnviarDadosPage(
                      evento: widget.evento,
                      usuario: _usuario!,
                    ),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              }
            : null,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          'Enviar Dados',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Colors.green : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),

      // Se a tela for estreita, coloca um espaçamento vertical
      if (screenWidth < 410) const SizedBox(height: 16),

      ElevatedButton.icon(
        onPressed: isPagamentoOk
            ? () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcompanharDadosPage(
                      evento: widget.evento,
                      usuario: _usuario!,
                    ),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              }
            : null,
        icon: const Icon(Icons.manage_search, color: Colors.white),
        label: const Text(
          'Acompanhar Dados',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPagamentoOk ? Colors.blue : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: screenWidth < 410
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttons,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons,
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
