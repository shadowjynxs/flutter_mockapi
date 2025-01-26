import 'package:mockapi/models/item_model.dart';

class ItemModelData {
  ItemModel? itemModel;

  ItemModelData({required this.itemModel});

  ItemModelData.initial() : itemModel = null;

  ItemModelData copyWith({ItemModel? itemModel}) {
    return ItemModelData(
      itemModel: itemModel ?? this.itemModel,
    );
  }
}
