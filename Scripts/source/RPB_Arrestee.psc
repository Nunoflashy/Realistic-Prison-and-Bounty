Scriptname RPB_Arrestee extends RPB_Actor

import RPB_Utility
import RPB_Config

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

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return API.Arrest
    endFunction
endProperty

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
Actor __captor
Actor property Captor
    Actor function get()
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

; ==========================================================
;                          Properties
; ==========================================================

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
    return (RPB_API.GetArrest()).GetArresteeReference(apPrisoner.GetActor())
endFunction

function Frisk()
    
endFunction

function AssignCaptor(Actor akCaptor)
    SetReference("Arresting Guard", akCaptor)
endFunction

function SetArrestParameters(string asArrestType, Actor akCaptor, Faction akCrimeFaction)
    Debug("Arrestee::SetArrestParameters", "akCaptor: " + akCaptor + ", akCrimeFaction: " + akCrimeFaction)
    if (akCaptor)
        akCrimeFaction = akCaptor.GetCrimeFaction()
        self.AssignCaptor(akCaptor)
        ; Debug(none, "Arrestee::SetArrestParameters", "Arrest is being done through a captor ("+ akCaptor +")")

        ; Temporary
        ; BindAliasTo(Arrest.CaptorRef, akCaptor)
        ; Arrest.CaptorRef.AssignArrestee(this)
    endif

    if (!akCrimeFaction)
        Error("Both the captor and faction are none, cannot proceed with the arrest! (returning...)")
        DebugError("Arrestee::SetArrestParameters", "Both the captor and faction are none, cannot proceed with the arrest! (returning...)")
        self.Destroy()
        return
    endif

    ; Set arrest related vars to this Arrestee's state
    __captor        = akCaptor
    __arrestFaction = akCrimeFaction
    __hold          = akCrimeFaction.GetName()
    __arrestType    = asArrestType

    SetForm("Arrest Faction", ArrestFaction)
    SetForm("Arrestee", this)
    SetString("Arrest Type", ArrestType)
    SetString("Hold", Hold)

    ; Trace(none, "Arrestee::SetArrestParameters", "[\n" + \ 
    ;     "\tCaptured: "+ ArrestVars.GetBool("Arrest::Captured") +" \n" + \
    ;     "\tArrest Faction: "+ ArrestVars.GetForm("Arrest::Arrest Faction") +"\n" + \
    ;     "\tHold: "+ ArrestVars.GetString("Arrest::Hold") +"\n" + \
    ;     "\tArrestee: "+ ArrestVars.GetForm("Arrest::Arrestee") +"\n" + \
    ;     "\tArrest Type: "+ ArrestVars.GetString("Arrest::Arrest Type") +"\n" + \
    ; "]")
endFunction

function Free()
    Arrest.OnArresteeFreed(this, Captor)
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
    Form cuffs = Game.GetFormEx(0xA081D33)
    this.SheatheWeapon()
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
    RPB_Prison prison  = (RPB_API.GetPrisonManager()).GetPrison(Hold)
    self.TransferArrestPropertiesToPrisoner(prison)

    return prison.MakePrisoner(this)
endFunction

function TransferArrestPropertiesToPrisoner(RPB_Prison apPrison)
    self.SetFloat("Time of Arrest", TimeOfArrest, "Jail")
    self.SetInt("Minute of Arrest", GetInt("Minute of Arrest"), "Jail")
    self.SetInt("Hour of Arrest", GetInt("Hour of Arrest"), "Jail")
    self.SetInt("Day of Arrest", GetInt("Day of Arrest"), "Jail")
    self.SetInt("Month of Arrest", GetInt("Month of Arrest"), "Jail")
    self.SetInt("Year of Arrest", GetInt("Year of Arrest"), "Jail")
    ; self.SetInt("Bounty Non-Violent", GetInt("Bounty Non-Violent"), "Jail")
    ; self.SetInt("Bounty Violent", GetInt("Bounty Violent"), "Jail")
    self.SetForm("Arrest Captor", Captor, "Jail")
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

function UpdateArrestStats()
    self.UpdateCurrentBounty()
    self.UpdateLargestBounty()
    self.UpdateTotalBounty()
endFunction

function RevertArrest()
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
    self.UpdateArrestStats()
    self.SetTimeOfArrest()

    SetBool("Arrested", true)
    SetBool("Captured", true) ; Used to avoid further arrest resists after being arrested, may change name or implementation
    self.IncrementStat("Times Arrested")
    
    ; Arrest.SceneManager.StartArrestScene( \
    ;     akGuard     = Captor, \
    ;     akArrestee  = this, \
    ;     asScene     = Arrest.GetArrestScene(this) \
    ; )

    Config.NotifyArrest("You have been arrested in " + Hold, this == Config.Player)
    Info(self.Name + " has been arrested in " + Hold + " at " + CurrentTime)
    Debug("Arrestee::Arrest", self.Name + " has been arrested in " + Hold + " at " + CurrentTime)

    Arrest.OnActorArrested(this, Captor)
endFunction

function EscortToPrison(bool abEscortDirectlyToCell = false)
    ; Arrest.SceneManager.StartArrestScene( \
    ;     akGuard     = Captor, \
    ;     akArrestee  = this, \
    ;     asScene     = Arrest.GetArrestScene(this) \
    ; )

    Arrest.SceneManager.StartArrestScene( \
        akGuard     = Captor, \
        akArrestee  = this, \
        asScene     = Arrest.SceneManager.SCENE_ARREST_START_02 \
    )

    Debug("Arrestee::EscortToPrison", "Captor: " + Captor + ", this: " + this + ", Arrest Scene: " + Arrest.GetArrestScene(this))

    if (!abEscortDirectlyToCell)
        Debug("Arrestee::EscortToPrison", "Started escorting " + this + " to prison")
        ; Make this arrestee a prisoner right away
        RPB_Prisoner prisonerRef = self.MakePrisoner()

        prisonerRef.SetBelongingsContainer()  ; Temporary, later another location should be used for taking to prison

        if (!prisonerRef.AssignCell())
            Debug("Arrestee::EscortToPrison", "Could not assign a cell to arrestee " + this)
            self.RevertArrest()
            return
        endif

        self.SetStateForScene("OnEscortToJailEnd", "EscortToJail")

        Arrest.SceneManager.StartEscortToJail( \
            akEscortLeader      = Captor, \
            akEscortedPrisoner  = this, \
            akPrisonerChest     = prisonerRef.PrisonerBelongingsContainer \
        )
    else
        ; Make this arrestee a prisoner right away
        RPB_Prisoner prisonerRef = self.MakePrisoner()
        if (!prisonerRef.AssignCell())
            Debug("Arrestee::EscortToPrison", "Could not assign a cell to arrestee " + this)
            self.RevertArrest()
            return
        endif

        ; return
        Debug("Arrestee::EscortToPrison", "Started escorting " + this + " directly to a cell")
        ; The marker where the escort will stand, waiting for the prisoner to enter the cell.
        ObjectReference outsideJailCellEscortWaitingMarker = prisonerRef.JailCell.GetRandomMarker("Exterior") as ObjectReference

        Arrest.SceneManager.StartEscortToCell( \
            akEscortLeader                  = Captor, \
            akEscortedPrisoner              = prisonerRef.GetActor(), \
            akJailCellMarker                = prisonerRef.JailCell, \
            akJailCellDoor                  = prisonerRef.JailCell.CellDoor, \
            akEscortWaitingMarker           = outsideJailCellEscortWaitingMarker \ 
        )
    endif
endFunction

function MoveToPrison(bool abMoveDirectlyToCell = false)
    ; Arrest.SceneManager.StartArrestScene( \
    ;     akGuard     = Captor, \
    ;     akArrestee  = this, \
    ;     asScene     = Arrest.GetArrestScene(this) \
    ; )
    ; Utility.Wait(6.0)
    RPB_Prisoner prisonerRef = self.MakePrisoner()
    RPB_Prison prison        = prisonerRef.Prison
    prisonerRef.IsUndeterminedSentence = false

    if (!abMoveDirectlyToCell)
        prisonerRef.MoveToPrison(Captor)
        ; Later when RPB_Captor is done, we should call it like
        ; captorRef.MoveToPrison(prison) or captorRef.MoveToPrison() in case a Prison is associated with that Captor already, which probably should be
        Debug("Arrestee::MoveToPrison", "Moving " + this + " to prison")
    else
        if (!prisonerRef.AssignCell())
            ; Terminate arrest, could not assign cell
            prisonerRef.Destroy()
            self.RevertArrest()
            return
        endif

        prisonerRef.MoveToCell()
    endif

    prison.OnPrisonerMovedToPrison(prisonerRef, abMoveDirectlyToCell)
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

function UpdateCurrentBounty()
    self.SetStat("Current Bounty", Bounty)
    Debug("Arrestee::UpdateCurrentBounty", "[\n" + \ 
        "\t Current Bounty: " + self.QueryStat("Current Bounty") + "\n" + \
        "\t Bounty: " + Bounty + "\n" + \
    "]")   
endFunction


function UpdateLargestBounty()
    parent.SyncLargestBountyForFaction(ArrestFaction)
endFunction

function UpdateTotalBounty()
    parent.SyncTotalBountyForFaction(ArrestFaction)
endFunction

function MoveToCaptor()
    this.MoveTo(Captor)
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
    Debug("Arrestee::OnInitialize", "Initialized Arrestee, this: " + this)

    self.RegisterForTrackedStats()
endEvent

event OnDestroy()
    Arrest.RemoveArresteeFromList(self) ; Remove this Actor from the AME list since they are no longer arrested
    self.UnregisterForTrackedStats()

    if (self.IsPlayer())
        ; If for some reason AI is enabled, disable it
        ReleaseAI()
    endif
endEvent

event OnBountyGained()
    self.HideBounty()
    ; self.UpdateCurrentBounty()
    self.UpdateLargestBounty()
    self.UpdateTotalBounty()
endEvent

event OnStatChanged(string asStatName, float afValue)
    if (asStatName == Hold + " Bounty") ; If there's bounty gained in the current arrest hold
        self.OnBountyGained()
    endif

    ; Debug("Arrestee::OnStatChanged", "Stat " + asStatName + " has been changed to " + afValue)
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    
endEvent

event OnDeath(Actor akKiller)
    Arrest.OnArresteeDeath(this, Captor, akKiller)
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

Actor function GetCaptor()
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

