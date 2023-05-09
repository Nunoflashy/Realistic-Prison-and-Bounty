scriptname RealisticPrisonAndBounty_ArrestVars extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RPB_ContainerManager property containerManager
    RPB_ContainerManager function get()
        return Game.GetFormFromFile(0x3DF8, GetPluginName()) as RPB_ContainerManager
    endFunction
endProperty

; ==========================================================
; Static Variables (Configured in MCM)
; ==========================================================

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
        return self.GetFloat("Escape::Escape Bounty from Current Arrest")
    endFunction
endProperty

int property EscapeBounty
    int function get()
        return self.GetFloat("Escape::Escape Bounty Flat") as int
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

bool property RedressOnRelease
    bool function get()
        return self.GetBool("Release::Redress on Release")
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

bool property IsInfamyRecognized
    bool function get()
        int currentInfamy = config.GetInfamyGained(Hold)
        int recognizedThreshold = self.GetFloat("Jail::Infamy Recognized Threshold") as int

        return currentInfamy >= recognizedThreshold
    endFunction
endProperty

bool property IsInfamyKnown
    bool function get()
        int currentInfamy = config.GetInfamyGained(Hold)
        int knownThreshold = self.GetFloat("Jail::Infamy Known Threshold") as int
        
        return currentInfamy >= knownThreshold
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
    containerManager.SetInt(ContainerName, paramKey, value as int)
endFunction

function SetInt(string paramKey, int value)
    containerManager.SetInt(ContainerName, paramKey, value as int)
endFunction

function SetFloat(string paramKey, float value)
    containerManager.SetFloat(ContainerName, paramKey, value)
endFunction

function SetString(string paramKey, string value)
    containerManager.SetString(ContainerName, paramKey, value)
endFunction

function SetForm(string paramKey, Form value)
    containerManager.SetForm(ContainerName, paramKey, value)
endFunction

function SetReference(string paramKey, ObjectReference value)
    containerManager.SetForm(ContainerName, paramKey, value as ObjectReference)
endFunction

function SetActor(string paramKey, Actor value)
    containerManager.SetForm(ContainerName, paramKey, value as Actor)
endFunction

function SetObject(string paramKey, int value)
    containerManager.SetObject(ContainerName, paramKey, value)
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
    if (!self.Exists(paramKey))
        Error(self, "ArrestVars::Get", "Arrest Variable <"+ paramKey +"> does not exist!")
        return false
    endif

    return containerManager.GetBool(ContainerName, __getUsedKey(paramKey, allowOverrides))
endFunction

int function GetInt(string paramKey, bool allowOverrides = true)
    if (!self.Exists(paramKey))
        Error(self, "ArrestVars::Get", "Arrest Variable <"+ paramKey +"> does not exist!")
        return 0
    endif

    int thisValue = containerManager.GetInt(ContainerName, __getUsedKey(paramKey, allowOverrides))

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
    if (!self.Exists(paramKey))
        Error(self, "ArrestVars::Get", "Arrest Variable <"+ paramKey +"> does not exist!")
        return 0.0
    endif

    float thisValue = containerManager.GetFloat(ContainerName, __getUsedKey(paramKey, allowOverrides))

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
    if (!self.Exists(paramKey))
        Error(self, "ArrestVars::Get", "Arrest Variable <"+ paramKey +"> does not exist!")
        return ""
    endif

    return containerManager.GetString(ContainerName, __getUsedKey(paramKey, allowOverrides))
endFunction

Form function GetForm(string paramKey, bool allowOverrides = true)
    if (!self.Exists(paramKey))
        Error(self, "ArrestVars::Get", "Arrest Variable <"+ paramKey +"> does not exist!")
        return none
    endif

    return containerManager.GetForm(ContainerName, __getUsedKey(paramKey, allowOverrides))
endFunction

ObjectReference function GetReference(string paramKey)
    return GetForm(paramKey) as ObjectReference
endFunction

Actor function GetActor(string paramKey)
    return GetForm(paramKey) as Actor
endFunction

int function GetObject(string paramKey, bool allowOverrides = true)
    if (!self.Exists(paramKey))
        Error(self, "ArrestVars::Get", "Arrest Variable ["+ paramKey +"] does not exist!")
        return -1
    endif
    return containerManager.GetObject(ContainerName, __getUsedKey(paramKey, allowOverrides))
endFunction

function Remove(string paramKey, bool removeOverrides = true)
    containerManager.RemoveElement(ContainerName, paramKey)
    
    if (self.HasOverride(paramKey) && removeOverrides)
        containerManager.RemoveElement(ContainerName, GetOverrideKey(paramKey))
    endif
endFunction

function Clear()
    containerManager.ClearContainer(ContainerName)
endFunction

bool function Exists(string paramKey)
    return containerManager.HasKey(ContainerName, paramKey)
endFunction

bool function HasOverride(string paramKey)
    return containerManager.HasKey(ContainerName, GetOverrideKey(paramKey))
endFunction

string function GetOverrideKey(string paramKey)
    return "Override::" + paramKey
endFunction

bool function HasMinimumValue(string paramKey)
    return containerManager.HasKey(ContainerName, "Min::" + paramKey)
endFunction

bool function HasMaximumValue(string paramKey)
    return containerManager.HasKey(ContainerName, "Max::" + paramKey)
endFunction

function SetIntMin(string paramKey, int minValue, bool allowNewRecords = false)
    if (!self.HasMinimumValue(paramKey) || allowNewRecords)
        containerManager.SetInt(ContainerName, "Min::" + paramKey, minValue)
    endif
endFunction

function SetIntMax(string paramKey, int minValue, bool allowNewRecords = false)
    if (!self.HasMaximumValue(paramKey) || allowNewRecords)
        containerManager.SetInt(ContainerName, "Max::" + paramKey, minValue)
    endif
endFunction

function SetFloatMin(string paramKey, float minValue, bool allowNewRecords = false)
    if (!self.HasMinimumValue(paramKey) || allowNewRecords)
        containerManager.SetFloat(ContainerName, "Min::" + paramKey, minValue)
    endif
endFunction

function SetFloatMax(string paramKey, float minValue, bool allowNewRecords = false)
    if (!self.HasMaximumValue(paramKey) || allowNewRecords)
        containerManager.SetFloat(ContainerName, "Max::" + paramKey, minValue)
    endif
endFunction

int function GetIntMin(string paramKey)
    return containerManager.GetInt(ContainerName, "Min::" + paramKey)
endFunction

int function GetIntMax(string paramKey)
    return containerManager.GetInt(ContainerName, "Max::" + paramKey)
endFunction

float function GetFloatMin(string paramKey)
    return containerManager.GetFloat(ContainerName, "Min::" + paramKey)
endFunction

float function GetFloatMax(string paramKey)
    return containerManager.GetFloat(ContainerName, "Max::" + paramKey)
endFunction

; string function GetList(string category = "")
;     bool hasCategory = category != ""
;     string categoryKey = string_if (!hasCategory, "", category + "::")
;     return GetContainerList(_arrestVarsContainer, includeStringFilter = categoryKey)
; endFunction

; function List(string category = "")
;     bool hasCategory = category != ""
;     string categoryKey = string_if (!hasCategory, "", category + "::")
;     Debug(self, string_if (!hasCategory, "ArrestVars::List", "ArrestVars::List("+ category +")"), GetContainerList(_arrestVarsContainer, includeStringFilter = categoryKey))
; endFunction

; function ListOverrides(string category = "")
;     bool hasCategory = category != ""
;     string categoryKey = string_if (!hasCategory, "Override::", "Override::" + category + "::")
;     Debug(self, string_if (!hasCategory, "ArrestVars::ListOverrides", "ArrestVars::ListOverrides("+ category +")"), GetContainerList(_arrestVarsContainer, includeStringFilter = categoryKey))
; endFunction

string function GetList(string category = "")
endFunction

function List(string category = "")
endFunction

function ListOverrides(string category = "")
endFunction

; Returns the made overriden key for this param if the var has an override and overriding is enabled,
; otherwise, returns the normal var key
string function __getUsedKey(string paramKey, bool allowOverrides)
    if (allowOverrides && self.HasOverride(paramKey))
        return GetOverrideKey(paramKey)
    endif
    
    return paramKey
endFunction

event OnInit()
    __init()
endEvent

function __init()
    containerManager.CreateMap(ContainerName)
    Debug(self, "__init", "Initialized Arrest Vars Container")
endFunction

int function GetHandle()
    return containerManager.GetContainer(ContainerName)
endFunction

string property ContainerName = "ArrestVars" autoreadonly
