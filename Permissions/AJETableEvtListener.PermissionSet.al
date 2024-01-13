/// <summary>
/// permissionset TableEventListener (ID 50100).
/// </summary>
permissionset 50100 AJETableEvtListener
{
    Assignable = true;
    Caption = 'AJE Table Event Listener', MaxLength = 30;
    Permissions =
        table "AJE Listener Test Run" = X,
        tabledata "AJE Listener Test Run" = RMID,
        table "AJE Table Event Listener Setup" = X,
        tabledata "AJE Table Event Listener Setup" = RIMD,
        codeunit "AJE Table Event Listener" = X,
        codeunit "AJE Test Table Event Listener" = X,
        page "AJE Config. Package Records" = X,
        page "AJE Config. Pack Rec. Subform" = X,
        page "AJE Listener Test Run Card" = X,
        page "AJE Listener Test Runs" = X,
        page "AJE Test Result Packages" = X,
        page "AJE Test Result Pack Card" = X,
        page "AJE Test Result Pack Subform" = X;
}