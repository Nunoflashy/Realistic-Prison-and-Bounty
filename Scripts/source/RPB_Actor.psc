scriptname RPB_Actor extends ActiveMagicEffect
{Base Actor script for RPB_Actor, must be inherited from to be used}

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

; ==========================================================
;                      Script References
; ==========================================================

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property Arrest
    RealisticPrisonAndBounty_Arrest function get()
        return Config.Arrest
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property Jail
    RealisticPrisonAndBounty_Jail function get()
        return Config.Jail
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property JailVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_ActorVars property ActorVars
    RealisticPrisonAndBounty_ActorVars function get()
        return Config.ActorVars
    endFunction
endProperty

; ==========================================================



; ==========================================================
;                 Arrest Vars Undefined Values
; ==========================================================

; bool    property ARREST_VARS_BOOL_UNDEFINED         = false autoreadonly
; int     property ARREST_VARS_INT_UNDEFINED          = -170000 autoreadonly
; float   property ARREST_VARS_FLOAT_UNDEFINED        = -170000 autoreadonly
; string  property ARREST_VARS_STRING_UNDEFINED       = "Undefined" autoreadonly
; Form    property ARREST_VARS_FORM_UNDEFINED         = none auto

; ==========================================================

; event OnArrestVarChanged(string asStatName, bool abValue, int aiValue, float afValue, string asValue, Form akValue)
;     ; Override
; endEvent

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
    return bool_if (self.IsPlayer(), self.GetFaction().GetCrimeGold() > 0, ActorVars.GetCrimeGold(self.GetFaction(), this) > 0)
endFunction

bool function HasLatentBounty()
    return (Vars_GetInt("Bounty Non-Violent", "Arrest") + Vars_GetInt("Bounty Violent", "Arrest")) > 0
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
        totalBounty += int_if (self.IsPlayer(), self.GetFaction().GetCrimeGoldNonViolent(), ActorVars.GetCrimeGoldNonViolent(self.GetFaction(), this))
    endif

    if (abViolent)
        totalBounty += int_if (self.IsPlayer(), self.GetFaction().GetCrimeGoldViolent(), ActorVars.GetCrimeGoldViolent(self.GetFaction(), this))
    endif

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
        totalBounty += Vars_GetInt("Bounty Non-Violent", "Arrest")
    endif

    if (abViolent)
        totalBounty += Vars_GetInt("Bounty Violent", "Arrest")
    endif

    return totalBounty
endFunction

; Transfers the Active Bounty into the Latent Bounty.
function HideBounty()
    if (self.HasLatentBounty())
        Vars_ModInt("Bounty Non-Violent",   self.GetActiveBounty(abViolent = false), "Arrest")
        Vars_ModInt("Bounty Violent",       self.GetActiveBounty(abNonViolent = false), "Arrest")
    else
        Vars_SetInt("Bounty Non-Violent",   self.GetActiveBounty(abViolent = false), "Arrest")
        Vars_SetInt("Bounty Violent",       self.GetActiveBounty(abNonViolent = false), "Arrest")
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
        Vars_Remove("Bounty Non-Violent", "Arrest")
    endif

    if (abViolent)
        Vars_Remove("Bounty Violent", "Arrest")
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
    return ActorVars.GetStat(statName, self.GetFaction(), this)
endFunction

;/
    Sets the given stat for this faction and this Actor.
/;
function SetStat(string statName, int value)
    ActorVars.SetStat(statName, self.GetFaction(), this, value)

    if (TrackStats)
        self.OnStatChanged(statName, value)
    endif
endFunction

;/
    Increments the given stat by the amount given.
/;
function IncrementStat(string statName, int incrementBy = 1)
    ActorVars.IncrementStat(statName, self.GetFaction(), this, incrementBy)

    if (TrackStats)
        self.OnStatChanged(statName, self.QueryStat(statName))
    endif
endFunction

;/
    Decrements the given stat by the amount given.
/;
function DecrementStat(string statName, int decrementBy = 1)
    ActorVars.DecrementStat(statName, self.GetFaction(), this, decrementBy)

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
;                         Arrest Vars
; ==========================================================

string function __getActorVarKey(string asVarName, string asVarCategory)
    if (self.IsPlayer())
        return asVarCategory + "::" + asVarName
    else
        return "["+ this.GetFormID() +"]" + asVarCategory + "::" + asVarName
    endif

    ; Fallback
    if (this == Config.Player)
        return asVarCategory + "::" + asVarName
    endif

    return "["+ this.GetFormID() +"]" + asVarCategory + "::" + asVarName
endFunction

;                           Getters
bool function Vars_GetBool(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    return ArrestVars.GetBool(paramKey)
endFunction

int function Vars_GetInt(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    return ArrestVars.GetInt(paramKey)
endFunction

float function Vars_GetFloat(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    return ArrestVars.GetFloat(paramKey)
endFunction

string function Vars_GetString(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    return ArrestVars.GetString(paramKey)
endFunction

Form function Vars_GetForm(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    return ArrestVars.GetForm(paramKey)
endFunction

ObjectReference function Vars_GetReference(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    return ArrestVars.GetReference(paramKey)
endFunction

Actor function Vars_GetActor(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    return ArrestVars.GetActor(paramKey)
endFunction
;                          Setters
function Vars_SetBool(string asVarName, bool abValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     abValue, \
    ;     ARREST_VARS_INT_UNDEFINED, \
    ;     ARREST_VARS_FLOAT_UNDEFINED, \
    ;     ARREST_VARS_STRING_UNDEFINED, \
    ;     ARREST_VARS_FORM_UNDEFINED \
    ; )
    return ArrestVars.SetBool(paramKey, abValue)
endFunction

function Vars_SetInt(string asVarName, int aiValue, string asVarCategory = "Arrest", int aiMinValue = 0, int aiMaxValue = 0)
    string paramKey = __getActorVarKey(asVarName, asVarCategory)

    if (aiMinValue != 0)
        ArrestVars.SetIntMin(paramKey, aiMinValue)
    endif

    if (aiMaxValue != 0)
        ArrestVars.SetIntMax(paramKey, aiMaxValue)
    endif

    return ArrestVars.SetInt(paramKey, aiValue)
endFunction

function Vars_ModInt(string asVarName, int aiValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     ARREST_VARS_BOOL_UNDEFINED, \
    ;     aiValue, \
    ;     ARREST_VARS_FLOAT_UNDEFINED, \
    ;     ARREST_VARS_STRING_UNDEFINED, \
    ;     ARREST_VARS_FORM_UNDEFINED \
    ; )    
    return ArrestVars.ModInt(paramKey, aiValue)
endFunction

function Vars_SetFloat(string asVarName, float afValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     ARREST_VARS_BOOL_UNDEFINED, \
    ;     ARREST_VARS_INT_UNDEFINED, \
    ;     afValue, \
    ;     ARREST_VARS_STRING_UNDEFINED, \
    ;     ARREST_VARS_FORM_UNDEFINED \
    ; )        
    return ArrestVars.SetFloat(paramKey, afValue)
endFunction

function Vars_ModFloat(string asVarName, float afValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     ARREST_VARS_BOOL_UNDEFINED, \
    ;     ARREST_VARS_INT_UNDEFINED, \
    ;     afValue, \
    ;     ARREST_VARS_STRING_UNDEFINED, \
    ;     ARREST_VARS_FORM_UNDEFINED \
    ; )      
    return ArrestVars.ModFloat(paramKey, afValue)
endFunction

function Vars_SetString(string asVarName, string asValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     ARREST_VARS_BOOL_UNDEFINED, \
    ;     ARREST_VARS_INT_UNDEFINED, \
    ;     ARREST_VARS_FLOAT_UNDEFINED, \
    ;     asValue, \
    ;     ARREST_VARS_FORM_UNDEFINED \
    ; )      
    return ArrestVars.SetString(paramKey, asValue)
endFunction

function Vars_SetForm(string asVarName, Form akValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     ARREST_VARS_BOOL_UNDEFINED, \
    ;     ARREST_VARS_INT_UNDEFINED, \
    ;     ARREST_VARS_FLOAT_UNDEFINED, \
    ;     ARREST_VARS_STRING_UNDEFINED, \
    ;     akValue \
    ; )      
    return ArrestVars.SetForm(paramKey, akValue)
endFunction

function Vars_SetReference(string asVarName, ObjectReference akValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     ARREST_VARS_BOOL_UNDEFINED, \
    ;     ARREST_VARS_INT_UNDEFINED, \
    ;     ARREST_VARS_FLOAT_UNDEFINED, \
    ;     ARREST_VARS_STRING_UNDEFINED, \
    ;     akValue \
    ; )       
    return ArrestVars.SetReference(paramKey, akValue)
endFunction

function Vars_SetActor(string asVarName, Actor akValue, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ; self.OnArrestVarChanged( \
    ;     asVarName, \ 
    ;     ARREST_VARS_BOOL_UNDEFINED, \
    ;     ARREST_VARS_INT_UNDEFINED, \
    ;     ARREST_VARS_FLOAT_UNDEFINED, \
    ;     ARREST_VARS_STRING_UNDEFINED, \
    ;     akValue \
    ; )       
    return ArrestVars.SetActor(paramKey, akValue)
endFunction

function Vars_Remove(string asVarName, string asVarCategory = "Arrest")
    string paramKey = __getActorVarKey(asVarName, asVarCategory)
    ArrestVars.Remove(paramKey)
endFunction

; ==========================================================

; ==========================================================
;                           Utility
; ==========================================================

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

function StopCombat(bool abStopCombatAlarm = true)
    this.StopCombat()

    if (abStopCombatAlarm)
        this.StopCombatAlarm()
    endif
endFunction

string function GetSex(bool abShortValue = false)
    if (self.IsFemale)
        return string_if (abShortValue, "F", "Female")
    elseif (self.IsMale)
        return string_if (abShortValue, "M", "Male")
    endif
endFunction


; ==========================================================
;                          Management
; ==========================================================

event OnEffectStart(Actor akTarget, Actor akCaster)
    __this = akTarget

    ; Assigns the actor for this script, differentiating between Player and NPC to avoid retrieving properties, instead caching it in a local variable to this script
    self.__assignActor()

    ; Initialization to overriden children
    self.OnInitialize()

    ; Debug(none, "RPB_Actor::OnEffectStart", this + " is now an " + self.GetExtends() + ", " + self.GetExtends() + " script bound! (Parent: RPB_Actor)")
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
    Debug(none, "RPB_Actor::OnEffectFinish", this + " is no longer bound to " + self as string + ", detaching script!")
    self.OnDestroy()
endEvent

event OnDetach()
    Debug(none, "Actor::OnDetach", "Detached " + self)
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

; Handles the destruction of this Actor reference
event OnDestroy() ; override
endEvent

; Registers this Actor to receive events when tracked stats are updated.
function RegisterForTrackedStats()
    if (self.IsPlayer())
        RegisterForTrackedStatsEvent() ; Vanilla Stats, Player only
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
    Debug(this, "Actor::GetActor", "Actor has not been overridden for " + self.GetExtends() + ", some features may not work properly! [Implement method " + self.GetExtends() + ".GetActor()]")
endFunction

Faction function GetFaction() ; override
    Debug(this, "Actor::GetFaction", "Faction has not been overridden for " + self.GetExtends() + ", some features may not work properly! [Implement method " + self.GetExtends() + ".GetFaction()]")
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

string property CurrentState
    string function get()
        return self.GetState()
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
