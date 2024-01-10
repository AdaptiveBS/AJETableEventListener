/// <summary>
/// Codeunit AJE Table Event Listener (ID 50100).
/// </summary>
codeunit 50100 "AJE Table Event Listener"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        AJEListenerTestRun: Record "AJE Listener Test Run";
        TempAJETableEventListenerEntry: Record "AJE Table Event Listener Entry" temporary;
        AJETableEventListenerSetup: Record "AJE Table Event Listener Setup";
        ConfigPackage: Record "Config. Package";
        Active: Boolean;
        TableTriggerSetup: Dictionary of [Integer, List of [Boolean]];
        TableFieldsSetup: Dictionary of [Integer, List of [Integer]];
        CurrentTestRunNo: Integer;
        EventType: Option Rename,Insert,Modify,Delete;

    /// <summary>
    /// GetEntries to show entries in the Listener page.
    /// </summary>
    /// <param name="TmpAJETableEventListenerEntry">Temporary VAR Record "AJE Table Event Listener Entry".</param>
    procedure GetEntries(var TmpAJETableEventListenerEntry: Record "AJE Table Event Listener Entry" temporary)
    begin
        TmpAJETableEventListenerEntry.Copy(TempAJETableEventListenerEntry, true);
    end;

    internal procedure Activate(Listen: Boolean)
    var
        AJETableEventListener: Codeunit "AJE Table Event Listener";
    begin
        TempAJETableEventListenerEntry.Reset();
        TempAJETableEventListenerEntry.DeleteAll();

        UnbindSubscription(AJETableEventListener);
        Active := false;
        if Listen then
            Active := BindSubscription(AJETableEventListener);
    end;

    internal procedure IsActive(): Boolean
    begin
        exit(Active);
    end;

    local procedure AddEntry(RecRef: RecordRef; EvtType: Option): Text
    begin
        if TempAJETableEventListenerEntry.FindLast() then
            TempAJETableEventListenerEntry.Id += 1;

        TempAJETableEventListenerEntry.Init();
        TempAJETableEventListenerEntry.Type := EvtType;
        TempAJETableEventListenerEntry."Table ID" := RecRef.Number;
        TempAJETableEventListenerEntry."Record ID" := RecRef.RecordId;
        TempAJETableEventListenerEntry.SetCallStack();
        TempAJETableEventListenerEntry.Insert(true);
    end;

    local procedure CreateTestRun(var CALTestLine: Record "CAL Test Line"): Integer
    var
        TestDescrLbl: Label '%1.%2', Locked = true;
    begin
        AJEListenerTestRun.Init();
        AJEListenerTestRun.Validate("Config. Package Code", CALTestLine."AJE Config. Pack Code");
        AJEListenerTestRun.Description := StrSubstNo(TestDescrLbl, CALTestLine."Test Codeunit", CALTestLine.Function);
        AJEListenerTestRun.Insert(true); // autoincremented "No."
        exit(AJEListenerTestRun."No.");
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

    local procedure StartTestRun(var CALTestLine: Record "CAL Test Line")
    begin
        if CALTestLine."AJE Config. Pack Code" = '' then
            exit;

        CurrentTestRunNo := CreateTestRun(CALTestLine);
    end;

    local procedure StopTestRun() TestRunNo: Integer
    begin
        if not GetListenerTestRun() then
            exit(0);
        TestRunNo := CurrentTestRunNo; // to set on before modify Test Result       

        // magic with AJEListenerTestRun


        CurrentTestRunNo := 0;
        Clear(AJEListenerTestRun);
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
            OnDatabaseInsert := OnDatabaseInsert or TriggerSetup.Get(1);
            OnDatabaseModify := OnDatabaseModify or TriggerSetup.Get(2);
            OnDatabaseDelete := OnDatabaseDelete or TriggerSetup.Get(3);
            OnDatabaseRename := OnDatabaseRename or TriggerSetup.Get(4);
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

    [EventSubscriber(ObjectType::Table, Database::"CAL Test Line", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifyCALTestLine(var Rec: Record "CAL Test Line"; var xRec: Record "CAL Test Line"; RunTrigger: Boolean)
    begin
        // Handle modification done in InitTestFunctionLine() of codeunit 130400 "CAL Test Runner" 
        if Rec."Line Type" <> Rec."Line Type"::"Function" then
            exit;

        if (Rec.Result = Rec.Result::Skipped) and (Rec."Finish Time" = Rec."Start Time") then
            StartTestRun(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseDelete, '', false, false)]
    local procedure OnAfterOnDatabaseDelete(RecRef: RecordRef);
    begin
        /*    if AJETableEventListenerSetup.Get(RecRef.Number) then
                if AJETableEventListenerSetup.OnDelete then
                    AddEntry(RecRef, EventType::Delete);*/
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseInsert, '', false, false)]
    local procedure OnAfterOnDatabaseInsert(RecRef: RecordRef);
    begin


        /*
        if AJETableEventListenerSetup.Get(RecRef.Number) then
            if AJETableEventListenerSetup.OnInsert then
                AddEntry(RecRef, EventType::Insert);
                */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseModify, '', false, false)]
    local procedure OnAfterOnDatabaseModify(RecRef: RecordRef);
    begin
        /*
        if AJETableEventListenerSetup.Get(RecRef.Number) then
            if AJETableEventListenerSetup.OnModify then
                AddEntry(RecRef, EventType::Modify);
                */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, OnAfterOnDatabaseRename, '', false, false)]
    local procedure OnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef);
    begin
        /*
        if AJETableEventListenerSetup.Get(RecRef.Number) then
            if AJETableEventListenerSetup.OnRename then
                AddEntry(RecRef, EventType::Rename);*/
    end;

    [EventSubscriber(ObjectType::Table, Database::"CAL Test Result", OnBeforeModifyEvent, '', false, false)]
    local procedure OnBeforeModifyCALTestResult(var Rec: Record "CAL Test Result"; var xRec: Record "CAL Test Result"; RunTrigger: Boolean)
    begin
        // Handle CALTestResult.Add() call from UpdateTestFunctionLine() of codeunit 130400 "CAL Test Runner"
        Rec."AJE Listener Test Run No." := StopTestRun();
    end;

    [EventSubscriber(ObjectType::Page, Page::"AJE Table Event Listener", OnListenerSubscribed, '', false, false)]
    local procedure OnListenerSubscribed(var Subscribed: Boolean);
    begin
        Subscribed := true
    end;
}
