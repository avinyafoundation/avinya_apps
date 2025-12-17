// 1. Kanban Board Mock Data
const String kanbanBoardResponse = '''
{
  "groups": [
    {
      "groupId": "Pending",
      "groupName": "Pending",
      "tasks": [
        {
          "id": "1",
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          },
          "deadline": "2025-11-01 00:00:00.000",
          "statusText": "Overdue by 2 days",
          "isOverdue": true,
          "status": "Pending"
        },
        {
          "id": "2",
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          },
          "deadline": "2025-11-01 00:00:00.000",
          "statusText": "Overdue by 2 days",
          "isOverdue": true,
          "status": "Pending"
        },
        {
          "id": "3",
          "title": "Clean Lab",
          "description": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          },
          "deadline": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "isOverdue": false,
          "status": "Pending"
        },
        {
          "id": "4",
          "title": "Clean Lab",
          "description": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          },
          "deadline": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "isOverdue": false,
          "status": "Pending"
        }
      ]
    },
    {
      "groupId": "progress",
      "groupName": "In Progress",
      "tasks": [
        {
          "id": "5",
          "title": "Clean Lab",
          "description": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          },
          "deadline": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "isOverdue": false,
          "status": "In Progress"
        },
        {
          "id": "6",
          "title": "Clean Lab",
          "description": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          },
          "deadline": "2025-11-03 00:00:00.000",
          "statusText": "Overdue in 2 days",
          "isOverdue": false,
          "status": "In Progress"
        }
      ]
    },
    {
      "groupId": "Completed",
      "groupName": "Completed",
      "tasks": [
        {
          "id": "7",
          "title": "Paint Walls",
          "description": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          },
          "deadline": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "isOverdue": false,
          "status": "Completed"
        },
        {
          "id": "8",
          "title": "Paint Walls",
          "description": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          },
          "deadline": "2025-11-03 00:00:00.000",
          "statusText": "On Schedule",
          "isOverdue": false,
          "status": "Completed"
        }
      ]
    }
  ]
}
''';

const String maintenanceTasksJson = '''
{
  "tasks": [
    {
      "activityInstance": {
        "id": 1,
        "start_time": "2025-01-10",
        "end_time": "2025-01-12",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 1,
          "title": "Air Conditioner Maintenance",
          "description": "Routine AC inspection and cleaning",
          "type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 1,
            "location_name": "Pod 1"
          }
        },
        "activityParticipants": [
          {
            "id": 1,
            "person": {
              "id": 1,
              "preferred_name": "John Doe"
            },
            "start_time": "2025-01-10",
            "end_time": "2025-01-12",
            "status": "Completed"
          },
          {
            "id": 2,
            "person": {
              "id": 2,
              "preferred_name": "Jane Smith"
            },
            "start_time": "2025-01-10",
            "end_time": "2025-01-12",
            "status": "Completed"
          }
        ],
        "financialInformation": {
          "id": 1,
          "estimatedCost": 1500,
          "totalCost": 1400,
          "materialCosts": [
            {
              "id": 1,
              "item": "Air Filter",
              "quantity": 5,
              "unit": "piece",
              "unitCost": 100
            },
            {
              "id": 2,
              "item": "Coolant",
              "quantity": 2,
              "unit": "liter",
              "unitCost": 250
            }
          ],
          "labourCost": 500,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 2,
        "start_time": "2025-01-15",
        "end_time": "2025-01-20",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 2,
          "title": "Air Conditioner Repair",
          "description": "Fix temperature control issue",
          "type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 1,
            "location_name": "Building A - Floor 2"
          }
        },
        "activityParticipants": [
          {
            "id": 2,
            "person": {
              "id": 2,
              "preferred_name": "Jane Smith"
            },
            "start_time": "2025-01-15",
            "end_time": "2025-01-20",
            "status": "In Progress"
          }
        ],
        "financialInformation": {
          "id": 1,
          "estimatedCost": 1500,
          "totalCost": 2000,
          "materialCosts": [
            {
              "id": 1,
              "item": "Air Filter",
              "quantity": 5,
              "unit": "piece",
              "unitCost": 100
            },
            {
              "id": 2,
              "item": "Coolant",
              "quantity": 2,
              "unit": "liter",
              "unitCost": 250
            }
          ],
          "labourCost": 500,
          "status": "Approved",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    }
  ]
}
''';

const String overdueTasksJson = '''
{
  "overdueTasks": [
    {
      "activityInstance": {
        "id": 12,
        "start_time": "2025-11-10",
        "end_time": "2025-11-15",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 44,
          "title": "Air Conditioner Maintenance",
          "description": "Perform routine maintenance of air conditioners.",
          "location": {
            "id": 3,
            "location_name": "Main Building - Floor 2"
          }
        },
        "overdueDays": 5,
        "activityParticipants": [
          {
            "id": 7,
            "person": {
              "id": 7,
              "preferred_name": "John Doe"
            }
          },
          {
            "id": 8,
            "person": {
              "id": 8,
              "preferred_name": "Jane Smith"
            }
          }
        ]
      }
    }
  ]
}
''';
