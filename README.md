# Task Manager API


// https://taskmanager02-api-c6207da5113d.herokuapp.com/tasks


````json
{
    "id": 1,
    "title": "Jim Sox",
    "description": "If we navigate the capacitor, we can get to the COM application through the neural PCI card!",
    "urgency": 3,
    "duration_minutes": 45,
    "attention_date": "2023-09-29",
    "deadline": "2023-10-02",
    "planned_date": "2023-09-29",
    "planned_starting_time": "2000-01-01T20:30:00.000Z",
    "status": 3,
    "created_at": "2023-09-29T06:02:59.203Z",
    "updated_at": "2023-09-29T06:02:59.203Z"
},
````


````elm
    case urgency of
        0 ->
            "Just do it"

        1 ->
            "Plan it"

        2 ->
            "Delegate it"

        3 ->
            "Look at it later"

        _ ->
            "unknown urgency"
````

````elm
    case status of
        0 ->
            "Unplanned"

        1 ->
            "Planned"

        2 ->
            "Done"

        3 ->
            "In the bin"

        _ ->
            "unknown status"
````
