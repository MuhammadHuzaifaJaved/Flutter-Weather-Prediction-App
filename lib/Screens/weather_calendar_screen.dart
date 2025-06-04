import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class WeatherCalendarScreen extends StatefulWidget {
  const WeatherCalendarScreen({Key? key}) : super(key: key);

  @override
  _WeatherCalendarScreenState createState() => _WeatherCalendarScreenState();
}

class _WeatherCalendarScreenState extends State<WeatherCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Calendar'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(),
          _buildDayDetails(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2024, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildDayDetails() {
    if (_selectedDay == null) return const SizedBox();

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather for ${_selectedDay?.toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHourlyForecast(),
            const SizedBox(height: 16),
            _buildWeatherDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return _buildHourlyItem(index);
        },
      ),
    );
  }

  Widget _buildHourlyItem(int hour) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${hour}:00',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.wb_sunny, color: Colors.orange),
          const SizedBox(height: 4),
          const Text(
            '22°C',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Temperature', '22°C (18°C - 25°C)'),
        _buildDetailRow('Humidity', '65%'),
        _buildDetailRow('Wind Speed', '10 km/h'),
        _buildDetailRow('Precipitation', '20%'),
        _buildDetailRow('UV Index', 'Moderate'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 