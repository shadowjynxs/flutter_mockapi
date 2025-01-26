import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockapi/models/item_model.dart';
import 'package:mockapi/models/item_model_data.dart';
import 'package:mockapi/services/mock_api_service.dart';

class ItemViewModel extends StateNotifier<ItemModelData> {
  final MockApiService _mockApiService = MockApiService();
  bool isLoading = false;

  ItemViewModel(super.state) {
    loadData(90, "down", "");
  }

  Future<void> loadData(int id, String direction, String searchQuery) async {
    if (isLoading) return;
    isLoading = true;

    try {
      if (state.itemModel == null) {
        final res = await _mockApiService.fetchItems(id: id, direction: direction);
        final items = ItemModel.fromJson(res);
        state = state.copyWith(itemModel: items);
      } else if (state.itemModel!.hasMore) {
        final res = await _mockApiService.fetchItems(id: id, direction: direction);
        final newData = ItemModel.fromJson(res);

        final updatedData = direction == "down"
            ? ItemModel(
                data: [...state.itemModel!.data, ...newData.data],
                hasMore: newData.hasMore,
              )
            : ItemModel(
                data: [...newData.data, ...state.itemModel!.data],
                hasMore: newData.hasMore,
              );
        // state = state.copyWith(itemModel: updatedData);
        _applySearchFilter(searchQuery, updatedData);
      }
    } catch (err) {
      debugPrint(err.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<void> searchItems(String query) async {
    _applySearchFilter(query, state.itemModel!);
  }

  void _applySearchFilter(String searchQuery, ItemModel updatedData) {
    final filteredItems = _filterItems(updatedData.data, searchQuery);
    state = state.copyWith(
      itemModel: ItemModel(data: filteredItems, hasMore: state.itemModel?.hasMore ?? false),
    );
  }

  List<Data> _filterItems(List<Data> items, String searchQuery) {
    if (searchQuery.isEmpty) {
      return items;
    }
    return items
        .where(
          (item) => item.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }
}

// class ItemViewModel extends StateNotifier<ItemModelData> {
//   final MockApiService _mockApiService = MockApiService();
//   bool isLoading = false;
//   List<Data> allItems = [];

//   ItemViewModel(super.state) {
//     loadData(90, "down", "");
//   }

//   Future<void> loadData(int id, String direction, String searchQuery) async {
//     if (isLoading) return;
//     isLoading = true;

//     try {
//       final res = await _mockApiService.fetchItems(id: id, direction: direction);
//       final items = ItemModel.fromJson(res);

//       if (state.itemModel == null) {
//         allItems = items.data;
//       } else if (state.itemModel!.hasMore) {
//         allItems = direction == "down"
//             ? [...state.itemModel!.data, ...items.data]
//             : [...items.data, ...state.itemModel!.data];
//       }

//       // Update state with all items, but apply search filter for display
//       _applySearchFilter(searchQuery);
//     } catch (err) {
//       debugPrint(err.toString());
//     } finally {
//       isLoading = false;
//     }
//   }

//   void searchItems(String searchTerm) {
//     _applySearchFilter(searchTerm);
//   }

//   void _applySearchFilter(String currentSearchTerm) {
//     final filteredItems = _filterItems(allItems, currentSearchTerm);
//     state = state.copyWith(itemModel: ItemModel(data: filteredItems, hasMore: state.itemModel?.hasMore ?? false));
//   }

//   List<Data> _filterItems(List<Data> items, String searchTerm) {
//     if (searchTerm.isEmpty) {
//       return items;
//     }
//     return items.where((item) => item.title.toLowerCase().contains(searchTerm.toLowerCase())).toList();
//   }
// }

final itemViewModelProvider = StateNotifierProvider<ItemViewModel, ItemModelData>((ref) {
  return ItemViewModel(ItemModelData.initial());
});
