part of '../../env.dart';

class CriarCampoPersonalizadoPage extends StatefulWidget {
  final Grupo? grupo;
  final int grupoId;

  const CriarCampoPersonalizadoPage(
      {super.key, required this.grupoId, required this.grupo});

  @override
  CriarCampoPersonalizadoPageState createState() =>
      CriarCampoPersonalizadoPageState();
}

class CriarCampoPersonalizadoPageState
    extends State<CriarCampoPersonalizadoPage> {
  final TextEditingController _nomeCampoController = TextEditingController();
  bool _obrigatorio = false;

  final TipoCampoController _tipoCampoController = TipoCampoController();
  List<TipoCampo> _tipoCampoList = [];
  TipoCampo? _selectedTipoCampo;

  // For RadioButton options
  final List<TextEditingController> _opcaoControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchTipoCampo();
  }

  Future<void> _fetchTipoCampo() async {
    await _tipoCampoController.fetchTiposCampo();
    // Filter out "Dropdown" option
    setState(() {
      _tipoCampoList = _tipoCampoController.tipoCampoList.where((tipo) {
        return tipo.chaveNome != 'DROPDOWN';
      }).toList();
    });
  }

  void _saveCampoPersonalizado() async {
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

    if (_selectedTipoCampo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o tipo do campo')),
      );
      return;
    }

    // If RadioButton, ensure at least two options are provided
    if (_selectedTipoCampo!.chaveNome == 'RADIOBUTTON') {
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

    CampoPersonalizadoController campoController =
        CampoPersonalizadoController();

    CampoPersonalizado novoCampo = CampoPersonalizado(
      idGruposEvento: widget.grupoId,
      idTipoCampo: _selectedTipoCampo!.id,
      nomeCampo: _nomeCampoController.text,
      obrigatorio: _obrigatorio,
      situacao: true,
    );

    try {
      CampoPersonalizado createdCampo =
          await campoController.createCampoPersonalizado(context, novoCampo);

      // If RadioButton, create options
      if (_selectedTipoCampo!.chaveNome == 'RADIOBUTTON') {
        // Assuming that the backend returns the created CampoPersonalizado with its ID
        int? campoId = createdCampo.id;
        if (kDebugMode) {
          print('Campo ID: $campoId');
        }
        if (campoId != null) {
          for (var controller in _opcaoControllers) {
            // Create OpcaoCampo
            OpcaoCampo opcao = OpcaoCampo(
              idCamposPersonalizados: campoId,
              opcao: controller.text,
            );
            OpcaoCampoController opcaoController = OpcaoCampoController();
            if (!mounted) return;
            await opcaoController.createOpcaoCampo(context, opcao);
          }
        }
      }

      if (!mounted) return;

      SalvoSucessoSnackBar.show(context,
          message: 'Campo personalizado criado com sucesso');

      // Navigate back to previous page
      Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar campo personalizado: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar campo personalizado: $e')),
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
                'Criar Campo Personalizado',
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                  // TipoCampo Dropdown
                  _buildTipoCampoDropdown(scaleFactor),
                  const SizedBox(height: 15),
                  // Nome do Campo
                  _buildTextField('Pergunta', _nomeCampoController, screenWidth,
                      scaleFactor: scaleFactor),
                  const SizedBox(height: 15),
                  // Dynamic options for RadioButton
                  if (_selectedTipoCampo != null &&
                      _selectedTipoCampo!.chaveNome == 'RADIOBUTTON')
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

  Widget _buildTipoCampoDropdown(double scaleFactor) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<TipoCampo>(
        value: _selectedTipoCampo,
        decoration: InputDecoration(
          hintStyle: const TextStyle(color: Colors.grey),
          hintText: 'Tipo do Campo',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide:
                BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide:
                BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide:
                BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
        ),
        items: _tipoCampoList.map((tipo) {
          return DropdownMenuItem<TipoCampo>(
            value: tipo,
            child: Text(tipo.descricao),
          );
        }).toList(),
        onChanged: (TipoCampo? newValue) {
          setState(() {
            _selectedTipoCampo = newValue;
            // Clear option controllers when changing type
            if (_selectedTipoCampo!.chaveNome != 'RADIOBUTTON') {
              _opcaoControllers.clear();
            }
          });
        },
        dropdownColor: Colors.white,
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
                  });
                },
              ),
              const SizedBox(height: 70), // Add this to create more space
            ],
          );
        }),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _opcaoControllers.add(TextEditingController());
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
          onSave: _saveCampoPersonalizado,
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
