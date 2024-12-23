scriptname RPB_ActorVars hidden

import RPB_StorageVars
import RPB_Utility

; ==========================================================
;                           Setters
; ==========================================================

function SetStat(string asStatName, Faction akFaction, Actor akActor, int aiValue) global
    SetIntOnForm(akFaction.GetName() + "::" + asStatName, akActor, aiValue, "ActorVars")
endFunction

function SetStatFloat(string asStatName, Faction akFaction, Actor akActor, float afValue) global
    SetFloatOnForm(akFaction.GetName() + "::" + asStatName, akActor, afValue, "ActorVars")
endFunction

function SetCrimeGold(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Bounty Non-Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
endFunction

function SetCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Bounty Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
endFunction

function SetLatentCrimeGold(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Latent Bounty Non-Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
endFunction

function SetLatentCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Latent Bounty Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
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

function SetTimesStrippedInPrison(RPB_Prison apPrison, Actor akActor, int value) global
    SetIntOnForm(apPrison.Name + "::Times Stripped", akActor, value, "ActorVars")
endFunction

function SetCurrentInfamy(Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::Infamy Gained", akActor, value, "ActorVars")
endFunction


; ==========================================================
;                           Modifiers
; ==========================================================

function ModStat(string asStatName, Faction akFaction, Actor akActor, int value) global
    SetIntOnForm(akFaction.GetName() + "::" + asStatName, akActor, value, "ActorVars")
endFunction

function ModCrimeGold(Faction akFaction, Actor akActor, int value, bool abViolent = false) global
    string bountyType = "Bounty Non-Violent"

    if (abViolent)
        bountyType = "Bounty Violent"
    endif

    string statKey = akFaction.GetName() + "::" + bountyType
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor, "ActorVars") + value, "ActorVars", abDeleteOnNull = true)
endFunction

function ModCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Bounty Violent"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor, "ActorVars") + value, "ActorVars", abDeleteOnNull = true)
endFunction

function ModLatentCrimeGold(Faction akFaction, Actor akActor, int value, bool abViolent = false) global
    string bountyType = "Latent Bounty Non-Violent"

    if (abViolent)
        bountyType = "Latent Bounty Violent"
    endif

    string statKey = akFaction.GetName() + "::" + bountyType
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor, "ActorVars") + value, "ActorVars", abDeleteOnNull = true)

    Debug("ActorVars::ModLatentCrimeGold", "Stat Key: " + statKey + ", New Value: " + GetIntOnForm(statKey, akActor, "ActorVars"))
endFunction

function ModLargestBounty(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Largest Bounty"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTotalBounty(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Total Bounty"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTimesArrested(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Times Arrested"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTimesFrisked(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Times Frisked"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTimeJailed(Faction akFaction, Actor akActor, float value) global
    string statKey = akFaction.GetName() + "::Time Jailed"
    SetFloatOnForm(statKey, akActor, GetFloatOnForm(statKey, akActor) + value, "ActorVars")
endFunction

function ModLongestSentence(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Longest Sentence"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor) + value, "ActorVars")
endFunction

function ModLastSentence(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Last Sentence"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor) + value, "ActorVars")
endFunction

function ModTimesJailed(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Times Jailed"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor) + value, "ActorVars")
endFunction

function ModTimesEscaped(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Times Escaped"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor) + value, "ActorVars")
endFunction

function ModTimesStripped(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Times Stripped"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor) + value, "ActorVars")
endFunction

function ModCurrentInfamy(Faction akFaction, Actor akActor, int value) global
    string statKey = akFaction.GetName() + "::Infamy Gained"
    SetIntOnForm(statKey, akActor, GetIntOnForm(statKey, akActor) + value, "ActorVars")
endFunction

function IncrementStat(string asStatName, Faction akFaction, Actor akActor, int aiIncrementBy = 1) global
    int currentValue = GetStat(asStatName, akFaction, akActor)
    SetStat(asStatName, akFaction, akActor, currentValue + aiIncrementBy)
endFunction

function DecrementStat(string asStatName, Faction akFaction, Actor akActor, int aiDecrementBy = 1) global
    int currentValue = GetStat(asStatName, akFaction, akActor)
    SetStat(asStatName, akFaction, akActor, currentValue - aiDecrementBy)
endFunction

function ModifyStat(string asStatName, Faction akFaction, Actor akActor, float modifyBy) global
    float currentValue = GetStatFloat(asStatName, akFaction, akActor)
    SetStatFloat(asStatName, akFaction, akActor, currentValue + modifyBy)

    if (asStatName == "Time Jailed")
        Debug("ActorVars::ModifyStat", "Time Jailed: " + currentValue + ", Adding: " + modifyBy + ", New Value: " + GetStatFloat(asStatName, akFaction, akActor))
    endif
endFunction


;                       Prison Related
; ==========================================================
; BOTH FUNCTIONS UNUSED
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

float function GetStatFloat(string asStatName, Faction akFaction, Actor akActor) global
    return GetFloatOnForm(akFaction.GetName() + "::" + asStatName, akActor, "ActorVars")
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

int function GetLatentCrimeGold(Faction akFaction, Actor akActor) global
    return  GetIntOnForm(akFaction.GetName() + "::Latent Bounty Non-Violent", akActor, "ActorVars") + \
            GetIntOnForm(akFaction.GetName() + "::Latent Bounty Violent", akActor, "ActorVars")
endFunction

int function GetLatentCrimeGoldNonViolent(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Latent Bounty Non-Violent", akActor, "ActorVars")
endFunction

int function GetLatentCrimeGoldViolent(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Latent Bounty Violent", akActor, "ActorVars")
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

int function GetArrestsEluded(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Arrests Eluded", akActor, "ActorVars")
endFunction

int function GetArrestsResisted(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Arrests Resisted", akActor, "ActorVars")
endFunction

int function GetBountiesPaid(Faction akFaction, Actor akActor) global
    return GetIntOnForm(akFaction.GetName() + "::Bounties Paid", akActor, "ActorVars")
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
    return GetIntOnForm(akFaction.GetName() + "::Infamy Gained", akActor, "ActorVars")
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