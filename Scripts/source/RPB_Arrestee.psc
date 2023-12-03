Scriptname RPB_Arrestee extends RPB_Actor

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

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
Actor captor

;/
    The Arresting Faction to this Arrestee (The faction that arrested this Actor).
    The value is set through SetArrestParameters().
/;
Faction arrestFaction

;/
    The Hold of where the arrest took place (usually this is the Faction name, but it might not be!)
    The value is set through SetArrestParameters().
/;
string hold

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
string arrestType

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
        return Arrest_GetFloat("Time of Arrest")
    endFunction
endProperty

float property TimeArrested
    float function get()
        return CurrentTime - TimeOfArrest
    endFunction
endProperty

bool property Defeated
    bool function get()
        return Arrest_GetBool("Defeated")
    endFunction
endProperty

int property DefeatedBounty
    int function get()
        return Arrest_GetInt("Bounty for Defeat")
    endFunction
endProperty

function Frisk()
    
endFunction

function AssignCaptor(Actor akCaptor)
    ArrestVars.SetReference("Arrest::Arresting Guard", akCaptor)
endFunction

function SetArrestParameters(string asArrestType, Actor akCaptor, Faction akCrimeFaction)
    if (akCaptor)
        akCrimeFaction = akCaptor.GetCrimeFaction()
        self.AssignCaptor(akCaptor)
        ; Debug(none, "Arrestee::SetArrestParameters", "Arrest is being done through a captor ("+ akCaptor +")")

        ; Temporary
        BindAliasTo(Arrest.CaptorRef, akCaptor)
        Arrest.CaptorRef.AssignArrestee(this)
    endif

    if (!akCrimeFaction)
        Error(none, "Arrestee::SetArrestParameters", "Both the captor and faction are none, cannot proceed with the arrest! (returning...)")
        return
    endif

    ; Set arrest related vars to this Arrestee's state
    captor          = akCaptor
    arrestFaction   = akCrimeFaction
    hold            = akCrimeFaction.GetName()
    arrestType      = asArrestType

    Arrest_SetForm("Arrest Faction", arrestFaction)
    Arrest_SetForm("Arrestee", this)
    Arrest_SetString("Arrest Type", arrestType)
    Arrest_SetString("Hold", hold)

    ; Trace(none, "Arrestee::SetArrestParameters", "[\n" + \ 
    ;     "\tCaptured: "+ ArrestVars.GetBool("Arrest::Captured") +" \n" + \
    ;     "\tArrest Faction: "+ ArrestVars.GetForm("Arrest::Arrest Faction") +"\n" + \
    ;     "\tHold: "+ ArrestVars.GetString("Arrest::Hold") +"\n" + \
    ;     "\tArrestee: "+ ArrestVars.GetForm("Arrest::Arrestee") +"\n" + \
    ;     "\tArrest Type: "+ ArrestVars.GetString("Arrest::Arrest Type") +"\n" + \
    ; "]")
endFunction

function Free()
    self.ResetArrest()
    Arrest.OnArresteeFreed(this, captor)
endFunction

;/
    Releases this arrestee from custody
/;
function Release()
    self.ResetArrest()
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
    Debug(this, "Arrestee::Uncuff", "Uncuffed " + this)
endFunction

;/
    Transfers this Actor from being an Arrestee to a Prisoner

    This function should probably return a type of RPB_Prisoner with
    prisoner related methods where the reference to the Actor is obtained
    and then clear them from being an Arrestee (delete ref to this instance)
/;
RPB_Prisoner function MakePrisoner()
    ; Get the prison for this arrestee
    RPB_PrisonManager prisonManager = GetFormFromMod(0x1B825) as RPB_PrisonManager
    RPB_Prison prison               = prisonManager.GetPrison(hold)


    ; Mark this actor as a Prisoner (Cast the spell on them to have access to Prisoner related functions and state)
    prison.MarkActorAsPrisoner(this)
    Utility.Wait(0.1)
    RPB_Prisoner prisonerRef = prison.GetPrisonerReference(this)
    ; debug.messagebox("Prison: " + prison + ", Hold: " + hold + ", Actor: " + this + ", PrisonerRef: " + prisonerRef)

    ; TODO: Remove arrest reference possibly
    ; self.Destroy() ; To be tested
    return prisonerRef
endFunction

bool function ShouldPayBounty()
    return Arrest.GetArrestGoal(this) == Arrest.ARREST_GOAL_BOUNTY_PAYMENT
endFunction

int function GetDefeatedBounty()
    return Vars_GetInt("Bounty for Defeat", "Arrest")
endFunction

function PayCrimeGold()
    int currentBountyNonViolent = Arrest_GetInt("Bounty Non-Violent")
    int currentBountyViolent    = Arrest_GetInt("Bounty Violent")
    int totalBounty             = currentBountyNonViolent + currentBountyViolent

    Form gold = Game.GetFormEx(0xF)
    this.RemoveItem(gold, totalBounty, true)

    Arrest_Remove("Bounty Non-Violent")
    Arrest_Remove("Bounty Violent")

    if (this == Config.Player)
        arrestFaction.PlayerPayCrimeGold(false, false)
        Config.NotifyArrest("Your bounty in " + hold + " has been paid")
    endif
endFunction

; Same as PayCrimeGold(), used for convenience
function PayBounty()
    self.PayCrimeGold()
endFunction

;/
    Adds the bounty gained while this Arrestee is in custody, this function is
    most likely temporary
/;
function AddBountyGainedWhileJailed()
    ArrestVars.ModInt("Jail::Bounty Non-Violent",   self.GetActiveBounty(true, false))
    ArrestVars.ModInt("Jail::Bounty Violent",       self.GetActiveBounty(false, true))
    ClearBounty(arrestFaction)
endFunction

function SetArrestTime()
    Arrest_SetBool("Arrested", true)
    Arrest_SetBool("Captured", true) ; Used to avoid further arrest resists after being arrested
    Arrest_SetFloat("Time of Arrest", CurrentTime)

    Config.NotifyArrest("You have been arrested in " + hold, this == Config.Player)
    Config.NotifyArrest(self.GetName() + " has been arrested in " + hold, this != Config.Player)
    Info(none, "Arrestee::SetArrestTime", this.GetBaseObject().GetName() + " has been arrested in " + hold + " at " + CurrentTime)
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
    Arrest_Remove("Arrest Faction")
    Arrest_Remove("Arrestee") ; Might be temp, we already have the Arrestee reference through this instance of RPB_Arrestee
    Arrest_Remove("Arrest Type")
    Arrest_Remove("Arrest Scene")
    Arrest_Remove("Hold")
    Arrest_Remove("Arrested")
    Arrest_Remove("Arresting Guard")
    Arrest_Remove("Captured")
    Arrest_Remove("Scenario")
    Arrest_Remove("Time of Arrest")

    Utility.Wait(0.5)
    self.Destroy()
endFunction

function ResetArrest()
    self.RestoreBounty()
    ArrestVars.RemoveForActor(this, "Arrest::Arrest Faction")
    ArrestVars.RemoveForActor(this, "Arrest::Arrest Scene")
    ArrestVars.RemoveForActor(this, "Arrest::Arrest Type")
    ArrestVars.RemoveForActor(this, "Arrest::Arrested")
    ArrestVars.RemoveForActor(this, "Arrest::Arrestee")
    ArrestVars.RemoveForActor(this, "Arrest::Arresting Guard")
    ArrestVars.RemoveForActor(this, "Arrest::Captured")
    ArrestVars.RemoveForActor(this, "Arrest::Hold")
    ArrestVars.RemoveForActor(this, "Arrest::Scenario")
    ArrestVars.RemoveForActor(this, "Arrest::Time of Arrest")
endFunction

; ==========================================================
;                           Scenes
; ==========================================================

function Arrest()
    Debug(this, "Arrestee::Arrest", "Arrested " + this)

    self.SetArrestGoal(Arrest.ARREST_GOAL_IMPRISONMENT)
    self.UpdateArrestStats()
    self.SetTimeOfArrest()

    Config.NotifyArrest("You have been arrested in " + hold, this == Config.Player)
    Info(none, "Arrestee::Arrest", this.GetBaseObject().GetName() + " has been arrested in " + hold + " at " + CurrentTime)

    ; Arrest.SceneManager.StartArrestScene( \
    ;     akGuard     = captor, \
    ;     akArrestee  = this, \
    ;     asScene     = Arrest.GetArrestScene(this) \
    ; )

    Arrest.OnActorArrested(this, captor)
endFunction

function EscortToPrison(bool abEscortDirectlyToCell = false)
    Arrest.SceneManager.StartArrestScene( \
        akGuard     = captor, \
        akArrestee  = this, \
        asScene     = Arrest.GetArrestScene(this) \
    )

    if (!abEscortDirectlyToCell)
        Debug(this, "Arrestee::EscortToPrison", "Started escorting " + this + " to prison")
        ArrestVars.SetReference("Jail::Prisoner Items Container", Config.GetJailPrisonerItemsContainer(hold) as ObjectReference) ; Temporary, later another location should be used for taking to prison
        Arrest.SceneManager.StartEscortToJail( \
            akEscortLeader      = captor, \
            akEscortedPrisoner  = this, \
            akPrisonerChest     = ArrestVars.GetReference("Jail::Prisoner Items Container") \
        )
    else
        ; Make this arrestee a prisoner right away
        RPB_Prisoner prisonerRef = self.MakePrisoner()
        if (!prisonerRef.AssignCell())
            Debug(this, "Arrestee::EscortToPrison", "Could not assign a cell to arrestee " + this)
            self.RevertArrest()
            return
        endif

        Debug(this, "Arrestee::EscortToPrison", "Started escorting " + this + " directly to a cell")
        Arrest.SceneManager.StartEscortToCell( \
            akEscortLeader      = captor, \
            akEscortedPrisoner  = prisonerRef.GetActor(), \
            akJailCellMarker    = prisonerRef.GetCell(), \
            akJailCellDoor      = prisonerRef.GetCellDoor() \ 
        )
    endif
endFunction

function MoveToPrison(bool abMoveDirectlyToCell = false)
    ; Arrest.SceneManager.StartArrestScene( \
    ;     akGuard     = captor, \
    ;     akArrestee  = this, \
    ;     asScene     = Arrest.GetArrestScene(this) \
    ; )
    ; Utility.Wait(6.0)
    if (!abMoveDirectlyToCell)
        Debug(this, "Arrestee::MoveToPrison", "Moving " + this + " to prison")
        ArrestVars.SetReference("Jail::Prisoner Items Container", Config.GetJailPrisonerItemsContainer(hold) as ObjectReference) ; Temporary, later another location should be used for taking to prison
        ObjectReference prisonerChest = ArrestVars.GetReference("Jail::Prisoner Items Container")
        this.MoveTo(prisonerChest)
        captor.MoveTo(prisonerChest)
    else
        RPB_Prisoner prisonerRef = self.MakePrisoner()

        if (!prisonerRef.AssignCell())
            Debug(this, "Arrestee::MoveToPrison", "Could not assign a cell to arrestee " + this)
            ; Terminate arrest, could not assign cell
            prisonerRef.Destroy()
            self.RevertArrest()
            return
        endif

        prisonerRef.MoveToCell()
    endif
endFunction

function ChangeEscort(Actor akNewEscort)
    Arrest_SetReference("Arresting Guard", akNewEscort)
    ; Arrest.RegisterCaptor() || Arrest.MarkActorAsCaptor(akNewEscort)
    Arrest.SceneManager.StartEscortToJail( \
        akEscortLeader      = akNewEscort, \
        akEscortedPrisoner  = this, \
        akPrisonerChest     = ArrestVars.PrisonerItemsContainer \
    )
endFunction

; ==========================================================
;                            Utility
; ==========================================================

function SetTimeOfArrest()
    Arrest_SetBool("Arrested", true)
    Arrest_SetBool("Captured", true) ; Used to avoid further arrest resists after being arrested, may change name or implementation
    Arrest_SetFloat("Time of Arrest", CurrentTime)

    self.IncrementStat("Times Arrested")
endFunction

function UpdateCurrentBounty()
    self.SetStat("Current Bounty", Bounty)

    ; Debug(this, "Arrestee::UpdateCurrentBounty", "[\n" + \ 
    ;     "\t Current Bounty: " + self.QueryStat("Current Bounty") + "\n" + \
    ;     "\t Bounty: " + Bounty + "\n" + \
    ; "]")   
endFunction

function UpdateLargestBounty()
    int currentLargestBounty = self.QueryStat("Largest Bounty")
    int newLargestBounty = int_if (currentLargestBounty < Bounty, Bounty, currentLargestBounty)

    self.SetStat("Largest Bounty", newLargestBounty)

    ; Debug(this, "Arrestee::UpdateLargestBounty", "[\n" + \ 
    ;     "\t Current Longest Bounty: " + currentLargestBounty + "\n" + \
    ;     "\t New Longest Bounty: " + newLargestBounty + "\n" + \
    ;     "\t Bounty: " + Bounty + "\n" + \
    ; "]")    
endFunction

function UpdateTotalBounty()
    self.IncrementStat("Total Bounty", Bounty)
endFunction

function MoveToCaptor()
    this.MoveTo(captor)
endFunction

; ==========================================================
;                           Events
; ==========================================================

event OnInitialize()
    Arrest.RegisterArrestedActor(self, this)
    ; Debug(this, "Arrestee::OnInitialize", "Initialized Arrestee, this: " + this)

    self.RegisterForTrackedStats()
endEvent

event OnDestroy()
    Arrest.UnregisterArrestedActor(this) ; Remove this Actor from the AME list since they are no longer arrested
    Arrest.UnregisterArrestee(self) ; remove the spell
    self.UnregisterForTrackedStats()
endEvent

event OnBountyGained()
    self.HideBounty()
    self.UpdateCurrentBounty()
    self.UpdateLargestBounty()
    self.UpdateTotalBounty()
endEvent

event OnStatChanged(string asStatName, int aiValue)
    if (asStatName == hold + " Bounty") ; If there's bounty gained in the current arrest hold
        self.OnBountyGained()
    endif

    ; Debug(this, "Arrestee::OnStatChanged", "Stat " + asStatName + " has been changed to " + aiValue)
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    
endEvent

event OnDeath(Actor akKiller)
    Arrest.OnArresteeDeath(this, captor, akKiller)
endEvent

; ==========================================================
;                           Management
; ==========================================================

function Destroy()
    ; TODO: Unset all properties related to this Arrestee

    Arrest.UnregisterArrestedActor(this)
endFunction

; ==========================================================
;                      -- Arrest Vars --
;                           Getters
bool function Arrest_GetBool(string asVarName, string asVarCategory = "Arrest")
    return parent.Vars_GetBool(asVarName, asVarCategory)
endFunction

int function Arrest_GetInt(string asVarName, string asVarCategory = "Arrest")
    return parent.Vars_GetInt(asVarName, asVarCategory)
endFunction

float function Arrest_GetFloat(string asVarName, string asVarCategory = "Arrest")
    return parent.Vars_GetFloat(asVarName, asVarCategory)
endFunction

string function Arrest_GetString(string asVarName, string asVarCategory = "Arrest")
    return parent.Vars_GetString(asVarName, asVarCategory)
endFunction

Form function Arrest_GetForm(string asVarName, string asVarCategory = "Arrest")
    return parent.Vars_GetForm(asVarName, asVarCategory)
endFunction

ObjectReference function Arrest_GetReference(string asVarName, string asVarCategory = "Arrest")
    return parent.Vars_GetReference(asVarName, asVarCategory)
endFunction

Actor function Arrest_GetActor(string asVarName, string asVarCategory = "Arrest")
    return parent.Vars_GetActor(asVarName, asVarCategory)
endFunction
;                          Setters
function Arrest_SetBool(string asVarName, bool abValue, string asVarCategory = "Arrest")
    parent.Vars_SetBool(asVarName, abValue, asVarCategory)
endFunction

function Arrest_SetInt(string asVarName, int aiValue, string asVarCategory = "Arrest")
    parent.Vars_SetInt(asVarName, aiValue, asVarCategory)
endFunction

function Arrest_ModInt(string asVarName, int aiValue, string asVarCategory = "Arrest")
    parent.Vars_ModInt(asVarName, aiValue, asVarCategory)
endFunction

function Arrest_SetFloat(string asVarName, float afValue, string asVarCategory = "Arrest")
    parent.Vars_SetFloat(asVarName, afValue, asVarCategory)
endFunction

function Arrest_ModFloat(string asVarName, float afValue, string asVarCategory = "Arrest")
    parent.Vars_ModFloat(asVarName, afValue, asVarCategory)
endFunction

function Arrest_SetString(string asVarName, string asValue, string asVarCategory = "Arrest")
    parent.Vars_SetString(asVarName, asValue, asVarCategory)
endFunction

function Arrest_SetForm(string asVarName, Form akValue, string asVarCategory = "Arrest")
    parent.Vars_SetForm(asVarName, akValue, asVarCategory)
endFunction

function Arrest_SetReference(string asVarName, ObjectReference akValue, string asVarCategory = "Arrest")
    parent.Vars_SetReference(asVarName, akValue, asVarCategory)
endFunction

function Arrest_SetActor(string asVarName, Actor akValue, string asVarCategory = "Arrest")
    parent.Vars_SetActor(asVarName, akValue, asVarCategory)
endFunction

function Arrest_Remove(string asVarName, string asVarCategory = "Arrest")
    parent.Vars_Remove(asVarName, asVarCategory)
endFunction

; ==========================================================

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
    return captor
endFunction

Faction function GetFaction()
    return arrestFaction
endFunction

string function GetHold()
    return hold
endFunction

string function GetArrestType()
    return arrestType
endFunction

