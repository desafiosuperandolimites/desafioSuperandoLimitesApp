part of '../env.dart';

class CustomSemicirculo extends StatelessWidget {
  final double height;
  final Color color;

  const CustomSemicirculo({
    super.key,
    this.height = 100.0, // Ajuste o valor conforme necessário
    this.color = Colors.white, // Cor padrão
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(height), // Semicirculo
        ),
      ),
    );
  }
}
