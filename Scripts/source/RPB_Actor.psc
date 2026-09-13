scriptname RPB_Actor extends RPB_ActorBase
{
    Represents an Actor that is not an Arrestee nor a Prisoner,
    this is a regular Actor.
}

import Math
import RPB_Utility
import RPB_Memory

; ==========================================================
;                        Attached Scripts
; ==========================================================
;/
    Attached Scripts are scripts that are bound to this Actor,
    which must be of type RPB_ActorScript.

    This allows the system to have multiple scripts for different functionality
    for a particular RPB_Actor.
/;

RPB_BountyDecayable __bountyDecayable

; ==========================================================
;                          Properties
; ==========================================================

RPB_ActorList property TrackedActors
    RPB_ActorList function get()
        return API.ActorListForTrackedActors
    endFunction
endProperty

; ==========================================================
;                           States
; ==========================================================

state Inactive
    event OnUpdate()
    endEvent

    event OnUpdateGameTime()
    endEvent

    event OnLocationChange(Location akOldLocation, Location akNewLocation)
    endEvent
endState

; ==========================================================
;                           Events
; ==========================================================

event OnInitialize()
    self.RegisterForTrackedStats()
    self.RegisterActorForTracking()
endEvent


event OnBountyGained()
endEvent

event OnStatChanged(string asStatName, float afValue)
    string[] holds = Config.Holds
    int i = 0

    while (i < holds.Length)
        string hold = holds[i]
        string holdBountyStat = hold + " Bounty"

        ; if (asStatName == holdBountyStat)
        ;     Faction holdCrimeFaction = Config.GetFaction(hold)
        ;     parent.SyncLargestBountyForFaction(holdCrimeFaction)
        ;     parent.ModTotalBountyForFaction(holdCrimeFaction, afValue as int)
        ; endif

        i += 1
    endWhile
endEvent

; ==========================================================
;                          Functions
; ==========================================================

;                         Script States
; ==========================================================

;/
    Applies a script state to this Actor, that is of type RPB_ActorScript.

    A script state allows for multiple scripts to be bound to the same Actor,
    and their state referenced and managed.

    RPB_ActorScript @apScriptState: The script state to apply.
/;
function ApplyScriptState(RPB_ActorScript apScriptState)
    if (apScriptState as RPB_BountyDecayable)
        __bountyDecayable = apScriptState as RPB_BountyDecayable
    endif
endFunction

;/
    Removes a script state from this Actor, that is of type RPB_ActorScript.

    RPB_ActorScript @apScriptState: The script state to remove.
/;
function RemoveScriptState(RPB_ActorScript apScriptState)
    if (apScriptState as RPB_BountyDecayable)
        __bountyDecayable = none
    endif
endFunction

function RemoveScriptStateFromTag(string asScriptStateTag)
    RPB_ActorScript scriptState = self.GetScriptState(asScriptStateTag)

    if (!scriptState)
        API.EventManager.SendError("Could not find script state with tag " + asScriptStateTag, "["+ self +"] Actor::RemoveScriptStateFromTag")
        return
    endif

    self.RemoveScriptState(scriptState)
endFunction

;/
    Returns a script state from this Actor, that is of type RPB_ActorScript.

    string @asScriptStateTag: The script state tag of type to return.

    returns (RPB_ActorScript): The script state of the specified type from this Actor.
/;
RPB_ActorScript function GetScriptState(string asScriptStateTag)
    if (asScriptStateTag == RPB_BountyDecayable.className())
        return __bountyDecayable
    endif

    return none
endFunction

;                          Management
; ==========================================================

function ApplyEffect(Actor akTargetActor) global
    if (!akTargetActor.HasSpell(RPB_ActorSpell()))
        akTargetActor.AddSpell(RPB_ActorSpell(), false)
    endif

    ; self.EnableMonitoring()
endFunction

function RemoveEffect(Actor akTargetActor) global
    akTargetActor.RemoveSpell(RPB_ActorSpell())
    ; self.DisableMonitoring()
endFunction

function RegisterActorForTracking()
    ; Debug("Actor::RegisterActorForTracking", "["+ self +"] Registering Actor for Tracking (this: " + this + ")")
    TrackedActors.AddElement(self, this)
    ; Debug("Actor::RegisterActorForTracking", "["+ self +"] Contents: " + TrackedActors.GetKeys())
endFunction

;/
    Returns the RPB_Actor reference for the specified Actor.

    Actor @akActor: The Actor to get the RPB_Actor reference for.

    returns (RPB_Actor): The RPB_Actor reference for the specified Actor.
/;
RPB_Actor function GetActorStateReference(Actor akActor) global
    return RPB_API.GetActorListForTrackedActors().AtKeyEx(akActor) as RPB_Actor
endFunction