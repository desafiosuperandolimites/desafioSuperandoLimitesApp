part of '../../../../env.dart';

InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    border: _outlineInputBorder(),
    enabledBorder: _outlineInputBorder(),
    focusedBorder: _outlineInputBorder(),
    suffixIcon: suffixIcon,
  );
}

OutlineInputBorder _outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
  );
}

Widget _buildAnimatedStatCard(double finalValue, String label, IconData icon,
    double textScaleFactor, double buttonScaleFactor,
    {bool isDouble = false}) {
  // Unchanged logic
  return Container(
    width: 85 * buttonScaleFactor,
    height: 85 * buttonScaleFactor,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: Colors.white, size: 25 * textScaleFactor),
        SizedBox(height: 11 * textScaleFactor),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: finalValue),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) {
            return Text(
              isDouble ? value.toStringAsFixed(1) : value.toInt().toString(),
              style: TextStyle(
                fontSize: 16 * textScaleFactor,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        SizedBox(height: 11 * textScaleFactor),
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * textScaleFactor,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

bool isEventoFinalizado(String dataFimInscricoes) {
  DateTime dataFim = DateTime.parse(dataFimInscricoes);
  DateTime dataAtual = DateTime.now();
  return dataFim.difference(dataAtual).inDays < 0;
}

Widget _buildInstataneoMensal(double textScaleFactor, double buttonScaleFactor,
    totalKmPercorrido, totalEventosInscritos, totalMedalhas) {
  // Unchanged logic
  return Container(
    margin: const EdgeInsets.all(12.0),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: const Color(0xFFFF7801),
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seu Instantâneo Anual',
          style: TextStyle(
            fontSize: 18 * textScaleFactor,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnimatedStatCard(
              totalKmPercorrido,
              'Km',
              Icons.leaderboard,
              textScaleFactor,
              buttonScaleFactor,
              isDouble: true,
            ),
            _buildAnimatedStatCard(
              totalEventosInscritos.toDouble(),
              'Desafios',
              Icons.event_available,
              textScaleFactor,
              buttonScaleFactor,
            ),
            _buildAnimatedStatCard(
              totalMedalhas.toDouble(),
              'Medalhas',
              Icons.workspace_premium,
              textScaleFactor,
              buttonScaleFactor,
            ),
          ],
        ),
      ],
    ),
  );
}
