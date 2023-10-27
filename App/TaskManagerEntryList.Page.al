page 50120 "Task Manager Entry List"
{
    ApplicationArea = All;
    Caption = 'Task Manager Entry List';
    PageType = List;
    SourceTable = "Task Manager Entry";
    SourceTableView = sorting(Id);
    UsageCategory = Lists;
    DelayedInsert = true;

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
                    var
                        TaskManagerEntryCard: Page "Task Manager Entry Card";
                    begin
                        Rec.SetRange(Id, Rec.Id);
                        TaskManagerEntryCard.SetTableView(Rec);
                        TaskManagerEntryCard.RunModal();
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
                Caption = 'Get All';
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
                    TaskManagerFunctions.ReadAllRequest();
                    Message('All tasks have been retrieved from the Task Manager API');
                    CurrPage.Update();
                end;
            }
            action(ClearBC)
            {
                ApplicationArea = All;
                Caption = 'Clear BC';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Deletes all tasks from BC';
                Image = AllLines;

                trigger OnAction()
                begin
                    Rec.DeleteAll();
                    Message('All tasks have been cleared from BC.');
                    CurrPage.Update();
                end;
            }
        }
    }
}
