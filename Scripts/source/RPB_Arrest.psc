scriptname RPB_Arrest extends Quest

;/
@constants:
    int TOPIC_START
    int TOPIC_END
    int TOPIC_TYPE_ARREST_SUSPICIOUS
    int TOPIC_TYPE_ARREST_DIALOGUE_ELUDING
    int TOPIC_TYPE_ARREST_PURSUIT_ELUDING
    int TOPIC_TYPE_ARREST_CONFRONT
    int TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT
    int TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_WILLINGLY
    int TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED
    int TOPIC_TYPE_ARREST_PAY_BOUNTY_MAX
    int TOPIC_TYPE_ARREST_RESIST
    int TOPIC_TYPE_COMBAT_YIELD
    int TOPIC_TYPE_ARREST_GO_TO_JAIL
    string ARREST_PAY_BOUNTY_ON_SPOT
    string ARREST_PAY_BOUNTY_ESCORT_WILLINGLY
    string ARREST_PAY_BOUNTY_ESCORT_BY_FORCE
    string ARREST_TYPE_TELEPORT_TO_JAIL
    string ARREST_TYPE_TELEPORT_TO_CELL
    string ARREST_TYPE_ESCORT_TO_JAIL
    string ARREST_TYPE_ESCORT_TO_CELL
    string ARREST_GOAL_IMPRISONMENT
    string ARREST_GOAL_BOUNTY_PAYMENT
    string ARREST_GOAL_TEMPORARY_HOLD
    int CAN_BE_ARRESTED
    int ALREADY_ARRESTED
    int ALREADY_IMPRISONED
    int CAN_ARREST
    int ALREADY_ARRESTING
    float SURRENDER_EXPIRE_SECONDS
    float SURRENDER_LEAVE_DISTANCE
    float SURRENDER_TAKEN_DISTANCE
    int SURRENDER_SCENE_RETRIES
@references:
    RPB_API API
    RPB_Config Config
    RPB_EventManager EventManager
    RPB_SceneManager SceneManager
    RPB_ArresteeList Arrestees
    RPB_CaptorList Captors
@properties:
    string LastSurrenderOutcome
    bool ShouldDisplayArrestNotifications
    bool ShouldDisplayBountyDecayNotifications
@functions:
    function SetReferenceStateInt(string asReference, string asStateProperty, int aiValue)
    function SetReferenceStateFloat(string asReference, string asStateProperty, float afValue)
    function SetReferenceStateString(string asReference, string asStateProperty, string asValue)
    int function GetReferenceStateInt(string asReference, string asStateProperty)
    float function GetReferenceStateFloat(string asReference, string asStateProperty)
    string function GetReferenceStateString(string asReference, string asStateProperty)
    function RemoveReferenceState(string asReference, string asStateProperty)
    RPB_Arrestee function AwaitArresteeReference(Actor akArrestee, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    bool function RegisterArrestee(RPB_Arrestee apArrestee)
    function UnregisterArrestee(RPB_Arrestee apArrestee)
    RPB_Captor function AwaitCaptorReference(Actor akCaptor, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    RPB_Captor function GetCaptor(Actor akCaptor)
    bool function RegisterCaptor(RPB_Captor apCaptor)
    function ReleaseCaptorOf(Actor akGuard, Actor akArrestee, bool abFreeGuard = false)
    function UnregisterCaptor(RPB_Captor apCaptor, bool abRemoveFromList = false)
    function SetArrestScene(Actor akArrestee, string asSceneName)
    function SetArrestGoal(Actor akArrestee, string asArrestGoal)
    function ArrestActor(Actor akArrester, Actor akArrestee, string asArrestType)
    function ArrestActorForFaction(Faction akCrimeFaction, Actor akArrestee, string asArrestType)
    function ArrestActors(Actor akArrester, Actor[] akArrestees, string asArrestType, bool abEnsureAllArrested = true, float afWaitTimeBetweenArrests = 0.3)
    function SetAsEluding(Actor akEludedGuard, Actor akEluder, string asEludeType)
    function SetAsResisting(Actor akGuard, Actor akResister)
    function SetAsYielding(Actor akSparerGuard, Actor akYieldedArrestee)
    function StartBountyPayment(Actor akGuard, Actor akPayerArrestee, string asBountyPaymentScenario)
    function Surrender(Actor akSurrenderer)
    bool function CanActorSurrender(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    bool function IsSurrenderGuard(Actor akActor)
    bool function HasSurrenderGuard(Actor[] akCombatTargets)
    Actor function GetNonGuardCombatTarget(Actor[] akCombatTargets)
    Actor[] function GetSurrenderGuards(Actor[] akCombatTargets)
    bool function IsSurrendering(Actor akActor)
    function AbortSurrender(Actor akSurrenderer, string asReason, bool abEndScene = true)
    function OnSurrenderSceneFailed(Actor akSurrenderer)
    bool function HasFakedSurrenderTo(Actor akActor, Faction akFaction)
    float function GetFakedSurrenderUntil(Actor akActor, Faction akFaction)
    function ForgetFakeSurrenders(Actor akActor)
    function ApplySurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    function ApplyFakeSurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    function PrepareSurrenderer(Actor akSurrenderer, Actor[] akGuards = none)
    function InitiateSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    int function GetActorArrestStatus(Actor akActor)
    function BeginArrest(RPB_Arrestee apArresteeRef)
    function PunishPaymentEvader(Actor akGuard, Actor akPayerArrestee)
    function ChangeArrestEscort(Actor akNewEscort, Actor akDetainee)
    function ApplyArrestResistedPenalty(Faction akArrestFaction)
    function SetAsDefeated(Faction akCrimeFaction)
    function SetResistedFlag(Faction akFaction)
    function SetEludedFlag(Faction akFaction)
    function ResetResistedFlag()
    function ResetEludedFlag()
    function ApplyArrestEludedPenalty(Faction akArrestFaction)
    function ApplyArrestDefeatedPenalty(Faction akArrestFaction)
    bool function MeetsPursuitEludeRequirements(Actor akEluder)
    bool function HasResistedArrestRecently(Faction akArrestFaction)
    bool function HasEludedArrestRecently(Faction akArrestFaction)
    function SetEludedGuard(Actor akEludedGuard, string asEludeType)
    function TriggerForcegreetEluding(Actor akEludedGuard)
    function TriggerPursuitEluding(Actor akEludedGuard)
    function SetActorWantsToPayBounty(Actor akPayerArrestee, bool abWantsToPay = true)
    bool function GetActorIsPayingBounty(Actor akPayerArrestee)
    string function GetArrestScene(Actor akArrestee, string asFallbackScene = "RPB_ArrestStart02")
    string function GetArrestGoal(Actor akArrestee)
    bool function IsActorToBeImprisoned(Actor akArrestee)
    bool function IsActorToPayBounty(Actor akArrestee)
    function PayCrimeGold(Actor akPayer, Faction akCrimeFaction)
    function ResetArrest(string reason = "")
    function RegisterForDelayedEvent(string stateName, float delaySeconds)
    function RegisterForDelayedEventGameTime(string stateName, float delayGameTime)
    function RestrainArrestee(Actor akArrestee)
    function UnrestrainArrestee(Actor akRestrainedArrestee)
    function RegisterHotkeys()
    function EnableForcedArrestDialogue() global
    function DisableForcedArrestDialogue() global
    function AllowArrestForcegreets(bool allow = true) global
    function SetupArrestPayableBountyVars(Faction akCrimeFaction)
    function ResetDiceRollForMaxPayableBounty() global
    bool function IsValidArrestGoal(string asArrestGoal)
    bool function ValidateArrestType(string arrestType)
    string function GetValidArrestTypes()
    function NotifyArrest(string msg, bool condition = true)
    function NotifyBounty(string msg, bool condition = true)
@events:
    event OnInit()
    event OnKeyDown(int keyCode)
    event OnControlDown(string asControl)
    event OnArresting(Actor akCaptor, Actor akArrestee)
    event OnArrestDialogue(int aiTopicInfoEvent, int aiTopicInfoType, string asTopicInfoDialogue, Actor akSpeakerArrester, Actor akSpokenToArrestee)
    event OnSurrenderBegin(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    event OnSurrenderEnd(Actor akSurrenderer, Actor akCaptor)
    event OnArrestPreparing(Actor akArrestee, Actor akCaptor, Faction akCrimeFaction, string asArrestType)
    event OnArrestBegin(RPB_Arrestee apArrestee, RPB_Captor apCaptor, Faction akCrimeFaction, string asArrestType)
    event OnArrestEnd(RPB_Arrestee apArrestee, RPB_Captor apCaptor, Faction akCrimeFaction)
    event OnArrestEludeStart(Actor akEludedGuard, string asEludeType)
    event OnArrestEludeTriggered(Actor akEludedGuard, string asEludeType)
    event OnArrestResist(Actor akArrestResister, Actor akGuard, Faction akCrimeFaction)
    event OnArrestPayBounty(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, string asPayBountyScenario)
    event OnArrestDefeat(Actor akAttacker)
    event OnArrestCaptorDeath(Actor akCaptor, Actor akCaptorKiller)
    event OnCombatYield(Actor akGuard, Actor akYieldedArrestee)
    event OnArrestPayBountyEnd(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, bool abEscortedForcefully)
    event OnArrestSceneChanged(Actor akArrestee, string asSceneName)
    event OnArrestGoalChanged(Actor akArrestee, string asOldArrestGoal, string asNewArrestGoal)
    event OnArrestFailed(Actor akCaptor, Actor akArrestee, string asFailReason)
    event OnUpdateGameTime()
    event OnActorArrested(RPB_Arrestee apArrestee, RPB_Captor apArrestGuard)
    event OnArresteeDeath(RPB_Arrestee apArrestee, RPB_Captor apArrestGuard, Actor akKiller)
    event OnArresteeRestrained(RPB_Arrestee apArrestee)
    event OnArresteeFreed(RPB_Arrestee apArrestee, RPB_Captor apCaptor)
    event OnBeginState()
    event OnUpdate()
    event OnEndState()
/;

import Math
import RPB_Config
import PO3_SKSEFunctions
import RPB_Utility

; ==========================================================
;                      Script References
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

RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
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
;                       Arrest Status
; ==========================================================

int property CAN_BE_ARRESTED = 0 autoreadonly
int property ALREADY_ARRESTED = 1 autoreadonly
int property ALREADY_IMPRISONED = 2 autoreadonly

; ==========================================================
;                       Captor Status
; ==========================================================

int property CAN_ARREST         = 0 autoreadonly
int property ALREADY_ARRESTING  = 1 autoreadonly

; ==========================================================
;                           Lists
; ==========================================================

;/
    Reference to container to store every possible Arrestee's state Script,
    this makes it possible to retrieve this script's actions that are attached to the Actor that is arrested
    without having them been passed through an Event.

    Making it possible then to do something like this in another script to control the behavior of an Arrestee:
        RPB_Arrestee arresteeRef = Arrestees.GetAt(akArrestee) as RPB_Arrestee

    Since we can add or remove this reference from the list through this script, 
    it also makes it possible to manage the lifetime of this object through an individual Arrestee script attached to the Actor,
    instead of managing it in some other script and checking for the Actor's state.
/;
RPB_ArresteeList property Arrestees
    RPB_ArresteeList function get()
        return self.GetAliasByName("ArresteeList") as RPB_ArresteeList
    endFunction
endProperty

RPB_CaptorList property Captors
    RPB_CaptorList function get()
        return self.GetAliasByName("CaptorList") as RPB_CaptorList
    endFunction
endProperty

; =========================================================
;                       State Registry                      
; =========================================================

function SetReferenceStateInt(string asReference, string asStateProperty, int aiValue)
    RPB_StorageVars.SetIntOnReference(asStateProperty, asReference, aiValue, "Arrest::State")
endFunction

function SetReferenceStateFloat(string asReference, string asStateProperty, float afValue)
    RPB_StorageVars.SetFloatOnReference(asStateProperty, asReference, afValue, "Arrest::State")
endFunction

function SetReferenceStateString(string asReference, string asStateProperty, string asValue)
    RPB_StorageVars.SetStringOnReference(asStateProperty, asReference, asValue, "Arrest::State")
endFunction

int function GetReferenceStateInt(string asReference, string asStateProperty)
    return RPB_StorageVars.GetIntOnReference(asStateProperty, asReference, "Arrest::State")
endFunction

float function GetReferenceStateFloat(string asReference, string asStateProperty)
    return RPB_StorageVars.GetFloatOnReference(asStateProperty, asReference, "Arrest::State")
endFunction

string function GetReferenceStateString(string asReference, string asStateProperty)
    return RPB_StorageVars.GetStringOnReference(asStateProperty, asReference, "Arrest::State")
endFunction

function RemoveReferenceState(string asReference, string asStateProperty)
    RPB_StorageVars.DeleteVariableOnReference(asStateProperty, asReference, "Arrest::State")

    bool hasStates = RPB_StorageVars.HasVarsOnReference(asReference, "Arrest::State")

    if (!hasStates)
        RPB_StorageVars.DeleteCategoryOnReference(asReference, "Arrest::State")
    endif
endFunction

; ==========================================================
;                   Config-specific Methods
; ==========================================================

; ==========================================================
;                   Actor-specific Methods
; ==========================================================

; ==========================================================
;                  Arrestee-specific Methods
; ==========================================================

;/
    Awaits a reference of RPB_Arrestee for the specified Actor.
    If the Actor is not an Arrestee yet, they will be made into one. 

    Actor   @akArrestee: The actor to retrieve the Arrestee reference from.
    int?    @aiMaxTries: How many attempts retrieving the reference, in case it fails initially.
    float?  @afInitialTimeBetweenTries: The delay on each try
    float?  @afMaxTimeBetweenTries: The max delay on each try that is possible (Exponential Backoff).
/;
RPB_Arrestee function AwaitArresteeReference(Actor akArrestee, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    return RPB_Utility.AwaitEntityReference(akArrestee, Arrestees, none, aiMaxTries, afInitialTimeBetweenTries, afMaxTimeBetweenTries) as RPB_Arrestee
endFunction

;/
    Binds @akArrestee to an instance of RPB_Arrestee,
    giving us the arrest state of the Actor bound to this reference.

    Used when this Actor is Arrested, lasts until Release or Imprisonment.
/;
bool function RegisterArrestee(RPB_Arrestee apArrestee)
    Arrestees.Add(apArrestee)
    return Arrestees.Exists(apArrestee)
endFunction

;/
    Removes the Arrestee spell (and consequently, the MagicEffect) from this arrestee.
/;
function UnregisterArrestee(RPB_Arrestee apArrestee)
    ; Remove the spell from the arrestee
    Spell arrestSpell = RPB_Utility.RPB_ArresteeSpell()
    if (apArrestee.HasSpell(arrestSpell))
        apArrestee.RemoveSpell(arrestSpell)
    endif

    if (apArrestee && Arrestees.Exists(apArrestee))
        Arrestees.Remove(apArrestee)
    endif
endFunction

; ==========================================================

; ==========================================================
;                  Captor-specific Methods
; ==========================================================

;/
    Awaits a reference of RPB_Captor for the specified Actor.
    If the Actor is not a Captor yet, they will be made into one. 

    Actor   @akCaptor: The actor to retrieve the Captor reference from.
    int?    @aiMaxTries: How many attempts retrieving the reference, in case it fails initially.
    float?  @afInitialTimeBetweenTries: The delay on each try
    float?  @afMaxTimeBetweenTries: The max delay on each try that is possible (Exponential Backoff).
/;
RPB_Captor function AwaitCaptorReference(Actor akCaptor, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    return RPB_Utility.AwaitEntityReference(akCaptor, Captors, none, aiMaxTries, afInitialTimeBetweenTries, afMaxTimeBetweenTries) as RPB_Captor
endFunction

;/
    Looks up an already-registered Captor without ever creating one - unlike AwaitCaptorReference(), which always
    calls EnsureCaptorSpellAndBinding() first (create-if-missing semantics). That's right for a genuine new arrest,
    but wrong for a caller that only wants to know "is this guard still a live Captor" (e.g. tearing one down once a
    prisoner it escorted is imprisoned): if the guard's own 3D happens to be unloaded at that exact moment, forcing a
    fresh registration attempt can never complete off-screen and burns a real multi-second grace window before
    erroring - confirmed by a real test ("<Guard> is not loaded, cannot be registered right now!") right after an
    off-screen imprisonment. Mirrors RPB_Prison.GetPrisoner(), which already uses AwaitExistingEntityReference() for
    the identical reason.

    Actor @akCaptor: the guard to look up.

    returns (RPB_Captor): the guard's live Captor instance, or none if they aren't currently one.
/;
RPB_Captor function GetCaptor(Actor akCaptor)
    ; A direct, instant presence check - not AwaitExistingEntityReference(), whose only difference is polling for up
    ; to 12s if the very first lookup misses. There's no "still registering" race for this function to wait out: by
    ; the time anything calls GetCaptor(), the entry either still exists or it's already gone (the guard was
    ; reassigned, or its own AME instance was torn down while off-screen) - waiting can't make an absent entry
    ; reappear, only stall the caller. Confirmed as the cause of real ~12-13s Prisoner::Imprison stalls (test 94):
    ; Imprisoned.OnBeginState() calls this near the top of the same event whose last line sets the "Imprisoned" flag
    ; every mass-run/settle test polls, so a stall here shows up directly as an imprisonment stall.
    return Captors.AtKeyEx(akCaptor) as RPB_Captor
endFunction

;/
    Binds @akCaptorRef to an instance of RPB_Captor,
    giving us the captor state of the Actor bound to this reference.

    Used when this Actor is arresting an Actor, lasts until Escort end or Death.
/;
bool function RegisterCaptor(RPB_Captor apCaptor)
    Captors.Add(apCaptor)
    return Captors.Exists(apCaptor)
endFunction

;/
    Removes the Captor spell (and consequently, the MagicEffect) from this Captor.
    Optionally removes it from the Captors list.

    RPB_Captor  @apCaptor: The Captor to unregister.
    bool?       @abRemoveFromList: Whether to also remove the Captor from the list.
/;
;/
    Tears down @akGuard's Captor if its Arrestee is still @akArrestee (Prisoner.ClearArrest, at the imprisonment). On the
    RPB_ReleaseCaptor event's own stack: the lookup calls into the guard, and a frozen guard (his Papyrus object never
    answers) used to hang the imprisonment right there - locked in the cell, never imprisoned, the Stats page blank.
/;
function ReleaseCaptorOf(Actor akGuard, Actor akArrestee, bool abFreeGuard = false)
    if (!akGuard || RPB_Utility.IsFrozenGuard(akGuard))
        return
    endif
    RPB_Recovery.__Step(akArrestee, "ReleaseCaptor: looking up the Captor of " + akGuard)
    RPB_Captor captorRef = self.GetCaptor(akGuard)
    RPB_Recovery.__Step(akArrestee, "ReleaseCaptor: Captor looked up (" + captorRef + ")")
    ; A guard already given a new arrest (a handover, a quick re-arrest) keeps his Captor. A cancel (@abFreeGuard) leaves a
    ; dead guard's alone: it ends with his effect (his OnDeath is what cancelled)
    if (captorRef && captorRef.Arrestee == akArrestee && (!abFreeGuard || !akGuard.IsDead()))
        captorRef.Destroy()
        RPB_Recovery.__Step(akArrestee, "ReleaseCaptor: Captor destroyed")
    endif
    if (abFreeGuard)
        RPB_Recovery.__FreeGuard(akGuard, SceneManager)
        RPB_Recovery.__Step(akArrestee, "ReleaseCaptor: guard freed")
    endif
endFunction

function UnregisterCaptor(RPB_Captor apCaptor, bool abRemoveFromList = false)
    ; Remove the spell from the Captor
    Spell captorSpell = RPB_Utility.RPB_CaptorSpell()
    if (apCaptor.HasSpell(captorSpell))
        apCaptor.RemoveSpell(captorSpell)
    endif
    RPB_Recovery.__Step(apCaptor.GetActor(), "UnregisterCaptor: spell removed")

    if (abRemoveFromList && Captors.Exists(apCaptor))
        Captors.Remove(apCaptor)
    endif
    RPB_Recovery.__Step(apCaptor.GetActor(), "UnregisterCaptor: list done")
endFunction

; ==========================================================

event OnInit()
    RegisterHotkeys()
endEvent

event OnKeyDown(int keyCode)
    if (keyCode == 0x42) ; F8
        Debug("Arrest::OnKeyDown", "F8 pressed (state '" + self.GetState() + "'), sending the surrender")
        self.Surrender(Config.Player)
    endif
endEvent

; The controls that end the surrender's cower (it loops and ignores movement): the surrender watch registers them
function __RegisterSurrenderControls(bool abRegister)
    string[] controls = new string[8]
    controls[0] = "Forward"
    controls[1] = "Back"
    controls[2] = "Strafe Left"
    controls[3] = "Strafe Right"
    controls[4] = "Move"
    controls[5] = "Jump"
    controls[6] = "Sprint"
    controls[7] = "Ready Weapon"
    int i = 0
    while (i < controls.Length)
        if (abRegister)
            RegisterForControl(controls[i])
        else
            UnregisterForControl(controls[i])
        endif
        i += 1
    endWhile
endFunction

; The player moving (or readying a weapon) while surrendering: out of the cower, so the input takes effect. The watch then
; sees them leave (or a guard close enough takes it anyway).
event OnControlDown(string asControl)
    Actor player = Config.Player
    if (!RPB_StorageVars.GetBoolOnReference("Surrendering", player, "Surrender"))
        return
    endif
    __SurrenderLog("Surrender of " + player + ": '" + asControl + "' pressed, leaving the surrender pose")
    Debug.SendAnimationEvent(player, "IdleForceDefaultState")
    if (asControl == "Ready Weapon")
        player.DrawWeapon() ; the press was spent leaving the idle
    endif
endEvent

event OnArresting(Actor akCaptor, Actor akArrestee)
    self.RestrainArrestee(akArrestee)
endEvent

; ==========================================================
;                        Event Handlers
; ==========================================================

;/
    Master Event for all types of dialogue concerning Arrest, anything to do with arrest through dialogue is
    handled here.

    int     @aiTopicInfoType: The type of the dialogue, Arrest to Jail, Arrest Resist, Arrest Confront, etc...
    int     @aiTopicInfoEvent: The time of the event, at the Start or End of the dialogue.
    string  @asTopicInfoDialogue: The dialogue lines, used if a unique action should be done depending on the dialogue.
    Actor   @akSpeakerArrester: The guard actively trying to arrest the player.
    Actor   @akSpokenToArrestee: The Actor that is being spoken to by @akSpeakerArrester, in most cases, an arrestee.

    Dialogue Lines (@asTopicInfoDialogue):
        - TOPIC_TYPE_ARREST_DIALOGUE_ELUDING
            - Wait... I know you.

        - TOPIC_TYPE_ARREST_PURSUIT_ELUDING
            - That'll teach you to break the law on my watch.
            - I thought it was finally going to be a quiet day.
            - You really thought you could get away with it?
            - Don't get any bright ideas.
            - Stop, in the name of the Jarl!
            - Come quietly or face the Jarl's justice!
            - By order of the Jarl, I command you to halt!
            - Sheathe your weapons and come quietly!

        - TOPIC_TYPE_ARREST_CONFRONT
            - By order of the Jarl, stop right there!
            - You have committed crimes against Skyrim and her people. What say you in your defense?

        - TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT
            - Good enough. I'll just confiscate any stolen goods you're carrying, then you're free to go.

        - TOPIC_TYPE_ARREST_PAY_BOUNTy_ESCORT_WILLINGLY
            - Smart man. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.
            - Smart woman. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.

        - TOPIC_TYPE_COMBAT_YIELD
            - I'll let you live. This time
            - I'll spare you - for now.
            - All right, you've had enough.
            - You're not worth it.
            - I didn't think you had the stomach for it.

        - TOPIC_TYPE_ARREST_RESIST
            - Time to cleanse the Empire of its filth.
            - Then suffer the Emperor's wrath.
            - Skyrim has no use for your kind.
            - Then let me speed your passage to Sovngarde!
            - Then pay with your blood.
            - That can be arranged.
            - So be it.
/;
event OnArrestDialogue(int aiTopicInfoEvent, int aiTopicInfoType, string asTopicInfoDialogue, Actor akSpeakerArrester, Actor akSpokenToArrestee)
    if (aiTopicInfoEvent == TOPIC_START)
        if (aiTopicInfoType == TOPIC_TYPE_ARREST_CONFRONT)
            ; Several nearby guards can independently reach their own arrest dialogue for the same target at once -
            ; EventManager.OnDialogueTopicStart's own "many guards talked at once" comment already acknowledges this.
            ; If another guard's flow already confirmed this arrest, don't re-roll these shared (not per-arrestee)
            ; bounty-payment globals out from under it - just let this guard's own dialogue disengage.
            if (RPB_Utility.IsActorArrested(akSpokenToArrestee))
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            self.SetupArrestPayableBountyVars(akSpeakerArrester.GetCrimeFaction()) ; Setup arrest payable bounty vars
            self.SetActorWantsToPayBounty(akSpokenToArrestee, false) ; Reset any possibility of paying the bounty, before actually selecting it

            ; The guard handling this arrest: another guard's resist line meanwhile isn't a resist (see TOPIC_TYPE_ARREST_RESIST)
            RPB_StorageVars.SetFormOnReference("Arrest Dialogue Guard", akSpokenToArrestee, akSpeakerArrester, "Pre-Arrest")
            RPB_StorageVars.SetFloatOnReference("Arrest Dialogue Time", akSpokenToArrestee, Utility.GetCurrentRealTime(), "Pre-Arrest")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_RESIST)
            ; Same multi-guard race as above, checked here (before SetAsResisting/the RPB_ResistArrest round-trip)
            ; rather than only after the fact in OnArrestResist - by the time that event's own "Captured" check ran,
            ; this guard had already spoken its hostile line with no code left to disengage it (a real, reproduced
            ; test: "no arrest was resisted [BUG]" fired, and the losing guard was left stuck - OnArrestResist's own
            ; comment on SetPlayerResistingArrest says that call is "needed... otherwise they will loop arrest
            ; dialogue", and the early-return there skips it). Don't touch the player's global resisting-arrest flag
            ; here either, for the same reason - it could re-arm hostility against an arrestee already being escorted
            ; in cuffs by the guard who actually won.
            if (RPB_Utility.IsActorArrested(akSpokenToArrestee))
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            ; A guard who breaks the dialogue off to fight (or talks to someone already fighting another hostile) isn't
            ; being resisted: leaving the dialogue then used to add the resisting-arrest bounty
            if (akSpeakerArrester.IsInCombat() || RPB_Utility.GetOtherCombatTarget(akSpokenToArrestee, akSpeakerArrester))
                EventManager.SendInfo("Not resisting arrest: " + akSpeakerArrester + " left the arrest dialogue in a fight", "Arrest::OnArrestDialogue")
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            ; Test-only: the teardown's move home cuts a confront its own reset set off (the test's bounty given back)
            if (RPB_Utility.IsTestTeardownRunning())
                EventManager.SendInfo("Not resisting arrest: a test's teardown cut " + akSpeakerArrester + "'s arrest dialogue", "Arrest::OnArrestDialogue")
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            ; Another guard's dialogue while one is already handling the arrest (several guards around: they come to talk
            ; while the first one still is, and their resist line counted as the player resisting, without them ever
            ; leaving the first dialogue). Only the guard handling it can be resisted.
            if (self.__OtherGuardHandlesArrestDialogue(akSpeakerArrester, akSpokenToArrestee))
                EventManager.SendInfo("Not resisting arrest: " + akSpeakerArrester + " spoke while another guard handles the arrest dialogue", "Arrest::OnArrestDialogue")
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            self.SetAsResisting(akSpeakerArrester, akSpokenToArrestee)

        elseif (aiTopicInfoType == TOPIC_TYPE_COMBAT_YIELD)
            self.SetAsYielding(akSpeakerArrester, akSpokenToArrestee)
        endif

    elseif (aiTopicInfoEvent == TOPIC_END)
        ; An outcome ends the arrest dialogue: nobody is handling it any more
        if (aiTopicInfoType == TOPIC_TYPE_ARREST_DIALOGUE_ELUDING || aiTopicInfoType == TOPIC_TYPE_ARREST_PURSUIT_ELUDING || aiTopicInfoType == TOPIC_TYPE_ARREST_GO_TO_JAIL || (aiTopicInfoType >= TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT && aiTopicInfoType <= TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED))
            RPB_StorageVars.DeleteVariableOnReference("Arrest Dialogue Guard", akSpokenToArrestee, "Pre-Arrest")
        endif

        ; An eluding line closed on someone already arrested (or surrendering) isn't eluding: the arresting guard's own
        ; "Wait... I know you" greeting, closed by the arrest starting, queued the Eluding Scene ahead of the escort to
        ; jail, and the escort never played
        if ((aiTopicInfoType == TOPIC_TYPE_ARREST_DIALOGUE_ELUDING || aiTopicInfoType == TOPIC_TYPE_ARREST_PURSUIT_ELUDING) && self.__IsBeyondEluding(akSpokenToArrestee))
            EventManager.SendInfo("Not eluding arrest: " + akSpokenToArrestee + " is already arrested, imprisoned or surrendering (" + akSpeakerArrester + "'s line)", "Arrest::OnArrestDialogue")
            akSpeakerArrester.EvaluatePackage()

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_DIALOGUE_ELUDING)
            self.SetAsEluding(akSpeakerArrester, akSpokenToArrestee, "Dialogue")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PURSUIT_ELUDING)
            self.SetAsEluding(akSpeakerArrester, akSpokenToArrestee, "Pursuit")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ON_SPOT)

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
            
        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ESCORT_BY_FORCE)

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_GO_TO_JAIL)
            self.ArrestActor(akSpeakerArrester, akSpokenToArrestee, ARREST_TYPE_ESCORT_TO_JAIL)
        endif
    endif
endEvent

; Past the point where eluding means anything: already arrested, imprisoned, or surrendering
bool function __IsBeyondEluding(Actor akActor)
    return RPB_Utility.IsActorArrested(akActor) || RPB_Utility.IsActorImprisoned(akActor) || self.IsSurrendering(akActor)
endFunction

; Whether a guard other than @akSpeaker is handling @akArrestee's arrest dialogue right now: recorded at its confrontation
; line, still alive, and either still in the dialogue with the player or recorded less than 30s ago (the dialogue target
; can't always be read with several guards talking)
bool function __OtherGuardHandlesArrestDialogue(Actor akSpeaker, Actor akArrestee)
    Actor handler = RPB_StorageVars.GetFormOnReference("Arrest Dialogue Guard", akArrestee, "Pre-Arrest") as Actor
    if (!handler || handler == akSpeaker || handler.IsDead())
        return false
    endif

    float since = Utility.GetCurrentRealTime() - RPB_StorageVars.GetFloatOnReference("Arrest Dialogue Time", akArrestee, "Pre-Arrest")
    return (akArrestee == Config.Player && handler.IsInDialogueWithPlayer()) || since < 30.0
endFunction

event OnSurrenderBegin(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    self.__BeginSurrender(akSurrenderer)
    Actor[] guards = self.GetSurrenderGuards(akSurrendererCaptors)
    __surrenderGuards = guards
    self.PrepareSurrenderer(akSurrenderer, guards)
    self.__PacifyForSurrender(akSurrenderer, guards)
    self.InitiateSurrenderScene(akSurrenderer, guards)
    ; Runs on this event's own stack until the Scene's end takes the surrender over, or the surrenderer leaves
    self.__WatchSurrender(akSurrenderer, guards)
endEvent

event OnSurrenderEnd(Actor akSurrenderer, Actor akCaptor)
    ; Already over (they left, an abort): a Scene end arriving late must not arrest anyone
    if (!self.__ClaimSurrender(akSurrenderer))
        __SurrenderLog("Surrender Scene of " + akSurrenderer + " ended after the surrender was already over, ignored")
        return
    endif

    ; The Scene's first captor slot is the guard nearest at its start; whoever is nearest now is the one who got there
    akCaptor = self.__NearestSurrenderGuard(akSurrenderer, __surrenderGuards, akCaptor)
    Actor[] noGuards
    __surrenderGuards = noGuards

    if (!self.IsSurrenderGuard(akCaptor))
        LastSurrenderOutcome = "no guard at the end"
        self.__UndoSurrender(akSurrenderer, "the Scene ended without a guard (captor " + akCaptor + ")")
        return
    endif

    Faction crimeFaction = akCaptor.GetCrimeFaction()
    self.ApplySurrenderPenalty(akSurrenderer, crimeFaction)
    ; The arrest rejects an actor with no bounty, and nothing would give the player back their controls after that
    if (RPB_ActorBase.GetCurrentActiveAndLatentBountyForFaction(akSurrenderer, crimeFaction) <= 0)
        LastSurrenderOutcome = "no bounty"
        self.__UndoSurrender(akSurrenderer, "no bounty in " + RPB_Utility.GetFormNameCached(crimeFaction) + " and no bounty for surrendering is set")
        return
    endif

    LastSurrenderOutcome = "arrest"
    self.ArrestActor(akCaptor, akSurrenderer, ARREST_TYPE_ESCORT_TO_JAIL)
endEvent

;/
    Handles what happens before an Actor is arrested.

    Actor   @akArrestee: The actor that will be arrested.
    Actor   @akCaptor: The captor of this arrest.
    Faction @akCrimeFaction: The crime faction for this arrest
    string  @asArrestType: The type of the arrest
/;
event OnArrestPreparing(Actor akArrestee, Actor akCaptor, Faction akCrimeFaction, string asArrestType)
    akArrestee.StopCombat()
    akArrestee.StopCombatAlarm()
    akArrestee.SheatheWeapon()
endEvent

;/
    TODO: Fix arrestee reference not being cleared after failed arrest (the Actor has RPB_Arrestee bound to them)

    RPB_Arrestee    @apArrestee: The reference to the actor that will be arrested.
    RPB_Captor|none @apCaptor: The actor that is performing the arrest. (Can be none if a Faction arrest is performed)
    Faction         @akCrimeFaction: The crime faction for this arrest.
    string          @asArrestType: The type of the arrest, whether to escort or to move to jail, etc... (for more info, see ARREST_TYPES)
/;
event OnArrestBegin(RPB_Arrestee apArrestee, RPB_Captor apCaptor, Faction akCrimeFaction, string asArrestType)
    RPB_Utility.Crumb(apArrestee.GetActor(), "Arrest.OnArrestBegin: enter")
    apArrestee.SetArrestParameters(asArrestType, apCaptor, akCrimeFaction)

    ; Debug("Arrest::OnArrestBegin", "ArresteeRef: [\n" + \
    ;     "\t arresteeRef: " + apArrestee + "\n" + \
    ;     "\t apArrestee.HasLatentBounty(): " + apArrestee.HasLatentBounty() + "\n" + \
    ;     "\t apArrestee.HasActiveBounty(): " + apArrestee.HasActiveBounty() + "\n" + \
    ;     "\t apArrestee.GetActiveBounty(): " + apArrestee.GetActiveBounty() + "\n" + \
    ;     "\t apArrestee.GetLatentBounty(): " + apArrestee.GetLatentBounty() + "\n" + \
    ;     "\t apArrestee.GetFaction(): " + apArrestee.GetFaction() + "\n" + \
    ; "]")

    if (!apArrestee.HasLatentBounty() && !apArrestee.HasActiveBounty())
        Config.NotifyArrest("You can't be arrested in " + RPB_Utility.GetFormNameCached(akCrimeFaction) + " since you do not have a bounty in the hold", apArrestee.IsPlayer())
        EventManager.SendError(apArrestee.Name + " has no bounty, cannot arrest for "+ RPB_Utility.GetFormNameCached(akCrimeFaction) +", aborting!", "Arrest::OnArrestBegin")
        RPB_Utility.Crumb(apArrestee.GetActor(), "Arrest.OnArrestBegin: ABORT no bounty")
        apArrestee.Destroy()
        return
    endif

    ; Bind this Captor to the Arrestee
    ; apCaptor.AddArrestee(apArrestee)
    if (apCaptor)
        apCaptor.AssignArrestee(apArrestee.GetActor())
    endif
    ; Captors.AtKey(apCaptor).GotoState("Escorting")

    if (apArrestee.IsPlayer())
        RPB_Arrest.AllowArrestForcegreets(false)
    endif

    RPB_Utility.FlowMark("Arrest.OnArrestBegin: parameters, bounty check, captor assigned")
    RPB_Utility.Crumb(apArrestee.GetActor(), "Arrest.OnArrestBegin: parameters, bounty check, captor assigned")
    self.BeginArrest(apArrestee)
endEvent

event OnArrestEnd(RPB_Arrestee apArrestee, RPB_Captor apCaptor, Faction akCrimeFaction)
    ; Re-enable forced arrest dialogue, arrest has been processed
    RPB_Arrest.EnableForcedArrestDialogue()
endEvent

;/
    Event that happens when the player is beginning to elude arrest.
    For Pursuit type arrest eludes, this is the only event that happens, because once the state is changed to Eluded,
    the penalty is given there. However, for Dialogue type arrest eluding, this is the event that is first fired upon making
    contact with a guard, which then gives way to their new dialogue that triggers OnEludingArrestDialogue which is where the penalties are given
    for that arrest elude type.

    Actor   @akEludedGuard: The guard that is being eluded.
    string  @asEludeType: How the arrest is being eluded, options are: [Dialogue, Pursuit]
        Eluding arrest through Dialogue means that the player has tried to avoid the "Wait, I know you..." guard dialogue
        but they caught up and demanded an explanation.

        Eluding arrest through Pursuit means that the player is trying to run away from the guards after they say lines such as:
        "In the name of the Jarl, I command you to stop!", or "Come quietly or face the Jarl's justice!"
/;
event OnArrestEludeStart(Actor akEludedGuard, string asEludeType)
    ; Eluding is the player's (TriggerForcegreetEluding/TriggerPursuitEluding act on them)
    if (self.__IsBeyondEluding(Config.Player))
        EventManager.SendInfo("Not eluding arrest: the player is already arrested, imprisoned or surrendering (" + asEludeType + ", " + akEludedGuard + ")", "Arrest::OnArrestEludeStart")
        if (akEludedGuard)
            akEludedGuard.EvaluatePackage()
        endif
        return
    endif

    Debug("Arrest::OnArrestEludeStart", "Started Eluding Arrest with Elude Type: " + asEludeType + ", akEludedGuard: " + akEludedGuard)

    if (asEludeType == "Dialogue")
        self.TriggerForcegreetEluding(akEludedGuard)
        return

    elseif (asEludeType == "Pursuit")
        self.TriggerPursuitEluding(akEludedGuard)
        return
    endif

    EventManager.SendError("The passed in Elude Type is invalid, the event failed!", "Arrest::OnArrestEludeStart")
endEvent

event OnArrestEludeTriggered(Actor akEludedGuard, string asEludeType)
    self.ApplyArrestEludedPenalty(akEludedGuard.GetCrimeFaction()) ; Set as eluding arrest from this guard

    if (asEludeType == "Pursuit")
        akEludedGuard.StartCombat(config.Player)
    
    elseif (asEludeType == "Dialogue")
        SceneManager.ReleaseAlias("Guard") ; Unbind alias running the AI package from eluded guard
        SceneManager.ReleaseAlias("Eluder") ; Unbind alias from the player
    endif
endEvent

event OnArrestResist(Actor akArrestResister, Actor akGuard, Faction akCrimeFaction)
    bool isCaptured = RPB_StorageVars.GetBoolOnReference("Captured", akArrestResister, "Arrest")
    if (isCaptured)
        EventManager.SendWarning(akArrestResister.GetBaseObject().GetName() + " was arrested, no arrest was resisted (maybe multiple guards talked at once and triggered resist arrest?) [BUG]", "Arrest::OnArrestResist")
        return
    endif

    akGuard.SetPlayerResistingArrest() ; Needed to make the guards attack the player, otherwise they will loop arrest dialogue

    if (self.HasResistedArrestRecently(akCrimeFaction))
        EventManager.SendInfo("You have already resisted arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    self.ApplyArrestResistedPenalty(akCrimeFaction)
endEvent

event OnArrestPayBounty(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, string asPayBountyScenario)
    Debug("Arrest::OnArrestPayBounty", "Paying Bounty for Faction " + akCrimeFaction + ", Payer: " + akPayerArrestee + ", paying to: " + akArresterGuard)

    if (asPayBountyScenario == ARREST_PAY_BOUNTY_ON_SPOT)
        self.PayCrimeGold(akPayerArrestee, akCrimeFaction)

    elseif (asPayBountyScenario == ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
        ; Start escort Scene, where guard will take the person paying the bounty to jail, to be frisked and pay it.
        ; If the payer strays from the path, give a bounty penalty and start combat

        ;/
            TODO: Replace the below with the equivalent for RPB_Captor
        /;
        ; CaptorRef.ForceRefTo(akArresterGuard)
        ; CaptorRef.AssignArrestee(akPayerArrestee)
        ; CaptorRef.RegisterForSingleUpdate(5.0)
        ; self.SetActorWantsToPayBounty(akPayerArrestee)
        ; self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_BOUNTY_PAYMENT)

        ; Get current bounty and hide it
        ; self.HideBounty(akCrimeFaction)

        SceneManager.StartArrestBountyPaymentFollowWillingly(akArresterGuard, akPayerArrestee, Config.GetJailPrisonerItemsContainer(RPB_Utility.GetFormNameCached(akCrimeFaction)) as ObjectReference)
    elseif (asPayBountyScenario == ARREST_PAY_BOUNTY_ESCORT_BY_FORCE)
        ; Start escort Scene, where guard will detain the person paying the bounty to jail and take them there by force, to be frisked and pay it.
        ; temporary escort location:
        self.SetArrestScene(akPayerArrestee, SceneManager.SCENE_ARREST_START_01)
        self.ArrestActor(akArresterGuard, akPayerArrestee, ARREST_TYPE_ESCORT_TO_JAIL)

        ; Set vars to differentiate from normal arrest
        self.SetActorWantsToPayBounty(akPayerArrestee)
        self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_BOUNTY_PAYMENT)
    endif
endEvent

event OnArrestDefeat(Actor akAttacker)
    self.ApplyArrestDefeatedPenalty(akAttacker.GetCrimeFaction())

    Form handcuffs = Game.GetFormEx(0xA033D9E)
    config.Player.StopCombatAlarm()
    config.Player.EquipItem(handcuffs, true, true)
endEvent

event OnArrestCaptorDeath(Actor akCaptor, Actor akCaptorKiller)
    ; Actor anotherGuard = GetNearestGuard(ArrestVars.Arrestee, 3500, exclude = akCaptor) ; TODO: Refactor ArrestVars to get the actual arrestee

    ; if (!anotherGuard)
    ;     config.NotifyArrest("Your captor has died, you may now try to break free")
    ;     self.ReleaseDetainee(akCaptor, ArrestVars.Arrestee)
    ;     return
    ; endif

    ; config.NotifyArrest("Your captor has died, you are being escorted by another guard")
    ; self.ChangeArrestEscort(anotherGuard, ArrestVars.Arrestee)

    ; if (akCaptorKiller == none) ; to be changed to Player later, but this is easier to test
    ;     int bounty = 10000
    ;     config.NotifyArrest("You have gained " + bounty + " Bounty in " + ArrestVars.Hold + " for killing your captor!")
    ; endif

    ; Debug("Arrest::OnArrestCaptorDeath", "[\n"+ \ 
    ;     "\tOld Captor: "+ akCaptor +"\n" + \
    ;     "\tNew Captor: "+ anotherGuard +"\n" \
    ; +"]")
endEvent

;/
    Event to handle what happens when the arrestee yields in combat against a guard.

    Actor   @akGuard: The guard that is in combat and trying to perform an arrest.
    Actor   @akYieldedArrestee: The Actor that has yielded and is about to be arrested.
/;
event OnCombatYield(Actor akGuard, Actor akYieldedArrestee)
    ; Yielding would be a way around a faked surrender's memory: the guard keeps fighting
    if (self.HasFakedSurrenderTo(akYieldedArrestee, akGuard.GetCrimeFaction()))
        __SurrenderLog("Yield of " + akYieldedArrestee + " to " + akGuard + " ignored: they faked a surrender to this hold")
        Config.NotifyArrest("The guards won't fall for that again", akYieldedArrestee == Config.Player)
        akGuard.StartCombat(akYieldedArrestee)
        return
    endif

    ; Only begin arrest if they are within this distance,
    ; this is to avoid Guards triggering their dialogue while the player has already ran away.
    if (akYieldedArrestee.GetDistance(akGuard) <= 1200)
        ; ArrestVars.SetString("Arrest::Arrest Scene", "ArrestStartFree01")
        RPB_StorageVars.SetStringOnReference("Arrest Scene", akYieldedArrestee, "ArrestStartFree01", "Arrest")
        akGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, akYieldedArrestee.GetFormID())
    endif
endEvent

;/
    Event to handle what happens when the bounty payer gets to jail to pay their bounty.
    
    Actor   @akArresterGuard: The guard that performed the arrest to take the person to pay their bounty.
    Actor   @akPayerArrestee: The actor currently detained in order to pay their bounty.
    Faction @akCrimeFaction: The crime faction this bounty's going to.
    bool    @abEscortedForcefully: Whether the bounty payer was restrained and escorted forcefully while getting to jail.
/;
event OnArrestPayBountyEnd(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, bool abEscortedForcefully)
    if (abEscortedForcefully) ; Payer is restrained
        self.UnrestrainArrestee(akPayerArrestee)
    endif

    self.PayCrimeGold(akPayerArrestee, akCrimeFaction)

    ; Reset Bounty Payment vars
    self.SetActorWantsToPayBounty(akPayerArrestee, false)
endEvent

event OnArrestSceneChanged(Actor akArrestee, string asSceneName)
    if (akArrestee == Config.Player)
        ; ArrestVars.SetString("Arrest::Scene", asSceneName)
        RPB_StorageVars.SetStringOnReference("Scene", akArrestee, asSceneName, "Arrest")
    endif
endEvent

;/
    Event to handle what happens when the arrest goal for a specific arrestee changes.

    Actor   @akArrestee: The Actor that is currently arrested and is having their goal for the arrest changed.
    string  @asOldArrestGoal: The previous arrest goal for this Actor.
    string  @asNewArrestGoal: The new arrest goal for this Actor.
/;
event OnArrestGoalChanged(Actor akArrestee, string asOldArrestGoal, string asNewArrestGoal)
    ; ArrestVars.SetString("Arrest::Arrest Goal", asNewArrestGoal)
    RPB_StorageVars.SetStringOnReference("Arrest Goal", akArrestee, asNewArrestGoal, "Arrest")
    ; Debug("Arrest::OnArrestGoalChanged", "Arrest Goal for Actor " + akArrestee + " was set to " + asNewArrestGoal, asOldArrestGoal == "")
    ; Debug("Arrest::OnArrestGoalChanged", "Arrest Goal for Actor " + akArrestee + " was changed from " + asOldArrestGoal + " to " + asNewArrestGoal, asOldArrestGoal != "")
endEvent

; Prototype may be different later, like this:
; event OnArrestFailed(RPB_Captor akCaptorRef, RPB_Arrestee akArresteeRef, string asFailReason)
event OnArrestFailed(Actor akCaptor, Actor akArrestee, string asFailReason)
    Error(asFailReason)
endEvent

event OnUpdateGameTime()
    self.ResetEludedFlag()      ; Reset Eluded Arrest flags for all Holds
    self.ResetResistedFlag()    ; Reset Resisted Arrest flags for all Holds
endEvent


; ==========================================================
;                 Event Handlers - Arrestee
; ==========================================================

event OnActorArrested(RPB_Arrestee apArrestee, RPB_Captor apArrestGuard)

endEvent

event OnArresteeDeath(RPB_Arrestee apArrestee, RPB_Captor apArrestGuard, Actor akKiller)
    ; This was an empty stub: an ActiveMagicEffect doesn't end itself just because its target actor died, so with
    ; nothing here to tear the arrest state down, RPB_Arrestee.OnUpdate()'s escort-catch-up loop kept re-registering
    ; every 5s forever - a real, guaranteed leak on every arrestee death mid-arrest. RevertArrest() is the same, already-
    ; proven full teardown a failed arrest already uses (uncuffs, restores bounty, clears storage, unregisters, and
    ; Destroy()s, which is what actually stops the OnUpdate loop).
    apArrestee.RevertArrest()
endEvent

event OnArresteeRestrained(RPB_Arrestee apArrestee)
    if (apArrestee.GetArrestType() == ARREST_TYPE_TELEPORT_TO_CELL)
        apArrestee.MoveToPrison(abMoveDirectlyToCell = true)

    elseif (apArrestee.GetArrestType() == ARREST_TYPE_TELEPORT_TO_JAIL)
        apArrestee.MoveToPrison()
    endif

    apArrestee.OnRestrained()
endEvent

event OnArresteeFreed(RPB_Arrestee apArrestee, RPB_Captor apCaptor)

endEvent

; ==========================================================
;                  Event Handlers - Captor
; ==========================================================


; ==========================================================
;                           Functions
; ==========================================================
; ==========================================================
;                       Event Dispatchers

;/
    Sets the arrest scene for @akArrestee.

    The verification is handled through EventManager which is then handled
    through OnArrestSceneChanged.

    Actor   @akArrestee: The arrestee from the arrest of which the scene is to be set.
    string  @asSceneName: The name of the arrest scene.
/;
function SetArrestScene(Actor akArrestee, string asSceneName)
    akArrestee.SendModEvent("RPB_SetArrestScene", asSceneName)
endFunction

;/
    Sets the primary arrest goal for @akArrestee.

    The verification is handled through EventManager which is then handled
    through OnArrestGoalChanged.

    Actor   @akArrestee: The arrestee from the arrest of which the scene is to be set.
    string  @asArrestGoal: The type of the arrest goal.
/;
function SetArrestGoal(Actor akArrestee, string asArrestGoal)
    akArrestee.SendModEvent("RPB_SetArrestGoal", asArrestGoal)
endFunction

;/
    Arrests the passed in Actor.
    The arrest is performed by a captor.

    The verification is handled through EventManager,
    the arrest begins with OnArrestBegin.

    Actor   @akArrester: The Actor that is performing the arrest, usually a guard.
    Actor   @akArrestee: The Actor that is to be arrested.
    string  @asArrestType: The type of the arrest, whether to escort to jail, cell, or teleport to jail or cell.
/;
function ArrestActor(Actor akArrester, Actor akArrestee, string asArrestType)
    RPB_Utility.FlowBegin("Arrest -> Imprison")
    akArrester.SendModEvent("RPB_ArrestBegin", asArrestType, akArrestee.GetFormID())
endFunction

;/
    Arrests the passed in Actor.
    The arrest is performed through a Crime Faction.

    The verification is handled through EventManager,
    the arrest begins with OnArrestBegin.

    Faction @akCrimeFaction: The Crime Faction of the hold to arrest the Actor in.
    Actor   @akArrestee: The Actor that is to be arrested.
    string  @asArrestType: The type of the arrest, whether to escort to jail, cell, or teleport to jail or cell.
/;
function ArrestActorForFaction(Faction akCrimeFaction, Actor akArrestee, string asArrestType)
    RPB_Utility.FlowBegin("Arrest -> Imprison")
    akCrimeFaction.SendModEvent("RPB_ArrestBegin", asArrestType, akArrestee.GetFormID())
endFunction

;/
    Arrests the passed in Actors.

    Wrapper to handle multiple actors using ArrestActor()

    Actor   @akArrester: The Actor that is performing the arrest, usually a guard.
    Actor[] @akArrestees: The Actors that will be arrested.
    string  @asArrestType: The type of the arrest, whether to escort to jail, cell, or teleport to jail or cell.
    float   @afWaitTimeBetweenArrests: The delay to wait between each actor arrest, since the event can only handle one at once.
/;
function ArrestActors(Actor akArrester, Actor[] akArrestees, string asArrestType, bool abEnsureAllArrested = true, float afWaitTimeBetweenArrests = 0.3)
    int i = 0
    while (i < akArrestees.Length)
        if (akArrestees[i])
            self.ArrestActor(akArrester, akArrestees[i], asArrestType)
        endif

        Utility.Wait(afWaitTimeBetweenArrests)
        if (abEnsureAllArrested && !RPB_Utility.IsActorArrested(akArrestees[i])) ; If they are not arrested yet
            int arrestAttempt = 0
            int arrestTries = 20

            while (arrestAttempt < arrestTries)
                if (!RPB_Utility.IsActorArrested(akArrestees[i]))
                    self.ArrestActor(akArrester, akArrestees[i], asArrestType)
                    Utility.Wait(afWaitTimeBetweenArrests)
                endif

                arrestAttempt += 1
            endWhile
        endif
        i += 1
    endWhile
endFunction

;/
    Sets the passed in Actor as being eluding arrest.

    The verification is handled through EventManager,
    and it's handled by OnArrestEludeStart

    Actor   @akEludedGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akEluder: The Actor that is eluding arrest.
    string  @asEludeType: The type of the arrest elude, Dialogue or Pursuit
/;
function SetAsEluding(Actor akEludedGuard, Actor akEluder, string asEludeType)
    akEludedGuard.SendModEvent("RPB_EludingArrest", asEludeType)
endFunction

;/
    Sets the passed in Actor as being resisting arrest.

    The verification is handled through EventManager,
    and it's handled by OnArrestResist

    Actor   @akGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akResister: The Actor that is resisting arrest.
/;
function SetAsResisting(Actor akGuard, Actor akResister)
    akGuard.SendModEvent("RPB_ResistArrest", "", akResister.GetFormID())
endFunction

;/
    Sets the passed in Actor as having yielded and been spared.

    The verification is handled through EventManager,
    and it's handled by OnCombatYield

    Actor   @akSparerGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akYieldedArrestee: The Actor that has yielded and will be arrested.
/;
function SetAsYielding(Actor akSparerGuard, Actor akYieldedArrestee)
    akSparerGuard.SendModEvent("RPB_CombatYield", "", akYieldedArrestee.GetFormID())
endFunction

;/
    Starts the bounty payment scenario for @akPayerArrestee, handled by @akGuard.

    The verification is handled through EventManager,
    and it's handled by OnArrestPayBounty

    Actor   @akGuard: The Actor that is requesting the payment, usually a guard.
    Actor   @akPayerArrestee: The Actor that is going to pay the bounty.
    string  @asBountyPaymentScenario: Whether the payer will pay the bounty on the spot, be escorted willingly or restrained and escorted forcefully
/;
function StartBountyPayment(Actor akGuard, Actor akPayerArrestee, string asBountyPaymentScenario)
    akGuard.SendModEvent("RPB_PayBounty", asBountyPaymentScenario, akPayerArrestee.GetFormID())
endFunction

;/
    Starts the Surrender procedure for this Actor.

    The verification is handled through EventManager,
    and it's handled by OnSurrenderPreparing

    Actor   @akSurrenderer: The actor that is about to surrender.
/;
function Surrender(Actor akSurrenderer)
    int handle = ModEvent.Create("RPB_Surrender")
    if (handle)
        ModEvent.PushForm(handle, akSurrenderer)
        ModEvent.Send(handle)
    endif
endFunction

; ==========================================================
;                      Surrender-Specific

bool function CanActorSurrender(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    bool isPlayer = akSurrenderer == Config.Player
    ; A second F8 while the first one is still on its way (the prepare alone takes 2s) started a second surrender
    if (self.IsSurrendering(akSurrenderer))
        __SurrenderLog("Surrender of " + akSurrenderer + " ignored: already surrendering")
        return false
    endif

    int arrestStatus = self.GetActorArrestStatus(akSurrenderer)

    if (arrestStatus != CAN_BE_ARRESTED)
        __SurrenderLog("Surrender of " + akSurrenderer + " refused: arrest status " + arrestStatus)
        EventManager.SendError("Actor " + akSurrenderer.GetBaseObject().GetName() + " is not able to be arrested! ("+ string_if (arrestStatus == ALREADY_ARRESTED, "Currently Arrested", "Currently Imprisoned") +")")
        return false
    endif

    if (!akSurrenderer.IsInCombat())
        __SurrenderLog("Surrender of " + akSurrenderer + " refused: not in combat")
        EventManager.SendWarning("Unable to surrender! (Actor " + akSurrenderer.GetBaseObject().GetName() + " is not in combat)")
        return false
    endif

    if (akSurrenderer.IsDead())
        __SurrenderLog("Surrender of " + akSurrenderer + " refused: dead")
        EventManager.SendWarning("Unable to surrender! (Actor " + akSurrenderer.GetBaseObject().GetName() + " is dead)")
        return false
    endif

    ; Nobody fighting them yet (the combat targets fill in a moment after the fight starts)
    if (!akSurrendererCaptors)
        LastSurrenderOutcome = "no captors"
        Config.NotifyArrest("There's no one here to surrender to", isPlayer)
        __SurrenderLog("Surrender of " + akSurrenderer + " refused: in combat, but with no combat targets")
        return false
    endif

    ; Only the law takes a surrender. Bandits and creatures used to be bound as captors too: one walked up, the arrest was
    ; rejected (no crime faction, or no bounty) and nothing ever gave the player back their controls
    Actor otherHostile = self.GetNonGuardCombatTarget(akSurrendererCaptors)
    if (!self.HasSurrenderGuard(akSurrendererCaptors))
        LastSurrenderOutcome = "no guard"
        Config.NotifyArrest("There's no one here to surrender to", isPlayer)
        __SurrenderLog("Surrender of " + akSurrenderer + " refused: none of their " + akSurrendererCaptors.Length + " combat targets is a guard")
        return false
    endif

    ; Surrendering locks the player in place, cowering: not while someone who won't take it is still attacking
    if (otherHostile)
        LastSurrenderOutcome = "attacked"
        Config.NotifyArrest("You can't surrender while you're still being attacked", isPlayer)
        __SurrenderLog("Surrender of " + akSurrenderer + " refused: " + otherHostile + " (" + RPB_Utility.GetFormNameCached(otherHostile.GetBaseObject()) + ", " + (akSurrenderer.GetDistance(otherHostile) as int) + " away, in combat " + otherHostile.IsInCombat() + ") is still in their combat targets")
        return false
    endif

    ; They faked one to these guards' hold not long ago
    Faction fooled = self.__FooledFaction(akSurrenderer, akSurrendererCaptors)
    if (fooled)
        LastSurrenderOutcome = "fooled"
        Config.NotifyArrest("The guards won't fall for that again", isPlayer)
        __SurrenderLog("Surrender of " + akSurrenderer + " refused: they faked a surrender to " + RPB_Utility.GetFormNameCached(fooled) + " not long ago")
        return false
    endif

    return true
endFunction

; The crime faction of the first guard among @akCombatTargets that @akSurrenderer faked a surrender to lately, or none
Faction function __FooledFaction(Actor akSurrenderer, Actor[] akCombatTargets)
    int i = 0
    while (i < akCombatTargets.Length)
        if (self.IsSurrenderGuard(akCombatTargets[i]))
            Faction crimeFaction = akCombatTargets[i].GetCrimeFaction()
            if (self.HasFakedSurrenderTo(akSurrenderer, crimeFaction))
                return crimeFaction
            endif
        endif
        i += 1
    endWhile
    return none
endFunction

; A combat target that can take a surrender: a living guard of a hold
bool function IsSurrenderGuard(Actor akActor)
    return akActor && !RPB_Utility.IsFrozenGuard(akActor) && !akActor.IsDead() && !akActor.IsDisabled() && akActor.IsGuard() && akActor.GetCrimeFaction()
endFunction

bool function HasSurrenderGuard(Actor[] akCombatTargets)
    int i = 0
    while (i < akCombatTargets.Length)
        if (self.IsSurrenderGuard(akCombatTargets[i]))
            return true
        endif
        i += 1
    endWhile
    return false
endFunction

; A living combat target that isn't a guard (a bandit, a creature), or none
Actor function GetNonGuardCombatTarget(Actor[] akCombatTargets)
    int i = 0
    while (i < akCombatTargets.Length)
        Actor target = akCombatTargets[i]
        if (target && !RPB_Utility.IsFrozenGuard(target) && !target.IsDead() && !target.IsDisabled() && !target.IsGuard())
            return target
        endif
        i += 1
    endWhile
    return none
endFunction

; The guards among @akCombatTargets, at most the Surrender Scene's 6 captor slots (empty slots stay none, the binding skips them)
Actor[] function GetSurrenderGuards(Actor[] akCombatTargets)
    Actor[] guards = new Actor[6]
    int count = 0
    int i = 0
    while (i < akCombatTargets.Length && count < guards.Length)
        if (self.IsSurrenderGuard(akCombatTargets[i]))
            guards[count] = akCombatTargets[i]
            count += 1
        endif
        i += 1
    endWhile
    return guards
endFunction

; ==========================================================
;               Surrender state (one way in, one way out)

; How long no bound guard can go without coming closer before the surrender expires (nobody is coming to take it)
float property SURRENDER_EXPIRE_SECONDS = 10.0 autoreadonly

; How far the surrenderer can move from where they surrendered before it counts as leaving
float property SURRENDER_LEAVE_DISTANCE = 64.0 autoreadonly

; A guard this close takes the surrender (the Surrender Scene's end condition): moving then isn't leaving
float property SURRENDER_TAKEN_DISTANCE = 300.0 autoreadonly

; How many times a Surrender Scene the engine refused to start (a guard back in combat) is started again
int property SURRENDER_SCENE_RETRIES = 2 autoreadonly

; How the last surrender ended or was refused ("no captors", "no guard", "attacked", "fooled", "expired" (still on),
; "faked", "withdrawn", "Scene never started", "no guard at the end", "no bounty", "arrest"): for the tests and the log
string property LastSurrenderOutcome auto hidden

; The guards bound to the current surrender (the Surrender Scene's captor slots), for the Scene's end
Actor[] __surrenderGuards

;/
    Stops the fight on the guards' side before the Surrender Scene: the engine refuses to start a Scene whose actors are
    still in combat, and a disguised surrenderer (a hostile faction on them) kept the guards fighting after the player's
    own StopCombat (the Scene "never started"). Their hostile factions are removed as the arrest would (the snapshot lets
    an undone surrender give them back); a disguise mod re-adds its faction, so I sweep until the guards stay calm, 5s at most.
/;
function __PacifyForSurrender(Actor akSurrenderer, Actor[] akGuards)
    float start = Utility.GetCurrentRealTime()
    int passes = 0
    bool fighting = true
    string stillFighting = ""
    while (fighting && (Utility.GetCurrentRealTime() - start) < 5.0)
        passes += 1
        if (RPB_Utility.IsHostileActor(akSurrenderer))
            RPB_Utility.NeutralizeHostileActor(akSurrenderer)
        endif
        akSurrenderer.StopCombat()
        akSurrenderer.StopCombatAlarm()
        fighting = false
        stillFighting = ""
        int i = 0
        while (i < akGuards.Length)
            if (akGuards[i] && akGuards[i].IsInCombat())
                akGuards[i].StopCombat()
                akGuards[i].StopCombatAlarm()
                fighting = true
                stillFighting += " " + akGuards[i]
            endif
            i += 1
        endWhile
        if (fighting)
            Utility.Wait(0.5)
        endif
    endWhile
    __SurrenderLog("Surrender of " + akSurrenderer + ": guards calmed in " + passes + " passes, still fighting " + fighting + string_if(fighting, " (in combat at the last pass:" + stillFighting + ")", "") + ", surrenderer in combat " + akSurrenderer.IsInCombat())
endFunction

; Surrender lines reach the log whether DEBUG is on (Info is silent then) or off
function __SurrenderLog(string asMessage)
    if (RPB_Utility.IsDebuggingEnabled())
        Debug("Arrest::Surrender", asMessage)
    else
        Info(asMessage)
    endif
endFunction

;/
    Whether @akActor has a surrender under way. The surrender's watch writes a heartbeat every tick: a flag with no
    heartbeat for an in-game hour has no one left to clear it (a save whose watch never came back), so it doesn't count.
/;
bool function IsSurrendering(Actor akActor)
    if (!RPB_StorageVars.GetBoolOnReference("Surrendering", akActor, "Surrender"))
        return false
    endif
    return (Utility.GetCurrentGameTime() - RPB_StorageVars.GetFloatOnReference("Surrender Heartbeat", akActor, "Surrender")) < (1.0 / 24.0)
endFunction

function __BeginSurrender(Actor akActor)
    RPB_StorageVars.SetBoolOnReference("Surrendering", akActor, true, "Surrender")
    RPB_StorageVars.SetFloatOnReference("Surrender Heartbeat", akActor, Utility.GetCurrentGameTime(), "Surrender")
endFunction

; Takes the surrender over: true for the one caller that gets it (the Scene's end, the watch, an abort), false for the rest
bool function __ClaimSurrender(Actor akActor)
    bool surrendering = self.IsSurrendering(akActor)
    RPB_StorageVars.DeleteCategoryOnReference(akActor, "Surrender")
    return surrendering
endFunction

;/
    Undoes what a surrender did to @akSurrenderer, for every way it can end without an arrest: the Surrender Scene
    (current or queued), the player's AI and controls, the cowering, the forced arrest dialogue switch.
    Call it after __ClaimSurrender() returned true. @abEndScene false from inside the Scene queue itself (a Scene that
    never started is already being dropped there). @abNotify false when the surrenderer ended it themselves.
/;
function __UndoSurrender(Actor akSurrenderer, string asReason, bool abEndScene = true, bool abNotify = true)
    bool isPlayer = akSurrenderer == Config.Player
    __SurrenderLog("Surrender of " + akSurrenderer + " undone: " + asReason)
    if (abEndScene)
        SceneManager.EndSceneWithActor(akSurrenderer, "the surrender is over: " + asReason)
    endif
    RPB_Utility.ReleaseAI(isPlayer)
    Debug.SendAnimationEvent(akSurrenderer, "IdleForceDefaultState")
    ; The hostility __PacifyForSurrender removed (nothing when they weren't hostile)
    RPB_Utility.RestoreNeutralizedHostility(akSurrenderer)
    RPB_Arrest.EnableForcedArrestDialogue()
    if (abNotify)
        Config.NotifyArrest("No one took your surrender", isPlayer)
    endif
endFunction

function AbortSurrender(Actor akSurrenderer, string asReason, bool abEndScene = true)
    if (self.__ClaimSurrender(akSurrenderer))
        self.__UndoSurrender(akSurrenderer, asReason, abEndScene)
    endif
endFunction

;/
    The surrender's own loop, on its event stack, until the Scene's end takes the surrender over. The surrenderer isn't
    arrested yet, so they keep their controls: moving away from where they stand when it starts (the cower is on by then;
    at F8 they could still be moving) or drawing a weapon ends it. Not with a guard within SURRENDER_TAKEN_DISTANCE: he's
    the one taking it (the Scene ends there).
    - While a guard is still coming, that's a fake surrender: a bounty, the guards fight again, and that hold's guards
      won't take a surrender from them for a few days.
    - Once no bound guard has come any closer for SURRENDER_EXPIRE_SECONDS, the surrender expires: nobody is coming, so
      leaving costs nothing. It stays on until then (a guard can still come and take it).
/;
function __WatchSurrender(Actor akSurrenderer, Actor[] akGuards)
    bool isPlayer = akSurrenderer == Config.Player
    float leaveSquared = SURRENDER_LEAVE_DISTANCE * SURRENDER_LEAVE_DISTANCE
    float originX = akSurrenderer.GetPositionX()
    float originY = akSurrenderer.GetPositionY()
    float originZ = akSurrenderer.GetPositionZ()
    ; Per tick (a vanilla native costs about a frame): the position, the weapon and one guard's distance. The nearest guard
    ; is re-scanned every 4th tick, the heartbeat written every 10th, and the time counted in ticks (a late Wait only
    ; makes the expiry later)
    int tracked = self.__NearestGuardIndex(akSurrenderer, akGuards)
    float nearest = self.__GuardDistance(akSurrenderer, akGuards, tracked)
    int ticks = 0
    int lastProgressTick = 0
    int sceneRetries = 0
    bool expired = false
    bool watching = true
    if (isPlayer)
        self.__RegisterSurrenderControls(true)
    endif
    while (watching)
        Utility.Wait(0.5)
        if (!RPB_StorageVars.GetBoolOnReference("Surrendering", akSurrenderer, "Surrender"))
            watching = false ; the Scene's end (or an abort) took it over
        elseif (RPB_StorageVars.GetBoolOnReference("Scene Failed", akSurrenderer, "Surrender"))
            RPB_StorageVars.DeleteVariableOnReference("Scene Failed", akSurrenderer, "Surrender")
            sceneRetries += 1
            if (sceneRetries <= SURRENDER_SCENE_RETRIES)
                __SurrenderLog("Surrender of " + akSurrenderer + ": the Surrender Scene didn't start (" + self.__GuardsInCombat(akGuards) + "), retry " + sceneRetries)
                self.__PacifyForSurrender(akSurrenderer, akGuards)
                self.InitiateSurrenderScene(akSurrenderer, akGuards)
                lastProgressTick = ticks
            else
                watching = false
                if (self.__ClaimSurrender(akSurrenderer))
                    LastSurrenderOutcome = "Scene never started"
                    self.__UndoSurrender(akSurrenderer, "the Surrender Scene never started after " + SURRENDER_SCENE_RETRIES + " retries (" + self.__GuardsInCombat(akGuards) + ")", abEndScene = false)
                endif
            endif
        else
            ticks += 1
            if (ticks % 10 == 0)
                RPB_StorageVars.SetFloatOnReference("Surrender Heartbeat", akSurrenderer, Utility.GetCurrentGameTime(), "Surrender")
            endif
            if (ticks % 4 == 0 || tracked < 0 || !akGuards[tracked])
                tracked = self.__NearestGuardIndex(akSurrenderer, akGuards)
            endif
            float distance = self.__GuardDistance(akSurrenderer, akGuards, tracked)
            float dx = akSurrenderer.GetPositionX() - originX
            float dy = akSurrenderer.GetPositionY() - originY
            float dz = akSurrenderer.GetPositionZ() - originZ
            float movedSquared = dx * dx + dy * dy + dz * dz
            bool weaponDrawn = akSurrenderer.IsWeaponDrawn()
            ; A close guard only "takes" it while the Surrender Scene plays (its end is the take-over): without the Scene,
            ; a guard standing next to them would hold the surrender on forever
            bool beingTaken = distance <= SURRENDER_TAKEN_DISTANCE && SceneManager.GetCurrentScene() == SceneManager.SCENE_SURRENDER_01
            if ((movedSquared > leaveSquared || weaponDrawn) && !beingTaken)
                watching = false
                __SurrenderLog("Surrender of " + akSurrenderer + ": they left (moved " + (Math.sqrt(movedSquared) as int) + ", weapon drawn " + weaponDrawn + ", nearest guard " + (distance as int) + ", expired " + expired + ")")
                if (expired)
                    self.__WithdrawSurrender(akSurrenderer)
                else
                    self.__FakeSurrender(akSurrenderer, akGuards)
                endif
            elseif (!expired)
                if (distance < nearest - 32.0)
                    nearest = distance
                    lastProgressTick = ticks
                elseif (((ticks - lastProgressTick) * 0.5) >= SURRENDER_EXPIRE_SECONDS)
                    expired = true
                    LastSurrenderOutcome = "expired"
                    __SurrenderLog("Surrender of " + akSurrenderer + " expired: no guard came closer in " + (SURRENDER_EXPIRE_SECONDS as int) + "s (nearest " + (nearest as int) + ")")
                    Config.NotifyArrest("No one is coming to take your surrender", isPlayer)
                endif
            endif
        endif
    endWhile
    if (isPlayer)
        self.__RegisterSurrenderControls(false)
    endif
endFunction

;/
    The Surrender Scene didn't start (EventManager.OnSceneStartFailed, inside the Scene queue): the watch retries it on its
    own stack. A surrender that's already over has nothing to retry.
/;
function OnSurrenderSceneFailed(Actor akSurrenderer)
    if (self.IsSurrendering(akSurrenderer))
        RPB_StorageVars.SetBoolOnReference("Scene Failed", akSurrenderer, true, "Surrender")
    endif
endFunction

; Which of @akGuards are in combat, for the log
string function __GuardsInCombat(Actor[] akGuards)
    string fighting = ""
    int i = 0
    while (i < akGuards.Length)
        if (akGuards[i] && akGuards[i].IsInCombat())
            fighting += " " + akGuards[i]
        endif
        i += 1
    endWhile
    if (fighting == "")
        return "no bound guard in combat"
    endif
    return "in combat:" + fighting
endFunction

; The index of the nearest of @akGuards to @akSurrenderer, -1 with none
int function __NearestGuardIndex(Actor akSurrenderer, Actor[] akGuards)
    int best = -1
    float bestDistance = 0.0
    int i = 0
    while (i < akGuards.Length)
        if (akGuards[i])
            float distance = akSurrenderer.GetDistance(akGuards[i])
            if (best < 0 || distance < bestDistance)
                best = i
                bestDistance = distance
            endif
        endif
        i += 1
    endWhile
    return best
endFunction

; The distance from @akSurrenderer to @akGuards[@aiIndex] (a huge one with none)
float function __GuardDistance(Actor akSurrenderer, Actor[] akGuards, int aiIndex)
    if (aiIndex < 0 || !akGuards[aiIndex])
        return 1000000000.0
    endif
    return akSurrenderer.GetDistance(akGuards[aiIndex])
endFunction

; The nearest of @akGuards that can still take the surrender, or @akFallback
Actor function __NearestSurrenderGuard(Actor akSurrenderer, Actor[] akGuards, Actor akFallback)
    Actor best = none
    float bestDistance = 0.0
    int i = 0
    while (i < akGuards.Length)
        if (self.IsSurrenderGuard(akGuards[i]))
            float distance = akSurrenderer.GetDistance(akGuards[i])
            if (!best || distance < bestDistance)
                best = akGuards[i]
                bestDistance = distance
            endif
        endif
        i += 1
    endWhile
    if (!best)
        return akFallback
    endif
    return best
endFunction

; They left while a guard was still coming: the fake surrender's bounty and memory, then the guards fight again
function __FakeSurrender(Actor akSurrenderer, Actor[] akGuards)
    if (!self.__ClaimSurrender(akSurrenderer))
        return
    endif
    Actor[] noGuards
    __surrenderGuards = noGuards
    LastSurrenderOutcome = "faked"
    Actor guard = self.__NearestSurrenderGuard(akSurrenderer, akGuards, none)
    if (guard)
        Faction crimeFaction = guard.GetCrimeFaction()
        self.ApplyFakeSurrenderPenalty(akSurrenderer, crimeFaction)
        self.__RememberFakeSurrender(akSurrenderer, crimeFaction)
    endif
    self.__UndoSurrender(akSurrenderer, "they left while a guard was still coming (a fake surrender)", abNotify = false)
    int i = 0
    while (i < akGuards.Length)
        if (akGuards[i] && !akGuards[i].IsDead())
            akGuards[i].StartCombat(akSurrenderer)
        endif
        i += 1
    endWhile
endFunction

; They left after the surrender expired: nobody was coming to take it, so it's over at no cost
function __WithdrawSurrender(Actor akSurrenderer)
    if (!self.__ClaimSurrender(akSurrenderer))
        return
    endif
    Actor[] noGuards
    __surrenderGuards = noGuards
    LastSurrenderOutcome = "withdrawn"
    self.__UndoSurrender(akSurrenderer, "they left after no guard came", abNotify = false)
endFunction

; ==========================================================
;               Fake surrenders (what the guards remember)

string function __FakedUntilKey(Faction akFaction)
    return RPB_Utility.GetFormNameCached(akFaction) + "::Surrender Faked Until"
endFunction

; Whether @akActor faked a surrender to @akFaction's guards within that hold's "Fake Surrender Memory"
bool function HasFakedSurrenderTo(Actor akActor, Faction akFaction)
    if (!akFaction)
        return false
    endif
    float fakedUntil = RPB_StorageVars.GetFloatOnReference(self.__FakedUntilKey(akFaction), akActor, "Surrender Memory")
    return fakedUntil > 0.0 && Utility.GetCurrentGameTime() < fakedUntil
endFunction

; When the memory of @akActor's fake surrender to @akFaction runs out (game days), 0 with none
float function GetFakedSurrenderUntil(Actor akActor, Faction akFaction)
    return RPB_StorageVars.GetFloatOnReference(self.__FakedUntilKey(akFaction), akActor, "Surrender Memory")
endFunction

function __RememberFakeSurrender(Actor akActor, Faction akFaction)
    float days = Config.GetArrestFakeSurrenderMemory(RPB_Utility.GetFormNameCached(akFaction))
    RPB_StorageVars.SetFloatOnReference(self.__FakedUntilKey(akFaction), akActor, Utility.GetCurrentGameTime() + days, "Surrender Memory")
endFunction

; Forgets every fake surrender of @akActor (the tests' teardown)
function ForgetFakeSurrenders(Actor akActor)
    RPB_StorageVars.DeleteCategoryOnReference(akActor, "Surrender Memory")
endFunction

;/
    The bounty for surrendering to @akFaction's guards: a flat amount plus a share of the current bounty (active and
    latent), set per hold in the MCM. With no bounty only the flat part applies, so a hostile actor who had none is
    still arrested for something.
/;
function ApplySurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    string hold = RPB_Utility.GetFormNameCached(akFaction)
    self.__AddSurrenderBounty(akSurrenderer, akFaction, Config.GetArrestAdditionalBountySurrenderingFromCurrentBounty(hold), Config.GetArrestAdditionalBountySurrenderingFlat(hold), "surrendering")
    RPB_ActorVars.IncrementStat("Arrests Surrendered", akFaction, akSurrenderer)
endFunction

; The bounty for faking a surrender to @akFaction's guards: a flat amount plus a share of the current bounty, per hold
function ApplyFakeSurrenderPenalty(Actor akSurrenderer, Faction akFaction)
    string hold = RPB_Utility.GetFormNameCached(akFaction)
    self.__AddSurrenderBounty(akSurrenderer, akFaction, Config.GetArrestAdditionalBountyFakingSurrenderFromCurrentBounty(hold), Config.GetArrestAdditionalBountyFakingSurrenderFlat(hold), "faking a surrender")
endFunction

function __AddSurrenderBounty(Actor akSurrenderer, Faction akFaction, float afPercent, int aiFlat, string asFor)
    string hold = RPB_Utility.GetFormNameCached(akFaction)
    bool isPlayer = akSurrenderer == Config.Player

    int currentBounty   = RPB_ActorBase.GetCurrentActiveAndLatentBountyForFaction(akSurrenderer, akFaction)
    int penalty         = floor(currentBounty * PercentToDecimal(afPercent)) + aiFlat

    if (penalty > 0)
        if (isPlayer)
            akFaction.ModCrimeGold(penalty)
        else
            RPB_ActorVars.ModCrimeGold(akFaction, akSurrenderer, penalty)
        endif
        Config.NotifyArrest("You have gained " + penalty + " Bounty in " + hold + " for " + asFor, isPlayer)
    endif

    __SurrenderLog("Surrender of " + akSurrenderer + " to " + hold + " (" + asFor + "): bounty " + currentBounty + " + " + penalty)
endFunction

;/
    Sheathes and plays the surrender and cower idles. The surrenderer keeps their controls: they aren't arrested yet, and
    moving or drawing a weapon ends the surrender (the watch). The arrest takes the controls at the Scene's end.
/;
function PrepareSurrenderer(Actor akSurrenderer, Actor[] akGuards = none)
    ; Sheathe weapons, animations won't play otherwise
    akSurrenderer.SheatheWeapon()

    Utility.Wait(1.0)
    Debug.SendAnimationEvent(akSurrenderer, "IdleSurrender")

    ; Stop all combat
    akSurrenderer.StopCombat()
    akSurrenderer.StopCombatAlarm()

    ; A guard already this close takes the surrender at once: hands up, straight into the arrest, no cowering first
    if (akGuards)
        float distance = self.__GuardDistance(akSurrenderer, akGuards, self.__NearestGuardIndex(akSurrenderer, akGuards))
        if (distance <= SURRENDER_TAKEN_DISTANCE)
            __SurrenderLog("Surrender of " + akSurrenderer + ": a guard is close (" + (distance as int) + "): hands up, no cower")
            return
        endif
    endif

    Utility.Wait(1.0)
    Debug.SendAnimationEvent(akSurrenderer, "IdleCowerEnter")
endFunction

function InitiateSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors)
    if (RPB_Utility.IsSurrenderSceneForcedToFail())
        return ; tests 144/149: no guard ever comes
    endif
    SceneManager.StartSurrenderScene(akSurrenderer, akSurrendererCaptors, SceneManager.SCENE_SURRENDER_01)
endFunction

; ==========================================================
;                       Arrest-Specific

int function GetActorArrestStatus(Actor akActor)
    if (RPB_Utility.IsActorArrested(akActor))
        return ALREADY_ARRESTED

    elseif (RPB_Utility.IsActorImprisoned(akActor))
        return ALREADY_IMPRISONED
    endif

    return CAN_BE_ARRESTED
endFunction

function BeginArrest(RPB_Arrestee apArresteeRef)
    Actor arrestee          = apArresteeRef.GetActor()
    Actor captor            = apArresteeRef.GetCaptor().GetActor()
    Faction arrestFaction   = apArresteeRef.GetFaction()
    string arrestType       = apArresteeRef.GetArrestType()
    string hold             = apArresteeRef.GetHold()
    RPB_Utility.FlowMark("BeginArrest: getters")

    ; A dead guard can't arrest anyone (an F4 arrest once picked one that had just died, and the arrest "resumed" at once)
    if (!captor || captor.IsDead() || captor.IsDisabled())
        RPB_Recovery.CancelArrest(arrestee, "the captor " + captor + " is dead or gone")
        return
    endif

    apArresteeRef.HideBounty()
    RPB_Utility.FlowMark("BeginArrest: HideBounty")
    ; Diagnostic (2026-09-23): HideBounty() -> ClearActiveBountyForFaction() should zero the native CrimeGold for the player
    ; (RPB_ActorBase.psc:702-759). Logged to confirm that's actually happening and whether combat was already under way
    ; before this function ever ran - a real in-game test kept showing guards re-engaging over several seconds despite
    ; every pacification step below running, with no Master of Disguise ability effect present on them by that point.
    ; Only when logging is on: the message calls three natives, and it's built before SendInfo could skip it
    if (RPB_Utility.IsLoggingEnabled())
        EventManager.SendInfo("BeginArrest bounty/combat check on " + arrestee.GetDisplayName() + " " + arrestee + ": crime gold now " + arrestFaction.GetCrimeGold() + ", arrestee in combat " + arrestee.IsInCombat(), "Arrest::BeginArrest")
    endif
    RPB_Utility.FlowMark("BeginArrest: bounty/combat diagnostic")
    ; Read before the StopCombat below clears it, and passed on as-is (a stored flag didn't reach EscortToPrison): an arrest
    ; made in a fight has its guard checked again once things settle (Arrestee.__CaptorStillFighting), a peaceful one skips
    ; that wait
    bool combatAtArrest = arrestee.IsInCombat() || (captor && captor.IsInCombat())
    ; Who the guard is actually fighting, read before anything is stopped: another hostile keeping him busy means the
    ; confrontation Scene can't play, so the arrest waits (Arrestee.__BeginPendingArrest). A timed IsInCombat check after
    ; the StopCombat below fell in the gap before that hostile pulled him back in.
    Actor captorBusyWith = RPB_Utility.GetOtherHostileTarget(captor, arrestee, captor)
    Actor otherHostile = captorBusyWith
    if (!otherHostile)
        ; The arrestee fought by someone else while the guard is free: the player attacked by bandits when a second guard
        ; came to arrest them (the first one died). The confrontation can't play in that fight either.
        ; Not the other guards still attacking them after a fight with the guards: that's this arrest (GetOtherHostileTarget)
        otherHostile = RPB_Utility.GetOtherHostileTarget(arrestee, captor, captor)
    endif
    apArresteeRef.StopCombat()
    RPB_Utility.FlowMark("BeginArrest: arrestee StopCombat")
    ; A hostile actor (a bandit/CW-soldier/Forsworn NPC, or the player disguised via a mod like Master of Disguise) is
    ; neutralized here, not only at Imprison() time: the arrest is confirmed at this point (the bounty check that can abort
    ; the whole arrest already passed, in OnArrestBegin), and everything from here on - confrontation if any, the escort
    ; walk, teleport, arrival, strip, Imprison() - would otherwise happen while a nearby guard could still evaluate this
    ; actor as hostile and break the scripted flow. A hostile faction is only half of it: a disguise mod can also have
    ; already put the CAPTOR (or another nearby guard) into active combat directly, and - confirmed in a real test - can
    ; keep RE-adding the faction as long as the disguise stays equipped, so a single removal doesn't stick on its own.
    ; See RPB_Utility.SustainArrestPacification's doc comment (it repeats both the faction check and the combat-break for
    ; a bounded window, not just once).
    ;
    ; This one-time removal is unconditional and direct - it used to be, before an earlier commit fused it together
    ; with the sustained/repeated combat-break loop into SustainArrestPacification below. Commenting out that single
    ; fused line for a retest (round 11) silently removed BOTH jobs, not just the sustained one: with the hostile
    ; faction never stripped at all, the confrontation Scene can never confirm while nearby guards still see the
    ; actor as hostile, so Imprison()'s own documented "fallback" re-neutralize is never reached either - a real,
    ; reproduced regression (guards wouldn't stop attacking, the confrontation Scene never confirmed). Restored here,
    ; split back out from the sustained loop, so the two jobs can be tested independently again.
    RPB_Utility.NeutralizeHostileActor(arrestee)
    ; Tells Prisoner.Imprison() this arrest already did it, so it doesn't repeat the same per-faction check (a frame per
    ; faction) seconds later. "Jail", the same bucket NeutralizeHostileActor's own snapshot lives in, so it survives into the
    ; prisoner.
    RPB_StorageVars.SetBoolOnReference("Hostility Checked At Arrest", arrestee, true, "Jail")
    RPB_Utility.FlowMark("BeginArrest: NeutralizeHostileActor")
    ; Skyrim generally can't run a Scene on an actor that's still actively in combat (RPB_Utility.SustainArrestPacification's
    ; own doc comment already says so) - the arrestee's own combat is stopped above, but nothing here ever stopped the
    ; CAPTOR's. Normal gameplay never notices, because a real arrest almost always happens after Surrender (which already
    ; stops combat on both sides first) - but any arrest reached without going through Surrender first can leave the guard
    ; actively fighting the arrestee, which silently blocks the confrontation Scene's first phase from ever completing,
    ; regardless of player presence. Confirmed as the real cause of a real test's confrontation Scene never confirming.
    ; Only a guard fighting nobody else: one still busy with another hostile keeps fighting it (stopping him only made him
    ; look free for a moment)
    if (captor && !captorBusyWith)
        captor.StopCombat()
    endif
    ; Commented out for a retest (2026-09-24): possibly redundant now that the direct NeutralizeHostileActor call
    ; above already covers the one-time removal - if a disguise mod keeps re-adding the faction faster than that
    ; sticks, restore this too.
    ; RPB_Utility.SustainArrestPacification(arrestee, captor)
    RPB_Utility.FlowMark("BeginArrest: HideBounty + StopCombat")
    RPB_Utility.Crumb(arrestee, "BeginArrest: HideBounty + StopCombat")
    ; apArresteeRef.SheatheWeapon()
    ; apArresteeRef.UnequipHands()

    ; Actually consider the actor Arrested
    apArresteeRef.Arrest()
    RPB_Utility.FlowMark("BeginArrest: Arrestee.Arrest() done")
    RPB_Utility.Crumb(arrestee, "BeginArrest: Arrestee.Arrest() done")

    ; Next step, escort/move to prison
    if (arrestType == ARREST_TYPE_TELEPORT_TO_CELL)
        ; No confrontation Scene in this arrest type (straight to the cell) - nothing to confirm first, so I declare
        ; success right here, same timing as before this was split out of Arrestee.Arrest() (see DeclareArrestSuccess's
        ; own doc comment for why the escort types below don't do this immediately any more).
        apArresteeRef.DeclareArrestSuccess()
        apArresteeRef.MoveToPrison(abMoveDirectlyToCell = true)
        RPB_Utility.FlowMark("BeginArrest: MoveToPrison returned")
        RPB_Utility.Crumb(arrestee, "BeginArrest: MoveToPrison returned")
        return
        ; Handled on OnArresteeRestrained()
        SceneManager.StartArrestScene( \
            akGuard     = captor, \
            akArrestee  = apArresteeRef.GetActor(), \
            asScene     = self.GetArrestScene(apArresteeRef.GetActor()) \
        )

    ; Could be used when the arrestee still has a chance to pay their bounty, and not go to the cell immediately
    elseif (arrestType == ARREST_TYPE_TELEPORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be teleported to some location in jail and then either escorted or teleported to the cell)
        ; Handled on OnArresteeRestrained()
        SceneManager.StartArrestScene( \
            akGuard     = captor, \
            akArrestee  = arrestee, \
            asScene     = SceneManager.SCENE_ARREST_START_02 \
        )

    ; Will most likely be used when the arrestee has no chance to pay their bounty, and therefore will get immediately escorted into the cell
    elseif (arrestType == ARREST_TYPE_ESCORT_TO_CELL)
        apArresteeRef.EscortToPrison(abEscortDirectlyToCell = true, abCombatAtArrest = combatAtArrest, akOtherHostile = otherHostile)
        apArresteeRef.SetStateForScene("OnEscortPrisonerToCellEnd", "Arrest")

    elseif (arrestType == ARREST_TYPE_ESCORT_TO_JAIL)
        apArresteeRef.EscortToPrison(abCombatAtArrest = combatAtArrest, akOtherHostile = otherHostile)

        ; Reset Arrest scene for future arrests
        self.SetArrestScene(arrestee, SceneManager.SCENE_ARREST_START_02)
    endif

    ; if (!self.GetCaptorReference(captor))
    ;     ; Bind the captor to their state script
    ;     RPB_Captor captorReference = self.MarkActorAsCaptor(captor)
    ;     captorReference.AddArrestee(apArresteeRef)
    ; endif

    self.OnArrestEnd(apArresteeRef, apArresteeRef.Captor, arrestFaction)
endFunction

function PunishPaymentEvader(Actor akGuard, Actor akPayerArrestee)
    Debug("Arrest::PunishPaymentEvader", "You have strayed too far from the path, punishment is upon you!")

    int evadingPenalty = 2000
    Faction crimeFaction = akGuard.GetCrimeFaction()
    string hold = RPB_Utility.GetFormNameCached(crimeFaction)

    ; Revert Bounty
    ; self.RevertBounty(akGuard.GetCrimeFaction())
    crimeFaction.ModCrimeGold(evadingPenalty)

    ; CaptorRef.AssignArrestee(none) TODO: Replace with the equivalent for RPB_Captor
    ; BindAliasTo(CaptorRef, none) TODO: Replace with the equivalent for RPB_Captor
    akGuard.StartCombat(akPayerArrestee)

    ; Reset Bounty Payment vars
    self.SetActorWantsToPayBounty(akPayerArrestee, false)
    self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_IMPRISONMENT)

    Config.NotifyArrest("You have gained " + evadingPenalty + " Bounty in " + hold + " for evading bounty payment!")
endFunction

function ChangeArrestEscort(Actor akNewEscort, Actor akDetainee)
    ; A new guard was found, escort Detainee to jail
    ; ArrestVars.SetReference("Arrest::Arresting Guard", akNewEscort) ; Change the captor for further scenes and to lead to the cell
    ; BindAliasTo(CaptorRef, akNewEscort)
    ; sceneManager.StartEscortToJail(akNewEscort, ArrestVars.Arrestee, ArrestVars.PrisonerItemsContainer)
endFunction

function ApplyArrestResistedPenalty(Faction akArrestFaction)
    string hold = RPB_Utility.GetFormNameCached(akArrestFaction)

    int resistBountyFlat                    = config.GetArrestAdditionalBountyResistingFlat(hold)
    float resistBountyFromCurrentBounty     = PercentToDecimal(config.GetArrestAdditionalBountyResistingFromCurrentBounty(hold))
    int resistArrestPenalty                 = int_if (resistBountyFromCurrentBounty > 0, floor(akArrestFaction.GetCrimeGold() * resistBountyFromCurrentBounty)) + resistBountyFlat

    if (resistArrestPenalty > 0)
        akArrestFaction.ModCrimeGold(resistArrestPenalty)
        config.NotifyArrest("You have gained " + resistArrestPenalty + " Bounty in " + hold +" for resisting arrest!")
    endif

    Actor arrestResister = config.Player ; Temporary

    RPB_ActorVars.IncrementStat("Arrests Resisted", akArrestFaction, arrestResister)
    self.SetResistedFlag(akArrestFaction)
endFunction

function SetAsDefeated(Faction akCrimeFaction)
    ; if (!self.HasResistedArrestRecently(akCrimeFaction))
    ;     ; Do not punish if the player hasn't resisted arrest upon being defeated
    ;     return
    ; endif

    ; string hold = RPB_Utility.GetFormNameCached(akCrimeFaction)

    ; int defeatBountyFlat                = config.GetArrestAdditionalBountyDefeatedFlat(hold)
    ; float defeatBountyFromCurrentBounty = config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)
    ; float defeatBountyPercentModifier   = PercentToDecimal(defeatBountyFromCurrentBounty)
    ; int defeatArrestPenalty             = floor(akCrimeFaction.GetCrimeGold() * defeatBountyPercentModifier) + defeatBountyFlat

    ; Debug("Arrest::SetAsDefeated", "\n" +  \
    ;     "defeatBountyFlat: " + defeatBountyFlat + "\n" + \
    ;     "defeatBountyFromCurrentBounty: " + defeatBountyFromCurrentBounty + "\n" + \
    ;     "defeatBountyPercentModifier: " + defeatBountyPercentModifier  + "\n" + \
    ;     "defeatArrestPenalty: " + defeatArrestPenalty  + "\n" \
    ; )

    ; if (defeatArrestPenalty > 0)
    ;     ArrestVars.ModInt("Arrest::Bounty Non-Violent", defeatArrestPenalty)
    ;     config.NotifyArrest("You have gained " + defeatArrestPenalty + " Bounty in " + hold +" for being defeated")
    ; endif
endFunction

;/
    Sets the arrest resisted flag to true.
    While the flag is active, further arrests of this faction will no longer incur a penalty upon resisting again. 
    This is to prevent multiple guards trying to arrest the player
    and eventually end up with multiple penalties from each guard for something that should only be punished once.
    After some time, this flag will be set to false and the next arrest will be punished once again.
    For more info, see the Resisted state

    Faction     @akFaction: The arresting faction
/;
function SetResistedFlag(Faction akFaction)
    string referenceKey = "Actor FormID(" + Config.Player.GetFormID() + ")"
    RPB_StorageVars.SetBoolOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Arrest Resisted", referenceKey, true, "Pre-Arrest") ; Set arrest resisted flag
    EventManager.SendInfo("Set resisted flag for " + RPB_Utility.GetFormNameCached(akFaction), "Arrest::SetResistedFlag")
endFunction

;/
    Sets the Eluded Arrest flag to be active.
    While this flag is active, further arrest attempts of this Faction will no longer incur a penalty upon eluding again.

    This is to prevent multiple guards attempting to arrest the player and eventually end up with multiple penalties from each
    guard for something that should only be punished once.

    After some time, this flag will be inactive again and the next arrest attempt will be punished once again.

    Faction     @akFaction: The arresting faction
/;
function SetEludedFlag(Faction akFaction)
    string referenceKey = "Actor FormID(" + Config.Player.GetFormID() + ")"
    RPB_StorageVars.SetBoolOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Arrest Eluded", referenceKey, true, "Pre-Arrest") ; Set arrest eluded flag
    RegisterForDelayedEventGameTime("Eluding", 1.0)
endFunction

;/
    Resets the arrest resisted flag for all the holds.

    This flag is used to determine whether an actor should be punished for resisting arrest,
    and is set to true upon resisting, and for the remainder of that time, no further resists will
    incur another penalty, unless enough time has passed to where the flag gets set to false here
    in this function, at which point the resist will be punished again.
/;
function ResetResistedFlag()
    string referenceKey = "Actor FormID(" + Config.Player.GetFormID() + ")"
    Debug("Arrest::ResetResistedFlag", "This is called")
    RPB_StorageVars.DeleteCategoryOnReference(referenceKey, "Pre-Arrest")
    EventManager.SendInfo("The resist arrest flags have been reset.")
endFunction

function ResetEludedFlag()
    string referenceKey = "Actor FormID(" + Config.Player.GetFormID() + ")"
    Debug("Arrest::ResetEludedFlag", "This is called")
    RPB_StorageVars.DeleteCategoryOnReference(referenceKey, "Pre-Arrest")
    EventManager.SendInfo("The eluding arrest flags have been reset.")
    EventManager.SendInfo("Elude Arrest: " + GetContainerList(RPB_StorageVars.GetObjectHandleOnReference(Config.Player, "Pre-Arrest")))

endFunction

function ApplyArrestEludedPenalty(Faction akArrestFaction)
    if (self.HasEludedArrestRecently(akArrestFaction))
        EventManager.SendInfo("You have already eluded arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    string hold = RPB_Utility.GetFormNameCached(akArrestFaction)

    int eludeBountyFlat = config.GetArrestAdditionalBountyEludingFlat(RPB_Utility.GetFormNameCached(akArrestFaction))
    float eludeBountyPercent = PercentToDecimal(config.GetArrestAdditionalBountyEludingFromCurrentBounty(RPB_Utility.GetFormNameCached(akArrestFaction)))
    int totalEludeBounty = int_if (eludeBountyPercent > 0, round(akArrestFaction.GetCrimeGold() * eludeBountyPercent)) + eludeBountyFlat

    if (totalEludeBounty > 0)
        akArrestFaction.ModCrimeGold(totalEludeBounty)
        config.NotifyArrest("You have gained " + totalEludeBounty + " Bounty in " + hold + " for eluding arrest!")
    endif

    ; ArrestVars.SetBool("Arrest::Eluded", true)
    self.SetEludedFlag(akArrestFaction)
endFunction

;/
    Refactor idea:
    Have an ArresteeRef or SuspectRef script that is attached to each character arrested, storing their arrest state and then:
    Arrestee.ApplyDefeatedPenalty()
    Since the state is known, the hold, bounty and everything will be handled internally by the function without any need for params
/;
function ApplyArrestDefeatedPenalty(Faction akArrestFaction)
    string hold = RPB_Utility.GetFormNameCached(akArrestFaction)

    ; Setup Defeated penalties
    ; Helper.GetArrestAdditionalBountyOnDefeat(hold)
    ; ArrestVars.SetInt("Arrest::Bounty for Defeat", Helper.GetArrestAdditionalBountyOnDefeat(hold))

    ; ArrestVars.SetInt("Arrest::Additional Bounty when Defeated", config.GetArrestAdditionalBountyDefeatedFlat(hold))
    ; ArrestVars.SetFloat("Arrest::Additional Bounty when Defeated from Current Bounty", PercentToDecimal(config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)))
    ; ArrestVars.SetInt("Arrest::Bounty for Defeat", int_if (ArrestVars.DefeatedAdditionalBountyPercentage > 0, round(akArrestFaction.GetCrimeGold() * ArrestVars.DefeatedAdditionalBountyPercentage)) + ArrestVars.DefeatedAdditionalBounty)
    ; ArrestVars.SetBool("Arrest::Defeated", true)

    ; TODO: Fix this
    ; RPB_StorageVars.SetIntOnReference("Additional Bounty when Defeated", Config.Player, Config.GetArrestAdditionalBountyDefeatedFlat(hold), "Arrest")
    ; RPB_StorageVars.SetFloatOnReference("Additional Bounty when Defeated from Current Bounty", Config.Player, Config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold), "Arrest")
    ; RPB_StorageVars.SetIntOnReference("Bounty for Defeat", Config.Player, int_if (ArrestVars.DefeatedAdditionalBountyPercentage > 0, round(akArrestFaction.GetCrimeGold() * ArrestVars.DefeatedAdditionalBountyPercentage)) + ArrestVars.DefeatedAdditionalBounty, "Arrest")
    ; RPB_StorageVars.SetBoolOnReference("Defeated", Config.Player, true, "Arrest")

    ; Bounty is applied later at the Arrest stage.
endFunction



bool function MeetsPursuitEludeRequirements(Actor akEluder)
    return akEluder.IsRunning() || akEluder.IsSprinting()
endFunction

bool function HasResistedArrestRecently(Faction akArrestFaction)
    string referenceKey = "Actor FormID(" + Config.Player.GetFormID() + ")"
    return RPB_StorageVars.GetBoolOnReference(RPB_Utility.GetFormNameCached(akArrestFaction) + "::Arrest Resisted", referenceKey, "Pre-Arrest")
    ; return RPB_StorageVars.GetBool("Arrest::" + RPB_Utility.GetFormNameCached(akArrestFaction) + "::Arrest Resisted")
endFunction

bool function HasEludedArrestRecently(Faction akArrestFaction)
    string referenceKey = "Actor FormID(" + Config.Player.GetFormID() + ")"
    return RPB_StorageVars.GetBoolOnReference(RPB_Utility.GetFormNameCached(akArrestFaction) + "::Arrest Eluded", referenceKey, "Pre-Arrest")
    ; return RPB_StorageVars.GetBool("Arrest::" + RPB_Utility.GetFormNameCached(akArrestFaction) + "::Arrest Eluded")
endFunction

function SetEludedGuard(Actor akEludedGuard, string asEludeType)
    RPB_StorageVars.SetForm("Eluded Captor", akEludedGuard, "Arrest")
    RPB_StorageVars.SetString("Elude Type", asEludeType, "Arrest")
    ; ArrestVars.SetActor("Arrest::Eluded Captor", akEludedGuard)
    ; ArrestVars.SetString("Arrest::Elude Type", asEludeType)
endFunction

function TriggerForcegreetEluding(Actor akEludedGuard)
    Debug("Arrest::TriggerForcegreetEluding", "Distance from Speaker: " + akEludedGuard.GetDistance(akEludedGuard.GetDialogueTarget()))
    self.SetEludedGuard(akEludedGuard, "Dialogue")
    SceneManager.StartEludingArrest(akEludedGuard, config.Player)
endFunction

function TriggerPursuitEluding(Actor akEludedGuard)
    ; if (akEludedGuard.GetCrimeFaction().GetCrimeGold() > 1000)
    ;     akEludedGuard.StartCombat(Config.Player)
    ;     return
    ; endif
    self.SetEludedGuard(akEludedGuard, "Pursuit")
    RegisterForDelayedEvent("Eluding", config.ArrestEludeWarningTime) ; Register for a delayed event on Eluding::OnUpdate()
endFunction

function SetActorWantsToPayBounty(Actor akPayerArrestee, bool abWantsToPay = true)
    ; ArrestVars.SetBool("Arrest::Paying Bounty" , abWantsToPay)
    ; Debug("Arrest::SetActorWantsToPayBounty", "Arrest::Paying Bounty: " + ArrestVars.GetBool("Arrest::Paying Bounty"))
endFunction

bool function GetActorIsPayingBounty(Actor akPayerArrestee)
    ; return ArrestVars.GetBool("Arrest::Paying Bounty")
endFunction

string function GetArrestScene(Actor akArrestee, string asFallbackScene = "RPB_ArrestStart02")
    ; if (akArrestee == Config.Player)

    ;     ; return RPB_StorageVars.GetStringOnReference("Scene", akArrestee, "Arrest")

    ;     if (ArrestVars.Exists("Arrest::Scene"))
    ;         return ArrestVars.GetString("Arrest::Scene")
    ;     endif

    ;     return asFallbackScene
    ; endif
endFunction

string function GetArrestGoal(Actor akArrestee)
    return RPB_StorageVars.GetStringOnReference("Arrest Goal", akArrestee, "Arrest")
    ; return ArrestVars.GetString("Arrest::Arrest Goal")
endFunction

bool function IsActorToBeImprisoned(Actor akArrestee)
    return self.GetArrestGoal(akArrestee) == ARREST_GOAL_IMPRISONMENT
endFunction

bool function IsActorToPayBounty(Actor akArrestee)
    return self.GetArrestGoal(akArrestee) == ARREST_GOAL_BOUNTY_PAYMENT
endFunction

function PayCrimeGold(Actor akPayer, Faction akCrimeFaction)
    ; if (akPayer == Config.Player) ; Later this should be dynamic for all Actors without a condition
    ;     int currentBountyNonViolent = ArrestVars.GetInt("Arrest::Bounty Non-Violent")
    ;     int currentBountyViolent    = ArrestVars.GetInt("Arrest::Bounty Violent")
    ;     int totalBounty = currentBountyNonViolent + currentBountyViolent
    ;     Form gold = Game.GetFormEx(0xF)
    ;     akPayer.RemoveItem(gold, totalBounty, true)

    ;     ; Clear Bounty
    ;     ArrestVars.Remove("Arrest::Bounty Non-Violent")
    ;     ArrestVars.Remove("Arrest::Bounty Violent")
    ;     akCrimeFaction.PlayerPayCrimeGold(false, false)

    ;     Config.NotifyArrest("Your bounty in " + RPB_Utility.GetFormNameCached(akCrimeFaction) + " has been paid")
    ; endif
endFunction

function ResetArrest(string reason = "")
    ; Clear all arrest related vars
    ; ArrestVars.Clear()
    Info(reason, reason != "")
endFunction

; ==========================================================
;                           Utility
;/
    Registers a delayed event through a state's OnUpdate()

    string  @stateName: The name of the state that represents the event name
    float   @delaySeconds: The time waited in seconds before the event is fired
/;
function RegisterForDelayedEvent(string stateName, float delaySeconds)
    RegisterForSingleUpdate(delaySeconds)
    GotoState(stateName)
endFunction

;/
    Registers a delayed event through a state's OnUpdateGameTime()

    string  @stateName: The name of the state that represents the event name
    float   @delayGameTime: The time waited in game-time before the event is fired (1 = 1 Day | 1/24 = 1h)
/;
function RegisterForDelayedEventGameTime(string stateName, float delayGameTime)
    RegisterForSingleUpdateGameTime(delayGameTime)
    GotoState(stateName)
endFunction

function RestrainArrestee(Actor akArrestee)
    ; Hand Cuffs Backside Rusty - 0xA081D2F
    ; Hand Cuffs Front Rusty - 0xA081D33
    ; Hand Cuffs Front Shiny - 0xA081D34
    ; Hand Cuffs Crossed Front 01 - 0xA033D9D
    ; Hands Crossed Front in Scarfs - 0xA073A14
    ; Hands in Irons Front Black - 0xA033D9E
    RPB_Utility.EquipCuffs(akArrestee) ; behind the back; weapons sheathed, not taken (they stay on until the strip)
endFunction

function UnrestrainArrestee(Actor akRestrainedArrestee)
    Form restraints = akRestrainedArrestee.GetEquippedArmorInSlot(59)
    akRestrainedArrestee.UnequipItemSlot(59)
    akRestrainedArrestee.RemoveItem(restraints)
    ReleaseAI()
endFunction

; ==========================================================
;                  Validation & Maintenance

function RegisterHotkeys()
    RegisterForKey(0x58) ; F12
    RegisterForKey(0x57) ; F11
    RegisterForKey(0x44) ; F10
    RegisterForKey(0x42) ; F8
    RegisterForKey(0x41) ; F7
    RegisterForKey(0x40) ; F6
endFunction

function EnableForcedArrestDialogue() global
    GlobalVariable RPB_NoArrestDialogue = RPB_Utility.RPB_ArrestGlobal("No Dialogue")
    RPB_NoArrestDialogue.SetValueInt(0)
endFunction

function DisableForcedArrestDialogue() global
    GlobalVariable RPB_NoArrestDialogue = RPB_Utility.RPB_ArrestGlobal("No Dialogue")
    RPB_NoArrestDialogue.SetValueInt(1)
endFunction

function AllowArrestForcegreets(bool allow = true) global
    ; Allow/Disallow Forcegreets (used in AI package RPB_DGForcegreet for Arrest eludes)
    GlobalVariable RPB_AllowArrestForcegreet = GetFormFromMod(0x130D7) as GlobalVariable
    RPB_AllowArrestForcegreet.SetValueInt(allow as int)
endFunction

function SetupArrestPayableBountyVars(Faction akCrimeFaction)
    GlobalVariable RPB_ArrestGuaranteedPayableBounty = GetFormFromMod(0x161D2) as GlobalVariable
    GlobalVariable RPB_ArrestMaxPayableBounty        = GetFormFromMod(0x161D4) as GlobalVariable
    GlobalVariable RPB_ArrestRollDiceResult          = GetFormFromMod(0x16737) as GlobalVariable
    GlobalVariable RPB_ArrestAllowFrisk              = GetFormFromMod(0x1776A) as GlobalVariable
    
    string hold = RPB_Utility.GetFormNameCached(akCrimeFaction)

    ; Update Globals (Determines if the arrest will be payable for sure, or if it falls within the maximum payable, which needs a roll of the dice)
    RPB_ArrestGuaranteedPayableBounty.SetValueInt(Config.GetArrestGuaranteedPayableBounty(hold))
    RPB_ArrestMaxPayableBounty.SetValueInt(Config.GetArrestMaximumPayableBounty(hold))
    RPB_ArrestAllowFrisk.SetValueInt(Config.IsFriskingEnabled(hold) as int)

    ; Roll the dice for max payable bounty chance
    int maxPayableChance = Config.GetArrestMaximumPayableChance(hold)
    int random = Utility.RandomInt(1, 100)
    RPB_ArrestRollDiceResult.SetValueInt(int_if (random <= maxPayableChance, 1, 0)) ; 1 = able to pay max bounty / 0 = not able
    Debug("Arrest::SetupArrestPayableBountyVars", "Needed: <= " + maxPayableChance + ", Got: " + random)

    Trace("Arrest::SetupArrestPayableBountyVars", "Stack Trace: [\n" + \
        "\tRPB_ArrestGuaranteedPayableBounty: " + RPB_ArrestGuaranteedPayableBounty.GetValueInt() + "\n" + \
        "\tRPB_ArrestMaxPayableBounty: " + RPB_ArrestMaxPayableBounty.GetValueInt() + "\n" + \
        "\tRPB_ArrestRollDiceResult: " + RPB_ArrestRollDiceResult.GetValueInt() + "\n" + \
        "\tmaxPayableChance: " + maxPayableChance + "\n" + \
        "\trandom: " + random + "\n" + \
        "\tAble to Pay Max Bounty: " + (random <= maxPayableChance) + "\n" + \
        "\takCrimeFaction: " + akCrimeFaction + "\n" + \
    "\n]")
endFunction

function ResetDiceRollForMaxPayableBounty() global
    GlobalVariable RPB_ArrestRollDiceResult = GetFormFromMod(0x16737) as GlobalVariable
    RPB_ArrestRollDiceResult.SetValueInt(0)
endFunction

bool function IsValidArrestGoal(string asArrestGoal)
    return  asArrestGoal == ARREST_GOAL_IMPRISONMENT || \
            asArrestGoal == ARREST_GOAL_BOUNTY_PAYMENT || \
            asArrestGoal == ARREST_GOAL_TEMPORARY_HOLD
endFunction

bool function ValidateArrestType(string arrestType)
    return  arrestType == ARREST_TYPE_TELEPORT_TO_JAIL || \ 
            arrestType == ARREST_TYPE_TELEPORT_TO_CELL || \ 
            arrestType == ARREST_TYPE_ESCORT_TO_JAIL || \
            arrestType == ARREST_TYPE_ESCORT_TO_CELL
endFunction

string function GetValidArrestTypes()
    return  ARREST_TYPE_TELEPORT_TO_JAIL + ", " + \ 
            ARREST_TYPE_TELEPORT_TO_CELL + ", " + \ 
            ARREST_TYPE_ESCORT_TO_JAIL + ", " + \ 
            ARREST_TYPE_ESCORT_TO_CELL
endFunction

; ==========================================================
;                   Notification Management
; ==========================================================

bool property ShouldDisplayArrestNotifications
    bool function get()
        return Config.ShouldDisplayArrestNotifications
    endFunction
endProperty

bool property ShouldDisplayBountyDecayNotifications
    bool function get()
        return Config.ShouldDisplayBountyDecayNotifications
    endFunction
endProperty

function NotifyArrest(string msg, bool condition = true)
    if (ShouldDisplayArrestNotifications && condition)
        debug.notification(msg)
    endif
endFunction

function NotifyBounty(string msg, bool condition = true)
    if (ShouldDisplayBountyDecayNotifications && condition)
        debug.notification(msg)
    endif
endFunction

; ==========================================================
;                   States & Delayed Events
; ==========================================================

; Should be refactored into a handler responsible for each Actor later
state Eluding
    event OnBeginState()
        Debug("Arrest::OnBeginState", "Begin State " + self.GetState())
    endEvent

    event OnUpdate()
        ; string eludeType = ArrestVars.GetString("Arrest::Elude Type")
        string eludeType = RPB_StorageVars.GetString("Elude Type", "Arrest")

        if (eludeType == "Pursuit")
            if (self.MeetsPursuitEludeRequirements(Config.Player))
                ; Actor eludedCaptor = ArrestVars.GetActor("Arrest::Eluded Captor")
                Actor eludedCaptor = RPB_StorageVars.GetForm("Eluded Captor", "Arrest") as Actor
                self.OnArrestEludeTriggered(eludedCaptor, eludeType) ; Explicitly fire Event
            endif
        endif

        GotoState("")
    endEvent

    event OnEndState()
        Debug("Arrest::OnStartState", "End State " + self.GetState())
    endEvent
endState
