part of '../env.dart';

class CustomDropdownPremiacao extends StatelessWidget {
  final List<Premiacao> premiacoes;
  final int? selectedPremiacao;
  final ValueChanged<int?> onChanged;

  const CustomDropdownPremiacao({
    super.key,
    required this.premiacoes,
    required this.selectedPremiacao,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<int>(
        value: selectedPremiacao,
        decoration: InputDecoration(
          hintStyle: const TextStyle(color: Colors.grey),
          //hintText: 'Selecione uma Premiação*',
          labelText:
              '   Selecione uma Premiação*', // O hint agora funciona como label
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
        items: premiacoes.map((premiacao) {
          return DropdownMenuItem<int>(
            value: premiacao.id,
            child: Text(premiacao.nome),
          );
        }).toList(),
        onChanged: onChanged,
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
