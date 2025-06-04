import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/pages/widgets/purchase_item_tile.dart';
import 'package:park_wallet/pages/widgets/added_balance_tile.dart';
import 'package:park_wallet/pages/widgets/common_app_bar.dart';
import 'package:park_wallet/pages/widgets/common_bottom_navigation_bar.dart';
import 'package:park_wallet/pages/widgets/common_drawer.dart';
import 'package:park_wallet/pages/widgets/wave_background.dart';
import 'package:park_wallet/pages/history/controllers/history_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with WidgetsBindingObserver, RouteAware {
  late HistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HistoryController>();
    WidgetsBinding.instance.addObserver(this);
    
    // Add a small delay to ensure the controller is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onPageVisible();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer to detect when coming back to this page
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      Get.find<RouteObserver<PageRoute>>().subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      Get.find<RouteObserver<PageRoute>>().unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Auto-refresh when app comes back from background
      controller.refreshData();
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this page from another page (like recharge)
    super.didPopNext();
    print("DEBUG: didPopNext called - user returned to history page");
    controller.onPageVisible();
  }
  
  @override
  void didPush() {
    // Called when this page is pushed onto the navigator
    super.didPush();
    print("DEBUG: didPush called - history page pushed");
    // Check for recent recharge when page is opened
    Future.delayed(const Duration(milliseconds: 300), () {
      controller.onPageVisible();
    });
  }

  @override
  void didPushNext() {
    // Called when another page is pushed on top of this page
    super.didPushNext();
    print("DEBUG: didPushNext called - user navigated away from history page");
  }

  @override
  void didPop() {
    // Called when this page is popped from the navigator
    super.didPop();
    print("DEBUG: didPop called - history page popped");
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Scaffold(
      appBar: CommonAppBar(),
      drawer: CommonDrawer(),
      body: Stack(
        children: [
          WaveBackground(opaque: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "transaction_history".tr,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Refresh indicator for new transactions
                  Obx(() {
                    if (controller.isRefreshing.value) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Atualizando histórico...",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (controller.hasNewTransactions.value) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.new_releases, color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "Novas transações disponíveis",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      final transactions = controller.filteredTransactions;

                      if (transactions.isEmpty) {
                        return Center(child: Text("no_transactions".tr));
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await controller.refreshData();
                        },
                        child: ListView.separated(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(), // Permite puxar do topo
                          padding: const EdgeInsets.only(bottom: 24), // Espaço extra no final
                          itemCount: transactions.length + 1,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            if (index == transactions.length) {
                              return Obx(() {
                                if (controller.isLoadingMore.value) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Center(
                                      child: Text(
                                        "Você chegou ao fim da lista.",
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  );
                                }
                              });
                            }

                            final item = transactions[index];
                            return item.operation == "purchase"
                                ? PurchaseItemTile(transaction: item)
                                : AddedBalanceTile(transaction: item);
                          },
                        ),

                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          controller.refreshData();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      bottomNavigationBar:
      CommonBottomNavigationBar(currentRoute: "/history"),
    );
  }
}
