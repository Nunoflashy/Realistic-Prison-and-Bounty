Scriptname RPB_PrisonExperimental extends ReferenceAlias  

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

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

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

; ==========================================================
;                       Prison Settings
; ==========================================================
;/
    These settings are retrieved directly through Config, which retrieves them
    from the MCM menu as soon as they are changed, so they are always up to date.
/;

;                           Jail
; ==========================================================

int property GuaranteedPayableBounty
    int function get()
        return Config.GetJailGuaranteedPayableBounty(Hold)
    endFunction
endProperty

int property MaximumPayableBounty
    int function get()
        return Config.GetJailMaximumPayableBounty(Hold)
    endFunction
endProperty

int property MaximumPayableBountyChance
    int function get()
        return Config.GetJailMaximumPayableChance(Hold)
    endFunction
endProperty

int property BountyExchange
    int function get()
        return Config.GetJailBountyExchange(Hold)
    endFunction
endProperty

int property BountyToSentence
    int function get()
        return Config.GetJailBountyToSentence(Hold)
    endFunction
endProperty

int property MinimumSentence
    int function get()
        return Config.GetJailMinimumSentence(Hold)
    endFunction
endProperty

int property MaximumSentence
    int function get()
        return Config.GetJailMaximumSentence(Hold)
    endFunction
endProperty

int property CellSearchThoroughness
    int function get()
        return Config.GetJailCellSearchThoroughness(Hold)
    endFunction
endProperty

string property CellLockLevel
    string function get()
        return Config.GetJailCellDoorLockLevel(Hold)
    endFunction
endProperty

bool property FastForward
    bool function get()
        return Config.IsJailFastForwardEnabled(Hold)
    endFunction
endProperty

int property DayToFastForwardFrom
    int function get()
        return Config.GetJailFastForwardDay(Hold)
    endFunction
endProperty

string property HandleSkillLoss
    string function get()
        return Config.GetJailHandleSkillLoss(Hold)
    endFunction
endProperty

int property DayToStartLosingSkills
    int function get()
        return Config.GetJailDayToStartLosingSkills(Hold)
    endFunction
endProperty

int property ChanceToLoseSkills
    int function get()
        return Config.GetJailChanceToLoseSkillsDaily(Hold)
    endFunction
endProperty

float property RecognizedCriminalPenalty
    float function get()
        return Config.GetJailRecognizedCriminalPenalty(Hold)
    endFunction
endProperty

float property KnownCriminalPenalty
    float function get()
        return Config.GetJailKnownCriminalPenalty(Hold)
    endFunction
endProperty

int property MinimumBountyToTriggerCriminalPenalty
    int function get()
        return Config.GetJailBountyToTriggerCriminalPenalty(Hold)
    endFunction
endProperty

;                           Release
; ==========================================================

bool property EnableReleaseFees
    bool function get()
        return Config.IsJailReleaseFeesEnabled(Hold)
    endFunction
endProperty

int property ReleaseFeesChanceForEvent
    int function get()
        return Config.GetReleaseChanceForReleaseFeesEvent(Hold)
    endFunction
endProperty

int property MinimumBountyToOweReleaseFees
    int function get()
        return Config.GetReleaseBountyToOweFees(Hold)
    endFunction
endProperty

float property ReleaseFeesOfCurrentBounty
    float function get()
        return Config.GetReleaseReleaseFeesFromBounty(Hold)
    endFunction
endProperty

int property ReleaseFees
    int function get()
        return Config.GetReleaseReleaseFeesFlat(Hold)
    endFunction
endProperty

int property DaysGivenToPayReleaseFees
    int function get()
        return Config.GetReleaseDaysGivenToPayReleaseFees(Hold)
    endFunction
endProperty

bool property EnableItemRetention
    bool function get()
        return Config.IsItemRetentionEnabledOnRelease(Hold)
    endFunction
endProperty

int property MinimumBountyToRetainItems
    int function get()
        return Config.GetReleaseBountyToRetainItems(Hold)
    endFunction
endProperty

bool property AutoRedressOnRelease
    bool function get()
        return Config.IsAutoDressingEnabledOnRelease(Hold)
    endFunction
endProperty

;                           Escape
; ==========================================================

float property EscapeBountyOfCurrentBounty
    float function get()
        return Config.GetEscapedBountyFromCurrentArrest(Hold)
    endFunction
endProperty

int property EscapeBounty
    int function get()
        return Config.GetEscapedBountyFlat(Hold)
    endFunction
endProperty

bool property AccountForTimeServedOnEscape
    bool function get()
        return Config.IsTimeServedAccountedForOnEscape(Hold)
    endFunction
endProperty

bool property FriskUponCapturedOnEscape
    bool function get()
        return Config.ShouldFriskOnEscape(Hold)
    endFunction
endProperty

bool property StripUponCapturedOnEscape
    bool function get()
        return Config.ShouldStripOnEscape(Hold)
    endFunction
endProperty

;                           Infamy
; ==========================================================

bool property EnableInfamy
    bool function get()
        return Config.IsInfamyEnabled(Hold)
    endFunction
endProperty

int property InfamyRecognizedThreshold
    int function get()
        return Config.GetInfamyRecognizedThreshold(Hold)
    endFunction
endProperty

int property InfamyKnownThreshold
    int function get()
        return Config.GetInfamyKnownThreshold(Hold)
    endFunction
endProperty

float property InfamyGainedDailyOfCurrentBounty
    float function get()
        return Config.GetInfamyGainedDailyFromArrestBounty(Hold)
    endFunction
endProperty

int property InfamyGainedDaily
    int function get()
        return Config.GetInfamyGainedDaily(Hold)
    endFunction
endProperty

float property InfamyGainModifierRecognized
    float function get()
        return Config.GetInfamyGainModifier(Hold, "Recognized")
    endFunction
endProperty

float property InfamyGainModifierKnown
    float function get()
        return Config.GetInfamyGainModifier(Hold, "Known")
    endFunction
endProperty

;                          Frisking
; ==========================================================

bool property AllowFrisking
    bool function get()
        return Config.IsFriskingEnabled(Hold)
    endFunction
endProperty

int property MinimumBountyForFrisking
    int function get()
        return Config.GetFriskingBountyRequired(Hold)
    endFunction
endProperty

int property FriskingThoroughness
    int function get()
        return Config.GetFriskingThoroughness(Hold)
    endFunction
endProperty

bool property ConfiscateStolenItemsOnFrisk
    bool function get()
        return Config.IsFriskingStolenItemsConfiscated(Hold)
    endFunction
endProperty

bool property StripIfStolenItemsFoundOnFrisk
    bool function get()
        return Config.IsFriskingStripSearchWhenStolenItemsFound(Hold)
    endFunction
endProperty

int property MinimumNumberOfStolenItemsRequiredToStripOnFrisk
    int function get()
        return Config.GetFriskingStolenItemsRequiredForStripping(Hold)
    endFunction
endProperty

;                         Stripping
; ==========================================================

bool property AllowStripping
    bool function get()
        return Config.IsStrippingEnabled(Hold)
    endFunction
endProperty

string property HandleStrippingOn
    string function get()
        return Config.GetStrippingHandlingCondition(Hold)
    endFunction
endProperty

int property MinimumBountyToStrip
    int function get()
        return Config.GetStrippingMinimumBounty(Hold)
    endFunction
endProperty

int property MinimumViolentBountyToStrip
    int function get()
        return Config.GetStrippingMinimumViolentBounty(Hold)
    endFunction
endProperty

int property MinimumSentenceToStrip
    int function get()
        return Config.GetStrippingMinimumSentence(Hold)
    endFunction
endProperty

int property StrippingThoroughness
    int function get()
        return Config.GetStrippingThoroughness(Hold)
    endFunction
endProperty

int property StrippingThoroughnessModifier
    int function get()
        return Config.GetStrippingThoroughnessBountyModifier(Hold)
    endFunction
endProperty

;                        Clothing
; ==========================================================

bool property AllowClothing
    bool function get()
        return Config.IsClothingEnabled(Hold)
    endFunction
endProperty

string property HandleClothingOn
    string function get()
        return Config.GetClothingHandlingCondition(Hold)
    endFunction
endProperty

int property MaximumBountyClothing
    int function get()
        return Config.GetClothingMaximumBounty(Hold)
    endFunction
endProperty

int property MaximumViolentBountyClothing
    int function get()
        return Config.GetClothingMaximumViolentBounty(Hold)
    endFunction
endProperty

int property MaximumSentenceClothing
    int function get()
        return Config.GetClothingMaximumSentence(Hold)
    endFunction
endProperty

bool property ClotheWhenDefeated
    bool function get()
        return Config.IsClothedOnDefeat(Hold)
    endFunction
endProperty

string property ClothingOutfit
    string function get()
        return Config.GetClothingOutfit(Hold)
    endFunction
endProperty

;                          Outfit
; ==========================================================

string property OutfitName
    string function get()
        return Config.GetClothingOutfit(Hold)
    endFunction
endProperty

Form property OutfitPartHead
    Form function get()
        return Config.GetOutfitPart(Hold, "Head")
    endFunction
endProperty

Form property OutfitPartBody
    Form function get()
        return Config.GetOutfitPart(Hold, "Body")
    endFunction
endProperty

Form property OutfitPartHands
    Form function get()
        return Config.GetOutfitPart(Hold, "Hands")
    endFunction
endProperty

Form property OutfitPartFeet
    Form function get()
        return Config.GetOutfitPart(Hold, "Feet")
    endFunction
endProperty

bool property IsOutfitConditional
    bool function get()
        return Config.IsClothingOutfitConditional(Hold)
    endFunction
endProperty

int property OutfitMinimumBounty
    int function get()
        return Config.GetClothingOutfitMinimumBounty(Hold)
    endFunction
endProperty

int property OutfitMaximumBounty
    int function get()
        return Config.GetClothingOutfitMaximumBounty(Hold)
    endFunction
endProperty

; ==========================================================

Location __prisonLocation
Location property PrisonLocation
    Location function get()
        return __prisonLocation
    endFunction
endProperty

Faction __prisonFaction
Faction property PrisonFaction
    Faction function get()
        return __prisonFaction
    endFunction
endProperty

string __hold
string property Hold
    string function get()
        return __hold
    endFunction
endProperty

function SetSentence(RPB_Prisoner akPrisoner, float afSentence = 0.0)
    ; akPrisoner.SetSentence(int_if (afSentence != 0.0, afSentence, akPrisoner.GetSentenceFromBounty()))
endFunction

; ==========================================================
;                          Cell
; ==========================================================

RPB_JailCell[] function GetEmptyCells()
    ; Prison_GetInt("Cell 01")
    ; Get all Prisoners from Cell 01
    ; If no prisoners, the cell is empty, add it to an array
    ; do the same for the remaining cells
endFunction

; ==========================================================

function SetAttributes( \
    Location akLocation, \
    Faction akFaction, \
    string asHold \
)

    __prisonLocation    = akLocation
    __prisonFaction     = akFaction
    __hold              = asHold

    Debug(self.GetOwningQuest(), "Prison::SetAttributes", "Prison Location: " + PrisonLocation + ", Prison Faction: " + PrisonFaction + ", Prison Hold: " + Hold)
endFunction

function InitializeSelfForPrisoner(RPB_Prisoner akPrisoner)
    akPrisoner.LockPrisonerSettings()
endFunction

; ==========================================================
;                          Events
; ==========================================================

event OnPrisonerDying(RPB_Prisoner akPrisoner, Actor akKiller)
    
endEvent

event OnPrisonerDeath(RPB_Prisoner akPrisoner, Actor akKiller)

endEvent

event OnGuardDying(RPB_Guard akGuard, Actor akKiller)
    
endEvent

event OnGuardDeath(RPB_Guard akGuard, Actor akKiller)

endEvent

; ==========================================================
;                          Management
; ==========================================================

event OnInit()
    Debug(self.GetOwningQuest(), "RPB_PrisonExperimental::OnInit", "Initialized Prison Experimental, Hold: " + Hold)
endEvent

; event OnEffectStart(Actor akTarget, Actor akCaster)
;     Debug(none, "Prison::OnEffectStart", akTarget + " is now an " + self as string + ", " + self as string + " script bound!")
;     Arrest.RegisterPrison(self, self.GetTargetActor())
; endEvent

; event OnEffectFinish(Actor akTarget, Actor akCaster)
;     Debug(none, "Prison::OnEffectFinish", akTarget + " is no longer bound to " + self as string + ", detaching script!")
; endEvent

; ==========================================================
;                         Arrest Vars
; ==========================================================
;                           Getters
; bool function Prison_GetBool(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory +"::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory +"::" + asVarName)
;     return ArrestVars.GetBool(paramKey)
; endFunction

; int function Prison_GetInt(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory +"::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory +"::" + asVarName)
;     return ArrestVars.GetInt(paramKey)
; endFunction

; float function Prison_GetFloat(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory +"::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory +"::" + asVarName)
;     return ArrestVars.GetFloat(paramKey)
; endFunction

; string function Prison_GetString(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory +"::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory +"::" + asVarName)
;     return ArrestVars.GetString(paramKey)
; endFunction

; Form function Prison_GetForm(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory +"::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory +"::" + asVarName)
;     return ArrestVars.GetForm(paramKey)
; endFunction

; ObjectReference function Prison_GetReference(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory +"::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory +"::" + asVarName)
;     return ArrestVars.GetReference(paramKey)
; endFunction

; Actor function Prison_GetActor(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory +"::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory +"::" + asVarName)
;     return ArrestVars.GetActor(paramKey)
; endFunction
; ;                          Setters
; function Prison_SetBool(string asVarName, bool abValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)
;     return ArrestVars.SetBool(paramKey, abValue)
; endFunction

; function Prison_SetInt(string asVarName, int aiValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)
;     return ArrestVars.SetInt(paramKey, aiValue)
; endFunction

; function Prison_ModInt(string asVarName, int aiValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)  
;     return ArrestVars.ModInt(paramKey, aiValue)
; endFunction

; function Prison_SetFloat(string asVarName, float afValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)   
;     return ArrestVars.SetFloat(paramKey, afValue)
; endFunction

; function Prison_ModFloat(string asVarName, float afValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)
;     return ArrestVars.ModFloat(paramKey, afValue)
; endFunction

; function Prison_SetString(string asVarName, string asValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)  
;     return ArrestVars.SetString(paramKey, asValue)
; endFunction

; function Prison_SetForm(string asVarName, Form akValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)
;     return ArrestVars.SetForm(paramKey, akValue)
; endFunction

; function Prison_SetReference(string asVarName, ObjectReference akValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName) 
;     return ArrestVars.SetReference(paramKey, akValue)
; endFunction

; function Prison_SetActor(string asVarName, Actor akValue, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]"+ asVarCategory + "::" + asVarName)
;     return ArrestVars.SetActor(paramKey, akValue)
; endFunction

; function Prison_Remove(string asVarName, string asVarCategory = "Arrest")
;     string paramKey = string_if (this == Config.Player, asVarCategory + "::" + asVarName, "["+ this.GetFormID() +"]" + asVarCategory + "::" + asVarName)
;     ArrestVars.Remove(paramKey)
; endFunction

; ; ==========================================================