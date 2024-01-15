/// <summary>
/// Codeunit AJE Table Event Listener (ID 50100).
/// </summary>
codeunit 50100 "AJE Table Event Listener"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        AJEListenerTestRun: Record "AJE Listener Test Run";
        ConfigPackage: Record "Config. Package";
        Active: Boolean;
        SkipAddingEntry: Boolean;
        TableFieldsSetup: Dictionary of [Integer, Dictionary of [Boolean, List of [Integer]]]; // [TableID, [PK/nonPK, [FieldID1, FieldID2 ..]]]
        TestRunData: Dictionary of [Integer, Dictionary of [Integer, Dictionary of [Integer, Text]]]; // [TableID, [RecNo, [FieldID, Text]]]]
        TableTriggerSetup: Dictionary of [Integer, List of [Boolean]]; // [TableID, [OnInsert, OnModify, OnDelete, OnRename]]
        RecordNo: Integer;

    procedure SkipCollectingData(Skip: Boolean)
    begin
        SkipAddingEntry := Skip;
    end;

    internal procedure Activate(NewActive: Boolean)
    var
        AJETableEventListener: Codeunit "AJE Table Event Listener";
    begin
        ClearAll();
        UnbindSubscription(AJETableEventListener);
        if NewActive then
            Active := BindSubscription(AJETableEventListener);
    end;

    internal procedure IsActive(): Boolean
    begin
        exit(Active);
    end;

    internal procedure StartTestRun(ManualAJEListenerTestRun: Record "AJE Listener Test Run"): Code[20]
    begin
        CheckAlreadyStartedRun();
        AJEListenerTestRun := ManualAJEListenerTestRun;
        if AJEListenerTestRun."All Tables" then begin
            SkipAddingEntry := true;
            CreateConfigPackage(AJEListenerTestRun."No.");
            SkipAddingEntry := false;
        end else begin
            AJEListenerTestRun.TestField("Config. Package Code");
            ConfigPackage.Get(AJEListenerTestRun."Config. Package Code");
        end;
        RecordNo := GetNextRecNo(ConfigPackage.Code);
        SetTableSetup();
        exit(ConfigPackage.Code);
    end;

    internal procedure StopTestRun(ManualAJEListenerTestRun: Record "AJE Listener Test Run")
    begin
        MoveDataToConfigPackageData();
        ClearData();
    end;

    local procedure AddEntry(RecRef: RecordRef; Fields: Dictionary of [Boolean, List of [Integer]]; EventType: Enum "AJE Listener Event Type"; CallStack: Text): Text
    var
        RecordData: Dictionary of [Integer, Dictionary of [Integer, Text]];
        FieldData: Dictionary of [Integer, Text];
        FieldId: Integer;
    begin
        FieldData.Add(-3, CallStack);
        FieldData.Add(-2, Format(RecRef.RecordId()));
        FieldData.Add(-1, Format(EventType.AsInteger()));
        // FieldData.Add(0, Format(RecRef.IsTemporary())); // Rec is never Temporary 

        if Fields.ContainsKey(true) then begin
            foreach FieldId in Fields.Get(true) do
                FieldData.Add(FieldId, GetFieldValueAsText(RecRef, FieldId));
            foreach FieldId in Fields.Get(false) do
                FieldData.Add(FieldId, GetFieldValueAsText(RecRef, FieldId));
        end;

        if TestRunData.Get(RecRef.Number, RecordData) then
            RecordData.Add(RecordNo, FieldData)
        else begin
            RecordData.Add(RecordNo, FieldData);
            TestRunData.Add(RecRef.Number, RecordData);
        end;
        RecordNo += 1;
    end;

    local procedure AddEntry(RecRef: RecordRef; EventType: Enum "AJE Listener Event Type")
    var
        Fields: Dictionary of [Boolean, List of [Integer]];
        Triggers: List of [Boolean];
    begin
        if AJEListenerTestRun."All Tables" then begin
            if SkipAddingEntry then
                exit;
            AddEntry(RecRef, Fields, EventType, GetCurrCallStack());
            exit;
        end;

        if TableTriggerSetup.Get(RecRef.Number, Triggers) then
            if Triggers.Get(EventType.AsInteger()) then
                if TableFieldsSetup.Get(RecRef.Number, Fields) then
                    AddEntry(RecRef, Fields, EventType, GetCurrCallStack());
    end;

    local procedure CheckAlreadyStartedRun()
    begin
        if AJEListenerTestRun."No." <> 0 then
            Error('Run #%1 is already started. Finish it first to start a new one.', AJEListenerTestRun."No.");
    end;

    local procedure ClearData()
    begin
        RecordNo := 0;
        Clear(AJEListenerTestRun);
        Clear(ConfigPackage);
        Clear(TableTriggerSetup);
        Clear(TableFieldsSetup);
        Clear(TestRunData);
    end;

    local procedure CreateConfigPackage(TestRunNo: Integer) PackageCode: Code[20]
    var
        PackCode: Label 'ALLTABLESRUN-%1', Locked = true;
        PackName: Label 'Autogenerated package by the test run #%1', Locked = true;
    begin
        PackageCode := StrSubstNo(PackCode, TestRunNo);
        if ConfigPackage.Get(PackageCode) then begin
            ConfigPackage.Delete(true);
            ConfigPackage.Init();
        end;
        ConfigPackage.Code := PackageCode;
        ConfigPackage."Package Name" := StrSubstNo(PackName, TestRunNo);
        ConfigPackage."AJE Test Result" := true;
        ConfigPackage.Insert();
    end;

    local procedure CreateConfigPackageTable(TableId: Integer)
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageTable."Package Code" := ConfigPackage.Code;
        ConfigPackageTable."Table ID" := TableId;
        ConfigPackageTable.Insert(true); // RIMD flags and all fields are added on insert
    end;

    local procedure EventTypeAsInt(Type: Enum "AJE Listener Event Type"): Integer
    begin
        exit(Type.AsInteger());
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

    local procedure GetFieldValueAsText(RecRef: RecordRef; FieldId: Integer) Value: Text
    var
        FldRef: FieldRef;
    begin
        if RecRef.FieldExist(FieldId) then begin
            FldRef := RecRef.Field(FieldId);
            if FldRef.Class = FldRef.Class::FlowField then
                FldRef.CalcField();
            Value := Format(FldRef.Value());
        end;
    end;

    local procedure GetNextRecNo(Code: Code[20]) NextRecNo: Integer
    var
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        ConfigPackageRecord.SetCurrentKey("No.");
        ConfigPackageRecord.SetRange("Package Code", Code);
        if ConfigPackageRecord.FindLast() then
            NextRecNo := ConfigPackageRecord."No.";
        NextRecNo += 1;
    end;

    local procedure MoveDataToConfigPackageData()
    var
        Fields: Dictionary of [Boolean, List of [Integer]];
        RecordData: Dictionary of [Integer, Dictionary of [Integer, Text]];
        FieldData: Dictionary of [Integer, Text];
        FieldId: Integer;
        RecNo: Integer;
        TableId: Integer;
    begin
        SkipAddingEntry := true;
        foreach TableId in TestRunData.Keys do
            if AJEListenerTestRun."All Tables" then begin
                CreateConfigPackageTable(TableId);
                RecordData := TestRunData.Get(TableId);
                foreach RecNo in RecordData.Keys do begin
                    FieldData := RecordData.Get(RecNo);
                    SaveRecordDataEntry(TableId, RecNo, FieldData);
                end;
            end else begin
                Fields := TableFieldsSetup.Get(TableId);
                RecordData := TestRunData.Get(TableId);
                foreach RecNo in RecordData.Keys do begin
                    FieldData := RecordData.Get(RecNo);
                    SaveRecordDataEntry(TableId, RecNo, FieldData);

                    SaveFieldDataEntry(TableId, RecNo, -1, FieldData.Get(-1), false);
                    // SaveFieldDataEntry(TableId, RecNo, 0, FieldData.Get(0), false);
                    foreach FieldId in Fields.Get(true) do // PrimaryKey
                        SaveFieldDataEntry(TableId, RecNo, FieldId, FieldData.Get(FieldId), true);
                    foreach FieldId in Fields.Get(false) do // non PrimaryKey
                        SaveFieldDataEntry(TableId, RecNo, FieldId, FieldData.Get(FieldId), false);
                end;
            end;
        SkipAddingEntry := false;
    end;

    local procedure SaveFieldDataEntry(TableId: Integer; RecNo: Integer; FieldId: Integer; TxtValue: Text; PrimaryKey: Boolean)
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        ConfigPackageData."Package Code" := ConfigPackage.Code;
        ConfigPackageData."Table ID" := TableId;
        ConfigPackageData."No." := RecNo;
        ConfigPackageData."Field ID" := FieldId;
        ConfigPackageData.Value := CopyStr(TxtValue, 1, MaxStrLen(ConfigPackageData.Value));
        ConfigPackageData.Invalid := PrimaryKey; // reused an existing boolean field for PrimaryKey flag
        ConfigPackageData.Insert(true);
    end;

    local procedure SaveRecordDataEntry(TableId: Integer; RecNo: Integer; FieldData: Dictionary of [Integer, Text])
    var
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        ConfigPackageRecord."Package Code" := ConfigPackage.Code;
        ConfigPackageRecord."Table ID" := TableId;
        ConfigPackageRecord."No." := RecNo;
        ConfigPackageRecord."AJE Listener Test Run No." := AJEListenerTestRun."No.";
        // Evaluate(ConfigPackageRecord."AJE Temporary", FieldData.Get(0));
        Evaluate(ConfigPackageRecord."AJE Event Type", FieldData.Get(-1), 9);
        Evaluate(ConfigPackageRecord."AJE Record ID", FieldData.Get(-2));
        ConfigPackageRecord.AJESetCallStack(FieldData.Get(-3));
        ConfigPackageRecord.Insert(true);
    end;

    local procedure SetFieldsSetup(ConfigPackageTable: Record "Config. Package Table"): Boolean
    var
        ConfigPackageField: Record "Config. Package Field";
        Fields: Dictionary of [Boolean, List of [Integer]];
        NonPKFields: List of [Integer];
        PKFields: List of [Integer];
    begin
        ConfigPackageField.SetRange("Package Code", ConfigPackageTable."Package Code");
        ConfigPackageField.SetRange("Table ID", ConfigPackageTable."Table ID");
        ConfigPackageField.SetRange("Include Field", true);
        ConfigPackageField.SetRange("Primary Key", true);
        if ConfigPackageField.FindSet() then
            repeat
                PKFields.Add(ConfigPackageField."Field ID");
            until ConfigPackageField.Next() = 0;
        if PKFields.Count() > 0 then
            Fields.Add(true, PKFields);

        ConfigPackageField.SetRange("Primary Key", false);
        if ConfigPackageField.FindSet() then
            repeat
                NonPKFields.Add(ConfigPackageField."Field ID");
            until ConfigPackageField.Next() = 0;
        if NonPKFields.Count() > 0 then
            Fields.Add(false, NonPKFields);

        if Fields.Count() = 0 then
            exit(false);

        TableFieldsSetup.Add(ConfigPackageTable."Table ID", Fields);
        exit(true);
    end;

    local procedure SetTableSetup()
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        if AJEListenerTestRun."All Tables" then
            exit;
        ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);
        if ConfigPackageTable.FindSet() then
            repeat
                if ConfigPackageTable.AJEIsAnyTriggerSet() then
                    if SetFieldsSetup(ConfigPackageTable) then
                        TableTriggerSetup.Add(ConfigPackageTable."Table ID", ConfigPackageTable.AJEGetTriggerSetup());
            until ConfigPackageTable.Next() = 0;
    end;

    local procedure StartTestRun(var TestMethodLine: Record "Test Method Line"): Integer
    begin
        CheckAlreadyStartedRun();

        if not TestMethodLine."AJE All Tables" and (TestMethodLine."AJE Config. Pack Code" = '') then
            exit;

        SkipAddingEntry := true;
        AJEListenerTestRun."No." := AJEListenerTestRun.Initialize(TestMethodLine);
        if AJEListenerTestRun."All Tables" then begin
            TestMethodLine."AJE Config. Pack Code" := CreateConfigPackage(AJEListenerTestRun."No.");
            TestMethodLine."AJE All Tables" := false;

            AJEListenerTestRun."Config. Package Code" := ConfigPackage.Code;
            AJEListenerTestRun.Modify();
        end else
            ConfigPackage.Get(AJEListenerTestRun."Config. Package Code");
        SkipAddingEntry := false;

        RecordNo := GetNextRecNo(ConfigPackage.Code);
        SetTableSetup();

        exit(AJEListenerTestRun."No.");
    end;

    local procedure StopTestRun(var CurrentTestMethodLine: Record "Test Method Line")
    begin
        if AJEListenerTestRun."No." = 0 then
            exit;

        SkipAddingEntry := true;
        AJEListenerTestRun.UpdateTestLine(CurrentTestMethodLine);
        SkipAddingEntry := false;
        MoveDataToConfigPackageData();

        ClearData();
    end;

    [TryFunction]
    local procedure ThrowError()
    begin
        // Throw an error to get the call stack by GetLastErrorCallstack
        Error('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterGetDatabaseTableTriggerSetup, '', false, false)]
    local procedure OnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean);
    var
        TriggerSetup: List of [Boolean];
    begin
        if AJEListenerTestRun."No." = 0 then
            exit;
        if (TableId >= 2000000000) or (TableId = Database::"AJE Listener Test Run") then
            exit;

        if AJEListenerTestRun."All Tables" then begin
            OnDatabaseInsert := true;
            OnDatabaseModify := true;
            OnDatabaseDelete := true;
            OnDatabaseRename := true;
            exit;
        end;

        if TableTriggerSetup.Get(TableId, TriggerSetup) then begin
            OnDatabaseInsert := OnDatabaseInsert or TriggerSetup.Get(EventTypeAsInt("AJE Listener Event Type"::Insert));
            OnDatabaseModify := OnDatabaseModify or TriggerSetup.Get(EventTypeAsInt("AJE Listener Event Type"::"Modify"));
            OnDatabaseDelete := OnDatabaseDelete or TriggerSetup.Get(EventTypeAsInt("AJE Listener Event Type"::Delete));
            OnDatabaseRename := OnDatabaseRename or TriggerSetup.Get(EventTypeAsInt("AJE Listener Event Type"::Rename));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseDelete, '', false, false)]
    local procedure OnAfterOnDatabaseDelete(RecRef: RecordRef);
    begin
        AddEntry(RecRef, "AJE Listener Event Type"::Delete);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseInsert, '', false, false)]
    local procedure OnAfterOnDatabaseInsert(RecRef: RecordRef);
    begin
        AddEntry(RecRef, "AJE Listener Event Type"::Insert);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    local procedure OnAfterOnDatabaseModify(RecRef: RecordRef);
    begin
        AddEntry(RecRef, "AJE Listener Event Type"::Modify);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseRename, '', false, false)]
    local procedure OnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef);
    begin
        AddEntry(RecRef, "AJE Listener Event Type"::Rename);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Test Method Line", OnBeforeModifyEvent, '', false, false)]
    local procedure OnBeforeModifyTestMethodLine(var Rec: Record "Test Method Line"; var xRec: Record "Test Method Line"; RunTrigger: Boolean)
    begin
        if (Rec.Function = '') or (Rec.Function = 'OnRun') or (Rec.Result = Rec.Result::" ") then
            exit;

        if Rec.Result = Rec.Result::Skipped then // SetStartTimeOnTestLine() of 130454 "Test Runner - Mgt"
            Rec."AJE Test Run No." := StartTestRun(Rec)
        else // UpdateTestFunctionLine() of 130454 "Test Runner - Mgt"
            StopTestRun(Rec);
    end;
}
