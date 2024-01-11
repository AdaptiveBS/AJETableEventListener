page 50108 "AJE Listener Test Run Card"
{
    AdditionalSearchTerms = 'test result run listener card';
    ApplicationArea = All;
    Caption = 'Listener Test Run';
    DataCaptionExpression = Rec.Description;
    Editable = false;
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
                    ToolTip = 'Specifies the configuration package code that defines tables and fields to be stored.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowConfigPackage();
                    end;
                }
                field("Start Time"; Rec."Start Time")
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
            part(Records; "AJE Config. Pack Rec. Subform")
            {
                Caption = 'Records';
                Editable = false;
                SubPageLink = "AJE Listener Test Run No." = field("No.");
            }
            part(Tables; "AJE Test Result Pack Subform")
            {
                Caption = 'Package Table Setup';
                Editable = false;
                SubPageLink = "Package Code" = field("Config. Package Code");
                Visible = false; // Package card is accessible by drilldown on config. package code
            }
        }
    }

    var
        ConfigPackageRecord: Record "Config. Package Record";

    trigger OnAfterGetCurrRecord()
    begin
        //ConfigPackageRecord.SetRange("AJE Listener Test Run No.", Rec."No.");
        //CurrPage.Records.Page.SetTableView(ConfigPackageRecord);
    end;
}