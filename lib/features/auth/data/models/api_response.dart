class ApiResponse<T> {
  final bool succeeded;
  final String? message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.succeeded,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final success = json['succeeded'] as bool? ??
        json['success'] as bool? ??
        false;

    return ApiResponse<T>(
      succeeded: success,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: (json['errors'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
