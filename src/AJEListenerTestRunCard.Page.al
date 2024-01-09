page 50108 "AJE Listener Test Run Card"
{
    AdditionalSearchTerms = 'test result run listener card';
    ApplicationArea = All;
    Caption = 'Listener Test Run';
    Editable = true;// TODO
    PageType = Card;
    SourceTable = "AJE Listener Test Run";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Test Run';
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
            part(Tables; "AJE Test Result Pack Subform")
            {
                Caption = 'Tables';
                Editable = false;
                SubPageLink = "Package Code" = field("Config. Package Code");
            }
            part(Records; "AJE Config. Pack Rec. Subform")
            {
                Caption = 'Records';
                Editable = false;
                SubPageLink = "Package Code" = field("Config. Package Code");
            }
        }
    }
}