page 90101 "User Pers. Content Viewer"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Content';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            usercontrol(CodeHighlight; CodeHighlight)
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    CurrPage.CodeHighlight.SetContent(ContentToShow, TypeXML);
                end;
            }
        }
    }

    internal procedure SetContentToShow(Content: Text; IsXML: Boolean)
    begin
        ContentToShow := Content;
        TypeXML := IsXML;
    end;

    var
        ContentToShow: Text;
        TypeXML: Boolean;
}