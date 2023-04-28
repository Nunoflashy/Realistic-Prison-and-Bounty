scriptname RealisticPrisonAndBounty_Arrest extends Quest

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

function RegisterEvents()
    RegisterForModEvent("ArrestBegin", "OnArrestBegin")
    RegisterForModEvent("ArrestEnd", "OnArrestEnd")
endFunction

event OnInit()
    RegisterEvents()
endEvent

event OnPlayerLoadGame()
    RegisterEvents()
endEvent

event OnArrestBegin(string eventName, string strArg, float numArg, Form sender)
    Actor captor = (sender as Actor)
    if (!captor)
        Error(self, "OnArrestBegin", "Captor is invalid ("+ captor +"), cannot start arrest process!")
        return
    endif

    Debug(self, "OnArrestBegin", "Beginning arrest process for Actor: ")

endEvent

event OnArrestEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnArrestEnd", "Ending arrest process for Actor: ")
endEvent
