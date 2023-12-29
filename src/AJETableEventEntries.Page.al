/// <summary>
/// Page AJE Table Event Entries (ID 50101).
/// </summary>
page 50101 "AJE Table Event Entries"
{
    ApplicationArea = All;
    Caption = 'Table Event Entries';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "AJE Table Event Listener Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                    Visible = false;
                }
                field("Type"; Rec."Type")
                {
                }
                field("Record ID"; RecordIDText)
                {
                    Caption = 'Record ID';
                    Editable = false;
                }
                field("Call Stack"; CallStack)
                {
                    Caption = 'Call Stack';
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Rec.ShowCallStack();
                    end;
                }
                field("Created DateTime"; Format(Rec."Created DateTime", 0, 9))
                {
                    Caption = 'Created DateTime';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CallStack := Rec.GetCallStack();
        RecordIDText := Format(Rec."Record ID");
    end;

    var
        AJETableEventListener: Codeunit "AJE Table Event Listener";
        CallStack: Text;
        RecordIDText: Text;

    internal procedure RefreshEntries()
    begin
        AJETableEventListener.GetEntries(Rec);
    end;
}
