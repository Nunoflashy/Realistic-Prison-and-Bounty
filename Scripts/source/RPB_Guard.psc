Scriptname RPB_Guard extends RPB_Actor  

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

function ReleasePrisoner(RPB_Prisoner akPrisoner)

endFunction

; Not sure what this function will do exactly as there's no context
function EscortPrisoner(RPB_Prisoner akPrisoner, string asScene) ; Maybe later have an RPB_Scene script?

endFunction

; The prison cells this guard is overseeing
RPB_JailCell[] function GetCells()

endFunction

event OnDeath(Actor akKiller)

endEvent



