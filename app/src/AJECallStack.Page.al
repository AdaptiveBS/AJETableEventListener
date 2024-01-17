page 50107 "AJE Call Stack"
{
    ApplicationArea = All;
    Caption = 'Call Stack';
    Editable = false;
    PageType = List;
    SourceTable = "AJE Call Stack Line";
    SourceTableView = sorting("Entry No.") where("Is Test Framework" = const(false));
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("Entry No."; Rec."Entry No.")
                    {
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field("Object Type"; Rec."Object Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Object ID"; Rec."Object ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Object Name"; Rec."Object Name")
                    {
                        ApplicationArea = All;
                    }
                    field(Method; Rec.Method)
                    {
                        ApplicationArea = All;
                    }
                    field("CC Line No."; Rec."CC Line No.")
                    {
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = UnfavorableCCLineStyle;
                        Visible = CodeCoverageExists;
                    }
                    field("Line No."; Rec."Line No.")
                    {
                        ApplicationArea = All;
                    }
                    field("App Name"; Rec."App Name")
                    {
                        ApplicationArea = All;
                    }
                    field(Publisher; Rec.Publisher)
                    {
                        ApplicationArea = All;
                    }
                }
                part(CodeCoverage; "AJE Code Coverage Subform")
                {
                    Caption = 'Code';
                    SubPageLink = "Object Type" = field("Object Type"), "Object ID" = field("Object ID");
                    Visible = CodeCoverageExists;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowAll)
            {
                ApplicationArea = All;
                Caption = 'Show All';
                Image = ShowList;

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Is Test Framework");
                    Rec.FilterGroup(0);
                end;
            }
            action(HideTestFramework)
            {
                ApplicationArea = All;
                Caption = 'Hide Test Framework';
                Image = CancelLine;

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Is Test Framework", false);
                    Rec.FilterGroup(1);
                end;
            }
        }

        area(Promoted)
        {
            group(Split)
            {
                ShowAs = SplitButton;
                actionref(Show; ShowAll)
                { }
                actionref(Hide; HideTestFramework)
                { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."CC Line No." <> 0 then begin
            if CodeCoverage.Get(Rec."Object Type", Rec."Object ID", Rec."CC Line No.") then;
            CurrPage.CodeCoverage.Page.SetLineNo(Rec."CC Line No.");
            CurrPage.CodeCoverage.Page.SetRecord(CodeCoverage);
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        UnfavorableCCLineStyle := Rec."CC Line No." = 0;
    end;

    var
        CodeCoverage: Record "Code Coverage";
        CodeCoverageExists: Boolean;
        UnfavorableCCLineStyle: Boolean;


    procedure Set(CallStack: Text)
    begin
        CodeCoverage.Reset();
        CodeCoverageExists := not CodeCoverage.IsEmpty();
        Rec.Initialize(CallStack, CodeCoverageExists);
    end;
}