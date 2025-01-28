import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockapi/models/item_model.dart';
import 'package:mockapi/models/item_model_data.dart';
import 'package:mockapi/viewmodel/item_view_model.dart';
import 'package:mockapi/viewmodel/theme_view_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ItemViewModel itemViewModel;
  late ItemModelData itemModelData;

  int initialResCount = 50;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final List<GlobalKey> itemKeys = [];
  late final GlobalKey searchKey = GlobalKey();
  late double? searchKeyHeight = MediaQuery.of(context).size.height * 0.075;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo((scrollController.position.extentTotal / initialResCount) * 10);
      searchKeyHeight = searchKey.currentContext?.size?.height;
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void _loadMoreItems(String direction, String searchQuery) async {
    final visibleHeights =
        itemKeys.map((key) => key.currentContext?.size?.height ?? 0).where((height) => height > 0).toList();

    final averageHeight =
        visibleHeights.isNotEmpty ? visibleHeights.reduce((a, b) => a + b) / visibleHeights.length : 0;

    final height = averageHeight.toDouble();

    if (direction == "down") {
      if (!itemViewModel.isLoading) {
        await itemViewModel.loadData(ref.read(itemViewModelProvider).itemModel!.data.last.id, direction, searchQuery);
      }
    }

    if (direction == "up") {
      if (!itemViewModel.isLoading) {
        final itemHeight = height;
        final newItemsCount = initialResCount;
        final offsetChange = itemHeight * newItemsCount;
        await itemViewModel.loadData(ref.read(itemViewModelProvider).itemModel!.data.first.id, direction, searchQuery);
        scrollController.jumpTo(scrollController.offset + offsetChange);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    itemViewModel = ref.watch(itemViewModelProvider.notifier);
    itemModelData = ref.watch(itemViewModelProvider);

    final themeMode = ref.watch(themeViewModelProvider);
    final themeViewModel = ref.watch(themeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: themeMode.name == "light" ? Colors.grey : Colors.grey.shade700,
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            final metrics = notification.metrics;
            final threshold = metrics.viewportDimension * 1;
            final distanceFromTop = metrics.pixels;
            final distanceFromBottom = metrics.maxScrollExtent - metrics.pixels;

            if (distanceFromTop < threshold &&
                !metrics.outOfRange &&
                scrollController.position.userScrollDirection.name == "forward") {
              _loadMoreItems("up", searchController.text);
            }

            if (distanceFromBottom < threshold &&
                !metrics.outOfRange &&
                scrollController.position.userScrollDirection.name == "reverse") {
              _loadMoreItems("down", searchController.text);
            }
          }
          return true;
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(key: searchKey, flex: 6, child: searchWidget(context, themeMode.name)),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            themeViewModel.toggleTheme();
                            debugPrint(themeMode.toString());
                          },
                          child: Container(
                            height: searchKeyHeight! - 15,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: themeMode.name == "light" ? Colors.white : Colors.grey.shade800),
                                borderRadius: BorderRadius.circular(20),
                                color: themeMode.name == "light" ? Colors.grey.shade400 : Colors.grey.shade700),
                            child: Icon(
                              themeMode.name == "light" ? Icons.light_mode : Icons.dark_mode,
                              color: themeMode.name == "light" ? Colors.white : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: itemWidget(context, themeMode.name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchWidget(BuildContext context, String mode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: searchController,
        onChanged: (value) async {
          searchController.text = value;
          // await itemViewModel.searchItems(value);
        },
        decoration: InputDecoration(
          fillColor: mode == "light" ? Colors.grey.shade300 : Colors.grey.shade700,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: mode == "light" ? Colors.white : Colors.grey.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: mode == "light" ? Colors.white : Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.green),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIcon: Icon(Icons.search_outlined),
          suffixIcon: Icon(Icons.mic_outlined),
          hintText: "Search here",
        ),
      ),
    );
  }

  Widget itemWidget(BuildContext context, String mode) {
    return ListView.builder(
      controller: scrollController,
      itemCount: itemModelData.itemModel?.data.length ?? 50,
      itemBuilder: (context, index) {
        if (itemKeys.length <= index) {
          itemKeys.add(GlobalKey());
        }
        final data = itemModelData.itemModel == null ? null : itemModelData.itemModel!.data[index];

        return itemTile(context, data, itemKeys[index], mode);
      },
    );
  }

  Widget itemTile(BuildContext context, Data? data, GlobalKey key, String mode) {
    return Padding(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: mode == "light" ? Colors.white : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Skeletonizer(
          enabled: itemViewModel.isLoading,
          child: ListTile(
            title: Text(data == null ? "101" : "${data.id}"),
            subtitle: Text(data == null ? "Item 101" : data.title),
          ),
        ),
      ),
    );
  }
}
