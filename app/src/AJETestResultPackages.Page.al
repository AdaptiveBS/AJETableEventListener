page 50103 "AJE Test Result Packages"
{
    AdditionalSearchTerms = 'test result setup packages';
    ApplicationArea = All;
    Caption = 'Test Result Packages';
    CardPageID = "AJE Test Result Package Card";
    Editable = false;
    PageType = List;
    SourceTable = "Config. Package";
    SourceTableView = sorting(Code) where("AJE Test Result" = const(true));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a code for the configuration package.';
                }
                field("Package Name"; Rec."Package Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the package.';
                }
                field("Product Version"; Rec."Product Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the version of the product that you are configuring. You can use this field to help differentiate among various versions of a solution.';
                }
                field("No. of Tables"; Rec."No. of Tables")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of tables that the package contains.';
                }
            }
        }
    }
}