Scriptname RPB_Captor extends RPB_Actor  

import RealisticPrisonAndBounty_Config

bool property IsGuard
    bool function get()
        return this.IsGuard()
    endFunction
endProperty

event OnDeath(Actor akKiller)

endEvent

RPB_Arrestee[] function GetArrestees()
    return none
endFunction

function AddArrestee(RPB_Arrestee akArresteeRef)

endFunction

function FriskArrestee(RPB_Arrestee akArrestee)
    
endFunction

function ArrestActor(Actor akActor)
    
endFunction

function FreeArrestee(RPB_Arrestee akArrestee)

endFunction

function RestrainActor(Actor akActor)

endFunction



