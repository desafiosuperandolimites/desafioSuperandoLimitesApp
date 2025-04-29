part of '../../env.dart';

class InfoPessoalAdmPage extends StatefulWidget {
  final Usuario selectedUser;

  const InfoPessoalAdmPage({
    super.key,
    required this.selectedUser,
  });

  @override
  InfoPessoalAdmPageState createState() => InfoPessoalAdmPageState();
}

class InfoPessoalAdmPageState extends State<InfoPessoalAdmPage> {
  final EnderecoController _enderecoController = EnderecoController();
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
  final GrupoController _grupoController = GrupoController();

  String? _selectedSexo;
  String? _selectedEstadoCivil;
  int? _currentNumero;
  String _currentComplemento = '';
  List<Grupo> grupos = [];
  int? _selectedGroup;
  Endereco? _selectedEndereco;

  @override
  void initState() {
    super.initState();
    _populateUserData(widget.selectedUser);
    if (widget.selectedUser.idEndereco != null) {
      // Fetch the address based on idEndereco
      _fetchEndereco(widget.selectedUser.idEndereco!);
    }
    _loadGruposFromBackend();
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
  }

  // Fetch address from backend based on idEndereco
  void _fetchEndereco(int enderecoId) async {
    try {
      await _enderecoController.fetchEnderecoById(enderecoId);
      Endereco endereco = _enderecoController.endereco!;
      setState(() {
        _selectedEndereco = endereco;
        _populateEnderecoData(endereco);
      });
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print('Error fetching address: $e');
      }
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
    _selectedGroup = user.idGrupoEvento;
  }

  void _populateEnderecoData(Endereco endereco) {
    _cepController.text = endereco.cep;
    _logradouroController.text = endereco.logradouro;
    _bairroController.text = endereco.bairro;
    if (_currentNumero == null) {
      _numeroController.text = endereco.numero?.toString() ?? '';
      _currentNumero = _numeroController.text.isNotEmpty
          ? int.tryParse(_numeroController.text)
          : null;
    }
    if (_currentComplemento.isEmpty) {
      _complementoController.text = endereco.complemento ?? '';
      _currentComplemento = _complementoController.text;
    }
    _ufController.text = endereco.uf;
    _cidadeController.text = endereco.cidade;
  }

  Future<void> _saveUserProfile() async {
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

    Usuario updatedUser = Usuario(
      id: widget.selectedUser.id,
      nome: _nomeController.text,
      email: widget.selectedUser.email,
      celular: widget.selectedUser.celular,
      cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      dataNascimento: _parseDate(_dataNascimentoController.text),
      fotoPerfil: widget.selectedUser.fotoPerfil,
      idGrupoEvento: _selectedGroup,
      situacao: widget.selectedUser.situacao,
      cadastroPendente: widget.selectedUser.cadastroPendente,
      pagamentoPendente: widget.selectedUser.pagamentoPendente,
      matricula: widget.selectedUser.matricula,
      problemaSaude: widget.selectedUser.problemaSaude,
      atividadeFisicaRegular: widget.selectedUser.atividadeFisicaRegular,
      aplicativoAtividades: widget.selectedUser.aplicativoAtividades,
      idSexoTipo: _mapSexoNameToId(_selectedSexo),
      idEstadoCivilTipo: _mapEstadoCivilNameToId(_selectedEstadoCivil),
      idEndereco: widget.selectedUser.idEndereco,
      peso: widget.selectedUser.peso,
      altura: widget.selectedUser.altura,
    );

    await _saveAddress(updatedUser.id);
    if (!mounted) return;

    final overlay = SalvandoSnackBar.show(context);
    try {
      await UserController().updateUser(context, updatedUser.id, updatedUser);
    } finally {
      overlay.remove();
    }

    if (!mounted) return;

    SalvoSucessoSnackBar.show(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            DadosCadastraisPage(selectedUser: widget.selectedUser),
      ),
    );
  }

  Future<void> _saveAddress(int usuarioId) async {
    if (!_areAddressFieldsComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os campos obrigatórios devem ser preenchidos!'),
        ),
      );
      return;
    }

    Endereco endereco = Endereco(
      id: _selectedEndereco?.id ?? 0, // Novo ou existente
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

    if (_selectedEndereco == null) {
      await EnderecoController().createEndereco(
        cep: endereco.cep,
        usuarioId: usuarioId,
        numero: endereco.numero,
        complemento: endereco.complemento ?? '', // Valor padrão vazio
      );
    } else {
      await EnderecoController().updateEndereco(endereco.id, endereco);
    }
  }

  bool _areAddressFieldsComplete() {
    return _cepController.text.isNotEmpty &&
        _logradouroController.text.isNotEmpty &&
        _bairroController.text.isNotEmpty &&
        _numeroController.text.isNotEmpty &&
        _ufController.text.isNotEmpty &&
        //_complementoController.text.isNotEmpty &&
        _cidadeController.text.isNotEmpty;
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
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Semicircle at the top of the screen
          CustomSemicirculo(
            height: screenHeight * 0.12, // Adjust as needed
            color: Colors.black, // Black color
          ),

          // Title at the top
          Positioned(
            top: screenHeight * 0.04, // Adjust as needed
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Informações Pessoais',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
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
          _buildTextField('Digite seu nome completo *', _nomeController),
          const SizedBox(height: 20),
          _buildDropdown('Selecione o sexo *', _selectedSexo,
              ['Masculino', 'Feminino', 'Outro'], (newValue) {
            setState(() {
              _selectedSexo = newValue;
            });
          }),
          const SizedBox(height: 20),
          _buildDropdown('Selecione o estado civil *', _selectedEstadoCivil,
              ['Solteiro', 'Casado', 'Divorciado', 'Viúvo'], (newValue) {
            setState(() {
              _selectedEstadoCivil = newValue;
            });
          }),
          const SizedBox(height: 20),
          _buildTextField('Digite o CPF *', _cpfController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildDateField(context),
          const SizedBox(height: 20),
          _buildCepField(),
          const SizedBox(height: 20),
          _buildTextField('Digite o logradouro *', _logradouroController),
          const SizedBox(height: 20),
          _buildTextField('Digite seu bairro *', _bairroController),
          const SizedBox(height: 20),
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
                      _currentNumero = int.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  'Complemento (opcional)', // Indica que é opcional
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          CustomDropdownGrupo(
            grupos: grupos,
            selectedGrupo: _selectedGroup,
            onChanged: (int? newValue) {
              setState(() {
                _selectedGroup = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCepField() {
    return TextField(
      controller: _cepController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Digite o CEP *',
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
            if (cep.isNotEmpty) {
              try {
                await _enderecoController.fetchEnderecoByCep(
                    cep, widget.selectedUser.id);
                Endereco endereco = _enderecoController.endereco!;
                setState(() {
                  _populateEnderecoData(endereco);
                });
              } catch (e) {
                if (!mounted) return;
                // Handle error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CEP não encontrado'),
                  ),
                );
              }
            }
          },
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.h),
          _buildForm(),
          _buildSaveButton(context),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      ValueChanged<String>? onChanged}) {
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
            DateTime? initialDate = _parseDate(_dataNascimentoController.text);
            initialDate ??= DateTime.now();
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
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
    return CustomButtonSalvar(onSave: () async {
      await _saveUserProfile();
    });
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DadosCadastraisPage(selectedUser: widget.selectedUser),
            ),
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
