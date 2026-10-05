Scriptname RPB_Arrestee extends RPB_ActorBase

;/
@constants:
    float ESCORT_LEASH_DISTANCE
    float PENDING_LEASH_DISTANCE
@references:
    RPB_Arrest Arrest
    RPB_SceneManager SceneManager
    RPB_Captor Captor
@properties:
    Faction ArrestFaction
    string Hold
    string ArrestType
    float CurrentTime
    int BountyNonViolent
    int BountyViolent
    int Bounty
    float TimeOfArrest
    int MinuteOfArrest
    int HourOfArrest
    int DayOfArrest
    int MonthOfArrest
    int YearOfArrest
    float TimeArrested
    bool Defeated
    int DefeatedBounty
    bool IsArrested
    bool IsImprisoned
@functions:
    Actor function GetCaptorActor()
    RPB_Arrestee function GetStateForPrisoner(RPB_Prisoner apPrisoner) global
    RPB_Prison function GetPotentialPrison()
    string function GetTimeOfArrestFormatted()
    string function GetTimeElapsedSinceArrest()
    function Frisk()
    function AssignCaptor(RPB_Captor apCaptor)
    function SetArrestParameters(string asArrestType, RPB_Captor apCaptor, Faction akCrimeFaction)
    function Free()
    function Release()
    function Restrain()
    function Cuff()
    function Uncuff()
    RPB_Prisoner function MakePrisoner()
    function TransferArrestPropertiesToPrisoner(RPB_Prison apPrison)
    bool function ShouldPayBounty()
    function PayCrimeGold()
    function PayBounty()
    function SetArrestTime()
    function SetArrestGoal(string asArrestGoal)
    function RevertArrest()
    function Arrest()
    function DeclareArrestSuccess()
    bool function AwaitConfrontationScene(string asScene)
    function EscortToPrison(bool abEscortDirectlyToCell = false, bool abCombatAtArrest = false, Actor akOtherHostile = none)
    function ResumePendingArrest()
    function MoveToPrison(bool abMoveDirectlyToCell = false)
    function ChangeEscort(Actor akNewEscort)
    function SetTimeOfArrest()
    function MoveToCaptor()
    bool function HasActiveBounty()
    bool function HasLatentBounty()
    function SetCrimeGold(int aiGold)
    function SetCrimeGoldViolent(int aiGold)
    function ModCrimeGold(int aiAmount, bool abViolent = false)
    int function GetActiveBounty(bool abNonViolent = true, bool abViolent = true)
    int function GetLatentBounty(bool abNonViolent = true, bool abViolent = true)
    function HideBounty()
    function RestoreBounty()
    function ClearLatentBounty(bool abNonViolent = true, bool abViolent = true)
    int function QueryStat(string asStatName)
    function SetStat(string asStatName, int aiValue)
    function PauseEscortForFight(Actor akHostile)
    function HandOverInPrison(Actor akDeadGuard)
    function HandOverEscort(Actor akFrozenGuard, Actor akNewGuard, string asReason = "the escort guard froze", bool abReleaseOld = false)
    function EndEscortWatch()
    function Destroy()
    string function GetScriptVarCategory(string asVarCategory = "Actor")
    bool function InitializeState()
    function RevertState()
    Actor function GetArrestedActor()
    Actor function GetActor()
    RPB_Captor function GetCaptor()
    Faction function GetFaction()
    string function GetHold()
    string function GetArrestType()
@events:
    event OnActorAction(int actionType, Actor akActor, Form source, int slot)
    event OnInitialize()
    event OnDestroy()
    event OnBountyGained()
    event OnStatChanged(string asStatName, float afValue)
    event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    event OnDeath(Actor akKiller)
    event OnRestrained()
    event OnArrestBegin()
    event OnArrestEnd()
    event OnArrestFailed(string asReason)
    event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    event OnUpdate()
/;

import RPB_Utility
import RPB_Config
import RPB_Memory

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

;/
    The Actor that has arrested this Arrestee.
    This may be null depending on whether the arrest was done through a captor or faction (if the latter, this is null).

    The reason this is not a property with the value of GetCasterActor() is the same as the one for the Arrestee.
    Once the MagicEffect is removed, this reference will be null and cannot be used in any function or event, this
    is using the same workaround.

    Additionally, the Caster may not be the Captor in the future, for instance if the Arrest is done through a Faction, there will
    be no Caster, or it will be the same as the Target, which would result in logic failure, this bypasses that problem too.

    The value is set through SetArrestParameters().
/;
RPB_Captor __captor
RPB_Captor property Captor
    RPB_Captor function get()
        ; The guard's Captor effect is started again each time his 3D reloads (every load door of the escort), and the
        ; instance set at the arrest is then dead ("[rpb_captor <None>]"): his death went unnoticed (a dead instance never
        ; matched the live one), and anything reading my captor read nothing. The live one is looked up by the guard.
        if (__captor && __captor.IsEffectActive)
            return __captor
        endif
        Actor guard = self.GetCaptorActor()
        if (guard)
            RPB_Captor live = Arrest.GetCaptor(guard)
            if (live)
                __captor = live
                return live
            endif
        endif
        return __captor
    endFunction
endProperty

; My guard, by actor (the Captor instance changes with his 3D reloads, he doesn't)
Actor function GetCaptorActor()
    return self.GetReference("Arresting Guard") as Actor
endFunction

;/
    The Arresting Faction to this Arrestee (The faction that arrested this Actor).
    The value is set through SetArrestParameters().
/;
Faction __arrestFaction
Faction property ArrestFaction
    Faction function get()
        return __arrestFaction
    endFunction
endProperty

;/
    The Hold of where the arrest took place (usually this is the Faction name, but it might not be!)
    The value is set through SetArrestParameters().
/;
string __hold
string property Hold
    string function get()
        return __hold
    endFunction
endProperty

;/
    The arrest type for this Arrestee, representing whether this Actor should be: 
    - Escorted to Jail
    - Escorted to Cell
    - Teleported to Jail
    - Teleported to Cell

    Used depending on the arrest situation, if the Actor is defeated and passes out for example, there's no sense in escorting them at all,
    instead, a teleport to jail or cell arrest will be used.

    There may be more arrest types in the future, but this is it for now.
    The value is set through SetArrestParameters().
/;
string __arrestType
string property ArrestType
    string function get()
        return __arrestType
    endFunction
endProperty


float property CurrentTime
    float function get()
        return Utility.GetCurrentGameTime()
    endFunction
endProperty

int property BountyNonViolent
    int function get()
        return self.GetLatentBounty(abViolent = false)
    endFunction
endProperty

int property BountyViolent
    int function get()
        return self.GetLatentBounty(abNonViolent = false)
    endFunction
endProperty

int property Bounty
    int function get()
        return self.GetLatentBounty()
    endFunction
endProperty

float property TimeOfArrest
    float function get()
        return GetFloat("Time of Arrest")
    endFunction
endProperty

int property MinuteOfArrest
    int function get()
        return GetInt("Minute of Arrest")
    endFunction
endProperty

int property HourOfArrest
    int function get()
        return GetInt("Hour of Arrest")
    endFunction
endProperty

int property DayOfArrest
    int function get()
        return GetInt("Day of Arrest")
    endFunction
endProperty

int property MonthOfArrest
    int function get()
        return GetInt("Month of Arrest")
    endFunction
endProperty

int property YearOfArrest
    int function get()
        return GetInt("Year of Arrest")
    endFunction
endProperty

float property TimeArrested
    float function get()
        return CurrentTime - TimeOfArrest
    endFunction
endProperty

bool property Defeated
    bool function get()
        return GetBool("Defeated")
    endFunction
endProperty

int property DefeatedBounty
    int function get()
        return GetInt("Bounty for Defeat")
    endFunction
endProperty

bool property IsArrested
    bool function get()
        return GetBool("Arrested")
    endFunction
endProperty

bool property IsImprisoned
    bool function get()
        return GetBool("Imprisoned", "Jail")
    endFunction
endProperty

;/
    Retrieves an instance of RPB_Arrestee for the given RPB_Prisoner,
    only valid until destroyed.

    RPB_Prisoner @apPrisoner: The prisoner reference

    returns (RPB_Arrestee): A reference to the arrest state of the prisoner.
/;
RPB_Arrestee function GetStateForPrisoner(RPB_Prisoner apPrisoner) global
    return (RPB_API.GetArrest()).AwaitArresteeReference(apPrisoner.GetActor())
endFunction

;/
    Retrieves the potential prison of where this Arrestee will go,
    it's not guaranteed, hence "potential".

    For now, it retrieves the Hold's Prison, but when 1:N (Hold to Prison) gets added
    this must be refactored to decide which one to choose (based on distance from the capture point to the Prison, maybe?).
/;
RPB_Prison function GetPotentialPrison()
    return API.PrisonManager.GetPrison(Hold)
endFunction

string function GetTimeOfArrestFormatted()
    int day      = self.DayOfArrest
    int month    = self.MonthOfArrest
    int year     = self.YearOfArrest
    int hour     = self.HourOfArrest
    int minute   = self.MinuteOfArrest

    return RPB_Utility.GetFormattedDate(day, month, year, hour, minute)
endFunction

string function GetTimeElapsedSinceArrest()
    return RPB_Utility.GetTimeFormatted(self.CurrentTime - self.TimeOfArrest)
endFunction


function Frisk()
    
endFunction

function AssignCaptor(RPB_Captor apCaptor)
    SetReference("Arresting Guard", apCaptor.GetActor())
endFunction

function SetArrestParameters(string asArrestType, RPB_Captor apCaptor, Faction akCrimeFaction)
    ; Debug("Arrestee::SetArrestParameters", "apCaptor: " + apCaptor + ", akCrimeFaction: " + akCrimeFaction)
    if (apCaptor)
        akCrimeFaction = apCaptor.GetActor().GetCrimeFaction()
        self.AssignCaptor(apCaptor)
        ; Debug(none, "Arrestee::SetArrestParameters", "Arrest is being done through a captor ("+ apCaptor +")")

        ; Temporary
        ; BindAliasTo(Arrest.CaptorRef, apCaptor)
        ; Arrest.CaptorRef.AssignArrestee(this)
    endif

    if (!akCrimeFaction)
        Error("Both the captor and faction are none, cannot proceed with the arrest! (returning...)")
        DebugError("Arrestee::SetArrestParameters", "Both the captor and faction are none, cannot proceed with the arrest! (returning...)")
        self.Destroy()
        return
    endif

    ; Set arrest related vars to this Arrestee's state
    __captor        = apCaptor
    __arrestFaction = akCrimeFaction
    __hold          = RPB_Utility.GetFormNameCached(akCrimeFaction)
    __arrestType    = asArrestType

    SetForm("Arrest Faction", ArrestFaction)
    SetForm("Arrestee", this)
    SetString("Arrest Type", ArrestType)
    SetString("Hold", Hold)
endFunction

function Free()
    Arrest.OnArresteeFreed(self, Captor)
endFunction

;/
    Releases this arrestee from custody
/;
function Release()
    self.Dispel()
endFunction

; Same as Cuff(), used for convenience
function Restrain()
    self.Cuff()
endFunction

; this.SheatheWeapon()
; UnequipHandsForActor(this)

; self.EquipItem(RPB_Utility.RPB_PrisonerHandCuffs(), true)
; self.PlayAnimation("OffsetBoundStandingPlayerInstant")
; Utility.Wait(5.0)
; self.PlayAnimation("OffsetBoundStandingPlayerInstant")
; return
; Form cuffs = Game.GetFormEx(0xA081D33) ; Front

; Form cuffs = Game.GetFormEx(0xA081D2F) ; Back

function Cuff()
    RPB_Utility.EquipCuffs(this) ; behind the back; weapons sheathed, not taken (they stay on me until the strip)
endFunction

; Dependency-free attempt (no ZaZAnimationPack) - currently broken, animation doesn't play
; correctly since there's no cuff model/animation of our own yet. Revisit once those assets
; exist, maybe by studying how ZazAnimationPack itself implements cuffing.
; function Cuff()
;     self.EquipItem(RPB_Utility.RPB_PrisonerHandCuffs(), true)
;     Utility.Wait(2.0)
;     self.PlayAnimation("OffsetBoundStandingPlayerInstant")
;
;     this.SheatheWeapon()
;     UnequipHandsForActor(this)
; endFunction

function Uncuff()
    ; By form, worn or carried, and deleted (the worn-slot lookup left unworn cuffs behind)
    int removed = RPB_Utility.RemoveCuffs(this)
    Debug("Arrestee::Uncuff", "Uncuffed " + this + " (" + removed + " removed)")
endFunction

;/
    Transfers this Actor from being an Arrestee to a Prisoner
/;
RPB_Prisoner function MakePrisoner()
    RPB_Prison prison  = self.GetPotentialPrison()
    self.TransferArrestPropertiesToPrisoner(prison)
    RPB_Utility.FlowMark("MakePrisoner: GetPotentialPrison + TransferArrestPropertiesToPrisoner")
    RPB_Utility.Crumb(this, "MakePrisoner: GetPotentialPrison + TransferArrestPropertiesToPrisoner")

    return prison.AwaitPrisonerReference(this)
endFunction

function TransferArrestPropertiesToPrisoner(RPB_Prison apPrison)
    self.SetFloat("Time of Arrest", TimeOfArrest, "Jail")
    self.SetInt("Minute of Arrest", MinuteOfArrest, "Jail")
    self.SetInt("Hour of Arrest", HourOfArrest, "Jail")
    self.SetInt("Day of Arrest", DayOfArrest, "Jail")
    self.SetInt("Month of Arrest", MonthOfArrest, "Jail")
    self.SetInt("Year of Arrest", YearOfArrest, "Jail")
    self.SetForm("Arrest Captor", Captor.GetActor(), "Jail")
endFunction

; ==========================================================
;                           Bounty
; ==========================================================

bool function ShouldPayBounty()
    return Arrest.GetArrestGoal(this) == Arrest.ARREST_GOAL_BOUNTY_PAYMENT
endFunction

function PayCrimeGold()
    int latentBounty    = self.GetLatentBounty()
    Form gold           = RPB_Utility.GetFormOfType("Gold")

    self.RemoveItem(gold, latentBounty, true)
    self.ClearLatentBounty()

    if (self.IsPlayer())
        ArrestFaction.PlayerPayCrimeGold(false, false)
        Config.NotifyArrest("Your bounty in " + Hold + " has been paid")
    endif
endFunction

; Same as PayCrimeGold(), used for convenience
function PayBounty()
    self.PayCrimeGold()
endFunction

; ==========================================================

function SetArrestTime()
    SetBool("Arrested", true)
    SetBool("Captured", true) ; Used to avoid further arrest resists after being arrested
    SetFloat("Time of Arrest", CurrentTime)

    Config.NotifyArrest("You have been arrested in " + Hold, this == Config.Player)
    Config.NotifyArrest(self.GetName() + " has been arrested in " + Hold, this != Config.Player)
    Info(self.Name + " has been arrested in " + Hold + " at " + CurrentTime)
endFunction

function SetArrestGoal(string asArrestGoal)
    Arrest.SetArrestGoal(this, asArrestGoal)
endFunction

function RevertArrest()
    self.__ReleasePendingHold(abReverted = true) ; a pending arrest reverted (a death on either side, or a reset) must not leave me frozen

    ; Unbind from Cuffs
    self.Uncuff()

    self.UnregisterForTrackedStats()
    self.RestoreBounty()

    ; Ideally these vars should be deleted and not set to none/null, but ArrestVars needs a refactor to do so on a per-actor basis if we want to delete all vars belonging to an actor
    self.Remove("Arrest Faction")
    self.Remove("Arrestee") ; Might be temp, we already have the Arrestee reference through this instance of RPB_Arrestee
    self.Remove("Arrest Type")
    self.Remove("Arrest Scene")
    self.Remove("Hold")
    self.Remove("Arrested")
    self.Remove("Arresting Guard")
    self.Remove("Captured")
    self.Remove("Scenario")
    self.Remove("Time of Arrest")

    self.Destroy() ; no fixed wait: Destroy() stops the escort loop before deleting the state
endFunction

; ==========================================================
;                           Scenes
; ==========================================================

function Arrest()
    self.SetArrestGoal(Arrest.ARREST_GOAL_IMPRISONMENT)
    self.SetTimeOfArrest()

    SetBool("Arrested", true)
    SetBool("Captured", true) ; Used to avoid further arrest resists after being arrested, may change name or implementation
    self.IncrementStat("Times Arrested")
endFunction

;/
    The actual "you/this Actor have been arrested" declaration - split out of Arrest() so it only fires once I know the
    arrest is real, not just attempted. Arrest() itself still runs immediately and unconditionally (other systems, like
    arrest-resist suppression, need "Captured"/"Arrested" set right away), but this only gets called once a confrontation
    Scene is actually confirmed (EscortToPrison, via AwaitConfrontationScene) or, for the arrest types that never touch a
    Scene at all, right where Arrest() used to declare success immediately (BeginArrest's teleport branches).
/;
function DeclareArrestSuccess()
    Config.NotifyArrest("You have been arrested in " + Hold, self.IsPlayer())
    Info(self.Name + " has been arrested in " + Hold + " at " + CurrentTime)
    ; Debug("Arrestee::DeclareArrestSuccess", self.Name + " has been arrested in " + Hold + " at " + CurrentTime)

    Arrest.OnActorArrested(self, Captor)
endFunction

;/
    Starts the confrontation Scene and waits for real confirmation it's actually progressing, instead of the old
    fire-and-forget StartArrestScene() call that never checked anything. Confirmation is the Scene's own first phase cue
    ("Hands Behind Back", which OnArrestBegin() below marks by setting "Scene Confirmed") - the earliest point anywhere
    in this codebase that a confrontation Scene can be observed to be doing something real. Found the hard way in a real
    test with a live disguise mod installed: the confrontation Scene silently never started once, and nothing noticed -
    "Prisoner has been arrested" still got logged, leaving the Actor half arrested (RPB_Arrestee + RPB_Prisoner both
    attached, no scene, no cuffs) with no way to recover short of a whole new arrest attempt.

    While waiting, this also watches for the guard getting physically wedged inside the Arrestee - a known vanilla
    Skyrim AI-package pathing problem (not specific to this mod) where the guard's own approach can get stuck with
    nothing able to path it back out, silently stalling the confrontation the same way a Scene that never started does.
    A wedge just gets nudged apart in place (same attempt, same Scene, no retry spent); only a whole attempt producing
    no phase cue at all costs a retry.

    string  @asScene: The confrontation Scene to start.

    returns (bool): true once the Scene is confirmed to be progressing, false if every attempt was exhausted.
/;
; Someone other than my guard is fighting me or my guard, or I'm the player and in combat with no readable targets (my
; StopCombat at the arrest doesn't stop whoever attacks me). The hostile, if known, is kept for the pending arrest.
bool function __FightBrokeOut(Actor akGuard)
    ; A fellow guard still attacking me is the arrest, not a fight (GetOtherHostileTarget): called off here
    RPB_Utility.CalmOwnLawAttackers(this, akGuard)
    Actor hostile = RPB_Utility.GetOtherHostileTarget(akGuard, this, akGuard)
    if (!hostile)
        hostile = RPB_Utility.GetOtherHostileTarget(this, akGuard, akGuard)
    endif

    bool fight = hostile != none
    if (!fight && self.IsPlayer() && this.IsInCombat())
        Actor[] targets = PO3_SKSEFunctions.GetCombatTargets(this)
        fight = !targets || targets.Length == 0
    endif

    if (fight)
        ; Known (a real combat target) acts on the first read; none (the player in combat, no readable targets) waits for a
        ; second one, so one stray frame doesn't end an arrest
        self.SetForm("Interrupting Hostile", hostile)
    endif
    return fight
endFunction

bool function AwaitConfrontationScene(string asScene)
    if (RPB_Utility.IsConfrontationSceneForcedToFail())
        ; Test-only override (RPB_Utility.SetConfrontationSceneForcedToFail) for exercising EscortToPrison()'s
        ; TeleportToCell fallback deterministically (test 103). Real confrontation Scenes turned out to be
        ; untestable through actor-state sabotage - two rounds tried disabling one participant's AI or the other's,
        ; and both still let the Scene's first phase confirm within seconds regardless of which actor was frozen
        ; (see KNOWN_ISSUES.md, rounds 22-24) - so this returns false without ever calling
        ; SceneManager.StartArrestScene() at all, which also structurally guarantees this path can never leave
        ; anything queued/dangling in SceneManager's shared queue, unlike the two earlier attempts. Deliberately not
        ; calling SceneManager.ForceResetSceneState() here (unlike the real exhausted-retries give-up path below) -
        ; nothing of ours was ever started or queued in this branch, and resetting anyway would risk wiping a
        ; different, genuinely in-progress arrest's scene state if one happened to be running concurrently.
        DebugWarn("["+ Name +"] Arrestee::AwaitConfrontationScene", "Forced failure for " + asScene + " on " + Name + " (RPB_Utility debug flag, not a real timeout)")
        return false
    endif

    int MAX_ATTEMPTS = 3
    float PER_ATTEMPT_TIMEOUT_SECONDS = 8.0   ; tunable - no real playtest numbers behind this yet
    float POLL_INTERVAL_SECONDS = 1.0
    float STUCK_DISTANCE_UNITS = 90.0         ; tunable - a real measured wedge came in at ~52 units; stay comfortably smaller than the nudge offset below
    int STUCK_CONSECUTIVE_CHECKS = 2          ; debounce so one transient close frame doesn't trigger a nudge
    float NUDGE_OFFSET_UNITS = 120.0          ; tunable - just needs to clear collision, not a real measured distance

    Actor guard = Captor.GetActor()
    int attempt = 1

    while (attempt <= MAX_ATTEMPTS)
        self.Remove("Scene Confirmed") ; clean slate for this attempt
        SceneManager.StartArrestScene( \
            akGuard     = guard, \
            akArrestee  = this, \
            asScene     = asScene \
        )

        float attemptStart = Utility.GetCurrentRealTime()
        int stuckStreak = 0
        int fightStreak = 0
        bool confirmed = false

        while (!confirmed && (Utility.GetCurrentRealTime() - attemptStart) < PER_ATTEMPT_TIMEOUT_SECONDS)
            if (!self.IsEffectActive) ; the Arrestee itself is gone mid-wait (e.g. died) - OnDeath already handles that
                return false
            endif

            Utility.Wait(POLL_INTERVAL_SECONDS)
            confirmed = self.GetBool("Scene Confirmed")

            if (!confirmed)
                ; A fight around us (two reads in a row, not one stray frame): the Scene can't play in it
                if (self.__FightBrokeOut(guard))
                    fightStreak += 1
                else
                    fightStreak = 0
                endif

                if (fightStreak >= 2 || (fightStreak >= 1 && self.GetForm("Interrupting Hostile")))
                    Info("Confrontation of " + Name + " " + this + " interrupted by a fight (" + self.GetForm("Interrupting Hostile") + ") before the cuffs, the arrest is cancelled")
                    SceneManager.EndSceneWithActor(this, "a fight broke out during the confrontation")
                    self.SetBool("Confrontation Interrupted", true)
                    return false
                endif

                if (RPB_Utility.IsWedgedTogether(self.GetActor(), guard, STUCK_DISTANCE_UNITS))
                    stuckStreak += 1
                else
                    stuckStreak = 0
                endif

                if (stuckStreak >= STUCK_CONSECUTIVE_CHECKS)
                    DebugWarn("["+ Name +"] Arrestee::AwaitConfrontationScene", "Guard wedged against " + Name + " during the approach, nudging aside")
                    ; PushActorAwayFrom, not MoveTo(afXOffset=...): that offset is relative to the TARGET's own local/
                    ; facing space, not a function of the mover's actual prior position - already proven buggy by a real
                    ; test elsewhere in this file (OnArrestEnd's own wedge check, fixed the same way) that visibly moved a
                    ; guard to the arrestee's side instead of straight back. This call site was missed when that landed.
                    RPB_Utility.PushActorAwayFrom(guard, self.GetActor(), NUDGE_OFFSET_UNITS)
                    stuckStreak = 0 ; give the package a fresh window to resolve after the nudge
                endif
            endif
        endWhile

        if (confirmed)
            return true
        endif

        DebugWarn("["+ Name +"] Arrestee::AwaitConfrontationScene", "Attempt " + attempt + "/" + MAX_ATTEMPTS + " of " + asScene + " for " + Name + " never confirmed, retrying")

        ; asScene is one singleton Scene form shared by every arrestee using it, not a per-arrestee instance - only
        ; one can actually be playing at a time (SceneManager's own queue). Checking IsPlaying() alone isn't enough:
        ; if I was only ever queued behind a DIFFERENT arrestee's attempt (never actually started), GetScene(asScene)
        ; still resolves to that same shared Scene, still playing, and I'd stop THEIR legitimate confrontation on my
        ; own timeout instead of my own (a real, reproduced bug - confirmed no code anywhere checked whose Scene it
        ; actually was). Verifying the currently-bound Escortee is really me closes that.
        Scene sceneObject = SceneManager.GetScene(asScene)
        if (sceneObject && sceneObject.IsPlaying() && SceneManager.GetSceneNthReferenceOfType(asScene, "Escortee") == self.GetActor())
            sceneObject.Stop()
            Utility.Wait(0.5) ; let OnSceneEnd land and clear the SceneManager's own "is playing" flag before retrying
        endif

        attempt += 1
    endWhile

    DebugError("["+ Name +"] Arrestee::AwaitConfrontationScene", "Gave up on " + asScene + " for " + Name + " after " + MAX_ATTEMPTS + " attempts")
    SceneManager.ForceResetSceneState() ; last resort: a stalled Start() may have left the Scene queue wedged for everyone
    return false
endFunction

function EscortToPrison(bool abEscortDirectlyToCell = false, bool abCombatAtArrest = false, Actor akOtherHostile = none)
    string sceneSet = string_if (self.GetString("Scene"), self.GetString("Scene"), Arrest.SceneManager.SCENE_ARREST_START_02)

    ; Persisted so anything resolving "which Scene is this arrest actually running" later (Captor.OnDeath, so it can
    ; stop this Scene if the guard dies before it confirms) has a reliable value to read back - "Scene" itself was
    ; only ever read here before, never written, so it always fell through to the fallback above.
    self.SetString("Scene", sceneSet)

    ; My guard is still fighting someone else (another hostile nearby keeps every guard in combat): the confrontation
    ; Scene can't play in a fight. I'm cuffed right away and wait, the escort starts once the fight is over.
    ; The main signal is who the guard was fighting at the arrest (@akOtherHostile, from BeginArrest); the settle check only
    ; covers a guard that ends up back in combat without one having been read
    if (akOtherHostile)
        Debug("["+ Name +"] Arrestee::EscortToPrison", "other hostile " + akOtherHostile + " keeps " + Captor.GetActor() + " busy -> pending arrest")
        self.__BeginPendingArrest(abEscortDirectlyToCell, akOtherHostile)
        return
    elseif (self.__CaptorStillFighting(abCombatAtArrest))
        self.__BeginPendingArrest(abEscortDirectlyToCell, none)
        return
    endif

    if (!self.AwaitConfrontationScene(sceneSet))
        ; A fight broke out before the confrontation got anywhere: nothing has been done to me yet, so I'm let go (the
        ; bounty and my hostility come back, guards will come for me again), rather than retrying a Scene that can't play
        ; and teleporting me to a cell
        if (self.GetBool("Confrontation Interrupted"))
            RPB_Recovery.CancelArrest(this, "a fight broke out before the cuffs")
            return
        endif

        ; AwaitConfrontationScene() returns false for two different reasons, and they need different handling here.
        ; (1) all retries exhausted, arrestee still alive - the case this fallback is for. (2) !self.IsEffectActive
        ; fired inside its own wait loop - but round 19's own original assumption here (this only ever means someone
        ; else already reverted the arrest, e.g. RPB_Captor.OnDeath's fast revert) turned out to be incomplete: round
        ; 32 confirmed via test 104 that IsEffectActive can also go false simply because the arrestee's own Actor went
        ; 3D-unloaded (e.g. the player left far enough away), with NOTHING else reverting anything - silently
        ; returning here in that case abandoned the arrest forever (round 32's own retest: neither imprisoned nor
        ; reverted, stuck for the rest of the test). Arrest.Arrestees.AtKey(this) tells the two apart directly -
        ; Destroy() (called from RevertArrest()) always empties this entry when something genuinely reverted the
        ; arrest; it's still present if nothing did.
        if (!self.IsEffectActive && Arrest.Arrestees.AtKey(this) == none)
            ; Genuinely already reverted by something else while this wait was in flight (e.g. the captor died and
            ; RPB_Captor.OnDeath's own fast-revert already called RevertArrest() -> Destroy() -> UnregisterArrestee()
            ; on a separate call stack) - nothing left to salvage. Confirmed by a real test: proceeding here in this
            ; case tried to DeclareArrestSuccess()/MoveToPrison() an Actor already disabled by the revert that already
            ; ran, producing "not loaded, disabled: TRUE" then "Could not turn bandit into a prisoner" - a doomed,
            ; redundant salvage attempt on an arrest that's already been reverted.
            return
        endif

        ; The confrontation Scene never confirmed (or confirmed too late to matter - the arrestee's own Actor already
        ; went 3D-unloaded with nothing else reverting it) - rather than reverting an arrest that already legitimately
        ; started (pacification already applied, intent already committed), fall back to the same Scene-free path
        ; ARREST_TYPE_TELEPORT_TO_CELL already uses (DeclareArrestSuccess + MoveToPrison(abMoveDirectlyToCell = true),
        ; see BeginArrest's own teleport branch) instead of undoing the arrest outright. Applies uniformly whether this
        ; was an Escort-to-Jail or Escort-to-Cell request - once witnessing anything is off the table, the simplest
        ; safe outcome is to finish the job, not preserve the jail-first distinction. Safe to attempt regardless of
        ; the actor's current load state: MakePrisoner() below already handles a still-unloaded actor safely (round
        ; 20's null-check). No separate Scene cleanup needed here: AwaitConfrontationScene's own give-up path already
        ; calls ForceResetSceneState() before returning false.
        DebugWarn("["+ Name +"] Arrestee::EscortToPrison", "Confrontation Scene never confirmed for " + Name + " - falling back to a direct teleport-to-cell arrest instead of reverting")
        self.DeclareArrestSuccess()
        self.MoveToPrison(abMoveDirectlyToCell = true)
        return
    endif

    self.__ContinueToPrison(abEscortDirectlyToCell)

    ; The confrontation confirms early (at "Hands Behind Back", ~2s in) and plays on for a while: a fight breaking out now
    ; used to freeze it with me locked in it. Watched from my updates, not this thread (BeginArrest's caller waits on it).
    if (SceneManager.GetCurrentScene() == sceneSet)
        self.SetString("Watched Confrontation", sceneSet)
        self.SetFloat("Confrontation Watch Start", Utility.GetCurrentRealTime())
        self.SetBool("Pending Directly To Cell", abEscortDirectlyToCell)
        RegisterForSingleUpdate(1.0)
    endif
endFunction

;/
    One read of the confrontation watch (see EscortToPrison): a fight around us two reads in a row, while my
    confrontation is still the current Scene (or, while I'm not cuffed yet, no Scene or my own escort to jail). Before the cuffs I'm let go (nothing was done to me yet); cuffed, the arrest
    waits the fight out (pending), then only the escort is left. True while the watch goes on. Bounded: 1 read a second,
    at most 30s, and it ends with the confrontation.
/;
bool function __WatchConfrontationTick()
    string watched = self.GetString("Watched Confrontation")
    if (watched == "")
        return false
    endif

    ; Still watched when the confrontation is no longer the current Scene but I'm not cuffed yet: a fight makes the engine
    ; stop the confrontation (no end event), and my escort to jail, queued at the confirmation, was then started in its
    ; place (or refused and dropped). The watch stopped there, and the fight left me in limbo: an uncuffed prisoner with no
    ; Scene, never cancelled (tests 111/112).
    string current = SceneManager.GetCurrentScene()
    bool stillMine = current == watched
    if (!stillMine && !RPB_Utility.IsCuffed(this))
        stillMine = current == "" || (SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ESCORT_TO_JAIL) && SceneManager.GetSceneNthReferenceOfType(current, "Escortee") == this)
    endif
    if (!stillMine || (Utility.GetCurrentRealTime() - self.GetFloat("Confrontation Watch Start")) > 30.0)
        self.Remove("Watched Confrontation")
        return false
    endif

    Actor guard = Captor.GetActor()
    int fightStreak = 0
    if (self.__FightBrokeOut(guard))
        fightStreak = self.GetInt("Confrontation Fight Streak") + 1
    endif
    self.SetInt("Confrontation Fight Streak", fightStreak)
    if (fightStreak < 2 && !(fightStreak >= 1 && self.GetForm("Interrupting Hostile")))
        return true
    endif

    self.Remove("Watched Confrontation")
    self.Remove("Confrontation Fight Streak")
    if (RPB_Utility.IsCuffed(this))
        Info("Confrontation of " + Name + " " + this + " interrupted by a fight (" + self.GetForm("Interrupting Hostile") + ") after the cuffs, the arrest goes pending")
        SceneManager.EndSceneWithActor(this, "a fight broke out after the cuffs") ; my queued escort goes with it
        self.__BeginPendingArrest(self.GetBool("Pending Directly To Cell"), self.GetForm("Interrupting Hostile") as Actor, abEscortOnly = true)
    else
        Info("Confrontation of " + Name + " " + this + " interrupted by a fight (" + self.GetForm("Interrupting Hostile") + ") before the cuffs, the arrest is cancelled")
        RPB_Recovery.CancelArrest(this, "a fight broke out before the cuffs")
    endif
    return false
endFunction

;/
    True if my guard is still in combat after BeginArrest's own combat break, once things settle. BeginArrest stops the
    combat of both of us, so right after it neither reads as fighting even when another hostile is about to pull the
    guard straight back in: an arrest made in a fight (@abCombatAtArrest, read by BeginArrest before its StopCombat) waits
    a moment for that before looking. A guard that was only fighting me is free by then; one back in combat is fighting
    someone else. A peaceful arrest skips all of it.
/;
bool function __CaptorStillFighting(bool abCombatAtArrest)
    Actor guard = Captor.GetActor()
    if (!guard)
        return false
    endif

    if (!abCombatAtArrest && !guard.IsInCombat())
        return false
    endif

    Utility.Wait(1.5) ; another hostile re-engages the guard

    float waitStart = Utility.GetCurrentRealTime()
    while (guard.IsInCombat() && (Utility.GetCurrentRealTime() - waitStart) < 1.5)
        Utility.Wait(0.25)
    endWhile

    ; The player still in combat after the settle is being fought by someone (their StopCombat doesn't stop the others,
    ; and combat targets may not be readable on the player)
    bool fighting = guard.IsInCombat() || (self.IsPlayer() && this.IsInCombat())
    Debug("["+ Name +"] Arrestee::__CaptorStillFighting", "combat at arrest " + abCombatAtArrest + ", guard " + guard + " still in combat after settling " + fighting + " -> " + string_if(fighting, "pending arrest", "normal confrontation"))
    return fighting
endFunction

;/
    The arrest while my guard is busy fighting: I'm taken out of the fight and cuffed now (never left standing armed), and
    the rest - becoming a prisoner and the escort - waits until the guard's combat ends. The Captor resumes me
    (RPB_Captor.OnCombatStateChanged, with a slow re-check as a safety net). A death on either side reverts it through the
    existing handlers.
/;
function __BeginPendingArrest(bool abEscortDirectlyToCell, Actor akOtherHostile, bool abEscortOnly = false)
    Actor guard = Captor.GetActor()
    ; Already a prisoner, cuffed by the confrontation: only the escort is left once the fight is over
    self.SetBool("Pending Escort Only", abEscortOnly)
    bool isPlayer = self.IsPlayer()
    ; Nobody known, but someone outside the law attacking me: my guard goes after them, and the arrest waits for that one
    if (!akOtherHostile)
        akOtherHostile = RPB_Utility.SendCaptorAfterAttacker(guard, this)
    endif
    self.SetForm("Pending Hostile", akOtherHostile) ; the Captor resumes me once it's dealt with

    this.StopCombat()
    this.StopCombatAlarm()
    this.SheatheWeapon()
    if (isPlayer)
        ; A leash, not a freeze: SetRestrained locked the camera too. Cuffed hands can't fight or activate anything, but
        ; the camera, movement and menus stay free; the leash (OnUpdate) keeps me near my guard.
        ; Also clears a confrontation's full RetainAI lock (a fight that broke out mid-confrontation lands here)
        RPB_Utility.HoldPlayerCuffed()
    else
        ; Out of the fight and held where I am: no fighting anyone (neutralized, I'm no longer the other hostiles' ally
        ; and my AI still reacted to them), no running off. SetRestrained alone still let me drift 75-240 units in 3s,
        ; so SetDontMove pins me too and the package is re-evaluated to drop whatever was walking me.
        this.SetActorValue("Aggression", 0) ; restored with the hostility restore
        ; Sheathed before being restrained: restraining in the same frame interrupted the sheathe, and a weapon drawn in
        ; the fight stayed drawn for the whole hold
        float sheatheStart = Utility.GetCurrentRealTime()
        while (this.IsWeaponDrawn() && (Utility.GetCurrentRealTime() - sheatheStart) < 1.5)
            Utility.Wait(0.1)
        endWhile
        this.SetRestrained(true)
        this.SetDontMove(true)
        ; Out of combat, my AI still drew my weapons at the fight next to me, on and off: the hold package (Ignore Combat,
        ; No Combat Alert) keeps me out of it. My weapons stay on me, sheathed.
        this.SetAlert(false)
        if (RPB_Utility.IsPendingHoldPackageDisabled() || !Arrest.SceneManager.SetPendingHoldOnActor(this))
            this.EvaluatePackage()
        endif
        ; Neither the script calls nor the hold package (Ignore Combat, No Combat Alert) stopped my AI drawing my weapon at
        ; the fight next to me: every draw is answered with a sheathe (SKSE action 8, "unsheathe end"; events only)
        RegisterForActorAction(8)
    endif
    self.SetBool("Pending Hold", true)
    Debug("["+ Name +"] Arrestee::__BeginPendingArrest", "hold on at (" + (this.GetPositionX() as int) + ", " + (this.GetPositionY() as int) + ")")

    ; What the confrontation Scene's "Handcuff" step does (the Scene itself can't start in a fight)
    if (!abEscortOnly)
        self.Restrain()
        Arrest.OnArresteeRestrained(self)
    endif

    self.SetBool("Arrest Pending", true)
    self.SetBool("Pending Directly To Cell", abEscortDirectlyToCell)
    Info("Arrest of " + Name + " " + this + " is pending: cuffed, waiting for " + guard + " to deal with " + akOtherHostile + " before the escort")

    Captor.WatchPendingArrest()
    RegisterForSingleUpdate(5.0) ; the leash: pulled back to my guard if I end up (or walk) too far

    ; The fight may have ended while I was being cuffed: no combat change would come for it
    Captor.__ResumePendingArrestIfDone()
endFunction

; The guard's fight is over: the arrest goes on from where the confrontation Scene would have left it (I'm already cuffed)
function ResumePendingArrest()
    if (!self.GetBool("Arrest Pending"))
        return ; already resumed (the event and the re-check can both get here)
    endif
    self.SetBool("Arrest Pending", false)
    __pausingEscort = false
    self.SetBool("Stall Primed", false)
    self.__ReleasePendingHold() ; the escort has to walk me
    ; The player is AI-driven from here, as after the confrontation Scene (its RetainAI never ran on this path)
    RetainAI(self.IsPlayer())

    Info("Pending arrest of " + Name + " " + this + " resumed: the fight is over, escorting")
    if (self.GetBool("Pending Escort Only"))
        self.Remove("Pending Escort Only")
        self.__ResumeEscort(self.GetBool("Pending Directly To Cell"))
    else
        self.__ContinueToPrison(self.GetBool("Pending Directly To Cell"))
    endif
    self.OnArrestEnd() ; what the confrontation Scene's end does: the escort leash, and the wedge check
endFunction

; Lifts what __BeginPendingArrest put on me to hold me in place (Aggression comes back with the hostility restore).
; @abReverted: the arrest is over, so the player gets their controls back; a resume keeps them AI-driven for the escort.
function __ReleasePendingHold(bool abReverted = false)
    if (!self.GetBool("Pending Hold"))
        return
    endif
    self.SetBool("Pending Hold", false)

    if (self.IsPlayer())
        if (abReverted)
            ReleaseAI(true)
        endif
        return
    endif

    Arrest.SceneManager.UnsetPendingHoldOnActor(this) ; before the escort Scene binds me
    if (abReverted)
        UnregisterForActorAction(8)
    else
        ; Resumed: the fight can still be going on next to me (the other hostile dying), and I drew my weapon at it with
        ; the cuffs on. Draws are still answered while I'm cuffed, until my arrest state ends (Destroy).
        self.SetBool("Sheathe While Cuffed", true)
    endif
    this.SetRestrained(false)
    this.SetDontMove(false)
endFunction

; While held (pending, NPC), and cuffed after a resume: a weapon drawn is put away again
event OnActorAction(int actionType, Actor akActor, Form source, int slot)
    if (akActor != this || actionType != 8)
        return
    endif

    if (!self.GetBool("Pending Hold"))
        ; Resumed and walking to the escort: only sheathed (no restraint, the escort walks me), and only while I'm still
        ; cuffed and not in a fight of my own
        if (self.GetBool("Sheathe While Cuffed") && RPB_Utility.IsCuffed(this) && !this.IsInCombat())
            self.SetInt("Resumed Draws", self.GetInt("Resumed Draws") + 1)
            Debug("["+ Name +"] Arrestee::OnActorAction", Name + " drew a weapon while cuffed after the resume, sheathing it")
            this.SheatheWeapon()
        endif
        return
    endif

    self.SetInt("Pending Draws", self.GetInt("Pending Draws") + 1)
    Debug("["+ Name +"] Arrestee::OnActorAction", Name + " drew a weapon while held, sheathing it")
    ; A restrained actor can't finish a sheathe: unrestrained for it (SetDontMove still pins me)
    this.SetRestrained(false)
    this.SheatheWeapon()
    float sheatheStart = Utility.GetCurrentRealTime()
    while (this.IsWeaponDrawn() && (Utility.GetCurrentRealTime() - sheatheStart) < 1.5)
        Utility.Wait(0.1)
    endWhile
    if (self.GetBool("Pending Hold"))
        this.SetRestrained(true)
    endif
endEvent

; The arrest from its confirmation on: I become a prisoner, get a cell, and am escorted there (or moved, off-screen)
; The escort of the prisoner I already am (a fight after the cuffs made the arrest wait): the tail of __ContinueToPrison
function __ResumeEscort(bool abEscortDirectlyToCell)
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(this)
    RPB_Prisoner prisoner = none
    if (prison)
        prisoner = prison.Prisoners.AtKey(this)
    endif
    if (!prisoner)
        DebugError("["+ Name +"] Arrestee::__ResumeEscort", "No prisoner to escort for " + Name + ", cancelling the arrest")
        RPB_Recovery.CancelArrest(this, "no prisoner left to escort")
        return
    endif

    Actor guard = Captor.GetActor()
    if (!this.Is3DLoaded() || !guard.Is3DLoaded())
        if (!abEscortDirectlyToCell)
            prisoner.MoveToPrison(guard)
        else
            prisoner.MoveToCell()
        endif
        return
    endif

    if (!abEscortDirectlyToCell)
        prisoner.EscortToJail(guard)
    else
        prisoner.EscortToCell(guard)
    endif
endFunction

function __ContinueToPrison(bool abEscortDirectlyToCell)
    if (this.IsDisabled())
        Debug("["+ Name +"] Arrestee::__ContinueToPrison", Name + " is disabled, not continuing the arrest")
        return
    endif

    self.DeclareArrestSuccess()

    RPB_Prisoner prisoner   = self.MakePrisoner()
    if (!prisoner)
        ; MakePrisoner()'s own registration never completed (AwaitEntityReference timed out - most likely the actor's
        ; 3D went away at exactly the wrong moment, see round 20's investigation). Fail explicitly and legibly instead
        ; of letting a None prisoner/prison cascade through AssignCell()/OnPrisonerImprisonmentFail()'s own silent
        ; "cannot call on a None object" native errors and land in RevertArrest() below with the wrong failure
        ; attributed - the same explicit guard MoveToPrison() already has for this identical failure mode.
        DebugError("["+ Name +"] Arrestee::EscortToPrison", "Could not turn " + Name + " into a prisoner (registration timed out), aborting the arrest!")
        self.OnArrestFailed("Prisoner Registration")
        return
    endif
    RPB_Prison prison       = prisoner.Prison

    bool hasAssignedCell = prisoner.AssignCell()

    if (!hasAssignedCell)
        prison.OnPrisonerImprisonmentFail(prisoner, "Assign Cell")
        self.RevertArrest()
        return
    endif

    if (!this.Is3DLoaded() || !Captor.GetActor().Is3DLoaded())
        ; The confrontation Scene can confirm even when one of us has already gone 3D-unloaded - Phase 1 has no CK
        ; condition at all (confirmed directly), so "Scene Confirmed" reads true almost unconditionally, regardless of
        ; either participant's load state. Starting a Package-driven Escort Scene against an unloaded actor doesn't
        ; fail cleanly: SceneManager only checks the bound reference for None, never Is3DLoaded(), so the Scene binds
        ; and "starts" successfully while its own phase machine can never actually evaluate Phase 1 (the Escort walk,
        ; unlike the confrontation Scene, genuinely is Package/AI-driven - see rounds 22-23) - no event ever fires to
        ; advance or revert the arrest, and the one existing stall check (QueueEscortToCellStallCheck) only arms from
        ; the Escort-to-Cell Scene's own last phase cue, never reached if it can't get moving at all; Escort-to-Jail
        ; has no stall check whatsoever. Confirmed as a real, reachable gap, not just a test artifact - test 104's own
        ; crumb trail showed exactly this sequence once its own timing bug was fixed. Skip the Scene entirely and
        ; finish the same way the confrontation-Scene fallback above already does, reusing MoveToPrison()'s own
        ; already-proven direct-teleport calls instead of a doomed Scene attempt.
        if (!abEscortDirectlyToCell)
            prisoner.MoveToPrison(Captor.GetActor())
        else
            prisoner.MoveToCell()
        endif
        return
    endif

    if (!abEscortDirectlyToCell)
        prisoner.EscortToJail(Captor.GetActor())
    else
        prisoner.EscortToCell(Captor.GetActor())
    endif
endFunction

function MoveToPrison(bool abMoveDirectlyToCell = false)
    if (this.IsDisabled())
        ; Gone while this arrest was still in flight (a test's teardown disables before deleting)
        Debug("["+ Name +"] Arrestee::MoveToPrison", Name + " is disabled, not moving them to prison")
        return
    endif

    RPB_Prisoner prisoner   = self.MakePrisoner()

    if (!prisoner)
        ; The prisoner never registered (AwaitEntityReference timed out): stop here instead of dereferencing None, and undo
        ; the half-made arrest (dangling prisoner spell, arrest state) so the actor can be arrested again.
        RPB_Utility.Crumb(this, "MoveToPrison: ABORT no prisoner registered")
        DebugError("[" + Name + "] Arrestee::MoveToPrison", "Could not turn " + Name + " into a prisoner (registration timed out), aborting the arrest!")
        this.RemoveSpell(RPB_Utility.RPB_PrisonerSpell())
        self.OnArrestFailed("Prisoner Registration")
        return
    endif

    RPB_Utility.FlowMark("MoveToPrison: MakePrisoner done (await prisoner incl. Initialize)")
    RPB_Utility.Crumb(this, "MoveToPrison: MakePrisoner done (await prisoner incl. Initialize)")
    RPB_Prison prison       = prisoner.Prison

    bool hasAssignedCell = prisoner.AssignCell()
    RPB_Utility.FlowMark("MoveToPrison: AssignCell done")
    RPB_Utility.Crumb(this, "MoveToPrison: AssignCell done")

    if (abMoveDirectlyToCell)
        if (!hasAssignedCell)
            prisoner.OnImprisonmentFail("Assign Cell")
            self.OnArrestFailed("Assign Cell")
            return
        endif

        prisoner.MoveToCell()
        RPB_Utility.FlowMark("MoveToPrison: prisoner.MoveToCell returned")
        RPB_Utility.Crumb(this, "MoveToPrison: prisoner.MoveToCell returned")
    else
        if (!hasAssignedCell)
            DebugWarn("["+ Name +"] Arrestee::MoveToPrison", "Arrestee hasn't been assigned a cell yet since it failed, the arrest may not work!")
        endif
        prisoner.MoveToPrison(Captor.GetActor())
    endif
endFunction

function ChangeEscort(Actor akNewEscort)
    ; SetReference("Arresting Guard", akNewEscort)
    ; ; Arrest.RegisterCaptor() || Arrest.MarkActorAsCaptor(akNewEscort)
    ; Arrest.SceneManager.StartEscortToJail( \
    ;     akEscortLeader      = akNewEscort, \
    ;     akEscortedPrisoner  = this, \
    ;     akPrisonerChest     = ArrestVars.PrisonerItemsContainer \
    ; )
endFunction

; ==========================================================
;                            Utility
; ==========================================================

function SetTimeOfArrest()
    SetFloat("Time of Arrest", CurrentTime)
    SetInt("Minute of Arrest", RPB_Utility.GetCurrentMinute())
    SetInt("Hour of Arrest", RPB_Utility.GetCurrentHour())
    SetInt("Day of Arrest", RPB_Utility.GetCurrentDay())
    SetInt("Month of Arrest", RPB_Utility.GetCurrentMonth())
    SetInt("Year of Arrest", RPB_Utility.GetCurrentYear())
endFunction

function MoveToCaptor()
    this.MoveTo(Captor.GetActor())
endFunction

; ==========================================================
;                           Bounty
; ==========================================================

bool function HasActiveBounty()
    return parent.HasActiveBountyForFaction(ArrestFaction)
endFunction

bool function HasLatentBounty()
    return parent.HasLatentBountyForFaction(ArrestFaction)
endFunction

function SetCrimeGold(int aiGold)
    parent.SetCrimeGoldForFaction(ArrestFaction, aiGold)
endFunction

function SetCrimeGoldViolent(int aiGold)
    parent.SetCrimeGoldViolentForFaction(ArrestFaction, aiGold)
endFunction

function ModCrimeGold(int aiAmount, bool abViolent = false)
    parent.ModCrimeGoldForFaction(ArrestFaction, aiAmount, abViolent)
endFunction

;/
    Gets the active bounty for this Actor, that is, the bounty that is currently set on a Faction when
    the Actor is wanted by that Faction.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetActiveBounty(bool abNonViolent = true, bool abViolent = true)
    return parent.GetActiveBountyForFaction(ArrestFaction, abNonViolent, abViolent)
endFunction

;/
    Gets the latent bounty for this Actor, that is, the bounty that is stored when Arrested/Jailed.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetLatentBounty(bool abNonViolent = true, bool abViolent = true)
    return parent.GetLatentBountyForFaction(ArrestFaction, abNonViolent, abViolent)
endFunction

; Transfers the Active Bounty into the Latent Bounty.
function HideBounty()
    parent.HideBountyForFaction(ArrestFaction)
endFunction

; Restores the Active Bounty from the Latent Bounty.
function RestoreBounty()
    parent.RestoreBountyForFaction(ArrestFaction)
endFunction

;/
    Clears the Latent Bounty for this Actor (The bounty used when Arrested/Jailed).

    bool?   @abNonViolent: Whether to clear non-violent bounty.
    bool?   @abViolent: Whether to clear violent bounty.
/;
function ClearLatentBounty(bool abNonViolent = true, bool abViolent = true)
    parent.ClearLatentBountyForFaction(ArrestFaction, abNonViolent, abViolent)
endFunction

; ==========================================================
;                          Actor Vars
; ==========================================================

int function QueryStat(string asStatName)
    return RPB_ActorVars.GetStat(asStatName, ArrestFaction, this)
endFunction

function SetStat(string asStatName, int aiValue)
    RPB_ActorVars.SetStat(asStatName, ArrestFaction, this, aiValue)

    if (TrackStats)
        self.OnStatChanged(asStatName, aiValue)
    endif
endFunction

; ==========================================================

; ==========================================================
;                           Events
; ==========================================================

event OnInitialize()
    Arrest.RegisterArrestee(self)
    ; Debug("Arrestee::OnInitialize", "Initialized Arrestee, this: " + this)

    self.RegisterForTrackedStats()
    self.InitializeState()
endEvent

event OnDestroy()
    self.UnregisterForTrackedStats()

    if (self.IsPlayer())
        ; If for some reason AI is enabled, disable it
        ReleaseAI()
    endif
endEvent

event OnBountyGained()
    if (self.GetBool("Hiding Bounty"))
        return ; RPB_Arrest.BeginArrest is hiding it (a submission's set-aside bounty given back): hidden once, not twice
    endif
    self.HideBounty()
endEvent

event OnStatChanged(string asStatName, float afValue)
    ;/ const /; string HOLD_BOUNTY = Hold + " Bounty"

    if (asStatName == HOLD_BOUNTY) ; If there's bounty gained in the current arrest hold
        self.OnBountyGained()
    endif

    ; Debug("Arrestee::OnStatChanged", "Stat " + asStatName + " has been changed to " + afValue)
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    
endEvent

event OnDeath(Actor akKiller)
    Arrest.OnArresteeDeath(self, Captor, akKiller)
endEvent

event OnRestrained()
    
endEvent

event OnArrestBegin()
    ; Fired unconditionally by RPB_EventManager.OnArrestScene on every confrontation phase cue (Hands Behind Back,
    ; Kneel Down, Lie Down, Handcuff) - the earliest one to land is "Hands Behind Back", which makes this the first real
    ; signal anywhere that the confrontation Scene is actually doing something. AwaitConfrontationScene() above polls
    ; this flag to confirm the Scene instead of assuming StartArrestScene() worked just because it was called.
    self.SetBool("Scene Confirmed", true)
endEvent

event OnArrestEnd()
    Debug("Arrest::OnArrestEnd", "Arrest, captor should be escorting now")

    ; Captor.SetEscorting()

    ; A real report confirmed the guard can end up wedged against the arrestee right here, at the start of the
    ; Escort-to-Jail walk (the cuffs are already on by now - "Handcuff" fires earlier in the confrontation Scene this
    ; event is dispatched from) - not something a recurring check should watch for over and over throughout a
    ; potentially long escort, just once, right at the moment the guard's approach package is about to take over.
    ; A gentler nudge than the confrontation Scene's own (that one clears a Package genuinely stuck fighting for a
    ; position; this is just breaking up incidental overlap before the walk begins).
    Actor guard = Captor.GetActor()
    if (RPB_Utility.IsWedgedTogether(self.GetActor(), guard))
        Debug("["+ Name +"] Arrestee::OnArrestEnd", "Guard wedged against " + Name + " right after cuffing, nudging aside")
        RPB_Utility.PushActorAwayFrom(guard, self.GetActor(), 40.0)
    endif

    RegisterForSingleUpdate(1.0)
endEvent

event OnArrestFailed(string asReason)
    if (asReason == "Assign Cell")
        ; Destroy anything related to RPB_Prisoner here (need to find a way to get the reference)
    endif

    self.RevertArrest()
endEvent

; While my arrest is pending I'm cuffed and out of every fight, but a single StopCombat didn't last: I was pulled back
; into combat within seconds and drew my weapons. Every time I re-enter combat while pending, I'm taken out again; a guard
; that picked me as a target drops me (he picks the other hostile back up on his own, and the resume waits for that one).
event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if (!self.GetBool("Arrest Pending"))
        return
    endif

    ; The escort can't start while I'm in combat (a player still fought by the other hostiles): out of it, the arrest can
    ; go on if the guard's fight is over too
    if (aeCombatState == 0)
        Captor.__ResumePendingArrestIfDone()
        return
    endif

    if (self.IsPlayer())
        return ; the player's combat isn't mine to stop: they wait it out, cuffed and leashed
    endif

    Actor guard = none
    if (Captor)
        guard = Captor.GetActor()
    endif
    Debug("["+ Name +"] Arrestee::OnCombatStateChanged", Name + " re-entered combat with " + akTarget + " (state " + aeCombatState + ") while the arrest is pending, taking them out again" + string_if(akTarget && akTarget == guard, " (the guard)", ""))

    this.StopCombat()
    this.StopCombatAlarm()
    this.SheatheWeapon()
    if (akTarget && akTarget == guard)
        guard.StopCombat()
    endif
endEvent

; How far I can get from my guard before the leash (OnUpdate) moves me back to them
float property ESCORT_LEASH_DISTANCE = 700.0 autoreadonly
float property PENDING_LEASH_DISTANCE = 2500.0 autoreadonly

event OnUpdate()
    ; Waiting in the prison for a guard who can see me (my guard died there): no Captor to watch or leash to
    if (self.GetBool("Awaiting Guard"))
        self.__AwaitGuardTick()
        return
    endif
    ; The hostile-faction re-check that used to live here (MaintainArrestPacification) was mitigating a symptom -
    ; a disguise mod reapplying a hostile faction mid-escort - of what turned out to be RPB checking the wrong faction
    ; entirely (see RPB_Compat_MasterOfDisguise.psc). With the actual root cause fixed, this per-tick recheck was no
    ; longer earning its keep: every arrestee paid a per-tick cost for a problem that no longer exists, and I'm trying
    ; to keep OnUpdate usage to what's actually necessary, not run it "just in case" - it's real overhead multiplied by
    ; however many arrestees are being escorted at once, and a script left registered is exactly what bloats a save.
    ; The guard-wedge nudge that briefly lived here too (round 3) doesn't belong in a recurring check either - it only
    ; ever needs to happen once, right as the confrontation ends (see OnArrestEnd()), not re-evaluated against normal
    ; walking proximity every 5s for the rest of a potentially long escort.
    ; A pending arrest leaves room to take cover from the fight; an escort keeps me close
    if (self.__WatchConfrontationTick())
        RegisterForSingleUpdate(1.0)
        return
    endif
    ; The watch above may have just cancelled the arrest and removed me: my variables still read on a dead effect, and the
    ; leash below then moved the freed player back to their guard
    if (!self.IsEffectActive)
        return
    endif

    if (!Captor || !Captor.GetActor())
        return ; the arrest is gone (cancelled by the watch above, or reverted)
    endif

    ; At the prison the escort to jail is over: the prison flow (strip, escort to the cell) has its own checks. Left
    ; running, this watch read "no Scene playing" between two prison Scenes as a stalled escort and sent me back to the
    ; prison entrance in the middle of the escort to my cell (Frisking all over again).
    ; Except a pending escort to my cell (a fight inside the prison, PauseEscortForFight): the leash still holds me there
    if (self.GetBool("Escort Arrived") && !self.GetBool("Arrest Pending"))
        return
    endif

    ; Attacked mid-escort by someone outside the law: my guard goes after them, and his fight pauses the escort
    ; (RPB_Captor.OnCombatStateChanged); paused here too in case that event comes late
    if (!self.GetBool("Arrest Pending") && this.IsInCombat())
        Actor attacker = RPB_Utility.SendCaptorAfterAttacker(Captor.GetActor(), this)
        if (attacker)
            self.PauseEscortForFight(attacker)
        endif
    endif

    float leash = ESCORT_LEASH_DISTANCE
    if (self.GetBool("Arrest Pending"))
        leash = PENDING_LEASH_DISTANCE
    endif
    if (this.GetDistance(Captor.GetActor()) >= leash)
        ; An escort I keep falling behind of is broken (seen: the player left standing while the guard walked off): after
        ; 3 pulls in a row (~15s), the same fallback as an escort that never starts
        int pulls = self.GetInt("Leash Pulls") + 1
        self.SetInt("Leash Pulls", pulls)
        ; The player's escort assist (RPB_Prisoner) handles a player falling behind: raised speed on stairs, then its own
        ; last-resort move and fallback. Pulled here, they skipped the stairs by teleport.
        if (self.IsPlayer() && self.__PlayerEscortAssisted())
            RegisterForSingleUpdate(5.0)
            return
        endif

        if (pulls >= 3 && !self.GetBool("Arrest Pending") && self.__EscortBroken())
            return
        endif

        ; Pulled back even while he's fighting: held off (round 40), a prisoner waiting out the fight could walk away as far as
        ; they liked, and the resumed escort then played out oddly from there. Running off while pending is meant to become
        ; an escape attempt with its own charge instead of a pull.
        this.MoveTo(Captor.GetActor())
        Debug("["+ Name +"] Arrestee::OnUpdate", "Moved Arrestee to " + Captor.Name)
    else
        self.SetInt("Leash Pulls", 0)
    endif

    if (self.__EscortStalled())
        return
    endif

    RegisterForSingleUpdate(5.0)
endEvent

;/
    An escort where nothing moves: its Scene never took hold (seen: the guard back on his own package after a resumed
    arrest, both standing there for good). Nobody drifts apart, so the leash never pulls. Counted on these 5s ticks from
    my position; 4 still ticks in a row (~20s): another guard of the hold takes the escort over (RPB_Arrest.
    TakeOverStalledEscort, up to STALL_TAKEOVERS_MAX per escort), and only with none, or after that many, the fallback to
    the prison without the Scene. Not while pending, in a fight, during another Scene than an escort to jail (a strip or
    frisk at the prison keeps me still on purpose), or while my escort is still queued behind other Scenes. True if it
    fell back.
/;
int property STALL_TAKEOVERS_MAX = 2 autoreadonly

bool function __EscortStalled()
    if (self.GetBool("Stall Takeover Pending"))
        return false ; a guard is being looked for (RPB_Arrest.TakeOverStalledEscort): its own fallback follows
    endif
    float x = this.GetPositionX()
    float y = this.GetPositionY()
    ; The first tick only records where I am: measured from a position left over from before this escort (an earlier
    ; arrest, or 0,0), it always read "moved" and set the nudge's gate at the escort's start
    if (!self.GetBool("Stall Primed"))
        self.SetFloat("Stall X", x)
        self.SetFloat("Stall Y", y)
        self.SetBool("Stall Primed", true)
        return false
    endif
    float moved = Math.sqrt(Math.pow(x - self.GetFloat("Stall X"), 2.0) + Math.pow(y - self.GetFloat("Stall Y"), 2.0))
    self.SetFloat("Stall X", x)
    self.SetFloat("Stall Y", y)

    string current = SceneManager.GetCurrentScene()
    Actor guard = Captor.GetActor()
    if (moved >= 64.0 || self.GetBool("Arrest Pending") || this.IsInCombat() || (guard && guard.IsInCombat()) || (current != "" && !SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ESCORT_TO_JAIL)))
        if (moved >= 64.0 && SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ESCORT_TO_JAIL))
            self.SetBool("Stall Escort Moved", true) ; the escort got going: a stop from here on is worth a nudge
        endif
        self.SetInt("Stall Ticks", 0)
        self.SetBool("Stall Nudged", false)
        return false
    endif

    int ticks = self.GetInt("Stall Ticks") + 1
    if (ticks >= 2 && SceneManager.HasQueuedSceneWithActor(this))
        ticks = 0 ; waiting its turn in the Scene queue, not stalled
    endif
    self.SetInt("Stall Ticks", ticks)
    ; Not before the escort got going: its opening phases hold both of us still (~10s), and a nudge fired there with the
    ; guard already setting off. The fallback below still counts from the start (a Scene that never took hold).
    if (ticks == 2 && guard && !self.GetBool("Stall Nudged") && self.GetBool("Stall Escort Moved"))
        self.SetBool("Stall Nudged", true)
        self.__NudgeStalledEscort(guard, current)
    endif
    if (ticks < 4)
        return false
    endif

    self.SetInt("Stall Ticks", 0)
    self.SetBool("Stall Nudged", false)
    string reason = "the escort isn't moving (" + string_if(current == "", "no Scene playing", current) + ")"
    ; Another guard of the hold first (the mod author, 2026-10-05): the teleport only with none around, or once
    ; STALL_TAKEOVERS_MAX guards in a row stalled too. The search calls into the guards around (one may be frozen): on its
    ; own stack
    if (self.GetInt("Stall Takeovers") < STALL_TAKEOVERS_MAX)
        self.SetBool("Stall Takeover Pending", true)
        int handle = ModEvent.Create("RPB_StalledEscortTakeover")
        if (handle)
            ModEvent.PushForm(handle, this)
            ModEvent.PushString(handle, reason)
            ModEvent.Send(handle)
            return false
        endif
        self.SetBool("Stall Takeover Pending", false)
    endif
    return self.__FallBackToPrison(reason)
endFunction

;/
    Halfway to the stall fallback (~10s still): what the guard and I are running, then both packages re-evaluated. Seen at
    Castle Dour's door into SolitudeJail01 with real guards too (2 of 10 escorts fell back, one more walked on by itself
    after ~17s). The guard's escort package is a plain Travel with no wait for me, and he stopped there before I had even
    caught up, so it isn't the two of us waiting on each other. The report tells a lost Scene package from a stuck Travel,
    and (DEBUG) lists who stands near the guard, in case someone blocks the doorway.
/;
function __NudgeStalledEscort(Actor akGuard, string asScene)
    GuardMark(akGuard, "stalled escort: reading his package")
    Info("Escort of " + Name + " " + this + " still for ~10s (" + string_if(asScene == "", "no Scene playing", asScene) + "), nudging it: guard " + akGuard + " on package " + akGuard.GetCurrentPackage() + ", " + Name + " on " + this.GetCurrentPackage() + ", " + (this.GetDistance(akGuard) as int) + " units apart, guard in " + akGuard.GetParentCell())

    if (IsDebuggingEnabled())
        Cell guardCell = akGuard.GetParentCell()
        string nearby = ""
        int count = 0
        if (guardCell)
            count = guardCell.GetNumRefs(62)
        endif
        int i = 0
        while (i < count)
            Actor other = guardCell.GetNthRef(i, 62) as Actor
            if (other && other != akGuard && other != this)
                float apart = other.GetDistance(akGuard)
                if (apart < 256.0)
                    nearby += other.GetDisplayName() + " " + other + " at " + (apart as int) + "; "
                endif
            endif
            i += 1
        endWhile
        Debug("["+ Name +"] Arrestee::__NudgeStalledEscort", "Actors within 256 units of " + akGuard + ": " + string_if(nearby == "", "none", nearby))
    endif

    ; Playing in the engine, or a phase waiting on its conditions: the escort to jail's "Reached Jail" needs the guard within
    ; 300 of the jail marker and within 150 of me (once stuck with the guard on his own quest package at the door)
    Scene stalledScene = none
    if (asScene != "")
        stalledScene = SceneManager.GetScene(asScene)
    endif
    if (stalledScene)
        string marker = "no marker"
        ReferenceAlias markerAlias = stalledScene.GetOwningQuest().GetAliasByName("Player_EscortLocation") as ReferenceAlias
        if (markerAlias && markerAlias.GetReference())
            marker = "guard " + (akGuard.GetDistance(markerAlias.GetReference()) as int) + " from the escort marker"
        endif
        Info("Stalled escort of " + Name + ": " + asScene + " playing " + stalledScene.IsPlaying() + ", " + marker + ", " + (this.GetDistance(akGuard) as int) + " from me")
    endif

    akGuard.EvaluatePackage()
    this.EvaluatePackage()
endFunction

bool function __PlayerEscortAssisted()
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(this)
    if (!prison)
        return false
    endif
    RPB_Prisoner prisoner = prison.Prisoners.AtKey(this)
    return prisoner && prisoner.EscortAssistActive
endFunction

; My escort to jail is playing but I'm not following it. False when it isn't an escort to jail that's playing.
bool function __EscortBroken()
    string current = SceneManager.GetCurrentScene()
    if (!SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ESCORT_TO_JAIL))
        return false
    endif

    self.SetInt("Leash Pulls", 0)
    return self.__FallBackToPrison("kept falling behind " + Captor.GetActor() + " (" + current + ")")
endFunction

; The escort's fallback: any Scene with me ended without its end events, and I'm moved to the prison without it (as for an
; escort that never starts). False when there's no prisoner of mine to move (or it's already imprisoned).
bool function __FallBackToPrison(string asReason)
    if (self.GetBool("Escort Arrived"))
        return false ; already at the prison (see EndEscortWatch)
    endif

    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(this)
    RPB_Prisoner prisoner = none
    if (prison)
        prisoner = prison.Prisoners.AtKey(this)
    endif
    if (!prisoner || prisoner.IsImprisoned)
        return false
    endif

    Info("Escort of " + Name + " " + this + " broken: " + asReason + ", moving them to the prison without the Scene")
    SceneManager.EndSceneWithActor(this, "the escort broke")
    ; The Scene ended without its end events, and those stop the player's escort assist: left on, it free-walked the player
    ; through the frisk and the strip, and the strip never ended
    prisoner.StopEscortAssist()
    prisoner.MoveToPrison(Captor.GetActor())
    return true
endFunction

;/
    My guard went into a fight with someone else during my escort to jail, or to my cell inside the prison
    (RPB_Captor.OnCombatStateChanged): the escort stops and the arrest waits for the fight to end, as a fight after the
    cuffs does during the confrontation. I'm already cuffed and a prisoner, so only the escort is left: the resume walks me
    on from wherever I am, to the jail or to my cell (__ResumeEscort). Before, the escort just lost its guard to the fight,
    and the player's stairs assist moved them to him, into it.
/;
bool __pausingEscort ; set and checked with no call between: two combat events at once both paused the escort (an NPC then held two PendingHold aliases, one released)

function PauseEscortForFight(Actor akHostile)
    if (__pausingEscort)
        return
    endif
    __pausingEscort = true

    if (self.GetBool("Arrest Pending") || !Captor)
        __pausingEscort = false
        return
    endif
    ; My escort to jail (not arrived yet) or to my cell (the arrest state lasts until I'm imprisoned). The escort to the cell
    ; 02 names me Prisoner, the others Escortee. Anything else (still the confrontation: its own watch handles a fight).
    string current = SceneManager.GetCurrentScene()
    bool toJail = SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ESCORT_TO_JAIL) && !self.GetBool("Escort Arrived")
    bool toCell = SceneManager.IsSceneOfType(current, SceneManager.CATEGORY_ESCORT_TO_CELL)
    string escorteeType = string_if(current == SceneManager.SCENE_ESCORT_TO_CELL_02, "Prisoner", "Escortee")
    if (!(toJail || toCell) || SceneManager.GetSceneNthReferenceOfType(current, escorteeType) != this)
        __pausingEscort = false
        return
    endif
    self.SetBool("Stall Primed", false) ; the resumed escort measures from where it starts again

    Actor guard = Captor.GetActor()
    Info("Escort of " + Name + " " + this + " paused: " + guard + " is fighting " + akHostile + ", the arrest waits for the fight to end")

    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(this)
    if (prison)
        RPB_Prisoner prisoner = prison.Prisoners.AtKey(this)
        if (prisoner)
            prisoner.StopEscortAssist() ; it would move the player to the guard, into the fight
        endif
    endif

    SceneManager.EndSceneWithActor(this, "the guard is fighting")
    self.__BeginPendingArrest(toCell, akHostile, abEscortOnly = true) ; resumed to the cell when it was the escort to the cell
endFunction

;/
    My guard died inside the prison (RPB_Captor.OnDeath, after my arrival): the nearest living guard in the prison's
    interior takes over, as a full Captor (a fight during his escort pauses it too, his own death hands over again), and
    the rest of the prison flow goes on with him. With none left, no imprisonment: I'm free inside the prison, stripped,
    and my belongings stay in the chest (nobody to hand them over), where an escape can begin. Before, the arrest was
    cancelled here and I got my belongings back, freed inside the jail with my gear.
/;
function HandOverInPrison(Actor akDeadGuard)
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(this)
    RPB_Prisoner prisoner = none
    if (prison)
        prisoner = prison.Prisoners.AtKey(this)
    endif
    if (!prisoner || prisoner.IsImprisoned)
        return
    endif

    ; First, before the 1-2s of finding and making the next guard: the dead guard's Scene went on meanwhile and stripped
    ; and cuffed the prisoner with nobody there. Whatever of mine was playing or queued (strip, clothing, the escort to the
    ; cell) stops now; the new guard starts it again.
    SceneManager.EndSceneWithActor(this, "the guard died")
    prisoner.StopEscortAssist()

    ; His package lock (if the escort to jail left one on him) on its own stack: a call on the dead guard held the whole
    ; handover once (148, 0010C06C: nothing after his lock was unbound)
    int handle = ModEvent.Create("RPB_FreeGuard")
    if (handle)
        ModEvent.PushForm(handle, akDeadGuard)
        ModEvent.Send(handle)
    endif
    RPB_Recovery.__Step(this, "HandOverInPrison: freeing " + akDeadGuard + " sent")
    Actor anyGuard = RPB_Utility.GetNearestGuardInCell(this, akDeadGuard)
    RPB_Recovery.__Step(this, "HandOverInPrison: a guard left in the prison: " + anyGuard)
    if (!anyGuard)
        Info("No guard left in " + prison.Name + " to take over from " + akDeadGuard + ": " + Name + " " + this + " is free inside, stripped; their belongings stay in the chest")
        RPB_Recovery.CancelArrest(this, "no guard left in the prison", abReturnBelongings = false)
        return
    endif

    ; Only a guard who can see me takes over. The nearest one in the prison, from across it, restrained me with nobody
    ; there (the pose held for a minute until he walked over) or posed me over the cuffs I already had on.
    Actor seeing = RPB_Utility.GetGuardSeeing(this, akDeadGuard)
    RPB_Recovery.__Step(this, "HandOverInPrison: a guard who sees me: " + seeing)
    if (seeing)
        self.__TakeOverInPrison(seeing, prison, prisoner, akDeadGuard)
    else
        self.__AwaitGuardInPrison(akDeadGuard, prison)
    endif
endFunction

;/
    My escort guard froze on the way to the prison (RPB_Arrest.__HandOverEscort), or my escort stalled (RPB_Arrest.
    TakeOverStalledEscort): @akNewGuard becomes my Captor and the escort to jail starts again with him. Nothing is called
    on @akFrozenGuard here: his Scene is stopped from my side, his package lock is freed on its own stack, and his Captor
    stays on him (ReleaseCaptorOf leaves a frozen guard alone) until the next load. @abReleaseOld: a guard who answers
    (a stall) has his Captor taken off too, on its own stack, once the new one is mine.
/;
function HandOverEscort(Actor akFrozenGuard, Actor akNewGuard, string asReason = "the escort guard froze", bool abReleaseOld = false)
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(this)
    RPB_Prisoner prisoner = none
    if (prison)
        prisoner = prison.Prisoners.AtKey(this)
    endif
    if (!prisoner || prisoner.IsImprisoned)
        return
    endif

    SceneManager.EndSceneWithActor(this, asReason)
    prisoner.StopEscortAssist()
    int handle = ModEvent.Create("RPB_FreeGuard")
    if (handle)
        ModEvent.PushForm(handle, akFrozenGuard)
        ModEvent.Send(handle)
    endif

    RPB_Captor newCaptor = Arrest.AwaitCaptorReference(akNewGuard)
    if (!newCaptor)
        Info("Could not make " + akNewGuard + " the captor of " + Name + " " + this + " after " + akFrozenGuard + " froze: the escort goes on without a Scene")
        prisoner.MoveToPrison(akNewGuard)
        return
    endif
    newCaptor.AssignArrestee(this)
    self.AssignCaptor(newCaptor)
    __captor = newCaptor
    self.SetForm("Arrest Captor", akNewGuard, "Jail")
    Info("Escort of " + Name + " " + this + " handed over to " + akNewGuard + " from " + akFrozenGuard + ": " + asReason)
    if (abReleaseOld)
        handle = ModEvent.Create("RPB_ReleaseCaptor")
        if (handle)
            ModEvent.PushForm(handle, akFrozenGuard)
            ModEvent.PushForm(handle, this)
            ModEvent.PushBool(handle, true)
            ModEvent.Send(handle)
        endif
    endif
    ; The stall watch starts over with him
    self.SetBool("Stall Primed", false)
    self.SetInt("Stall Ticks", 0)
    self.SetBool("Stall Nudged", false)
    self.SetBool("Stall Escort Moved", false)
    RetainAI(self.IsPlayer()) ; the escort walks me
    self.__ResumeEscort(false)
endFunction

; @akNewGuard becomes my Captor and the prison flow goes on with him from where it stopped
function __TakeOverInPrison(Actor akNewGuard, RPB_Prison apPrison, RPB_Prisoner apPrisoner, Actor akOldGuard)
    RPB_Captor newCaptor = Arrest.AwaitCaptorReference(akNewGuard)
    if (!newCaptor)
        Info("Could not make " + akNewGuard + " the captor of " + Name + " " + this + " after " + akOldGuard + " died: free inside, stripped")
        self.SetBool("Awaiting Guard", false)
        RPB_Recovery.CancelArrest(this, "no guard could take over in the prison", abReturnBelongings = false)
        return
    endif
    newCaptor.AssignArrestee(this)
    self.AssignCaptor(newCaptor)
    __captor = newCaptor ; the Captor property (set once by SetArrestParameters at the arrest)
    ; The prisoner's side too: the imprisonment releases "Arrest Captor", which still named the dead guard (the new one
    ; kept his Captor for good)
    self.SetForm("Arrest Captor", akNewGuard, "Jail")

    string waited = ""
    if (self.GetBool("Awaiting Guard"))
        self.SetBool("Awaiting Guard", false)
        waited = ", after waiting " + ((Utility.GetCurrentRealTime() - self.GetFloat("Awaiting Guard Since")) as int) + "s for a guard to see them"
    endif
    Info("Arrest of " + Name + " " + this + " handed over to " + akNewGuard + " in " + apPrison.Name + ": " + akOldGuard + " died" + waited)

    if (self.GetBool("Arrest Pending"))
        self.SetBool("Arrest Pending", false)
        __pausingEscort = false
        self.SetBool("Stall Primed", false)
    endif
    self.__ReleasePendingHold()
    RetainAI(self.IsPlayer()) ; the escort walks me, as after the confrontation
    apPrison.ResumePrisonFlowWith(apPrisoner, akNewGuard)
endFunction

;/
    No guard sees me after mine died inside the prison: the arrest waits until one does (OnUpdate, __AwaitGuardTick).
    Cuffed, the player walks free with the cuffs on (no fighting, no activating); uncuffed, they're simply free to move. An
    NPC is held where they are. Leaving the prison's cell doesn't count: guards elsewhere don't take over (escaping while
    an arrest waits is its own design).
/;
function __AwaitGuardInPrison(Actor akDeadGuard, RPB_Prison apPrison)
    self.SetBool("Awaiting Guard", true)
    self.SetForm("Awaiting Guard Dead", akDeadGuard)
    self.SetForm("Awaiting Guard Cell", this.GetParentCell())
    self.SetFloat("Awaiting Guard Since", Utility.GetCurrentRealTime())
    apPrison.CancelEscortToCellStallCheck(this) ; nothing is escorting me now

    bool cuffed = RPB_Utility.IsCuffed(this)
    if (self.IsPlayer())
        if (cuffed)
            RPB_Utility.HoldPlayerCuffed()
        else
            ReleaseAI(true)
        endif
    else
        this.SheatheWeapon()
        this.SetDontMove(true)
        if (!RPB_Utility.IsPendingHoldPackageDisabled())
            Arrest.SceneManager.SetPendingHoldOnActor(this)
        endif
        self.SetBool("Pending Hold", true) ; lifted by the take-over (__ReleasePendingHold)
    endif
    Info(Name + " " + this + " waits in " + apPrison.Name + " (cuffed " + cuffed + ") for a guard who can see them: " + akDeadGuard + " died")
    RegisterForSingleUpdate(2.0)
endFunction

function __AwaitGuardTick()
    Actor deadGuard = self.GetForm("Awaiting Guard Dead") as Actor
    RPB_Prison prison = API.PrisonManager.FindPrisonByPrisoner(this)
    RPB_Prisoner prisoner = none
    if (prison)
        prisoner = prison.Prisoners.AtKey(this)
    endif
    if (!prisoner || prisoner.IsImprisoned)
        self.SetBool("Awaiting Guard", false)
        return
    endif

    ; Outside the prison's cell nobody takes over, and nobody lets me go either
    if (this.GetParentCell() != self.GetForm("Awaiting Guard Cell") as Cell)
        RegisterForSingleUpdate(2.0)
        return
    endif

    if (!RPB_Utility.GetNearestGuardInCell(this, deadGuard))
        self.SetBool("Awaiting Guard", false)
        Info("No guard left in " + prison.Name + " while " + Name + " " + this + " waited: free inside, stripped; their belongings stay in the chest")
        RPB_Recovery.CancelArrest(this, "no guard left in the prison", abReturnBelongings = false)
        return
    endif

    Actor seeing = RPB_Utility.GetGuardSeeing(this, deadGuard)
    if (seeing)
        self.__TakeOverInPrison(seeing, prison, prisoner, deadGuard)
        return
    endif
    RegisterForSingleUpdate(2.0)
endFunction

; I've arrived at the prison (the escort to jail ended, or I was moved there or into my cell): the escort watch in
; OnUpdate (leash, stall, broken escort) stops at its next tick
function EndEscortWatch()
    self.SetBool("Escort Arrived", true)
    self.SetInt("Stall Ticks", 0)
    self.SetBool("Stall Nudged", false)
    self.SetBool("Stall Escort Moved", false)
    self.SetBool("Stall Primed", false)
    __pausingEscort = false
    self.SetInt("Leash Pulls", 0)
endFunction

; ==========================================================
;                           Management
; ==========================================================

function Destroy()
    ; Unset all properties related to this Arrestee
    ; Stop the escort loop first (OnUpdate reads the Captor, which RemoveAll deletes). This used to be a blind
    ; Utility.Wait(0.5) between RemoveAll and UnregisterArrestee, which blocked every imprisonment for half a second.
    if (self.IsEffectActive) ; on a dead effect the native errors out (no native object bound)
        UnregisterForUpdate()
        UnregisterForActorAction(8) ; the draws answered while held or cuffed after a resume
    endif
    self.RemoveAll()
    Arrest.UnregisterArrestee(self)
endFunction

string function GetScriptVarCategory(string asVarCategory = "Actor")
    if (asVarCategory == "Actor")
        return "Arrest"
    endif

    return asVarCategory
endFunction

bool function InitializeState()
    ; Determine what Prison to go to (or another location, needs to be handled accordingly)
    ; Check if the Prison exists and every crucial property is okay, if not abort the arrest.
    if (self.Was("Initialized"))
        return true
    endif

    ; self.DeterminePrison() or Location

    int errors = FastArray("<string>")
    ; errors = EnsureTrue(HasPrisonToGoTo || HasLocationToGoTo, "Could not determine the Location to escort the Arrestee " + Name, errors)

    bool hasErrors = FastArray_Size(errors) > 0

    if (hasErrors)
        self.RevertState()
    endif

    self.SetBool("Initialized", true) ; Prevent further initializations

    ; Both the effect's OnInitialize() and EventManager.OnArrestBegin() call this, and whichever runs first executes the body.
    ; The function used to fall off the end (a bool function then returns false), so when the event handler won the race
    ; it aborted the arrest and left the actor stuck as an arrestee. The body is idempotent, so a double run is harmless.
    return !hasErrors
endFunction

function RevertState()
    ; Decouple the Captor from this Arrestee, if it exists.
    if (Captor)
        Captor.RemoveArrestee(self)
    endif

    ; Revert the Arrestee's state
    self.UnregisterForTrackedStats()
    self.RestoreBounty()
    self.RemoveAll()

    ; Destroy the effect
    self.Destroy()
endFunction

; ==========================================================
;                            Getters
; ==========================================================

;/
    Returns the same as GetActor(), used for convenience.
/;
Actor function GetArrestedActor()
    return self.GetActor()
endFunction

Actor function GetActor()
    return this
endFunction

RPB_Captor function GetCaptor()
    return self.Captor
endFunction

Faction function GetFaction()
    return self.ArrestFaction
endFunction

string function GetHold()
    return self.Hold
endFunction

string function GetArrestType()
    return self.ArrestType
endFunction

