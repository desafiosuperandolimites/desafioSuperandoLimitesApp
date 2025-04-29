// ignore_for_file: deprecated_member_use

part of '../../../env.dart';

class InfoPessoalPage extends StatefulWidget {
  const InfoPessoalPage({super.key});

  @override
  InfoPessoalPageState createState() => InfoPessoalPageState();
}

class InfoPessoalPageState extends State<InfoPessoalPage> {
  String? _selectedSexo;
  String? _selectedEstadoCivil;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final MaskedTextController _dataNascimentoController =
      Mascaras.dateController();
  final MaskedTextController _cepController = Mascaras.cepController();
  final MaskedTextController _cpfController = Mascaras.cpfController();
  int? _currentNumero;
  String _currentComplemento = '';

  @override
  void initState() {
    super.initState();
    final userController = Provider.of<UserController>(context, listen: false);
    final enderecoController =
        Provider.of<EnderecoController>(context, listen: false);

    final user = userController.user;

    if (user != null) {
      _populateUserData(user);
      if (user.idEndereco != null) {
        enderecoController.fetchEnderecoById(user.idEndereco!);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enderecoController = Provider.of<EnderecoController>(context);
    final endereco = enderecoController.endereco;

    if (endereco != null) {
      _populateEnderecoData(endereco);
    }
  }

  void _populateUserData(Usuario user) {
    _nomeController.text = user.nome;
    _cpfController.text = user.cpf ?? '';

    _dataNascimentoController.text = user.dataNascimento != null
        ? '${user.dataNascimento!.day.toString().padLeft(2, '0')}/${user.dataNascimento!.month.toString().padLeft(2, '0')}/${user.dataNascimento!.year}'
        : '';

    _selectedSexo = _mapSexoIdToName(user.idSexoTipo);
    _selectedEstadoCivil = _mapEstadoCivilIdToName(user.idEstadoCivilTipo);
  }

  void _populateEnderecoData(Endereco endereco) {
    _cepController.text = endereco.cep;
    _logradouroController.text = endereco.logradouro;
    _bairroController.text = endereco.bairro;
    if (_currentNumero == null) {
      _numeroController.text = endereco.numero.toString() == 'null'
          ? ''
          : endereco.numero.toString();
      _currentNumero = _numeroController.text.isNotEmpty
          ? int.parse(_numeroController.text)
          : null;
    }
    if (_currentComplemento.isEmpty) {
      _complementoController.text = endereco.complemento ?? '';
      _currentComplemento = _complementoController.text;
    }
    _ufController.text = endereco.uf;
    _cidadeController.text = endereco.cidade;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final enderecoController = Provider.of<EnderecoController>(context);
    //final double screenWidth = MediaQuery.of(context).size.width;

    // Verificar se a tela é menor que 369x662
    final bool isSmallScreen = screenHeight < 668;

    // Define a cor do semicírculo com base no modo administrador
    Color semicircleColor = const Color(0xFFFF7801);

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20.h),
                  _buildForm(enderecoController),
                  _buildSaveButton(context),
                  const SizedBox(height: 15),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
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
                'Informações Pessoais',
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

  Widget _buildForm(EnderecoController enderecoController) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTextField('Digite seu nome completo *', _nomeController),
          const SizedBox(height: 15),
          _buildDropdown('Selecione seu sexo *', _selectedSexo,
              ['Masculino', 'Feminino', 'Outro'], (newValue) {
            setState(() {
              _selectedSexo = newValue;
            });
          }),
          const SizedBox(height: 15),
          _buildDropdown('Selecione seu estado civil *', _selectedEstadoCivil,
              ['Solteiro', 'Casado', 'Divorciado', 'Viúvo'], (newValue) {
            setState(() {
              _selectedEstadoCivil = newValue;
            });
          }),
          const SizedBox(height: 15),
          _buildTextField('Digite seu CPF *', _cpfController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 15),
          _buildDateField(context),
          const SizedBox(height: 15),
          _buildCepField(enderecoController),
          const SizedBox(height: 15),
          _buildTextField('Digite o logradouro *', _logradouroController),
          const SizedBox(height: 15),
          _buildTextField('Digite seu bairro *', _bairroController),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTextField(
                  'Nº *',
                  _numeroController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _currentNumero = int.parse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  'Complemento (opcional)', // Indicar que é opcional
                  _complementoController,
                  onChanged: (value) {
                    setState(() {
                      _currentComplemento = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTextField('UF *', _ufController),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _buildTextField('Cidade *', _cidadeController),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCepField(EnderecoController enderecoController) {
    final userController = Provider.of<UserController>(context, listen: false);
    return TextField(
      controller: _cepController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Digite seu CEP *',
        labelText: 'Seu CEP',
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
            if (cep.isNotEmpty && userController.user != null) {
              final usuarioId = userController.user!.id;
              // Clear previous address before fetching the new one
              enderecoController.clearEndereco();
              _numeroController.clear();
              _complementoController.clear();
              await enderecoController.fetchEnderecoByCep(cep, usuarioId);
              final endereco = enderecoController.endereco;
              if (endereco != null) {
                setState(() {
                  _populateEnderecoData(endereco);
                });
              }
            }
          },
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      ValueChanged<String>? onChanged}) {
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
        hintStyle: const TextStyle(color: Colors.grey),
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
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextField(
      controller: _dataNascimentoController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'DD/MM/AAAA *',
        labelText: 'DD/MM/AAAA',
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFFF7801),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    buttonTheme: const ButtonThemeData(
                      textTheme: ButtonTextTheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                _dataNascimentoController.text =
                    '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
              });
            }
          },
        ),
      ),
      keyboardType: TextInputType.datetime,
    );
  }

  Widget _buildDropdown(String hintText, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return ButtonTheme(
      alignedDropdown: true,
      child: CustomDropdownButton(
        value: value,
        hint: '   $hintText',
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final userController = Provider.of<UserController>(context, listen: false);
    final enderecoController =
        Provider.of<EnderecoController>(context, listen: false);

    return CustomButtonSalvar(onSave: () async {
      _saveUserProfile(userController, enderecoController);
    });
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PerfilPage()),
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

  Future<void> _saveUserProfile(UserController userController,
      EnderecoController enderecoController) async {
    final String cpf = _cpfController.text;

    // Valida o CPF: Deve ter 11 números ou 14 caracteres formatados
    final RegExp cpfRegex = RegExp(r'^\d{11}$|^\d{3}\.\d{3}\.\d{3}-\d{2}$');
    if (!cpfRegex.hasMatch(cpf)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O CPF informado é inválido!'),
        ),
      );
      return;
    }

    // Adicione aqui a lógica para validar o CPF com base nos dígitos verificadores, se necessário

    if (userController.user != null) {
      Usuario updatedUser = Usuario(
        id: userController.user!.id,
        nome: _nomeController.text,
        email: userController.user!.email,
        celular: userController.user!.celular,
        cpf: cpf.replaceAll(RegExp(r'[^0-9]'), ''), // Remove pontos e traços
        dataNascimento: _parseDate(_dataNascimentoController.text),
        fotoPerfil: userController.user!.fotoPerfil,
        idGrupoEvento: userController.user!.idGrupoEvento,
        situacao: userController.user!.situacao,
        cadastroPendente: userController.user!.cadastroPendente,
        pagamentoPendente: userController.user!.pagamentoPendente,
        matricula: userController.user!.matricula,
        problemaSaude: userController.user!.problemaSaude,
        atividadeFisicaRegular: userController.user!.atividadeFisicaRegular,
        aplicativoAtividades: userController.user!.aplicativoAtividades,
        idSexoTipo: _mapSexoNameToId(_selectedSexo),
        idEstadoCivilTipo: _mapEstadoCivilNameToId(_selectedEstadoCivil),
        idEndereco: userController.user!.idEndereco,
        peso: userController.user!.peso,
        altura: userController.user!.altura,
      );

      // Resto do código para salvar o perfil
      _saveAddress(userController, enderecoController, userController.user!.id,
          updatedUser);
    }
  }

  Future<void> _saveAddress(
      UserController userController,
      EnderecoController enderecoController,
      int usuarioId,
      Usuario updatedUser) async {
    final String cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O CEP deve ser informado!')),
      );
      return;
    }

    // Depuração: Log do CEP
    if (kDebugMode) {
      print("Enviando CEP para validação: $cep");
    }

    // Verificar se o CEP é válido buscando dados
    final enderecoFromCep =
        await enderecoController.fetchEnderecoByCep(cep, usuarioId);

    if (enderecoFromCep == null) {
      // Log para depuração
      if (kDebugMode) {
        print("Erro: CEP inválido ou não encontrado.");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP inválido ou não encontrado!')),
      );
      return;
    }

    // Processa os dados recebidos do CEP
    _populateEnderecoData(enderecoFromCep);

    if (_cepController.text.isEmpty ||
        _logradouroController.text.isEmpty ||
        _bairroController.text.isEmpty ||
        _ufController.text.isEmpty ||
        _cidadeController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os campos obrigatórios devem ser preenchidos!'),
        ),
      );
      return;
    }

    Endereco endereco = Endereco(
      id: enderecoController.endereco?.id ?? 0, // Novo ou existente
      cep: _cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      logradouro: _logradouroController.text,
      bairro: _bairroController.text,
      numero: _numeroController.text.isNotEmpty
          ? int.tryParse(_numeroController.text)
          : null,
      complemento: _complementoController.text.isNotEmpty
          ? _complementoController.text
          : null, // Permite complemento nulo
      uf: _ufController.text,
      cidade: _cidadeController.text,
    );

    if (!mounted) return;

    final overlay = SalvandoSnackBar.show(context);
    try {
      // Atualizar dados do usuário
      await userController.updateUser(context, updatedUser.id, updatedUser);

      if (endereco.id == 0) {
        // Criar um novo endereço
        final createdEndereco = await enderecoController.createEndereco(
          cep: endereco.cep,
          usuarioId: usuarioId,
          numero: endereco.numero,
          complemento: endereco.complemento ?? '', // Trata como string vazia
        );

        updatedUser = updatedUser.copyWith(idEndereco: createdEndereco.id);
        if (!mounted) return;
        await userController.updateUser(context, updatedUser.id, updatedUser);
      } else {
        // Atualizar endereço existente
        await enderecoController.updateEndereco(endereco.id, endereco);
      }

      await enderecoController.fetchEnderecoById(endereco.id);
    } finally {
      overlay.remove();
    }

    if (!mounted) return;

    SalvoSucessoSnackBar.show(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PerfilPage(),
      ),
    );
  }

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Handle parsing error
    }
    return null;
  }

  String? _mapSexoIdToName(int? id) {
    switch (id) {
      case 1:
        return 'Masculino';
      case 2:
        return 'Feminino';
      case 3:
        return 'Outro';
      default:
        return null;
    }
  }

  String? _mapEstadoCivilIdToName(int? id) {
    switch (id) {
      case 1:
        return 'Solteiro';
      case 2:
        return 'Casado';
      case 3:
        return 'Divorciado';
      case 4:
        return 'Viúvo';
      default:
        return null;
    }
  }

  int? _mapSexoNameToId(String? name) {
    switch (name) {
      case 'Masculino':
        return 1;
      case 'Feminino':
        return 2;
      case 'Outro':
        return 3;
      default:
        return null;
    }
  }

  int? _mapEstadoCivilNameToId(String? name) {
    switch (name) {
      case 'Solteiro':
        return 1;
      case 'Casado':
        return 2;
      case 'Divorciado':
        return 3;
      case 'Viúvo':
        return 4;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _bairroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _ufController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }
}
