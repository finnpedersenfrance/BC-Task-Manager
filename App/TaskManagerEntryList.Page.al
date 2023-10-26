page 50120 "Task Manager Entry List"
{
    ApplicationArea = All;
    Caption = 'Task Manager Entry List';
    PageType = List;
    SourceTable = "Task Manager Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field.';
                }
                field(Title; Rec.Title)
                {
                    ToolTip = 'Specifies the value of the Title field.';
                }
                field("Attention Date"; Rec."Attention Date")
                {
                    ToolTip = 'Specifies the value of the Attention Date field.';
                }
                field(Deadline; Rec.Deadline)
                {
                    ToolTip = 'Specifies the value of the Deadline field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field(Urgency; Rec.Urgency)
                {
                    ToolTip = 'Specifies the value of the Urgency field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetOne)
            {
                ApplicationArea = All;
                Caption = 'One';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Gets one task from the Task Manager API';
                Image = GetLines;

                trigger OnAction()
                var
                    TaskManagerFunctions: Codeunit "Task Manager API";
                begin
                    TaskManagerFunctions.GetRequest(1);
                end;
            }
            action(GetAll)
            {
                ApplicationArea = All;
                Caption = 'All';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Gets all tasks from the Task Manager API';
                Image = AllLines;

                trigger OnAction()
                var
                    TaskManagerFunctions: Codeunit "Task Manager API";
                begin
                    TaskManagerFunctions.GetRequest(0);
                end;
            }
        }
    }
}
