part of '../../env.dart';

class DadosCadastraisPage extends StatefulWidget {
  final Usuario selectedUser;

  const DadosCadastraisPage({super.key, required this.selectedUser});

  @override
  DadosCadastraisPageState createState() => DadosCadastraisPageState();
}

class DadosCadastraisPageState extends State<DadosCadastraisPage> {
  final UserController _userController = UserController();
  final GrupoController _grupoController = GrupoController();
  List<Grupo> grupos = [];
  Usuario? user;
  Usuario? currentUser;
  bool isActive = false;
  bool isAssAdmin = false; // New variable to track Ass. admin status

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();
    isActive = widget.selectedUser.situacao;
    isAssAdmin =
        widget.selectedUser.idTipoPerfil == 2; // Check if user is an Ass. admin
  }

  Future<void> _loadDataFromBackend() async {
    // Fetch both user and groups
    await Future.wait([
      _loadUserFromBackend(),
      _loadCurrentUserFromBackend(),
      _loadGruposFromBackend(),
    ]);
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
  }

  Future<void> _loadCurrentUserFromBackend() async {
    await _userController.fetchCurrentUser(); // Fetch users from backend
    setState(() {
      currentUser = _userController.user!;
    });
  }

  Future<void> _loadUserFromBackend() async {
    await _userController
        .fetchUserById(widget.selectedUser.id); // Fetch users from backend
    setState(() {
      user = _userController.user!;
    });
  }

  Future<bool> _updateUserAssAdminStatus() async {
    try {
      if (user != null) {
        int newIdTipoPerfil =
            isAssAdmin ? 2 : 3; // 2 for Ass. admin, 3 for regular user
        Usuario updatedUser = user!.copyWith(idTipoPerfil: newIdTipoPerfil);

        await _userController.updateUser(context, user!.id, updatedUser);
        setState(() {
          user = updatedUser;
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateUserStatus() async {
    try {
      if (user != null) {
        await _userController.toggleUserStatus(user!.id);
      }
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  /// Contacts the user via WhatsApp.
  /// If the phone number is null or empty, displays a message.
  void _contactViaWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Número de telefone não informado pelo usuário'),
        ),
      );
      return;
    }
    // Remove any non-digit characters
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    final Uri url = Uri.parse('https://wa.me/55$cleanedNumber');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!mounted) return;
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
      );
    }
  }

  String getGrupoName(int? idGrupoEvento) {
    if (idGrupoEvento == null) {
      return 'Grupo não foi informado';
    }
    final grupo = grupos.firstWhere(
      (g) => g.id == idGrupoEvento,
      orElse: () => Grupo(
          id: 0, nome: 'Desconhecido', cnpj: '00000000000000', situacao: false),
    );
    return grupo.nome;
  }

  /// Formats the CPF number.
  /// If `cpf` is null or empty, returns "CPF não foi informado".
  String formatCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'Não foi informado';
    }
    String cleanedCPF = cpf.replaceAll(RegExp(r'\D'), '');
    if (cleanedCPF.length != 11) {
      return cpf; // Return as is if not 11 digits
    }
    return '${cleanedCPF.substring(0, 3)}.${cleanedCPF.substring(3, 6)}.${cleanedCPF.substring(6, 9)}-${cleanedCPF.substring(9, 11)}';
  }

  /// Formats the phone number into the format "(00) 00000-0000".
  /// If `phoneNumber` is null or empty, returns "Telefone não foi informado".
  String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return 'Não foi informado';
    }
    // Remove any non-digit characters
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanedNumber.length == 11) {
      // Format as (00) 00000-0000
      return '(${cleanedNumber.substring(0, 2)}) ${cleanedNumber.substring(2, 7)}-${cleanedNumber.substring(7, 11)}';
    } else if (cleanedNumber.length == 10) {
      // Format as (00) 0000-0000 (landline numbers)
      return '(${cleanedNumber.substring(0, 2)}) ${cleanedNumber.substring(2, 6)}-${cleanedNumber.substring(6, 10)}';
    } else {
      // Return the original input if it doesn't match expected lengths
      return phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Semicircle at the top of the screen
          CustomSemicirculo(
            height: screenHeight * 0.12, // Ajuste conforme necessário
            color: Colors.black, // Cor preta
          ),

          // Título no topo
          Positioned(
            top: screenHeight * 0.04, // Ajuste conforme necessário
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Dados cadastrais',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Conteúdo principal
          _buildContent(screenHeight),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildContent(double screenHeight) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinhar à esquerda
        children: [
          SizedBox(height: screenHeight * 0.16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nome, Grupo, CPF e Celular com WhatsApp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do usuário
                      Text(
                        user?.nome ?? 'Nome não informado',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Grupo do usuário
                      Text(
                        getGrupoName(user?.idGrupoEvento),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // CPF do usuário
                      Text(
                        'CPF: ${formatCPF(user?.cpf)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Celular e Ícone do WhatsApp juntos
                      Row(
                        children: [
                          // Número de celular
                          Text(
                            'Celular: ${formatPhoneNumber(user?.celular)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                              width: 8), // Espaçamento entre número e ícone
                          GestureDetector(
                            onTap: () {
                              _contactViaWhatsApp(user
                                  ?.celular); // Chama a função de contato via WhatsApp
                            },
                            child: const Icon(
                              FontAwesomeIcons.whatsapp,
                              color: Color(0xFF25D366), // Cor verde do WhatsApp
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // User Status Section
          _buildUserStatusSection(),

          const SizedBox(height: 10),
          // Divider
          Container(
            height: 30,
            padding: const EdgeInsets.all(0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(106, 158, 158, 158),
                  blurRadius: 6.0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          // Information Categories
          const SizedBox(height: 40),
          _buildInformationCategories(),
          const SizedBox(height: 80),
          CustomButtonVoltar(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/gestao-usuarios');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing Active/Inactive Switch
          Row(
            children: [
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isActive,
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.grey,
                  onChanged: (value) async {
                    bool previousStatus = isActive;
                    setState(() {
                      isActive = value;
                    });

                    bool success = await _updateUserStatus();
                    if (success) {
                      String message = isActive
                          ? 'Usuário ativado com sucesso'
                          : 'Usuário inativado com sucesso';
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    } else {
                      setState(() {
                        isActive = previousStatus;
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Erro ao atualizar o status do usuário')),
                      );
                    }
                  },
                ),
              ),
              Text(
                isActive ? 'Ativo' : 'Inativo',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (currentUser?.idTipoPerfil == 1 &&
              (user!.idTipoPerfil == 2 || user!.idTipoPerfil == 3))
            Row(
              children: [
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: isAssAdmin,
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (value) async {
                      bool previousStatus = isAssAdmin;
                      setState(() {
                        isAssAdmin = value;
                      });

                      bool success = await _updateUserAssAdminStatus();
                      if (success) {
                        String message = isAssAdmin
                            ? 'Usuário agora é assistente administrativo'
                            : 'Usuário não é mais assistente administrativo';
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      } else {
                        setState(() {
                          isAssAdmin = previousStatus;
                        });
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Erro ao atualizar o status do usuário')),
                        );
                      }
                    },
                  ),
                ),
                const Text(
                  'Tornar Assistente Adm.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInformationCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildCategoryTile(
            icon: Icons.person,
            title: 'Informações Pessoais',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoPessoalAdmPage(selectedUser: user!),
                ),
              );
            },
          ),
          _buildCategoryTile(
            icon: Icons.contact_phone,
            title: 'Contatos',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ContatosAdmPage(selectedUser: user!),
                ),
              );
            },
          ),
          _buildCategoryTile(
            icon: Icons.info,
            title: 'Dados Adicionais',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DadosAdicionaisAdmPage(selectedUser: user!),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
