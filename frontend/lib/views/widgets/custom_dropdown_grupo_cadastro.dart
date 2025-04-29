part of '../env.dart';

class CustomDropdownGrupoCadastro extends StatelessWidget {
  final List<Grupo> grupos;
  final int? selectedGrupo;
  final ValueChanged<int?>? onChanged;
  final bool enabled;

  const CustomDropdownGrupoCadastro({
    super.key,
    required this.grupos,
    required this.selectedGrupo,
    required this.onChanged,
    this.enabled =
        true, // Adiciona um valor padrão para a propriedade 'enabled'
  });

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<int>(
        //icon: const Icon(null), // Remove o ícone de seta para baixoss
        isExpanded: true,
        value: selectedGrupo,
        decoration: InputDecoration(
          hintStyle: const TextStyle(color: ui.Color.fromARGB(255, 59, 59, 59)),
          hintText: '   Selecione um Grupo*',
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
            child: Text(grupo.nome),
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
    );
  }
}
