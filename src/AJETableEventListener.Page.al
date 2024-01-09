/// <summary>
/// Page AJE Data Change Listener (ID 50100).
/// </summary>
page 50100 "AJE Table Event Listener"
{
    ApplicationArea = All;
    Caption = 'Table Event Listener';
    DataCaptionExpression = Rec."Package Code";
    PageType = List;
    SourceTable = "Config. Package Table";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Setup)
            {
                Caption = 'Setup';
                field(Listen; Listen)
                {
                    ApplicationArea = All;
                    Caption = 'Listen';
                    trigger OnValidate()
                    begin
                        AJETableEventListener.Activate(Listen);
                    end;
                }
                field(PackageCode; PackageCode)
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ConfigPackage: Record "Config. Package";
                    begin
                        if ConfigPackage.Get(PackageCode) then;
                        if Page.RunModal(Page::"Config. Packages", ConfigPackage) = Action::LookupOK then begin
                            PackageCode := ConfigPackage.Code;
                            SetPackageFilter();
                        end;
                    end;

                    trigger OnValidate()
                    var
                        ConfigPackage: Record "Config. Package";
                    begin
                        if PackageCode <> '' then
                            ConfigPackage.Get(PackageCode);
                        SetPackageFilter();
                    end;
                }

            }
            group(Tables)
            {
                Caption = 'Tables to listen';
                Visible = PackageCode <> '';
                repeater(General)
                {
                    field("Table ID"; Rec."Table ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Table Name"; Rec."Table Name")
                    {
                        ApplicationArea = All;
                    }
                    field(AvailableFields; Rec."No. of Fields Available")
                    {
                        ApplicationArea = All;
                    }
                    field(IncludedFields; Rec."No. of Fields Included")
                    {
                        ApplicationArea = All;
                    }
                    field(Insert; Rec."AJE Insert")
                    {
                        ApplicationArea = All;
                    }
                    field(Modify; Rec."AJE Modify")
                    {
                        ApplicationArea = All;
                    }
                    field(Delete; Rec."AJE Delete")
                    {
                        ApplicationArea = All;
                    }
                    field(Rename; Rec."AJE Rename")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            part(EventList; "AJE Table Event Entries")
            {
                Caption = 'Events';
                SubPageLink = "Table ID" = field("Table ID");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh entries';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    CurrPage.EventList.Page.RefreshEntries();
                end;
            }
        }
    }

    var
        AJETableEventListener: Codeunit "AJE Table Event Listener";
        Listen: Boolean;
        OldChangeLogActive: Boolean;
        PackageCode: Code[20];

    trigger OnOpenPage()
    var
        ChangeLogSetup: Record "Change Log Setup";
    begin
        if not ChangeLogSetup.Get() or not ChangeLogSetup."Change Log Activated" then
            PAGE.Run(Page::"Change Log Setup");
        OldChangeLogActive := ChangeLogSetup."Change Log Activated";

        Listen := IsListenerSubscribed();
    end;

    trigger OnClosePage()
    var
        ChangeLogSetup: Record "Change Log Setup";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not OldChangeLogActive then
            if ChangeLogSetup.Get() and ChangeLogSetup."Change Log Activated" then
                if ConfirmManagement.GetResponseOrDefault('Will you deactivate the change log?', false) then
                    PAGE.Run(Page::"Change Log Setup");
    end;

    local procedure IsListenerSubscribed() Subscribed: Boolean
    begin
        OnListenerSubscribed(Subscribed);
    end;

    [InternalEvent(false)]
    local procedure OnListenerSubscribed(var Subscribed: Boolean)
    begin
    end;

    local procedure SetPackageFilter()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Package Code", PackageCode);
        Rec.FilterGroup(0);
    end;
}
