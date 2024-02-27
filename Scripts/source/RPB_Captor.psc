Scriptname RPB_Captor extends RPB_Actor

import RPB_Utility
import RPB_Arrest

RPB_API __api
RPB_API property API
    RPB_API function get()
        if (__api)
            return __api
        endif

        __api = RPB_API.GetSelf()
        return __api
    endFunction
endProperty


bool property IsGuard
    bool function get()
        return this.IsGuard()
    endFunction
endProperty

event OnDeath(Actor akKiller)
    Debug("Captor::OnDeath", "The captor has died! (Captor: " + self.Name + ") [Killed by: " + akKiller.GetName() +"]")
    API.Arrest.OnArrestCaptorDeath(this, akKiller)
endEvent

; Needs to be revised. (Where is the RegisterForSingleUpdate()?)
event OnUpdate()
    if (!_arrestee)
        return
    endif

    ; Keep track of the arrestee's distance to the captor,
    ; only if we are in the Bounty Payment scenario
    if (API.Arrest.GetActorIsPayingBounty(_arrestee))
        if (this.GetDistance(_arrestee) >= 800)
            API.Arrest.PunishPaymentEvader(this, _arrestee)
        endif
    
        RegisterForSingleUpdate(5.0)
    endif
endEvent

RPB_Arrestee[] function GetArrestees()
    return none
endFunction

Actor _arrestee = none ; Temp, later this must be an array since a captor can have N arrestees (1:N)

function AssignArrestee(Actor akArrestee)
    _arrestee = akArrestee
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



