page 50109 "AJE Config. Pack Rec. Subform"
{
    Caption = 'Records';
    DelayedInsert = true;
    Editable = false;
    PageType = ListPart;
    SourceTable = "Config. Package Record";
    SourceTableView = sorting("No.");

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("AJE Event Type"; Rec."AJE Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the change - rename, insert, modify, or delete.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the table.';
                }
                field("AJE Record ID"; RecordIDText)
                {
                    ApplicationArea = All;
                    Caption = 'Record ID';
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
                field("AJE Created DateTime"; Rec."AJE Created DateTime")
                {
                    ApplicationArea = All;
                }
                field("Rec No."; Rec."No.")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the configuration table. After you select a table ID from the list of tables, the table name is automatically filled in.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowData)
            {
                ApplicationArea = All;
                Caption = 'Show Data';
                Image = Grid;
                ToolTip = 'View all stored records of the current table.';

                trigger OnAction()
                begin
                    Rec.ShowRecords();
                end;
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