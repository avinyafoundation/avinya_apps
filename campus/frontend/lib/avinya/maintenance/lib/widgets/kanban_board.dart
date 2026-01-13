import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import '../data/task_item.dart';
import 'dart:math';
import '../widgets/animated_task_card.dart';
import '../widgets/animated_status_icon.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/common/page_title.dart';
import '../data/person.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  late AppFlowyBoardController controller;
  int? selectedPersonId;
  List<Person> employees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();

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
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          bool isInvalidMove = false;
          String errorMessage = "";

          // 1. Validation Logic: Cannot move Pending directly to Completed
          if (fromGroupId == "pending" && toGroupId == "completed") {
            isInvalidMove = true;
            errorMessage =
                "You cannot move tasks directly between Pending and Completed.";
          }
          // 2. Validation Logic: Cannot move OUT of Completed
          else if (fromGroupId == "completed" &&
              (toGroupId == "pending" || toGroupId == "progress")) {
            isInvalidMove = true;
            errorMessage =
                "Completed tasks cannot be moved back to Pending or In Progress.";
          }

          if (isInvalidMove) {
            _showAlertDialog("Invalid Move", errorMessage);
            _revertMove(fromGroupId, fromIndex, toGroupId, toIndex);
            return;
          }

          // 3. Confirmation Logic: Moving to Completed
          if (toGroupId == "completed") {
            bool? confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Confirm Completion"),
                content: const Text(
                    "Are you sure you want to mark this task as Completed? This action cannot be undone."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            );

            if (confirm != true) {
              _revertMove(fromGroupId, fromIndex, toGroupId, toIndex);
            } else {
              // Logic to update status in the backend goes here
            }
          }
        });
      },
    );
    _fetchEmployees();
  }

  void _revertMove(
    String fromGroupId, int fromIndex, String toGroupId, int toIndex) {
    final item = controller.groupDatas
        .firstWhere((g) => g.id == toGroupId)
        .items[toIndex];
    controller.removeGroupItem(toGroupId, item.id);
    controller.insertGroupItem(fromGroupId, fromIndex, item);
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchEmployees() async {
    employees = await fetchEmployeeListByOrganization(2);

    if (employees.isNotEmpty) {
      setState(() {
        selectedPersonId = employees.first.id;
      });
      await _loadBoardData();
    } else {
      setState(() {});
    }
  }

  Future<void> _loadBoardData() async {
    for (var group in controller.groupDatas.toList()) {
      controller.removeGroup(group.id);
    }
    final initialData =
        await getBoardData(personId: selectedPersonId, organizationId: 2);
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
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropDown<Person>(
                                label: "Select Person",
                                items: employees,
                                selectedValues: selectedPersonId,
                                valueField: (item) => item.id ?? 0,
                                displayField: (item) =>
                                    item.preferred_name ?? "",
                                onChanged: (value) {
                                  setState(() {
                                    selectedPersonId = value;
                                  });
                                  _loadBoardData();
                                },
                              ),
                            ),
                          ],
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
