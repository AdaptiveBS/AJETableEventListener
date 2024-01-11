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
        TestRunnerMgt: Codeunit "Test Runner - Mgt";
        Active: Boolean;
        TestRunData: Dictionary of [Integer, Dictionary of [Integer, Dictionary of [Integer, Dictionary of [Integer, Text]]]]; // [TestRunNo, [TableID, [RecNo, [FieldID, Text]]]]
        TableTriggerSetup: Dictionary of [Integer, List of [Boolean]];
        TableFieldsSetup: Dictionary of [Integer, List of [Integer]];
        CurrentTestRunNo: Integer;
        RecordNo: Integer;
        EventType: Option ,Insert,Modify,Delete,Rename;

    /// <summary>
    /// GetEntries to show entries in the Listener page.
    /// </summary>
    /// <param name="TmpAJETableEventListenerEntry">Temporary VAR Record "AJE Table Event Listener Entry".</param>
    procedure GetEntries(var TmpAJETableEventListenerEntry: Record "AJE Table Event Listener Entry" temporary)
    begin
        //TmpAJETableEventListenerEntry.Copy(TempAJETableEventListenerEntry, true);
    end;

    internal procedure Activate(NewActive: Boolean)
    var
        AJETableEventListener: Codeunit "AJE Table Event Listener";
    begin
        //TempAJETableEventListenerEntry.Reset();
        //TempAJETableEventListenerEntry.DeleteAll();

        ClearAll();
        UnbindSubscription(AJETableEventListener);
        if NewActive then
            Active := BindSubscription(AJETableEventListener);
    end;

    internal procedure IsActive(): Boolean
    begin
        exit(Active);
    end;

    local procedure AddEntry(RecRef: RecordRef; Fields: List of [Integer]; EvtType: Option): Text
    var
        TableData: Dictionary of [Integer, Dictionary of [Integer, Dictionary of [Integer, Text]]];
        RecordData: Dictionary of [Integer, Dictionary of [Integer, Text]];
        FieldData: Dictionary of [Integer, Text];
        FieldId: Integer;
    begin
        FieldData.Add(0, Format(EvtType));
        foreach FieldId in Fields do
            FieldData.Add(FieldId, GetFieldValueAsText(RecRef, FieldId));

        RecordNo += 1;
        if TestRunData.Get(CurrentTestRunNo, TableData) then begin
            if TableData.Get(RecRef.Number, RecordData) then
                RecordData.Add(RecordNo, FieldData)
            else begin
                RecordData.Add(RecordNo, FieldData);
                TableData.Add(RecRef.Number, RecordData);
            end;
        end else begin
            RecordData.Add(RecordNo, FieldData);
            TableData.Add(RecRef.Number, RecordData);
            TestRunData.Add(CurrentTestRunNo, TableData);
        end;

        /*
        if TempAJETableEventListenerEntry.FindLast() then
            TempAJETableEventListenerEntry.Id += 1;

        TempAJETableEventListenerEntry.Init();
        TempAJETableEventListenerEntry.Type := EvtType;
        TempAJETableEventListenerEntry."Table ID" := RecRef.Number;
        TempAJETableEventListenerEntry."Record ID" := RecRef.RecordId;
        TempAJETableEventListenerEntry.SetCallStack();
        TempAJETableEventListenerEntry.Insert(true);
        */
    end;

    local procedure GetFieldValueAsText(RecRef: RecordRef; FieldId: Integer) Value: Text
    var
        FldRef: FieldRef;
    begin
        if RecRef.FieldExist(FieldId) then begin
            FldRef := RecRef.Field(FieldId);
            if FldRef.Class = FldRef.Class::FlowField then
                FldRef.CalcField();
            Value := Format(FldRef.Value(), 0, 9);
        end;
    end;

    local procedure GetListenerTestRun(): Boolean
    begin
        if CurrentTestRunNo = 0 then
            exit(false);
        if (AJEListenerTestRun."No." = CurrentTestRunNo) and (ConfigPackage.Code = AJEListenerTestRun."Config. Package Code") then
            exit(true);
        if not AJEListenerTestRun.Get(CurrentTestRunNo) then
            exit(false);
        if not ConfigPackage.Get(AJEListenerTestRun."Config. Package Code") then
            exit(false);
        SetTableSetup();
        exit(true)
    end;

    local procedure MoveDataToConfigPackageData()
    begin
        // TODO
    end;

    local procedure SetFieldsSetup(ConfigPackageTable: Record "Config. Package Table"): Boolean
    var
        ConfigPackageField: Record "Config. Package Field";
        Fields: List of [Integer];
    begin
        ConfigPackageField.SetRange("Package Code", ConfigPackageTable."Package Code");
        ConfigPackageField.SetRange("Table ID", ConfigPackageTable."Table ID");
        ConfigPackageField.SetRange("Include Field", true);
        if ConfigPackageField.FindSet() then
            repeat
                Fields.Add(ConfigPackageField."Field ID");
            until ConfigPackageField.Next() = 0;
        if Fields.Count() = 0 then
            exit(false);

        TableFieldsSetup.Add(ConfigPackageTable."Table ID", Fields);
        exit(true);
    end;

    local procedure SetTableSetup()
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
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
        if TestMethodLine."AJE Config. Pack Code" = '' then
            exit;

        CurrentTestRunNo := AJEListenerTestRun.Initialize(TestMethodLine);
        ConfigPackage.Get(AJEListenerTestRun."Config. Package Code");
        SetTableSetup();

        exit(CurrentTestRunNo);
    end;

    local procedure StopTestRun(var CurrentTestMethodLine: Record "Test Method Line")
    begin
        if not GetListenerTestRun() then
            exit;

        AJEListenerTestRun.Update(CurrentTestMethodLine);

        MoveDataToConfigPackageData();

        CurrentTestRunNo := 0;
        Clear(AJEListenerTestRun);
        Clear(ConfigPackage);
        Clear(TableTriggerSetup);
        Clear(TableFieldsSetup);
        Clear(TestRunData);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterGetDatabaseTableTriggerSetup, '', false, false)]
    local procedure OnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean);
    var
        TriggerSetup: List of [Boolean];
    begin
        if CurrentTestRunNo = 0 then
            exit;
        if not GetListenerTestRun() then
            exit;

        if TableTriggerSetup.Get(TableId, TriggerSetup) then begin
            OnDatabaseInsert := OnDatabaseInsert or TriggerSetup.Get(EventType::Insert);
            OnDatabaseModify := OnDatabaseModify or TriggerSetup.Get(EventType::Modify);
            OnDatabaseDelete := OnDatabaseDelete or TriggerSetup.Get(EventType::Delete);
            OnDatabaseRename := OnDatabaseRename or TriggerSetup.Get(EventType::Rename);
        end;
        /*
                if AJETableEventListenerSetup.Get(TableId) then begin
                    OnDatabaseInsert := OnDatabaseInsert or AJETableEventListenerSetup.OnInsert;
                    OnDatabaseModify := OnDatabaseModify or AJETableEventListenerSetup.OnModify;
                    OnDatabaseDelete := OnDatabaseDelete or AJETableEventListenerSetup.OnDelete;
                    OnDatabaseRename := OnDatabaseRename or AJETableEventListenerSetup.OnRename;
                end;
        */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseDelete, '', false, false)]
    local procedure OnAfterOnDatabaseDelete(RecRef: RecordRef);
    var
        Triggers: List of [Boolean];
        Fields: List of [Integer];
    begin
        if TableTriggerSetup.Get(RecRef.Number, Triggers) then
            if Triggers.Get(EventType::Delete) then
                if TableFieldsSetup.Get(RecRef.Number, Fields) then
                    AddEntry(RecRef, Fields, EventType::Delete);

        /*    if AJETableEventListenerSetup.Get(RecRef.Number) then
                if AJETableEventListenerSetup.OnDelete then
                    AddEntry(RecRef, EventType::Delete);*/
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseInsert, '', false, false)]
    local procedure OnAfterOnDatabaseInsert(RecRef: RecordRef);
    var
        Triggers: List of [Boolean];
        Fields: List of [Integer];
    begin
        if TableTriggerSetup.Get(RecRef.Number, Triggers) then
            if Triggers.Get(EventType::Insert) then
                if TableFieldsSetup.Get(RecRef.Number, Fields) then
                    AddEntry(RecRef, Fields, EventType::Insert);

        /*
        if AJETableEventListenerSetup.Get(RecRef.Number) then
            if AJETableEventListenerSetup.OnInsert then
                AddEntry(RecRef, EventType::Insert);
                */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    local procedure OnAfterOnDatabaseModify(RecRef: RecordRef);
    var
        Triggers: List of [Boolean];
        Fields: List of [Integer];
    begin
        if TableTriggerSetup.Get(RecRef.Number, Triggers) then
            if Triggers.Get(EventType::Modify) then
                if TableFieldsSetup.Get(RecRef.Number, Fields) then
                    AddEntry(RecRef, Fields, EventType::Modify);
        /*
        if AJETableEventListenerSetup.Get(RecRef.Number) then
            if AJETableEventListenerSetup.OnModify then
                AddEntry(RecRef, EventType::Modify);
                */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseRename, '', false, false)]
    local procedure OnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef);
    var
        Triggers: List of [Boolean];
        Fields: List of [Integer];
    begin
        if TableTriggerSetup.Get(RecRef.Number, Triggers) then
            if Triggers.Get(EventType::Rename) then
                if TableFieldsSetup.Get(RecRef.Number, Fields) then
                    AddEntry(RecRef, Fields, EventType::Rename);
        /*
        if AJETableEventListenerSetup.Get(RecRef.Number) then
            if AJETableEventListenerSetup.OnRename then
                AddEntry(RecRef, EventType::Rename);*/
    end;

    [EventSubscriber(ObjectType::Table, Database::"Test Method Line", OnBeforeModifyEvent, '', false, false)]
    local procedure OnBeforeModifyTestMethodLine(var Rec: Record "Test Method Line"; var xRec: Record "Test Method Line"; RunTrigger: Boolean)
    begin
        if (Rec.Function = '') or (Rec.Function = 'OnRun') or (Rec.Result = Rec.Result::" ") then
            exit;

        if Rec.Result = Rec.Result::Skipped then // SetStartTimeOnTestLine of 130454 "Test Runner - Mgt"
            Rec."AJE Test Run No." := StartTestRun(Rec)
        else // UpdateTestFunctionLine() of 130454 "Test Runner - Mgt"
            StopTestRun(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"AJE Table Event Listener", OnListenerSubscribed, '', false, false)]
    local procedure OnListenerSubscribed(var Subscribed: Boolean);
    begin
        Subscribed := true
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", OnAfterTestMethodRun, '', false, false)]
    local procedure TestRunnerMgt_OnAfterTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", OnBeforeTestMethodRun, '', false, false)]
    local procedure TestRunnerMgtOnBeforeTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions)
    begin
    end;


}
