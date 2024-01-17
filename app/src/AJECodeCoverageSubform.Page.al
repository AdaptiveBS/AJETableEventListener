page 50108 "AJE Code Coverage Subform"
{
    ApplicationArea = All;
    Caption = 'Code Coverage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Code Coverage";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Line; Rec.Line)
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    StyleExpr = IsCurrLine;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GoToLine)
            {
                ApplicationArea = All;
                Caption = 'Go To Line';
                Image = GoTo;

                trigger OnAction()
                begin
                    GoToCurrLineNo();
                    CurrPage.Update(false);
                end;
            }

        }
    }


    trigger OnAfterGetRecord()
    begin
        SetStyle();
        IsCurrLine := CurrLineNo = Rec."Line No.";
    end;

    var
        IsCurrLine: Boolean;
        CurrLineNo: Integer;
        LineStyle: Text;

    procedure GoToCurrLineNo()
    begin
        Rec.SetRange("Line No.", CurrLineNo);
        if Rec.FindFirst() then;
        Rec.SetRange("Line No.");
        CurrPage.SetRecord(Rec);
    end;

    procedure SetLine(AJECallStackLine: Record "AJE Call Stack Line")
    begin
        CurrLineNo := AJECallStackLine."CC Line No.";
        GoToCurrLineNo();
    end;

    local procedure SetStyle()
    begin
        case Rec."Line Type" of
            Rec."Line Type"::Code:
                case Rec."Code Coverage Status" of
                    Rec."Code Coverage Status"::NotCovered:
                        LineStyle := 'Unfavorable';
                    Rec."Code Coverage Status"::Covered:
                        LineStyle := 'Favorable';
                    Rec."Code Coverage Status"::PartiallyCovered:
                        LineStyle := 'Ambiguous';
                end;
            Rec."Line Type"::Empty:
                LineStyle := 'Subordinate';
            Rec."Line Type"::Object:
                LineStyle := 'StrongAccent';
            Rec."Line Type"::"Trigger/Function":
                LineStyle := 'Strong';
        end;
    end;
}