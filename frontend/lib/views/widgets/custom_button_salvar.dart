part of '../env.dart';

class CustomButtonSalvar extends StatelessWidget {
  final VoidCallback onSave;
  final Widget? child; // Parâmetro opcional

  const CustomButtonSalvar({super.key, required this.onSave, this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: child ??
          const Text(
            // Verifica se o `child` foi passado, senão usa o texto "Salvar"
            'Salvar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16, // Tamanho do texto padrão
            ),
          ),
    );
  }
}
