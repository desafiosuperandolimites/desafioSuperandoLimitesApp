part of '../env.dart';

class CustomDropdownButtonAno extends StatefulWidget {
  final String? value;
  final List<String> items;
  final Function(String?)? onChanged;
  final String hint;
  final double? width; // Permite personalizar a largura
  final bool isEnabled; // Novo parâmetro para habilitar/desabilitar o dropdown
  final InputDecoration? inputDecoration;

  const CustomDropdownButtonAno({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    this.inputDecoration,
    this.width,
    this.isEnabled = true, // Define o padrão como habilitado
  });

  @override
  CustomDropdownButtonAnoState createState() => CustomDropdownButtonAnoState();
}

class CustomDropdownButtonAnoState extends State<CustomDropdownButtonAno> {
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true, // Alinha o dropdown
      child: SizedBox(
        width: widget.width ?? double.infinity,
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: widget.value,
            items: widget.items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.width ?? double.infinity,
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.isEnabled
                ? widget.onChanged
                : null, // Desabilita o dropdown
            decoration: widget.inputDecoration ??
                InputDecoration(
                  labelText: widget.hint
                      .replaceAll('*', ''), // O hint agora funciona como label
                  hintStyle: const TextStyle(color: Colors.grey),
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16, // Ajusta a altura interna
                    horizontal: -4, // Garante alinhamento horizontal
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 1),
                  ),
                ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.filter_alt_outlined), // Ícone do dropdown
            style: const TextStyle(
              fontSize: 16, // Padroniza estilo do texto
              color: Colors.black,
            ),
            isDense: true, // Remove excesso de espaçamento vertical
            menuMaxHeight: 200, // Define altura máxima para o menu
          ),
        ),
      ),
    );
  }
}
