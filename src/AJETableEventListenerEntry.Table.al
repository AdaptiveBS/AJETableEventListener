/// <summary>
/// Table AJE Table Event Listener Entry (ID 50101).
/// </summary>
table 50101 "AJE Table Event Listener Entry"
{
    Caption = 'Table Event Listener Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(2; Type; Enum "AJE Listener Event Type")
        {
            Caption = 'Type';
        }
        field(3; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
        }
        field(4; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
        }
        field(5; "Call Stack"; Blob)
        {
            Caption = 'Call Stack';
        }
        field(6; Id; Integer)
        {
            Caption = 'Id';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime;
    end;

    /// <summary>
    /// GetCallStack.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        if not "Call Stack".HasValue() then
            exit('');
        CalcFields("Call Stack");
        "Call Stack".CreateInStream(InStream, TEXTENCODING::Windows);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    /// <summary>
    /// SetCallStack.
    /// </summary>
    procedure SetCallStack()
    var
        OutStream: OutStream;
    begin
        "Call Stack".CreateOutStream(OutStream, TEXTENCODING::Windows);
        OutStream.Write(GetCurrCallStack());
    end;

    /// <summary>
    /// ShowCallStack.
    /// </summary>
    procedure ShowCallStack()
    var
        CallStack: Text;
    begin
        CallStack := GetCallStack();
        if CallStack <> '' then
            Message(CallStack);
    end;

    local procedure GetCurrCallStack() CallStack: Text;
    var
        SubString: Text;
    begin
        if ThrowError() then;
        CallStack := GetLastErrorCallStack();
        SubString := '"Global Triggers"(CodeUnit 2000000002).OnDatabase';
        CallStack := CopyStr(CallStack, StrPos(CallStack, SubString) + StrLen(SubString));
        CallStack := CopyStr(CallStack, StrPos(CallStack, '\') + 1);
    end;

    [TryFunction]
    local procedure ThrowError()
    begin
        // Throw an error to get the call stack by GetLastErrorCallstack
        Error('');
    end;
}
