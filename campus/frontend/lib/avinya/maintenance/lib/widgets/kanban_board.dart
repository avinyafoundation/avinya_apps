import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import '../data/task_item.dart';
import 'dart:math';
import '../widgets/animated_task_card.dart';
import '../widgets/animated_status_icon.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/common/page_title.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  late AppFlowyBoardController controller;
  String selectedPerson = "Lahiru";
  int? selectedPersonId = 1;

  @override
  void initState() {
    super.initState();

    // 1. Initialize AppFlowy Controller
    controller = AppFlowyBoardController(
      onMoveGroup: (_, __, ___, ____) {
        // Revert the column order if changed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final expectedIds = ["pending", "progress", "completed"];
          for (int i = 0; i < expectedIds.length; i++) {
            final currentIndex =
                controller.groupDatas.indexWhere((g) => g.id == expectedIds[i]);
            if (currentIndex != -1 && currentIndex != i) {
              controller.moveGroup(currentIndex, i);
            }
          }
        });
      },
      onMoveGroupItem: (groupId, fromIndex, toIndex) {},
      onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //cannot move Pending to completed directly and vice versa
          if ((fromGroupId == "pending" && toGroupId == "completed") ||
              (fromGroupId == "completed" && toGroupId == "pending")) {
            //Display Alert
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Invalid Move"),
                  content: const Text(
                      "You cannot move tasks directly between Pending and Completed."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );

            // Revert the move
            final item = controller.groupDatas
                .firstWhere((g) => g.id == toGroupId)
                .items[toIndex];
            controller.removeGroupItem(toGroupId, item.id);
            controller.insertGroupItem(fromGroupId, fromIndex, item);
          }
        });
      },
    );

    // 2. Load Data from dummy_data.dart
    _loadBoardData();
  }

  Future<void> _loadBoardData() async {
    final initialData = await getBoardData();
    for (var group in initialData) {
      controller.addGroup(group);
    }
    setState(() {});
  }

  // Helper for Whole Page Scroll height
  double _calculateBoardHeight() {
    int maxItems = 0;
    // Check if controller has data to prevent errors
    if (controller.groupDatas.isEmpty) return 500;

    for (var group in controller.groupDatas) {
      maxItems = max(maxItems, group.items.length);
    }
    // Header + Footer + (Items * Height) + Buffer
    return 100.0 + (maxItems * 180.0) + 150.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER SECTION ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PageTitle(
                        title: "Task Activities",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: 200,
                        child: DropDown<Map<String, dynamic>>(
                          label: "Select Person",
                          items: const [
                            {"id": 1, "name": "Lahiru"},
                            {"id": 2, "name": "Sakuna"},
                            {"id": 3, "name": "Basuru"},
                          ],
                          selectedValues: selectedPersonId,
                          valueField: (item) => item["id"] as int,
                          displayField: (item) => item["name"] as String,
                          onChanged: (value) {
                            setState(() {
                              selectedPersonId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // --- KANBAN BOARD SECTION ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: _calculateBoardHeight(),
                      width: double.infinity,
                      child: AppFlowyBoard(
                        controller: controller,
                        // Config: Transparent background
                        config: const AppFlowyBoardConfig(
                            groupBackgroundColor: Colors.transparent),
                        groupConstraints:
                            const BoxConstraints.tightFor(width: 380),

                        // --- HEADER BUILDER ---
                        headerBuilder: (context, group) {
                          Color color;
                          if (group.id == "pending") {
                            color = const Color(0xFFFFA000);
                          } else if (group.id == "progress") {
                            color = const Color(0xFF1E88E5);
                          } else {
                            color = const Color(0xFF43A047);
                          }

                          return GestureDetector(
                            onHorizontalDragStart: (details) {}, // Steal drag
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: 15, left: 5),
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  AnimatedStatusIcon(
                                      status: group.id, color: color),
                                  const SizedBox(width: 8),
                                  Text(group.headerData.groupName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[800])),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text("${group.items.length}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          );
                        },

                        // --- CARD BUILDER ---
                        cardBuilder: (context, group, groupItem) {
                          final item = groupItem as TaskItem;
                          TaskItem displayItem = item;

                          // Override status text if Completed and not overdue
                          if (group.id == "completed" && !item.isOverdue) {
                            displayItem = TaskItem(
                                itemId: item.id,
                                title: item.title,
                                description: item.description,
                                location: item.location,
                                endDate: item.endDate,
                                statusText: "On Schedule",
                                overdueDays: item.overdueDays);
                          }

                          Color accentColor;
                          if (group.id == "pending") {
                            accentColor = const Color(0xFFFFA000);
                          } else if (group.id == "progress") {
                            accentColor = const Color(0xFF1E88E5);
                          } else {
                            accentColor = const Color(0xFF43A047);
                          }

                          return AppFlowyGroupCard(
                            key: ObjectKey(item),
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: AnimatedTaskCard(
                              item: displayItem,
                              accentColor: accentColor,
                              groupId: group.id,
                            ),
                          );
                        },

                        // --- FOOTER ---
                        footerBuilder: (context, group) =>
                            const SizedBox(height: 20),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
