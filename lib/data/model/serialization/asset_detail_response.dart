import 'package:json_annotation/json_annotation.dart';
import 'story.dart';

part 'asset_detail_response.g.dart';

@JsonSerializable()
class DetailResponse {
  @JsonKey(name: "story")
  final Story story;

  DetailResponse({
    required this.story,
  });

  factory DetailResponse.fromJson(json) => _$DetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DetailResponseToJson(this);
}
