import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  String? userId;
  String? name;
  String? token;

  Token({
    this.userId,
    this.name,
    this.token,
  });

  @override
  String toString() => 'Token(userId: $userId, name: $name, token: $token)';

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Token &&
        other.userId == userId &&
        other.name == name &&
        other.token == token;
  }

  @override
  int get hashCode => Object.hash(userId, name, token);
}
