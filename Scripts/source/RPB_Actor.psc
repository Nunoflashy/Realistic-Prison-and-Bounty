scriptname RPB_Actor extends ActiveMagicEffect
{Base Actor script for RPB_Actor, must be inherited from to be used}

import RPB_Utility
import RPB_Config

; ==========================================================
;                      Script References
; ==========================================================

RPB_Config property Config
    RPB_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RPB_Config
    endFunction
endProperty

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return Config.Arrest
    endFunction
endProperty

; ==========================================================
;                       Actor Related
; ==========================================================

string property Name
    string function get()
        return self.GetName()
    endFunction
endProperty

string property Sex
    string function get()
        return self.GetSex()
    endFunction
endProperty

bool property IsFemale
    bool function get()
        return this.GetActorBase().GetSex() == 1
    endFunction
endProperty

bool property IsMale
    bool function get()
        return this.GetActorBase().GetSex() == 0
    endFunction
endProperty

; ==========================================================

function AddSpell(Spell akSpell, bool abVerbose = true)
    this.AddSpell(akSpell, abVerbose)
endFunction

function RemoveSpell(Spell akSpell)
    this.RemoveSpell(akSpell)
endFunction

bool function HasSpell(Spell akSpell)
    return this.HasSpell(akSpell)
endFunction

function RemoveItem(Form akItemToRemove, int aiCount = 1, bool abSilent = true, ObjectReference akOtherContainer = none)
    this.RemoveItem(akItemToRemove, aiCount, abSilent, akOtherContainer)
endFunction

function StopCombat(bool abStopCombatAlarm = true)
    this.StopCombat()

    if (abStopCombatAlarm)
        this.StopCombatAlarm()
    endif
endFunction

function MoveTo(ObjectReference akTarget, float afXOffset = 0.0, float afYOffset = 0.0, float afZOffset = 0.0, bool abMatchRotation = true)
    this.MoveTo(akTarget, afXOffset, afYOffset, afZOffset, abMatchRotation)
    Debug("Actor::MoveTo", "Moved " + self.Name + " to " + akTarget)
endFunction

string function GetSex(bool abShortValue = false)
    if (self.IsFemale)
        return string_if (abShortValue, "F", "Female")
    elseif (self.IsMale)
        return string_if (abShortValue, "M", "Male")
    endif
endFunction

; ==========================================================
;                          Clothing
; ==========================================================

bool function IsNaked()
    ; TOOD: Logic to determine when the actor is naked
endFunction

bool function IsInUnderwear()
    ; TOOD: Logic to determine when the actor is only wearing underwear
endFunction

; ==========================================================
;                           Bounty
; ==========================================================

bool function HasActiveBounty()
    if (self.IsPlayer())
        return self.GetFaction().GetCrimeGold() > 0
    else
        return RPB_ActorVars.GetCrimeGold(self.GetFaction(), this) > 0
    endif
endFunction

bool function HasLatentBounty()
    return (GetInt("Bounty Non-Violent", "Arrest") + GetInt("Bounty Violent", "Arrest")) > 0
endFunction

function SetActiveBounty(int aiBounty)
    self.SetCrimeGold(aiBounty)
endFunction

function SetActiveViolentBounty(int aiBounty)
    self.SetCrimeGoldViolent(aiBounty)
endFunction

;/
    Gets the active bounty for this Actor, that is, the bounty that is currently set on a Faction when
    the Actor is wanted by that Faction.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetActiveBounty(bool abNonViolent = true, bool abViolent = true)
    int totalBounty = 0
    
    if (abNonViolent)
        totalBounty += int_if (self.IsPlayer(), self.GetFaction().GetCrimeGoldNonViolent(), RPB_ActorVars.GetCrimeGoldNonViolent(self.GetFaction(), this))
        ; totalBounty += int_if (self.IsPlayer(), self.GetFaction().GetCrimeGoldNonViolent(), ActorVars.GetCrimeGoldNonViolent(self.GetFaction(), this))
        ; RPB_Utility.Debug("Actor::GetActiveBounty", "Bounty Non-Violent: " + totalBounty)
    endif

    if (abViolent)
        totalBounty += int_if (self.IsPlayer(), self.GetFaction().GetCrimeGoldViolent(), RPB_ActorVars.GetCrimeGoldViolent(self.GetFaction(), this))
        ; totalBounty += int_if (self.IsPlayer(), self.GetFaction().GetCrimeGoldViolent(), ActorVars.GetCrimeGoldViolent(self.GetFaction(), this))
        ; RPB_Utility.Debug("Actor::GetActiveBounty", "Bounty Violent: " + totalBounty)
    endif

    ; RPB_Utility.Debug("Actor::GetActiveBounty", "Total Bounty: " + totalBounty)
    return totalBounty
endFunction

;/
    Gets the latent bounty for this Actor, that is, the bounty that is stored when Arrested/Jailed.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetLatentBounty(bool abNonViolent = true, bool abViolent = true)
    int totalBounty = 0

    if (abNonViolent)
        totalBounty += GetInt("Bounty Non-Violent", "Arrest")
    endif

    if (abViolent)
        totalBounty += GetInt("Bounty Violent", "Arrest")
    endif

    return totalBounty
endFunction

; Transfers the Active Bounty into the Latent Bounty.
function HideBounty()
    if (self.HasLatentBounty())
        ModInt("Bounty Non-Violent",   self.GetActiveBounty(abViolent = false), "Arrest")
        ModInt("Bounty Violent",       self.GetActiveBounty(abNonViolent = false), "Arrest")
    else
        SetInt("Bounty Non-Violent",   self.GetActiveBounty(abViolent = false), "Arrest")
        SetInt("Bounty Violent",       self.GetActiveBounty(abNonViolent = false), "Arrest")
    endif

    ; if (Defeated && DefeatedBounty > 0)
    ;     Vars_ModInt("Bounty Non-Violent", ArrestVars.DefeatedBounty, "Arrest")
    ; endif

    self.ClearActiveBounty()
endFunction

; Restores the Active Bounty from the Latent Bounty.
function RestoreBounty()
    if (!self.HasLatentBounty())
        return
    endif

    int nonViolent = self.GetLatentBounty(abViolent = false)
    int violent    = self.GetLatentBounty(abNonViolent = false)

    if (self.HasActiveBounty())
        self.ModCrimeGold(nonViolent)
        self.ModCrimeGold(violent, true)
    else
        self.SetCrimeGold(nonViolent)
        self.SetCrimeGoldViolent(violent)
    endif

    self.ClearLatentBounty()
endFunction

;/
    Clears the Latent Bounty for this Actor (The bounty used when Arrested/Jailed).

    bool?   @abNonViolent: Whether to clear non-violent bounty.
    bool?   @abViolent: Whether to clear violent bounty.
/;
function ClearLatentBounty(bool abNonViolent = true, bool abViolent = true)
    if (abNonViolent)
        Remove("Bounty Non-Violent", "Arrest")
    endif

    if (abViolent)
        Remove("Bounty Violent", "Arrest")
    endif
endFunction

;/
    Clears the Active Bounty for this Actor (The bounty when this Actor is wanted by the Faction).

    bool?   @abNonViolent: Whether to clear non-violent bounty.
    bool?   @abViolent: Whether to clear violent bounty.
/;
function ClearActiveBounty(bool abNonViolent = true, bool abViolent = true)
    if (abNonViolent)
        self.SetCrimeGold(0)
    endif

    if (abViolent)
        self.SetCrimeGoldViolent(0)
    endif
endFunction

; ==========================================================
;                          Actor Vars
; ==========================================================

;/
    Queries the given stat for this faction and this Actor.
/;
int function QueryStat(string statName)
    return RPB_ActorVars.GetStat(statName, self.GetFaction(), this)
endFunction

;/
    Sets the given stat for this faction and this Actor.
/;
function SetStat(string statName, int value)
    RPB_ActorVars.SetStat(statName, self.GetFaction(), this, value)
    ; RPB_Actor.SetStat(statName, self.Faction, this, value)

    if (TrackStats)
        self.OnStatChanged(statName, value)
    endif
endFunction

;/
    Increments the given stat by the amount given.
/;
function IncrementStat(string statName, int incrementBy = 1)
    RPB_ActorVars.IncrementStat(statName, self.GetFaction(), this, incrementBy)

    ; RPB_Utility.DebugWithArgs("Actor::IncrementStat", "statName: " + statName + ", incrementBy: " + incrementBy, "Incrementing stat")

    if (TrackStats)
        self.OnStatChanged(statName, self.QueryStat(statName))
    endif
endFunction

;/
    Decrements the given stat by the amount given.
/;
function DecrementStat(string statName, int decrementBy = 1)
    RPB_ActorVars.DecrementStat(statName, self.GetFaction(), this, decrementBy)

    if (TrackStats)
        self.OnStatChanged(statName, self.QueryStat(statName))
    endif
endFunction

function SetCrimeGold(int aiGold)
    if (self.IsPlayer())
        self.GetFaction().SetCrimeGold(aiGold)
    else
        self.SetStat("Bounty Non-Violent", aiGold)
    endif
endFunction

function SetCrimeGoldViolent(int aiGold)
    if (self.IsPlayer())
        self.GetFaction().SetCrimeGoldViolent(aiGold)
    else
        self.SetStat("Bounty Violent", aiGold)
    endif
endFunction

function ModCrimeGold(int aiAmount, bool abViolent = false)
    if (self.IsPlayer())
        self.GetFaction().ModCrimeGold(aiAmount, abViolent)
    else
        self.IncrementStat(string_if (abViolent, "Bounty Violent", "Bounty Non-Violent"), aiAmount)
    endif
endFunction

; ==========================================================
;                     State Storage Vars
; ==========================================================

;                           Getters
bool function GetBool(string asVarName, string asVarCategory = "Actor")
    return RPB_StorageVars.GetBoolOnForm(asVarName, this, asVarCategory)
endFunction

int function GetInt(string asVarName, string asVarCategory = "Actor")
    return RPB_StorageVars.GetIntOnForm(asVarName, this, asVarCategory)
endFunction

float function GetFloat(string asVarName, string asVarCategory = "Actor")
    return RPB_StorageVars.GetFloatOnForm(asVarName, this, asVarCategory)
endFunction

string function GetString(string asVarName, string asVarCategory = "Actor")
    return RPB_StorageVars.GetStringOnForm(asVarName, this, asVarCategory)
endFunction

Form function GetForm(string asVarName, string asVarCategory = "Actor")
    return RPB_StorageVars.GetFormOnForm(asVarName, this, asVarCategory)
endFunction

ObjectReference function GetReference(string asVarName, string asVarCategory = "Actor")
    return RPB_StorageVars.GetFormOnForm(asVarName, this, asVarCategory) as ObjectReference
endFunction


;                          Setters
function SetBool(string asVarName, bool abValue, string asVarCategory = "Actor")
    RPB_StorageVars.SetBoolOnForm(asVarName, this, abValue, asVarCategory)
endFunction

function SetInt(string asVarName, int aiValue, string asVarCategory = "Actor")
    RPB_StorageVars.SetIntOnForm(asVarName, this, aiValue, asVarCategory)
endFunction

function ModInt(string asVarName, int aiValue, string asVarCategory = "Actor")
    RPB_StorageVars.ModIntOnForm(asVarName, this, aiValue, asVarCategory)
endFunction

function SetFloat(string asVarName, float afValue, string asVarCategory = "Actor")
    RPB_StorageVars.SetFloatOnForm(asVarName, this, afValue, asVarCategory)
endFunction

function ModFloat(string asVarName, float afValue, string asVarCategory = "Actor")
    RPB_StorageVars.ModFloatOnForm(asVarName, this, afValue, asVarCategory)
endFunction

function SetString(string asVarName, string asValue, string asVarCategory = "Actor")
    RPB_StorageVars.SetStringOnForm(asVarName, this, asValue, asVarCategory)
endFunction

function SetForm(string asVarName, Form akValue, string asVarCategory = "Actor")
    RPB_StorageVars.SetFormOnForm(asVarName, this, akValue, asVarCategory)
endFunction

function SetReference(string asVarName, ObjectReference akValue, string asVarCategory = "Actor")
    RPB_StorageVars.SetFormOnForm(asVarName, this, akValue, asVarCategory)
endFunction

function Remove(string asVarName, string asVarCategory = "Actor")
    RPB_StorageVars.DeleteVariableOnForm(asVarName, this, asVarCategory)
endFunction

function RemoveAll(string asVarCategory = "Actor")
    RPB_StorageVars.DeleteCategoryOnForm(this, asVarCategory)
endFunction

; ==========================================================

; ==========================================================
;                          Management
; ==========================================================

event OnEffectStart(Actor akTarget, Actor akCaster)
    __this = akTarget
    __isEffectActive = true

    ; Assigns the actor for this script, differentiating between Player and NPC to avoid retrieving properties, instead caching it in a local variable to this script
    self.__assignActor()

    ; Initialization to overriden children
    self.OnInitialize()
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
    Debug("RPB_Actor::OnEffectFinish", this + " is no longer bound to " + self as string + ", detaching script!")

    __isEffectActive = false
    self.OnDestroy()
endEvent

event OnDetach()
    Debug("Actor::OnDetach", "Detached " + self)
endEvent

event OnTrackedStatsEvent(string asStatFilter, int aiValue)
    if (TrackStats)
        self.OnStatChanged(asStatFilter, aiValue)
    endif
endEvent

; Handles the tracked stats when they are changed.
; Tracks both ActorVars for this particular Actor and all stats handled by OnTrackedStatsEvent() for the Player.
event OnStatChanged(string asStatName, int aiValue) ; override
endEvent

; Handles the initialization of this Actor
event OnInitialize() ; override
endEvent

; Handles the destruction of this Actor
event OnDestroy() ; override
endEvent

; Registers this Actor to receive events when tracked stats are updated.
function RegisterForTrackedStats()
    if (self.IsPlayer())
        RegisterForTrackedStatsEvent() ; Vanilla Stats, Player only

        if (self.RegisterSleepEvents)
            RegisterForSleep()
        endif
    endif

    __trackStats = true
endFunction

function UnregisterForTrackedStats()
    if (self.IsPlayer())
        UnregisterForTrackedStatsEvent() ; Vanilla Stats, Player only
    endif

    __trackStats = false
endFunction

Actor function GetActor() ; override
    Debug("Actor::GetActor", "Actor has not been overridden for " + self.GetExtends() + ", some features may not work properly! [Implement method " + self.GetExtends() + ".GetActor()]")
endFunction

Faction function GetFaction() ; override
    Debug("Actor::GetFaction", "Faction has not been overridden for " + self.GetExtends() + ", some features may not work properly! [Implement method " + self.GetExtends() + ".GetFaction()]")
endFunction

string function GetExtends()
    return self.GetBaseObject().GetName()
endFunction

string function GetName()
    return this.GetBaseObject().GetName()
endFunction

string function GetIdentifier()
    return this.GetFormID()
endFunction

string function GetPossessivePronoun()
    if (self.IsFemale)
        return "her"
    elseif (self.IsMale)
        return "his"
    endif
endFunction

string function GetPronoun()
    if (self.IsFemale)
        return "her"
    elseif (self.IsMale)
        return "him"
    endif
endFunction

;/
    The Actor that is currently attached to this script.

    The reason this is not a property with the value of GetTargetActor() is due to how the MagicEffect works once removed.
    When removing the magic effect from the Actor, and calling any function/event that requires a reference to said Actor,
    it will return None because the script is not pointing to that reference anymore, this is a workaround that enables the script
    to assign this value to akTarget OnEffectStart(), bypassing the problem entirely.

    The value is set through OnEffectStart().
/;
Actor __this
Actor property this
    Actor function get()
        return __this
    endFunction
endProperty

;/
    Whether to track this Actor's stats.
/;
bool __trackStats
bool property TrackStats
    bool function get()
        return __trackStats
    endFunction
endProperty

bool property RegisterSleepEvents auto

string property CurrentState
    string function get()
        return self.GetState()
    endFunction
endProperty

bool __isEffectActive
bool property IsEffectActive
    bool function get()
        return __isEffectActive
    endFunction
endProperty


; State vars to control whether this Actor is the Player or an NPC
bool __isPlayer
bool __wasActorAssigned

; Internal function for RPB_Actor, assigns the Actor for this script
function __assignActor()
    if (this.GetFormID() == 0x14) ; Player FormID
        __isPlayer = true
        __wasActorAssigned = true
    else
        __isPlayer = false
        __wasActorAssigned = true
    endif
endFunction

bool function IsPlayer()
    return __wasActorAssigned && __isPlayer
endFunction

bool function IsNPC()
    return __wasActorAssigned && !__isPlayer
endFunction
