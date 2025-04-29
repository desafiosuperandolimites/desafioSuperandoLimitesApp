part of '../../env.dart';

class PerfilPageAdmin extends StatefulWidget {
  const PerfilPageAdmin({
    super.key,
  }); // Defina o valor padrão como false

  @override
  PerfilPageAdminState createState() => PerfilPageAdminState();
}

class PerfilPageAdminState extends State<PerfilPageAdmin> {
  final UserController _userController = UserController();
  final GrupoController _grupoController = GrupoController();
  final FileController _fileController = FileController();
  List<Grupo> grupos = [];
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? fileName;
  File? _downloadedImage;
  Usuario? user;

  final String? baseUrl = dotenv.env['BASE_URL'];

  @override
  void initState() {
    super.initState();
    _loadGruposFromBackend();
    _loadCachedImage(); // Tenta carregar do cache primeiro
    _loadImage(); // Depois tenta baixar (se necessário)
  }

  Future<void> _loadImage() async {
    await _userController.fetchCurrentUser();
    user = _userController.user;
    if (kDebugMode) {
      print('User: ${user!.id} / FotoPerfil: ${user!.fotoPerfil}');
    }

    // Tenta carregar a imagem do cache primeiro
    final cachedImage = await _getCachedImageFile();
    if (await cachedImage.exists()) {
      // Se existir, carrega a imagem do cache
      setState(() {
        _downloadedImage = cachedImage;
      });
      if (kDebugMode) {
        print('Imagem carregada do cache: ${cachedImage.path}');
      }
    } else {
      // Caso não exista no cache, faz o download
      await _fileController.downloadFileFotosPerfil(user!.fotoPerfil);
      if (kDebugMode) {
        print('Downloaded file: ${_fileController.downloadedFile}');
      }

      // Salva a imagem no cache
      if (_fileController.downloadedFile != null) {
        await _saveImageToCache(_fileController.downloadedFile!);
      }

      setState(() {
        _downloadedImage = _fileController.downloadedFile;
      });
    }
  }

  Future<void> _loadGruposFromBackend() async {
    await _grupoController.fetchGrupos();
    if (mounted) {
      setState(() {
        grupos = _grupoController.groupList;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      // Usar permissão de armazenamento para galeria no Android
      if (Platform.isAndroid) {
        await Permission.storage.request();
      } else {
        // Usar permissão de fotos para galeria no iOS
        await Permission.photos.request();
      }
    }

    // Escolhe a imagem da câmera ou galeria
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Envia a imagem ao backend
      await _fileController.uploadFileFotosPerfil(_image);

      // Atualiza as informações do usuário no backend
      Usuario updatedUser = Usuario(
        id: user!.id,
        nome: user!.nome,
        email: user!.email,
        situacao: user!.situacao,
        cadastroPendente: user!.cadastroPendente,
        pagamentoPendente: user!.pagamentoPendente,
        // Pega apenas o nome do arquivo
        fotoPerfil: _image!.path.split('/').last,
      );
      if (!mounted) return;
      await _userController.updateUser(context, user!.id, updatedUser);

      // Salva a nova imagem no cache
      await _saveImageToCache(_image!);

      // Carrega a nova imagem
      await _loadImage();
    }
  }

  String getGrupoName(int? idGrupoEvento) {
    if (idGrupoEvento == null) {
      return 'Grupo não foi informado';
    }
    final grupo = grupos.firstWhere(
      (g) => g.id == idGrupoEvento,
      orElse: () => Grupo(
        id: 0,
        nome: 'Desconhecido',
        cnpj: '00000000000000',
        situacao: false,
      ),
    );
    return grupo.nome;
  }

  Widget _buildProfileImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: AspectRatio(
        aspectRatio: 1, // Mantém a proporção quadrada
        child: _downloadedImage != null
            ? Image.file(_downloadedImage!, fit: BoxFit.cover)
            : Image.asset('assets/image/Logo.png', fit: BoxFit.cover),
      ),
    );
  }

  Future<File> _getCachedImageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/perfil.jpg'); // Nome fixo para imagem de perfil
  }

  Future<void> _saveImageToCache(File image) async {
    final cachedImage = await _getCachedImageFile();
    await image.copy(cachedImage.path);
  }

  Future<void> _loadCachedImage() async {
    final cachedImage = await _getCachedImageFile();
    if (await cachedImage.exists()) {
      setState(() {
        _downloadedImage = cachedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 720;

    Color semicircleColor = Colors.black;

    double textScaleFactor = isSmallScreen ? 0.8 : 1.2;
    double buttonScaleFactor = isSmallScreen ? 0.8 : 0.8;
    double semicircleHeight =
        isSmallScreen ? screenHeight * 0.15 : screenHeight * 0.2;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<UserController>(
          builder: (context, userController, child) {
            final user = userController.user;
            final tipoPerfil = user?.idTipoPerfil;

            return Stack(
              children: <Widget>[
                CustomSemicirculoPerfil(
                  height: semicircleHeight,
                  color: semicircleColor,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: screenHeight * (isSmallScreen ? 0.05 : 0.06)),
                    Center(
                      child: Text(
                        'Meu Perfil',
                        style: TextStyle(
                          fontSize: 22 * textScaleFactor,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: screenHeight * (isSmallScreen ? 0.01 : 0.06)),
                    Container(
                      width: 100 * buttonScaleFactor,
                      height: 100 * buttonScaleFactor,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFF24A749),
                          width: 2.0 * buttonScaleFactor,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _buildProfileImage(),
                      ),
                    ),
                    SizedBox(height: 0.001 * buttonScaleFactor),
                    TextButton(
                      onPressed: () async {
                        final action = await showDialog<ImageSource>(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: const Center(
                              child: Text(
                                'Selecione uma opção',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            backgroundColor: Colors.white,
                            children: [
                              SimpleDialogOption(
                                onPressed: () => Navigator.of(context)
                                    .pop(ImageSource.camera),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: Colors.orange,
                                      size: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Tirar Foto',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.of(context)
                                    .pop(ImageSource.gallery),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      color: Colors.orange,
                                      size: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Escolher da Galeria',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );

                        if (action != null) {
                          await _pickImage(action);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 16.0 * buttonScaleFactor,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Alterar Foto',
                            style: TextStyle(
                              fontSize: 16 * textScaleFactor,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: screenHeight * (isSmallScreen ? 0.005 : 0.05)),
                    Text(
                      user?.nome ?? 'Carregando...',
                      style: TextStyle(
                        fontSize: 18 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      user != null
                          ? getGrupoName(user.idGrupoEvento)
                          : 'Carregando...',
                      style: TextStyle(
                        fontSize: 16 * textScaleFactor,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  top: screenHeight * (isSmallScreen ? 0.40 : 0.45),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              _buildListTile(
                                context,
                                Icons.person,
                                'Informações pessoais',
                                const InfoPessoalPageAdmin(),
                                textScaleFactor,
                                onTap: () {},
                              ),
                              _buildListTile(
                                context,
                                Icons.contact_phone,
                                'Contatos',
                                const ContatosPageAdmin(),
                                textScaleFactor,
                                onTap: () {},
                              ),
                              _buildListTile(
                                context,
                                Icons.info,
                                'Dados adicionais',
                                const DadosAdicionaisPageAdmin(),
                                textScaleFactor,
                                onTap: () {},
                              ),
                              _buildListTile(
                                context,
                                Icons.account_balance,
                                'Dados Bancários',
                                const CadastrarDadosBancariosPage(),
                                textScaleFactor,
                                onTap: () {},
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (tipoPerfil == 1 || tipoPerfil == 2) ...[
                          SizedBox(
                              height: screenHeight *
                                  (isSmallScreen ? 0.005 : 0.05)),
                        ],
                        _buildLogoutButton(context, textScaleFactor),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar:
            const CustomBottomNavigationBarAdm(currentIndex: 4));
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title,
      Widget page, double textScaleFactor,
      {required Null Function() onTap}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: TextStyle(fontSize: 16 * textScaleFactor),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16 * textScaleFactor),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, double textScaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * textScaleFactor),
      child: TextButton.icon(
        onPressed: () {
          AuthController().logout(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TipoLoginPage(
                      noticiaExiste: false,
                    )),
          );
        },
        icon: Icon(
          Icons.exit_to_app,
          color: const Color(0xFF8E8E8E),
          size: 20 * textScaleFactor,
        ),
        label: Text(
          'Sair da Conta',
          style: TextStyle(
            color: const Color(0xFF8E8E8E),
            fontSize: 16 * textScaleFactor,
          ),
        ),
      ),
    );
  }
}
