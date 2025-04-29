part of '../../../env.dart';

class InscricaoPage extends StatefulWidget {
  final Evento? evento;
  final int? manualEventId;

  const InscricaoPage({super.key, this.evento, this.manualEventId});

  @override
  InscricaoPageState createState() => InscricaoPageState();
}

class InscricaoPageState extends State<InscricaoPage> {
  Evento? _evento;
  Premiacao? _premiacao;
  Grupo? _grupo;
  Usuario? _usuario;
  bool _isLoading = true;
  String? _selectedModalidade;
  String? _selectedCategoryCiclismo;
  String? _selectedCategoryCorridaCaminhada;
  List<String> categoriasCiclismo = [];
  List<String> categoriasCorridaCaminhada = [];
  bool _isSelectable = true;
  bool _isInscrito =
      false; // Variável para checar se o usuário já está inscrito
  int? idInscricao; // Armazena o ID da inscrição caso exista
  int? idPagamento;
  bool termoCiente = false; // Declaração do termo

  final EventoService _eventoService = EventoService();
  final PremiacaoController _premiacaoController = PremiacaoController();
  final GrupoController _grupoController = GrupoController();
  final UserController _userController = UserController();
  final CategoriaBicicletaController _categoriaBicicletaController =
      CategoriaBicicletaController();
  final CategoriaCaminhadaCorridaController
      _categoriaCaminhadaCorridaController =
      CategoriaCaminhadaCorridaController();
  final InscricaoController _inscricaoController = InscricaoController();
  final PagamentoInscricaoController _pagamentoInscricaoController =
      PagamentoInscricaoController();
  final DadosBancariosController _dadosBancariosController =
      DadosBancariosController();
  final CampoPersonalizadoController _campoPersonalizadoController =
      CampoPersonalizadoController();
  final RespCampoPersonalizadoEventoController
      _respCampoPersonalizadoEventoController =
      RespCampoPersonalizadoEventoController();
  final FileController _fileController = FileController();
  File? _downloadedEventoImage;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadEventoData();
    await _loadUserData();
    await _checkInscricao();
    await _loadEventoImage(); // Download the event image if available
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadEventoImage() async {
    // Download event image if capaEvento is available
    if (_evento?.capaEvento != null && _evento!.capaEvento!.isNotEmpty) {
      try {
        await _fileController.downloadFileCapasEvento(_evento?.capaEvento!);
        _downloadedEventoImage = _fileController.downloadedFile;
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao baixar imagem do evento: $e');
        }
        _downloadedEventoImage = null;
      }
    }
  }

  Future<void> _loadEventoData() async {
    try {
      int? id = widget.evento?.id ?? widget.manualEventId;
      if (id != null) {
        Evento evento = await _eventoService.getEventoById(id);
        setState(() {
          _evento = evento;
          _isSelectable = evento.idModalidadeEvento == 3;
          _selectedModalidade =
              null; // reseta a modalidade ao carregar um evento

          // Adiciona mensagem de debug para verificar o idModalidadeEvento
          if (kDebugMode) {
            print(
                'Evento carregado: ${evento.nome}, Modalidade: ${evento.idModalidadeEvento}');
          }

          // Definir modalidade e carregar categorias
          if (evento.idModalidadeEvento == 1) {
            _selectedModalidade = 'Ciclismo';
            _loadCategoriasCiclismo();
          } else if (evento.idModalidadeEvento == 2) {
            _selectedModalidade = 'Caminhada/Corrida';
            _loadCategoriasCorridaCaminhada();
          }
        });

        _loadPremiacaoData(evento.idPremiacaoEvento);
        _loadGrupoData(evento.idGrupoEvento);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento inválido ou não encontrado.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os dados do evento: $e')),
      );
    }
  }

  Future<void> _loadCategoriasCiclismo() async {
    await _categoriaBicicletaController.fetchCategorias();
    setState(() {
      categoriasCiclismo = _categoriaBicicletaController.categorias
          .map((categoria) => '${categoria.descricao} - ${categoria.distancia}')
          .toList();
    });
  }

  Future<void> _loadCategoriasCorridaCaminhada() async {
    await _categoriaCaminhadaCorridaController.fetchCategorias();
    setState(() {
      categoriasCorridaCaminhada = _categoriaCaminhadaCorridaController
          .categorias
          .map((categoria) => '${categoria.descricao} - ${categoria.distancia}')
          .toList();
    });
  }

  Future<void> _loadPremiacaoData(int idPremiacao) async {
    try {
      await _premiacaoController.fetchPremiacaoById(idPremiacao);
      setState(() {
        _premiacao = _premiacaoController.selectedPremiacao;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar dados da premiação: $e');
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados da premiação.')),
      );
    }
  }

  Future<void> _loadGrupoData(int idGrupo) async {
    try {
      await _grupoController.fetchGrupoById(idGrupo);
      setState(() {
        _grupo = _grupoController.selectedGrupo;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar dados do grupo: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados do grupo.')),
      );
    }
  }

  Future<void> _loadUserData() async {
    try {
      await _userController.fetchCurrentUser();
      setState(() {
        _usuario = _userController.user;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar dados do usuário: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados do usuário.')),
      );
    }
  }

  /*Future<void> _loadPagamentoEvento() async {
    await _pagamentoInscricaoController.fetchPagamentosInscricoes();
    print(widget.);
    setState(() {
      _pagamentoEvento = _pagamentoInscricaoController.selectedPagamento;
    });
  }*/

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Voltar',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlterarDadosButton(
      double screenWidth, double screenHeight, double scaleFactor) {
    return SizedBox(
      height: screenHeight * 0.045, // Altura fixa
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/perfil');
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              size: 15.0,
              color: Colors.black,
            ),
            SizedBox(width: 2),
            Text(
              'Alterar Dados',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadPagamentoForInscricao(int idInscricao) async {
    try {
      // Obtém a lista de todos os pagamentos
      await _pagamentoInscricaoController.fetchPagamentosInscricoes();

      // Filtra para encontrar o pagamento com o idInscricao desejado
      PagamentoInscricao? pagamento =
          _pagamentoInscricaoController.pagamentoList.firstWhere(
        (p) => p.idInscricaoEvento == idInscricao,
      );

      // Atualiza o estado com o ID do pagamento encontrado
      setState(() {
        idPagamento = pagamento.id;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar o pagamento: $e')),
      );
    }
  }

  Future<void> _saveEvent() async {
    int? idCategoriaBicicletaTipo;
    int? idCategoriaCaminhadaCorridaTipo;

    // Verifique se o evento é isento
    int idStatusInscricaoTipo = _evento!.isentoPagamento
        ? 7
        : 1; // 7 = Isenta, 1 = Pendente de Pagamento
    int idEvento = _evento!.id!;
    int meta = 0;

    String distanciaString;

    if (_selectedModalidade == 'Ciclismo') {
      distanciaString = _selectedCategoryCiclismo!.split(' - ')[1];
      meta = int.parse(distanciaString.replaceAll(RegExp(r'[^0-9]'), ''));
      idCategoriaBicicletaTipo = _categoriaBicicletaController.categorias
          .firstWhere((c) =>
              '${c.descricao} - ${c.distancia}' == _selectedCategoryCiclismo)
          .id;
    } else if (_selectedModalidade == 'Caminhada/Corrida') {
      distanciaString = _selectedCategoryCorridaCaminhada!.split(' - ')[1];
      meta = int.parse(distanciaString.replaceAll(RegExp(r'[^0-9]'), ''));
      idCategoriaCaminhadaCorridaTipo = _categoriaCaminhadaCorridaController
          .categorias
          .firstWhere((c) =>
              '${c.descricao} - ${c.distancia}' ==
              _selectedCategoryCorridaCaminhada)
          .id;
    }

    int idUsuario = _usuario!.id;
    DateTime criadoEm = DateTime.now();
    DateTime atualizadoEm = DateTime.now();

    try {
      // Criação da inscrição no evento
      await _inscricaoController.criarInscricao(
        context,
        InscricaoEvento(
          idUsuario: idUsuario,
          idCategoriaBicicleta: idCategoriaBicicletaTipo,
          idCategoriaCaminhadaCorrida: idCategoriaCaminhadaCorridaTipo,
          idStatusInscricaoTipo: idStatusInscricaoTipo, // Status ajustado aqui
          idEvento: idEvento,
          meta: meta,
          medalhaEntregue: false,
          termoCiente: termoCiente,
          criadoEm: criadoEm,
          atualizadoEm: atualizadoEm,
        ),
      );

      // Após criar a inscrição, obtemos o id da inscrição
      InscricaoEvento? inscricao =
          await _inscricaoController.getInscricaoByUserAndEvent(
        userId: _usuario!.id,
        eventId: _evento!.id!,
      );

      if (inscricao != null) {
        idInscricao = inscricao.id;

        // Criação do pagamento e captura do ID
        int idStatusPagamento =
            _evento!.isentoPagamento ? 5 : 1; // Define o status do pagamento
        PagamentoInscricao? pagamentoCriado =
            await _createPagamentoInscricao(idInscricao!, idStatusPagamento);

        setState(() {
          idPagamento =
              pagamentoCriado?.id; // Atualiza o idPagamento no estado da tela
        });

        if (!mounted) return;

        // Exibe mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscrição realizada com sucesso!')),
        );

        if (!mounted) return;

        if (_evento!.isentoPagamento) {
          Navigator.pushReplacementNamed(
              context, '/home'); // Volta para a lista de eventos
        } else {
          _navigateToPayments(); // Navega para a tela de pagamentos com o ID atualizado
        }
      } else {
        throw Exception('Erro ao recuperar a inscrição');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar inscrição: $e')),
      );
    }
  }

  Future<void> _checkInscricao() async {
    if (_usuario != null && _evento != null) {
      try {
        _isInscrito = await _inscricaoController.isUserInscrito(
          userId: _usuario!.id,
          eventId: _evento!.id!,
        );

        if (_isInscrito) {
          _isSelectable = false;
          await _loadCategoriasCiclismo();
          await _loadCategoriasCorridaCaminhada();

          // Carrega os dados da inscrição e do pagamento
          InscricaoEvento? inscricao =
              await _inscricaoController.getInscricaoByUserAndEvent(
            userId: _usuario!.id,
            eventId: _evento!.id!,
          );

          if (inscricao != null) {
            setState(() {
              idInscricao = inscricao.id;
              // Defina a modalidade com base na categoria inscrita
              if (inscricao.idCategoriaBicicleta != null) {
                _selectedModalidade = 'Ciclismo';
                _selectedCategoryCiclismo = categoriasCiclismo.firstWhere(
                  (categoria) => categoria.contains(inscricao.meta.toString()),
                  orElse: () => '', // Valor padrão é uma string vazia
                );
              } else if (inscricao.idCategoriaCaminhadaCorrida != null) {
                _selectedModalidade = 'Caminhada/Corrida';
                _selectedCategoryCorridaCaminhada =
                    categoriasCorridaCaminhada.firstWhere(
                  (categoria) => categoria.contains(inscricao.meta.toString()),
                  orElse: () => '', // Valor padrão é uma string vazia
                );
              }
            });
            await _loadPagamentoForInscricao(inscricao.id!);
          }
        } else {
          setState(() {
            _isInscrito = false;
          });
        }

        // Adição da lógica para ajustar o estado do botão com base no evento
        if (_isInscrito) {
          if (_evento!.isentoPagamento) {
            setState(() {
              // Desabilita o botão e mostra "EVENTO ISENTO"
              _isSelectable = false;
            });
          } else {
            setState(() {
              // Mostra o botão "Ir para Pagamentos"
              _isSelectable = false;
            });
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar inscrição: $e')),
        );
      }
    }
  }

  void _navigateToPayments() {
    if (idInscricao != null && idPagamento != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PagamentoPage(
            inscricaoEventoId: idInscricao!,
            pagamentoId:
                idPagamento!, // Use o valor do pagamento, se necessário
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erro: ID da inscrição ou do pagamento não encontrado.')),
      );
    }
  }

  // Função para exibir o popup de termo
  Future<void> _showTermoDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Confirmação de Termo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Durante o desafio daremos dicas e sugestões visando que você atinja uma melhor saúde, porém cada participante é responsável pela sua saúde e deverá procurar um médico caso sinta algum problema de saúde.',
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        termoCiente = true;
                      });
                      Navigator.of(context).pop(); // Fecha o diálogo
                      if (termoCiente) {
                        _saveEvent();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    child: const Text(
                      'Ciente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _hasRequiredFieldsFilled(Usuario usuario) {
    return usuario.idSexoTipo != null &&
        usuario.idEstadoCivilTipo != null &&
        usuario.idEndereco != null &&
        usuario.idGrupoEvento != null &&
        //usuario.nome != null &&
        usuario.nome.isNotEmpty &&
        //usuario.email != null &&
        usuario.email.isNotEmpty &&
        usuario.cpf != null &&
        usuario.cpf!.isNotEmpty &&
        usuario.celular != null &&
        usuario.celular!.isNotEmpty &&
        usuario.dataNascimento != null &&
        usuario.altura != null &&
        usuario.peso != null &&
        usuario.profissao != null &&
        usuario.profissao!.isNotEmpty;
  }

  // Função para salvar o evento, alterada para primeiro exibir o termo
  /*Future<void> _confirmAndSaveEvent() async {
    // Verifique se o usuário tem os campos obrigatórios preenchidos
    if (_usuario == null || !_hasRequiredFieldsFilled(_usuario!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Existem campos obrigatórios no seu perfil que precisam ser preenchidos. Por favor, clique no botão "Alterar Dados" para atualizá-los',
          ),
        ),
      );
      return;
    }
    if (_grupo != null) {
      await _verificarCamposPersonalizadosObrigatorios();
    }

    // Verifica se a modalidade e a categoria estão selecionadas
    if ((_selectedModalidade == 'Ciclismo' &&
            _selectedCategoryCiclismo == null) ||
        (_selectedModalidade == 'Caminhada/Corrida' &&
            _selectedCategoryCorridaCaminhada == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      return;
    }

    // Exibe o popup de confirmação de termo antes de salvar o evento
  }*/

// Método para confirmar e salvar o evento
  Future<void> _confirmAndSaveEvent() async {
    // Verifica se o usuário tem os campos obrigatórios preenchidos
    if (_usuario == null || !_hasRequiredFieldsFilled(_usuario!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Existem campos obrigatórios no seu perfil que precisam ser preenchidos. Por favor, clique no botão "Alterar Dados" para atualizá-los.',
          ),
        ),
      );
      return; // Interrompe a execução se os campos obrigatórios não estiverem preenchidos
    }

    if (_grupo != null) {
      await _verificarCamposPersonalizadosObrigatorios();
      return;
    }

    // Verifica se uma modalidade foi selecionada
    if (_selectedModalidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma modalidade.'),
        ),
      );
      return; // Interrompe a execução
    }

    // Verifica se uma categoria foi selecionada de acordo com a modalidade
    if ((_selectedModalidade == 'Ciclismo' &&
            _selectedCategoryCiclismo == null) ||
        (_selectedModalidade == 'Caminhada/Corrida' &&
            _selectedCategoryCorridaCaminhada == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, selecione uma categoria para a modalidade escolhida.'),
        ),
      );
      return; // Interrompe a execução
    }

    // Se todas as condições forem atendidas, exibe o termo
    await _showTermoDialog();
  }

  Future<void> _verificarCamposPersonalizadosObrigatorios() async {
    try {
      // Carregar os campos personalizados do grupo
      await _campoPersonalizadoController.fetchCamposPersonalizados(
          idGruposEvento: _grupo!.id);

      // Filtrar campos obrigatórios
      List<CampoPersonalizado> camposObrigatorios =
          _campoPersonalizadoController.campoList
              .where((campo) => campo.obrigatorio)
              .toList();

      if (camposObrigatorios.isEmpty) {
        // Não existem campos obrigatórios, prosseguir
        await _showTermoDialog();
        return;
      }

      // Buscar respostas do usuário
      await _respCampoPersonalizadoEventoController
          .fetchRespostasCamposPersonalizados(idUsuario: _usuario!.id);
      List<RespCampoPersonalizadoEvento> respostas =
          _respCampoPersonalizadoEventoController.respList;

      // Verificar se todas os campos obrigatórios têm respostas válidas
      bool todasPreenchidas = camposObrigatorios.every((campo) {
        final resposta = respostas.firstWhere(
          (resp) => resp.idCamposPersonalizados == campo.id,
          orElse: () => RespCampoPersonalizadoEvento(
              id: null,
              idCamposPersonalizados: campo.id!,
              idUsuario: _usuario!.id,
              respostaCampo: ''),
        );
        return resposta.respostaCampo.trim().isNotEmpty;
      });

      if (!todasPreenchidas) {
        if (!mounted) return;
        // Existe pelo menos um campo obrigatório não preenchido ou vazio
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Existem campos obrigatórios no seu perfil que precisam ser preenchidos. Por favor, clique no botão "Alterar Dados" para atualizá-los.',
            ),
          ),
        );
      } else {
        // Todos os campos obrigatórios foram preenchidos, prosseguir com a inscrição
        await _showTermoDialog();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar campos personalizados: $e')),
      );
    }
  }

// Função para criar o pagamento de inscrição
  Future<PagamentoInscricao?> _createPagamentoInscricao(
      int idInscricaoEvento, int idStatusPagamento) async {
    // Busca a inscrição do evento com base no usuário e evento
    InscricaoEvento? inscricao =
        await _inscricaoController.getInscricaoByUserAndEvent(
      userId: _usuario!.id,
      eventId: _evento!.id!,
    );

    if (inscricao == null) {
      throw Exception('Inscrição não encontrada para o evento e usuário.');
    }

    // Busca os dados bancários do usuário
    await _dadosBancariosController.fetchDadosBancariosByUsuario(1);
    DadosBancarios? dadosBancarios = _dadosBancariosController.dadosBancarios;

    if (dadosBancarios == null) {
      throw Exception('Dados bancários não encontrados para o usuário.');
    }

    try {
      if (!mounted) return null;
      // Cria o pagamento e retorna o objeto criado
      PagamentoInscricao pagamentoCriado =
          await _pagamentoInscricaoController.createPagamentoInscricao(
        context,
        PagamentoInscricao(
          idUsuario: _usuario!.id,
          idInscricaoEvento: inscricao.id!,
          idDadosBancariosAdm: dadosBancarios.id!,
          idStatusPagamento: idStatusPagamento,
          comprovante: '',
          dataPagamento: DateTime.now(),
        ),
      );
      return pagamentoCriado; // Retorna o pagamento criado
    } catch (e) {
      throw Exception('Erro ao criar o pagamento: $e');
    }
  }

  Widget _buildSaveButton(
      double screenWidth, double screenHeight, double scaleFactor) {
    return SizedBox(
      height: screenHeight * 0.045, // Altura fixa
      child: Center(
        child: ElevatedButton(
          onPressed: (_isInscrito && _evento!.isentoPagamento)
              ? null // Desabilita o botão quando o evento é isento
              : _isInscrito
                  ? _navigateToPayments
                  : _confirmAndSaveEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: (_isInscrito && _evento!.isentoPagamento)
                ? Colors.grey
                : Colors.green, // Cor cinza se for evento isento
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02 * scaleFactor,
            ),
            fixedSize:
                Size(screenWidth * 0.40, 40 * scaleFactor), // Tamanho escalado
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8 * scaleFactor), // Escala da borda
            ),
          ),
          child: Text(
            (_isInscrito && _evento!.isentoPagamento)
                ? 'EVENTO ISENTO'
                : _isInscrito
                    ? 'Ir para Pagamentos'
                    : 'Inscrever',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage(double screenHeight, double buttonScaleFactor) {
    Widget eventImage;
    if (_downloadedEventoImage != null) {
      eventImage = Image.file(
        _downloadedEventoImage!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      eventImage = Image.asset(
        _evento?.capaEvento ?? 'assets/image/foto01.jpg',
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * buttonScaleFactor),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0), child: eventImage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430; // Adapte para sua base de design
    double textScaleFactor =
        screenHeight < 668 ? 0.85 : 1.2; // Fator de escala do texto
    //double iconScaleFactor =
    screenHeight < 668 ? 0.8 : 1.0; // Fator de escala dos ícones
    double buttonScaleFactor =
        screenHeight < 668 ? 0.8 : 1.0; // Fator de escala dos botões

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _evento != null
              ? Column(
                  children: [
                    // Parte fixa que não rola
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
                                'Inscrição',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      22 * textScaleFactor, // Escala do texto
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Parte rolável
                    // Parte rolável
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Imagem do evento
                            _buildEventImage(screenHeight, buttonScaleFactor),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40.0 * buttonScaleFactor),
                              child: Text(
                                '${_evento?.nome ?? 'Título do Evento'} - ${_grupo?.nome ?? 'Nenhum'}',
                                style: TextStyle(
                                  fontSize:
                                      22 * textScaleFactor, // Escala do texto
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Restante da UI
                            const SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0 * buttonScaleFactor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'Local: ',
                                      style: TextStyle(
                                        fontSize: 15 *
                                            textScaleFactor, // Escala do texto
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _evento?.local ??
                                              'Não disponível',
                                          style: TextStyle(
                                            fontSize: 13 *
                                                textScaleFactor, // Escala do texto
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Premiação: ',
                                      style: TextStyle(
                                        fontSize: 15 * textScaleFactor,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _premiacao?.nome ?? 'Nenhuma',
                                          style: TextStyle(
                                            fontSize: 13 * textScaleFactor,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Período de Inscrição: ',
                                      style: TextStyle(
                                        fontSize: 15 * textScaleFactor,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${_formatDate(_evento?.dataInicioInscricoes)} a ${_formatDate(_evento?.dataFimInscricoes)}',
                                          style: TextStyle(
                                            fontSize: 13 * textScaleFactor,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Duração do Evento: ',
                                      style: TextStyle(
                                        fontSize: 15 * textScaleFactor,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${_formatDate(_evento?.dataInicioEvento)} a ${_formatDate(_evento?.dataFimEvento)}',
                                          style: TextStyle(
                                            fontSize: 13 * textScaleFactor,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Descrição: ',
                                      style: TextStyle(
                                        fontSize: 15 * textScaleFactor,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _evento?.descricao ??
                                              'Não disponível',
                                          style: TextStyle(
                                            fontSize: 13 * textScaleFactor,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16 * buttonScaleFactor),
                              color: const Color(0xFFFF7801),
                              child: Text(
                                'FORMULÁRIO DE INSCRIÇÃO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      14 * textScaleFactor, // Escala do texto
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0), // Espaçamento consistente
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '*Revise os dados e, se preciso, clique em "Alterar dados"',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Nome: ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _usuario?.nome ??
                                              'Não disponível',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Telefone: ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _usuario?.celular ??
                                              'Não disponível',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      text: 'E-mail: ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _usuario?.email ??
                                              'Não disponível',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Grupo: ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              _grupo?.nome ?? 'Não disponível',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // InputDecorator contendo as opções de modalidades
                                        InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Escolha uma modalidade',
                                            labelStyle: const TextStyle(
                                              color: Colors.black,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // Primeiro RadioListTile para 'Ciclismo'
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  contentPadding: EdgeInsets
                                                      .zero, // Remove o padding entre a bolinha e a borda
                                                  dense:
                                                      true, // Reduz a altura do RadioListTile
                                                  title: Transform.translate(
                                                    offset: const Offset(-16,
                                                        0), // Aproxima o texto da bolinha
                                                    child: Text(
                                                      'Ciclismo',
                                                      style: TextStyle(
                                                          fontSize: 13 *
                                                              textScaleFactor),
                                                    ),
                                                  ),
                                                  value: 'Ciclismo',
                                                  groupValue:
                                                      _selectedModalidade,
                                                  activeColor:
                                                      const Color(0xFFFF7801),
                                                  onChanged: (_isSelectable ||
                                                          widget.evento
                                                                  ?.idModalidadeEvento ==
                                                              1)
                                                      ? (String? value) {
                                                          setState(() {
                                                            _selectedModalidade =
                                                                value;
                                                            _selectedCategoryCiclismo =
                                                                null;
                                                            _loadCategoriasCiclismo();
                                                          });
                                                        }
                                                      : null,
                                                ),
                                              ),
                                              // Adiciona um SizedBox com largura pequena entre os RadioListTile
                                              const SizedBox(
                                                  width:
                                                      8), // Ajuste esse valor para controlar o espaço entre eles
                                              // Segundo RadioListTile para 'Caminhada/Corrida'
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  contentPadding: EdgeInsets
                                                      .zero, // Remove o padding entre a bolinha e a borda
                                                  dense:
                                                      true, // Reduz a altura do RadioListTile
                                                  title: Transform.translate(
                                                    offset: const Offset(-16,
                                                        0), // Aproxima o texto da bolinha
                                                    child: Text(
                                                      'Caminhada/Corrida',
                                                      style: TextStyle(
                                                          fontSize: 13 *
                                                              textScaleFactor),
                                                    ),
                                                  ),
                                                  value: 'Caminhada/Corrida',
                                                  groupValue:
                                                      _selectedModalidade,
                                                  activeColor:
                                                      const Color(0xFFFF7801),
                                                  onChanged: (_isSelectable ||
                                                          widget.evento
                                                                  ?.idModalidadeEvento ==
                                                              2)
                                                      ? (String? value) {
                                                          setState(() {
                                                            _selectedModalidade =
                                                                value;
                                                            _selectedCategoryCorridaCaminhada =
                                                                null;
                                                            _loadCategoriasCorridaCaminhada();
                                                          });
                                                        }
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Código do _buildCategoriaSelector diretamente aqui
                                        _selectedModalidade == 'Ciclismo'
                                            ? CustomDropdownButton(
                                                value:
                                                    _selectedCategoryCiclismo,
                                                hint: 'Escolha uma categoria',
                                                items: categoriasCiclismo,
                                                onChanged: _isInscrito
                                                    ? null // Função vazia quando desativado
                                                    : (String? newValue) {
                                                        setState(() {
                                                          _selectedCategoryCiclismo =
                                                              newValue;
                                                        });
                                                      },
                                                isEnabled: !_isInscrito,
                                                inputDecoration:
                                                    InputDecoration(
                                                  hintStyle: const TextStyle(
                                                      color: Colors.black),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black),
                                                  labelText:
                                                      'Escolha uma categoria',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : CustomDropdownButton(
                                                value:
                                                    _selectedCategoryCorridaCaminhada,
                                                hint: 'Escolha uma categoria',
                                                items:
                                                    categoriasCorridaCaminhada,
                                                onChanged: _isInscrito
                                                    ? null // Função vazia quando desativado
                                                    : (String? newValue) {
                                                        setState(() {
                                                          _selectedCategoryCorridaCaminhada =
                                                              newValue;
                                                        });
                                                      },
                                                isEnabled: !_isInscrito,
                                                inputDecoration:
                                                    InputDecoration(
                                                  hintStyle: const TextStyle(
                                                      color: Colors.black),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black),
                                                  labelText:
                                                      'Escolha uma categoria',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),

                                        // Problema de saúde
                                        RichText(
                                          text: TextSpan(
                                            text:
                                                'Possui algum problema de saúde? ',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: _usuario?.problemaSaude
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? 'Sim'
                                                    : 'Não',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_usuario
                                                ?.problemaSaude?.isNotEmpty ==
                                            true)
                                          RichText(
                                            text: TextSpan(
                                              text: 'Descrição: ',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _usuario!.problemaSaude,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        const SizedBox(height: 2),

                                        // Aplicativo de atividade
                                        RichText(
                                          text: TextSpan(
                                            text: 'Qual app você usa? ',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: _usuario
                                                        ?.aplicativoAtividades ??
                                                    'Não especificado',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        // Atividade física
                                        RichText(
                                          text: TextSpan(
                                            text:
                                                'Pratica alguma atividade física? ',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: _usuario
                                                            ?.atividadeFisicaRegular
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? 'Sim'
                                                    : 'Não',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_usuario?.atividadeFisicaRegular
                                                ?.isNotEmpty ==
                                            true)
                                          RichText(
                                            text: TextSpan(
                                              text: 'Descrição: ',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _usuario!
                                                      .atividadeFisicaRegular,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        const SizedBox(height: 2),

                                        // Peso
                                        RichText(
                                          text: TextSpan(
                                            text: 'Seu peso: ',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${_usuario?.peso?.toStringAsFixed(2) ?? 'Não especificado'} kg',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  //SizedBox(height: 2),
                                  _buildAlterarDadosButton(
                                      screenWidth, screenHeight, scaleFactor),
                                  const SizedBox(height: 40),
                                  _buildSaveButton(
                                      screenWidth, screenHeight, scaleFactor),
                                  //SizedBox(height: 10),
                                  _buildBackButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text('Evento não encontrado.'),
                ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  // Função para formatar datas (adapte conforme o formato de suas datas)
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Data não disponível';
    DateTime date = DateTime.parse(dateStr);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
