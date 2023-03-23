curl -X POST -H "Content-Type: application/json" -d @test/avinya_type.json http://localhost:9090/avinya_types

curl -X POST http://localhost:9090/evaluations -H "Content-Type: application.json" -d @test/evaluation.json 

curl -X POST http://localhost:9090/evaluations -H "Content-Type: application/json"  -d "[{\"evaluatee_id\":1, \"evaluator_id\": 1 , \"evaluation_criteria_id\": 1 , \"activity_instance_id\": 145 , \"updated\": \"2022-01-01T00:00:00Z\" , \"response\": \"test 1\" , \"notes\": \"Test 1\" , \"grade\":32 , \"child_evaluations\":[1] , \"parent_evaluations\":[] } , {\"evaluatee_id\":1, \"evaluator_id\": 1 , \"evaluation_criteria_id\": 1 , \"activity_instance_id\": 145 , \"updated\": \"2022-01-01T00:00:00Z\" , \"response\": \"test 2\" , \"notes\": \"Test 2\" , \"grade\":32 , \"child_evaluations\":[1] , \"parent_evaluations\":[] }]"

curl http://localhost:9090/evaluation/72
curl http://localhost:9090/all_evaluations

curl http://localhost:9090/evaluation_criterias

curl http://localhost:9090/pcti_evaluation/1

curl -X POST http://localhost:9090/pcti_evaluation -H "Content-Type: application.json" -d @test/pctievaluation.json 


curl http://localhost:9090/evaluation_meta_data/72

curl -X POST http://localhost:9090/evaluations -H "Content-Type: application.json" -d @test/evaluation.json 

curl -X POST http://localhost:9090/add_evaluation_meta_data -H "Content-Type: application.json" -d @test/metadata.json 


curl -X POST -H "Content-Type: application/json" -d @evaluation.json http://localhost:9090/avinya_types

curl -X POST http://localhost:9090/add_evaluation_cycle -H "Content-Type: application.json" -d @test/evaluation_cycle.json 

curl -X POST http://localhost:9090/education_experience -H "Content-Type: application.json" -d @test/education_experience.json 

curl -X POST http://localhost:9090/work_experience -H "Content-Type: application.json" -d @test/work_experience.json 

curl http://localhost:9090/evaluation_criteria/1/prompt

curl -X POST http://localhost:9090/evaluation_criteria -H "Content-Type: application.json" -d @test/evaluation_criteria.json 

curl -X POST http://localhost:9090/evaluation_answer_option -H "Content-Type: application.json" -d @test/answer_option.json 
