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
        "overall_task_status": "Pending",
        "task": {
          "id": 1,
          "title": "Air Conditioner Maintenance",
          "description": "Routine AC inspection and cleaning",
          "task_type": "Recurring",
          "frequency": "Monthly",
          "exception_deadline": 2,
          "location": {
            "id": 12,
            "location_name": "Pod 1"
          }
        },
        "activity_participants": [
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
        "overall_task_status": "In Progress",
        "task": {
          "id": 2,
          "title": "Air Conditioner Repair",
          "description": "Fix temperature control issue",
          "task_type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 14,
            "location_name": "Building A - Floor 2"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 1,
          "estimated_cost": 1500,
          "total_cost": 2000,
          "material_costs": [
            {
              "id": 1,
              "item": "Air Filter",
              "quantity": 5,
              "unit": "piece",
              "unit_cost": 100
            },
            {
              "id": 2,
              "item": "Coolant",
              "quantity": 2,
              "unit": "liter",
              "unit_cost": 250
            }
          ],
          "labour_cost": 500,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 3,
        "start_time": "2025-02-01",
        "end_time": "2025-02-05",
        "overall_task_status": "Pending",
        "task": {
          "id": 3,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "task_type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 15,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 3,
          "estimated_cost": 500,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 3,
              "item": "LED Bulbs",
              "quantity": 3,
              "unit": "piece",
              "unit_cost": 50
            }
          ],
          "labour_cost": 350,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 4,
        "start_time": "2025-02-10",
        "end_time": "2025-02-12",
        "overall_task_status": "Pending",
        "task": {
          "id": 4,
          "title": "Clean Lab",
          "description": "Deep cleaning of laboratory facilities",
          "task_type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 13,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 4,
          "estimated_cost": 800,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 4,
              "item": "Cleaning Supplies",
              "quantity": 10,
              "unit": "piece",
              "unit_cost": 40
            }
          ],
          "labour_cost": 400,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 5,
        "start_time": "2025-03-01",
        "end_time": "2025-03-03",
        "overall_task_status": "Pending",
        "task": {
          "id": 5,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "task_type": "oneTime",
          "frequency": null,
          "location": {
            "id": 12,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 5,
          "estimated_cost": 450,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 5,
              "item": "Fluorescent Tubes",
              "quantity": 3,
              "unit": "piece",
              "unit_cost": 60
            }
          ],
          "labour_cost": 270,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 6,
        "start_time": "2025-03-15",
        "end_time": "2025-03-18",
        "overall_task_status": "Pending",
        "task": {
          "id": 6,
          "title": "Clean Lab",
          "description": "Regular maintenance cleaning of laboratory spaces",
          "task_type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 15,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 6,
          "estimated_cost": 950,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 6,
              "item": "Disinfectant",
              "quantity": 5,
              "unit": "liter",
              "unit_cost": 80
            },
            {
              "id": 7,
              "item": "Floor Cleaner",
              "quantity": 3,
              "unit": "liter",
              "unit_cost": 50
            }
          ],
          "labour_cost": 500,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 7,
        "start_time": "2025-04-01",
        "end_time": "2025-04-05",
        "overall_task_status": "In Progress",
        "task": {
          "id": 7,
          "title": "Clean Lab",
          "description": "Comprehensive cleaning of all lab equipment",
          "task_type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 7,
          "estimated_cost": 700,
          "total_cost": 650,
          "material_costs": [
            {
              "id": 8,
              "item": "Cleaning Kit",
              "quantity": 2,
              "unit": "piece",
              "unit_cost": 125
            }
          ],
          "labour_cost": 400,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 8,
        "start_time": "2025-04-10",
        "end_time": "2025-04-15",
        "overall_task_status": "In Progress",
        "task": {
          "id": 8,
          "title": "Fix Lights",
          "description": "Emergency lighting system repair",
          "task_type": "oneTime",
          "frequency": null,
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 8,
          "estimated_cost": 1200,
          "total_cost": 1150,
          "material_costs": [
            {
              "id": 9,
              "item": "Emergency Lights",
              "quantity": 4,
              "unit": "piece",
              "unit_cost": 180
            },
            {
              "id": 10,
              "item": "Wiring",
              "quantity": 50,
              "unit": "piece",
              "unit_cost": 5
            }
          ],
          "labour_cost": 630,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 9,
        "start_time": "2025-05-01",
        "end_time": "2025-05-05",
        "overall_task_status": "Completed",
        "task": {
          "id": 9,
          "title": "Paint Walls",
          "description": "Repaint interior walls with fresh coat",
          "task_type": "oneTime",
          "frequency": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 9,
          "estimated_cost": 2500,
          "total_cost": 2400,
          "material_costs": [
            {
              "id": 11,
              "item": "Paint",
              "quantity": 20,
              "unit": "liter",
              "unit_cost": 80
            },
            {
              "id": 12,
              "item": "Primer",
              "quantity": 10,
              "unit": "liter",
              "unit_cost": 60
            }
          ],
          "labour_cost": 800,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 10,
        "start_time": "2025-05-10",
        "end_time": "2025-05-12",
        "overall_task_status": "Completed",
        "task": {
          "id": 10,
          "title": "Paint Walls",
          "description": "Touch up paint work in common areas",
          "task_type": "Recurring",
          "frequency": "Quarterly",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 10,
          "estimated_cost": 1800,
          "total_cost": 1750,
          "material_costs": [
            {
              "id": 13,
              "item": "Wall Paint",
              "quantity": 15,
              "unit": "liter",
              "unit_cost": 85
            }
          ],
          "labour_cost": 475,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
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
        "overall_task_status": "In Progress",
        "task": {
          "id": 44,
          "title": "Air Conditioner Maintenance",
          "description": "Perform routine maintenance of air conditioners.",
          "location": {
            "id": 3,
            "location_name": "Main Building - Floor 2"
          }
        },
        "overdue_days": 5,
        "activity_participants": [
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
        "overall_task_status": "In Progress",
        "task": {
          "id": 44,
          "title": "Fix Lights",
          "description": "Replace faulty lights in the main corridor.",
          "location": {
            "id": 3,
            "location_name": "Main Building - Floor 2"
          }
        },
        "overdue_days": 5,
        "activity_participants": [
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
        "overall_task_status": "Pending",
        "task": {
          "id": 45,
          "title": "Clean Lab",
          "description": "Deep cleaning of laboratory facilities",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "overdue_days": 7,
        "activity_participants": [
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
        "overall_task_status": "Pending",
        "task": {
          "id": 46,
          "title": "Paint Walls",
          "description": "Touch up paint work in common areas",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "overdue_days": 3,
        "activity_participants": [
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
        "overall_task_status": "In Progress",
        "task": {
          "id": 47,
          "title": "Air Conditioner Repair",
          "description": "Fix temperature control issue",
          "location": {
            "id": 1,
            "location_name": "Building A - Floor 2"
          }
        },
        "overdue_days": 10,
        "activity_participants": [
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
  "monthlyCostSummary": {
    "year": 2025,
    "monthly_costs": [
      {
        "month": 1,
        "estimated_cost": 45000,
        "actual_cost": 42000
      },
      {
        "month": 2,
        "estimated_cost": 52000,
        "actual_cost": 48000
      },
      {
        "month": 3,
        "estimated_cost": 58000,
        "actual_cost": 55000
      },
      {
        "month": 4,
        "estimated_cost": 65000,
        "actual_cost": 62000
      },
      {
        "month": 5,
        "estimated_cost": 72000,
        "actual_cost": 74000
      },
      {
        "month": 6,
        "estimated_cost": 80000,
        "actual_cost": 83000
      },
      {
        "month": 7,
        "estimated_cost": 88000,
        "actual_cost": 85000
      },
      {
        "month": 8,
        "estimated_cost": 92000,
        "actual_cost": 90000
      },
      {
        "month": 9,
        "estimated_cost": 85000,
        "actual_cost": 82000
      },
      {
        "month": 10,
        "estimated_cost": 78000,
        "actual_cost": 75000
      },
      {
        "month": 11,
        "estimated_cost": 70000,
        "actual_cost": 68000
      },
      {
        "month": 12,
        "estimated_cost": 62000,
        "actual_cost": 59000
      }
    ]
  }
}
''';

const String directorDashboardSummaryJson = '''
{
  "monthlyMaintenanceReport": {
    "totalTasks": 10,
    "completedTasks": 2,
    "inProgressTasks": 3,
    "pendingTasks": 5,
    "totalCost": 175000.5,
    "totalUpcomingTasks": 5,
    "nextMonthlyEstimatedCost": 20000.0
  }
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
        "overall_task_status": "Pending",
        "task": {
          "id": 1,
          "title": "Air Conditioner Maintenance",
          "description": "Routine AC inspection and cleaning",
          "task_type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 1,
            "location_name": "Pod 1"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 1,
          "estimated_cost": 1500,
          "total_cost": 1400,
          "material_costs": [
            {
              "id": 1,
              "item": "Air Filter",
              "quantity": 5,
              "unit": "piece",
              "unit_cost": 100
            },
            {
              "id": 2,
              "item": "Coolant",
              "quantity": 2,
              "unit": "liter",
              "unit_cost": 250
            }
          ],
          "labour_cost": 500,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 3,
        "start_time": "2025-02-01",
        "end_time": "2025-02-05",
        "overall_task_status": "Pending",
        "task": {
          "id": 3,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "task_type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 3,
          "estimated_cost": 500,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 3,
              "item": "LED Bulbs",
              "quantity": 3,
              "unit": "piece",
              "unit_cost": 50
            }
          ],
          "labour_cost": 350,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 4,
        "start_time": "2025-02-10",
        "end_time": "2025-02-12",
        "overall_task_status": "Pending",
        "task": {
          "id": 4,
          "title": "Clean Lab",
          "description": "Deep cleaning of laboratory facilities",
          "task_type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 4,
          "estimated_cost": 800,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 4,
              "item": "Cleaning Supplies",
              "quantity": 10,
              "unit": "piece",
              "unit_cost": 40
            }
          ],
          "labour_cost": 400,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 5,
        "start_time": "2025-03-01",
        "end_time": "2025-03-03",
        "overall_task_status": "Pending",
        "task": {
          "id": 5,
          "title": "Fix Lights",
          "description": "Replace the 3 bulbs in the main corridor.",
          "task_type": "oneTime",
          "frequency": null,
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 5,
          "estimated_cost": 450,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 5,
              "item": "Fluorescent Tubes",
              "quantity": 3,
              "unit": "piece",
              "unit_cost": 60
            }
          ],
          "labour_cost": 270,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 6,
        "start_time": "2025-03-15",
        "end_time": "2025-03-18",
        "overall_task_status": "Pending",
        "task": {
          "id": 6,
          "title": "Clean Lab",
          "description": "Regular maintenance cleaning of laboratory spaces",
          "task_type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 6,
          "estimated_cost": 950,
          "total_cost": 0,
          "material_costs": [
            {
              "id": 6,
              "item": "Disinfectant",
              "quantity": 5,
              "unit": "liter",
              "unit_cost": 80
            },
            {
              "id": 7,
              "item": "Floor Cleaner",
              "quantity": 3,
              "unit": "liter",
              "unit_cost": 50
            }
          ],
          "labour_cost": 500,
          "status": "Pending",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
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
        "overall_task_status": "In Progress",
        "task": {
          "id": 2,
          "title": "Air Conditioner Repair",
          "description": "Fix temperature control issue",
          "task_type": "Recurring",
          "frequency": "Monthly",
          "location": {
            "id": 1,
            "location_name": "Building A - Floor 2"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 1,
          "estimated_cost": 1500,
          "total_cost": 2000,
          "material_costs": [
            {
              "id": 1,
              "item": "Air Filter",
              "quantity": 5,
              "unit": "piece",
              "unit_cost": 100
            },
            {
              "id": 2,
              "item": "Coolant",
              "quantity": 2,
              "unit": "liter",
              "unit_cost": 250
            }
          ],
          "labour_cost": 500,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 7,
        "start_time": "2025-04-01",
        "end_time": "2025-04-05",
        "overall_task_status": "In Progress",
        "task": {
          "id": 7,
          "title": "Clean Lab",
          "description": "Comprehensive cleaning of all lab equipment",
          "task_type": "Recurring",
          "frequency": "Weekly",
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 7,
          "estimated_cost": 700,
          "total_cost": 650,
          "material_costs": [
            {
              "id": 8,
              "item": "Cleaning Kit",
              "quantity": 2,
              "unit": "piece",
              "unit_cost": 125
            }
          ],
          "labour_cost": 400,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 8,
        "start_time": "2025-04-10",
        "end_time": "2025-04-15",
        "overall_task_status": "In Progress",
        "task": {
          "id": 8,
          "title": "Fix Lights",
          "description": "Emergency lighting system repair",
          "task_type": "oneTime",
          "frequency": null,
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 8,
          "estimated_cost": 1200,
          "total_cost": 1150,
          "material_costs": [
            {
              "id": 9,
              "item": "Emergency Lights",
              "quantity": 4,
              "unit": "piece",
              "unit_cost": 180
            },
            {
              "id": 10,
              "item": "Wiring",
              "quantity": 50,
              "unit": "piece",
              "unit_cost": 5
            }
          ],
          "labour_cost": 630,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
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
        "overall_task_status": "Completed",
        "task": {
          "id": 9,
          "title": "Paint Walls",
          "description": "Repaint interior walls with fresh coat",
          "task_type": "oneTime",
          "frequency": null,
          "location": {
            "id": 1,
            "location_name": "IT Lab"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 9,
          "estimated_cost": 2500,
          "total_cost": 2400,
          "material_costs": [
            {
              "id": 11,
              "item": "Paint",
              "quantity": 20,
              "unit": "liter",
              "unit_cost": 80
            },
            {
              "id": 12,
              "item": "Primer",
              "quantity": 10,
              "unit": "liter",
              "unit_cost": 60
            }
          ],
          "labour_cost": 800,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    },
    {
      "activityInstance": {
        "id": 10,
        "start_time": "2025-05-10",
        "end_time": "2025-05-12",
        "overall_task_status": "Completed",
        "task": {
          "id": 10,
          "title": "Paint Walls",
          "description": "Touch up paint work in common areas",
          "task_type": "Recurring",
          "frequency": "Quarterly",
          "location": {
            "id": 2,
            "location_name": "Main Hall"
          }
        },
        "activity_participants": [
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
        "finance": {
          "id": 10,
          "estimated_cost": 1800,
          "total_cost": 1750,
          "material_costs": [
            {
              "id": 13,
              "item": "Wall Paint",
              "quantity": 15,
              "unit": "liter",
              "unit_cost": 85
            }
          ],
          "labour_cost": 475,
          "status": "Approved",
          "rejection_reason": null,
          "reviewed_by": null,
          "reviewed_date": null
        }
      }
    }
  ]
}
''';

// GET /organizations/{organizationId}/tasks (With financial status pending query parameter)
const String pendingFinancialTasksJson = '''
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
        "finance": {
          "id": 1,
          "estimated_cost": 1500,
          "totalCost": 1400,
          "materialCosts": [
            {
              "id": 1,
              "item": "Air Filter",
              "quantity": 5,
              "unit": "piece",
              "unit_cost": 100
            },
            {
              "id": 2,
              "item": "Coolant",
              "quantity": 2,
              "unit": "liter",
              "unit_cost": 250
            }
          ],
          "labour_cost": 500,
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
        "finance": {
          "id": 3,
          "estimated_cost": 500,
          "totalCost": 0,
          "materialCosts": [
            {
              "id": 3,
              "item": "LED Bulbs",
              "quantity": 3,
              "unit": "piece",
              "unit_cost": 50
            }
          ],
          "labour_cost": 350,
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
