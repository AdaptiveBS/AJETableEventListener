page 50107 "AJE Listener Test Runs"
{
    AdditionalSearchTerms = 'test result run listener';
    ApplicationArea = All;
    Caption = 'Listener Test Runs';
    CardPageID = "AJE Listener Test Run Card";
    Editable = false;
    PageType = List;
    SourceTable = "AJE Listener Test Run";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an autoincremented number of the test run.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description of the run.';
                }
                field("Config. Package Code"; Rec."Config. Package Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the confiuration package code that defines tables and fields to be stored.';
                }
                field("Created DateTime"; Rec."Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when the run was started.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the run.';
                }

            }
        }
    }
}