import 'package:flutter/material.dart';
import 'package:ikpm_sidoarjo/admin/layouts/sidebar.dart';
import 'package:ikpm_sidoarjo/controllers/admin/dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart'; // Import Chart Library

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  late Future<Map<String, int>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = DashboardController().getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              FutureBuilder<Map<String, int>>(
                future: _dashboardData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 4;
                            if (constraints.maxWidth < 600) {
                              crossAxisCount = 2;
                            }
                            if (constraints.maxWidth < 400) {
                              crossAxisCount = 1;
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 20.0,
                                mainAxisSpacing: 20.0,
                                childAspectRatio: 1.7,
                              ),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                switch (index) {
                                  case 0:
                                    return CardWidget(
                                      icon: Icons.person,
                                      count: data['alumni']!,
                                      label: 'Jumlah Alumni',
                                      color: Colors.orange,
                                    );
                                  case 1:
                                    return CardWidget(
                                      icon: Icons.timer,
                                      count: data['kegiatan']!,
                                      label: 'Jumlah Kegiatan',
                                      color: Colors.blue,
                                    );
                                  case 2:
                                    return CardWidget(
                                      icon: Icons.book,
                                      count: data['informasi']!,
                                      label: 'Jumlah Informasi',
                                      color: Colors.teal,
                                    );
                                  case 3:
                                    return CardWidget(
                                      icon: Icons.comment,
                                      count: data['kritik']!,
                                      label: 'Jumlah Kritik dan Saran',
                                      color: Colors.pink,
                                    );
                                  default:
                                    return Container();
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 10),

                        // **Bagian Chart**
                        Text(
                          "Visualisasi Data",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: _buildBarChart(data),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No Data Available'));
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: data['alumni']!.toDouble(), color: Colors.orange)],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: data['kegiatan']!.toDouble(), color: Colors.blue)],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: data['informasi']!.toDouble(), color: Colors.teal)],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: data['kritik']!.toDouble(), color: Colors.pink)],
            showingTooltipIndicators: [0],
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Alumni', style: TextStyle(fontSize: 12));
                  case 1:
                    return const Text('Kegiatan', style: TextStyle(fontSize: 12));
                  case 2:
                    return const Text('Informasi', style: TextStyle(fontSize: 12));
                  case 3:
                    return const Text('Kritik', style: TextStyle(fontSize: 12));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final IconData icon;
  final dynamic count;
  final String label;
  final Color color;

  const CardWidget({
    Key? key,
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}