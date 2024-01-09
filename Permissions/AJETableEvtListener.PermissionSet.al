/// <summary>
/// permissionset TableEventListener (ID 50100).
/// </summary>
permissionset 50100 AJETableEvtListener
{
    Assignable = true;
    Caption = 'AJE Table Event Listener', MaxLength = 30;
    Permissions =
        table "AJE Table Event Listener Entry" = X,
        tabledata "AJE Table Event Listener Entry" = RIMD,
        table "AJE Table Event Listener Setup" = X,
        tabledata "AJE Table Event Listener Setup" = RIMD,
        table "AJE Test Run" = X,
        tabledata "AJE Test Run" = RMID,
        codeunit "AJE Table Event Listener" = X,
        page "AJE Table Event Entries" = X,
        page "AJE Table Event Listener" = X,
        page "AJE Test Result Packages" = X,
        page "AJE Test Result Pack Card" = X,
        page "AJE Test Result Pack Subform" = X;
}