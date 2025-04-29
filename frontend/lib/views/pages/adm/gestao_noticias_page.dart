part of '../../env.dart';

class GestaoNoticiaPage extends StatefulWidget {
  const GestaoNoticiaPage({super.key});

  @override
  GestaoNoticiaPageState createState() => GestaoNoticiaPageState();
}

class GestaoNoticiaPageState extends State<GestaoNoticiaPage> {
  final FeedNoticiaController _feedNoticiaController = FeedNoticiaController();
  bool isAscending = false;
  List<FeedNoticia> noticias = [];
  List<FeedNoticia> filteredNoticias = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNoticiasFromBackend();
  }

  Future<void> _loadNoticiasFromBackend() async {
    await _feedNoticiaController
        .fetchFeedNoticias(); // Fetch noticias from backend
    setState(() {
      noticias = _feedNoticiaController.feedNoticiaList;
      filteredNoticias = List.from(noticias);
    });
  }

  void _filterNoticias() {
    setState(() {
      filteredNoticias = noticias.where((noticia) {
        return noticia.titulo.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _sortNoticias() {
    setState(() {
      if (isAscending) {
        filteredNoticias.sort(
            (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
      } else {
        filteredNoticias.sort(
            (a, b) => b.titulo.toLowerCase().compareTo(a.titulo.toLowerCase()));
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
            height: screenHeight * 0.15,
            child: Stack(
              children: [
                CustomSemicirculo(
                  height: screenHeight * 0.15,
                  color: Colors.black,
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Gestão de Notícias',
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
          const SizedBox(height: 10),

          // Campo de pesquisa e botão de adicionar notícia
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _filterNoticias();
                      });
                    },
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.search),
                      hintText: 'Buscar Notícias',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CriarNoticiaPage()),
                      );
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

          // Retângulo com sombra contendo "Todos" e ícone de ordenação
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
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
                    'Todos (${filteredNoticias.length})',
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
                  onPressed: _sortNoticias,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Lista de notícias, rolável
          Expanded(
            child: ListView.builder(
              itemCount: filteredNoticias.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CriarNoticiaPage(
                                      noticia: filteredNoticias[index],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                filteredNoticias[index].titulo,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final noticiaId = filteredNoticias[index].id;

                              if (noticiaId != null) {
                                bool? confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor:
                                        Colors.white, // Fundo branco do pop-up
                                    title: const Text(
                                      'Confirmar Exclusão',
                                      style: TextStyle(
                                          color: Colors.black), // Texto preto
                                    ),
                                    content: const Text(
                                      'Deseja realmente excluir esta notícia?',
                                      style: TextStyle(
                                          color: Colors.black), // Texto preto
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Excluir',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    if (!context.mounted) return;
                                    await _feedNoticiaController
                                        .deleteFeedNoticia(context, noticiaId);
                                    await _loadNoticiasFromBackend(); // Atualiza a lista de notícias

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Notícia removida com sucesso!'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Erro ao remover a notícia!'),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('ID da notícia é inválido.')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
