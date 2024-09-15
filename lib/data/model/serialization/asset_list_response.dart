import 'package:json_annotation/json_annotation.dart';
import 'story.dart';

part 'asset_list_response.g.dart';

@JsonSerializable()
class ListResponse {
  @JsonKey(name: "listStory")
  final List<Story> listStory;

  ListResponse({
    required this.listStory,
  });

  factory ListResponse.fromJson(json) => _$ListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListResponseToJson(this);
}
