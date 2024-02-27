scriptname RPB_API extends Quest Hidden

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

RPB_Config __config
RPB_Config property Config
    RPB_Config function get()
        if (__config)
            return __config
        endif

        __config = GetConfig()
        return __config
    endFunction
endProperty

RPB_Arrest __arrest
RPB_Arrest property Arrest
    RPB_Arrest function get()
        if (__arrest)
            return __arrest
        endif

        __arrest = GetArrest()
        return __arrest
    endFunction
endProperty

RPB_EventManager __eventManager
RPB_EventManager property EventManager
    RPB_EventManager function get()
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

RPB_SceneManager __sceneManager
RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
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

RPB_Config function GetConfig() global
    return GetFormFromMod(0x3317) as RPB_Config
endFunction

RPB_Arrest function GetArrest() global
    return GetFormFromMod(0x3DF8) as RPB_Arrest
endFunction

RPB_PrisonManager function GetPrisonManager() global
    return GetFormFromMod(0x1B825) as RPB_PrisonManager
endFunction

RPB_SceneManager function GetSceneManager() global
    return GetFormFromMod(0xC9F5) as RPB_SceneManager
endFunction

RPB_EventManager function GetEventManager() global
    return GetFormFromMod(0xEA67) as RPB_EventManager
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
