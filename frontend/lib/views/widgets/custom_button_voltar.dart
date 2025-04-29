part of '../env.dart';

class CustomButtonVoltar extends StatelessWidget {
  final VoidCallback? onPressed; // Callback opcional

  const CustomButtonVoltar({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // Espaçamento de 20px
      child: Align(
        alignment: Alignment.bottomCenter, // Alinhado ao centro inferior
        child: SizedBox(
          width: 150, // Largura fixa ou pode ser ajustada conforme necessário
          child: TextButton(
            onPressed: onPressed ??
                () =>
                    Navigator.pop(context, true), // Volta para a tela anterior
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.transparent,
            ),
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
      ),
    );
  }
}
