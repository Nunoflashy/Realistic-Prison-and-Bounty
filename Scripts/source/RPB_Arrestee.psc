Scriptname RPB_Arrestee extends RPB_ActorBase

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
    this must be refactored to decide which one to choose.
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
    __hold          = akCrimeFaction.GetName()
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

function Cuff()
    ; this.SheatheWeapon()
    ; UnequipHandsForActor(this)

    ; self.EquipItem(RPB_Utility.RPB_PrisonerHandCuffs(), true)
    ; self.PlayAnimation("OffsetBoundStandingPlayerInstant")
    ; Utility.Wait(5.0)
    ; self.PlayAnimation("OffsetBoundStandingPlayerInstant")
    ; return
    ; Form cuffs = Game.GetFormEx(0xA081D33) ; Front

    ; Form cuffs = Game.GetFormEx(0xA081D2F) ; Back
    Form cuffs = Game.GetFormFromFile(0x81D2F, "ZaZAnimationPack.esm")

    this.SheatheWeapon()
    UnequipHandsForActor(this)
    this.EquipItem(cuffs, true, true)
endFunction

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

    Utility.Wait(0.5)
    self.Destroy()
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

    Config.NotifyArrest("You have been arrested in " + Hold, self.IsPlayer())
    Info(self.Name + " has been arrested in " + Hold + " at " + CurrentTime)
    ; Debug("Arrestee::Arrest", self.Name + " has been arrested in " + Hold + " at " + CurrentTime)

    Arrest.OnActorArrested(self, Captor)
endFunction

function EscortToPrison(bool abEscortDirectlyToCell = false)
    string sceneSet = string_if (self.GetString("Scene"), self.GetString("Scene"), Arrest.SceneManager.SCENE_ARREST_START_02)
    SceneManager.StartArrestScene( \
        akGuard     = Captor.GetActor(), \
        akArrestee  = this, \
        asScene     = sceneSet \
    )

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
    RPB_Prison prison       = prisoner.Prison

    bool hasAssignedCell = prisoner.AssignCell()

    if (abMoveDirectlyToCell)
        if (!hasAssignedCell)
            prisoner.OnImprisonmentFail("Assign Cell")
            self.OnArrestFailed("Assign Cell")
            return
        endif

        prisoner.MoveToCell()
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
    
endEvent

event OnArrestEnd()
    Debug("Arrest::OnArrestEnd", "Arrest, captor should be escorting now")

    ; Captor.SetEscorting()
    
    RegisterForSingleUpdate(1.0)
endEvent

event OnArrestFailed(string asReason)
    if (asReason == "Assign Cell")
        ; Destroy anything related to RPB_Prisoner here (need to find a way to get the reference)
    endif

    self.RevertArrest()
endEvent

event OnUpdate()
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
    self.RemoveAll()
    Utility.Wait(0.5)
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

