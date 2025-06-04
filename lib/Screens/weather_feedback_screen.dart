import 'package:flutter/material.dart';

class WeatherFeedbackScreen extends StatefulWidget {
  const WeatherFeedbackScreen({Key? key}) : super(key: key);

  @override
  _WeatherFeedbackScreenState createState() => _WeatherFeedbackScreenState();
}

class _WeatherFeedbackScreenState extends State<WeatherFeedbackScreen> {
  double _accuracyRating = 3;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isCurrentlyRaining = false;
  bool _isCurrentlyCloudy = false;
  bool _isCurrentlySunny = false;
  bool _isCurrentlyWindy = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Feedback'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeather(),
            const SizedBox(height: 24),
            _buildAccuracyRating(),
            const SizedBox(height: 24),
            _buildCurrentConditions(),
            const SizedBox(height: 24),
            _buildFeedbackInput(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Weather Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '25°C',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sunny',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.wb_sunny,
                  size: 48,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How accurate was our forecast?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _accuracyRating,
          min: 1,
          max: 5,
          divisions: 4,
          label: _accuracyRating.round().toString(),
          onChanged: (value) {
            setState(() {
              _accuracyRating = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Not Accurate',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Very Accurate',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Weather Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _buildConditionChip('Raining', _isCurrentlyRaining, (value) {
              setState(() {
                _isCurrentlyRaining = value;
              });
            }),
            _buildConditionChip('Cloudy', _isCurrentlyCloudy, (value) {
              setState(() {
                _isCurrentlyCloudy = value;
              });
            }),
            _buildConditionChip('Sunny', _isCurrentlySunny, (value) {
              setState(() {
                _isCurrentlySunny = value;
              });
            }),
            _buildConditionChip('Windy', _isCurrentlyWindy, (value) {
              setState(() {
                _isCurrentlyWindy = value;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionChip(
    String label,
    bool isSelected,
    ValueChanged<bool> onSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
    );
  }

  Widget _buildFeedbackInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us more about the weather conditions...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitFeedback,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Submit Feedback'),
      ),
    );
  }

  void _submitFeedback() {
    // Handle feedback submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
      ),
    );
  }
} 