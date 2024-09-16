function SetContent(Content, IsXML) {
    HTMLContainer = document.getElementById("controlAddIn");
    
    if (IsXML) {
        // Escape angle brackets for XML content
        Content = Content.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }
    
    HTMLContainer.innerHTML += `<pre><code>${Content}</code></pre>`;

    HTMLContainer.style.overflow = "auto";
}