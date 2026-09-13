scriptname RPB_Hold extends RPB_Entity
{
    @property int ID
    @property string UUID
    @property string Name
    @property bool Active

    @property Faction CrimeFaction
    @property Form[] Locations
    @property string[] Cities
    @property Alias[] Prisons
    @property RPB_ArresteeList Arrestees
    @property RPB_CaptorList Captors
}

import Math
import RPB_Config
import RPB_Utility

; ==========================================================
;                     Script References
; ==========================================================

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

RPB_Config property Config
    RPB_Config function get()
        return API.Config
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
    endFunction
endProperty

; ==========================================================
;                        Hold Identity
; ==========================================================

string property Name
    string function get()
        return self.TryGetString("Name")
    endFunction
endProperty

Faction property CrimeFaction
    Faction function get()
        return self.TryGetForm("Crime Faction") as Faction
    endFunction
endProperty

Form[] property Locations
    Form[] function get()
        return self.GetPropertyOfTypeFormArray("Locations")
    endFunction
endProperty

string[] property Cities
    string[] function get()
        return self.GetPropertyOfTypeStringArray("Cities")
    endFunction
endProperty

Alias[] property Prisons
    Alias[] function get()
        ; return PrisonManager.GetPrisonsForHold(self)
    endFunction
endProperty

; ==========================================================
;                          Properties
; ==========================================================

RPB_ArresteeList property Arrestees
    RPB_ArresteeList function get()
        return ((self as ReferenceAlias) as RPB_ActiveMagicEffectContainer) as RPB_ArresteeList
    endFunction
endProperty

RPB_CaptorList property Captors
    RPB_CaptorList function get()
        return ((self as ReferenceAlias) as RPB_ActiveMagicEffectContainer) as RPB_CaptorList
    endFunction
endProperty

; ==========================================================
;                      Arrest Topic Types
; ==========================================================

int property TOPIC_START    = 0 autoreadonly
int property TOPIC_END      = 1 autoreadonly

int property TOPIC_TYPE_ARREST_SUSPICIOUS                       = 5 autoreadonly
int property TOPIC_TYPE_ARREST_DIALOGUE_ELUDING                 = 6 autoreadonly
int property TOPIC_TYPE_ARREST_PURSUIT_ELUDING                  = 7 autoreadonly
int property TOPIC_TYPE_ARREST_CONFRONT                         = 10 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT               = 11 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_WILLINGLY      = 12 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED       = 13 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_MAX                   = 14 autoreadonly
int property TOPIC_TYPE_ARREST_RESIST                           = 15 autoreadonly
int property TOPIC_TYPE_COMBAT_YIELD                            = 16 autoreadonly
int property TOPIC_TYPE_ARREST_GO_TO_JAIL                       = 20 autoreadonly

; ==========================================================
;                 Arrest Pay Bounty Scenarios
; ==========================================================

string property ARREST_PAY_BOUNTY_ON_SPOT           = "ArrestPayOnSpot" autoreadonly
string property ARREST_PAY_BOUNTY_ESCORT_WILLINGLY  = "ArrestEscortWillingly" autoreadonly
string property ARREST_PAY_BOUNTY_ESCORT_BY_FORCE   = "ArrestEscortByForce" autoreadonly

; ==========================================================
;                         Arrest Types
; ==========================================================

string property ARREST_TYPE_TELEPORT_TO_JAIL    = "TeleportToJail" autoreadonly
string property ARREST_TYPE_TELEPORT_TO_CELL    = "TeleportToCell" autoreadonly
string property ARREST_TYPE_ESCORT_TO_JAIL      = "EscortToJail" autoreadonly
string property ARREST_TYPE_ESCORT_TO_CELL      = "EscortToCell" autoreadonly

; ==========================================================
;                         Arrest Goals
; ==========================================================

string property ARREST_GOAL_IMPRISONMENT        = "Imprisonment" autoreadonly
string property ARREST_GOAL_BOUNTY_PAYMENT      = "BountyPayment" autoreadonly
string property ARREST_GOAL_TEMPORARY_HOLD      = "TemporaryHold" autoreadonly ; Unused for Now, later will be used to hold suspects (temporary imprisonment, short term), should they be considered a RPB_Prisoner though?


; ==========================================================
;                         Arrestees
; ==========================================================

;/
    Awaits a reference of RPB_Arrestee for the specified Actor.
    If the Actor is not an Arrestee yet, they will be made into one and bound to this Hold. 

    Actor   @akArrestee: The actor to retrieve the Arrestee reference from.
    int?    @aiMaxTries: How many attempts retrieving the reference, in case it fails initially.
    float?  @afInitialTimeBetweenTries: The delay on each try
    float?  @afMaxTimeBetweenTries: The max delay on each try that is possible (Exponential Backoff).
    bool?   @abDelayExecution: Whether to delay before obtaining a reference to the Arrestee.
/;
RPB_Arrestee function AwaitArresteeReference(Actor akArrestee, int aiMaxTries = 50, float afInitialTimeBetweenTries = 0.1, float afMaxTimeBetweenTries = 3.0)
    RPB_Utility.EnsureArresteeSpellAndBinding(akArrestee, self)

    RPB_Arrestee arresteeRef = Arrestees.AtKey(akArrestee)
    int tries = 0
    float delay = afInitialTimeBetweenTries

    ; Safeguard
    while (!arresteeRef && tries < aiMaxTries)
        arresteeRef = Arrestees.AtKey(akArrestee)
        Utility.Wait(delay)
        tries += 1
        delay *= 1.5
        if (delay > afMaxTimeBetweenTries)
            delay = afMaxTimeBetweenTries
        endif
    endWhile

    if (!arresteeRef)
        DebugError("Hold::AwaitArresteeReference", "The Actor " + akArrestee + " is not an arrestee or there was a state mismatch!")
        Error(akArrestee.GetBaseObject().GetName() + " is not an arrestee or there was a state mismatch!")
        return none
    endif

    return arresteeRef
endFunction

; ==========================================================
;                           Arrest
; ==========================================================

event OnArrestBegin(RPB_Arrestee apArrestee, RPB_Captor apCaptor, string asArrestType)
    if (apArrestee.IsArrested)
        Config.NotifyArrest("You are already under arrest.", apArrestee.IsPlayer())
        Error(apArrestee.GetName() + " has already been arrested, cannot arrest for "+ CrimeFaction.GetName() +", aborting!")
        return
    endif

    if (apArrestee.IsImprisoned)
        Config.NotifyArrest("You are already in prison.", apArrestee.IsPlayer())
        Error(apArrestee.GetName() + " has already been arrested, and is currently in prison. Cannot arrest for "+ CrimeFaction.GetName() +", aborting!")
        return
    endif

endEvent

; ==========================================================
;                        Hold Manager
; ==========================================================

RPB_Hold function GetHoldForCrimeFaction(Faction akCrimeFaction) global
    Quest holdManager = GetFormFromMod(0x1B825) as Quest ; placeholder
    int holdSlots = holdManager.GetNumAliases()

    int i = 0
    while (i < holdSlots)
        RPB_Hold hold = holdManager.GetNthAlias(i) as RPB_Hold
        if (hold.CrimeFaction == akCrimeFaction)
            return hold
        endif
        i += 1
    endWhile

    return none
endFunction