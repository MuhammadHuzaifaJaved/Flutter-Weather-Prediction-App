import 'package:flutter/material.dart';

class WeatherAlertsScreen extends StatefulWidget {
  const WeatherAlertsScreen({Key? key}) : super(key: key);

  @override
  _WeatherAlertsScreenState createState() => _WeatherAlertsScreenState();
}

class _WeatherAlertsScreenState extends State<WeatherAlertsScreen> {
  bool rainAlerts = true;
  bool stormAlerts = true;
  bool extremeWeatherAlerts = true;
  double temperatureThreshold = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Alerts Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActiveAlert(
                    'Severe Thunderstorm Warning',
                    'Active until 6:00 PM',
                    Icons.flash_on,
                    Colors.red,
                  ),
                  _buildActiveAlert(
                    'Flash Flood Watch',
                    'Active until 8:00 PM',
                    Icons.water,
                    Colors.orange,
                  ),
                ],
              ),
            ),

            // Alert Settings Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alert Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAlertToggle(
                    'Rain Alerts',
                    'Get notified about rain forecasts',
                    rainAlerts,
                    (value) {
                      setState(() => rainAlerts = value);
                    },
                  ),
                  _buildAlertToggle(
                    'Storm Alerts',
                    'Get notified about storms',
                    stormAlerts,
                    (value) {
                      setState(() => stormAlerts = value);
                    },
                  ),
                  _buildAlertToggle(
                    'Extreme Weather Alerts',
                    'Get notified about extreme weather conditions',
                    extremeWeatherAlerts,
                    (value) {
                      setState(() => extremeWeatherAlerts = value);
                    },
                  ),
                ],
              ),
            ),

            // Custom Thresholds Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Thresholds',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Temperature Threshold'),
                      Expanded(
                        child: Slider(
                          value: temperatureThreshold,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          label: '${temperatureThreshold.round()}°C',
                          onChanged: (value) {
                            setState(() => temperatureThreshold = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement custom alert creation
          _showAddAlertDialog(context);
        },
        label: const Text('Add Custom Alert'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveAlert(
      String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            // Show alert details
          },
        ),
      ),
    );
  }

  Widget _buildAlertToggle(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showAddAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Alert Name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Alert Type',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'temperature',
                  child: Text('Temperature'),
                ),
                DropdownMenuItem(
                  value: 'precipitation',
                  child: Text('Precipitation'),
                ),
                DropdownMenuItem(
                  value: 'wind',
                  child: Text('Wind'),
                ),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement alert creation
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
} 