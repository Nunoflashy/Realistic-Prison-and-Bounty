Scriptname RPB_Captor extends RPB_ActorBase

;/
@references:
    RPB_Arrest Arrest
    RPB_SceneManager SceneManager
    RPB_ArresteeList ArresteesList
@properties:
    bool IsGuard
    bool IsBountyHunter
    bool IsEscorting
    Form[] Arrestees
    Actor Arrestee
    string Test
@functions:
    RPB_Arrestee[] function GetArrestees()
    function AssignArrestee(Actor akArrestee)
    function RemoveArrestee(RPB_Arrestee apArrestee)
    function AddArrestee(RPB_Arrestee akArresteeRef)
    function FriskArrestee(RPB_Arrestee akArrestee)
    function ArrestActor(Actor akActor)
    function FreeArrestee(RPB_Arrestee akArrestee)
    function RestrainActor(Actor akActor)
    function SetEscorting()
    function StopEscorting()
    Actor function GetActor()
    function Destroy()
@events:
    event OnUpdate()
    event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    event OnBeginState()
    event OnInitialize()
    event OnDeath(Actor akKiller)
    event OnDestroy()
/;

import RPB_Utility
import RPB_Memory
import RPB_Arrest

; ==========================================================
;                      Script References
; ==========================================================

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return API.Arrest
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
    endFunction
endProperty

; ==========================================================
;                          Properties
; ==========================================================

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

RPB_ArresteeList property ArresteesList
    RPB_ArresteeList function get()
        return Arrest.Arrestees
    endFunction
endProperty

int __arrestees
Form[] property Arrestees
    Form[] function get()
        __arrestees = Object_CreateIfNotExists(__arrestees, FastArray("<Form>", retain = true))
        return FastArray_ToFormArray(__arrestees)
    endFunction
endProperty

; event OnDeath(Actor akKiller)
;     Debug("Captor::OnDeath", "The captor has died! (Captor: " + self.Name + ") [Killed by: " + akKiller.GetName() +"]")
;     API.Arrest.OnArrestCaptorDeath(this, akKiller)
; endEvent

;/
    My arrestee is cuffed and waiting for my fight to end (RPB_Arrestee.__BeginPendingArrest). The combat change below
    resumes it; this slow re-check is the safety net for a change I didn't get (one that happened while unloaded).
/;
function WatchPendingArrest()
    RegisterForSingleUpdate(5.0)
endFunction

;/
    Resumes my arrestee's pending arrest once the hostile that kept me busy is dealt with: gone (dead, disabled, unloaded),
    or both of us out of combat. Not on "I'm out of combat" alone: a lull, or a StopCombat, reads the same for a moment
    while the fight goes on. With no hostile recorded (the settle check made it pending), my own combat is all there is.
    The arrestee must be out of combat too: the escort Scene can't start on them otherwise (a player still fought by the
    other hostiles waits, cuffed, until they're dealt with). True if it resumed.
/;
bool function __ResumePendingArrestIfDone()
    RPB_Arrestee arresteeRef = API.Arrest.Arrestees.AtKey(Arrestee)
    if (!arresteeRef || !arresteeRef.GetBool("Arrest Pending"))
        return false
    endif

    ; A dead guard reads as out of combat: OnDeath cancels the arrest instead
    if (this.IsDead())
        return false
    endif

    Actor hostile = arresteeRef.GetForm("Pending Hostile") as Actor
    string why = ""
    if (hostile)
        if (hostile.IsDead())
            why = "the hostile is dead"
        elseif (hostile.IsDisabled())
            why = "the hostile is disabled"
        elseif (!hostile.Is3DLoaded())
            why = "the hostile is unloaded"
        elseif (!this.IsInCombat() && !hostile.IsInCombat())
            why = "the guard and the hostile are both out of combat"
        endif
    elseif (!this.IsInCombat())
        why = "the guard is out of combat"
    endif

    if (why == "" || Arrestee.IsInCombat())
        return false
    endif

    RPB_Utility.Info("Resuming the pending arrest of " + Arrestee + ": " + why)

    arresteeRef.ResumePendingArrest()
    return true
endFunction

event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if (aeCombatState == 0 && Arrestee)
        self.__ResumePendingArrestIfDone()
    endif
endEvent

; Needs to be revised. (Where is the RegisterForSingleUpdate()?)
event OnUpdate()
    if (!Arrestee)
        return
    endif

    RPB_Arrestee pendingRef = API.Arrest.Arrestees.AtKey(Arrestee)
    if (pendingRef && pendingRef.GetBool("Arrest Pending"))
        if (!self.__ResumePendingArrestIfDone())
            RegisterForSingleUpdate(5.0)
        endif
        return
    endif

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

function RemoveArrestee(RPB_Arrestee apArrestee)
    ArresteesList.Remove(apArrestee)
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
endState

state Escorting
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

;/
    Fails the arrest immediately when the guard dies before the arrestee is ever confirmed neutralized, instead of
    leaving her stuck for the ~24s AwaitConfrontationScene()'s own unrelated retry timeout takes to notice and clean
    up on its own (that loop only watches for the arrestee's own death, never the captor's). A real, reproduced test
    hit this: a hostile bandit killed her arresting guard before she was pacified, and kept the RPB_Arrestee effect
    for the full ~24s before ForceResetSceneState() indirectly cleared it.
/;
event OnDeath(Actor akKiller)
    Debug("Captor::OnDeath", "Captor died, releasing arrestees")

    if (!Arrestee)
        ; Died before AssignArrestee ever ran - a narrow window right at the very start of the arrest, before the
        ; link between this Captor and its Arrestee is even made. Nothing to resolve yet; AwaitConfrontationScene()'s
        ; own timeout still eventually reverts the arrest in this rarer case - a known, smaller residual gap.
        return
    endif

    RPB_Arrestee arresteeRef = API.Arrest.AwaitArresteeReference(Arrestee)
    ; arresteeRef.Captor == this doubles today as "no other captors remain for this arrestee" under the current
    ; one-captor-per-arrestee model - the natural place to widen this check once multiple Captors per Arrestee exist.
    if (arresteeRef && arresteeRef.Captor == self)
        ; Nobody takes the arrest over (yet): the arrestee is free, whatever stage it was at. CancelArrest ends their Scenes
        ; (confrontation or escort) without end events and also undoes a prisoner already registered for the escort - a
        ; revert alone left the RPB_Prisoner on them, and that leftover blocked every later arrest ("already arrested").
        RPB_Recovery.CancelArrest(Arrestee, "the captor died")
    endif
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

    ; abRemoveFromList = true: without it the registry keeps a stale entry keyed to this guard's FormID (this was never
    ; actually reached in production before, so the gap never mattered until Destroy() itself got wired up - see
    ; RPB_Prisoner.psc's Imprisoned.OnBeginState()). A guard reused for a later arrest would then find a key that
    ; "already exists," silently keep pointing at this dead instance, and the new one would never get registered.
    ; This has to run FIRST, before anything else here - a real, reproduced test confirmed a guard reused quickly
    ; enough could still hit that exact error when this ran last, after the Wait(0.5) below: RemoveAll()/the wait don't
    ; need to happen before the registry is cleared, so there's no reason to make a new arrest's registration race the
    ; tail end of this cleanup instead of something that already finished.
    API.Arrest.UnregisterCaptor(self, abRemoveFromList = true)

    self.RemoveAll()
    parent.Destroy() ; clears the base "Actor"/"Temporary" categories too - RPB_Prisoner.Destroy() does the same, this never did
    ; A trailing Utility.Wait(0.5) used to sit here, unexplained since a July 2024 refactor - nothing below it ever
    ; existed to protect, and nothing above it needs it either (the registry cleanup above already runs to completion
    ; on its own). It only became a real cost once this function started actually running on every Imprison() (the
    ; CaptorList fix made AwaitCaptorReference/Arrestee==this reliably true instead of hit-or-miss) - removed.
endFunction
