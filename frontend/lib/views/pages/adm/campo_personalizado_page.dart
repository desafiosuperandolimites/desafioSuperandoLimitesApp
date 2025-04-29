part of '../../env.dart';

class CampoPersonalizadoPage extends StatefulWidget {
  final Grupo? grupo;
  final CampoPersonalizado campoPersonalizado;

  const CampoPersonalizadoPage(
      {super.key, required this.campoPersonalizado, required this.grupo});

  @override
  CampoPersonalizadoPageState createState() => CampoPersonalizadoPageState();
}

class CampoPersonalizadoPageState extends State<CampoPersonalizadoPage> {
  final TextEditingController _nomeCampoController = TextEditingController();
  final List<OpcaoCampo> _opcoesCampoRemovidas = [];
  final OpcaoCampoController _opcaoCampoController = OpcaoCampoController();
  final CampoPersonalizadoController campoController =
      CampoPersonalizadoController();

  bool _obrigatorio = false;
  bool _situacao = true;
  TipoCampo? _tipoCampo;
  List<OpcaoCampo> _opcoesCampo = [];
  List<TextEditingController> _opcaoControllers = [];

  @override
  void initState() {
    super.initState();
    _nomeCampoController.text = widget.campoPersonalizado.nomeCampo;
    _obrigatorio = widget.campoPersonalizado.obrigatorio;
    _situacao = widget.campoPersonalizado.situacao;
    _initializeData();
  }

  void _initializeData() async {
    await _fetchTipoCampo();
    await _fetchOpcoesCampo();
  }

  Future<void> _fetchTipoCampo() async {
    TipoCampoController tipoCampoController = TipoCampoController();
    await tipoCampoController.fetchTiposCampo();
    setState(() {
      _tipoCampo = tipoCampoController.tipoCampoList.firstWhere(
        (tipo) => tipo.id == widget.campoPersonalizado.idTipoCampo,
        orElse: () => TipoCampo(
            id: 0, descricao: 'Desconhecido', chaveNome: '', situacao: true),
      );
    });
  }

  Future<void> _fetchOpcoesCampo() async {
    if (_tipoCampo != null && _tipoCampo!.chaveNome == 'RADIOBUTTON') {
      await _opcaoCampoController.fetchOpcoesCampo(
        idCamposPersonalizados: widget.campoPersonalizado.id!,
      );
      setState(() {
        _opcoesCampo = _opcaoCampoController.opcaoList;
        _opcaoControllers = _opcoesCampo.map((opcao) {
          return TextEditingController(text: opcao.opcao);
        }).toList();
      });
    }
  }

  void _updateCampoPersonalizado() async {
    if (_nomeCampoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira a pergunta')),
      );
      return;
    }

    //Verificar se a pergunta tem no máximo 50 caracteres
    if (_nomeCampoController.text.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A pergunta deve ter no máximo 50 caracteres')),
      );
      return;
    }

    // If RadioButton, ensure at least two options are provided
    if (_tipoCampo?.chaveNome == 'RADIOBUTTON') {
      if (_opcaoControllers.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, insira pelo menos duas respostas')),
        );
        return;
      }
      if (_opcaoControllers.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Número máximo de respostas é 5')),
        );
        return;
      }
      // Ensure no option is empty
      for (var controller in _opcaoControllers) {
        if (controller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Por favor, preencha todas as respostas')),
          );
          return;
        }
      }
    }

    CampoPersonalizado updatedCampo = CampoPersonalizado(
      id: widget.campoPersonalizado.id,
      idGruposEvento: widget.campoPersonalizado.idGruposEvento,
      idTipoCampo: widget.campoPersonalizado.idTipoCampo,
      nomeCampo: _nomeCampoController.text,
      obrigatorio: _obrigatorio,
      situacao: _situacao,
    );

    try {
      await campoController.updateCampoPersonalizado(
          context, updatedCampo.id!, updatedCampo);

      // If RadioButton, update options
      if (_tipoCampo != null && _tipoCampo!.chaveNome == 'RADIOBUTTON') {
        for (int i = 0; i < _opcaoControllers.length; i++) {
          OpcaoCampo opcao = _opcoesCampo[i];
          opcao.opcao = _opcaoControllers[i].text;

          OpcaoCampoController opcaoController = OpcaoCampoController();
          if (!mounted) return;
          if (opcao.id != null) {
            // Update existing option
            await opcaoController.updateOpcaoCampo(context, opcao.id!, opcao);
          } else {
            // Create new option
            await opcaoController.createOpcaoCampo(context, opcao);
          }
        }

        // Delete removed options
        for (var opcao in _opcoesCampoRemovidas) {
          if (!mounted) return;
          OpcaoCampoController opcaoController = OpcaoCampoController();
          await opcaoController.deleteOpcaoCampo(context, opcao.id!);
        }
        // Clear the removed options list after deletion
        _opcoesCampoRemovidas.clear();
      }

      if (!mounted) return;

      SalvoSucessoSnackBar.show(context,
          message: 'Campo personalizado alterado com sucesso');
      // Navigate back to previous page
      Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar campo personalizado: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar campo personalizado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    bool hasManyCampos = _opcaoControllers.length > 2;

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
            child: const Center(
              child: Text(
                'Editar Campo Personalizado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
                          value: _situacao,
                          onChanged: (bool value) {
                            setState(() {
                              _situacao = value;
                            });
                          },
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.grey,
                        ),
                      ),
                      Text(
                        _situacao ? 'Ativo' : 'Inativo',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(width: screenWidth * 0.3),
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: _obrigatorio,
                          onChanged: (bool value) {
                            setState(() {
                              _obrigatorio = value;
                            });
                          },
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.grey,
                        ),
                      ),
                      Text(
                        _obrigatorio ? 'Obrigatório' : 'Obrigatório',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.18,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: ListView(
                children: [
                  // Display TipoCampo
                  _buildTipoCampoDisplay(scaleFactor),
                  const SizedBox(height: 15),
                  // Nome do Campo
                  _buildTextField('Pergunta', _nomeCampoController, screenWidth,
                      scaleFactor: scaleFactor),
                  const SizedBox(height: 15),
                  // Dynamic options for RadioButton
                  if (_tipoCampo != null &&
                      _tipoCampo!.chaveNome == 'RADIOBUTTON')
                    _buildRadioButtonOptions(scaleFactor),
                  const SizedBox(height: 40),
                  _buildSaveButton(screenWidth, screenHeight, scaleFactor),
                  if (hasManyCampos) _buildBackButton(),
                ],
              ),
            ),
          ),
          // Botão Voltar fixo no final da página
          if (!hasManyCampos) const CustomButtonVoltar(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildTipoCampoDisplay(double scaleFactor) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Tipo do Campo',
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
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
      controller:
          TextEditingController(text: _tipoCampo?.descricao ?? 'Carregando...'),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, double screenWidth,
      {int maxLines = 1, required double scaleFactor}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
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
      maxLines: maxLines,
    );
  }

  Widget _buildRadioButtonOptions(double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        ..._opcaoControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Row(
            children: [
              Expanded(
                child: _buildTextField('Resposta ${index + 1}', controller,
                    MediaQuery.of(context).size.width,
                    scaleFactor: scaleFactor),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _opcaoControllers.removeAt(index);
                    // Remove the option and add to removed list if it exists in the database
                    OpcaoCampo opcaoRemovida = _opcoesCampo.removeAt(index);
                    if (opcaoRemovida.id != null) {
                      _opcoesCampoRemovidas.add(opcaoRemovida);
                    }
                  });
                },
              ),
              const SizedBox(height: 70),
            ],
          );
        }),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _opcaoControllers.add(TextEditingController());
              _opcoesCampo.add(OpcaoCampo(
                  idCamposPersonalizados: widget.campoPersonalizado.id!,
                  opcao: ''));
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[500],
          ),
          icon: const Icon(Icons.add_circle, color: Colors.green),
          label: const Text('Adicionar Resposta'),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
      double screenWidth, double screenHeight, double scaleFactor) {
    return SizedBox(
      height: screenHeight * 0.070,
      child: Center(
        child: CustomButtonSalvar(
          onSave: _updateCampoPersonalizado,
        ),
      ),
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

  @override
  void dispose() {
    _nomeCampoController.dispose();
    for (var controller in _opcaoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
