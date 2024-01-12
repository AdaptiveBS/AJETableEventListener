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
        field(50101; "AJE Event Type"; Enum "AJE Listener Event Type")
        {
            Caption = 'Event Type';
            Editable = false;
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
        field(50105; "AJE Temporary"; Boolean)
        {
            Caption = 'Temporary';
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
    procedure AJESetCallStack(CallStack: Text)
    var
        OutStream: OutStream;
    begin
        "AJE Call Stack".CreateOutStream(OutStream, TEXTENCODING::UTF16);
        OutStream.Write(CallStack);
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

    internal procedure ShowRecords()
    var
        ConfigPackageRecord: Record "Config. Package Record";
        ConfigPackageRecords: Page "AJE Config. Package Records";
        Fields: List of [Integer];
        FieldCaptions: List of [Text];
    begin
        GetFieldsCaptions(Fields, FieldCaptions);

        Clear(ConfigPackageRecords);
        ConfigPackageRecord.SetRange("AJE Listener Test Run No.", "AJE Listener Test Run No.");
        ConfigPackageRecord.SetRange("Package Code", "Package Code");
        ConfigPackageRecord.SetRange("Table ID", "Table ID");
        ConfigPackageRecords.SetTableView(ConfigPackageRecord);
        ConfigPackageRecords.LookupMode(true);
        ConfigPackageRecords.Load(Fields, FieldCaptions, GetTableCaption());
        ConfigPackageRecords.RunModal();
    end;

    local procedure GetFieldsCaptions(var Fields: List of [Integer]; var FieldCaptions: List of [Text])
    var
        ConfigPackageData: Record "Config. Package Data";
        Field: Record Field;
    begin
        ConfigPackageData.SetRange("Package Code", Rec."Package Code");
        ConfigPackageData.SetRange("Table ID", Rec."Table ID");
        ConfigPackageData.SetRange("No.", Rec."No.");
        ConfigPackageData.SetFilter("Field ID", '>-2'); // to skip CallStack and RecID data
        if ConfigPackageData.FindSet() then
            repeat
                case ConfigPackageData."Field ID" of
                    -1:
                        Field."Field Caption" := 'Event Type';
                    0:
                        Field."Field Caption" := 'Temporary';
                    else
                        Field.Get(ConfigPackageData."Table ID", ConfigPackageData."Field ID");
                end;
                Fields.Add(ConfigPackageData."Field ID");
                FieldCaptions.Add(Field."Field Caption");
            until ConfigPackageData.Next() = 0;
    end;

    local procedure GetTableCaption(): Text[80]
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get("Table ID");
        exit(TableMetadata.Caption);
    end;
}