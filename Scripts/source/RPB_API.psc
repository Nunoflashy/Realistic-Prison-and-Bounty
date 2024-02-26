scriptname RPB_API extends Quest Hidden

RealisticPrisonAndBounty_ArrestVars     property ArrestVars auto
RealisticPrisonAndBounty_ActorVars      property ActorVars auto
RealisticPrisonAndBounty_MiscVars       property MiscVars auto


RPB_MCM __mcm
RPB_MCM property MCM
    RPB_MCM function get()
        if (__mcm)
            return __mcm
        endif

        __mcm = GetMCM()
        return __mcm
    endFunction
endProperty

RealisticPrisonAndBounty_Config __config
RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        if (__config)
            return __config
        endif

        __config = GetConfig()
        return __config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest __arrest
RealisticPrisonAndBounty_Arrest property Arrest
    RealisticPrisonAndBounty_Arrest function get()
        if (__arrest)
            return __arrest
        endif

        __arrest = GetArrest()
        return __arrest
    endFunction
endProperty

RealisticPrisonAndBounty_Jail __jail
RealisticPrisonAndBounty_Jail property Jail
    RealisticPrisonAndBounty_Jail function get()
        if (__jail)
            return __jail
        endif

        __jail = GetJail()
        return __jail
    endFunction
endProperty

RealisticPrisonAndBounty_EventManager __eventManager
RealisticPrisonAndBounty_EventManager property EventManager
    RealisticPrisonAndBounty_EventManager function get()
        if (__eventManager)
            return __eventManager
        endif

        __eventManager = GetEventManager()
        return __eventManager
    endFunction
endProperty

RPB_PrisonManager __prisonManager
RPB_PrisonManager property PrisonManager
    RPB_PrisonManager function get()
        if (__prisonManager)
            return __prisonManager
        endif

        __prisonManager = GetPrisonManager()
        return __prisonManager
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager __sceneManager
RealisticPrisonAndBounty_SceneManager property SceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        if (__sceneManager)
            return __sceneManager
        endif

        __sceneManager = GetSceneManager()
        return __sceneManager
    endFunction
endProperty

RPB_API function GetSelf() global
    return GetFormFromMod(0x14C13) as RPB_API
endFunction

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
