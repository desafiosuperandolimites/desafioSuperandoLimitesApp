part of '../../env.dart';

class GestaoUsuarioPage extends StatefulWidget {
  const GestaoUsuarioPage({super.key});

  @override
  GestaoUsuarioPageState createState() => GestaoUsuarioPageState();
}

class GestaoUsuarioPageState extends State<GestaoUsuarioPage> {
  final UserController _userController = UserController();
  final GrupoController _grupoController = GrupoController();
  final FileController _fileController =
      FileController(); // FileController for photos

  List<Grupo> grupos = [];
  List<Usuario> users = [];
  List<Usuario> filteredUsers = [];
  bool isAscending = false;
  int? selectedGroup;
  String? selectedStatus = 'Todos';
  String searchQuery = '';
  Map<int, File?> userPhotos = {};

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();
  }

  Future<void> _loadDataFromBackend() async {
    await Future.wait([
      _loadUsersFromBackend(),
      _loadGruposFromBackend(),
    ]);
    await _downloadUsersPhotos();
    setState(() {});
  }

  Future<void> _loadUsersFromBackend() async {
    await _userController.fetchUsers(); // Fetch users from backend
    setState(() {
      users = _userController.userList;
      filteredUsers = List.from(users);
    });
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    setState(() {
      grupos = _grupoController.groupList;
    });
  }

  // Download each user's photo if available
  Future<void> _downloadUsersPhotos() async {
    for (var user in users) {
      if (user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty) {
        await _fileController.downloadFileFotosPerfil(user.fotoPerfil!);
        userPhotos[user.id] = _fileController.downloadedFile;
      } else {
        userPhotos[user.id] = null;
      }
    }
  }

  void _sortUsers() {
    setState(() {
      if (isAscending) {
        filteredUsers.sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      } else {
        filteredUsers.sort(
            (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
      }
      isAscending = !isAscending;
    });
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

  void _filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        final matchGroup =
            selectedGroup == null || user.idGrupoEvento == selectedGroup;
        final matchStatus = selectedStatus == 'Todos' ||
            (selectedStatus == 'Ativo' && user.situacao == true) ||
            (selectedStatus == 'Inativo' && user.situacao == false);
        final matchNameOrCpf =
            user.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (user.cpf != null && user.cpf!.contains(searchQuery));
        return matchGroup && matchStatus && matchNameOrCpf;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Semicírculo no topo da tela
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
                'Gestão de Usuários',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Conteúdo principal
          Column(
            children: <Widget>[
              SizedBox(
                  height: screenHeight *
                      0.14), // Ajuste para começar após o semicírculo
              // Campo de pesquisa e botão de adicionar usuário
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            _filterUsers();
                          });
                        },
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.search),
                          hintText: 'Buscar nome ou CPF',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/criar-usuario');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Filtros e botão de ordenação
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Filtro de grupo
                    Expanded(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonHideUnderline(
                          // Esconde a linha sublinhada
                          child: DropdownButtonFormField<int?>(
                            value: selectedGroup,
                            icon: const Icon(
                                null), // Remove o ícone de seta para baixo
                            dropdownColor: Colors
                                .white, // Define a cor do menu expandido como branco
                            isExpanded:
                                false, // Evita que o menu expanda além do tamanho necessário
                            decoration: InputDecoration(
                              suffixIcon: const Icon(
                                  Icons.filter_alt_outlined), // Ícone de funil
                              hintText: 'Grupo',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null, // Representing 'Todos'
                                child: Text('Todos',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal)),
                              ),
                              ...grupos.map((grupo) {
                                return DropdownMenuItem<int?>(
                                  value: grupo.id,
                                  child: Text(grupo.nome,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                );
                              }),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedGroup = newValue;
                                _filterUsers();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Filtro de status
                    Expanded(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonHideUnderline(
                          // Esconde a linha sublinhada
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            icon: const Icon(
                                null), // Remove o ícone de seta para baixo
                            dropdownColor: Colors
                                .white, // Define a cor do menu expandido como branco
                            isExpanded:
                                false, // Evita que o menu expanda além do tamanho necessário
                            decoration: InputDecoration(
                              suffixIcon: const Icon(
                                  Icons.filter_alt_outlined), // Ícone de funil
                              hintText: 'Status',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 1),
                              ),
                            ),
                            items: ['Todos', 'Ativo', 'Inativo']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal)),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedStatus = newValue;
                                _filterUsers();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Título e ícone de ordenação
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Todos (${filteredUsers.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Image.asset(
                        isAscending
                            ? 'assets/image/ZA.png'
                            : 'assets/image/AZ.png',
                        height: 15,
                        width: 15,
                      ),
                      onPressed: _sortUsers,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Lista de usuários
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    File? userPhoto = userPhotos[user.id];

                    Widget userPhotoWidget;
                    if (userPhoto != null) {
                      userPhotoWidget = CircleAvatar(
                        backgroundImage: FileImage(userPhoto),
                      );
                    } else {
                      userPhotoWidget = const CircleAvatar(
                        backgroundImage: AssetImage('assets/image/Logo.png'),
                      );
                    }

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          child: ListTile(
                            leading: userPhotoWidget,
                            title: Text(user.nome),
                            subtitle: Text(getGrupoName(user.idGrupoEvento)),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DadosCadastraisPage(
                                    selectedUser: user,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  },
                ),
              ),
              const CustomButtonVoltar()
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }
}
