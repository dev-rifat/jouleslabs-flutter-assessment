import 'package:equatable/equatable.dart';

class SignatureModel extends Equatable {
  final String id;
  final String base64Data;
  final DateTime createdAt;

  const SignatureModel({
    required this.id,
    required this.base64Data,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, base64Data, createdAt];
}
