class ItemModel {
  ItemModel({
    required this.data,
    required this.hasMore,
  });
  late final List<Data> data;
  late final bool hasMore;

  ItemModel.fromJson(Map<String, dynamic> json) {
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
    hasMore = json['hasMore'];
  }
}

class Data {
  Data({
    required this.id,
    required this.title,
  });
  late final int id;
  late final String title;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }
}
