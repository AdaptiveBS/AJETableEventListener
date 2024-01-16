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
                    Width = 4;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStyle();
    end;

    var
        LineStyle: Text;

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