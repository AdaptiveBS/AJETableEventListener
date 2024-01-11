tableextension 50104 AJEConfigPackRecordRunNo extends "Config. Package Record"
{
    fields
    {
        field(50100; "AJE Listener Test Run No."; Integer)
        {
            Caption = 'Listener Test Run No.';
            Editable = false;
            TableRelation = "AJE Listener Test Run"."No.";
        }
        field(50101; "AJE RIMD"; Option)
        {
            Caption = 'RIMD';
            Editable = false;
            OptionCaption = 'Rename,Insert,Modify,Delete';
            OptionMembers = Rename,Insert,Modify,Delete;
        }
        field(50102; "AJE Record ID"; RecordId)
        {
            Caption = 'Record ID';
            Editable = false;
        }
        field(50103; "AJE Call Stack"; Blob)
        {
            Caption = 'Call Stack';
        }
        field(50104; "AJE Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
        }
    }

    keys
    {
        key(AJEKey1; "AJE Listener Test Run No.")
        {
        }
    }

    trigger OnInsert()
    begin
        "AJE Created DateTime" := CurrentDateTime;
    end;

    /// <summary>
    /// GetCallStack.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure AJEGetCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        if not "AJE Call Stack".HasValue() then
            exit('');
        CalcFields("AJE Call Stack");
        "AJE Call Stack".CreateInStream(InStream, TEXTENCODING::UTF16);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    /// <summary>
    /// SetCallStack.
    /// </summary>
    procedure AJESetCallStack()
    var
        OutStream: OutStream;
    begin
        "AJE Call Stack".CreateOutStream(OutStream, TEXTENCODING::UTF16);
        OutStream.Write(GetCurrCallStack());
    end;

    /// <summary>
    /// ShowCallStack.
    /// </summary>
    procedure AJEShowCallStack()
    var
        CallStack: Text;
    begin
        CallStack := AJEGetCallStack();
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