tableextension 50102 AJERecordTestRun extends "Config. Package Record"
{
    fields
    {
        field(50100; "AJE Listener Test Run No."; Integer)
        {
            DataClassification = CustomerContent;

            Caption = 'Listener Test Run No.';
            Editable = false;
            TableRelation = "AJE Listener Test Run"."No.";
        }
        field(50101; "AJE Event Type"; Enum "AJE Listener Event Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Event Type';
            Editable = false;
        }
        field(50102; "AJE Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
            Editable = false;
        }
        field(50103; "AJE Call Stack"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Call Stack';
        }
        field(50104; "AJE Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
        }
        field(50105; "AJE Temporary"; Boolean)
        {
            DataClassification = CustomerContent;
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

    internal procedure IsDataExist(): Boolean
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        ConfigPackageData.SetRange("Package Code", "Package Code");
        ConfigPackageData.SetRange("Table ID", "Table ID");
        ConfigPackageData.SetRange("No.", "No.");
        exit(not ConfigPackageData.IsEmpty());
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
        ConfigPackageRecords.Load(Fields, FieldCaptions);
        ConfigPackageRecords.RunModal();
    end;

    local procedure FilterDataForRecord(var ConfigPackageData: Record "Config. Package Data")
    begin
        ConfigPackageData.SetRange("Package Code", Rec."Package Code");
        ConfigPackageData.SetRange("Table ID", Rec."Table ID");
        ConfigPackageData.SetRange("No.", Rec."No.");
        ConfigPackageData.SetFilter("Field ID", '>0');
    end;

    local procedure GetFieldCaption(TableID: Integer; FieldID: Integer): Text
    var
        Field: Record Field;
    begin
        Field.Get(TableID, FieldID);
        exit(Field."Field Caption");
    end;

    local procedure GetFieldsCaptions(var Fields: List of [Integer]; var FieldCaptions: List of [Text])
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        Fields.Add(-1);
        FieldCaptions.Add('Event Type');
        Fields.Add(0);
        FieldCaptions.Add('Call Stack');
        //FieldCaptions.Add('Temporary');

        FilterDataForRecord(ConfigPackageData);
        ConfigPackageData.SetRange(Invalid, true); // PrimaryKey 
        if ConfigPackageData.FindSet() then
            repeat
                Fields.Add(ConfigPackageData."Field ID");
                FieldCaptions.Add(GetFieldCaption(ConfigPackageData."Table ID", ConfigPackageData."Field ID"));
            until ConfigPackageData.Next() = 0;

        ConfigPackageData.SetRange(Invalid, false); // non PrimaryKey 
        if ConfigPackageData.FindSet() then
            repeat
                Fields.Add(ConfigPackageData."Field ID");
                FieldCaptions.Add(GetFieldCaption(ConfigPackageData."Table ID", ConfigPackageData."Field ID"));
            until ConfigPackageData.Next() = 0;
    end;
}