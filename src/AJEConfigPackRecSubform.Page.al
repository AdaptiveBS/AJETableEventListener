page 50109 "AJE Config. Pack Rec. Subform"
{
    Caption = 'Records';
    DelayedInsert = true;
    Editable = false;
    PageType = ListPart;
    SourceTable = "Config. Package Record";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the table.';
                }
                field("Rec No."; Rec."No.")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the configuration table. After you select a table ID from the list of tables, the table name is automatically filled in.';
                }
                field("AJE Record ID"; RecordIDText)
                {
                    ApplicationArea = All;
                    Caption = 'Record ID';
                }
                field("AJE RIMD"; Rec."AJE RIMD")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the change - rename, insert, modify, or delete.';
                }
                field("AJE Created DateTime"; Rec."AJE Created DateTime")
                {
                    ApplicationArea = All;
                }
                field("AJE Call Stack"; CallStack)
                {
                    ApplicationArea = All;
                    Caption = 'Call Stack';
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Rec.AJEShowCallStack();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CallStack := Rec.AJEGetCallStack();
        RecordIDText := Format(Rec."AJE Record ID");
    end;

    var
        CallStack: Text;
        RecordIDText: Text;
}