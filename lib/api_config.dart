class ApiConfig {
  const ApiConfig._();

  // Railway domain default (آپ بعد میں VPS domain رکھ دیں)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://premiumchatbackend-production.up.railway.app',
  );
}