part of '../../../env.dart';

class ContatosPage extends StatefulWidget {
  const ContatosPage({super.key}); // Adicionando isAdminMode

  @override
  ContatosPageState createState() => ContatosPageState();
}

class ContatosPageState extends State<ContatosPage> {
  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final MaskedTextController _telefoneController =
      Mascaras.cellphoneController();

  @override
  void initState() {
    super.initState();
    final userController = Provider.of<UserController>(context, listen: false);
    final user = userController.user;

    if (user != null) {
      _populateContatoData(user);
    }
  }

  void _populateContatoData(Usuario user) {
    _telefoneController.text = user.celular ?? '';
    _emailController.text = user.email;
    _profissaoController.text = user.profissao ?? '';
    _matriculaController.text = user.matricula ?? '';
  }

  Future<void> _saveContatoProfile(UserController userController) async {
    if (userController.user != null) {
      Usuario updatedUser = Usuario(
        id: userController.user!.id,
        nome: userController.user!.nome,
        email: _emailController.text,
        celular: _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        profissao: _profissaoController.text,
        cpf: userController.user!.cpf,
        dataNascimento: userController.user!.dataNascimento,
        fotoPerfil: userController.user!.fotoPerfil,
        idGrupoEvento: userController.user!.idGrupoEvento,
        situacao: userController.user!.situacao,
        cadastroPendente: userController.user!.cadastroPendente,
        pagamentoPendente: userController.user!.pagamentoPendente,
        matricula: _matriculaController.text,
        problemaSaude: userController.user!.problemaSaude,
        atividadeFisicaRegular: userController.user!.atividadeFisicaRegular,
        aplicativoAtividades: userController.user!.aplicativoAtividades,
        idSexoTipo: userController.user!.idSexoTipo,
        idEstadoCivilTipo: userController.user!.idEstadoCivilTipo,
        idEndereco: userController.user!.idEndereco,
        peso: userController.user!.peso,
        altura: userController.user!.altura,
      );

      final overlay = SalvandoSnackBar.show(context);
      try {
        await userController.updateUser(context, updatedUser.id, updatedUser);
      } finally {
        overlay.remove();
      }
      if (!mounted) return;

      SalvoSucessoSnackBar.show(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilPage()),
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
                  _buildForm(),
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
                'Contatos',
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
          _buildTextField(
            'Telefone',
            _telefoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            'E-mail',
            _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            'Profissão',
            _profissaoController,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            'Matrícula',
            _matriculaController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
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
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final userController = Provider.of<UserController>(context, listen: false);

    return CustomButtonSalvar(onSave: () async {
      _saveContatoProfile(userController);
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

  @override
  void dispose() {
    _telefoneController.dispose();
    _emailController.dispose();
    _profissaoController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }
}
