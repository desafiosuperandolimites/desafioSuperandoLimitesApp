part of '../../../env.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  CadastroPageState createState() => CadastroPageState();
}

class CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final GrupoController _grupoController = GrupoController();
  final FocusNode _senhaFocusNode = FocusNode();

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

  void _validateAndSubmit(BuildContext context) async {
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

    // Dados de registro
    final registrationData = {
      'NOME': nome,
      'EMAIL': email,
      'SENHA': senha,
      'CONFIRMAR_SENHA': confirmarSenha,
      'ID_GRUPO_EVENTO': _selectedGroup!,
      'ID_PERFIL_TIPO': 3,
    };

    // Chama o registro
    bool emailExiste = false;
    try {
      emailExiste = await UserController().verifyEmail(email);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail já em uso.')),
      );
      return;
    }
    if (emailExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail já em uso.')),
      );
    }
    if (!emailExiste) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TermosDeUsoPage(registrationData: registrationData)),
      );
    }
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Garante que o teclado evite sobreposição
      body: Stack(
        children: <Widget>[
          // Imagem de fundo
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/Tela9.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          // Sobreposição escura
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          // Máscara laranja com baixa opacidade
          Container(
            color: const Color(0xFFFF7801).withOpacity(0.5), // Máscara laranja
          ),
          // Círculo branco no topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(screenHeight * 0.3),
                ),
              ),
            ),
          ),
          // Logo centralizada
          Positioned(
            top: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('assets/image/Prancheta 2.png',
                  height: screenHeight * 0.2),
            ),
          ),
          // Formulário de cadastro
          Center(
            child: SingleChildScrollView(
              // Adicionando SingleChildScrollView aqui
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.28),
                  Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Nome Completo *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 1),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'E-mail *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        CustomDropdownGrupoCadastro(
                          grupos: grupos,
                          selectedGrupo: _selectedGroup,
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedGroup = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _senhaController,
                          obscureText: _isObscure,
                          focusNode: _senhaFocusNode,
                          onChanged: _verificarRequisitosSenha,
                          onTap: () {
                            setState(() {
                              _showPasswordRequirements = true;
                            });
                          },
                          onEditingComplete: () {
                            setState(() {
                              _showPasswordRequirements = false;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Senha *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 1),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: _showPasswordRequirements
                              ? screenHeight * 0.09
                              : 0,
                          child: _showPasswordRequirements
                              ? _construirRequisitosSenha()
                              : Container(),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _confirmarSenhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Confirmação de senha *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: screenWidth - screenWidth * 0.16,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _validateAndSubmit(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.04,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'CADASTRAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/tipo-login');
                          },
                          child: const Text(
                            'Voltar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
