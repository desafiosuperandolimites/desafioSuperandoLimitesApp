part of '../../env.dart';

class CadastrarDepoimentoPage extends StatefulWidget {
  const CadastrarDepoimentoPage({super.key});

  @override
  State<CadastrarDepoimentoPage> createState() =>
      _CadastrarDepoimentoPageState();
}

class _CadastrarDepoimentoPageState extends State<CadastrarDepoimentoPage> {
  final DepoimentoController _depoimentoController = DepoimentoController();
  final TextEditingController _newLinkController = TextEditingController();
  List<Depoimento> _depoimentosCadastrados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepoimentos();
  }

  Future<void> _loadDepoimentos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _depoimentoController.fetchDepoimentos();
      setState(() {
        _depoimentosCadastrados = _depoimentoController.depoimentoList;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar depoimentos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addDepoimento(String link) async {
    try {
      await _depoimentoController.createDepoimento(
        context,
        Depoimento(
          idUsuario: 1, // Substitua pelo ID do usuário logado ou admin
          link: link,
          situacao: true,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depoimento adicionado com sucesso!')),
      );
      _newLinkController.clear(); // Limpa o campo após adicionar
      await _loadDepoimentos(); // Recarrega a lista de depoimentos
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar depoimento: $e')),
      );
    }
  }

  Future<void> _deleteDepoimento(int id) async {
    try {
      await _depoimentoController.deleteDepoimento(context, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Depoimento excluído com sucesso!')),
      );
      await _loadDepoimentos(); // Recarrega a lista de depoimentos
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir depoimento: $e')),
      );
    }
  }

  Widget _buildNewLinkField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48, // Garantimos a mesma altura para o campo de texto
              child: TextFormField(
                controller: _newLinkController,
                decoration: const InputDecoration(
                  hintText: "Colar URL do YouTube",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(
              width: 8), // Espaçamento consistente entre os elementos
          SizedBox(
            height: 48, // Mesma altura do campo de texto
            width: 48, // Largura proporcional
            child: ElevatedButton(
              onPressed: () {
                final link = _newLinkController.text.trim();
                if (link.isEmpty ||
                    (!link.startsWith("https://www.youtube.com") &&
                        !link.startsWith("https://youtu.be"))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Insira uma URL válida do YouTube")),
                  );
                  return;
                }
                _addDepoimento(link);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bordas arredondadas
                ),
                padding: EdgeInsets.zero, // Remove padding interno do botão
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepoimentoList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_depoimentosCadastrados.isEmpty) {
      return const Text("Nenhum depoimento cadastrado.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _depoimentosCadastrados.length,
      itemBuilder: (context, index) {
        final depoimento = _depoimentosCadastrados[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  enabled: false,
                  initialValue: depoimento.link,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48, // Mesma altura do botão de "Add"
                width: 48, // Largura consistente com o botão "Add"
                child: GestureDetector(
                  onTap: () => _deleteDepoimento(depoimento.id!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fundo branco
          Container(color: Colors.white),

          // CustomSemicirculo
          CustomSemicirculo(
            height: screenHeight * 0.12,
            color: Colors.black,
          ),

          // Título
          Positioned(
            top: screenHeight * 0.04,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Gestão de Depoimentos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Conteúdo
          Positioned(
            top: screenHeight * 0.14,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                children: [
                  const Text(
                    "Adicione o vídeo:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Campo para adicionar novos links
                  if (_depoimentosCadastrados.length < 4) _buildNewLinkField(),

                  //const SizedBox(height: 10),

                  // Lista de depoimentos cadastrados
                  Expanded(child: _buildDepoimentoList()),

                  //const SizedBox(height: 10),

                  // Texto de limite
                  if (_depoimentosCadastrados.length >= 4)
                    const Text(
                      "*O limite para upload de vídeos é de 4 vídeos.",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),

                  // Botão "Voltar"
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ],
      ),

      // CustomBottomNavigationBarAdm
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 2),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
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
    _newLinkController.dispose();
    super.dispose();
  }
}
