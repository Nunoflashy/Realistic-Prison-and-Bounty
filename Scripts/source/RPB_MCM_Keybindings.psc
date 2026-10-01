Scriptname RPB_MCM_Keybindings hidden

;/
@functions:
    bool function ShouldHandleEvent(RPB_MCM mcm) global
    function Render(RPB_MCM mcm) global
    function OnHighlight(RPB_MCM mcm, int oid) global
    function OnDefault(RPB_MCM mcm, int oid) global
    function OnKeymapChange(RPB_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
/;

; The Keybindings page: one key map option per RPB_Keybindings action. The values live in RPB_Keybindings (per save, not
; in mcm.json or the presets).

bool function ShouldHandleEvent(RPB_MCM mcm) global
    return mcm.CurrentPage == "Keybindings"
endFunction

function Render(RPB_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    mcm.AddHeaderOption("Keybindings")
    string[] actions = RPB_Keybindings.Actions()
    int i = 0
    while (i < actions.Length)
        int oid = mcm.AddKeyMapOption(RPB_Keybindings.GetName(actions[i]), RPB_Keybindings.GetKey(actions[i]), mcm.OPTION_FLAG_WITH_UNMAP)
        mcm.RegisterOption("Keybindings::" + actions[i], oid)
        i += 1
    endWhile
endFunction

; "Keybindings::Surrender" -> "Surrender"
string function __ActionOf(RPB_MCM mcm, int oid) global
    string optionKey = mcm.GetKeyFromOption(oid, false)
    int separator = StringUtil.Find(optionKey, "::")
    if (separator == -1)
        return ""
    endif
    return StringUtil.Substring(optionKey, separator + 2)
endFunction

function OnHighlight(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    string bindAction = __ActionOf(mcm, oid)
    if (bindAction != "")
        mcm.SetInfoText(RPB_Keybindings.GetInfo(bindAction) + "\nDefault: " + RPB_Keybindings.KeyName(RPB_Keybindings.GetDefault(bindAction)))
    endif
endFunction

function OnDefault(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    string bindAction = __ActionOf(mcm, oid)
    if (bindAction != "")
        int defaultKey = RPB_Keybindings.GetDefault(bindAction)
        RPB_Keybindings.SetKey(bindAction, defaultKey)
        mcm.SetKeyMapOptionValue(oid, defaultKey)
    endif
endFunction

function OnKeymapChange(RPB_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    string bindAction = __ActionOf(mcm, oid)
    if (bindAction == "")
        return
    endif
    if (conflictControl != "")
        string conflict = "This key is already mapped to:\n\"" + conflictControl + "\""
        if (conflictName != "")
            conflict += "\n(" + conflictName + ")"
        endif
        if (!mcm.ShowMessage(conflict + "\n\nAre you sure you want to continue?", true, "$Yes", "$No"))
            return
        endif
    endif
    RPB_Keybindings.SetKey(bindAction, keycode)
    mcm.SetKeyMapOptionValue(oid, keycode)
endFunction
