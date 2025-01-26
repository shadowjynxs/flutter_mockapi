class MockApiService {
  Future<Map<String, dynamic>> fetchItems({
    required int id,
    required String direction,
  }) async {
    await Future.delayed(Duration(seconds: 1));

    if (direction != "up" && direction != "down") {
      throw Exception("Invalid direction: $direction");
    }

    const int pageSize = 50;
    List<Map<String, dynamic>> data = [];

    if (direction == "down") {
      for (int i = 1; i <= pageSize; i++) {
        data.add({'id': id + i, 'title': 'Item ${id + i}'});
      }
    } else if (direction == "up") {
      for (int i = 1; i <= pageSize; i++) {
        data.insert(0, {'id': id - i, 'title': 'Item ${id - i}'});
      }
    }

    bool hasMore = direction == "down" ? data.last['id'] < 2000 : data.first['id'] > -2000;

    return {
      'data': data,
      'hasMore': hasMore,
    };
  }
}
