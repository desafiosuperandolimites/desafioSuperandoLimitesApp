part of '../env.dart';

class CustomButtonCadastrar extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButtonCadastrar({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      child: const Text(
        'CADASTRAR',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}