page 50104 "AJE Test Result Pack Card"
{
    Caption = 'Test Result Package Card';
    PageType = Document;
    SourceTable = "Config. Package";
    SourceTableView = sorting(Code) where("AJE Test Result" = const(true));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code for the configuration package.';
                }
                field("Package Name"; Rec."Package Name")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the package.';
                }
                field("Product Version"; Rec."Product Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the version of the product that you are configuring. You can use this field to help differentiate among various versions of a solution.';
                }
            }
            part(Control10; "Config. Package Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Package Code" = field(Code);
                SubPageView = sorting("Package Code", "Table ID");
            }
        }
    }
}