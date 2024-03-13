enum 50121 TaskStatus
{
    Extensible = false;

    value(0; Unplanned)
    {
        Caption = 'Unplanned';
    }
    value(1; Planned)
    {
        Caption = 'Planned';
    }
    value(2; Done)
    {
        Caption = 'Done';
    }
    value(3; "In the bin")
    {
        Caption = 'In the bin';
    }
}