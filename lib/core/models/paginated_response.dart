import 'package:equatable/equatable.dart';

/// Modelo genérico para respostas paginadas
///
/// Representa uma resposta paginada do servidor com informações
/// sobre o conteúdo, paginação e totais.
class PaginatedResponse<T> extends Equatable {
  /// Lista de itens da página atual
  final List<T> content;

  /// Número total de elementos em todas as páginas
  final int totalElements;

  /// Número da página atual (baseado em zero)
  final int number;

  /// Número total de páginas
  final int totalPages;

  /// Tamanho da página (número de itens por página)
  final int size;

  /// Indica se é a primeira página
  final bool first;

  /// Indica se é a última página
  final bool last;

  /// Número de elementos na página atual
  final int numberOfElements;

  const PaginatedResponse({
    required this.content,
    required this.totalElements,
    required this.number,
    required this.totalPages,
    required this.size,
    required this.first,
    required this.last,
    required this.numberOfElements,
  });

  /// Cria uma instância a partir de JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      content: (json['content'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      number: json['number'] as int,
      totalPages: json['totalPages'] as int,
      size: json['size'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
      numberOfElements: json['numberOfElements'] as int,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'content': content.map((item) => toJsonT(item)).toList(),
      'totalElements': totalElements,
      'number': number,
      'totalPages': totalPages,
      'size': size,
      'first': first,
      'last': last,
      'numberOfElements': numberOfElements,
    };
  }

  /// Cria uma cópia com valores modificados
  PaginatedResponse<T> copyWith({
    List<T>? content,
    int? totalElements,
    int? number,
    int? totalPages,
    int? size,
    bool? first,
    bool? last,
    int? numberOfElements,
  }) {
    return PaginatedResponse<T>(
      content: content ?? this.content,
      totalElements: totalElements ?? this.totalElements,
      number: number ?? this.number,
      totalPages: totalPages ?? this.totalPages,
      size: size ?? this.size,
      first: first ?? this.first,
      last: last ?? this.last,
      numberOfElements: numberOfElements ?? this.numberOfElements,
    );
  }

  @override
  List<Object> get props => [
    content,
    totalElements,
    number,
    totalPages,
    size,
    first,
    last,
    numberOfElements,
  ];

  @override
  String toString() {
    return 'PaginatedResponse(content: ${content.length} items, '
        'totalElements: $totalElements, number: $number, '
        'totalPages: $totalPages, size: $size)';
  }
}