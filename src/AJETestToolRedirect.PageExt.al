pageextension 50102 AJETestToolRedirect extends "CAL Test Tool"
{
    trigger OnOpenPage()
    begin
        Error('Run "AL Test Tool" page istead!');
    end;

}