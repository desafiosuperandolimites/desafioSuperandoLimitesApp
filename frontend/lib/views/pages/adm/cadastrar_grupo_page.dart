part of '../../env.dart';

class CadastrarGrupoPage extends StatefulWidget {
  final Grupo? grupo; // Evento selecionado
  final bool isEditing; // Indica se é edição

  const CadastrarGrupoPage({super.key, this.grupo, this.isEditing = false});

  @override
  CadastrarGrupoPageState createState() => CadastrarGrupoPageState();
}

class CadastrarGrupoPageState extends State<CadastrarGrupoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final MaskedTextController _cnpjController = Mascaras.cnpjController();
  final GrupoController _grupoController = GrupoController();
  final CampoPersonalizadoController _campoPersonalizadoController =
      CampoPersonalizadoController();

  List<CampoPersonalizado> _camposPersonalizados = [];
  String? _nomeError;
  String? _cnpjError;
  bool _grupoAtivo = true;

  @override
  void initState() {
    super.initState();

    if (widget.grupo != null) {
      // Preencher os controladores com os dados do grupo em modo de edição
      _nomeController.text = widget.grupo!.nome;
      _cnpjController.text = widget.grupo!.cnpj;
      _grupoAtivo = widget.grupo!.situacao;
      _fetchCamposPersonalizados();
    }
  }

  Future<void> _fetchCamposPersonalizados() async {
    if (widget.grupo != null && widget.grupo!.id != null) {
      await _campoPersonalizadoController.fetchCamposPersonalizados(
          idGruposEvento: widget.grupo!.id!);
      setState(() {
        _camposPersonalizados = _campoPersonalizadoController.campoList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    bool hasManyCampos = _camposPersonalizados.length > 2;

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
                widget.isEditing ? 'Meu Grupo' : 'Cadastrar Grupo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (widget.isEditing)
            Positioned(
              top: screenHeight * 0.125,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: _grupoAtivo,
                            onChanged: (bool value) {
                              setState(() {
                                _grupoAtivo = value;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ),
                        Text(
                          _grupoAtivo ? 'Grupo Ativo' : 'Grupo Inativo',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: widget.isEditing ? screenHeight * 0.18 : screenHeight * 0.14,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: ListView(
                children: [
                  _buildTextField(
                    'Nome do Grupo',
                    _nomeController,
                    screenWidth,
                    scaleFactor: scaleFactor,
                    maxLength: 10, // Limite de caracteres
                    onChanged: (value) {
                      setState(() {
                        if (value.length > 11) {
                          _nomeError =
                              'O nome não pode ter mais de 12 caracteres.';
                        } else {
                          _nomeError = null; // Reseta a mensagem de erro
                        }
                      });
                    },
                  ),
                  if (_nomeError != null) // Verifica se há erro
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _nomeError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  _buildTextField(
                    'CNPJ', _cnpjController, screenWidth,
                    scaleFactor: scaleFactor,
                    maxLength: 18, // Limite de caracteres
                    onChanged: (value) {
                      setState(() {
                        if (value.length > 17) {
                          _cnpjError =
                              'O CNPJ não pode ter mais de 14 caracteres.';
                        } else {
                          _cnpjError = null; // Reseta a mensagem de erro
                        }
                      });
                    },
                  ),
                  if (_cnpjError != null) // Verifica se há erro
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _cnpjError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  if (widget.isEditing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 15),
                        // Retângulo com sombra contendo "Todos" e ícone de ordenação
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 2.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.zero,
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
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Campos Personalizados (${_camposPersonalizados.length})',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              _buildAddCampoButton(screenWidth, scaleFactor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildCamposPersonalizadosList(scaleFactor),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Positioned(
            top: widget.isEditing ? screenHeight * 0.73 : screenHeight * 0.73,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: ListView(
                children: [
                  _buildSaveButton(screenWidth, screenHeight, scaleFactor),
                  hasManyCampos
                      ? _buildBackButton()
                      : const CustomButtonVoltar(),
                ],
              ),
            ),
          ),
          // Botão Voltar fixo no final da página
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
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
      ),
    );
  }

  Widget _buildAddCampoButton(double screenWidth, double scaleFactor) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CriarCampoPersonalizadoPage(
                  grupoId: widget.grupo!.id!, grupo: widget.grupo!),
            ),
          );
          if (result == true) _fetchCamposPersonalizados();
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
    );
  }

  Widget _buildCamposPersonalizadosList(double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _camposPersonalizados.length,
          itemBuilder: (context, index) {
            final campo = _camposPersonalizados[index];
            return GestureDetector(
              onTap: () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampoPersonalizadoPage(
                        campoPersonalizado: campo, grupo: widget.grupo!),
                  ),
                );
                if (result == true) {
                  _fetchCamposPersonalizados(); // Refresh the list after returning
                }
              },
              child: Container(
                height:
                    55, // Adjust this value to match the height of the text fields
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      255, 217, 217, 217), // Darker background
                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      campo.nomeCampo,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[
                            600], // Match the label color of the text field
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward, // Arrow icon at the end
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, double screenWidth,
      {int maxLines = 1,
      required double scaleFactor,
      int? maxLength,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLength: maxLength, // Adiciona o limite de caracteres
      onChanged: onChanged, // Chama a função onChanged se fornecida
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1), // Borda com 50% de opacidade
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1), // Borda ao habilitar com 50% de opacidade
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1), // Borda ao focar com 50% de opacidade
        ),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildSaveButton(
      double screenWidth, double screenHeight, double scaleFactor) {
    return SizedBox(
      height: screenHeight * 0.070,
      child: Center(
        child: CustomButtonSalvar(
          onSave: () async {
            if (widget.isEditing &&
                widget.grupo != null &&
                widget.grupo!.id != null) {
              // Atualizar o grupo existente
              await _grupoController.updateGrupo(
                context,
                widget.grupo!.id!, // Garante que o ID não seja nulo
                Grupo(
                  id: widget.grupo!.id,
                  nome: _nomeController.text,
                  cnpj: _cnpjController.text
                      .replaceAll('.', '')
                      .replaceAll('/', '')
                      .replaceAll('-', ''),
                  qtdUsuarios: widget.grupo!.qtdUsuarios,
                  situacao: _grupoAtivo, // Atualiza o status do grupo
                ),
              );

              if (!mounted) return;

              // Mostrar mensagem de sucesso ao editar
              SalvoSucessoSnackBar.show(context,
                  message: 'Grupo alterado com sucesso');
            } else {
              // Criar um novo grupo
              await _grupoController.createGrupo(
                context,
                Grupo(
                  nome: _nomeController.text,
                  cnpj: _cnpjController.text
                      .replaceAll('.', '')
                      .replaceAll('/', '')
                      .replaceAll('-', ''),
                  situacao: _grupoAtivo,
                ),
              );

              if (!mounted) return;

              // Mostrar mensagem de sucesso ao criar
              SalvoSucessoSnackBar.show(context,
                  message: 'Grupo criado com sucesso');
            }

            // Navegar de volta à página de gestão de grupo
            Navigator.pushReplacementNamed(context, '/gestao-grupo');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }
}
