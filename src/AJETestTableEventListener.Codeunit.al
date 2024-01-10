codeunit 50101 "AJE Test Table Event Listener"
{
    Permissions = TableData "Cust. Ledger Entry" = RIMD,
                TableData "Detailed Cust. Ledg. Entry" = RIMD,
                TableData "G/L Entry" = RIMD;
    Subtype = Test;

    [Test]
    procedure TestRIMD()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry."Entry No." := -1;
        GLEntry.Insert();

        GLEntry.Description := 'mod';
        GLEntry.Modify();

        GLEntry.Rename(-2);

        GLEntry.Delete();

        CustLedgerEntry."Entry No." := -1;
        CustLedgerEntry.Insert();

        CustLedgerEntry.Description := 'mod';
        CustLedgerEntry.Modify();

        CustLedgerEntry.Delete();

        DetailedCustLedgEntry."Entry No." := -1;
        DetailedCustLedgEntry.Insert();

        DetailedCustLedgEntry."Document No." := 'mod';
        DetailedCustLedgEntry.Modify();

        DetailedCustLedgEntry.Delete();
    end;
}