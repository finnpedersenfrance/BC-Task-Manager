page 50120 "Task Manager Entry List"
{
    ApplicationArea = All;
    Caption = 'Task Manager Entry List';
    PageType = List;
    SourceTable = "Task Manager Entry";
    SourceTableView = sorting(Id) order(descending);
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

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Task Manager Entry Card", Rec);
                        CurrPage.Update();
                    end;
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
            action(GetAll)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Gets all tasks from the Task Manager API';
                Image = Refresh;
                trigger OnAction()
                var
                    TaskManagerFunctions: Codeunit "Task Manager API";
                begin
                    Rec.DeleteAll();
                    TaskManagerFunctions.ReadAllRequest(Rec);
                    Message('All tasks have been retrieved from the Task Manager API');
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        TaskManagerFunctions: Codeunit "Task Manager API";
    begin
        Rec.DeleteAll();
        TaskManagerFunctions.ReadAllRequest(Rec);
    end;

}
