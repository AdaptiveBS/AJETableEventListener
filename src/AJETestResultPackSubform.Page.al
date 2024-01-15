page 50105 "AJE Test Result Pack Subform"
{
    Caption = 'Tables';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Config. Package Table";

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

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Table Name");
                    end;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the configuration table. After you select a table ID from the list of tables, the table name is automatically filled in.';
                }
                field(AJERename; Rec."AJE Rename")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a rename event will be logged in test results.';
                }
                field(AJEInsert; Rec."AJE Insert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if an insert event will be logged in test results.';
                }
                field(AJEModify; Rec."AJE Modify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a modify event will be logged in test results.';
                }
                field(AJEDelete; Rec."AJE Delete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a delete event will be logged in test results.';
                }
                field("No. of Fields Included"; Rec."No. of Fields Included")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageID = "Config. Package Fields";
                    ToolTip = 'Specifies the count of the number of fields that are included in the migration table.';
                }
                field("No. of Fields Available"; Rec."No. of Fields Available")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageID = "Config. Package Fields";
                    ToolTip = 'Specifies the count of the number of fields that are available in the migration table.';
                }
            }
        }
    }
}