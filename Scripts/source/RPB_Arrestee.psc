Scriptname RPB_Arrestee extends RPB_ActorBase

;/
@properties:
    RPB_Arrest Arrest
    RPB_SceneManager SceneManager
    RPB_Captor Captor
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
    function EscortToPrison(bool abEscortDirectlyToCell = false)
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
        return __captor
    endFunction
endProperty

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
    Form cuffs = Game.GetFormFromFile(0x81D2F, "ZaZAnimationPack.esm")

    self.SheatheWeapon()
    UnequipHandsForActor(this)
    self.EquipItem(cuffs, true, true)
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
    int cuffsItemSlot = 59

    Form cuffs = this.GetEquippedArmorInSlot(cuffsItemSlot)

    this.UnequipItemSlot(cuffsItemSlot)
    this.RemoveItem(cuffs)
    Debug("Arrestee::Uncuff", "Uncuffed " + this)
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
bool function AwaitConfrontationScene(string asScene)
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
        bool confirmed = false

        while (!confirmed && (Utility.GetCurrentRealTime() - attemptStart) < PER_ATTEMPT_TIMEOUT_SECONDS)
            if (!self.IsEffectActive) ; the Arrestee itself is gone mid-wait (e.g. died) - OnDeath already handles that
                return false
            endif

            Utility.Wait(POLL_INTERVAL_SECONDS)
            confirmed = self.GetBool("Scene Confirmed")

            if (!confirmed)
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

function EscortToPrison(bool abEscortDirectlyToCell = false)
    string sceneSet = string_if (self.GetString("Scene"), self.GetString("Scene"), Arrest.SceneManager.SCENE_ARREST_START_02)

    ; Persisted so anything resolving "which Scene is this arrest actually running" later (Captor.OnDeath, so it can
    ; stop this Scene if the guard dies before it confirms) has a reliable value to read back - "Scene" itself was
    ; only ever read here before, never written, so it always fell through to the fallback above.
    self.SetString("Scene", sceneSet)

    if (!self.AwaitConfrontationScene(sceneSet))
        ; AwaitConfrontationScene() returns false for two different reasons, and they need different handling here.
        ; (1) all retries exhausted, arrestee still alive - the case this fallback is for. (2) !self.IsEffectActive
        ; fired inside its own wait loop because this Arrestee was already torn down by something else entirely (e.g.
        ; the captor died and RPB_Captor.OnDeath's own fast-revert already called RevertArrest() on a separate call
        ; stack, while this call stack was still suspended in the confrontation wait from before the kill). Confirmed
        ; by a real test: proceeding here in that second case tried to DeclareArrestSuccess()/MoveToPrison() an Actor
        ; already disabled by the revert that already ran, producing "not loaded, disabled: TRUE" then "Could not
        ; turn bandit into a prisoner" - a doomed, redundant salvage attempt on an arrest that's already been reverted.
        if (!self.IsEffectActive)
            return
        endif

        ; The confrontation Scene never confirmed - rather than reverting an arrest that already legitimately started
        ; (pacification already applied, intent already committed), fall back to the same Scene-free path
        ; ARREST_TYPE_TELEPORT_TO_CELL already uses (DeclareArrestSuccess + MoveToPrison(abMoveDirectlyToCell = true),
        ; see BeginArrest's own teleport branch) instead of undoing the arrest outright. Applies uniformly whether this
        ; was an Escort-to-Jail or Escort-to-Cell request - once witnessing anything is off the table, the simplest
        ; safe outcome is to finish the job, not preserve the jail-first distinction. No separate cleanup needed here:
        ; AwaitConfrontationScene's own give-up path already calls ForceResetSceneState() before returning false.
        DebugWarn("["+ Name +"] Arrestee::EscortToPrison", "Confrontation Scene never confirmed for " + Name + " - falling back to a direct teleport-to-cell arrest instead of reverting")
        self.DeclareArrestSuccess()
        self.MoveToPrison(abMoveDirectlyToCell = true)
        return
    endif

    self.DeclareArrestSuccess()

    RPB_Prisoner prisoner   = self.MakePrisoner()
    RPB_Prison prison       = prisoner.Prison

    bool hasAssignedCell = prisoner.AssignCell()

    if (!hasAssignedCell)
        prison.OnPrisonerImprisonmentFail(prisoner, "Assign Cell")
        self.RevertArrest()
        return
    endif

    if (!abEscortDirectlyToCell)
        prisoner.EscortToJail(Captor.GetActor())
    else
        prisoner.EscortToCell(Captor.GetActor())
    endif
endFunction

function MoveToPrison(bool abMoveDirectlyToCell = false)
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

event OnUpdate()
    ; The hostile-faction re-check that used to live here (MaintainArrestPacification) was mitigating a symptom -
    ; a disguise mod reapplying a hostile faction mid-escort - of what turned out to be RPB checking the wrong faction
    ; entirely (see RPB_Compat_MasterOfDisguise.psc). With the actual root cause fixed, this per-tick recheck was no
    ; longer earning its keep: every arrestee paid a per-tick cost for a problem that no longer exists, and I'm trying
    ; to keep OnUpdate usage to what's actually necessary, not run it "just in case" - it's real overhead multiplied by
    ; however many arrestees are being escorted at once, and a script left registered is exactly what bloats a save.
    ; The guard-wedge nudge that briefly lived here too (round 3) doesn't belong in a recurring check either - it only
    ; ever needs to happen once, right as the confrontation ends (see OnArrestEnd()), not re-evaluated against normal
    ; walking proximity every 5s for the rest of a potentially long escort.
    if (this.GetDistance(Captor.GetActor()) >= 700)
        this.MoveTo(Captor.GetActor())
        Debug("["+ Name +"] Arrestee::OnUpdate", "Moved Arrestee to " + Captor.Name)
    endif

    RegisterForSingleUpdate(5.0)
endEvent

; ==========================================================
;                           Management
; ==========================================================

function Destroy()
    ; Unset all properties related to this Arrestee
    ; Stop the escort loop first (OnUpdate reads the Captor, which RemoveAll deletes). This used to be a blind
    ; Utility.Wait(0.5) between RemoveAll and UnregisterArrestee, which blocked every imprisonment for half a second.
    if (self.IsEffectActive) ; on a dead effect the native errors out (no native object bound)
        UnregisterForUpdate()
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

