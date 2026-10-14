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
@references:
    RPB_API API
    RPB_Config Config
    RPB_EventManager EventManager
    RPB_SceneManager SceneManager
    RPB_Surrender Surrender
    RPB_ArresteeList Arrestees
    RPB_CaptorList Captors
@properties:
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
    function ArrestActor(Actor akArrester, Actor akArrestee, string asArrestType, bool abKeepFlow = false)
    function SetAsideBountyOnSubmission(Actor akActor, Actor akGuard) global
    function __SetAsideBountyFrom(Actor akActor, Actor akGuard) global
    function __SetAsideBounty(Actor akActor, Actor akGuard, Faction akCrimeFaction) global
    bool function HasSetAsideBounty(Actor akActor) global
    bool function GiveBackSetAsideBounty(Actor akActor, string asWhy) global
    function RequestSubmissionTakeover(Actor akFrozenGuard) global
    function TakeOverSubmission(Actor akFrozenGuard)
    function TakeOverStalledEscort(Actor akActor, string asReason)
    function ArrestActorForFaction(Faction akCrimeFaction, Actor akArrestee, string asArrestType)
    function ArrestActors(Actor akArrester, Actor[] akArrestees, string asArrestType, bool abEnsureAllArrested = true, float afWaitTimeBetweenArrests = 0.3)
    function SetAsEluding(Actor akEludedGuard, Actor akEluder, string asEludeType)
    function SetAsResisting(Actor akGuard, Actor akResister)
    function SetAsYielding(Actor akSparerGuard, Actor akYieldedArrestee)
    function StartBountyPayment(Actor akGuard, Actor akPayerArrestee, string asBountyPaymentScenario)
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
    function __WorldInteractionsInCustody(bool abInCustody) global
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
    event OnArresting(Actor akCaptor, Actor akArrestee)
    event OnArrestDialogue(int aiTopicInfoEvent, int aiTopicInfoType, string asTopicInfoDialogue, Actor akSpeakerArrester, Actor akSpokenToArrestee)
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

RPB_Surrender property Surrender
    RPB_Surrender function get()
        return API.Surrender
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

; The arrest side's quest-level watch (patch 013 puts it on the ArresteeList alias, as each prison alias has its monitor)
RPB_ArrestMonitor property Monitor
    RPB_ArrestMonitor function get()
        return (Arrestees as ReferenceAlias) as RPB_ArrestMonitor
    endFunction
endProperty

; An NPC's escort to jail began (RPB_Arrestee.OnArrestEnd)
function WatchEscortToJail(Actor akEscortee)
    RPB_ArrestMonitor arrestMonitor = Monitor
    if (arrestMonitor)
        arrestMonitor.WatchEscortToJail(akEscortee)
    endif
endFunction

; Her escort to jail is over, or her arrest (RPB_Arrestee.EndEscortWatch, Destroy)
function StopWatchingEscort(Actor akEscortee)
    RPB_ArrestMonitor arrestMonitor = Monitor
    if (arrestMonitor)
        arrestMonitor.StopWatching(akEscortee)
    endif
endFunction

; Whether @akActor's arrest put the cuffs on (RPB_Arrestee.OnRestrained), whatever they wear now
bool function WasRestrainedByArrest(Actor akActor)
    RPB_Arrestee arrestee = Arrestees.AtKey(akActor)
    return arrestee && arrestee.GetBool("Restrained By Arrest")
endFunction

; A step of a confrontation (RPB_EventManager.OnArrestScene): the stuck-confrontation watch's clock (RPB_ArrestMonitor)
function NoteConfrontationStep(Actor akArrestee, string asStep)
    RPB_ArrestMonitor arrestMonitor = Monitor
    if (arrestMonitor)
        arrestMonitor.NoteConfrontationStep(akArrestee, asStep)
    endif
endFunction

function StopWatchingConfrontation(Actor akArrestee)
    RPB_ArrestMonitor arrestMonitor = Monitor
    if (arrestMonitor)
        arrestMonitor.StopWatchingConfrontation(akArrestee)
    endif
endFunction

;/
    @akActor's confrontation stopped moving (RPB_ArrestMonitor: no step for its time, or @akStuckGuard frozen). Another guard
    of the hold takes it over, by the takeover rule (noticed within 15m, or seen within 40m), up to STALL_TAKEOVERS_MAX per
    arrest: not cuffed yet, he plays the whole confrontation again (RPB_Arrestee.HandOverConfrontation), the arrestee's pose
    (hands behind the back, kept when its Scene stops) reset first so the replay starts from a natural stance (the mod
    author, 2026-10-10: a walk-up with PathToReference failed at once, cuffing the player from 749 away); cuffed, only the
    escort is left (HandOverEscort). With none: GiveUpConfrontation. On RPB_ConfrontationStalled's own stack (the search
    calls into the guards around). A frozen arrestee is left to the next load: every step here calls into her
/;
function TakeOverStalledConfrontation(Actor akActor, Actor akStuckGuard, string asReason, string asStep = "")
    RPB_Arrestee arrestee = Arrestees.AtKey(akActor)
    if (!arrestee || RPB_Utility.IsFrozenNPC(akActor))
        return
    endif
    Actor guard = none
    if (arrestee.GetInt("Confrontation Takeovers") < arrestee.STALL_TAKEOVERS_MAX)
        guard = RPB_Utility.FindTakeoverGuard(akActor, arrestee.GetFaction(), akStuckGuard, TAKEOVER_ARREST_DISTANCE, TAKEOVER_APPROACH_DISTANCE)
    endif
    if (!guard)
        self.GiveUpConfrontation(arrestee, akStuckGuard, asReason)
        return
    endif
    arrestee.SetInt("Confrontation Takeovers", arrestee.GetInt("Confrontation Takeovers") + 1)
    bool releaseOld = !RPB_Utility.IsFrozenNPC(akStuckGuard)
    bool cuffed = RPB_Utility.IsCuffed(akActor)
    bool posing = !cuffed && (asStep == "Hands Behind Back" || asStep == "Handcuff")
    string taking = ", the confrontation again"
    if (cuffed)
        taking = ", the escort"
    elseif (posing)
        taking = ", the confrontation again (their pose reset)"
    endif
    RPB_Utility.LogInfo(akActor + "'s " + asReason + ": " + guard + " (" + ((akActor.GetDistance(guard) * 0.01428) as int) + "m) takes it over from " + akStuckGuard + taking + " (takeover " + arrestee.GetInt("Confrontation Takeovers") + "/" + arrestee.STALL_TAKEOVERS_MAX + ")", "Arrest::TakeOverStalledConfrontation")
    if (cuffed)
        arrestee.HandOverEscort(akStuckGuard, guard, asReason, abReleaseOld = releaseOld)
    else
        arrestee.HandOverConfrontation(akStuckGuard, guard, asReason, releaseOld, abResetPose = posing)
    endif
    RPB_Utility.ProbeAfterBurst(guard, "took over a stuck confrontation")
endFunction

;/
    A stuck confrontation nobody can take over (the mod author, 2026-10-10): with the player there (the arrestee, or an NPC
    whose 3D is loaded, so in sight) the arrest is cancelled, as a fight before the cuffs is; with nobody there to see it
    (an arrest left to run off-screen, or an NPC arrest made through the API later), she goes to the prison, cuffed
/;
function GiveUpConfrontation(RPB_Arrestee apArrestee, Actor akStuckGuard, string asReason)
    Actor arresteeActor = apArrestee.GetActor()
    if (arresteeActor == Config.Player || arresteeActor.Is3DLoaded())
        RPB_Utility.LogInfo(arresteeActor + "'s " + asReason + ", and no guard to take it over: the arrest is cancelled", "Arrest::GiveUpConfrontation")
        RPB_Recovery.CancelArrest(arresteeActor, asReason + ", no guard to take it over")
        return
    endif
    RPB_Utility.LogInfo(arresteeActor + "'s " + asReason + ", no guard to take it over and nobody there to see it: to the prison", "Arrest::GiveUpConfrontation")
    apArrestee.ConfrontationToPrison(akStuckGuard, asReason)
endFunction

; After a game load (RPB_ConfigAlias.PerformMaintenance): every NPC arrestee's escort watch started again (RPB_Arrestee.
; ResumeEscortWatch). The list read without a call into anyone; the few arrestees each get one call
function ResumeEscortWatchesAfterLoad()
    ; The stuck-confrontation clocks start over (real time restarts with each session), and a confrontation playing in a save
    ; made before it was watched is watched now (one Scene plays at a time: the current one)
    RPB_ArrestMonitor arrestMonitor = Monitor
    if (arrestMonitor)
        arrestMonitor.RestartClocksAfterLoad()
        string current = API.SceneManager.GetCurrentScene()
        if (API.SceneManager.IsSceneOfType(current, API.SceneManager.CATEGORY_ARREST_START))
            Actor confronted = API.SceneManager.GetSceneNthReferenceOfType(current, "Escortee") as Actor
            if (confronted)
                arrestMonitor.NoteConfrontationStep(confronted, "Resumed")
            endif
        endif
    endif
    ; An escort to jail already playing at the load began before it (the player's included: a save from before the begin
    ; mark existed read as an escort that never started, RPB_Arrestee.__EscortNeverBegan)
    string playing = API.SceneManager.GetCurrentScene()
    if (API.SceneManager.IsSceneOfType(playing, API.SceneManager.CATEGORY_ESCORT_TO_JAIL))
        Actor escorted = API.SceneManager.GetSceneNthReferenceOfType(playing, "Escortee") as Actor
        RPB_Arrestee escortedState = none
        if (escorted && !RPB_Utility.IsFrozenNPC(escorted))
            escortedState = Arrestees.AtKey(escorted)
        endif
        if (escortedState)
            escortedState.SetBool("Escort Begun", true)
        endif
    endif
    Form[] actors = Arrestees.GetActorsNoCall()
    int i = 0
    while (actors && i < actors.Length)
        Actor arresteeActor = actors[i] as Actor
        if (arresteeActor && arresteeActor != Config.Player && !RPB_Utility.IsFrozenNPC(arresteeActor))
            RPB_Arrestee arrestee = Arrestees.AtKey(arresteeActor)
            if (arrestee)
                arrestee.ResumeEscortWatch("after the game load")
            endif
        endif
        i += 1
    endWhile
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
    if (!akGuard || RPB_Utility.IsFrozenNPC(akGuard))
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
    ; Guards froze right after things of mine came off them (150's clone: this, then his package lock): probes after it
    RPB_Utility.ProbeAfterBurst(apCaptor.GetActor(), "captor spell removed")

    if (abRemoveFromList && Captors.Exists(apCaptor))
        Captors.Remove(apCaptor)
    endif
    RPB_Recovery.__Step(apCaptor.GetActor(), "UnregisterCaptor: list done")
endFunction

; ==========================================================

event OnInit()
    RegisterHotkeys()
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

            ; Who forcegreets matters for the guard-freeze hunt: every freeze so far came with a confront 1-3s after a Captor came off
            RPB_Utility.LogInfo("Arrest confront by " + akSpeakerArrester + " to " + akSpokenToArrestee + " (probe open on the speaker: " + RPB_Utility.IsNPCProbeOpen(akSpeakerArrester) + ")", "Arrest::OnArrestDialogue")
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
                RPB_Utility.LogInfo("Not resisting arrest: " + akSpeakerArrester + " left the arrest dialogue in a fight", "Arrest::OnArrestDialogue")
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            ; Just submitted ("I'll go to jail"): the arrest is on its way but not registered yet, and the guard's forcegreet came
            ; straight back (the bounty isn't cleared until the arrest starts), was cut off by the arrest, and vanilla had him
            ; speak a resist line for it (2026-10-03: the player resisted on every submission). Any guard, a few seconds
            float submittedAt = RPB_StorageVars.GetFloatOnReference("Submitted At", akSpokenToArrestee, "Pre-Arrest")
            float sinceSubmitted = Utility.GetCurrentRealTime() - submittedAt
            if (submittedAt > 0.0 && sinceSubmitted >= 0.0 && sinceSubmitted < 10.0)
                RPB_Utility.LogInfo("Not resisting arrest: " + akSpokenToArrestee + " submitted " + (sinceSubmitted as int) + "s ago (" + akSpeakerArrester + "'s line came from the dialogue the arrest cut off)", "Arrest::OnArrestDialogue")
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            ; Test-only: the teardown's move home cuts a confront its own reset set off (the test's bounty given back)
            if (RPB_Utility.IsTestTeardownRunning())
                RPB_Utility.LogInfo("Not resisting arrest: a test's teardown cut " + akSpeakerArrester + "'s arrest dialogue", "Arrest::OnArrestDialogue")
                akSpeakerArrester.EvaluatePackage()
                return
            endif

            ; Another guard's dialogue while one is already handling the arrest (several guards around: they come to talk
            ; while the first one still is, and their resist line counted as the player resisting, without them ever
            ; leaving the first dialogue). Only the guard handling it can be resisted.
            if (self.__OtherGuardHandlesArrestDialogue(akSpeakerArrester, akSpokenToArrestee))
                RPB_Utility.LogInfo("Not resisting arrest: " + akSpeakerArrester + " spoke while another guard handles the arrest dialogue", "Arrest::OnArrestDialogue")
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
            RPB_Utility.LogInfo("Not eluding arrest: " + akSpokenToArrestee + " is already arrested, imprisoned or surrendering (" + akSpeakerArrester + "'s line)", "Arrest::OnArrestDialogue")
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
            ; Noted first: a resist line from the dialogue this arrest cuts off isn't the player resisting (TOPIC_TYPE_ARREST_RESIST)
            RPB_StorageVars.SetFloatOnReference("Submitted At", akSpokenToArrestee, Utility.GetCurrentRealTime(), "Pre-Arrest")
            ; The bounty is set aside when this line starts (its begin fragment); again here in case that one didn't run
            RPB_Arrest.SetAsideBountyOnSubmission(akSpokenToArrestee, akSpeakerArrester)
            self.ArrestActor(akSpeakerArrester, akSpokenToArrestee, ARREST_TYPE_ESCORT_TO_JAIL)
        endif
    endif
endEvent

; The player's bounty, set aside the moment they submit: called when the guard's "go to jail" line starts (its begin
; fragment), so no guard sees it while the arrest gets going. The vanilla forcegreet goes by the bounty alone: set aside at
; the line's end, it was a few frames late, the guard's forcegreet had already come back, and the arrest cutting it off had
; him speak a resist line ("Then pay with your blood", 2026-10-04). The arrest takes it back right before hiding it itself
; (BeginArrest), so its stats and latent bounty work as always. Given back at once when the arrest is rejected
; (RPB_EventManager.OnArrestBegin) or the guard is found frozen (RPB_Utility.MarkNPCFrozen), and after 30s if nothing
; took it (RPB_EventManager.OnSetAsideBountyCheck). Only the player: an NPC's bounty is RPB's own and no forcegreet reads it.
; His crime faction is read on a stack of its own (RPB_EventManager.OnSetAsideBounty -> __SetAsideBountyFrom): this runs
; first in the line's fragment, before its probe, and a call into a guard who froze (not marked yet) held the fragment there,
; the probe after it never ran (2026-10-12 audit). A frame later, still at the line's beginning
function SetAsideBountyOnSubmission(Actor akActor, Actor akGuard) global
    if (!akActor || !akGuard || akActor != Game.GetPlayer() || HasSetAsideBounty(akActor) || RPB_Utility.IsFrozenNPC(akGuard))
        return
    endif
    int handle = ModEvent.Create("RPB_SetAsideBounty")
    if (handle)
        ModEvent.PushForm(handle, akActor)
        ModEvent.PushForm(handle, akGuard)
        ModEvent.Send(handle)
    endif
endFunction

; RPB_EventManager.OnSetAsideBounty: the set-aside, with the call into him
function __SetAsideBountyFrom(Actor akActor, Actor akGuard) global
    if (HasSetAsideBounty(akActor) || RPB_Utility.IsFrozenNPC(akGuard))
        return
    endif
    RPB_Arrest.__SetAsideBounty(akActor, akGuard, akGuard.GetCrimeFaction())
endFunction

; The set-aside itself, @akCrimeFaction given (no call into @akGuard: he may be frozen)
function __SetAsideBounty(Actor akActor, Actor akGuard, Faction akCrimeFaction) global
    Faction crimeFaction = akCrimeFaction
    if (!crimeFaction || HasSetAsideBounty(akActor))
        return
    endif
    int nonViolent  = crimeFaction.GetCrimeGoldNonViolent()
    int violent     = crimeFaction.GetCrimeGoldViolent()
    if (nonViolent + violent <= 0)
        return
    endif

    RPB_StorageVars.SetFormOnReference("Faction", akActor, crimeFaction, "Set-Aside Bounty")
    RPB_StorageVars.SetFormOnReference("Guard", akActor, akGuard, "Set-Aside Bounty")
    RPB_StorageVars.SetIntOnReference("Non-Violent", akActor, nonViolent, "Set-Aside Bounty")
    RPB_StorageVars.SetIntOnReference("Violent", akActor, violent, "Set-Aside Bounty")
    crimeFaction.SetCrimeGold(0)
    crimeFaction.SetCrimeGoldViolent(0)
    RPB_Utility.LogInfo("Set aside " + akActor + "'s bounty in " + RPB_Utility.GetFormNameCached(crimeFaction) + " on submitting to " + akGuard + " (" + nonViolent + " non-violent, " + violent + " violent)", "Arrest::SetAsideBountyOnSubmission")

    ; A guard freezing now never sends his arrest: the probe finds him, and MarkNPCFrozen gives the bounty back
    RPB_Utility.ProbeAfterBurst(akGuard, "submitted to him")

    int handle = ModEvent.Create("RPB_SetAsideBountyCheck")
    if (handle)
        ModEvent.PushForm(handle, akActor)
        ModEvent.PushFloat(handle, 30.0)
        ModEvent.Send(handle)
    endif
endFunction

bool function HasSetAsideBounty(Actor akActor) global
    return RPB_StorageVars.GetFormOnReference("Faction", akActor, "Set-Aside Bounty") != none
endFunction

; Puts a set-aside bounty back where it was. Added to what's there, so a bounty gained meanwhile is kept. Returns whether
; there was one
bool function GiveBackSetAsideBounty(Actor akActor, string asWhy) global
    if (!akActor)
        return false
    endif
    Faction crimeFaction = RPB_StorageVars.GetFormOnReference("Faction", akActor, "Set-Aside Bounty") as Faction
    if (!crimeFaction)
        return false
    endif

    int nonViolent  = RPB_StorageVars.GetIntOnReference("Non-Violent", akActor, "Set-Aside Bounty")
    int violent     = RPB_StorageVars.GetIntOnReference("Violent", akActor, "Set-Aside Bounty")
    RPB_StorageVars.DeleteCategoryOnReference(akActor, "Set-Aside Bounty")
    crimeFaction.ModCrimeGold(nonViolent)
    crimeFaction.ModCrimeGold(violent, true)
    ; Already counted when it was gained: giving it back mustn't count it again (RPB_ActorBase.RestoreBountyForFaction)
    Game.IncrementStat("Total Lifetime Bounty", -(nonViolent + violent))
    RPB_Utility.LogInfo("Gave back " + akActor + "'s set-aside bounty in " + RPB_Utility.GetFormNameCached(crimeFaction) + " (" + nonViolent + " non-violent, " + violent + " violent): " + asWhy, "Arrest::GiveBackSetAsideBounty")
    return true
endFunction

; The guard the player submitted to is frozen (found by a probe, or his arrest rejected for it): another guard takes the
; arrest over, on a stack of its own (the search calls into the guards around, and one of them may be frozen too)
function RequestSubmissionTakeover(Actor akFrozenGuard) global
    Actor player = Game.GetPlayer()
    if (!akFrozenGuard)
        return
    endif
    ; His submission (not started yet), or his arrest of the player (started, the escort not yet): the arrest stores its
    ; guard, so neither check calls into him
    RPB_Arrestee arrestee = (RPB_API.GetArrest()).Arrestees.AtKey(player)
    if (RPB_StorageVars.GetFormOnReference("Guard", player, "Set-Aside Bounty") != akFrozenGuard && !(arrestee && arrestee.GetCaptorActor() == akFrozenGuard))
        return
    endif
    int handle = ModEvent.Create("RPB_SubmissionTakeover")
    if (handle)
        ModEvent.PushForm(handle, akFrozenGuard)
        ModEvent.Send(handle)
    endif
endFunction

; How far a guard taking over a frozen guard's arrest may be (game units, ~70 per metre): within TAKEOVER_ARREST_DISTANCE
; (15m) a guard who noticed the player arrests them directly; up to TAKEOVER_APPROACH_DISTANCE (40m), noticed and in line
; of sight, he walks over first (surrender-like, running is eluding). Placeholders until the mod author settles them
float property TAKEOVER_ARREST_DISTANCE = 1050.0 autoreadonly
float property TAKEOVER_APPROACH_DISTANCE = 2800.0 autoreadonly

;/
    The player had submitted to @akFrozenGuard ("I'll go to jail") and he froze before his arrest could start. The mod
    author's rule (2026-10-04), by the guards of the same hold who noticed the player (RPB_Utility.FindTakeoverGuard):
    - one within 15m: he arrests them straight away, no new dialogue (asking again would only repeat their choice);
    - one within 40m, in line of sight: he walks over through the Surrender Scene, the player in a surrender-like state
      (they can still move: leaving is eluding arrest), and arrests them when he gets there;
    - nobody: the arrest is off, the bounty comes back, and the player can go.
    The frozen guard faints either way (RPB_Utility.FaintFrozenGuard), for 15s when another guard took over, until the next
    load when nobody did: the visible reason his arrest stopped. The bounty stays set aside while another guard comes (the
    arrest takes it as usual). An arrest already under way (the Arrestee effect is on) isn't this case: that's a guard
    frozen mid-arrest.
/;
function TakeOverSubmission(Actor akFrozenGuard)
    Actor player = Config.Player
    if (RPB_StorageVars.GetFormOnReference("Guard", player, "Set-Aside Bounty") != akFrozenGuard)
        ; Not a submission waiting for its arrest: his arrest of the player may have started already
        if (!self.__CancelArrestByFrozenGuard(player, akFrozenGuard))
            return ; the arrest took the bounty meanwhile, or another takeover already did this
        endif
    endif
    ; His arrest only half set up: it froze between making the player the arrestee and making him the captor (the Captor
    ; await calls into him), so the player has the Arrestee spell and no captor, or him (2026-10-04: "already under way",
    ; and the bounty came back 30s later). That arrest is cancelled; the bounty stays set aside for the takeover
    RPB_Arrestee halfArrestee = Arrestees.AtKey(player)
    Actor halfCaptor = none
    if (halfArrestee)
        halfCaptor = halfArrestee.GetCaptorActor()
    endif
    if (player.HasSpell(RPB_Utility.RPB_ArresteeSpell()) && !RPB_Utility.IsActorArrested(player) && !RPB_Utility.IsActorImprisoned(player) && (!halfCaptor || halfCaptor == akFrozenGuard))
        RPB_Utility.LogInfo(akFrozenGuard + " froze while his arrest of " + player + " was being set up: that arrest is cancelled for the takeover", "Arrest::TakeOverSubmission")
        RPB_Recovery.CancelArrest(player, "the guard they submitted to froze while the arrest was being set up")
        if (player.HasSpell(RPB_Utility.RPB_ArresteeSpell())) ; no Arrestee registered yet to revert: the spell alone
            player.RemoveSpell(RPB_Utility.RPB_ArresteeSpell())
        endif
    endif
    if (RPB_Utility.IsActorArrested(player) || RPB_Utility.IsActorImprisoned(player) || player.HasSpell(RPB_Utility.RPB_ArresteeSpell()) || Surrender.IsSurrendering(player))
        RPB_Utility.LogWarn("No takeover for " + akFrozenGuard + ": " + player + "'s arrest is already under way", "Arrest::TakeOverSubmission")
        return
    endif

    ; Frozen during his own jail line, he leaves the player in his dialogue, and no Scene plays while it's open (2026-10-04:
    ; the takeover's cuffing Scene never got its first phase). It closes on its own once the line is over
    int waits = 0
    while (UI.IsMenuOpen("Dialogue Menu") && waits < 20)
        Utility.WaitMenuMode(0.5)
        waits += 1
    endWhile
    if (waits > 0)
        RPB_Utility.LogInfo("Takeover of " + akFrozenGuard + "'s arrest waited " + (waits / 2) + "s for the dialogue to close (open still: " + UI.IsMenuOpen("Dialogue Menu") + ")", "Arrest::TakeOverSubmission")
    endif

    Faction crimeFaction = RPB_StorageVars.GetFormOnReference("Faction", player, "Set-Aside Bounty") as Faction
    Actor guard = RPB_Utility.FindTakeoverGuard(player, crimeFaction, akFrozenGuard, TAKEOVER_ARREST_DISTANCE, TAKEOVER_APPROACH_DISTANCE)
    RPB_Utility.FaintFrozenGuard(akFrozenGuard, abAlone = !guard)
    if (!guard)
        RPB_Arrest.GiveBackSetAsideBounty(player, "the guard they submitted to (" + akFrozenGuard + ") is frozen and no other guard of the hold noticed them")
        return
    endif

    RPB_StorageVars.SetFormOnReference("Guard", player, guard, "Set-Aside Bounty")
    float distance = player.GetDistance(guard)
    ; Watched like the first one: if he freezes too, the next takeover (or the bounty back) follows the same way
    RPB_Utility.ProbeAfterBurst(guard, "took over a submission")
    if (distance < TAKEOVER_ARREST_DISTANCE)
        RPB_Utility.LogInfo(guard + " takes over the arrest of " + player + " from " + akFrozenGuard + " (frozen), " + ((distance * 0.01428) as int) + "m away: arrests them", "Arrest::TakeOverSubmission")
        RPB_Utility.NoteFrozenAction(akFrozenGuard, "The player's submission to him was taken over by " + guard + " (an arrest)")
        self.ArrestActor(guard, player, ARREST_TYPE_ESCORT_TO_JAIL)
        return
    endif

    RPB_Utility.LogInfo(guard + " takes over the arrest of " + player + " from " + akFrozenGuard + " (frozen), " + ((distance * 0.01428) as int) + "m away: walks over first", "Arrest::TakeOverSubmission")
    RPB_Utility.NoteFrozenAction(akFrozenGuard, "The player's submission to him was taken over by " + guard + " (walking over)")
    ; On this event's own stack until the Scene's end arrests them, or they leave (eluding): the surrender's machinery
    Surrender.BeginTakeoverApproach(player, guard)
endFunction

;/
    @akFrozenGuard froze after his arrest of @akActor started (the submission's bounty was already hidden by it), before the
    escort: the arrest can't go on (its flow is stuck on a call into him, and his confrontation Scene waits on him). It's
    cancelled (RPB_Recovery.CancelArrest: the guard's side on its own stack, the rest only calls on @akActor; the bounty
    comes back), and the bounty is set aside again as at the submission, so the takeover rule goes on from there. Not once
    the escort is walking (its own fallbacks handle a frozen escort). Returns whether it was this case.
    The arrest's stuck stack stays stuck until the next load, waiting on him (and is a stale replay then: KNOWN_ISSUES G5).
/;
bool function __CancelArrestByFrozenGuard(Actor akActor, Actor akFrozenGuard)
    RPB_Arrestee arrestee = Arrestees.AtKey(akActor)
    if (!arrestee || arrestee.GetCaptorActor() != akFrozenGuard || RPB_Utility.IsActorImprisoned(akActor))
        return false
    endif
    RPB_Prison prison = (RPB_API.GetPrisonManager()).FindPrisonByPrisoner(akActor)
    if (prison)
        RPB_Prisoner prisoner = prison.Prisoners.AtKey(akActor)
        if (prisoner && (prisoner.EscortAssistActive || arrestee.GetBool("Escort Arrived")))
            self.__HandOverEscort(akActor, akFrozenGuard, arrestee, prison)
            return false
        endif
    endif
    Faction crimeFaction = arrestee.GetFaction()
    RPB_Utility.LogInfo(akFrozenGuard + " froze during his arrest of " + akActor + ", before the escort: the arrest is cancelled for another guard to take it over", "Arrest::TakeOverSubmission")
    RPB_Recovery.CancelArrest(akActor, "the guard arresting them froze before the escort")
    RPB_Arrest.__SetAsideBounty(akActor, akFrozenGuard, crimeFaction)
    return RPB_StorageVars.GetFormOnReference("Guard", akActor, "Set-Aside Bounty") == akFrozenGuard
endFunction

;/
    @akFrozenGuard froze while escorting @akActor (the mod author's rule, 2026-10-04): a guard of the hold who sees them
    (line of sight, within 40m) takes the escort over, and the frozen one faints for 15s (as if the others helped him up).
    One scan when he's found frozen, no polling. Nobody sees them: he goes on escorting, frozen (his AI still walks; the
    escort's helpers read him through calls, so they're blind on him). Inside the prison, after the escort's arrival, it's
    the handover RPB already does when an escort guard dies there (RPB_Arrestee.HandOverInPrison), only when a guard there
    sees them.
/;
function __HandOverEscort(Actor akActor, Actor akFrozenGuard, RPB_Arrestee apArrestee, RPB_Prison apPrison)
    if (apArrestee.GetBool("Escort Arrived"))
        if (!RPB_Utility.GetGuardSeeing(akActor, akFrozenGuard))
            RPB_Utility.LogInfo(akFrozenGuard + " froze in " + apPrison.Name + " with " + akActor + ": no guard there sees them, he carries on", "Arrest::HandOverEscort")
            RPB_Utility.NoteFrozenAction(akFrozenGuard, "Froze in " + apPrison.Name + " with his prisoner: no guard there saw it, he carried on")
            return
        endif
        RPB_Utility.LogInfo(akFrozenGuard + " froze in " + apPrison.Name + " with " + akActor + ": a guard there takes over", "Arrest::HandOverEscort")
        RPB_Utility.NoteFrozenAction(akFrozenGuard, "His prisoner was taken over by a guard of " + apPrison.Name)
        RPB_Utility.FaintFrozenGuard(akFrozenGuard, abAlone = false)
        apArrestee.HandOverInPrison(akFrozenGuard)
        return
    endif

    Actor guard = RPB_Utility.FindTakeoverGuard(akActor, apArrestee.GetFaction(), akFrozenGuard, 0.0, TAKEOVER_APPROACH_DISTANCE, abSightOnly = true)
    if (!guard)
        RPB_Utility.LogInfo(akFrozenGuard + " froze escorting " + akActor + ": no guard of the hold sees them within 40m, he carries on", "Arrest::HandOverEscort")
        RPB_Utility.NoteFrozenAction(akFrozenGuard, "Froze mid-escort: no guard saw it within 40 m, he carried on")
        return
    endif
    RPB_Utility.LogInfo(akFrozenGuard + " froze escorting " + akActor + ": " + guard + " (" + ((akActor.GetDistance(guard) * 0.01428) as int) + "m, sees them) takes the escort over", "Arrest::HandOverEscort")
    RPB_Utility.NoteFrozenAction(akFrozenGuard, "His escort was taken over by " + RPB_Utility.ActorNameNoCall(guard) + " " + guard)
    RPB_Utility.FaintFrozenGuard(akFrozenGuard, abAlone = false)
    apArrestee.HandOverEscort(akFrozenGuard, guard)
    RPB_Utility.ProbeAfterBurst(guard, "took over an escort")
endFunction

;/
    @akActor's escort to jail stalled (~20s without moving: RPB_Arrestee.__EscortStalled). Another guard of the hold takes it
    over, by the takeover rule (noticed within 15m, or seen within 40m), as for a frozen escort guard, and the escort
    starts again with him; the old guard is released (his Captor off, his package lock freed). With none around, the
    fallback to the prison without the Scene, as before. On RPB_StalledEscortTakeover's own stack (the search calls into
    the guards around).
/;
function TakeOverStalledEscort(Actor akActor, string asReason)
    RPB_Arrestee arrestee = Arrestees.AtKey(akActor)
    if (!arrestee)
        return
    endif
    Actor oldGuard = arrestee.GetCaptorActor()
    Actor guard = RPB_Utility.FindTakeoverGuard(akActor, arrestee.GetFaction(), oldGuard, TAKEOVER_ARREST_DISTANCE, TAKEOVER_APPROACH_DISTANCE)
    arrestee.SetBool("Stall Takeover Pending", false)
    if (!guard || arrestee.GetBool("Escort Arrived"))
        RPB_Utility.LogInfo(akActor + "'s escort stalled (" + asReason + "): " + string_if(guard == none, "no guard of the hold around to take it over", "already at the prison") + ", the fallback", "Arrest::TakeOverStalledEscort")
        arrestee.__FallBackToPrison(asReason)
        return
    endif
    arrestee.SetInt("Stall Takeovers", arrestee.GetInt("Stall Takeovers") + 1)
    RPB_Utility.LogInfo(akActor + "'s escort stalled (" + asReason + "): " + guard + " (" + ((akActor.GetDistance(guard) * 0.01428) as int) + "m) takes it over from " + oldGuard + " (takeover " + arrestee.GetInt("Stall Takeovers") + "/" + arrestee.STALL_TAKEOVERS_MAX + ")", "Arrest::TakeOverStalledEscort")
    arrestee.HandOverEscort(oldGuard, guard, "the escort stalled", abReleaseOld = !RPB_Utility.IsFrozenNPC(oldGuard))
    RPB_Utility.ProbeAfterBurst(guard, "took over a stalled escort")
endFunction

; Past the point where eluding means anything: already arrested, imprisoned, or surrendering
bool function __IsBeyondEluding(Actor akActor)
    return RPB_Utility.IsActorArrested(akActor) || RPB_Utility.IsActorImprisoned(akActor) || Surrender.IsSurrendering(akActor)
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
    ; And no walking off or drawing it again: until the confrontation starts (RetainAI, ~1-2s, much longer when the arrest is
    ; held up) the player's controls were all on: a weapon drawn then broke the hands-behind-back pose, and walking off
    ; started the guards' pursuit. Given back by the confrontation's own controls, by the arrest's revert
    ; (Arrestee.RevertArrest) if it never gets there, or by the check 30s on (EventManager.OnArrestControlsCheck)
    if (akArrestee == Game.GetPlayer())
        RPB_Utility.ScheduleArrestControlsCheck()
        Game.DisablePlayerControls(abMovement = true, abFighting = true, abCamSwitch = false, abLooking = false, abSneaking = false, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 0)
    endif
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

    if (!apArrestee.HasLatentBounty() && !apArrestee.HasActiveBounty() && !RPB_Arrest.HasSetAsideBounty(apArrestee.GetActor()))
        Config.NotifyArrest("You can't be arrested in " + RPB_Utility.GetFormNameCached(akCrimeFaction) + " since you do not have a bounty in the hold", apArrestee.IsPlayer())
        RPB_Utility.LogError(apArrestee.Name + " has no bounty, cannot arrest for "+ RPB_Utility.GetFormNameCached(akCrimeFaction) +", aborting!", "Arrest::OnArrestBegin")
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
        ; The guards' arrest forcegreet off for as long as the player is in custody, whichever way the arrest began (a
        ; guard's dialogue, the attacker rule, a test): only the dev menu's arrest and a surrender set it, and the
        ; confrontation's end turned it back on, so other guards stopped the cuffed player on the escort with the crime
        ; menu ("Pay Bounty (0 gold)", 2026-10-07). Back on when the custody ends (the release, a cancel, a load with none)
        RPB_Arrest.DisableForcedArrestDialogue()
        ; Watched until the escort: a guard freezing now leaves the arrest stuck on him, and the probe that finds him has
        ; another guard take it over (TakeOverSubmission). A submission probes him already; a yield or a surrender didn't
        if (apCaptor)
            RPB_Utility.ProbeAfterBurst(apArrestee.GetCaptorActor(), "his arrest started") ; stored, no call into him
        endif
    else
        ; An NPC arrestee goes through the confrontation's burst too: probed, to learn whether NPC prisoners freeze (2026-10-05)
        RPB_Utility.ProbeAfterBurst(apArrestee.GetActor(), "arrest started", "PRISONER")
    endif

    RPB_Utility.FlowMark("Arrest.OnArrestBegin: parameters, bounty check, captor assigned")
    RPB_Utility.Crumb(apArrestee.GetActor(), "Arrest.OnArrestBegin: parameters, bounty check, captor assigned")
    self.BeginArrest(apArrestee)
endEvent

event OnArrestEnd(RPB_Arrestee apArrestee, RPB_Captor apCaptor, Faction akCrimeFaction)
    ; Back on once the arrest has been processed, unless the player is the one in custody (it stays off until the release)
    Actor player = Game.GetFormEx(0x14) as Actor
    if (!RPB_Utility.IsActorArrested(player) && !RPB_Utility.IsActorImprisoned(player) && !Surrender.IsSurrendering(player))
        RPB_Arrest.EnableForcedArrestDialogue()
    endif
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
        RPB_Utility.LogInfo("Not eluding arrest: the player is already arrested, imprisoned or surrendering (" + asEludeType + ", " + akEludedGuard + ")", "Arrest::OnArrestEludeStart")
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

    RPB_Utility.LogError("The passed in Elude Type is invalid, the event failed!", "Arrest::OnArrestEludeStart")
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
        RPB_Utility.LogWarn(akArrestResister.GetBaseObject().GetName() + " was arrested, no arrest was resisted (maybe multiple guards talked at once and triggered resist arrest?) [BUG]", "Arrest::OnArrestResist")
        return
    endif

    akGuard.SetPlayerResistingArrest() ; Needed to make the guards attack the player, otherwise they will loop arrest dialogue

    if (self.HasResistedArrestRecently(akCrimeFaction))
        RPB_Utility.LogInfo("You have already resisted arrest recently, no bounty will be added as it most likely is the same arrest.")
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
    if (Surrender.HasFakedSurrenderTo(akYieldedArrestee, akGuard.GetCrimeFaction()))
        RPB_Surrender.SurrenderLog("Yield of " + akYieldedArrestee + " to " + akGuard + " ignored: they faked a surrender to this hold")
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
function ArrestActor(Actor akArrester, Actor akArrestee, string asArrestType, bool abKeepFlow = false)
    ; @abKeepFlow: a surrender's arrest goes on profiling the surrender's flow (its Scene's events are in it)
    if (abKeepFlow)
        RPB_Utility.FlowEnsure("Arrest -> Imprison")
    else
        RPB_Utility.FlowBegin("Arrest -> Imprison")
    endif
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

    ; Back from where submitting set it aside, then hidden as the arrest's own, in one go. Giving it back raises the hold's
    ; bounty stat, and my OnBountyGained (RPB_Arrestee) hid it too, at the same time as this: both read the same bounty
    ; before either cleared it, and the hidden bounty doubled at every arrest after a submission (1200 -> 2400 -> 4800,
    ; the captor's death giving it all back, 2026-10-04). It stands aside until this one is done
    apArresteeRef.SetBool("Hiding Bounty", true)
    RPB_Arrest.GiveBackSetAsideBounty(arrestee, "the arrest hides it")
    apArresteeRef.HideBounty()
    apArresteeRef.SetBool("Hiding Bounty", false)
    RPB_Utility.FlowMark("BeginArrest: HideBounty")
    ; Diagnostic (2026-09-23): HideBounty() -> ClearActiveBountyForFaction() should zero the native CrimeGold for the player
    ; (RPB_ActorBase.psc:702-759). Logged to confirm that's actually happening and whether combat was already under way
    ; before this function ever ran - a real in-game test kept showing guards re-engaging over several seconds despite
    ; every pacification step below running, with no Master of Disguise ability effect present on them by that point.
    ; Only when logging is on: the message calls three natives, and it's built before SendInfo could skip it
    if (RPB_Utility.IsLoggingEnabled())
        RPB_Utility.LogInfo("BeginArrest bounty/combat check on " + arrestee.GetDisplayName() + " " + arrestee + ": crime gold now " + arrestFaction.GetCrimeGold() + ", arrestee in combat " + arrestee.IsInCombat(), "Arrest::BeginArrest")
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
    RPB_Utility.LogInfo("Set resisted flag for " + RPB_Utility.GetFormNameCached(akFaction), "Arrest::SetResistedFlag")
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
    RPB_Utility.LogInfo("The resist arrest flags have been reset.")
endFunction

function ResetEludedFlag()
    string referenceKey = "Actor FormID(" + Config.Player.GetFormID() + ")"
    Debug("Arrest::ResetEludedFlag", "This is called")
    RPB_StorageVars.DeleteCategoryOnReference(referenceKey, "Pre-Arrest")
    RPB_Utility.LogInfo("The eluding arrest flags have been reset.")
    RPB_Utility.LogInfo("Elude Arrest: " + GetContainerList(RPB_StorageVars.GetObjectHandleOnReference(Config.Player, "Pre-Arrest")))

endFunction

function ApplyArrestEludedPenalty(Faction akArrestFaction)
    if (self.HasEludedArrestRecently(akArrestFaction))
        RPB_Utility.LogInfo("You have already eluded arrest recently, no bounty will be added as it most likely is the same arrest.")
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

; The surrender key (rebindable on the MCM's Keybindings page)
function RegisterHotkeys()
    RPB_Keybindings.RegisterSurrenderKey()
endFunction

function EnableForcedArrestDialogue() global
    GlobalVariable RPB_NoArrestDialogue = RPB_Utility.RPB_ArrestGlobal("No Dialogue")
    RPB_NoArrestDialogue.SetValueInt(0)
    RPB_Arrest.__HoldArrestOnSight(false)
    RPB_Arrest.__WorldInteractionsInCustody(false)
endFunction

function DisableForcedArrestDialogue() global
    GlobalVariable RPB_NoArrestDialogue = RPB_Utility.RPB_ArrestGlobal("No Dialogue")
    RPB_NoArrestDialogue.SetValueInt(1)
    RPB_Arrest.__HoldArrestOnSight(true)
    RPB_Arrest.__WorldInteractionsInCustody(true)
endFunction

;/
    No world interaction while the player is in RPB's custody (the mod author, 2026-10-12: the dead-body accusation started
    again right after its "go to jail", its guard came back with it, and another guard had to take the arrest over). Vanilla's
    own switch, WIEventsEnabled (Skyrim.esm 0x00035D66), checked by the Story Manager's world-interaction branches: off at the
    custody's start, back on at its end only if RPB turned it off and it's still off (vanilla quests switch it off for their
    own scenes; theirs is left alone). Also run on every load (RPB_EventManager.RegisterEvents)
/;
function __WorldInteractionsInCustody(bool abInCustody) global
    GlobalVariable eventsEnabled = Game.GetFormFromFile(0x00035D66, "Skyrim.esm") as GlobalVariable
    if (!eventsEnabled)
        return
    endif
    bool offByUs = JDB.solveInt(".rpb_root.worldInteraction.offInCustody") == 1
    if (abInCustody)
        if (!offByUs && eventsEnabled.GetValueInt() == 1)
            eventsEnabled.SetValueInt(0)
            JDB.solveIntSetter(".rpb_root.worldInteraction.offInCustody", 1, true)
        endif
    elseif (offByUs)
        JDB.solveIntSetter(".rpb_root.worldInteraction.offInCustody", 0, true)
        if (eventsEnabled.GetValueInt() == 0)
            eventsEnabled.SetValueInt(1)
        endif
    endif
endFunction

;/
    The engine's own arrest approach: a guard walks up to a wanted player once their bounty reaches iArrestOnSightNonViolent
    (iArrestOnSightViolent for violent crimes). With the "No Dialogue" global on, that guard still came over, with a plain
    greeting (2026-10-07). While the player is in custody both are raised out of reach, so nobody starts the approach, and
    the values they had are put back after. Game settings last the whole game session and aren't saved: the load check
    (EventManager.RegisterEvents) sets this again.
/;
; The values from before the hold, or the game's defaults (counts above 1000 / above 1) when none were saved or the saved one
; is the raised value itself (saved by an earlier version)
function __RestoreArrestOnSight() global
    int nonViolent = JDB.solveInt(".rpb_root.arrestOnSight.nonViolent", 1000)
    int violent = JDB.solveInt(".rpb_root.arrestOnSight.violent", 1)
    if (nonViolent == 1000000000)
        nonViolent = 1000
    endif
    if (violent == 1000000000)
        violent = 1
    endif
    Game.SetGameSettingInt("iArrestOnSightNonViolent", nonViolent)
    Game.SetGameSettingInt("iArrestOnSightViolent", violent)
endFunction

function __HoldArrestOnSight(bool abHold) global
    bool held = JDB.solveInt(".rpb_root.arrestOnSight.held") != 0
    if (abHold == held)
        if (abHold)
            Game.SetGameSettingInt("iArrestOnSightNonViolent", 1000000000) ; again: a load in the same session keeps the
            Game.SetGameSettingInt("iArrestOnSightViolent", 1000000000)    ; flag but a restart resets the settings
        elseif (Game.GetGameSettingInt("iArrestOnSightNonViolent") == 1000000000 || Game.GetGameSettingInt("iArrestOnSightViolent") == 1000000000)
            ; Not held by this save, but still raised: held by the save played before this one in the same game session
            ; (the settings outlive a load, the flag doesn't). The guards never approached again (2026-10-07)
            RPB_Arrest.__RestoreArrestOnSight()
            RPB_Utility.Debug("Arrest::__HoldArrestOnSight", "the guards' arrest on sight was still held from another save: back to " + Game.GetGameSettingInt("iArrestOnSightNonViolent") + "/" + Game.GetGameSettingInt("iArrestOnSightViolent"))
        endif
        return
    endif
    if (abHold)
        ; Only real values saved: still raised by another save of this game session, the raised value was saved as the
        ; original and the release "restored" it (no guard ever approached again, 2026-10-07)
        int nonViolent = Game.GetGameSettingInt("iArrestOnSightNonViolent")
        int violent = Game.GetGameSettingInt("iArrestOnSightViolent")
        if (nonViolent != 1000000000)
            JDB.solveIntSetter(".rpb_root.arrestOnSight.nonViolent", nonViolent, true)
        endif
        if (violent != 1000000000)
            JDB.solveIntSetter(".rpb_root.arrestOnSight.violent", violent, true)
        endif
        Game.SetGameSettingInt("iArrestOnSightNonViolent", 1000000000)
        Game.SetGameSettingInt("iArrestOnSightViolent", 1000000000)
    else
        RPB_Arrest.__RestoreArrestOnSight()
    endif
    JDB.solveIntSetter(".rpb_root.arrestOnSight.held", abHold as int, true)
    RPB_Utility.Debug("Arrest::__HoldArrestOnSight", "the guards' arrest on sight " + RPB_Utility.string_if(abHold, "held (player in custody)", "back") + ": non-violent " + Game.GetGameSettingInt("iArrestOnSightNonViolent") + ", violent " + Game.GetGameSettingInt("iArrestOnSightViolent"))
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
