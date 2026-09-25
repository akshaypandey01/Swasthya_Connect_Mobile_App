/// Base API Response wrapper
/// 
/// Standardizes API responses across all endpoints.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  /// Success response factory
  factory ApiResponse.success({
    required T data,
    String? message,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  /// Error response factory
  factory ApiResponse.error({
    required String error,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  /// Parse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      'success': success,
      if (data != null && toJsonT != null) 'data': toJsonT(data as T),
      if (message != null) 'message': message,
      if (error != null) 'error': error,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}

/// Paginated API Response
class PaginatedApiResponse<T> {
  final bool success;
  final List<T> data;
  final PaginationMeta meta;
  final String? message;
  final String? error;

  PaginatedApiResponse({
    required this.success,
    required this.data,
    required this.meta,
    this.message,
    this.error,
  });

  factory PaginatedApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = (json['data'] as List?)
        ?.map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList() ?? [];

    return PaginatedApiResponse(
      success: json['success'] ?? false,
      data: dataList,
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
      message: json['message'],
      error: json['error'],
    );
  }
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalCount: json['totalCount'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalCount': totalCount,
      'pageSize': pageSize,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}
