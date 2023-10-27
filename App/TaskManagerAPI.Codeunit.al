codeunit 50120 "Task Manager API"
{
    local procedure APIUrl(Id: Integer): Text
    begin
        if Id < 0 then
            Error('Invalid ID: %1', Id);
        if Id = 0 then
            exit('https://taskmanager02-api-c6207da5113d.herokuapp.com/tasks')
        else
            exit('https://taskmanager02-api-c6207da5113d.herokuapp.com/tasks/' + Format(Id));
    end;


    procedure ReadAllRequest()
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        TextResponse: Text;
        ErrorMessage: Text;
    begin
        RequestMessage.Method := 'GET';
        RequestUrl := APIUrl(0);
        RequestMessage.SetRequestUri(RequestUrl);

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if ResponseMessage.HttpStatusCode() = HttpStatusCodeOK() then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessGetAllResult(TextResponse);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    procedure ReadOneRequest(Id: Integer)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        TextResponse: Text;
        ErrorMessage: Text;

    begin
        RequestMessage.Method := 'GET';
        RequestUrl := APIUrl(Id);
        RequestMessage.SetRequestUri(RequestUrl);

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if ResponseMessage.HttpStatusCode() = HttpStatusCodeOK() then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessGetOneResult(TextResponse, Id);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    procedure UpdateOneRequest(TaskManagerEntry: Record "Task Manager Entry")
    var
        Document: JsonObject;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        TextJson: Text;
        RequestUrl: Text;
        TextResponse: Text;
        ErrorMessage: Text;
        Id: Integer;

    begin
        if TaskManagerEntry.id = 0 then
            exit;
        EncodeTaskObject(TaskManagerEntry, Document);
        Document.WriteTo(TextJson);
        Message('Update: %1', TextJson);
        RequestMessage.Method := 'PATCH';

        RequestUrl := APIUrl(TaskManagerEntry.Id);
        RequestMessage.SetRequestUri(RequestUrl);

        Content.WriteFrom(TextJson);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        RequestMessage.Content := Content;

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if ResponseMessage.HttpStatusCode() = HttpStatusCodeOK() then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessGetOneResult(TextResponse, Id);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    procedure CreateOneRequest(TaskManagerEntry: Record "Task Manager Entry"; var Id: Integer)
    var
        Document: JsonObject;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        TextJson: Text;
        RequestUrl: Text;
        TextResponse: Text;
        ErrorMessage: Text;
    begin
        EncodeTaskObject(TaskManagerEntry, Document);
        Document.WriteTo(TextJson);
        Message('Create: %1', TextJson);
        RequestMessage.Method := 'POST';
        RequestUrl := APIUrl(TaskManagerEntry.Id);
        RequestMessage.SetRequestUri(RequestUrl);

        Content.WriteFrom(TextJson);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        RequestMessage.Content := Content;

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if ResponseMessage.HttpStatusCode() = HttpStatusCodeCreated() then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessGetOneResult(TextResponse, Id);
                ReadOneRequest(Id);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    procedure DeleteOneRequest(Id: Integer)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        ErrorMessage: Text;

    begin
        RequestMessage.Method := 'DELETE';
        RequestUrl := APIUrl(Id);
        RequestMessage.SetRequestUri(RequestUrl);

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if not (ResponseMessage.HttpStatusCode() in [HttpStatusCodeNoContent(), HttpStatusCodeNotFound()]) then begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    local procedure ProcessGetAllResult(TextResponse: Text)
    var
        TaskList: JsonArray;
    begin
        if not TaskList.ReadFrom(TextResponse) then
            error('Invalid JSON ARRAY response.');

        DecodeTaskArray(TaskList);
    end;

    local procedure DecodeTaskArray(TaskList: JsonArray)
    var
        TaskManagerEntry: Record "Task Manager Entry";
        Token: JsonToken;
        TaskObject: JsonObject;
    begin
        TaskManagerEntry.DeleteAll();
        TaskManagerEntry.Reset();
        foreach Token in TaskList do begin
            TaskObject := Token.AsObject();
            DecodeTaskObject(TaskObject, TaskManagerEntry);
            TaskManagerEntry.Insert(true);
        end;
    end;

    local procedure ProcessGetOneResult(TextResponse: Text; var Id: Integer)
    var
        NewTaskManagerEntry: Record "Task Manager Entry";
        CurrentTaskManagerEntry: Record "Task Manager Entry";
        TaskObject: JsonObject;
    begin
        if not TaskObject.ReadFrom(TextResponse) then
            error('Invalid JSON OBJECT response.');

        DecodeTaskObject(TaskObject, NewTaskManagerEntry);
        CurrentTaskManagerEntry.SetCurrentKey(Id);
        CurrentTaskManagerEntry.SetRange(Id, NewTaskManagerEntry.Id);
        if CurrentTaskManagerEntry.FindFirst() then begin
            CurrentTaskManagerEntry.id := NewTaskManagerEntry.id;
            CurrentTaskManagerEntry.TransferFields(NewTaskManagerEntry, false);
            if CurrentTaskManagerEntry.Modify() then;
        end else begin
            CurrentTaskManagerEntry.Init();
            CurrentTaskManagerEntry.id := NewTaskManagerEntry.id;
            CurrentTaskManagerEntry.TransferFields(NewTaskManagerEntry);
            CurrentTaskManagerEntry.Insert(true);
        end;
        Id := CurrentTaskManagerEntry.Id;
    end;

    local procedure DecodeTaskObject(TaskObject: JsonObject; var TaskManagerEntry: Record "Task Manager Entry")
    var
        IdField: JsonToken;
        TitleField: JsonToken;
        DescriptionField: JsonToken;
        UrgencyField: JsonToken;
        DurationField: JsonToken;
        AttentionDateField: JsonToken;
        DeadlineField: JsonToken;
        PlannedDateField: JsonToken;
        PlannedStartingTimeField: JsonToken;
        StatusField: JsonToken;
        CreatedDateField: JsonToken;
        UpdatedDateField: JsonToken;
    begin
        TaskManagerEntry.Init();

        if TaskObject.Get('id', IdField) then
            if not IdField.AsValue().IsNull then
                TaskManagerEntry.Id := IdField.AsValue().AsInteger();

        if TaskObject.Get('title', TitleField) then
            if not TitleField.AsValue().IsNull then
                TaskManagerEntry.Title := CopyStr(TitleField.AsValue().AsText(), 1, 100);

        if TaskObject.Get('description', DescriptionField) then
            if not DescriptionField.AsValue().IsNull then
                TaskManagerEntry.Description := CopyStr(DescriptionField.AsValue().AsText(), 1, 2048);

        if TaskObject.Get('urgency', UrgencyField) then
            if not UrgencyField.AsValue().IsNull then
                TaskManagerEntry.Urgency := UrgencyField.AsValue().AsInteger();

        if TaskObject.Get('duration_minutes', DurationField) then
            if not DurationField.AsValue().IsNull then
                TaskManagerEntry."Duration Minutes" := DurationField.AsValue().AsInteger();

        if TaskObject.Get('attention_date', AttentionDateField) then
            if not AttentionDateField.AsValue().IsNull then
                TaskManagerEntry."Attention Date" := AttentionDateField.AsValue().AsDate();

        if TaskObject.Get('deadline', DeadlineField) then
            if not DeadlineField.AsValue().IsNull then
                TaskManagerEntry.Deadline := DeadlineField.AsValue().AsDate();

        if TaskObject.Get('planned_date', PlannedDateField) then
            if not PlannedDateField.AsValue().IsNull then
                TaskManagerEntry."Planned Date" := PlannedDateField.AsValue().AsDate();

        if TaskObject.Get('planned_starting_time', PlannedStartingTimeField) then
            if not PlannedStartingTimeField.AsValue().IsNull then
                TaskManagerEntry."Planned Starting Time" := System.DT2Time(PlannedStartingTimeField.AsValue().AsDateTime());

        if TaskObject.Get('status', StatusField) then
            if not StatusField.AsValue().IsNull then
                TaskManagerEntry.Status := StatusField.AsValue().AsInteger();

        if TaskObject.Get('created_date', CreatedDateField) then
            if not CreatedDateField.AsValue().IsNull then
                TaskManagerEntry."Created At" := CreatedDateField.AsValue().AsDateTime();

        if TaskObject.Get('updated_date', UpdatedDateField) then
            if not UpdatedDateField.AsValue().IsNull then
                TaskManagerEntry."Updated At" := UpdatedDateField.AsValue().AsDateTime();
    end;

    local procedure EncodeTaskObject(TaskManagerEntry: Record "Task Manager Entry"; var TaskObject: JsonObject)
    var
        TimeAsDateTime: DateTime;
    begin
        if TaskManagerEntry.Id > 0 then
            TaskObject.Add('id', TaskManagerEntry.Id);
        TaskObject.Add('title', TaskManagerEntry.Title);
        if TaskManagerEntry.Description <> '' then
            TaskObject.Add('description', TaskManagerEntry.Description);
        TaskObject.Add('urgency', TaskManagerEntry.Urgency);
        TaskObject.Add('duration_minutes', TaskManagerEntry."Duration Minutes");
        TaskObject.Add('attention_date', TaskManagerEntry."Attention Date");
        TaskObject.Add('deadline', TaskManagerEntry.Deadline);
        TaskObject.Add('planned_date', TaskManagerEntry."Planned Date");
        TimeAsDateTime := CreateDateTime(TaskManagerEntry."Planned Date", TaskManagerEntry."Planned Starting Time");
        TaskObject.Add('planned_starting_time', TimeAsDateTime);
        TaskObject.Add('status', TaskManagerEntry.Status);
    end;

    local procedure HttpStatusCodeOK(): Integer
    begin
        exit(200);
    end;

    local procedure HttpStatusCodeCreated(): Integer
    begin
        exit(201);
    end;

    local procedure HttpStatusCodeNoContent(): Integer
    begin
        exit(204);
    end;

    local procedure HttpStatusCodeNotFound(): Integer
    begin
        exit(404);
    end;

}
