Scriptname RPB_Keybindings hidden

;/
@functions:
    string[] function Actions() global
    int function GetKey(string asAction) global
    int function GetDefault(string asAction) global
    string function GetName(string asAction) global
    string function GetInfo(string asAction) global
    function SetKey(string asAction, int aiKeyCode) global
    function RegisterSurrenderKey() global
    string function KeyName(int aiKeyCode) global
/;

; The keys the player can rebind (the MCM's Keybindings page). Their defaults, names and descriptions are in
; RPB_Data/keybindings.json, apart from mcm.json; the bindings themselves are kept per save.

string function DataPath() global
    return "Data/RPB_Data/keybindings.json"
endFunction

string[] function Actions() global
    string[] actions = new string[2]
    actions[0] = "Surrender"
    actions[1] = "EscortToggle"
    return actions
endFunction

; The bound key, or the default when never bound. -1: unbound by the player.
int function GetKey(string asAction) global
    int bound = RPB_StorageVars.GetInt(asAction, "Keybindings")
    if (bound == 0)
        return GetDefault(asAction)
    endif
    return bound
endFunction

int function GetDefault(string asAction) global
    return JValue.solveInt(JValue.readFromFile(DataPath()), "." + asAction + ".Default", -1)
endFunction

string function GetName(string asAction) global
    return JValue.solveStr(JValue.readFromFile(DataPath()), "." + asAction + ".Name", asAction)
endFunction

string function GetInfo(string asAction) global
    return JValue.solveStr(JValue.readFromFile(DataPath()), "." + asAction + ".Info", "")
endFunction

; Rebinds @asAction (-1 unbinds it). Surrender is registered again right away; the escort key is read at each escort's start.
function SetKey(string asAction, int aiKeyCode) global
    int oldKey = GetKey(asAction)
    if (aiKeyCode == 0)
        aiKeyCode = -1 ; 0 reads as "never bound"
    endif
    RPB_StorageVars.SetInt(asAction, aiKeyCode, "Keybindings")
    if (asAction == "Surrender")
        RPB_Arrest arrest = RPB_API.GetArrest()
        if (oldKey > 0)
            arrest.UnregisterForKey(oldKey)
        endif
        RegisterSurrenderKey()
    endif
endFunction

; A key's name ("F8", "K") from RPB_Data/keycodes.json (DirectX scan codes, mouse 256+, gamepad 266+)
string function KeyName(int aiKeyCode) global
    if (aiKeyCode < 0)
        return "Unbound"
    endif
    string keyName = JMap.getStr(JValue.readFromFile("Data/RPB_Data/keycodes.json"), aiKeyCode as string)
    if (keyName == "")
        return "Key " + aiKeyCode
    endif
    return keyName
endFunction

function RegisterSurrenderKey() global
    int surrenderKey = GetKey("Surrender")
    if (surrenderKey > 0)
        RPB_API.GetArrest().RegisterForKey(surrenderKey)
    endif
endFunction
