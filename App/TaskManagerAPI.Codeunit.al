codeunit 50120 "Task Manager API"
{
    procedure CreateTask(var TaskManagerEntry: Record "Task Manager Entry")
    begin

    end;

    procedure ReadTask(id: Integer) TaskManagerEntry: Record "Task Manager Entry"
    begin

    end;

    procedure UpdateTask(var TaskManagerEntry: Record "Task Manager Entry")
    begin

    end;

    procedure DeleteTask(var TaskManagerEntry: Record "Task Manager Entry")
    begin

    end;

    local procedure APIUrl(Id: Integer): Text
    begin
        if Id < 0 then
            Error('Invalid ID');
        if Id = 0 then
            exit('https://taskmanager02-api-c6207da5113d.herokuapp.com/tasks')
        else
            exit('https://taskmanager02-api-c6207da5113d.herokuapp.com/tasks/' + Format(Id));
    end;

    procedure GetRequest(Id: Integer)
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
            if ResponseMessage.HttpStatusCode() = 200 then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessResult(TextResponse);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    procedure PatchRequest(Id: Integer; var Document: JsonObject)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Content: HttpContent;
        TextXml: Text;
        RequestUrl: Text;
        TextResponse: Text;
        ErrorMessage: Text;

    begin
        Document.WriteTo(TextXml);
        RequestMessage.Method := 'PATCH';
        RequestUrl := APIUrl(Id);
        RequestMessage.SetRequestUri(RequestUrl);

        Content.WriteFrom(TextXml);
        RequestMessage.Content := Content;

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if ResponseMessage.HttpStatusCode() = 200 then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessResult(TextResponse);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    procedure PostRequest(var Document: JsonObject)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Content: HttpContent;
        TextXml: Text;
        RequestUrl: Text;
        TextResponse: Text;
        ErrorMessage: Text;

    begin
        Document.WriteTo(TextXml);
        RequestMessage.Method := 'PATCH';
        RequestUrl := APIUrl(0);
        RequestMessage.SetRequestUri(RequestUrl);

        Content.WriteFrom(TextXml);
        RequestMessage.Content := Content;

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if ResponseMessage.HttpStatusCode() = 200 then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessResult(TextResponse);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    procedure DeleteRequest(Id: Integer)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        TextResponse: Text;
        ErrorMessage: Text;

    begin
        RequestMessage.Method := 'DELETE';
        RequestUrl := APIUrl(Id);
        RequestMessage.SetRequestUri(RequestUrl);

        if Client.Send(RequestMessage, ResponseMessage) then begin
            if ResponseMessage.HttpStatusCode() = 200 then begin
                ResponseMessage.Content().ReadAs(TextResponse);
                ProcessResult(TextResponse);
            end else begin
                ErrorMessage := StrSubstNo('Web service call failed (status code %1)', ResponseMessage.HttpStatusCode());
                error(ErrorMessage);
            end;
        end else begin
            ErrorMessage := 'Cannot contact service, connection error!';
            error(ErrorMessage);
        end;
    end;

    local procedure ProcessResult(TextResponse: Text)
    var
        XMLResponse: XmlDocument;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
    begin
        case true of
            JsonObject.ReadFrom(TextResponse):
                Message('Successful JSON OBJECT response.');
            JsonArray.ReadFrom(TextResponse):
                Message('Successful JSON ARRAY response.');
            XmlDocument.ReadFrom(TextResponse, XMLResponse):
                Message('Successful XML response.');
            else
                Message('Successful TEXT response: %1', TextResponse);
        end;
    end;
}
