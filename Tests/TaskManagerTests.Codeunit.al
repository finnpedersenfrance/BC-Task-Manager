namespace FinnPedersenFrance.Demo.TaskManagerAPI;

codeunit 50121 "Task Manager Tests"
{
    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Accumulate comments
    end;

    [Test]
    procedure TestHttpStatusCodeOK()
    var
        TaskManagerAPI: Codeunit "Task Manager API";
    begin
        // [SCENARIO #001] Testing the HttpStatusCodeOK.
        // [GIVEN] Nothing special
        // [WHEN] Calling the function
        // [THEN] The expected result is 200.

        if TaskManagerAPI.HttpStatusCodeOK() <> 200 then
            Error('HttpStatusCodeOK() failed');
    end;

    [Test]
    procedure TestGetHttpStatusMessage()
    var
        TaskManagerAPI: Codeunit "Task Manager API";
    begin
        // [SCENARIO #001] Testing the GetHttpStatusMessage.
        // [GIVEN] Nothing special
        // [WHEN] Calling the function
        // [THEN] The expected result is 200.

        if TaskManagerAPI.GetHttpStatusMessage(200) <> 'OK' then
            Error('GetHttpStatusMessage(200) failed');
    end;

    [Test]
    procedure TestEncodeText()
    var
        TaskManagerAPI: Codeunit "Task Manager API";
        TaskObject: JsonObject;
        ValueToken: JsonToken;
        ObjectKey: Text;
        Value: Text;
    begin
        ObjectKey := 'key';
        Value := 'Value';
        TaskManagerAPI.EncodeText(ObjectKey, Value, TaskObject);
        if TaskObject.Get('key', ValueToken) then
            if not ValueToken.AsValue().IsNull then
                if 'Value' <> CopyStr(ValueToken.AsValue().AsText(), 1, 100) then
                    Error('EncodeText() failed. Value not found.');
        if not TaskObject.Get('key', ValueToken) then
            Error('EncodeText() failed. Key not found.');
    end;
}
