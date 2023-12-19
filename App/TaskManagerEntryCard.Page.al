namespace FinnPedersenFrance.Demo.TaskManagerAPI;

page 50121 "Task Manager Entry Card"
{
    ApplicationArea = All;
    Caption = 'Task Manager Entry Card';
    PageType = Card;
    SourceTable = "Task Manager Entry";
    UsageCategory = None;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field.';
                }
                field(Title; Rec.Title)
                {
                    ToolTip = 'Specifies the value of the Title field.';
                }
                field(Urgency; Rec.Urgency)
                {
                    ToolTip = 'Specifies the value of the Urgency field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Attention Date"; Rec."Attention Date")
                {
                    ToolTip = 'Specifies the value of the Attention Date field.';
                }
                field(Deadline; Rec.Deadline)
                {
                    ToolTip = 'Specifies the value of the Deadline field.';
                }
                field("Duration Minutes"; Rec."Duration Minutes")
                {
                    ToolTip = 'Specifies the value of the Duration Minutes field.';
                }
            }
            group(Details)
            {
                Caption = 'Details';

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    MultiLine = true;
                }
                field("Planned Date"; Rec."Planned Date")
                {
                    ToolTip = 'Specifies the value of the Planned Date field.';
                }
                field("Planned Starting Time"; Rec."Planned Starting Time")
                {
                    ToolTip = 'Specifies the value of the Planned Starting Time field.';
                }
            }
            group(System)
            {
                Caption = 'System';

                field("Updated At"; Rec."Updated At")
                {
                    ToolTip = 'Specifies when the entry was last updated.';
                }
                field("Created At"; Rec."Created At")
                {
                    ToolTip = 'Specifies when the entry was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Gets all tasks from the Task Manager API.';
                Image = Refresh;
                trigger OnAction()
                var
                    TaskManagerFunctions: Codeunit "Task Manager API";
                begin
                    TaskManagerFunctions.ReadOneRequest(Rec.id, Rec);
                    Message('The task %1 has been retrieved from the Task Manager API.', Rec.id);
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        TaskManagerAPI: Codeunit "Task Manager API";
    begin
        if Rec.Id > 0 then begin
            TaskManagerAPI.ReadOneRequest(Rec.id, Rec);
            CurrPage.Update();
        end;
    end;

}
