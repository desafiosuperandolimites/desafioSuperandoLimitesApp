part of '../env.dart';

class CustomButtonCompartilhar extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButtonCompartilhar({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Ligeiramente arredondado
        ),
      ),
      icon: const Icon(
        Icons.share, // Ícone de compartilhar
        color: Colors.white,
      ),
      label: const Text(
        'Compartilhar',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
