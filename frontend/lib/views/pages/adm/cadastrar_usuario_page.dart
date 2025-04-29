part of '../../env.dart';

class CriarUsuarioPage extends StatefulWidget {
  const CriarUsuarioPage({super.key});

  @override
  CriarUsuarioPageState createState() => CriarUsuarioPageState();
}

class CriarUsuarioPageState extends State<CriarUsuarioPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final GrupoController _grupoController = GrupoController();
  final FocusNode _senhaFocusNode = FocusNode();
  final CadastroController _cadastroController = CadastroController();

  List<Grupo> grupos = [];
  int? _selectedGroup;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialCharacter = false;

  bool _showPasswordRequirements = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();
    _senhaFocusNode.addListener(() {
      if (!_senhaFocusNode.hasFocus) {
        setState(() {
          _showPasswordRequirements = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _senhaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
  }

  void _verificarRequisitosSenha(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _hasMinLength = false;
        _hasUppercase = false;
        _hasLowercase = false;
        _hasNumber = false;
        _hasSpecialCharacter = false;
      });
      return;
    }

    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecialCharacter = RegExp(r'[\W_]').hasMatch(value);
    });
  }

  void _validateAndSubmit() async {
    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    final senhaError = Validacoes.validatePassword(senha);
    final emailError = Validacoes.validateEmail(email);
    final nomeError = Validacoes.validateNome(nome);

    if (nomeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nomeError)),
      );
      return;
    }

    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    if (senhaError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(senhaError)),
      );
      return;
    }

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um grupo')),
      );
      return;
    }

    final registrationData = {
      'NOME': nome,
      'EMAIL': email,
      'SENHA': senha,
      'CONFIRMAR_SENHA': confirmarSenha,
      'ID_GRUPO_EVENTO': _selectedGroup!,
      'ID_PERFIL_TIPO': 3, // Assuming admin creates normal users
    };

    final overlay = SalvandoSnackBar.show(context);
    try {
      bool success =
          await _cadastroController.adminRegister(context, registrationData);
      if (!mounted) return;
      if (success) {
        SalvoSucessoSnackBar.show(context);
      }
    } finally {
      overlay.remove();
    }
    Navigator.pushReplacementNamed(context, '/gestao-usuarios');
  }

  Widget _construirRequisitoSenha(String requirement, bool satisfied) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.cancel,
          color: satisfied ? Colors.green : Colors.red,
          size: 16.0,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            requirement,
            style: TextStyle(
              color: satisfied ? Colors.green : Colors.red,
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirRequisitosSenha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _construirRequisitoSenha(
                  "Pelo menos 8 caracteres", _hasMinLength),
            ),
            Expanded(
              child: _construirRequisitoSenha(
                  "Uma letra maiúscula", _hasUppercase),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _construirRequisitoSenha(
                  "Uma letra minúscula", _hasLowercase),
            ),
            Expanded(
              child: _construirRequisitoSenha("Um número", _hasNumber),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _construirRequisitoSenha(
                  "Um caractere especial", _hasSpecialCharacter),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430; // Based on iPhone 14 Pro Max width

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
          // Fundo branco
          Container(
            color: Colors.white,
          ),
          // Semicirculo
          CustomSemicirculo(
            height: screenHeight * 0.12, // Adjusted to 1/4 of original size
            color: Colors.black, // Black color
          ),
          Positioned(
            top: screenHeight * 0.04, // Adjust as needed
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Criar Usuário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25 * ratio,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Main content positioned below the semicircle
          Positioned(
            top: screenHeight *
                0.14, // Adjust to start just after the semicircle
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: ListView(
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  _buildTextField('Nome Completo', _nomeController),
                  SizedBox(height: screenHeight * 0.01),
                  _buildTextField('E-mail', _emailController),
                  SizedBox(height: screenHeight * 0.01),
                  CustomDropdownGrupo(
                    grupos: grupos,
                    selectedGrupo: _selectedGroup,
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedGroup = newValue;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildPasswordField('Senha', _senhaController),
                  SizedBox(height: screenHeight * 0.005),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _showPasswordRequirements ? screenHeight * 0.09 : 0,
                    child: _showPasswordRequirements
                        ? _construirRequisitosSenha()
                        : Container(),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildPasswordField(
                      'Confirmação de senha', _confirmarSenhaController,
                      isConfirm: true),
                  SizedBox(height: screenHeight * 0.05),
                  _buildSaveButton(
                      screenWidth, screenHeight, scaleFactor, ratio),
                  //SizedBox(height: screenHeight * 0.2),
                  const CustomButtonVoltar()
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 3),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      ValueChanged<String>? onChanged}) {
    //final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        labelText: hintText,
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

  Widget _buildPasswordField(String label, TextEditingController controller,
      {bool isConfirm = false}) {
    //final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;
    return TextField(
      controller: controller,
      obscureText: isConfirm ? true : _isObscure,
      focusNode: isConfirm ? null : _senhaFocusNode,
      onChanged: isConfirm
          ? null
          : (value) {
              setState(() {
                _verificarRequisitosSenha(value);
              });
            },
      onTap: isConfirm
          ? null
          : () {
              setState(() {
                _showPasswordRequirements = true;
              });
            },
      onEditingComplete: isConfirm
          ? null
          : () {
              setState(() {
                _showPasswordRequirements = false;
              });
            },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        labelText: label,
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
        suffixIcon: isConfirm
            ? null
            : IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
      ),
    );
  }

  Widget _buildSaveButton(double screenWidth, double screenHeight,
      double scaleFactor, double ratio) {
    return SizedBox(
      height: screenHeight * 0.06, // Fixed height
      child: Center(
        child: ElevatedButton(
          onPressed: _validateAndSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(
              horizontal: ratio * 0.5 * scaleFactor,
            ),
            fixedSize: Size(ratio * 100, 48 * scaleFactor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6 * scaleFactor),
            ),
          ),
          child: Text(
            'Salvar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16 * ratio,
            ),
          ),
        ),
      ),
    );
  }
}
