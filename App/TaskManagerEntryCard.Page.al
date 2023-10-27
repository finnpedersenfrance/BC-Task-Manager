page 50121 "Task Manager Entry Card"
{
    ApplicationArea = All;
    Caption = 'Task Manager Entry Card';
    PageType = Card;
    SourceTable = "Task Manager Entry";
    UsageCategory = None;
    DelayedInsert = true;
    DataCaptionFields = Id, Title;

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
        }
    }

    actions
    {
        area(Processing)
        {
            action(Create)
            {
                ApplicationArea = All;
                Caption = 'Create';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Creates the task in the Task Manager API';
                Image = NewDocument;

                trigger OnAction()
                var
                    TaskManagerEntry: Record "Task Manager Entry";
                    TaskManagerFunctions: Codeunit "Task Manager API";
                    Id: Integer;
                begin
                    if Rec.id = 0 then begin
                        TaskManagerFunctions.CreateOneRequest(Rec, Id);
                        TaskManagerEntry.SetCurrentKey(Id);
                        TaskManagerEntry.SetRange(Id, Id);
                        if TaskManagerEntry.FindFirst() then begin
                            CurrPage.SetRecord(TaskManagerEntry);
                            CurrPage.Update();
                            Message('Task created with id %1', Rec.id);
                        end else
                            Message('Task %1 not found.', Rec.id)
                    end else
                        Message('Task %1 already exists. Choose Update.', Rec.id);
                end;
            }
            action(Modify)
            {
                ApplicationArea = All;
                Caption = 'Modify';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Updates the task in the Task Manager API';
                Image = UpdateXML;

                trigger OnAction()
                var
                    TaskManagerEntry: Record "Task Manager Entry";
                    TaskManagerFunctions: Codeunit "Task Manager API";
                begin
                    if Rec.id > 0 then begin
                        TaskManagerFunctions.UpdateOneRequest(Rec);
                        TaskManagerEntry.SetCurrentKey(Id);
                        TaskManagerEntry.SetRange(Id, Rec.id);
                        if TaskManagerEntry.FindFirst() then begin
                            TaskManagerEntry.Get(Rec.Id);
                            CurrPage.SetRecord(TaskManagerEntry);
                            CurrPage.Update();
                            Message('Task %1 updated.', Rec.id);
                        end else
                            Message('Task %1 not found.', Rec.id)
                    end else
                        Message('Task %1 does not exist. Choose Create.', Rec.id);
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Deletes the task from the Task Manager API';
                Image = DeleteXML;

                trigger OnAction()
                var
                    TaskManagerFunctions: Codeunit "Task Manager API";
                begin
                    TaskManagerFunctions.DeleteOneRequest(Rec.id);
                    Rec.Delete();
                    Message('Task deleted.');
                end;
            }
        }

    }
}
