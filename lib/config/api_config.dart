class ApiConfig {
  // TODO: Replace with your OpenWeatherMap API key
  // 1. Go to https://openweathermap.org/
  // 2. Sign up for a free account
  // 3. Go to your account -> My API keys
  // 4. Copy your API key
  // 5. Replace the placeholder below with your actual API key
  static const String weatherMapApiKey = 'c027b1fa9c29b36b549016be428fd6df';
  
  // OpenWeatherMap API endpoints
  static const String weatherMapBaseUrl = 'https://tile.openweathermap.org/map';
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Available map layers
  static const List<String> mapLayers = [
    'clouds_new',
    'precipitation_new',
    'pressure_new',
    'wind_new',
    'temp_new',
  ];
} 