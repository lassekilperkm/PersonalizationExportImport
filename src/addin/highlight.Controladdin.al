controladdin CodeHighlight
{
    RequestedHeight = 300;
    RequestedWidth = 700;
    VerticalStretch = false;
    VerticalShrink = false;
    HorizontalStretch = false;
    HorizontalShrink = false;
    Scripts = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js', 'src/addin/loader.js';
    StyleSheets = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/default.min.css';
    StartupScript = 'src/addin/startup.js';

    event AddInReady()

    procedure SetContent(Content: Text; IsXML: Boolean)
}