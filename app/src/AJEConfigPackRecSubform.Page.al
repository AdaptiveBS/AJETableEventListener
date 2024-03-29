page 50102 "AJE Config. Pack Rec. Subform"
{
    Caption = 'Records';
    DelayedInsert = true;
    Editable = false;
    PageType = ListPart;
    SourceTable = "Config. Package Record";
    SourceTableView = sorting("No.") where("AJE Listener Test Run No." = filter('>0'));

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
                field("AJE Temporary"; Rec."AJE Temporary")
                {
                    ApplicationArea = All;
                    Caption = 'Temporary';
                    Visible = false;
                }
                field("AJE Call Stack"; CallStack)
                {
                    ApplicationArea = All;
                    Caption = 'Call Stack';
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        AJECallStack: Page "AJE Call Stack";
                    begin
                        AJECallStack.Set(Rec.AJEGetCallStack());
                        AJECallStack.Run();
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
                Visible = ShowDataVisible;

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
        ShowDataVisible := Rec.IsDataExist();
    end;

    var
        ShowDataVisible: Boolean;
        CallStack: Text;
        RecordIDText: Text;
}