scriptname RealisticPrisonAndBounty_ArrestVars extends Quest
{
    Serves as storage for Arrest and Jail variables,
    anything to do with Bounty, Sentence, MCM Options related to Arrest, etc...
}

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

; ==========================================================
; Static Variables (Configured in MCM)
; ==========================================================

int property DefeatedAdditionalBounty
    int function get()
        return self.GetInt("Arrest::Additional Bounty when Defeated")
    endFunction
endProperty

float property DefeatedAdditionalBountyPercentage
    float function get()
        return self.GetFloat("Arrest::Additional Bounty when Defeated from Current Bounty")
    endFunction
endProperty

bool property InfamyEnabled
    bool function get()
        return self.GetBool("Jail::Infamy Enabled")
    endFunction
endProperty

bool property IsStrippingEnabled
    bool function get()
        return self.GetBool("Stripping::Allow Stripping")
    endFunction
endProperty

bool property IsClothingEnabled
    bool function get()
        return self.GetBool("Clothing::Allow Clothing")
    endFunction
endProperty

bool property IsFriskingEnabled
    bool function get()
        return self.GetBool("Frisking::Allow Frisking")
    endFunction
endProperty

bool property IsFriskingUnconditional
    bool function get()
        return self.GetBool("Frisking::Unconditional Frisking")
    endFunction
endProperty

int property FriskingMinBounty
    int function get()
        return self.GetInt("Frisking::Bounty for Frisking")
    endFunction
endProperty

string property ClothingHandling
    string function get()
        return self.GetString("Clothing::Handle Clothing On")
    endFunction
endProperty

int property ClothingMaxBounty
    int function get()
        return self.GetInt("Clothing::Maximum Bounty to Clothe")
    endFunction
endProperty

int property ClothingMaxBountyViolent
    int function get()
        return self.GetInt("Clothing::Maximum Violent Bounty to Clothe")
    endFunction
endProperty

int property ClothingMaxSentence
    int function get()
        return self.GetInt("Clothing::Maximum Sentence to Clothe")
    endFunction
endProperty

bool property ClotheWhenDefeated
    bool function get()
        return self.GetBool("Clothing::Clothe when Defeated")
    endFunction
endProperty

bool property IsClothingUnconditional
    bool function get()
        return self.ClothingHandling == "Unconditionally"
    endFunction
endProperty

string property OutfitName
    string function get()
        return self.GetString("Clothing::Outfit::Name")
    endFunction
endProperty

Armor property OutfitHead
    Armor function get()
        return self.GetForm("Clothing::Outfit::Head") as Armor
    endFunction
endProperty

Armor property OutfitBody
    Armor function get()
        return self.GetForm("Clothing::Outfit::Body") as Armor
    endFunction
endProperty

Armor property OutfitHands
    Armor function get()
        return self.GetForm("Clothing::Outfit::Hands") as Armor
    endFunction
endProperty

Armor property OutfitFeet
    Armor function get()
        return self.GetForm("Clothing::Outfit::Feet") as Armor
    endFunction
endProperty

bool property IsOutfitConditional
    bool function get()
        return self.GetBool("Clothing::Outfit::Conditional")
    endFunction
endProperty

int property OutfitMinBounty
    int function get()
        return self.GetFloat("Clothing::Outfit::Minimum Bounty") as int
    endFunction
endProperty

int property OutfitMaxBounty
    int function get()
        return self.GetFloat("Clothing::Outfit::Maximum Bounty") as int
    endFunction
endProperty

float property EscapeBountyFromCurrentArrest
    float function get()
        return GetPercentAsDecimal(self.GetFloat("Escape::Escape Bounty from Current Arrest"))
    endFunction
endProperty

int property EscapeBounty
    int function get()
        return self.GetFloat("Escape::Escape Bounty Flat") as int
    endFunction
endProperty

bool property AccountForTimeServed
    bool function get()
        return self.GetBool("Escape::Account for Time Served")
    endFunction
endProperty

int property MinimumSentence
    int function get()
        return self.GetFloat("Jail::Minimum Sentence") as int
    endFunction
endProperty

int property MaximumSentence
    int function get()
        return self.GetFloat("Jail::Maximum Sentence") as int
    endFunction
endProperty

int property BountyExchange
    int function get()
        return self.GetFloat("Jail::Bounty Exchange") as int
    endFunction
endProperty

int property BountyToSentence
    int function get()
        return self.GetFloat("Jail::Bounty to Sentence") as int
    endFunction
endProperty

int property InfamyRecognizedThreshold
    int function get()
        return self.GetInt("Jail::Infamy Recognized Threshold")
    endFunction
endProperty

int property InfamyKnownThreshold
    int function get()
        return self.GetInt("Jail::Infamy Known Threshold")
    endFunction
endProperty

int property InfamyGainedDaily
    int function get()
        return self.GetInt("Jail::Infamy Gained Daily")
    endFunction
endProperty

float property InfamyGainedDailyFromBountyPercentage
    float function get()
        return GetPercentAsDecimal(self.GetFloat("Jail::Infamy Gained Daily from Current Bounty"))
    endFunction
endProperty

int property InfamyGainModifierRecognized
    int function get()
        return self.GetInt("Jail::Infamy Gain Modifier (Recognized)")
    endFunction
endProperty

int property InfamyGainModifierKnown
    int function get()
        return self.GetInt("Jail::Infamy Gain Modifier (Known)")
    endFunction
endProperty

int property InfamyBountyTrigger
    int function get()
        return self.GetInt("Jail::Bounty to Trigger Infamy")
    endFunction
endProperty

float property InfamyRecognizedPenalty
    float function get()
        return GetPercentAsDecimal(self.GetFloat("Jail::Recognized Criminal Penalty"))
    endFunction
endProperty

float property InfamyKnownPenalty
    float function get()
        return GetPercentAsDecimal(self.GetFloat("Jail::Known Criminal Penalty"))
    endFunction
endProperty

bool property RedressOnRelease
    bool function get()
        return self.GetBool("Release::Redress on Release")
    endFunction
endProperty

string property StrippingHandling
    string function get()
        return self.GetString("Stripping::Handle Stripping On")
    endFunction
endProperty

int property StrippingMinBounty
    int function get()
        return self.GetInt("Stripping::Bounty to Strip")
    endFunction
endProperty

int property StrippingMinViolentBounty
    int function get()
        return self.GetInt("Stripping::Violent Bounty to Strip")
    endFunction
endProperty

int property StrippingMinSentence
    int function get()
        return self.GetInt("Stripping::Sentence to Strip")
    endFunction
endProperty

float property StrippingThoroughness
    float function get()
        return self.GetFloat("Stripping::Stripping Thoroughness")
    endFunction
endProperty

int property StrippingThoroughnessModifier
    int function get()
        return self.GetInt("Stripping::Stripping Thoroughness Modifier")
    endFunction
endProperty

bool property ShouldStripOnEscape
    bool function get()
        return self.GetBool("Escape::Should Strip Search")
    endFunction
endProperty

bool property IsStrippingUnconditional
    bool function get()
        return self.StrippingHandling == "Unconditionally"
    endFunction
endProperty

; ==========================================================
; Dynamic Variables
; ==========================================================

float property CurrentTime
    float function get()
        return Utility.GetCurrentGameTime()
    endFunction
endProperty

float property TimeOfArrest
    float function get()
        return self.GetFloat("Arrest::Time of Arrest")
    endFunction
endProperty

float property TimeOfImprisonment
    float function get()
        return self.GetFloat("Jail::Time of Imprisonment")
    endFunction
endProperty

int property Sentence
    int function get()
        self.SetIntMin("Jail::Sentence", self.MinimumSentence)
        self.SetIntMax("Jail::Sentence", self.MaximumSentence)

        return self.GetInt("Jail::Sentence")
    endFunction
endProperty

bool property IsArrested
    bool function get()
        return self.GetBool("Arrest::Arrested")
    endFunction
endProperty

bool property IsJailed
    bool function get()
        return self.GetBool("Jail::Jailed")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    endFunction
endProperty

string property Hold
    string function get()
        return self.GetString("Arrest::Hold")
    endFunction
endProperty

Faction property ArrestFaction
    Faction function get()
        return self.GetForm("Arrest::Arrest Faction") as Faction
    endFunction
endProperty

Actor property Captor
    Actor function get()
        return self.GetForm("Arrest::Arresting Guard") as Actor
    endFunction
endProperty

int property BountyNonViolent
    int function get()
        return self.GetInt("Arrest::Bounty Non-Violent")
    endFunction
endProperty

int property BountyViolent
    int function get()
        return self.GetInt("Arrest::Bounty Violent")
    endFunction
endProperty

int property Bounty
    int function get()
        return BountyNonViolent + BountyViolent
    endFunction
endProperty

bool property MeetsOutfitConditions
    bool function get()
        return Bounty >= OutfitMinBounty && Bounty <= OutfitMaxBounty
    endFunction
endProperty

bool property IsStripped
    bool function get()
        return self.GetBool("Jail::Stripped")
    endFunction
endProperty

bool property IsClothed
    bool function get()
        return self.GetBool("Jail::Clothed")
    endFunction
endProperty

bool property WasDefeated
    bool function get()
        return self.GetBool("Arrest::Defeated")
    endFunction
endProperty

int property DefeatedBounty
    int function get()
        return self.GetInt("Arrest::Bounty for Defeat")
    endFunction
endProperty

bool property HasEludedArrest
    bool function get()
        self.GetBool("Arrest::Eluded")
    endFunction
endProperty

bool property IsAwaitingArrest
    bool function get()
        self.GetBool("Arrest::Awaiting Arrest")
    endFunction
endProperty

ObjectReference property JailCell
    ObjectReference function get()
        return self.GetForm("Jail::Cell") as ObjectReference
    endFunction
endProperty

ObjectReference property CellDoor
    ObjectReference function get()
        return self.GetForm("Jail::Cell Door") as ObjectReference
    endFunction
endProperty

Actor property Arrestee
    Actor function get()
        return self.GetForm("Arrest::Arrestee") as Actor
    endFunction
endProperty

string property ArrestType
    string function get()
        return self.GetString("Arrest::Arrest Type")
    endFunction
endProperty

ObjectReference property PrisonerItemsContainer
    ObjectReference function get()
        return self.GetReference("Jail::Prisoner Items Container")
    endFunction
endProperty


; ==========================================================
; Functions & Events
; ==========================================================

function SetBool(string paramKey, bool value)
    JMap.setInt(_arrestVarsContainer, paramKey, value as int)
endFunction

function SetInt(string paramKey, int value)
    JMap.setInt(_arrestVarsContainer, paramKey, value)
endFunction

function SetFloat(string paramKey, float value)
    JMap.setFlt(_arrestVarsContainer, paramKey, value)
endFunction

function SetString(string paramKey, string value)
    JMap.setStr(_arrestVarsContainer, paramKey, value)
endFunction

function SetForm(string paramKey, Form value)
    JMap.setForm(_arrestVarsContainer, paramKey, value)
endFunction

function SetReference(string paramKey, ObjectReference value)
    JMap.setForm(_arrestVarsContainer, paramKey, value)
endFunction

function SetActor(string paramKey, Actor value)
    JMap.setForm(_arrestVarsContainer, paramKey, value)
endFunction

function SetObject(string paramKey, int value)
    JMap.setObj(_arrestVarsContainer, paramKey, value)
endFunction

function ModInt(string paramKey, int value)
    int currentValue = self.GetInt(paramKey)
    self.SetInt(paramKey, currentValue + value)
endFunction

function ModFloat(string paramKey, float value)
    float currentValue = self.GetFloat(paramKey)
    self.SetFloat(paramKey, currentValue + value)
endFunction

bool function GetBool(string paramKey, bool allowOverrides = true)
    return JMap.getInt(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides)) as bool
endFunction

int function GetInt(string paramKey, bool allowOverrides = true)
    int thisValue = JMap.getInt(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides))

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)
    
    if (hasMin || hasMax)
        int minValue = self.GetIntMin(paramKey)
        int maxValue = self.GetIntMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

float function GetFloat(string paramKey, bool allowOverrides = true)
    float thisValue = JMap.getFlt(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides))

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)

    if (hasMin || hasMax)
        float minValue = self.GetFloatMin(paramKey)
        float maxValue = self.GetFloatMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

string function GetString(string paramKey, bool allowOverrides = true)
    return JMap.getStr(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides))
endFunction

Form function GetForm(string paramKey, bool allowOverrides = true)
    return JMap.getForm(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides))
endFunction

ObjectReference function GetReference(string paramKey)
    return GetForm(paramKey) as ObjectReference
endFunction

Actor function GetActor(string paramKey)
    return GetForm(paramKey) as Actor
endFunction

int function GetObject(string paramKey, bool allowOverrides = true)
    return JMap.getObj(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides))
endFunction

function Remove(string paramKey, bool removeOverrides = true)
    JMap.removeKey(_arrestVarsContainer, paramKey)
    
    if (self.HasOverride(paramKey) && removeOverrides)
        JMap.removeKey(_arrestVarsContainer, GetOverrideKey(paramKey))
    endif
endFunction

function RemoveForActor(Actor akActor, string paramKey, bool removeOverrides = true)
    string fullKey = "["+ akActor.GetFormID() +"]" + paramKey
    JMap.removeKey(_arrestVarsContainer, fullKey)

    if (self.HasOverride(fullKey) && removeOverrides)
        JMap.removeKey(_arrestVarsContainer, GetOverrideKey(fullKey))
    endif
endFunction

function Clear()
    JMap.clear(_arrestVarsContainer)
endFunction

; Clears all Arrest vars for this Actor
; Idea: add every actor to a sub-container inside the main container, and then clear the sub-container only which belongs to that Actor
function ClearActor(Actor akActor)

endFunction

bool function Exists(string paramKey)
    return JMap.hasKey(_arrestVarsContainer, paramKey)
endFunction

bool function HasOverride(string paramKey)
    return JMap.hasKey(_arrestVarsContainer, GetOverrideKey(paramKey))
endFunction

string function GetOverrideKey(string paramKey)
    return "Override::" + paramKey
endFunction

bool function HasMinimumValue(string paramKey)
    return JMap.hasKey(_arrestVarsContainer, "Min::" + paramKey)
endFunction

bool function HasMaximumValue(string paramKey)
    return JMap.hasKey(_arrestVarsContainer, "Max::" + paramKey)
endFunction

function SetIntMin(string paramKey, int minValue, bool allowNewRecords = false)
    if (!self.HasMinimumValue(paramKey) || allowNewRecords)
        JMap.setInt(_arrestVarsContainer, "Min::" + paramKey, minValue)
    endif
endFunction

function SetIntMax(string paramKey, int minValue, bool allowNewRecords = false)
    if (!self.HasMaximumValue(paramKey) || allowNewRecords)
        JMap.setInt(_arrestVarsContainer, "Max::" + paramKey, minValue)
    endif
endFunction

function SetFloatMin(string paramKey, float minValue, bool allowNewRecords = false)
    if (!self.HasMinimumValue(paramKey) || allowNewRecords)
        JMap.setFlt(_arrestVarsContainer, "Min::" + paramKey, minValue)
    endif
endFunction

function SetFloatMax(string paramKey, float minValue, bool allowNewRecords = false)
    if (!self.HasMaximumValue(paramKey) || allowNewRecords)
        JMap.setFlt(_arrestVarsContainer, "Max::" + paramKey, minValue)
    endif
endFunction

int function GetIntMin(string paramKey)
    return JMap.getInt(_arrestVarsContainer, "Min::" + paramKey)
endFunction

int function GetIntMax(string paramKey)
    return JMap.getInt(_arrestVarsContainer, "Max::" + paramKey)
endFunction

float function GetFloatMin(string paramKey)
    return JMap.getFlt(_arrestVarsContainer, "Min::" + paramKey)
endFunction

float function GetFloatMax(string paramKey)
    return JMap.getFlt(_arrestVarsContainer, "Max::" + paramKey)
endFunction

string function GetList(string category = "")
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "", category + "::")
    return GetContainerList(_arrestVarsContainer, includeStringFilter = categoryKey)
endFunction

function List(string category = "")
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "", category + "::")
    Debug(self, string_if (!hasCategory, "ArrestVars::List", "ArrestVars::List("+ category +")"), GetContainerList(_arrestVarsContainer, includeStringFilter = categoryKey))
endFunction

function ListOverrides(string category = "")
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "Override::", "Override::" + category + "::")
    Debug(self, string_if (!hasCategory, "ArrestVars::ListOverrides", "ArrestVars::ListOverrides("+ category +")"), GetContainerList(_arrestVarsContainer, includeStringFilter = categoryKey))
endFunction

function Serialize(string filePath)
    JValue.writeToFile(_arrestVarsContainer, RPB_Data.GetModDataDirectory() + filePath)
endFunction

int function Unserialize(string filePath)
    return JValue.readFromFile(filePath)
endFunction

; Returns the made overriden key for this param if the var has an override and overriding is enabled,
; otherwise, returns the normal var key
string function __getUsedKey(string paramKey, bool allowOverrides)
    if (allowOverrides && self.HasOverride(paramKey))
        return GetOverrideKey(paramKey)
    endif
    
    return paramKey
    ; return string_if (allowOverrides && self.HasOverride(paramKey), GetOverrideKey(paramKey), paramKey)
endFunction

event OnInit()
    __init()
endEvent

function __init()
    _arrestVarsContainer = JMap.object()
    JValue.retain(_arrestVarsContainer)
    Debug(self, "__init", "Initialized Arrest Vars Container")
endFunction

int function GetHandle()
    return _arrestVarsContainer
endFunction

int _arrestVarsContainer