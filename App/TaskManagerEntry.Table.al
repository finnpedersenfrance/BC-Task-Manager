namespace FinnPedersenFrance.Demo.TaskManagerAPI;

table 50120 "Task Manager Entry"
{
    Caption = 'Task Manager Entry';
    DataCaptionFields = Id, Title;
    DataClassification = ToBeClassified;
    DrillDownPageId = "Task Manager Entry Card";
    LookupPageId = "Task Manager Entry Card";
    TableType = Temporary;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            Editable = false;
        }
        field(2; Title; Text[100])
        {
            Caption = 'Title';
        }
        field(3; Description; Text[2048])
        {
            Caption = 'Description';
        }
        field(4; Urgency; Enum Urgency)
        {
            Caption = 'Urgency';
        }
        field(5; "Duration Minutes"; Integer)
        {
            Caption = 'Duration Minutes';
        }
        field(6; "Attention Date"; Date)
        {
            Caption = 'Attention Date';
        }
        field(7; Deadline; Date)
        {
            Caption = 'Deadline';
        }
        field(8; "Planned Date"; Date)
        {
            Caption = 'Planned Date';
        }
        field(9; "Planned Starting Time"; Time)
        {
            Caption = 'Planned Starting Time';
        }
        field(10; Status; Enum TaskStatus)
        {
            Caption = 'Status';
        }
        field(11; "Created At"; DateTime)
        {
            Caption = 'Created At';
            Editable = false;
        }
        field(12; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            Editable = false;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        TaskManagerAPI: Codeunit "Task Manager API";
    begin
        TaskManagerAPI.CreateOneRequest(Rec);
    end;

    trigger OnModify()
    var
        TaskManagerAPI: Codeunit "Task Manager API";
    begin
        TaskManagerAPI.UpdateOneRequest(Rec);
    end;

    trigger OnDelete()
    var
        TaskManagerAPI: Codeunit "Task Manager API";
    begin
        TaskManagerAPI.DeleteOneRequest(Rec.Id);
    end;
}
