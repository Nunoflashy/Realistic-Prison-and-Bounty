scriptname RealisticPrisonAndBounty_ArrestVars extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
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
        return self.GetFloat("Jail::Sentence") as int
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
    return JMap.getInt(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides))
endFunction

float function GetFloat(string paramKey, bool allowOverrides = true)
    return JMap.getFlt(_arrestVarsContainer, __getUsedKey(paramKey, allowOverrides))
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

function Remove(string paramKey)
    JMap.removeKey(_arrestVarsContainer, paramKey)
    
    if (self.HasOverride(paramKey))
        JMap.removeKey(_arrestVarsContainer, GetOverride(paramKey))
    endif
endFunction

function Delete()
    JMap.clear(_arrestVarsContainer)
endFunction

bool function Exists(string paramKey)
    return JMap.hasKey(_arrestVarsContainer, paramKey)
endFunction

bool function HasOverride(string paramKey)
    return JMap.hasKey(_arrestVarsContainer, GetOverride(paramKey))
endFunction

string function GetOverride(string paramKey)
    return OverrideKey + paramKey
endFunction

; Returns the made overriden key for this param
string function __getUsedKey(string paramKey, bool allowOverrides)
    return string_if (allowOverrides && self.HasOverride(paramKey), GetOverride(paramKey), paramKey)
endFunction

string property OverrideKey
    string function get()
        return "Override::"
    endFunction
endProperty

event OnInit()
    __init()
endEvent

function __init()
    _arrestVarsContainer = JMap.object()
    JValue.retain(_arrestVarsContainer)
    Debug(self, "__init", "Initialized Arrest Vars Container")
endFunction

int function GetContainer()
    return _arrestVarsContainer
endFunction

int _arrestVarsContainer