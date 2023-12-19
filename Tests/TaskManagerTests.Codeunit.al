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
        TaskManagerAPI: codeunit "Task Manager API";
    begin
        // [SCENARIO #001] Testing the HttpStatusCodeOK.
        // [GIVEN] Nothing special
        // [WHEN] Calling the function
        // [THEN] The expected result is 200.

        if TaskManagerAPI.HttpStatusCodeOK() <> 200 then
            error('HttpStatusCodeOK() failed');
    end;

    [Test]
    procedure TestGetHttpStatusMessage()
    var
        TaskManagerAPI: codeunit "Task Manager API";
    begin
        // [SCENARIO #001] Testing the GetHttpStatusMessage.
        // [GIVEN] Nothing special
        // [WHEN] Calling the function
        // [THEN] The expected result is 200.

        if TaskManagerAPI.GetHttpStatusMessage(200) <> 'OK' then
            error('GetHttpStatusMessage(200) failed');
    end;

    [Test]
    procedure TestEncodeText()
    var
        TaskManagerAPI: codeunit "Task Manager API";
        ObjectKey: Text;
        Value: Text;
        TaskObject: JsonObject;
        ValueToken: JsonToken;
    begin
        ObjectKey := 'key';
        Value := 'Value';
        TaskManagerAPI.EncodeText(ObjectKey, Value, TaskObject);
        if TaskObject.Get('key', ValueToken) then
            if not ValueToken.AsValue().IsNull then
                if 'Value' <> CopyStr(ValueToken.AsValue().AsText(), 1, 100) then
                    error('EncodeText() failed. Value not found.');
        if not TaskObject.Get('key', ValueToken) then
            error('EncodeText() failed. Key not found.');
    end;

}
