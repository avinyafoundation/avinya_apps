// 1. The Raw JSON Response
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

// //////////////////////////////////////////////////////////////////
// ///Maintenance tasks dummy data

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
          "exceptionDeadline":2,
          "location": {
            "id": 12,
            "location_name": "Pod 1"
          }
        },
        "activityParticipants": [
          {
            "id": 1,
            "person": {
              "id": 1,
              "preferred_name": "Ashan"
            },
            "start_time": "2025-01-10",
            "end_time": "2025-01-12",
            "status": "Completed"
          },
          {
            "id": 2,
            "person": {
              "id": 2,
              "preferred_name": "Sunil"
            },
            "start_time": "2025-01-10",
            "end_time": "2025-01-12",
            "status": "Completed"
          }
        ]
        
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
            "id": 14,
            "location_name": "Building A - Floor 2"
          }
        },
        "activityParticipants": [
          {
            "id": 2,
            "person": {
              "id": 2,
              "preferred_name": "Sunil"
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
    },
    {
      "activityInstance": {
        "id": 3,
        "start_time": "2025-02-01",
        "end_time": "2025-02-05",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 3,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 15,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 3,
            "person": {
              "id": 3,
              "preferred_name": "Pradeepa"
            },
            "start_time": "2025-02-01",
            "end_time": "2025-02-05",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 3,
          "estimatedCost": 500,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 3,
              "item": "LED Bulbs",
              "quantity": 3,
              "unit": "piece",
              "unitCost": 50
            }
          ],
          "labourCost": 350,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 4,
        "start_time": "2025-02-10",
        "end_time": "2025-02-12",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 4,
          "title": "Clean Lab",
          "description": "Deep cleaning of laboratory facilities",
          "type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 13,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 4,
            "person": {
              "id": 4,
              "preferred_name": "Kamal"
            },
            "start_time": "2025-02-10",
            "end_time": "2025-02-12",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 4,
          "estimatedCost": 800,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 4,
              "item": "Cleaning Supplies",
              "quantity": 10,
              "unit": "piece",
              "unitCost": 40
            }
          ],
          "labourCost": 400,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 5,
        "start_time": "2025-03-01",
        "end_time": "2025-03-03",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 5,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "type": "oneTime",
          "frequency": null,
          "location": {
            "id": 12,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 5,
            "person": {
              "id": 5,
              "preferred_name": "Janaka"
            },
            "start_time": "2025-03-01",
            "end_time": "2025-03-03",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 5,
          "estimatedCost": 450,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 5,
              "item": "Fluorescent Tubes",
              "quantity": 3,
              "unit": "piece",
              "unitCost": 60
            }
          ],
          "labourCost": 270,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 6,
        "start_time": "2025-03-15",
        "end_time": "2025-03-18",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 6,
          "title": "Clean Lab",
          "description": "Regular maintenance cleaning of laboratory spaces",
          "type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 15,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 6,
            "person": {
              "id": 6,
              "preferred_name": "Iresha"
            },
            "start_time": "2025-03-15",
            "end_time": "2025-03-18",
            "status": "Pending"
          },
          {
            "id": 7,
            "person": {
              "id": 7,
              "preferred_name": "Sunil"
            },
            "start_time": "2025-03-15",
            "end_time": "2025-03-18",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 6,
          "estimatedCost": 950,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 6,
              "item": "Disinfectant",
              "quantity": 5,
              "unit": "liter",
              "unitCost": 80
            },
            {
              "id": 7,
              "item": "Floor Cleaner",
              "quantity": 3,
              "unit": "liter",
              "unitCost": 50
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
        "id": 7,
        "start_time": "2025-04-01",
        "end_time": "2025-04-05",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 7,
          "title": "Clean Lab",
          "description": "Comprehensive cleaning of all lab equipment",
          "type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 8,
            "person": {
              "id": 8,
              "preferred_name": "Nimal Perera"
            },
            "start_time": "2025-04-01",
            "end_time": "2025-04-05",
            "status": "In Progress"
          }
        ],
        "financialInformation": {
          "id": 7,
          "estimatedCost": 700,
          "totalCost": 650,
          "materialCosts": [
            {
              "id": 8,
              "item": "Cleaning Kit",
              "quantity": 2,
              "unit": "piece",
              "unitCost": 125
            }
          ],
          "labourCost": 400,
          "status": "Approved",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 8,
        "start_time": "2025-04-10",
        "end_time": "2025-04-15",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 8,
          "title": "Fix Lights",
          "description": "Emergency lighting system repair",
          "type": "oneTime",
          "frequency": null,
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 9,
            "person": {
              "id": 9,
              "preferred_name": "Ashan"
            },
            "start_time": "2025-04-10",
            "end_time": "2025-04-15",
            "status": "In Progress"
          },
          {
            "id": 10,
            "person": {
              "id": 10,
              "preferred_name": "Janaka"
            },
            "start_time": "2025-04-10",
            "end_time": "2025-04-15",
            "status": "In Progress"
          }
        ],
        "financialInformation": {
          "id": 8,
          "estimatedCost": 1200,
          "totalCost": 1150,
          "materialCosts": [
            {
              "id": 9,
              "item": "Emergency Lights",
              "quantity": 4,
              "unit": "piece",
              "unitCost": 180
            },
            {
              "id": 10,
              "item": "Wiring",
              "quantity": 50,
              "unit": "piece",
              "unitCost": 5
            }
          ],
          "labourCost": 630,
          "status": "Approved",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 9,
        "start_time": "2025-05-01",
        "end_time": "2025-05-05",
        "overallTaskStatus": "Completed",
        "maintenanceTask": {
          "id": 9,
          "title": "Paint Walls",
          "description": "Repaint interior walls with fresh coat",
          "type": "oneTime",
          "frequency": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 11,
            "person": {
              "id": 11,
              "preferred_name": "Pradeepa"
            },
            "start_time": "2025-05-01",
            "end_time": "2025-05-05",
            "status": "Completed"
          },
          {
            "id": 12,
            "person": {
              "id": 12,
              "preferred_name": "Iresha"
            },
            "start_time": "2025-05-01",
            "end_time": "2025-05-05",
            "status": "Completed"
          }
        ],
        "financialInformation": {
          "id": 9,
          "estimatedCost": 2500,
          "totalCost": 2400,
          "materialCosts": [
            {
              "id": 11,
              "item": "Paint",
              "quantity": 20,
              "unit": "liter",
              "unitCost": 80
            },
            {
              "id": 12,
              "item": "Primer",
              "quantity": 10,
              "unit": "liter",
              "unitCost": 60
            }
          ],
          "labourCost": 800,
          "status": "Approved",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 10,
        "start_time": "2025-05-10",
        "end_time": "2025-05-12",
        "overallTaskStatus": "Completed",
        "maintenanceTask": {
          "id": 10,
          "title": "Paint Walls",
          "description": "Touch up paint work in common areas",
          "type": "Recurring",
          "frequency": "Quarterly",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 13,
            "person": {
              "id": 13,
              "preferred_name": "Pradeepa"
            },
            "start_time": "2025-05-10",
            "end_time": "2025-05-12",
            "status": "Completed"
          }
        ],
        "financialInformation": {
          "id": 10,
          "estimatedCost": 1800,
          "totalCost": 1750,
          "materialCosts": [
            {
              "id": 13,
              "item": "Wall Paint",
              "quantity": 15,
              "unit": "liter",
              "unitCost": 85
            }
          ],
          "labourCost": 475,
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
              "preferred_name": "Ashan"
            }
          },
          {
            "id": 8,
            "person": {
              "id": 8,
              "preferred_name": "Sunil"
            }
          }
        ]
      }
    },
    {
      "activityInstance": {
        "id": 13,
        "start_time": "2025-11-07",
        "end_time": "2025-11-15",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 44,
          "title": "Fix Lights",
          "description": "Replace faulty lights in the main corridor.",
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
              "preferred_name": "Nimal Perera"
            }
          }
        ]
      }
    },
    {
      "activityInstance": {
        "id": 14,
        "start_time": "2025-11-05",
        "end_time": "2025-11-12",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 45,
          "title": "Clean Lab",
          "description": "Deep cleaning of laboratory facilities",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "overdueDays": 7,
        "activityParticipants": [
          {
            "id": 14,
            "person": {
              "id": 14,
              "preferred_name": "Kamal"
            }
          }
        ]
      }
    },
    {
      "activityInstance": {
        "id": 15,
        "start_time": "2025-11-08",
        "end_time": "2025-11-14",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 46,
          "title": "Paint Walls",
          "description": "Touch up paint work in common areas",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "overdueDays": 3,
        "activityParticipants": [
          {
            "id": 15,
            "person": {
              "id": 15,
              "preferred_name": "Janaka"
            }
          },
          {
            "id": 16,
            "person": {
              "id": 16,
              "preferred_name": "Iresha"
            }
          }
        ]
      }
    },
    {
      "activityInstance": {
        "id": 16,
        "start_time": "2025-11-03",
        "end_time": "2025-11-10",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 47,
          "title": "Air Conditioner Repair",
          "description": "Fix temperature control issue",
          "location": {
            "id": 1,
            "location_name": "Building A - Floor 2"
          }
        },
        "overdueDays": 10,
        "activityParticipants": [
          {
            "id": 17,
            "person": {
              "id": 17,
              "preferred_name": "Pradeepa"
            }
          }
        ]
      }
    }
  ]
}
''';

// ------------ DUMMY DATA FOR DIRECTOR DASHBOARD ----------------
// Get monthly tast cost summary for an organization

const String monthlyTaskCostSummaryJson = '''
{
  "year": 2025,
  "monthlyCosts": [
    {
      "month": 1,
      "estimatedCost": 45000,
      "actualCost": 42000
    },
    {
      "month": 2,
      "estimatedCost": 52000,
      "actualCost": 48000
    },
    {
      "month": 3,
      "estimatedCost": 58000,
      "actualCost": 55000
    },
    {
      "month": 4,
      "estimatedCost": 65000,
      "actualCost": 62000
    },
    {
      "month": 5,
      "estimatedCost": 72000,
      "actualCost": 74000
    },
    {
      "month": 6,
      "estimatedCost": 80000,
      "actualCost": 83000
    },
    {
      "month": 7,
      "estimatedCost": 88000,
      "actualCost": 85000
    },
    {
      "month": 8,
      "estimatedCost": 92000,
      "actualCost": 90000
    },
    {
      "month": 9,
      "estimatedCost": 85000,
      "actualCost": 82000
    },
    {
      "month": 10,
      "estimatedCost": 78000,
      "actualCost": 75000
    },
    {
      "month": 11,
      "estimatedCost": 70000,
      "actualCost": 68000
    },
    {
      "month": 12,
      "estimatedCost": 62000,
      "actualCost": 59000
    }
  ]
}
''';

const String directorDashboardSummaryJson = '''{
  "totalTasks": 10,
  "completedTasks": 2,
  "inProgressTasks": 3,
  "pendingTasks": 5,
  "totalCost": 175000.5,
  "totalUpcomingTasks": 5,
  "nextMonthlyEstimatedCost": 20000.0
}
''';

const String pendingTasksJson = '''
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
              "preferred_name": "Ashan"
            },
            "start_time": "2025-01-10",
            "end_time": "2025-01-12",
            "status": "Completed"
          },
          {
            "id": 2,
            "person": {
              "id": 2,
              "preferred_name": "Sunil"
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
        "id": 3,
        "start_time": "2025-02-01",
        "end_time": "2025-02-05",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 3,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 3,
            "person": {
              "id": 3,
              "preferred_name": "Pradeepa"
            },
            "start_time": "2025-02-01",
            "end_time": "2025-02-05",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 3,
          "estimatedCost": 500,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 3,
              "item": "LED Bulbs",
              "quantity": 3,
              "unit": "piece",
              "unitCost": 50
            }
          ],
          "labourCost": 350,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 4,
        "start_time": "2025-02-10",
        "end_time": "2025-02-12",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 4,
          "title": "Clean Lab",
          "description": "Deep cleaning of laboratory facilities",
          "type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 4,
            "person": {
              "id": 4,
              "preferred_name": "Kamal"
            },
            "start_time": "2025-02-10",
            "end_time": "2025-02-12",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 4,
          "estimatedCost": 800,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 4,
              "item": "Cleaning Supplies",
              "quantity": 10,
              "unit": "piece",
              "unitCost": 40
            }
          ],
          "labourCost": 400,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 5,
        "start_time": "2025-03-01",
        "end_time": "2025-03-03",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 5,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "type": "oneTime",
          "frequency": null,
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 5,
            "person": {
              "id": 5,
              "preferred_name": "Janaka"
            },
            "start_time": "2025-03-01",
            "end_time": "2025-03-03",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 5,
          "estimatedCost": 450,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 5,
              "item": "Fluorescent Tubes",
              "quantity": 3,
              "unit": "piece",
              "unitCost": 60
            }
          ],
          "labourCost": 270,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 6,
        "start_time": "2025-03-15",
        "end_time": "2025-03-18",
        "overallTaskStatus": "Pending",
        "maintenanceTask": {
          "id": 6,
          "title": "Clean Lab",
          "description": "Regular maintenance cleaning of laboratory spaces",
          "type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 6,
            "person": {
              "id": 6,
              "preferred_name": "Iresha"
            },
            "start_time": "2025-03-15",
            "end_time": "2025-03-18",
            "status": "Pending"
          },
          {
            "id": 7,
            "person": {
              "id": 7,
              "preferred_name": "Sunil"
            },
            "start_time": "2025-03-15",
            "end_time": "2025-03-18",
            "status": "Pending"
          }
        ],
        "financialInformation": {
          "id": 6,
          "estimatedCost": 950,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 6,
              "item": "Disinfectant",
              "quantity": 5,
              "unit": "liter",
              "unitCost": 80
            },
            {
              "id": 7,
              "item": "Floor Cleaner",
              "quantity": 3,
              "unit": "liter",
              "unitCost": 50
            }
          ],
          "labourCost": 500,
          "status": "Pending",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    }
  ]
}
''';

const String inProgressTasksJson = '''
{
  "tasks": [
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
              "preferred_name": "Sunil"
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
    },
    {
      "activityInstance": {
        "id": 7,
        "start_time": "2025-04-01",
        "end_time": "2025-04-05",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 7,
          "title": "Clean Lab",
          "description": "Comprehensive cleaning of all lab equipment",
          "type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 8,
            "person": {
              "id": 8,
              "preferred_name": "Nimal Perera"
            },
            "start_time": "2025-04-01",
            "end_time": "2025-04-05",
            "status": "In Progress"
          }
        ],
        "financialInformation": {
          "id": 7,
          "estimatedCost": 700,
          "totalCost": 650,
          "materialCosts": [
            {
              "id": 8,
              "item": "Cleaning Kit",
              "quantity": 2,
              "unit": "piece",
              "unitCost": 125
            }
          ],
          "labourCost": 400,
          "status": "Approved",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 8,
        "start_time": "2025-04-10",
        "end_time": "2025-04-15",
        "overallTaskStatus": "In Progress",
        "maintenanceTask": {
          "id": 8,
          "title": "Fix Lights",
          "description": "Emergency lighting system repair",
          "type": "oneTime",
          "frequency": null,
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 9,
            "person": {
              "id": 9,
              "preferred_name": "Ashan"
            },
            "start_time": "2025-04-10",
            "end_time": "2025-04-15",
            "status": "In Progress"
          },
          {
            "id": 10,
            "person": {
              "id": 10,
              "preferred_name": "Janaka"
            },
            "start_time": "2025-04-10",
            "end_time": "2025-04-15",
            "status": "In Progress"
          }
        ],
        "financialInformation": {
          "id": 8,
          "estimatedCost": 1200,
          "totalCost": 1150,
          "materialCosts": [
            {
              "id": 9,
              "item": "Emergency Lights",
              "quantity": 4,
              "unit": "piece",
              "unitCost": 180
            },
            {
              "id": 10,
              "item": "Wiring",
              "quantity": 50,
              "unit": "piece",
              "unitCost": 5
            }
          ],
          "labourCost": 630,
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

const String completedTasksJson = '''
{
  "tasks": [
    {
      "activityInstance": {
        "id": 9,
        "start_time": "2025-05-01",
        "end_time": "2025-05-05",
        "overallTaskStatus": "Completed",
        "maintenanceTask": {
          "id": 9,
          "title": "Paint Walls",
          "description": "Repaint interior walls with fresh coat",
          "type": "oneTime",
          "frequency": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activityParticipants": [
          {
            "id": 11,
            "person": {
              "id": 11,
              "preferred_name": "Pradeepa"
            },
            "start_time": "2025-05-01",
            "end_time": "2025-05-05",
            "status": "Completed"
          },
          {
            "id": 12,
            "person": {
              "id": 12,
              "preferred_name": "Iresha"
            },
            "start_time": "2025-05-01",
            "end_time": "2025-05-05",
            "status": "Completed"
          }
        ],
        "financialInformation": {
          "id": 9,
          "estimatedCost": 2500,
          "totalCost": 2400,
          "materialCosts": [
            {
              "id": 11,
              "item": "Paint",
              "quantity": 20,
              "unit": "liter",
              "unitCost": 80
            },
            {
              "id": 12,
              "item": "Primer",
              "quantity": 10,
              "unit": "liter",
              "unitCost": 60
            }
          ],
          "labourCost": 800,
          "status": "Approved",
          "rejectionReason": null,
          "reviewedBy": null,
          "reviewedDate": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 10,
        "start_time": "2025-05-10",
        "end_time": "2025-05-12",
        "overallTaskStatus": "Completed",
        "maintenanceTask": {
          "id": 10,
          "title": "Paint Walls",
          "description": "Touch up paint work in common areas",
          "type": "Recurring",
          "frequency": "Quarterly",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activityParticipants": [
          {
            "id": 13,
            "person": {
              "id": 13,
              "preferred_name": "Pradeepa"
            },
            "start_time": "2025-05-10",
            "end_time": "2025-05-12",
            "status": "Completed"
          }
        ],
        "financialInformation": {
          "id": 10,
          "estimatedCost": 1800,
          "totalCost": 1750,
          "materialCosts": [
            {
              "id": 13,
              "item": "Wall Paint",
              "quantity": 15,
              "unit": "liter",
              "unitCost": 85
            }
          ],
          "labourCost": 475,
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
