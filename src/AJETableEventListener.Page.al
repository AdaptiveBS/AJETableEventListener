/// <summary>
/// Page AJE Data Change Listener (ID 50100).
/// </summary>
page 50100 "AJE Table Event Listener"
{
    ApplicationArea = All;
    Caption = 'Table Event Listener';
    DataCaptionExpression = Rec.Name;
    PageType = List;
    SourceTable = "AJE Table Event Listener Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Setup)
            {
                Caption = 'Setup';
                field(Listed; Listen)
                {
                    ApplicationArea = All;
                    Caption = 'Listen';
                    trigger OnValidate()
                    begin
                        AJETableEventListener.Activate(Listen);
                    end;
                }
            }
            group(Tables)
            {
                Caption = 'Tables to listen';
                repeater(General)
                {
                    field("Table ID"; Rec."Table ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Table No."; Rec.Name)
                    {
                        ApplicationArea = All;
                    }
                    field(Insert; Rec.OnInsert)
                    {
                        ApplicationArea = All;
                    }
                    field(Modify; Rec.OnModify)
                    {
                        ApplicationArea = All;
                    }
                    field(Delete; Rec.OnDelete)
                    {
                        ApplicationArea = All;
                    }
                    field(Rename; Rec.OnRename)
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
                if ConfirmManagement.GetResponseOrDefault('Will you deactivate the chnage log?', false) then
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
}
