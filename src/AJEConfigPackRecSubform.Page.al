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
                    ToolTip = 'Specifies the name of the table that is part of the migration process. The name comes from the Name property of the table.';
                }
                field("Rec No."; Rec."No.")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the configuration table. After you select a table ID from the list of tables, the table name is automatically filled in.';
                }
                /* TODO
                field(AJERIMD; Rec."AJE RIMD")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the change - rename, insert, modify, or delete.';
                }
                */
            }
        }
    }
}