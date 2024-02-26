scriptname RPB_UIInterface extends ObjectReference

UILIB_1 property UILib
    UILIB_1 function get()
        return (self as Form) as UILIB_1
    endFunction
endProperty

int function ShowList(string asTitle = "", string[] asOptions, int aiStartIndex, int aiDefaultIndex)
    return UILib.ShowList(asTitle, asOptions, aiStartIndex, aiDefaultIndex)
endFunction

string function ShowList_ReturnElement(string asTitle = "", string[] asOptions, int aiStartIndex, int aiDefaultIndex)
    int selectedIndex = UILib.ShowList(asTitle, asOptions, aiStartIndex, aiDefaultIndex)
    return asOptions[selectedIndex]
endFunction

string function ShowInput(string asTitle = "", string asInitialText = "")
    return UILib.ShowTextInput(asTitle, asInitialText)
endFunction