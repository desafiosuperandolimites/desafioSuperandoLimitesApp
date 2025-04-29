part of '../../env.dart';

class CadastrarEventoPage extends StatefulWidget {
  final Evento? evento; // Evento selecionado
  final bool isEditing; // Indica se é edição

  const CadastrarEventoPage({super.key, this.evento, this.isEditing = false});

  @override
  CadastrarEventoPageState createState() => CadastrarEventoPageState();
}

class CadastrarEventoPageState extends State<CadastrarEventoPage> {
  final TextEditingController _inicioEventoController = TextEditingController();
  final TextEditingController _fimEventoController = TextEditingController();
  final TextEditingController _inicioInscricaoController =
      TextEditingController();
  final TextEditingController _fimInscricaoController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final EventoController _eventoController = EventoController();
  final GrupoController _grupoController = GrupoController();
  final PremiacaoController _premiacaoController = PremiacaoController();
  final FileController _fileController = FileController();
  final TextEditingController _taxaInscricaoController =
      Mascaras.taxaInscricaoController();
  final InscricaoController _inscricaoController = InscricaoController();

  List<Grupo> grupos = [];
  List<Premiacao> premiacao = [];
  int? _selectedPremiacao;
  int? _selectedGrupo;

  bool _caminhadaCorrida = false;
  bool _bicicleta = false;
  bool _eventoAtivo = true; // Define se o evento está ativo
  bool _eventoIsento = true;

  String? _nomeError;
  String? _descricaoError;
  String? _localError;

  File? _eventoImage; // Newly chosen image before upload
  // ignore: unused_field
  File? _downloadedEventoImage; // Downloaded image if editing existing event

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();

    if (widget.evento != null) {
      _populateFields(widget.evento!);
      _loadExistingEventoImage();
    }
  }

  Future<void> _loadDataFromBackend() async {
    // Carrega grupos e premiações do backend
    await _grupoController.fetchGrupos();
    await _premiacaoController.fetchPremiacaos();
    setState(() {
      grupos = _grupoController.groupList;
      premiacao = _premiacaoController.premiacaoList;
    });
  }

  Future<void> _loadExistingEventoImage() async {
    if (widget.evento != null &&
        widget.evento!.capaEvento != null &&
        widget.evento!.capaEvento!.isNotEmpty) {
      try {
        await _fileController
            .downloadFileCapasEvento(widget.evento!.capaEvento!);
        setState(() {
          _downloadedEventoImage = _fileController.downloadedFile;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao baixar imagem do evento: $e');
        }
      }
    }
  }

  void _populateFields(Evento evento) {
    _nomeController.text = evento.nome;
    _descricaoController.text = evento.descricao;
    _localController.text = evento.local;

    _inicioEventoController.text = _formatDateString(evento.dataInicioEvento);
    _fimEventoController.text = _formatDateString(evento.dataFimEvento);
    _inicioInscricaoController.text =
        _formatDateString(evento.dataInicioInscricoes);
    _fimInscricaoController.text = _formatDateString(evento.dataFimInscricoes);

    _selectedPremiacao = evento.idPremiacaoEvento;
    _selectedGrupo = evento.idGrupoEvento;

    _caminhadaCorrida =
        evento.idModalidadeEvento == 2 || evento.idModalidadeEvento == 3;
    _bicicleta =
        evento.idModalidadeEvento == 1 || evento.idModalidadeEvento == 3;
    _eventoAtivo = evento.situacao;
    _eventoIsento = evento.isentoPagamento;
    // Defina valorEvento corretamente, assumindo que este campo existe em Evento
    double valorEvento = evento.valorEvento;
    // Atribua o valor no controlador, se necessário
    _taxaInscricaoController.text = valorEvento.toString();
  }

  @override
  void dispose() {
    _inicioEventoController.dispose();
    _fimEventoController.dispose();
    _inicioInscricaoController.dispose();
    _fimInscricaoController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _taxaInscricaoController.dispose();
    super.dispose();
  }

  Future<void> _pickEventoImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      } else {
        await Permission.photos.request();
      }
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _eventoImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
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
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            child: const Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.black,
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
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: const Row(
              children: [
                Icon(
                  Icons.photo,
                  color: Colors.black,
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
      await _pickEventoImage(action);
    }
  }

  Future<void> _saveEvent() async {
    if (!_validateForm()) {
      return;
    }

    try {
      int idModalidadeEvento = _getModalidadeId();
      if (idModalidadeEvento == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecione ao menos uma modalidade.')),
        );
        return;
      }

      DateTime dataInicioEvento = _parseDate(_inicioEventoController.text)!;
      DateTime dataFimEvento = _parseDate(_fimEventoController.text)!;
      DateTime dataInicioInscricoes =
          _parseDate(_inicioInscricaoController.text)!;
      DateTime dataFimInscricoes = _parseDate(_fimInscricaoController.text)!;

      final UserController userController = UserController();
      await userController.fetchCurrentUser();
      final user = userController.user;
      final userId = user?.id;

      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado.')),
        );
        return;
      }

      double valorEvento =
          double.tryParse(_taxaInscricaoController.text) ?? 0.0;

      // Upload image if a new one was chosen
      String? uploadedFileName;
      if (_eventoImage != null) {
        try {
          await _fileController.uploadFileCapasEvento(_eventoImage);
          uploadedFileName = _eventoImage!.path.split('/').last;
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao enviar imagem: $e')),
          );
          return;
        }
      } else {
        // Keep existing image if editing and none chosen
        uploadedFileName = widget.evento?.capaEvento;
      }

      Evento newEvento = Evento(
        id: widget.isEditing ? widget.evento?.id : null,
        idModalidadeEvento: idModalidadeEvento,
        idGrupoEvento: _selectedGrupo!,
        idPremiacaoEvento: _selectedPremiacao!,
        idUsuario: userId,
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        local: _localController.text,
        capaEvento: uploadedFileName,
        dataInicioEvento: dataInicioEvento.toIso8601String(),
        dataFimEvento: dataFimEvento.toIso8601String(),
        dataInicioInscricoes: dataInicioInscricoes.toIso8601String(),
        dataFimInscricoes: dataFimInscricoes.toIso8601String(),
        situacao: _eventoAtivo,
        isentoPagamento: _eventoIsento,
        valorEvento: valorEvento,
      );

      if (!mounted) return;

      final overlay = SalvandoSnackBar.show(context);

      if (widget.isEditing && newEvento.id != null) {
        await _eventoController.updateEvento(context, newEvento.id!, newEvento);
      } else if (!widget.isEditing) {
        await _eventoController.createEvento(context, newEvento);
      } else {
        overlay.remove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro: Evento sem ID válido para edição.')),
        );
        return;
      }

      overlay.remove();
      if (!mounted) return;
      SalvoSucessoSnackBar.show(context);

      Navigator.pushReplacementNamed(context, '/gestao-evento');
    } catch (e) {
      if (kDebugMode) {
        print('Error saving event: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving event: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {DateTime? firstDate, DateTime? lastDate}) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    DateTime pickerFirstDate = firstDate ?? today;
    DateTime pickerLastDate = lastDate ?? DateTime(2101);

    if (pickerLastDate.isBefore(pickerFirstDate)) {
      pickerLastDate = pickerFirstDate.add(const Duration(days: 1));
    }

    DateTime? existingDate = _parseDate(controller.text);
    DateTime initialDate = existingDate ?? pickerFirstDate;

    if (initialDate.isBefore(pickerFirstDate)) {
      initialDate = pickerFirstDate;
    } else if (initialDate.isAfter(pickerLastDate)) {
      initialDate = pickerLastDate;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: pickerFirstDate,
      lastDate: pickerLastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7801),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.text =
          '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
      setState(() {});
    }
  }

  Future<bool> _updateEventStatus() async {
    try {
      // Só deve impedir se o usuário estiver tentando inativar (value == false)
      // e se o evento tiver inscrições.
      if (_eventoAtivo == false &&
          widget.evento != null &&
          widget.evento!.id != null) {
        // Consulta a lista de inscrições do evento
        await _inscricaoController.getInscricaoByEvent(
            eventId: widget.evento!.id!);

        // Verifica se existe alguma inscrição
        if (_inscricaoController.inscricaoList.isNotEmpty) {
          // Bloqueia ação e exibe mensagem
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Não é possível inativar: este evento possui inscritos.'),
              ),
            );
          }
          return false;
        }
      }

      // Se chegou até aqui, significa que pode inativar (ou ativar) normalmente
      if (widget.evento?.id != null) {
        await _eventoController.toggleEventoStatus(widget.evento!.id!);
        return true;
      } else {
        throw Exception('Evento inválido para atualização de status.');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar status do evento: $e');
      return false;
    }
  }

  Widget _buildSaveButton(
      double screenWidth, double screenHeight, double ratio, bool isEditing) {
    return SizedBox(
      height: screenHeight * 0.045,
      child: Center(
        child: ElevatedButton(
          onPressed: _saveEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding:
                EdgeInsets.symmetric(horizontal: screenWidth * 0.04 * ratio),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4 * ratio),
            ),
            fixedSize: Size(ratio * 150, 10 * ratio),
          ),
          child: Text(
            isEditing ? 'Salvar' : 'Publicar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15 * ratio,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(double ratio) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Voltar',
            style: TextStyle(
              fontSize: 16 * ratio,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(
      double screenWidth, double screenHeight, double ratio) {
    String buttonText;
    if (_eventoImage != null) {
      buttonText = 'Foto selecionada: ${_eventoImage!.path.split('/').last}';
    } else {
      buttonText = 'Selecionar Imagem';
    }
    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.045,
          child: ElevatedButton(
            onPressed: _showImageSourceDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade200,
              padding:
                  EdgeInsets.symmetric(horizontal: screenWidth * 0.04 * ratio),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4 * ratio),
              ),
              fixedSize: Size(ratio * 200, 600 * ratio),
            ),
            child: Text(
              buttonText,
              style: TextStyle(color: Colors.white, fontSize: 15 * ratio),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    //double scaleFactor = screenWidth / 430;

    final bool isSmallScreen = screenWidth <= 400;
    final bool isMidScreen = screenWidth > 400 && screenWidth < 600;
    final bool isBigScreen = screenWidth > 600 && screenWidth < 850;
    final bool isPixelScreen = screenWidth > 850;

    // Ajustar fatores de escala conforme o tamanho
    double ratio = 0;
    if (isSmallScreen) {
      //small
      ratio = 0.9;
    } else if (isMidScreen) {
      //rexible
      ratio = 1.1;
    } else if (isBigScreen) {
      //tablet
      ratio = 1.4;
    } else if (isPixelScreen) {
      //pixel fold
      ratio = 1.2;
    }

    //_loadDataFromBackend();

    bool isEditing = widget.isEditing;

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
                isEditing ? 'Meu Evento' : 'Cadastrar Evento',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * (isEditing ? 0.125 : 0.14),
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isEditing)
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: _eventoAtivo,
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.grey,
                            onChanged: (bool value) async {
                              bool previousStatus = _eventoAtivo;
                              setState(() {
                                _eventoAtivo = value; // Tenta mudar
                              });

                              bool success = await _updateEventStatus();

                              if (success) {
                                // Mostra mensagem de sucesso
                                String message = _eventoAtivo
                                    ? 'Evento ativado com sucesso'
                                    : 'Evento inativado com sucesso';

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              } else {
                                // Reverte o estado do switch
                                setState(() {
                                  _eventoAtivo = previousStatus;
                                });

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Erro ao atualizar o status do evento.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        Text(
                          _eventoAtivo ? 'Ativo' : 'Inativo',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: _eventoIsento,
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.grey,
                          onChanged: (bool value) async {
                            // Se não for edição, não precisa checar nada
                            if (!widget.isEditing) {
                              setState(() {
                                _eventoIsento = value;
                              });
                              return;
                            }

                            // Só faz sentido checar se há um evento com ID
                            if (widget.evento == null ||
                                widget.evento!.id == null) {
                              setState(() {
                                _eventoIsento = value;
                              });
                              return;
                            }

                            // Se o usuário NÃO estiver alterando nada, nem precisa checar
                            if (value == _eventoIsento) return;

                            // Guarda o valor anterior
                            bool previousValue = _eventoIsento;

                            // Tenta mudar
                            setState(() {
                              _eventoIsento = value;
                            });

                            // Verifica se há inscrições
                            await _inscricaoController.getInscricaoByEvent(
                              eventId: widget.evento!.id!,
                            );

                            if (_inscricaoController.inscricaoList.isNotEmpty) {
                              // Se há inscritos, bloqueia a mudança e reverte
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Não é possível alterar o evento de isento para pago (ou vice-versa) pois já existem inscrições.'),
                                  ),
                                );
                              }

                              setState(() {
                                // Reverte o valor do switch
                                _eventoIsento = previousValue;
                              });
                            } else {
                              // Caso não tenha inscritos, a mudança persiste
                              // (Opcional) Você pode salvar imediatamente no backend
                              // ou esperar pelo _saveEvent() depois.
                            }
                          },
                        ),
                      ),
                      Text(
                        _eventoIsento ? 'Isento' : 'Pago',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: isEditing ? screenHeight * 0.16 : screenHeight * 0.18,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: ListView(
                children: [
                  const SizedBox(height: 5),
                  _buildTextTitulo(
                    'Título do Evento*',
                    _nomeController,
                    screenWidth,
                    ratio: ratio,
                    maxLength: 18,
                    onChanged: (value) {
                      setState(() {
                        if (value.length > 17) {
                          _nomeError =
                              'O nome não pode ter mais de 18 caracteres.';
                        } else {
                          _nomeError = null;
                        }
                      });
                    },
                  ),
                  if (_nomeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _nomeError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  //const SizedBox(height: 15),
                  _buildTextDescricao(
                    'Descrição Evento*', _descricaoController, screenWidth,
                    maxLines: 4, ratio: ratio,
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
                  //const SizedBox(height: 15),
                  _buildTextLocal(
                    'Local*', _localController, screenWidth,
                    ratio: ratio,
                    maxLength: 22, // Limite de caracteres
                    onChanged: (value) {
                      setState(() {
                        if (value.length > 21) {
                          _localError =
                              'O Local não pode ter mais de 12 caracteres.';
                        } else {
                          _localError = null; // Reseta a mensagem de erro
                        }
                      });
                    },
                  ),
                  if (_localError != null) // Verifica se há erro
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _localError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  //const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdownPremiacao(
                          premiacoes: premiacao,
                          selectedPremiacao: _selectedPremiacao,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedPremiacao = newValue;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: screenHeight * 0.055,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
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
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdownGrupo(
                          grupos: grupos,
                          selectedGrupo: _selectedGrupo,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGrupo = newValue;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: screenHeight * 0.055,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/cadastrar-grupo');
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
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Campo para "Taxa de Inscrição" visível somente se o evento não for isento
                  if (!_eventoIsento)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _taxaInscricaoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Taxa de Inscrição R\$: 1.00-99.99',
                                labelStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: screenWidth * 0.03 * ratio),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 15),
                  _buildCheckboxOptions(screenWidth, ratio),
                  const SizedBox(height: 15),
                  _buildDatePickers(screenWidth, ratio),
                  const SizedBox(height: 15),
                  _buildInscricaoDatePickers(screenWidth, ratio),
                  const SizedBox(height: 15),
                  _buildImageButton(screenWidth, screenHeight, ratio),
                  const SizedBox(height: 0),
                  Text(
                    'Tam: 170px X 63px',
                    style: TextStyle(color: Colors.grey, fontSize: 11 * ratio),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  _buildSaveButton(screenWidth, screenHeight, ratio, isEditing),
                  const SizedBox(height: 15),
                  _buildBackButton(ratio),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
    );
  }

  Widget _buildTextTitulo(
      String label, TextEditingController controller, double screenWidth,
      {int maxLines = 1,
      required double ratio,
      int? maxLength,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13 * ratio),
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

  Widget _buildTextLocal(
      String label, TextEditingController controller, double screenWidth,
      {int maxLines = 1,
      required double ratio,
      int? maxLength,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13 * ratio),
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

  Widget _buildTextDescricao(
      String label, TextEditingController controller, double screenWidth,
      {int maxLines = 1,
      required double ratio,
      int? maxLength,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13 * ratio),
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

  Widget _buildCheckboxOptions(double screenWidth, double ratio) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02 * ratio),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8 * ratio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modalidade*',
            style: TextStyle(fontSize: 13 * ratio, color: Colors.grey[500]),
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8 * ratio),
                child: Checkbox(
                  value: _caminhadaCorrida,
                  activeColor: Colors.green,
                  onChanged: (bool? value) {
                    setState(() {
                      _caminhadaCorrida = value ?? false;
                    });
                  },
                ),
              ),
              Text('Caminhada/Corrida',
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 13 * ratio)),
              SizedBox(width: screenWidth * 0.0 * ratio),
              ClipRRect(
                borderRadius: BorderRadius.circular(8 * ratio),
                child: Checkbox(
                  value: _bicicleta,
                  activeColor: Colors.green,
                  onChanged: (bool? value) {
                    setState(() {
                      _bicicleta = value ?? false;
                    });
                  },
                ),
              ),
              Text('Ciclismo',
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 13 * ratio)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickers(double screenWidth, double ratio) {
    DateTime today = DateTime.now();
    DateTime? fimEventoDate = _parseDate(_fimEventoController.text);

    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            'Data de Início*',
            _inicioEventoController,
            screenWidth,
            ratio,
            firstDate: today,
            lastDate: fimEventoDate ??
                today.add(const Duration(days: 1825)), // 5 years from now
          ),
        ),
        SizedBox(width: screenWidth * 0.02 * ratio),
        Expanded(
          child: _buildDatePicker(
            'Data de Término*',
            _fimEventoController,
            screenWidth,
            ratio,
            firstDate: _parseDate(_inicioEventoController.text) ?? today,
            lastDate: today.add(const Duration(days: 1825)), // 5 years from now
          ),
        ),
      ],
    );
  }

  Widget _buildInscricaoDatePickers(double screenWidth, double ratio) {
    DateTime today = DateTime.now();
    DateTime? fimInscricaoDate = _parseDate(_fimInscricaoController.text);

    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            'Inscrição Início*',
            _inicioInscricaoController,
            screenWidth,
            ratio,
            firstDate: today,
            lastDate: fimInscricaoDate ?? today.add(const Duration(days: 1825)),
          ),
        ),
        SizedBox(width: screenWidth * 0.02 * ratio),
        Expanded(
          child: _buildDatePicker(
            'Inscrição Término*',
            _fimInscricaoController,
            screenWidth,
            ratio,
            firstDate: _parseDate(_inicioInscricaoController.text) ?? today,
            lastDate: today.add(const Duration(days: 1825)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller,
      double screenWidth, double ratio,
      {DateTime? firstDate, DateTime? lastDate}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13 * ratio),
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
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        await _selectDate(
          context,
          controller,
          firstDate: firstDate,
          lastDate: lastDate,
        );
      },
    );
  }

  bool _validateForm() {
    if (_nomeController.text.isEmpty ||
        _descricaoController.text.isEmpty ||
        _localController.text.isEmpty ||
        _selectedGrupo == null ||
        _selectedPremiacao == null ||
        (!_caminhadaCorrida && !_bicicleta) ||
        _inicioEventoController.text.isEmpty ||
        _fimEventoController.text.isEmpty ||
        _inicioInscricaoController.text.isEmpty ||
        _fimInscricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return false;
    }

    DateTime? dataInicioEvento = _parseDate(_inicioEventoController.text);
    DateTime? dataFimEvento = _parseDate(_fimEventoController.text);
    DateTime? dataInicioInscricoes =
        _parseDate(_inicioInscricaoController.text);
    DateTime? dataFimInscricoes = _parseDate(_fimInscricaoController.text);
    DateTime today = DateTime.now();
    DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    if (dataInicioEvento != null) {
      if (dataInicioEvento.isBefore(todayDateOnly)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('A data de início não pode ser uma data passada.')),
        );
        return false;
      }
    }

    if (dataInicioEvento != null && dataFimEvento != null) {
      if (dataFimEvento.isBefore(dataInicioEvento)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'A data de término do evento deve ser posterior ou igual à data de início.')),
        );
        return false;
      }
    }

    if (!_eventoIsento) {
      if (_taxaInscricaoController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'O Evento não sendo isento deve conter o valor da Taxa de Inscrição')),
        );
        return false;
      }
      double taxa = double.tryParse(_taxaInscricaoController.text) ?? 0.0;
      if (taxa <= 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'O valor da taxa de inscrição deve ser maior que 0 R\$')),
        );
        return false;
      }
    }

    if (dataInicioInscricoes != null && dataFimInscricoes != null) {
      if (dataFimInscricoes.isBefore(dataInicioInscricoes)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'A data de término da inscrição deve ser posterior à data de início da inscrição.')),
        );
        return false;
      }
    }

    return true;
  }

  String _formatDateString(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return '';
    }
  }

  int _getModalidadeId() {
    if (_caminhadaCorrida && !_bicicleta) {
      return 2; // Caminhada/Corrida
    } else if (_bicicleta && !_caminhadaCorrida) {
      return 1; // Bicicleta
    } else if (_caminhadaCorrida && _bicicleta) {
      return 3; // Both
    } else {
      return 0;
    }
  }

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Handle parsing error
    }
    return null;
  }
}
