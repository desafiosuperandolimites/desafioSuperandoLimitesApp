part of '../env.dart';

class CustomDropdownGrupo extends StatelessWidget {
  final List<Grupo> grupos;
  final int? selectedGrupo;
  final ValueChanged<int?>? onChanged;
  final bool enabled;

  const CustomDropdownGrupo({
    super.key,
    required this.grupos,
    required this.selectedGrupo,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true, // Garante alinhamento do dropdown com o campo
        child: DropdownButtonFormField<int>(
          value: selectedGrupo,
          decoration: InputDecoration(
            labelText: '   Selecione um Grupo*',
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16, // Ajusta a altura interna
              horizontal: -4, // Garante alinhamento horizontal
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
            ),
          ),
          items: grupos.map((grupo) {
            return DropdownMenuItem<int>(
              value: grupo.id,
              child: Align(
                alignment: Alignment.centerLeft, // Alinha o texto no item
                child: Text(
                  grupo.nome,
                  style: const TextStyle(
                    fontSize:
                        16, // Define tamanho fixo para evitar desalinhamento
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
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
    );
  }
}
