class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  ApiResponse({
    required this.data,
    required this.success,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      success: json['success'] ?? true,
      message: json['message'],
    );
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: json['user'] ?? {},
    );
  }
}

class UserResponse {
  final String id;
  final String email;
  final String fullName;
  final String? createdAt;

  UserResponse({
    required this.id,
    required this.email,
    required this.fullName,
    this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      createdAt: json['created_at'],
    );
  }
}
