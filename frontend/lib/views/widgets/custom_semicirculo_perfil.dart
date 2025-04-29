part of '../env.dart';

class CustomSemicirculoPerfil extends StatelessWidget {
  final double height;
  final Color color;

  const CustomSemicirculoPerfil({
    super.key,
    this.height = 100.0, // Ajuste o valor conforme necessário
    this.color = Colors.white, // Cor padrão
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(height),
          ),
        ),
      ),
    );
  }
}
