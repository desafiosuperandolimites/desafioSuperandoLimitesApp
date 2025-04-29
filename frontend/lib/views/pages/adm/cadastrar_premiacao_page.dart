part of '../../env.dart';

class CadastrarPremiacaoPage extends StatefulWidget {
  final dynamic premiacao; // Premiacao selecionado
  final bool isEditing; // Indica se é edição

  const CadastrarPremiacaoPage(
      {super.key, this.premiacao, this.isEditing = false});

  @override
  CadastrarPremiacaoPageState createState() => CadastrarPremiacaoPageState();
}

class CadastrarPremiacaoPageState extends State<CadastrarPremiacaoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final PremiacaoController _premiacaoController = PremiacaoController();

  String? _nomeError;
  String? _descricaoError;
  bool _premiacaoAtivo = true;

  @override
  void initState() {
    super.initState();

    if (widget.premiacao != null) {
      // Preencher os controladores com os dados do evento
      _nomeController.text = widget.premiacao.nome;
      _descricaoController.text = widget.premiacao.descricao;
      _premiacaoAtivo = widget.premiacao.situacao;
    }
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
                widget.isEditing ? 'Minha Premiação' : 'Cadastrar Premiação',
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
                            value: _premiacaoAtivo,
                            onChanged: (bool value) {
                              setState(() {
                                _premiacaoAtivo = value;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ),
                        Text(
                          _premiacaoAtivo
                              ? 'Premiação Ativo'
                              : 'Premiação Inativo',
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
                    'Nome da Premiação', _nomeController, screenWidth,
                    scaleFactor: scaleFactor,
                    maxLength: 12, // Limite de caracteres
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
                  //const SizedBox(height: 15),
                  _buildTextField(
                    'Descrição da Premiação',
                    _descricaoController, screenWidth,
                    maxLines: 4, scaleFactor: scaleFactor,
                    maxLength: 150, // Limite de caracteres
                    onChanged: (value) {
                      setState(() {
                        if (value.length > 149) {
                          _descricaoError =
                              'A descrição não pode ter mais de 150 caracteres.';
                        } else {
                          _descricaoError = null; // Reseta a mensagem de erro
                        }
                      });
                    },
                  ),
                  if (_descricaoError != null) // Verifica se há erro
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _descricaoError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 40),
                  //_buildSaveButton(screenWidth, screenHeight, scaleFactor),
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
                  const CustomButtonVoltar(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
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
                widget.premiacao != null &&
                widget.premiacao!.id != null) {
              await _premiacaoController.updatePremiacao(
                context,
                widget.premiacao!.id!, // Garante que o ID não seja nulo
                Premiacao(
                  id: widget.premiacao!.id,
                  nome: _nomeController.text,
                  descricao: _descricaoController.text,
                  situacao: _premiacaoAtivo, // Atualiza o status do grupo
                ),
              );
              if (!mounted) return;
              // Mostrar mensagem de sucesso ao editar
              SalvoSucessoSnackBar.show(context,
                  message: 'Premiação alterada com sucesso');
            } else {
              await _premiacaoController.createPremiacao(
                context,
                Premiacao(
                  nome: _nomeController.text,
                  descricao: _descricaoController.text,
                  situacao: _premiacaoAtivo,
                ),
              );
              if (!mounted) return;
              SalvoSucessoSnackBar.show(context,
                  message: 'Premiação criada com sucesso');
            }
            Navigator.pushReplacementNamed(context, '/gestao-premiacao');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}
