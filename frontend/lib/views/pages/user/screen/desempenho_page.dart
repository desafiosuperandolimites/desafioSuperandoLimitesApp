part of '../../../env.dart';

class DesempenhoPage extends StatefulWidget {
  const DesempenhoPage({super.key}); // Construtor atualizado

  @override
  DesempenhoPageState createState() => DesempenhoPageState();
}

class DesempenhoPageState extends State<DesempenhoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color semicircleColor = const Color(0xFFFF7801);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          _buildHeader(semicircleColor),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Gráfico de Desempenho Semanal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 20:
                                  return const Text('9 km');
                                case 40:
                                  return const Text('29 km');
                                case 60:
                                  return const Text('59 km');
                                case 80:
                                  return const Text('79 km');
                                case 100:
                                  return const Text('99 km');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            reservedSize: 70,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 1:
                                  return const Text('0');
                                case 2:
                                  return const Text('2');
                                case 3:
                                  return const Text('3');
                                case 4:
                                  return const Text('4');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: const [
                            FlSpot(1, 150),
                            FlSpot(2, 250),
                            FlSpot(3, 50),
                            FlSpot(4, 100),
                            FlSpot(5, 90),
                            FlSpot(6, 150),
                            FlSpot(7, 250),
                            FlSpot(8, 50),
                            FlSpot(9, 100),
                            FlSpot(10, 90),
                            FlSpot(11, 150),
                            FlSpot(12, 250),
                            FlSpot(13, 50),
                            FlSpot(14, 100),
                            FlSpot(15, 90),
                          ],
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFFF7801).withOpacity(0.3),
                          ),
                          color: const Color.fromARGB(255, 17, 17, 17)
                              .withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width / 2.5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(MediaQuery.of(context).size.width),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 110.h,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'SEU DESEMPENHO',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
