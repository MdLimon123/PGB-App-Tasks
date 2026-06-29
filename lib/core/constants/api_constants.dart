class ApiConstants {
  static const String baseUrl = 'https://todo.progressivebyte.com';
  
  // Auth
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String me = '/api/v1/me';
  
  // Locations
  static const String locations = '/api/v1/locations';
  
  // Todos
  static const String todos = '/api/v1/todos';
  static const String syncTodos = '/api/v1/todos/sync';
}
