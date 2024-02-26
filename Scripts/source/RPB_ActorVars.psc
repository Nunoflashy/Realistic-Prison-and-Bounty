scriptname RPB_ActorVars hidden

import RPB_StorageVars
import RPB_Utility

; ==========================================================
;                           Setters
; ==========================================================

function SetStat(string asStatName, Faction akFaction, Actor akActor, int aiValue) global
    SetIntOnForm(akFaction.GetName() + "::" + asStatName, akActor, aiValue, "ActorVars")
endFunction

function SetCrimeGold(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Bounty Non-Violent", akActor, value, "ActorVars")
endFunction

function SetCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Bounty Violent", akActor, value, "ActorVars")
endFunction

function SetCurrentBounty(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Current Bounty", akActor, value, "ActorVars")
endFunction

function SetLargestBounty(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Largest Bounty", akActor, value, "ActorVars")
endFunction

function SetTotalBounty(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Total Bounty", akActor, value, "ActorVars")
endFunction

function SetTimesArrested(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Times Arrested", akActor, value, "ActorVars")
endFunction

function SetTimesFrisked(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Times Frisked", akActor, value, "ActorVars")
endFunction

function SetTimeJailed(Faction akFaction, Actor akActor, float value) global
    SetFloatOnForm(akFaction.GetName() + "::Time Jailed", akActor, value, "ActorVars")
endFunction

function SetLongestSentence(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Longest Sentence", akActor, value, "ActorVars")
endFunction

function SetLastSentence(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Last Sentence", akActor, value, "ActorVars")
endFunction

function SetTimesJailed(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Times Jailed", akActor, value, "ActorVars")
endFunction

function SetTimesEscaped(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Times Escaped", akActor, value, "ActorVars")
endFunction

function SetTimesStripped(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Times Stripped", akActor, value, "ActorVars")
endFunction

function SetCurrentInfamy(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Current Infamy", akActor, value, "ActorVars")
endFunction

;                       Prison Related
; ==========================================================
function SetTimeJailedInPrison(RPB_Prison apPrison, RPB_Prisoner apPrisoner, float value) global
    SetFloatOnForm(apPrison.Name + "::Time Jailed", apPrisoner.GetActor(), value, "ActorVars")
endFunction

float function GetTimeJailedInPrison(RPB_Prison apPrison, Actor akActor) global
    return GetFloatOnForm(apPrison.Name + "::Time Jailed", akActor, "ActorVars")
endFunction



; ==========================================================
;                           Getters
; ==========================================================

int function GetStat(string asStatName, Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::" + asStatName, akActor, "ActorVars")
endFunction

int function GetCrimeGold(Faction akFaction, Actor akActor) global
    return  GetIntOnForm(akFaction.GetName() + "::Bounty Non-Violent", akActor, "ActorVars") + \
            GetIntOnForm(akFaction.GetName() + "::Bounty Violent", akActor, "ActorVars")
endFunction

int function GetCrimeGoldNonViolent(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Bounty Non-Violent", akActor, "ActorVars")
endFunction

int function GetCrimeGoldViolent(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Bounty Violent", akActor, "ActorVars")
endFunction

int function GetCurrentBounty(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Current Bounty", akActor, "ActorVars")
endFunction

int function GetLargestBounty(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Largest Bounty", akActor, "ActorVars")
endFunction

int function GetTotalBounty(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Total Bounty", akActor, "ActorVars")
endFunction

int function GetTimesArrested(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Times Arrested", akActor, "ActorVars")
endFunction

int function GetTimesFrisked(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Times Frisked", akActor, "ActorVars")
endFunction

float function GetTimeJailed(Faction akFaction, Actor akActor) global
    return GetFloatOnForm(akFaction.GetName() + "::Time Jailed", akActor, "ActorVars")
endFunction

int function GetLongestSentence(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Longest Sentence", akActor, "ActorVars")
endFunction

int function GetLastSentence(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Last Sentence", akActor, "ActorVars")
endFunction

int function GetTimesJailed(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Times Jailed", akActor, "ActorVars")
endFunction

int function GetTimesEscaped(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Times Escaped", akActor, "ActorVars")
endFunction

int function GetTimesStripped(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Times Stripped", akActor, "ActorVars")
endFunction

int function GetCurrentInfamy(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Current Infamy", akActor, "ActorVars")
endFunction

; ==========================================================
;                    Deletion & Management
; ==========================================================

function DeleteActorVars() global
    DeleteCategory("ActorVars")
endFunction

function DeleteFromForm(Form akForm) global
    DeleteCategoryOnForm(akForm, "ActorVars")
endFunction

function Unset(string asVarKey, Form akForm = none) global
    if (akForm)
        DeleteVariableOnForm(asVarKey, akForm, "ActorVars")
    else
        DeleteVariable(asVarKey, "ActorVars")
    endif
endFunction