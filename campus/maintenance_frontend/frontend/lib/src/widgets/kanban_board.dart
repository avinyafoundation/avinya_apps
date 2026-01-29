import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Added for Timer
import '../services/translation_service.dart';
import '../data/task_item.dart';
import 'dart:math';
import '../widgets/animated_task_card.dart';
import '../widgets/animated_status_icon.dart';
import '../widgets/common/drop_down.dart';
import '../widgets/common/page_title.dart';
import '../widgets/common/pin_code_dialog.dart';
import '../data/person.dart';
import '../data/person_pin.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  late AppFlowyBoardController controller;
  int? selectedPersonId;
  List<Person> employees = [];
  bool _isLoading = false;

  // Session Management Variables
  Timer? _sessionTimer;
  DateTime? _sessionLoginTime;
  DateTime? _sessionEndTime;
  int? _sessionPersonId;
  static const int _sessionDurationMinutes = 5;

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Removed redundant _fetchEmployees(); call

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
          final item = controller.groupDatas
              .firstWhere((g) => g.id == toGroupId)
              .items[toIndex];

          final isValid = await _handleTaskMove(fromGroupId, toGroupId, item);

          if (!isValid) {
            _revertMove(fromGroupId, fromIndex, toGroupId, toIndex);
          } else {
            // Logic to update status in the backend goes here
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

  // --- Session Management ---

  void _startSession(int personId) {
    if (!mounted) return;

    _sessionTimer?.cancel();

    setState(() {
      _sessionPersonId = personId;
      selectedPersonId = personId;
      _sessionLoginTime = DateTime.now();
      _sessionEndTime = _sessionLoginTime!
          .add(const Duration(minutes: _sessionDurationMinutes));
    });

    _sessionTimer = Timer(
      const Duration(minutes: _sessionDurationMinutes),
      _endSession,
    );

    _loadBoardData();
  }

  void _endSession() {
    if (_sessionPersonId == null) return; // Already ended
    _sessionTimer?.cancel();
    setState(() {
      _sessionPersonId = null;
      _sessionLoginTime = null;
      _sessionEndTime = null;
      selectedPersonId = null;
      // Clear board data
      for (var group in controller.groupDatas.toList()) {
        controller.removeGroup(group.id);
      }
    });
    _promptInitialPin(); // Prompt again
  }

  bool _checkSessionValidity() {
    if (_sessionPersonId != null && _sessionEndTime != null) {
       if (DateTime.now().isAfter(_sessionEndTime!)) {
          _endSession();
          return false;
       }
       return true;
    }
    return false;
  }

  Future<void> _promptInitialPin() async {
    final pin = await _showPinDialog();
    if (!mounted || pin == null) return;

    try {
      final user = await PersonPin.validatePin(pin);

      if (!mounted) return;

      if (user == null) {
        await _showAlertDialog("වැරදි PIN අංකයකි", "කරුණාකර නැවත උත්සාහ කරන්න.");
        _promptInitialPin();
        return;
      }

      final int userId = int.parse(user['id'].toString());
      _startSession(userId);
      
    } catch (e) {
      await _showAlertDialog("සන්නිවේදන දෝෂයකි", "නැවත උත්සාහ කරන්න.");
      _promptInitialPin();
    }
  }

  Future<String?> _showPinDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Force entry
      builder: (context) => const PinCodeDialog(),
    );
  }

  // Handle task move with validation and confirmation
  Future<bool> _handleTaskMove(
      String fromGroupId, String toGroupId, AppFlowyGroupItem item) async {
    if (!_checkSessionValidity()) return false;

    bool isInvalidMove = false;
    String errorMessage = "";

    // 1. Validation Logic: Cannot move Pending directly to Completed
    if (fromGroupId == "pending" && toGroupId == "completed") {
      isInvalidMove = true;
      errorMessage =
          "'කරන්න තියෙන' කාර්යයන් කෙලින්ම 'ඉවර කරපු' කාර්යයන් වෙත මාරු කළ නොහැක.";
    }
    // 2. Validation Logic: Cannot move OUT of Completed
    else if (fromGroupId == "completed" &&
        (toGroupId == "pending" || toGroupId == "progress")) {
      isInvalidMove = true;
      errorMessage =
          "'ඉවර කරපු' කාර්යයන් 'කරන්න තියෙන' හෝ 'කරගෙන යන' කාර්යයන් වෙත මාරු කළ නොහැක.";
    }

    if (isInvalidMove) {
      _showAlertDialog("අවලංගු මාරුවකි", errorMessage);
      return false;
    }

    // 3. Confirmation Logic: Moving to Completed
    if (toGroupId == "completed") {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("තහවුරු කිරීම"),
          content: const Text(
              "ඔබට මෙම කාර්යය 'ඉවර කරපු' ලෙස සලකුණු කිරීමට ඔබට අවශ්‍ය බව සහතිකද? මෙම ක්‍රියාව වෙනස් කළ නොහැක."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("අවලංගු කරන්න"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text("තහවුරු කරන්න"),
            ),
          ],
        ),
      );

      if (confirm != true) {
        return false;
      }
    }

    // Update backend status
    try {
      String status = toGroupId == 'pending'
          ? 'Pending'
          : toGroupId == 'progress'
              ? 'InProgress'
              : 'Completed';
      await updateTaskStatus(int.parse(item.id), selectedPersonId!, status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task status: $e')),
        );
      }
      return false; // Revert the move
    }

    return true;
  }

  Future<void> _showAlertDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("හරි"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchEmployees() async {
    employees = await fetchEmployeeListByOrganization(2);

    if (employees.isNotEmpty) {
      // Don't auto-select. Wait for PIN.
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_sessionPersonId == null) {
              _promptInitialPin();
          }
      });
    }
    setState(() {});
  }

  Future<void> _loadBoardData({bool forceRefresh = false}) async {
    if (!_checkSessionValidity()) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    // 1. Clear existing groups to avoid duplication during refresh
    for (var group in controller.groupDatas.toList()) {
      controller.removeGroup(group.id);
    }

    try {
      // 2. Fetch the raw task data from your database/backend
      final initialData =
          await getBoardData(personId: selectedPersonId, organizationId: 2);

      // 3. Collect all strings that need translation (Titles and Descriptions)
      List<String> stringsToTranslate = [];
      for (var group in initialData) {
        for (var item in group.items) {
          final task = item as TaskItem;
          if (task.title.isNotEmpty) stringsToTranslate.add(task.title);
          if (task.description != null && task.description!.isNotEmpty) {
            stringsToTranslate.add(task.description!);
          }
        }
      }

      // 4. Call Gemini ONCE to translate the entire board's content.
      // This fills the GeminiTranslator._cache, so cards load instantly.
      if (stringsToTranslate.isNotEmpty) {
        if (forceRefresh) {
          GeminiTranslator.clearCache();
        }
        await GeminiTranslator.translateBatch(stringsToTranslate);
      }

      // 5. Add the translated/prepared groups back to the controller
      for (var group in initialData) {
        controller.addGroup(group);
      }
    } catch (e) {
      print("Error loading board data: $e");
      _showAlertDialog("Sync Error", "Failed to load tasks. Please try again.");
    } finally {
      // 6. Trigger a UI refresh
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  // Helper to translate group names to Sinhala
  String _getGroupDisplayName(String groupId) {
    switch (groupId) {
      case 'pending':
        return 'කරන්න තියෙන'; // Karanna thiyena - Things to be done
      case 'progress':
        return 'කරගෙන යන'; // Karagena yana - Work currently going on
      case 'completed':
        return 'ඉවර කරපු'; // Iwara karapu - Finished/Done
      default:
        return groupId;
    }
  }

  // Helper to get Sinhala status text based on overdue days
  String getSinhalaStatusText(int overdueDays) {
    if (overdueDays > 0) {
      // Already late
      return "දින $overdueDays ක් ප්‍රමාදයි";
    } else if (overdueDays >= -2 && overdueDays < 0) {
      // Upcoming deadline
      return "අවසන් වීමට තව දින ${overdueDays.abs()} කි";
    } else if (overdueDays == 0) {
      // Overdue today
      return "අද අවසන් වේ";
    } else {
      // On track
      return "නියමිත කාලසටහනට අනුව";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER SECTION ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PageTitle(
                                  title:
                                      "${employees.firstWhere((e) => e.id == selectedPersonId, orElse: () => Person()).preferred_name ?? "User"}'s Task Activities",
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 15),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: DropDown<Person>(
                                          label: "නම තෝරන්න",
                                          items: employees,
                                          selectedValues: selectedPersonId,
                                          valueField: (item) => item.id ?? 0,
                                          displayField: (item) =>
                                              item.preferred_name ?? "",
                                          onChanged: (value) async {
                                            if (value == null || value == selectedPersonId) return;

                                            String? pin = await _showPinDialog();
                                            if (pin != null) {
                                              try {
                                                final user = await PersonPin.validatePin(pin);
                                                // Ensure the PIN belongs to the user they actually selected
                                                if (user != null && int.parse(user['id'].toString()) == value) {
                                                  _startSession(value);
                                                } else {
                                                  await _showAlertDialog("වැරදි PIN අංකයකි", "මෙම පරිශීලකයා සඳහා PIN අංකය වැරදිය.");
                                                  setState(() {});
                                                }
                                              } catch (e) {
                                                await _showAlertDialog("Error", "Failed to validate PIN.");
                                                setState(() {});
                                              }
                                            } else {
                                              setState(() {});
                                            }
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
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () => _loadBoardData(forceRefresh: true),
                                tooltip: 'Refresh',
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.logout),
                                onPressed: _endSession,
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
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
                                onHorizontalDragStart:
                                    (details) {}, // Steal drag
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 15, left: 5),
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      AnimatedStatusIcon(
                                          status: group.id, color: color),
                                      const SizedBox(width: 8),
                                      Text(_getGroupDisplayName(group.id),
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

                              // Always use Sinhala status text
                              final displayItem = TaskItem(
                                  itemId: item.id,
                                  title: GeminiTranslator.getCachedTranslation(
                                      item.title),
                                  description: item.description != null
                                      ? GeminiTranslator.getCachedTranslation(
                                          item.description!)
                                      : null,
                                  location: item.location,
                                  endDate: item.endDate,
                                  statusText:
                                      getSinhalaStatusText(item.overdueDays),
                                  overdueDays: item.overdueDays);

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
                                decoration: const BoxDecoration(
                                    color: Colors.transparent),
                                child: PopupMenuButton<String>(
                                  tooltip: '',
                                  padding: EdgeInsets.zero,
                                  offset: const Offset(0, 40),
                                  onSelected: (newGroupId) async {
                                    if (newGroupId != group.id) {
                                      final isValid = await _handleTaskMove(
                                          group.id, newGroupId, item);

                                      if (isValid) {
                                        final toGroup = controller.groupDatas
                                            .firstWhere(
                                                (g) => g.id == newGroupId);

                                        controller.removeGroupItem(
                                            group.id, item.id);
                                        controller.insertGroupItem(newGroupId,
                                            toGroup.items.length, item);
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<String>(
                                      value: 'pending',
                                      child: Row(
                                        children: [
                                          Icon(Icons.pending_outlined,
                                              color: Color(0xFFFFA000)),
                                          SizedBox(width: 12),
                                          Text('කරන්න තියෙන'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'progress',
                                      child: Row(
                                        children: [
                                          Icon(Icons.pending_outlined,
                                              color: Color(0xFF1E88E5)),
                                          SizedBox(width: 12),
                                          Text('කරගෙන යන'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'completed',
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              color: Color(0xFF43A047)),
                                          SizedBox(width: 12),
                                          Text('ඉවර කරපු'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: AnimatedTaskCard(
                                    item: displayItem,
                                    accentColor: accentColor,
                                    groupId: group.id,
                                  ),
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

          // --- LOADING OVERLAY ---
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
