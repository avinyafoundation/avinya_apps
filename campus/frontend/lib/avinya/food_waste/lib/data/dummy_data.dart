// 1. The Raw JSON Response
const String kanbanBoardResponse = '''
[
    {
      "groupId": "pending",
      "groupName": "Pending",
      "tasks": [
        {
          "id": "1",
          "task": {
            "id": "1",
            "title": "Fix Lights",
            "description": "Replace the 3 bulbs in the main corridor.",
            "location": {
              "id": 2,
              "location_name": "Main Hall"
            }
          },
          "end_time": "2025-11-01 00:00:00.000",
          "statusText": "Overdue by 2 days",
          "overdue_days": 2
        },
        {
          "id": "2",
          "task": {
            "id": "2",
            "title": "Fix Lights",
            "description": "Replace the 3 bulbs in the main corridor.",
            "location": {
              "id": 2,
              "location_name": "Main Hall"
            }
          },
          "end_time": "2025-11-01 00:00:00.000",
          "statusText": "Overdue by 2 days",
          "overdue_days": 2
        },
        {
          "id": "3",
          "task": {
            "id": "3",
            "title": "Clean Lab",
            "description": null,
            "location": {
              "id": 1,
              "name": "IT Lab"
            }
          },
          "end_time": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "overdue_days": 0
        },
        {
          "id": "4",
          "task": {
            "id": "4",
            "title": "Clean Lab",
            "description": null,
            "location": {
              "id": 1,
              "location_name": "IT Lab"
            }
          },
          "end_time": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "overdue_days": 0
        }
      ]
    },
    {
      "groupId": "progress",
      "groupName": "In Progress",
      "tasks": [
        {
          "id": "5",
          "task": {
            "id": "5",
            "title": "Clean Lab",
            "description": null,
            "location": {
              "id": 1,
              "location_name": "IT Lab"
            }
          },
          "end_time": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "overdue_days": 0
        },
        {
          "id": "6",
          "task": {
            "id": "6",
            "title": "Clean Lab",
            "description": null,
            "location": {
              "id": 1,
              "location_name": "IT Lab"
            }
          },
          "end_time": "2025-11-03 00:00:00.000",
          "statusText": "Overdue in 2 days",
          "overdue_days": -2
        }
      ]
    },
    {
      "groupId": "completed",
      "groupName": "Completed",
      "tasks": [
        {
          "id": "7",
          "task": {
            "id": "7",
            "title": "Paint Walls",
            "description": null,
            "location": {
              "id": 1,
              "location_name": "IT Lab"
            }
          },
          "end_time": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "overdue_days": 0
        },
        {
          "id": "8",
          "task": {
            "id": "8",
            "title": "Paint Walls",
            "description": null,
            "location": {
              "id": 1,
              "location_name": "IT Lab"
            }
          },
          "end_time": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "overdue_days": 0
        }
      ]
    }
]
''';

const String analyticsResponse = '''
{
    "average_daily_waste_cost": 502.000000,
    "weekly_total_cost": 2410.00
}
''';

const String topWastedItemsResponse = '''
[
    {
        "food_id": 2,
        "food_name": "Milk Rice",
        "total_portions": 30,
        "total_cost": 750.00
    },
    {
        "food_id": 9,
        "food_name": "Maldives Sambol",
        "total_portions": 20,
        "total_cost": 400.00
    },
    {
        "food_id": 6,
        "food_name": "Dhal Curry",
        "total_portions": 10,
        "total_cost": 400.00
    }
]
''';

const String last7DaysWasteResponse = '''
[
    {
        "date": "2026-02-10",
        "total_waste": 400.00
    },
    {
        "date": "2026-02-09",
        "total_waste": 250.00
    },
    {
        "date": "2026-02-08",
        "total_waste": 450.00
    },
    {
        "date": "2026-02-07",
        "total_waste": 1310.00
    }
]
''';

const String foodItemsResponse = '''
[
    {
        "id": 1,
        "name": "Idly with Sambar",
        "cost_per_portion": 80.00,
        "meal_type": "BREAKFAST"
    },
    {
        "id": 2,
        "name": "Milk Rice",
        "cost_per_portion": 25.00,
        "meal_type": "BREAKFAST"
    },
    {
        "id": 3,
        "name": "Vegetable Fried Rice",
        "cost_per_portion": 90.00,
        "meal_type": "LUNCH"
    },
    {
        "id": 4,
        "name": "Chicken Curry",
        "cost_per_portion": 80.00,
        "meal_type": "LUNCH"
    },
    {
        "id": 6,
        "name": "Dhal Curry",
        "cost_per_portion": 40.00,
        "meal_type": "BREAKFAST"
    },
    {
        "id": 8,
        "name": "Fish",
        "cost_per_portion": 60.00,
        "meal_type": "LUNCH"
    },
    {
        "id": 9,
        "name": "Maldives Sambol",
        "cost_per_portion": 20.00,
        "meal_type": "BREAKFAST"
    },
    {
        "id": 10,
        "name": "Rice",
        "cost_per_portion": 60.00,
        "meal_type": "BREAKFAST"
    }
]
''';

const String mealServingByDateResponse = '''
[
    {
        "id": 71,
        "date": "2026-02-12",
        "meal_type": "breakfast",
        "served_count": 40,
        "notes": null,
        "created_at": "2026-02-10 10:38:05.0",
        "updated_at": "2026-02-10 10:38:05.0",
        "food_wastes": [
            {
                "id": 83,
                "portions": 10,
                "food_item": {
                    "id": 6,
                    "name": "Dhal Curry",
                    "cost_per_portion": 40.00,
                    "meal_type": "BREAKFAST"
                },
                "food_id": 6,
                "meal_serving_id": 71
            }
        ]
    }
]
''';

const String mealServingByIdResponse = '''
{
    "id": 1,
    "date": "2025-12-04",
    "meal_type": "breakfast",
    "served_count": 120,
    "notes": "Normal weekday breakfast",
    "created_at": "2025-11-13 10:49:40.0",
    "updated_at": "2025-12-12 08:28:09.0",
    "food_wastes": [
        {
            "id": 1,
            "portions": 10,
            "food_item": {
                "id": 1,
                "name": "Idly with Sambar",
                "cost_per_portion": 80.00
            }
        },
        {
            "id": 2,
            "portions": 5,
            "food_item": {
                "id": 2,
                "name": "Milk Rice",
                "cost_per_portion": 25.00
            }
        },
        {
            "id": 41,
            "portions": 6,
            "food_item": {
                "id": 1,
                "name": "Idly with Sambar",
                "cost_per_portion": 80.00
            }
        }
    ]
}
''';

const String mealServingsListResponse = '''
[
    {
        "id": 1,
        "date": "2025-12-04",
        "meal_type": "breakfast",
        "served_count": 120,
        "notes": "Normal weekday breakfast",
        "created_at": "2025-11-13 10:49:40.0",
        "updated_at": "2025-12-12 08:28:09.0",
        "food_wastes": [
            {
                "id": 1,
                "portions": 10,
                "food_item": {
                    "id": 1,
                    "name": "Idly with Sambar",
                    "cost_per_portion": 80.00
                }
            },
            {
                "id": 2,
                "portions": 5,
                "food_item": {
                    "id": 2,
                    "name": "Milk Rice",
                    "cost_per_portion": 25.00
                }
            }
        ]
    },
    {
        "id": 71,
        "date": "2026-02-12",
        "meal_type": "breakfast",
        "served_count": 40,
        "notes": null,
        "created_at": "2026-02-10 10:38:05.0",
        "updated_at": "2026-02-10 10:38:05.0",
        "food_wastes": [
            {
                "id": 83,
                "portions": 10,
                "food_item": {
                    "id": 6,
                    "name": "Dhal Curry",
                    "cost_per_portion": 40.00
                }
            }
        ]
    },
    {
        "id": 72,
        "date": "2026-02-11",
        "meal_type": "lunch",
        "served_count": 85,
        "notes": "Tuesday lunch",
        "created_at": "2026-02-11 12:15:00.0",
        "updated_at": "2026-02-11 12:15:00.0",
        "food_wastes": [
            {
                "id": 84,
                "portions": 8,
                "food_item": {
                    "id": 3,
                    "name": "Chicken Curry",
                    "cost_per_portion": 120.00
                }
            },
            {
                "id": 85,
                "portions": 12,
                "food_item": {
                    "id": 4,
                    "name": "White Rice",
                    "cost_per_portion": 30.00
                }
            }
        ]
    }
]
''';
