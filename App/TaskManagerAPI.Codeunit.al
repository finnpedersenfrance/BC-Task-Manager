namespace FinnPedersenFrance.Demo.TaskManagerAPI;

codeunit 50120 "Task Manager API"
{
    /* CRUD operations on the Task Manager API
        C: Create
        R: Read
        U: Update
        D: Delete
    */

    procedure CreateOneRequest(var TaskManagerEntry: Record "Task Manager Entry")
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Document: JsonObject;
        RequestUrl: Text;
        TextJson: Text;
        TextResponse: Text;
    begin
        EncodeTaskObject(TaskManagerEntry, Document);
        Document.WriteTo(TextJson);
        HttpRequestMessage.Method := 'POST';
        RequestUrl := APIUrl(0);
        HttpRequestMessage.SetRequestUri(RequestUrl);

        HttpContent.WriteFrom(TextJson);
        HttpContent.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content := HttpContent;

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode() = HttpStatusCodeCreated() then begin
                HttpResponseMessage.Content().ReadAs(TextResponse);
                ProcessJsonObjectResult(TextResponse, TaskManagerEntry);
            end else
                WebServiceCallFailedError(HttpResponseMessage.HttpStatusCode());
        end else
            ConnectionError();
    end;

    procedure ReadAllRequest(var TaskManagerEntry: Record "Task Manager Entry")
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        TextResponse: Text;
    begin
        HttpRequestMessage.Method := 'GET';
        RequestUrl := APIUrl(0);
        HttpRequestMessage.SetRequestUri(RequestUrl);

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode() = HttpStatusCodeOK() then begin
                HttpResponseMessage.Content().ReadAs(TextResponse);
                ProcessJsonArrayResult(TextResponse, TaskManagerEntry);
            end else
                WebServiceCallFailedError(HttpResponseMessage.HttpStatusCode());
        end else
            ConnectionError();
    end;

    procedure ReadOneRequest(EntryId: Integer; var TaskManagerEntry: Record "Task Manager Entry")
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        TextResponse: Text;
    begin
        if EntryId = 0 then
            Error('ReadOneRequest was called with id = 0. The Id must be a possitive integer.');
        HttpRequestMessage.Method := 'GET';
        RequestUrl := APIUrl(EntryId);
        HttpRequestMessage.SetRequestUri(RequestUrl);

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode() = HttpStatusCodeOK() then begin
                HttpResponseMessage.Content().ReadAs(TextResponse);
                ProcessJsonObjectResult(TextResponse, TaskManagerEntry);
            end else
                WebServiceCallFailedError(HttpResponseMessage.HttpStatusCode());
        end else
            ConnectionError();
    end;

    procedure UpdateOneRequest(var TaskManagerEntry: Record "Task Manager Entry")
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Document: JsonObject;
        RequestUrl: Text;
        TextJson: Text;
        TextResponse: Text;
    begin
        if TaskManagerEntry.Id = 0 then
            exit;
        EncodeTaskObject(TaskManagerEntry, Document);
        Document.WriteTo(TextJson);
        HttpRequestMessage.Method := 'PATCH';

        RequestUrl := APIUrl(TaskManagerEntry.Id);
        HttpRequestMessage.SetRequestUri(RequestUrl);

        HttpContent.WriteFrom(TextJson);
        HttpContent.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content := HttpContent;

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.HttpStatusCode() = HttpStatusCodeOK() then begin
                HttpResponseMessage.Content().ReadAs(TextResponse);
                ProcessJsonObjectResult(TextResponse, TaskManagerEntry);
            end else
                if HttpResponseMessage.HttpStatusCode() <> HttpStatusCodeNotFound() then // if we run an update on an entry that has been deleted
                    WebServiceCallFailedError(HttpResponseMessage.HttpStatusCode());
        end else
            ConnectionError();
    end;

    procedure DeleteOneRequest(EntryId: Integer)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
    begin
        if EntryId = 0 then
            exit;
        HttpRequestMessage.Method := 'DELETE';
        RequestUrl := APIUrl(EntryId);
        HttpRequestMessage.SetRequestUri(RequestUrl);

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if not (HttpResponseMessage.HttpStatusCode() in [HttpStatusCodeNoContent(), HttpStatusCodeNotFound()]) then
                WebServiceCallFailedError(HttpResponseMessage.HttpStatusCode());
        end else
            ConnectionError();
    end;

    procedure ProcessJsonArrayResult(TextResponse: Text; var TaskManagerEntry: Record "Task Manager Entry")
    var
        TaskList: JsonArray;
    begin
        if not TaskList.ReadFrom(TextResponse) then
            Error('I expected a JSON ARRAY, but got this %1.', TextResponse);

        DecodeTaskArray(TaskList, TaskManagerEntry);
    end;

    procedure ProcessJsonObjectResult(TextResponse: Text; var TaskManagerEntry: Record "Task Manager Entry")
    var
        TaskObject: JsonObject;
    begin
        if not TaskObject.ReadFrom(TextResponse) then
            Error('I expected a JSON OBJECT, but got this: %1', TextResponse);

        DecodeTaskObject(TaskObject, TaskManagerEntry);
    end;

    procedure DecodeTaskArray(TaskList: JsonArray; var TaskManagerEntry: Record "Task Manager Entry")
    var
        TaskObject: JsonObject;
        Token: JsonToken;
    begin
        TaskManagerEntry.DeleteAll();
        TaskManagerEntry.Reset();
        foreach Token in TaskList do begin
            TaskObject := Token.AsObject();
            DecodeTaskObject(TaskObject, TaskManagerEntry);
            TaskManagerEntry.Insert();
        end;
    end;

    procedure DecodeTaskObject(TaskObject: JsonObject; var TaskManagerEntry: Record "Task Manager Entry")
    var
        AttentionDateField: JsonToken;
        CreatedDateField: JsonToken;
        DeadlineField: JsonToken;
        DescriptionField: JsonToken;
        DurationField: JsonToken;
        IdField: JsonToken;
        PlannedDateField: JsonToken;
        PlannedStartingTimeField: JsonToken;
        StatusField: JsonToken;
        TitleField: JsonToken;
        UpdatedDateField: JsonToken;
        UrgencyField: JsonToken;
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

        if TaskObject.Get('created_at', CreatedDateField) then
            if not CreatedDateField.AsValue().IsNull then
                TaskManagerEntry."Created At" := CreatedDateField.AsValue().AsDateTime();

        if TaskObject.Get('updated_at', UpdatedDateField) then
            if not UpdatedDateField.AsValue().IsNull then
                TaskManagerEntry."Updated At" := UpdatedDateField.AsValue().AsDateTime();
    end;

    procedure EncodeTaskObject(TaskManagerEntry: Record "Task Manager Entry"; var TaskObject: JsonObject)
    begin
        if TaskManagerEntry.Id > 0 then
            EncodeInteger('id', TaskManagerEntry.Id, TaskObject);
        EncodeText('title', TaskManagerEntry.Title, TaskObject);
        EncodeText('description', TaskManagerEntry.Description, TaskObject);
        EncodeInteger('urgency', TaskManagerEntry.Urgency, TaskObject);
        EncodeInteger('duration_minutes', TaskManagerEntry."Duration Minutes", TaskObject);
        EncodeDate('attention_date', TaskManagerEntry."Attention Date", TaskObject);
        EncodeDate('deadline', TaskManagerEntry.Deadline, TaskObject);
        EncodeDate('planned_date', TaskManagerEntry."Planned Date", TaskObject);
        EncodeTime('planned_starting_time', TaskManagerEntry."Planned Date", TaskManagerEntry."Planned Starting Time", TaskObject);
        EncodeInteger('status', TaskManagerEntry.Status, TaskObject);
    end;

    procedure EncodeDate(ObjectKey: Text; Date: Date; var TaskObject: JsonObject)
    var
        NullValue: JsonValue;
    begin
        NullValue.SetValueToNull();
        if Date <> 0D then
            TaskObject.Add(ObjectKey, Date)
        else
            TaskObject.Add(ObjectKey, NullValue);
    end;

    procedure EncodeTime(ObjectKey: Text; Date: Date; Time: Time; var TaskObject: JsonObject)
    var
        TimeAsDateTime: DateTime;
        NullValue: JsonValue;
    begin
        NullValue.SetValueToNull();
        if (Date <> 0D) and (Time <> 0T) then begin
            TimeAsDateTime := CreateDateTime(Date, Time);
            TaskObject.Add(ObjectKey, TimeAsDateTime);
        end else
            TaskObject.Add(ObjectKey, NullValue);
    end;

    procedure EncodeInteger(ObjectKey: Text; Value: Integer; var TaskObject: JsonObject)
    begin
        TaskObject.Add(ObjectKey, Value)
    end;

    procedure EncodeText(ObjectKey: Text; Value: Text; var TaskObject: JsonObject)
    begin
        TaskObject.Add(ObjectKey, Value)
    end;

    procedure APIUrl(Id: Integer): Text
    begin
        if Id = 0 then
            exit('https://taskmanager02-api-c6207da5113d.herokuapp.com/tasks')
        else
            exit('https://taskmanager02-api-c6207da5113d.herokuapp.com/tasks/' + Format(Id));
    end;

    procedure WebServiceCallFailedError(StatusCode: Integer)
    begin
        Error('Web service call failed (status code %1: %2)', StatusCode, GetHttpStatusMessage(StatusCode));
    end;

    procedure ConnectionError()
    begin
        Error('Cannot contact service, connection error!');
    end;

    procedure HttpStatusCodeOK(): Integer
    begin
        exit(200);
    end;

    procedure HttpStatusCodeCreated(): Integer
    begin
        exit(201);
    end;

    procedure HttpStatusCodeNoContent(): Integer
    begin
        exit(204);
    end;

    procedure HttpStatusCodeNotFound(): Integer
    begin
        exit(404);
    end;

    procedure GetHttpStatusMessage(HttpStatusCode: Integer): Text
    var
        UnknownStatusCodeMsg: Label 'Unknown Status Code %1', Comment = '%1 = Unknown status code.';
        StatusMessage: Text;
    begin
        case HttpStatusCode of
            100:
                StatusMessage := 'Continue';
            101:
                StatusMessage := 'Switching Protocols';
            102:
                StatusMessage := 'Processing';
            103:
                StatusMessage := 'Early Hints';
            200:
                StatusMessage := 'OK';
            201:
                StatusMessage := 'Created';
            202:
                StatusMessage := 'Accepted';
            203:
                StatusMessage := 'Non-Authoritative Information';
            204:
                StatusMessage := 'No Content';
            205:
                StatusMessage := 'Reset Content';
            206:
                StatusMessage := 'Partial Content';
            207:
                StatusMessage := 'Multi-Status';
            208:
                StatusMessage := 'Already Reported';
            226:
                StatusMessage := 'IM Used';
            300:
                StatusMessage := 'Multiple Choices';
            301:
                StatusMessage := 'Moved Permanently';
            302:
                StatusMessage := 'Found';
            303:
                StatusMessage := 'See Other';
            304:
                StatusMessage := 'Not Modified';
            305:
                StatusMessage := 'Use Proxy';
            306:
                StatusMessage := 'Switch Proxy';
            307:
                StatusMessage := 'Temporary Redirect';
            308:
                StatusMessage := 'Permanent Redirect';
            400:
                StatusMessage := 'Bad Request';
            401:
                StatusMessage := 'Unauthorized';
            402:
                StatusMessage := 'Payment Required';
            403:
                StatusMessage := 'Forbidden';
            404:
                StatusMessage := 'Not Found';
            405:
                StatusMessage := 'Method Not Allowed';
            406:
                StatusMessage := 'Not Acceptable';
            407:
                StatusMessage := 'Proxy Authentication Required';
            408:
                StatusMessage := 'Request Timeout';
            409:
                StatusMessage := 'Conflict';
            410:
                StatusMessage := 'Gone';
            411:
                StatusMessage := 'Length Required';
            412:
                StatusMessage := 'Precondition Failed';
            413:
                StatusMessage := 'Payload Too Large';
            414:
                StatusMessage := 'URI Too Long';
            415:
                StatusMessage := 'Unsupported Media Type';
            416:
                StatusMessage := 'Range Not Satisfiable';
            417:
                StatusMessage := 'Expectation Failed';
            418:
                StatusMessage := 'I''m a teapot';
            421:
                StatusMessage := 'Misdirected Request';
            422:
                StatusMessage := 'Unprocessable Entity';
            423:
                StatusMessage := 'Locked';
            424:
                StatusMessage := 'Failed Dependency';
            425:
                StatusMessage := 'Too Early';
            426:
                StatusMessage := 'Upgrade Required';
            428:
                StatusMessage := 'Precondition Required';
            429:
                StatusMessage := 'Too Many Requests';
            431:
                StatusMessage := 'Request Header Fields Too Large';
            451:
                StatusMessage := 'Unavailable For Legal Reasons';
            500:
                StatusMessage := 'Internal Server Error';
            501:
                StatusMessage := 'Not Implemented';
            502:
                StatusMessage := 'Bad Gateway';
            503:
                StatusMessage := 'Service Unavailable';
            504:
                StatusMessage := 'Gateway Timeout';
            505:
                StatusMessage := 'HTTP Version Not Supported';
            506:
                StatusMessage := 'Variant Also Negotiates';
            507:
                StatusMessage := 'Insufficient Storage';
            508:
                StatusMessage := 'Loop Detected';
            510:
                StatusMessage := 'Not Extended';
            511:
                StatusMessage := 'Network Authentication Required';
            else
                StatusMessage := StrSubstNo(UnknownStatusCodeMsg, HttpStatusCode);
        end;

        exit(StatusMessage);
    end;
}
