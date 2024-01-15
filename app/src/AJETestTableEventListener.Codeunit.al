codeunit 50101 "AJE Test Table Event Listener"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestFailure()
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry."Entry No." := -1;
        GLEntry."G/L Account No." := 'GLAcc0001';
        GLEntry.Insert();

        Error('this is an error');
    end;

    [Test]
    procedure TestTriggerSetup()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry."Entry No." := -1;
        GLEntry."G/L Account No." := 'GLAcc0001';
        GLEntry.Insert();

        GLEntry.Description := 'mod';
        GLEntry."Posting Date" := Today;
        GLEntry.Modify();

        GLEntry.Rename(-2);

        GLEntry.Delete();

        CustLedgerEntry."Entry No." := -1;
        CustLedgerEntry."Customer No." := 'custNo';
        CustLedgerEntry.Insert();

        CustLedgerEntry.Description := 'mod';
        CustLedgerEntry."Customer No." := 'custNo2';
        CustLedgerEntry.Modify();

        CustLedgerEntry.Delete();

        DetailedCustLedgEntry."Entry No." := -1;
        DetailedCustLedgEntry."Entry Type" := DetailedCustLedgEntry."Entry Type"::"Initial Entry";
        DetailedCustLedgEntry.Insert();

        DetailedCustLedgEntry."Document No." := 'mod';
        DetailedCustLedgEntry."Entry Type" := DetailedCustLedgEntry."Entry Type"::Application;
        DetailedCustLedgEntry.Modify();

        DetailedCustLedgEntry.Delete();
    end;

}