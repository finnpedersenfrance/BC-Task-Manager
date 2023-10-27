table 50120 "Task Manager Entry"
{
    Caption = 'Task Manager Entry';
    DataClassification = ToBeClassified;
    LookupPageId = "Task Manager Entry Card";
    DrillDownPageId = "Task Manager Entry Card";

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
        field(4; Urgency; Option)
        {
            Caption = 'Urgency';
            OptionMembers = "Just do it","Plan it","Delegate it","Look at it later";
            OptionCaption = 'Just do it,Plan it,Delegate it,Look at it later';
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
        field(10; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = "Unplanned","Planned","Done","In the bin";
            OptionCaption = 'Unplanned,Planned,Done,In the bin';
        }

        field(11; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }
        field(12; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
        }

        field(50000; PrimaryKey; guid)
        {
            Caption = 'Primary Key';
            Editable = false;
        }
    }
    keys
    {
        key(PrimaryKey; PrimaryKey)
        {
            Clustered = true;
        }
        key(APIKey; Id)
        {
        }
    }

    trigger OnInsert()
    begin
        PrimaryKey := CreateGuid();
    end;
}
