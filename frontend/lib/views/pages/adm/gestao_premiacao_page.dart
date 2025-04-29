part of '../../env.dart';

class GestaoPremiacaoPage extends StatefulWidget {
  const GestaoPremiacaoPage({super.key});

  @override
  GestaoPremiacaoPageState createState() => GestaoPremiacaoPageState();
}

class GestaoPremiacaoPageState extends State<GestaoPremiacaoPage> {
  final PremiacaoController _premiacaoController = PremiacaoController();
  bool isAscending = false;
  List<Premiacao> premiacaos = [];
  List<Premiacao> filteredPremiacaos = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPremiacaosFromBackend();
  }

  Future<void> _loadPremiacaosFromBackend() async {
    await _premiacaoController.fetchPremiacaos(); // Fetch users from backend
    setState(() {
      premiacaos = _premiacaoController.premiacaoList;
      filteredPremiacaos = List.from(premiacaos);
    });
  }

  void _filterPremiacaos() {
    setState(() {
      filteredPremiacaos = premiacaos.where((premiacao) {
        return premiacao.nome.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _sortPremiacaos() {
    setState(() {
      if (isAscending) {
        filteredPremiacaos.sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      } else {
        filteredPremiacaos.sort(
            (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
      }
      isAscending = !isAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 430;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Stack para o semicirculo e título
          SizedBox(
            height: screenHeight * 0.15, // Aumente a altura para evitar corte
            child: Stack(
              children: [
                CustomSemicirculo(
                  height:
                      screenHeight * 0.15, // Ajuste para garantir visibilidade
                  color: Colors.black,
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Gestão de Premiações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _filterPremiacaos();
                      });
                    },
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por Premiação',
                      filled: true,
                      fillColor: Colors.white,
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
                            width:
                                1), // Borda ao habilitar com 50% de opacidade
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1), // Borda ao focar com 50% de opacidade
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, '/cadastrar-premiacao');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Mantenha o mesmo raio da borda
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
          // Retângulo com sombra contendo "Todos" e ícone de ordenação
          Container(
            padding: const EdgeInsets.all(1.0),
            margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
              // Remove os cantos arredondados
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
                    'Todos (${filteredPremiacaos.length})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Image.asset(
                    isAscending ? 'assets/image/ZA.png' : 'assets/image/AZ.png',
                    height: 15,
                    width: 15,
                  ),
                  onPressed: _sortPremiacaos,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Lista de premiacaos
          // Dentro do ListView.builder na GestaoPremiacaoPage
          Expanded(
            child: ListView.builder(
              itemCount: filteredPremiacaos.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CadastrarPremiacaoPage(
                              premiacao: filteredPremiacaos[index],
                              isEditing: true, // Passa isEditing como true
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                filteredPremiacaos[index].nome,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10, // Espaçamento de 15px entre os itens
                    ),
                  ],
                );
              },
            ),
          ),
          const CustomButtonVoltar(), // Botão Voltar
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }
}
