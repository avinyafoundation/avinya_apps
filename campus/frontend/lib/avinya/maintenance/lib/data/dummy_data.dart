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
            "name": "Main Hall"
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
            "name": "Main Hall"
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
            "name": "IT Lab"
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
            "name": "IT Lab"
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
            "name": "IT Lab"
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
            "name": "IT Lab"
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
            "name": "IT Lab"
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
            "name": "IT Lab"
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
