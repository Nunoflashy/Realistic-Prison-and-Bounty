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

; TODO: Add Bounty Hunter support
bool property IsBountyHunter
    bool function get()
        return false
    endFunction
endProperty

bool property IsEscorting
    bool function get()
        return self.GetString("Current State") == "Escorting"
    endFunction
endProperty

; RPB_ArresteeList property Arrestees
;     RPB_ArresteeList function get()
        
;     endFunction
; endProperty

int __arrestees
Form[] property Arrestees
    Form[] function get()
        if (!__arrestees)
            __arrestees = JArray.object()
            JValue.retain(__arrestees)
        endif

        return JArray.asFormArray(__arrestees)
    endFunction
endProperty

; event OnDeath(Actor akKiller)
;     Debug("Captor::OnDeath", "The captor has died! (Captor: " + self.Name + ") [Killed by: " + akKiller.GetName() +"]")
;     API.Arrest.OnArrestCaptorDeath(this, akKiller)
; endEvent

; Needs to be revised. (Where is the RegisterForSingleUpdate()?)
event OnUpdate()
    if (!Arrestee)
        return
    endif
    
    ; if (this.GetDistance(Arrestee) >= 700)
    ;     Arrestee.MoveTo(this)
    ;     Debug("Captor::OnUpdate", "Moved Arrestee to " + Name)

    ; endif
    ; RegisterForSingleUpdate(5.0)

    ; Keep track of the arrestee's distance to the captor,
    ; only if we are in the Bounty Payment scenario
    if (API.Arrest.GetActorIsPayingBounty(Arrestee))
        if (this.GetDistance(Arrestee) >= 800)
            API.Arrest.PunishPaymentEvader(this, Arrestee)
        endif
    
        RegisterForSingleUpdate(5.0)
    endif
endEvent

RPB_Arrestee[] function GetArrestees()
    return none
endFunction

; Actor _arrestee = none ; Temp, later this must be an array since a captor can have N arrestees (1:N)

Actor property Arrestee
    Actor function get()
        return self.GetForm("Arrestee") as Actor
    endFunction
endProperty

function AssignArrestee(Actor akArrestee)
    ; _arrestee = akArrestee
    self.SetForm("Arrestee", akArrestee)
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

function SetEscorting()
    Debug("Captor::SetEscorting", "Set escorting from " + Name)

    self.SetString("Current State", "Escorting")
    RegisterForSingleUpdate(5.0)
    GotoState("Escorting")
endFunction

function StopEscorting()
    UnregisterForUpdates()
    GotoState("Inactive")

endFunction

; ==========================================================
;                           States
; ==========================================================

state Inactive
    event OnBeginState()
        Debug("[state: Inactive] Captor::OnBeginState", "Captor is now inactive")
    endEvent

    event OnUpdate()
    endEvent
endState

state Escorting
    event OnUpdate()
        return
        if (this.GetDistance(Arrestee) >= 700)
            Arrestee.MoveTo(this)
            Debug("Captor::OnUpdate", "Moved Arrestee to " + Name)
    
        endif
        RegisterForSingleUpdate(5.0)
    endEvent
endState

; ==========================================================
;                           Events
; ==========================================================

event OnInitialize()
    API.Arrest.RegisterCaptor(self)
    Debug("Captor::OnInitialize", "Initialized Captor, this: " + this)

    if (self.IsEscorting)
        GotoState("Escorting")
        RegisterForSingleUpdate(5.0)
        return
    endif

    RegisterForSingleUpdate(5.0)
endEvent

event OnDeath(Actor akKiller)
    Debug("Captor::OnDeath", "Captor died, releasing arrestees")
    API.Arrest.GetArresteeReference(Arrestee).RevertArrest()
endEvent

event OnDestroy()
    if (this.IsDead())
        OnDeath(none)
    endif
endEvent

Actor function GetActor()
    return this
endFunction

; ==========================================================
;                           Management
; ==========================================================

string _test
string property Test
    string function get()
        return _test
    endFunction
endProperty

function Destroy()
    ; Unset all properties related to this captor
    _test = "Gata"
    self.RemoveAll()
    Utility.Wait(0.5)
    API.Arrest.UnregisterCaptor(self)
endFunction
