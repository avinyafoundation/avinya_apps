curl -X POST -H "Content-Type: application/json" -d @avinya_type.json http://localhost:9091/avinya_types
curl -X POST -H "Content-Type: application/json" -d @activity_attendance.json http://localhost:9091/activity_attendance

curl http://localhost:9091/avinya_types

curl -X PUT -H "Content-Type: application/json" -d @avinya_type.json http://localhost:9091/avinya_types 

curl http://localhost:9091/avinya_types

curl -X DELETE  http://localhost:9091/avinya_types/76
