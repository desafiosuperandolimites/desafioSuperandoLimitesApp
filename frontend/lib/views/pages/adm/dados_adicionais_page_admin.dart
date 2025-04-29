part of '../../env.dart';

class DadosAdicionaisPageAdmin extends StatefulWidget {
  const DadosAdicionaisPageAdmin({super.key}); // Adicionando isAdminMode);

  @override
  DadosAdicionaisPageAdminState createState() =>
      DadosAdicionaisPageAdminState();
}

class DadosAdicionaisPageAdminState extends State<DadosAdicionaisPageAdmin> {
  final TextEditingController _selectedAppController = TextEditingController();
  final TextEditingController _problemaSaudeController =
      TextEditingController();
  final TextEditingController _atividadeFisicaController =
      TextEditingController();
  final MaskedTextController _alturaController = Mascaras.alturaController();
  final TextEditingController _pesoController = TextEditingController();
  final GrupoController _grupoController = GrupoController();
  final CampoPersonalizadoController _campoPersonalizadoController =
      CampoPersonalizadoController();
  final Map<int, List<OpcaoCampo>> _opcoesCampoMap = {};
  final Map<int, TextEditingController> _responseControllers = {};
  final Map<int, String?> _selectedOpcaoText = {};
  final RespCampoPersonalizadoEventoController
      _respCampoPersonalizadoController =
      RespCampoPersonalizadoEventoController();

  bool? _possuiProblemaSaude;
  bool? _praticaAtividadeFisica;
  List<Grupo> grupos = [];
  int? _selectedGroup;
  Map<int, RespCampoPersonalizadoEvento> _existingAnswers = {};
  List<CampoPersonalizado> _camposPersonalizados = [];

  void _populateUserData(Usuario user) {
    // Populate text fields with user data, converting numeric types to string
    _alturaController.text = user.altura != null ? user.altura.toString() : '';
    _pesoController.text = user.peso != null ? user.peso.toString() : '';

    // Boolean flags for radio buttons
    _possuiProblemaSaude =
        user.problemaSaude != "" && user.problemaSaude != null;
    _praticaAtividadeFisica = user.atividadeFisicaRegular != "" &&
        user.atividadeFisicaRegular != null;

    // Populate additional information fields if the flags are true
    _problemaSaudeController.text = user.problemaSaude ?? '';
    _atividadeFisicaController.text = user.atividadeFisicaRegular ?? '';

    // Populate the app used field
    _selectedAppController.text = user.aplicativoAtividades ?? '';
    _selectedGroup = user.idGrupoEvento;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final userController = Provider.of<UserController>(context, listen: false);
    final user = userController.user;

    if (user != null) {
      _populateUserData(user);
      _selectedGroup = user.idGrupoEvento;
    }

    _loadGruposFromBackend();
    if (_selectedGroup != null) {
      _fetchCamposPersonalizados();
    }
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
  }

  Future<void> _fetchCamposPersonalizados() async {
    if (_selectedGroup != null) {
      await _campoPersonalizadoController.fetchCamposPersonalizados(
          idGruposEvento: _selectedGroup!);
      await _fetchExistingAnswers();
      // Filter campos where situacao == true
      _camposPersonalizados = _campoPersonalizadoController.campoList
          .where((campo) => campo.situacao == true)
          .toList();

      // Fetch options for all RADIOBUTTON campos
      await _fetchOpcoesForAllCampos();

      setState(() {
        _initializeResponseControllers();
      });
    }
  }

  Future<void> _fetchOpcoesForAllCampos() async {
    OpcaoCampoController opcaoCampoController = OpcaoCampoController();
    List<Future<void>> fetches = [];

    for (var campo in _camposPersonalizados) {
      if (campo.idTipoCampo == 2) {
        // RADIOBUTTON type
        Future<void> fetch = opcaoCampoController
            .fetchOpcoesCampo(idCamposPersonalizados: campo.id!)
            .then((_) {
          List<OpcaoCampo> opcoes =
              List<OpcaoCampo>.from(opcaoCampoController.opcaoList);
          _opcoesCampoMap[campo.id!] = opcoes;
        });
        fetches.add(fetch);
      }
    }

    await Future.wait(fetches);
  }

  Future<void> _fetchExistingAnswers() async {
    final userController = Provider.of<UserController>(context, listen: false);
    if (userController.user != null) {
      await _respCampoPersonalizadoController
          .fetchRespostasCamposPersonalizados(
        idUsuario: userController.user!.id,
      );
      List<RespCampoPersonalizadoEvento> respostas =
          _respCampoPersonalizadoController.respList;
      _existingAnswers = {
        for (var resp in respostas) resp.idCamposPersonalizados: resp
      };
    }
  }

  String? _validateRequiredCamposPersonalizados() {
    for (var campo in _camposPersonalizados) {
      if (campo.obrigatorio == true) {
        if (campo.idTipoCampo == 3) {
          // 'TEXT' type
          String resposta = _responseControllers[campo.id!]!.text;
          if (resposta.trim().isEmpty) {
            return 'O campo "${campo.nomeCampo}" é obrigatório.';
          }
        } else if (campo.idTipoCampo == 2) {
          // 'RADIOBUTTON' type
          String? opcaoTexto = _selectedOpcaoText[campo.id!];
          if (opcaoTexto == null || opcaoTexto.trim().isEmpty) {
            return 'O campo "${campo.nomeCampo}" é obrigatório.';
          }
        }
      }
    }
    return null;
  }

  void _initializeResponseControllers() {
    _responseControllers.clear();
    _selectedOpcaoText.clear();
    for (var campo in _camposPersonalizados) {
      RespCampoPersonalizadoEvento? existingAnswer =
          _existingAnswers[campo.id!];
      if (campo.idTipoCampo == 3) {
        // 'TEXT' type
        _responseControllers[campo.id!] = TextEditingController(
          text: existingAnswer?.respostaCampo ?? '',
        );
      } else if (campo.idTipoCampo == 2) {
        // 'RADIOBUTTON' type
        _selectedOpcaoText[campo.id!] = existingAnswer?.respostaCampo;
      }
    }
  }

  Future<void> _saveRespostasCamposPersonalizados() async {
    final userController = Provider.of<UserController>(context, listen: false);
    if (_camposPersonalizados.isNotEmpty && userController.user != null) {
      List<RespCampoPersonalizadoEvento> respostasToCreate = [];
      List<RespCampoPersonalizadoEvento> respostasToUpdate = [];
      for (var campo in _camposPersonalizados) {
        // Existing answer if any
        RespCampoPersonalizadoEvento? existingAnswer =
            _existingAnswers[campo.id!];
        // Collect responses
        if (campo.idTipoCampo == 3) {
          // 'TEXT' type
          String resposta = _responseControllers[campo.id!]!.text;
          RespCampoPersonalizadoEvento resp = RespCampoPersonalizadoEvento(
            id: existingAnswer?.id,
            idCamposPersonalizados: campo.id!,
            idUsuario: userController.user!.id,
            respostaCampo: resposta,
          );
          if (existingAnswer != null) {
            respostasToUpdate.add(resp);
          } else {
            respostasToCreate.add(resp);
          }
        } else if (campo.idTipoCampo == 2) {
          // 'RADIOBUTTON' type
          String? opcaoTexto = _selectedOpcaoText[campo.id!];
          if (opcaoTexto != null) {
            RespCampoPersonalizadoEvento resp = RespCampoPersonalizadoEvento(
              id: existingAnswer?.id,
              idCamposPersonalizados: campo.id!,
              idUsuario: userController.user!.id,
              respostaCampo: opcaoTexto,
            );
            if (existingAnswer != null) {
              respostasToUpdate.add(resp);
            } else {
              respostasToCreate.add(resp);
            }
          }
        }
      }
      // Save responses to backend
      await _respCampoPersonalizadoController.saveRespostas(
        respostasToCreate: respostasToCreate,
        respostasToUpdate: respostasToUpdate,
      );
    }
  }

  Future<void> _saveAdditionalData(UserController userController) async {
    final alturaError = Validacoes.validateAltura(_alturaController.text);
    final pesoError = Validacoes.validatePeso(_pesoController.text);

    if (alturaError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(alturaError)));
      return;
    }

    if (pesoError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(pesoError)));
      return;
    }

    // Validate required custom fields
    final camposValidationError = _validateRequiredCamposPersonalizados();
    if (camposValidationError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(camposValidationError)));
      return;
    }

    if (userController.user != null) {
      Usuario updatedUser = Usuario(
        id: userController.user!.id,
        nome: userController.user!.nome,
        email: userController.user!.email,
        celular: userController.user!.celular,
        cpf: userController.user!.cpf,
        dataNascimento: userController.user!.dataNascimento,
        fotoPerfil: userController.user!.fotoPerfil,
        idGrupoEvento: _selectedGroup,
        situacao: userController.user!.situacao,
        cadastroPendente: userController.user!.cadastroPendente,
        pagamentoPendente: userController.user!.pagamentoPendente,
        matricula: userController.user!.matricula,
        problemaSaude:
            _possuiProblemaSaude == true ? _problemaSaudeController.text : '',
        atividadeFisicaRegular: _praticaAtividadeFisica == true
            ? _atividadeFisicaController.text
            : '',
        aplicativoAtividades: _selectedAppController.text.isNotEmpty
            ? _selectedAppController.text
            : null,
        idSexoTipo: userController.user!.idSexoTipo,
        idEstadoCivilTipo: userController.user!.idEstadoCivilTipo,
        idEndereco: userController.user!.idEndereco,
        peso: _pesoController.text.isNotEmpty
            ? double.tryParse(_pesoController.text)
            : null,
        altura: _alturaController.text.isNotEmpty
            ? double.tryParse(_alturaController.text)
            : null,
      );

      final overlay = SalvandoSnackBar.show(context);
      try {
        await userController.updateUser(context, updatedUser.id, updatedUser);
        await _saveRespostasCamposPersonalizados();
      } finally {
        overlay.remove();
      }

      if (!mounted) return;

      SalvoSucessoSnackBar.show(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PerfilPageAdmin(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    //final double screenWidth = MediaQuery.of(context).size.width;

    // Verificar se a tela é menor que 369x662
    final bool isSmallScreen = screenHeight < 668;

    // Define a cor do semicírculo com base no modo administrador
    Color semicircleColor = Colors.black;

    // Definir escalas para as fontes e widgets de acordo com o tamanho da tela
    double textScaleFactor = isSmallScreen ? 0.8 : 1.2; // Escala de texto
    // Escala de botões e ícones
    double semicircleHeight = isSmallScreen
        ? screenHeight * 0.15
        : screenHeight * 0.15; // Ajuste do semicírculo

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          _buildHeader(semicircleHeight, semicircleColor, textScaleFactor),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildForm(),
                  const SizedBox(height: 40),
                  _buildSaveButton(context),
                  const SizedBox(height: 15),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 3),
    );
  }

  Widget _buildHeader(
      double semicircleHeight, Color semicircleColor, double textScaleFactor) {
    return Container(
      width: double.infinity,
      height: semicircleHeight,
      decoration: BoxDecoration(
        color: semicircleColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(MediaQuery.of(context).size.width),
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Dados Adicionais',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomDropdownGrupo(
            grupos: grupos,
            selectedGrupo: _selectedGroup,
            onChanged: (int? newValue) {
              setState(() {
                _selectedGroup = newValue;
                _fetchCamposPersonalizados(); // Fetch Campos Personalizados quando o grupo muda
              });
            }, // Se não for admin, onChanged é null
            enabled: true,
          ),
          if (_camposPersonalizados.isNotEmpty) ...[
            const SizedBox(height: 15),
            _buildCamposPersonalizadosFields(),
          ],
          const SizedBox(height: 15),
          _buildTextField(
            'Altura* (Ex. 1.72)',
            _alturaController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildPesoTextField(),
          const SizedBox(height: 15),
          _buildHealthQuestion(),
          if (_possuiProblemaSaude == true)
            _buildTextField(
                'Descreva seu problema de saúde*', _problemaSaudeController),
          const SizedBox(height: 15),
          _buildActivityQuestion(),
          if (_praticaAtividadeFisica == true)
            _buildTextField('Descreva sua prática de atividade física*',
                _atividadeFisicaController),
          const SizedBox(height: 15),
          _buildDropdownField(
            'Você usa algum desses apps?',
            _selectedAppController,
            [
              'Strava',
              'Adidas Running',
              'Garmin Connect',
              'Relive',
              'Nike Run Club'
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCamposPersonalizadosFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _camposPersonalizados.map((campo) {
        // Adicione o asterisco ao nome do campo se for obrigatório
        final labelText =
            campo.obrigatorio ? '${campo.nomeCampo}*' : campo.nomeCampo;

        if (campo.idTipoCampo == 3) {
          // Campo de texto
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              _buildTextField(
                labelText,
                _responseControllers[campo.id!] ?? TextEditingController(),
              ),
              const SizedBox(height: 15),
            ],
          );
        } else if (campo.idTipoCampo == 2) {
          // Campo de RadioButton
          List<OpcaoCampo>? opcoes = _opcoesCampoMap[campo.id!];
          if (opcoes == null || opcoes.isEmpty) {
            return const Text('Nenhuma opção disponível');
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelText,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                ...opcoes.map((opcao) {
                  return RadioListTile<String>(
                    title: Text(opcao.opcao),
                    activeColor: const Color(0xFFFF7801),
                    value: opcao.opcao,
                    groupValue: _selectedOpcaoText[campo.id!],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOpcaoText[campo.id!] = value;
                      });
                    },
                  );
                }),
                const SizedBox(height: 15),
              ],
            );
          }
        } else {
          return Container();
        }
      }).toList(),
    );
  }

  Widget _buildHealthQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Possui algum problema de saúde?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Sim'),
                activeColor: const Color(0xFFFF7801),
                value: true,
                groupValue: _possuiProblemaSaude,
                onChanged: (bool? value) {
                  setState(() {
                    _possuiProblemaSaude = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                activeColor: const Color(0xFFFF7801),
                title: const Text('Não'),
                value: false,
                groupValue: _possuiProblemaSaude,
                onChanged: (bool? value) {
                  setState(() {
                    _possuiProblemaSaude = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Pratica alguma atividade física regularmente?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                activeColor: const Color(0xFFFF7801),
                title: const Text('Sim'),
                value: true,
                groupValue: _praticaAtividadeFisica,
                onChanged: (bool? value) {
                  setState(() {
                    _praticaAtividadeFisica = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                activeColor: const Color(0xFFFF7801),
                title: const Text('Não'),
                value: false,
                groupValue: _praticaAtividadeFisica,
                onChanged: (bool? value) {
                  setState(() {
                    _praticaAtividadeFisica = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;
    String limparLabel(String text) {
      return text
          .replaceAll('Digite', '')
          .replaceAll('seu', 'Seu')
          .replaceAll(' o ', '')
          .replaceAll('nome', 'Nome')
          .replaceAll('logradouro', 'Logradouro')
          .replaceAll('bairro', 'Bairro');
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        labelText: limparLabel(hintText),
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  // This widget will contain the modified text field with input validation
  Widget _buildPesoTextField() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;
    return TextField(
      controller: _pesoController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Peso* (Ex. 80.5)',
        labelText: 'Seu Peso',
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        MascaraPeso(),
      ],
    );
  }

  Widget _buildDropdownField(
    String hintText,
    TextEditingController controller,
    List<String> items,
  ) {
    return ButtonTheme(
      alignedDropdown: true,
      child: CustomDropdownButton(
        value: controller.text.isNotEmpty ? controller.text : null,
        hint: '   $hintText',
        items: items,
        onChanged: (String? newValue) {
          setState(() {
            controller.text = newValue ?? '';
          });
        },
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final userController = Provider.of<UserController>(context, listen: false);

    return Center(
      child: CustomButtonSalvar(onSave: () async {
        await _saveAdditionalData(userController);
      }),
    );
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PerfilPageAdmin()),
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
    );
  }

  @override
  void dispose() {
    _problemaSaudeController.dispose();
    _atividadeFisicaController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _selectedAppController.dispose();
    super.dispose();
  }
}
