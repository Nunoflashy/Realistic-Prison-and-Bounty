scriptname RealisticPrisonAndBounty_ActorVars extends Quest

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

; ==========================================================
; Dynamic Variables
; ==========================================================
; =================================
; Setters - Changers
; =================================
function SetStat(string statName, Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::" + statName, value)
    ; self.OnTrackedStatChanged(statName, akFaction, akActor, value)
endFunction

function SetCrimeGold(Faction akFaction, Actor akActor, int value)
    ; [0x382FA]Haafingar::Bounty Non-Violent
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Bounty Non-Violent", value)
endFunction

function SetCrimeGoldViolent(Faction akFaction, Actor akActor, int value)
    ; [0x382FA]Haafingar::Bounty Violent
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Bounty Violent", value)
endFunction

function SetCurrentBounty(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Current Bounty", value)
endFunction

function SetLargestBounty(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Largest Bounty", value)
endFunction

function SetTotalBounty(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Total Bounty", value)
endFunction

function SetTimesArrested(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Arrested", value)
endFunction

function SetTimesFrisked(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Frisked", value)
endFunction

function SetFeesOwed(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Fees Owed", value)
endFunction

function SetDaysJailed(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Days Jailed", value)
endFunction

function SetLongestSentence(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Longest Sentence", value)
endFunction

function SetTimesJailed(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Jailed", value)
endFunction

function SetTimesEscaped(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Escaped", value)
endFunction

function SetTimesStripped(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Stripped", value)
endFunction

function SetInfamy(Faction akFaction, Actor akActor, int value)
    ; [0x382FA]Haafingar::Infamy
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Infamy", value)
endFunction

; =============================================
; Setters - Modifiers / Increment & Decrement
; =============================================

function ModCrimeGold(Faction akFaction, Actor akActor, int value, bool abViolent = false)
    int crimeGold = int_if(abViolent, self.GetCrimeGoldViolent(akFaction, akActor), self.GetCrimeGoldNonViolent(akFaction, akActor))
    string crimeGoldType = string_if(abViolent, "Bounty Violent", "Bounty Non-Violent")
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::" + crimeGoldType, crimeGold + value)
endFunction

function ModTotalBounty(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Total Bounty", self.GetTotalBounty(akFaction, akActor) + value)
endFunction

function ModTimesArrested(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Arrested", self.GetTimesArrested(akFaction, akActor) + value)
endFunction

function ModTimesFrisked(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Frisked", self.GetTimesFrisked(akFaction, akActor) + value)
endFunction

function ModFeesOwed(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Fees Owed", self.GetFeesOwed(akFaction, akActor) + value)
endFunction

function ModDaysJailed(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Days Jailed", self.GetDaysJailed(akFaction, akActor) + value)
endFunction

function ModTimesJailed(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Jailed", self.GetTimesJailed(akFaction, akActor) + value)
endFunction

function ModTimesEscaped(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Escaped", self.GetTimesEscaped(akFaction, akActor) + value)
endFunction

function ModTimesStripped(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Stripped", self.GetTimesStripped(akFaction, akActor) + value)
endFunction

function ModInfamy(Faction akFaction, Actor akActor, int value)
    self.Set("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Infamy Gained", self.GetInfamy(akFaction, akActor) + value)
endFunction

function IncrementStat(string statName, Faction akFaction, Actor akActor, int incrementBy = 1)
    string statKey = "["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::" + statName
    ; if (!self.Exists(statKey))
    ;     Error(self, "ActorVars::IncrementStat", "The stat: " + statKey + " does not exist.")
    ;     return
    ; endif
    self.Set(statKey, self.Get(statKey) + incrementBy)
endFunction

function DecrementStat(string statName, Faction akFaction, Actor akActor, int decrementBy = 1)
    string statKey = "["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::" + statName
    ; if (!self.Exists(statKey))
    ;     Error(self, "ActorVars::DecrementStat", "The stat: " + statKey + " does not exist.")
    ;     return
    ; endif
    self.Set(statKey, self.Get(statKey) - decrementBy)
endFunction

; =================================
; Getters
; =================================

int function GetStat(string statName, Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::" + statName)
endFunction

int function GetCrimeGold(Faction akFaction, Actor akActor)
    return  self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Bounty Non-Violent") + \
            self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Bounty Violent")
endFunction

int function GetCrimeGoldNonViolent(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Bounty Non-Violent")
endFunction

int function GetCrimeGoldViolent(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Bounty Violent")
endFunction

int function GetCurrentBounty(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Current Bounty")
endFunction

int function GetLargestBounty(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Largest Bounty")
endFunction

int function GetTotalBounty(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Total Bounty")
endFunction

int function GetTimesArrested(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Arrested")
endFunction

int function GetTimesFrisked(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Frisked")
endFunction

int function GetFeesOwed(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Fees Owed")
endFunction

int function GetDaysJailed(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Days Jailed")
endFunction

int function GetLongestSentence(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Longest Sentence")
endFunction

int function GetTimesJailed(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Jailed")
endFunction

int function GetTimesEscaped(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Escaped")
endFunction

int function GetTimesStripped(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Times Stripped")
endFunction

int function GetInfamy(Faction akFaction, Actor akActor)
    return self.Get("["+ akActor.GetFormID() +"]" + akFaction.GetName() + "::Infamy Gained")
endFunction

; =================================
; Events
; =================================

event OnTrackedStatChanged(string asStatName, Faction akFaction, Actor akActor, int aiValue)
    
endEvent


; =================================
; Base Methods
; =================================

function Set(string paramKey, int value)
    JMap.setInt(_actorVarsContainer, paramKey, value)
endFunction

int function Get(string paramKey)
    return JMap.getInt(_actorVarsContainer, paramKey)
endFunction

function Remove(string paramKey)
    JMap.removeKey(_actorVarsContainer, paramKey)
endFunction

function Delete()
    JMap.clear(_actorVarsContainer)
endFunction

bool function Exists(string paramKey)
    return JMap.hasKey(_actorVarsContainer, paramKey)
endFunction

event OnInit()
    __init()
endEvent

function SetInt(int paramKey, int value)
    JIntMap.setInt(_actorVarsContainerIntMap, paramKey, value)
endFunction

function SetString(int paramKey, string value)
    JIntMap.setStr(_actorVarsContainerIntMap, paramKey, value)
endFunction

string function GetString(int paramKey)
    return JIntMap.getStr(_actorVarsContainerIntMap, paramKey)
endFunction

function __init()
    _actorVarsContainer = JMap.object()
    JValue.retain(_actorVarsContainer)

    _actorVarsContainerIntMap = JIntMap.object()
    JValue.retain(_actorVarsContainerIntMap)
    Debug(self, "__init", "Initialized Actor Vars Container")
endFunction

int function GetContainer()
    return _actorVarsContainer
endFunction

int _actorVarsContainer
int _actorVarsContainerIntMap