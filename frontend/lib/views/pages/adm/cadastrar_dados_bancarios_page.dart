part of '../../env.dart';

class CadastrarDadosBancariosPage extends StatefulWidget {
  const CadastrarDadosBancariosPage({super.key});

  @override
  CadastrarDadosBancariosPageState createState() =>
      CadastrarDadosBancariosPageState();
}

class CadastrarDadosBancariosPageState
    extends State<CadastrarDadosBancariosPage> {
  final TextEditingController _bancoController = TextEditingController();
  final TextEditingController _agenciaController = TextEditingController();
  final TextEditingController _contaController = TextEditingController();
  final TextEditingController _digitoController = TextEditingController();
  final TextEditingController _pixController = TextEditingController();
  final TextEditingController _titularController = TextEditingController();
  final DadosBancariosController _dadosBancarioController =
      DadosBancariosController();

  String? _tipoChavePix;
  DadosBancarios? _dadosBancarios;
  bool _isEditing = false;

  final _telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _cnpjFormatter = MaskTextInputFormatter(
      mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
  final _defaultFormatter = MaskTextInputFormatter();

  MaskTextInputFormatter _currentFormatter = MaskTextInputFormatter();

  @override
  void initState() {
    super.initState();
    _loadDadosBancariosFromBackend();
    _currentFormatter = _defaultFormatter;
  }

  void _setPixMask(String? tipoChavePix) {
    switch (tipoChavePix) {
      case 'Telefone':
        _currentFormatter = _telefoneFormatter;
        break;
      case 'CPF':
        _currentFormatter = _cpfFormatter;
        break;
      case 'CNPJ':
        _currentFormatter = _cnpjFormatter;
        break;
      default:
        _currentFormatter = _defaultFormatter;
        break;
    }
    _pixController.clear();
  }

  Future<void> _loadDadosBancariosFromBackend() async {
    await _dadosBancarioController.fetchDadosBancariosByUsuario(1);
    if (_dadosBancarioController.dadosBancarios != null) {
      setState(() {
        _dadosBancarios = _dadosBancarioController.dadosBancarios;
        _populateFields();
        _isEditing = true;
      });
    }
  }

  void _populateFields() {
    if (_dadosBancarios != null) {
      _bancoController.text = _dadosBancarios!.banco;
      _agenciaController.text = _dadosBancarios!.agencia;

      String contaCompleta = _dadosBancarios!.conta;
      if (contaCompleta.isNotEmpty) {
        _contaController.text =
            contaCompleta.substring(0, contaCompleta.length - 1);
        _digitoController.text = contaCompleta[contaCompleta.length - 1];
      }

      _pixController.text = _dadosBancarios!.pix ?? '';
      _titularController.text = _dadosBancarios!.titular;

      String chavePix = _pixController.text;
      if (chavePix.contains('@')) {
        _tipoChavePix = 'E-mail';
      } else if (chavePix.startsWith('+55')) {
        _tipoChavePix = 'Telefone';
      } else if (RegExp(r'^\d{11}$').hasMatch(chavePix)) {
        _tipoChavePix = 'CPF';
      } else if (RegExp(r'^\d{12,}$').hasMatch(chavePix)) {
        _tipoChavePix = 'CNPJ';
      } else {
        _tipoChavePix = 'Chave Aleatória';
      }
    }
  }

  Future<void> _saveDadosBancarios() async {
    if (_validateForm()) {
      try {
        String formatarChavePix(String chave, String? tipoChave) {
          switch (tipoChave) {
            case 'CPF':
              return chave.replaceAll(RegExp(r'\D'), '');
            case 'CNPJ':
              return chave.replaceAll(RegExp(r'\D'), '');
            case 'Telefone':
              String telefone = chave.replaceAll(RegExp(r'\D'), '');
              if (!telefone.startsWith('55')) {
                telefone = '55$telefone';
              }
              return '+$telefone';
            default:
              return chave;
          }
        }

        String contaCompleta =
            '${_contaController.text}${_digitoController.text}';

        String chavePixFormatada =
            formatarChavePix(_pixController.text, _tipoChavePix);
        DadosBancarios dadosBancarios = DadosBancarios(
          usuarioId: 1,
          banco: _bancoController.text,
          agencia: _agenciaController.text,
          conta: contaCompleta,
          titular: _titularController.text,
          pix: chavePixFormatada.isEmpty ? null : chavePixFormatada,
          dataAtualizacao: DateTime.now(),
        );

        await _dadosBancarioController.createDadosBancarios(dadosBancarios);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dados bancários inseridos com sucesso!')),
        );

        setState(() {
          _isEditing = true;
          _dadosBancarios = dadosBancarios;
        });

        await _loadDadosBancariosFromBackend();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar dados bancários: $e')),
        );
      }
    }
  }

  Future<void> _updateDadosBancarios() async {
    if (_validateForm()) {
      try {
        String formatarChavePix(String chave, String? tipoChave) {
          switch (tipoChave) {
            case 'CPF':
              return chave.replaceAll(RegExp(r'\D'), '');
            case 'CNPJ':
              return chave.replaceAll(RegExp(r'\D'), '');
            case 'Telefone':
              String telefone = chave.replaceAll(RegExp(r'\D'), '');
              if (!telefone.startsWith('55')) {
                telefone = '55$telefone';
              }
              return '+$telefone';
            default:
              return chave;
          }
        }

        String contaCompleta =
            '${_contaController.text}${_digitoController.text}';

        String chavePixFormatada =
            formatarChavePix(_pixController.text, _tipoChavePix);
        DadosBancarios dadosAtualizados = DadosBancarios(
          usuarioId: 1,
          banco: _bancoController.text,
          agencia: _agenciaController.text,
          conta: contaCompleta,
          titular: _titularController.text,
          pix: chavePixFormatada.isEmpty ? null : chavePixFormatada,
          dataAtualizacao: DateTime.now(),
        );

        if (_dadosBancarios!.id != null) {
          await _dadosBancarioController.updateDadosBancarios(
              _dadosBancarios!.id!, dadosAtualizados);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Dados bancários atualizados com sucesso!')),
          );

          setState(() {
            _dadosBancarios = dadosAtualizados;
          });

          await _loadDadosBancariosFromBackend();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: ID da conta é nulo.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar dados bancários: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    final bool isSmallScreen = screenWidth <= 400;
    final bool isMidScreen = screenWidth > 400 && screenWidth < 600;
    final bool isBigScreen = screenWidth > 600 && screenWidth < 850;
    final bool isPixelScreen = screenWidth > 850;

    // Ajustar fatores de escala conforme o tamanho
    double ratio = 0;
    if (isSmallScreen) {
      //small
      ratio = 0.9;
    } else if (isMidScreen) {
      //rexible
      ratio = 1;
    } else if (isBigScreen) {
      //tablet
      ratio = 1.4;
    } else if (isPixelScreen) {
      //pixel fold
      ratio = 1.2;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(color: Colors.white),
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
                'Dados Bancários',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 * ratio,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.14,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: ListView(
                children: [
                  _buildTextField('Banco*', _bancoController, screenWidth,
                      scaleFactor: scaleFactor),
                  const SizedBox(height: 15),
                  _buildTextField('Titular*', _titularController, screenWidth,
                      scaleFactor: scaleFactor),
                  const SizedBox(height: 15),
                  _buildTextField('Agência*', _agenciaController, screenWidth,
                      scaleFactor: scaleFactor),
                  const SizedBox(height: 15),
                  _buildContaDigitoField(screenWidth, scaleFactor, ratio),
                  const SizedBox(height: 15),
                  _buildTipoChavePixSelector(),
                  const SizedBox(height: 15),
                  _buildMaskedTextField(
                    'Pix (opcional)',
                    _pixController,
                    screenWidth,
                    scaleFactor: scaleFactor,
                  ),
                  const SizedBox(height: 40),
                  _buildSaveButton(
                      screenWidth, screenHeight, scaleFactor, ratio),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildTipoChavePixSelector() {
    return CustomDropdownButton(
      value: _tipoChavePix,
      items: const ['CPF', 'CNPJ', 'E-mail', 'Telefone', 'Chave Aleatória'],
      onChanged: (String? newValue) {
        setState(() {
          _tipoChavePix = newValue;
          _setPixMask(newValue);
        });
      },
      hint: '   Selecione o Tipo de Chave Pix',
    );
  }

  Widget _buildMaskedTextField(
      String label, TextEditingController controller, double screenWidth,
      {int maxLines = 1, required double scaleFactor}) {
    return TextField(
      controller: controller,
      inputFormatters: [_currentFormatter],
      decoration: InputDecoration(
        labelText: label,
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
      maxLines: maxLines,
    );
  }

  Widget _buildContaDigitoField(
      double screenWidth, double scaleFactor, double ratio) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField('Conta*', _contaController, screenWidth,
              scaleFactor: scaleFactor),
        ),
        SizedBox(width: screenWidth * 0.02),
        Text('-',
            style: TextStyle(
                fontSize: screenWidth * 0.03 * scaleFactor,
                color: Colors.grey[700])),
        SizedBox(width: screenWidth * 0.02),
        SizedBox(
          width: screenWidth * 0.2,
          child: _buildTextField('Dígito*', _digitoController, screenWidth,
              scaleFactor: scaleFactor),
        ),
        SizedBox(width: screenWidth * 0.02),
        Text('CC',
            style: TextStyle(fontSize: ratio * 16, color: Colors.grey[700])),
      ],
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

  Widget _buildTextField(
      String label, TextEditingController controller, double screenWidth,
      {int maxLines = 1, required double scaleFactor}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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
      maxLines: maxLines,
    );
  }

  Widget _buildSaveButton(double screenWidth, double screenHeight,
      double scaleFactor, double ratio) {
    return SizedBox(
      height: screenHeight * 0.070,
      child: Center(
        child: ElevatedButton(
          onPressed: _isEditing ? _updateDadosBancarios : _saveDadosBancarios,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(
              horizontal: ratio * 0.5 * scaleFactor,
            ),
            fixedSize: Size(ratio * 150, 48 * scaleFactor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6 * scaleFactor),
            ),
          ),
          child: Text(
            'Salvar',
            style: TextStyle(
              color: Colors.white,
              fontSize: ratio * 20,
            ),
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    if (_bancoController.text.isEmpty ||
        _agenciaController.text.isEmpty ||
        _contaController.text.isEmpty ||
        _titularController.text.isEmpty ||
        _digitoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return false;
    }

    if (_tipoChavePix == 'E-mail' && !_pixController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira um e-mail válido contendo "@"')),
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _bancoController.dispose();
    _agenciaController.dispose();
    _contaController.dispose();
    _digitoController.dispose();
    _pixController.dispose();
    _titularController.dispose();
    super.dispose();
  }
}
