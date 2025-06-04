import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/weatherProvider.dart';
import '../models/dailyWeather.dart';
import '../models/hourlyWeather.dart';

class WeatherStatisticsScreen extends StatefulWidget {
  const WeatherStatisticsScreen({Key? key}) : super(key: key);

  @override
  _WeatherStatisticsScreenState createState() => _WeatherStatisticsScreenState();
}

class _WeatherStatisticsScreenState extends State<WeatherStatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DailyWeather> weeklyForecast = [];
  List<HourlyWeather> hourlyForecast = [];
  String selectedMetric = 'Temperature';
  bool showAverage = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWeatherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    setState(() {
      weeklyForecast = weatherProvider.dailyWeather;
      hourlyForecast = weatherProvider.hourlyWeather;
    });
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildTemperatureChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < weeklyForecast.length) {
                        return Text(
                          weeklyForecast[value.toInt()].date.day.toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: weeklyForecast.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.temp);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
                if (showAverage)
                  LineChartBarData(
                    spots: List.generate(weeklyForecast.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        _calculateAverage(weeklyForecast.map((e) => e.temp).toList()),
                      );
                    }),
                    isCurved: false,
                    color: Colors.red.withOpacity(0.5),
                    barWidth: 2,
                    dashArray: [5, 5],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHumidityChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < weeklyForecast.length) {
                        return Text(
                          weeklyForecast[value.toInt()].date.day.toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: weeklyForecast.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.humidity.toDouble(),
                      color: Colors.blue,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWindSpeedChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < weeklyForecast.length) {
                        return Text(
                          weeklyForecast[value.toInt()].date.day.toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: weeklyForecast.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.windSpeed);
                  }).toList(),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPressureChart() {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final currentPressure = weatherProvider.weather.pressure.toDouble();
    
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < weeklyForecast.length) {
                        return Text(
                          weeklyForecast[value.toInt()].date.day.toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: [FlSpot(0, currentPressure)],
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avgTemp = _calculateAverage(weeklyForecast.map((e) => e.temp).toList());
    final avgHumidity = _calculateAverage(weeklyForecast.map((e) => e.humidity.toDouble()).toList());
    final avgWindSpeed = _calculateAverage(weeklyForecast.map((e) => e.windSpeed).toList());
    final currentPressure = Provider.of<WeatherProvider>(context, listen: false).weather.pressure.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Statistics'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(showAverage ? Icons.show_chart : Icons.visibility_off),
            onPressed: () => setState(() => showAverage = !showAverage),
            tooltip: 'Toggle Average Line',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Temperature'),
            Tab(text: 'Humidity'),
            Tab(text: 'Wind Speed'),
            Tab(text: 'Pressure'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Statistics Cards in a horizontal scrollable row
            Container(
              height: 140,
              margin: EdgeInsets.only(top: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SizedBox(
                    width: 160,
                    child: _buildStatisticsCard(
                      'Avg Temp',
                      avgTemp.toStringAsFixed(1),
                      '°C',
                      Icons.thermostat,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: _buildStatisticsCard(
                      'Avg Humidity',
                      avgHumidity.toStringAsFixed(0),
                      '%',
                      Icons.water_drop,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: _buildStatisticsCard(
                      'Avg Wind',
                      avgWindSpeed.toStringAsFixed(1),
                      'km/h',
                      Icons.air,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: _buildStatisticsCard(
                      'Pressure',
                      currentPressure.toStringAsFixed(0),
                      'hPa',
                      Icons.speed,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            // Charts in tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: _buildTemperatureChart(),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: _buildHumidityChart(),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: _buildWindSpeedChart(),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: _buildPressureChart(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 