part of '../../env.dart';

class ContatosAdmPage extends StatefulWidget {
  final Usuario selectedUser;

  const ContatosAdmPage({
    super.key,
    required this.selectedUser,
  });

  @override
  ContatosAdmPageState createState() => ContatosAdmPageState();
}

class ContatosAdmPageState extends State<ContatosAdmPage> {
  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final MaskedTextController _telefoneController =
      Mascaras.cellphoneController();

  @override
  void initState() {
    super.initState();
    _populateContatoData(widget.selectedUser);
  }

  void _populateContatoData(Usuario user) {
    _telefoneController.text = user.celular ?? '';
    _emailController.text = user.email;
    _profissaoController.text = user.profissao ?? '';
    _matriculaController.text = user.matricula ?? '';
  }

  Future<void> _saveContatoProfile() async {
    Usuario updatedUser = Usuario(
      id: widget.selectedUser.id,
      nome: widget.selectedUser.nome,
      email: _emailController.text,
      celular: _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      profissao: _profissaoController.text,
      cpf: widget.selectedUser.cpf,
      dataNascimento: widget.selectedUser.dataNascimento,
      fotoPerfil: widget.selectedUser.fotoPerfil,
      idGrupoEvento: widget.selectedUser.idGrupoEvento,
      situacao: widget.selectedUser.situacao,
      cadastroPendente: widget.selectedUser.cadastroPendente,
      pagamentoPendente: widget.selectedUser.pagamentoPendente,
      matricula: _matriculaController.text,
      problemaSaude: widget.selectedUser.problemaSaude,
      atividadeFisicaRegular: widget.selectedUser.atividadeFisicaRegular,
      aplicativoAtividades: widget.selectedUser.aplicativoAtividades,
      idSexoTipo: widget.selectedUser.idSexoTipo,
      idEstadoCivilTipo: widget.selectedUser.idEstadoCivilTipo,
      idEndereco: widget.selectedUser.idEndereco,
      peso: widget.selectedUser.peso,
      altura: widget.selectedUser.altura,
    );

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

  @override
  Widget build(BuildContext context) {
    // Build the UI, similar to InfoPessoalAdmPage
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
                'Contatos',
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

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.h),
          _buildForm(),
          _buildSaveButton(),
          SizedBox(height: 150.h),
          _buildBackButton(),
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
          SizedBox(height: 20.h),
          _buildTextField(
            'E-mail',
            _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20.h),
          _buildTextField(
            'Profissão',
            _profissaoController,
          ),
          SizedBox(height: 20.h),
          _buildTextField(
            'Matrícula',
            _matriculaController,
            keyboardType: TextInputType.text,
          ),
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

  Widget _buildSaveButton() {
    return CustomButtonSalvar(onSave: () async {
      await _saveContatoProfile();
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
    _telefoneController.dispose();
    _emailController.dispose();
    _profissaoController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }
}
