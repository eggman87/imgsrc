import 'package:json_annotation/json_annotation.dart';

part 'comment_models.g.dart';

@JsonSerializable()
class Comment {

  Comment({ this.id, this.comment, this.author, this.authorId, this.ups, this.downs, this.vote });

  final int id;
  final String comment;
  final String author;
  @JsonKey(name: "author_id")
  final int authorId;
  final int ups;
  final int downs;
  final String vote;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic>toJson() => _$CommentToJson(this);
}

enum CommentSort {
  best, top, New //weird casing here due to keyword
}