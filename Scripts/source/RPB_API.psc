scriptname RPB_API extends Quest Hidden

RPB_MCM                                 property MCM auto
RealisticPrisonAndBounty_Arrest         property Arrest auto
RealisticPrisonAndBounty_Jail           property Jail auto
RealisticPrisonAndBounty_ArrestVars     property ArrestVars auto
RealisticPrisonAndBounty_ActorVars      property ActorVars auto
RealisticPrisonAndBounty_MiscVars       property MiscVars auto
RealisticPrisonAndBounty_SceneManager   property SceneManager auto
RealisticPrisonAndBounty_EventManager   property EventManager auto
RPB_PrisonManager                       property PrisonManager auto

RPB_MCM function GetMCM() global
    return GetFormFromMod(0xD61) as RPB_MCM
endFunction

RealisticPrisonAndBounty_Config function GetConfig() global
    return GetFormFromMod(0x3317) as RealisticPrisonAndBounty_Config
endFunction

RealisticPrisonAndBounty_Arrest function GetArrest() global
    return GetFormFromMod(0x3DF8) as RealisticPrisonAndBounty_Arrest
endFunction

RealisticPrisonAndBounty_Jail function GetJail() global
    return GetFormFromMod(0x3DF8) as RealisticPrisonAndBounty_Jail
endFunction

RPB_PrisonManager function GetPrisonManager() global
    return GetFormFromMod(0x1B825) as RPB_PrisonManager
endFunction

RealisticPrisonAndBounty_SceneManager function GetSceneManager() global
    return GetFormFromMod(0xC9F5) as RealisticPrisonAndBounty_SceneManager
endFunction

RealisticPrisonAndBounty_EventManager function GetEventManager() global
    return GetFormFromMod(0xEA67) as RealisticPrisonAndBounty_EventManager
endFunction


string function GetPluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

string function GetModName() global
    return "Realistic Prison and Bounty"
endFunction

Form function GetFormFromMod(int formId) global
    return Game.GetFormFromFile(formId, GetPluginName())
endFunction
