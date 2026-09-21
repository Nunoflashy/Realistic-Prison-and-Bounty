scriptname RPB_ActorVars hidden

;/
@functions:
    function SetStat(string asStatName, Faction akFaction, Actor akActor, int aiValue) global
    function SetStatFloat(string asStatName, Faction akFaction, Actor akActor, float afValue) global
    function SetCrimeGold(Faction akFaction, Actor akActor, int value) global
    function SetCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    function SetLatentCrimeGold(Faction akFaction, Actor akActor, int value) global
    function SetLatentCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    function SetLargestBounty(Faction akFaction, Actor akActor, int value) global
    function SetTotalBounty(Faction akFaction, Actor akActor, int value) global
    function SetTimesArrested(Faction akFaction, Actor akActor, int value) global
    function SetTimesFrisked(Faction akFaction, Actor akActor, int value) global
    function SetTimeJailed(Faction akFaction, Actor akActor, float value) global
    function SetLongestSentence(Faction akFaction, Actor akActor, int value) global
    function SetLastSentence(Faction akFaction, Actor akActor, int value) global
    function SetTimesJailed(Faction akFaction, Actor akActor, int value) global
    function SetTimesEscaped(Faction akFaction, Actor akActor, int value) global
    function SetTimesStripped(Faction akFaction, Actor akActor, int value) global
    function SetTimesStrippedInPrison(RPB_Prison apPrison, Actor akActor, int value) global
    function SetCurrentInfamy(Faction akFaction, Actor akActor, int value) global
    function ModStat(string asStatName, Faction akFaction, Actor akActor, int value) global
    function ModCrimeGold(Faction akFaction, Actor akActor, int value, bool abViolent = false) global
    function ModCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    function ModLatentCrimeGold(Faction akFaction, Actor akActor, int value, bool abViolent = false) global
    function ModLargestBounty(Faction akFaction, Actor akActor, int value) global
    function ModTotalBounty(Faction akFaction, Actor akActor, int value) global
    function ModTimesArrested(Faction akFaction, Actor akActor, int value) global
    function ModTimesFrisked(Faction akFaction, Actor akActor, int value) global
    function ModTimeJailed(Faction akFaction, Actor akActor, float value) global
    function ModLongestSentence(Faction akFaction, Actor akActor, int value) global
    function ModLastSentence(Faction akFaction, Actor akActor, int value) global
    function ModTimesJailed(Faction akFaction, Actor akActor, int value) global
    function ModTimesEscaped(Faction akFaction, Actor akActor, int value) global
    function ModTimesStripped(Faction akFaction, Actor akActor, int value) global
    function ModCurrentInfamy(Faction akFaction, Actor akActor, int value) global
    function IncrementStat(string asStatName, Faction akFaction, Actor akActor, int aiIncrementBy = 1) global
    function DecrementStat(string asStatName, Faction akFaction, Actor akActor, int aiDecrementBy = 1) global
    function ModifyStat(string asStatName, Faction akFaction, Actor akActor, float modifyBy) global
    function SetTimeJailedInPrison(RPB_Prison apPrison, RPB_Prisoner apPrisoner, float value) global
    float function GetTimeJailedInPrison(RPB_Prison apPrison, Actor akActor) global
    int function GetStat(string asStatName, Faction akFaction, Actor akActor) global
    float function GetStatFloat(string asStatName, Faction akFaction, Actor akActor) global
    int function GetCrimeGold(Faction akFaction, Actor akActor) global
    int function GetCrimeGoldNonViolent(Faction akFaction, Actor akActor) global
    int function GetCrimeGoldViolent(Faction akFaction, Actor akActor) global
    int function GetLatentCrimeGold(Faction akFaction, Actor akActor) global
    int function GetLatentCrimeGoldNonViolent(Faction akFaction, Actor akActor) global
    int function GetLatentCrimeGoldViolent(Faction akFaction, Actor akActor) global
    int function GetLargestBounty(Faction akFaction, Actor akActor) global
    int function GetTotalBounty(Faction akFaction, Actor akActor) global
    int function GetTimesArrested(Faction akFaction, Actor akActor) global
    int function GetTimesFrisked(Faction akFaction, Actor akActor) global
    int function GetArrestsEluded(Faction akFaction, Actor akActor) global
    int function GetArrestsResisted(Faction akFaction, Actor akActor) global
    int function GetBountiesPaid(Faction akFaction, Actor akActor) global
    float function GetTimeJailed(Faction akFaction, Actor akActor) global
    int function GetLongestSentence(Faction akFaction, Actor akActor) global
    int function GetLastSentence(Faction akFaction, Actor akActor) global
    int function GetTimesJailed(Faction akFaction, Actor akActor) global
    int function GetTimesEscaped(Faction akFaction, Actor akActor) global
    int function GetTimesStripped(Faction akFaction, Actor akActor) global
    int function GetCurrentInfamy(Faction akFaction, Actor akActor) global
    function DeleteActorVars() global
    function DeleteFromForm(Form akForm) global
    function Unset(string asVarKey, Form akForm = none) global
@events:
/;

import RPB_StorageVars
import RPB_Utility

; ==========================================================
;                           Setters
; ==========================================================

function SetStat(string asStatName, Faction akFaction, Actor akActor, int aiValue) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::" + asStatName, akActor, aiValue, "ActorVars")
endFunction

function SetStatFloat(string asStatName, Faction akFaction, Actor akActor, float afValue) global
    SetFloatOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::" + asStatName, akActor, afValue, "ActorVars")
endFunction

function SetCrimeGold(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Bounty Non-Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
endFunction

function SetCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Bounty Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
endFunction

function SetLatentCrimeGold(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Latent Bounty Non-Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
endFunction

function SetLatentCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Latent Bounty Violent", akActor, value, "ActorVars", abDeleteOnNull = true)
endFunction

function SetLargestBounty(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Largest Bounty", akActor, value, "ActorVars")
endFunction

function SetTotalBounty(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Total Bounty", akActor, value, "ActorVars")
endFunction

function SetTimesArrested(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Arrested", akActor, value, "ActorVars")
endFunction

function SetTimesFrisked(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Frisked", akActor, value, "ActorVars")
endFunction

function SetTimeJailed(Faction akFaction, Actor akActor, float value) global
    SetFloatOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Time Jailed", akActor, value, "ActorVars")
endFunction

function SetLongestSentence(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Longest Sentence", akActor, value, "ActorVars")
endFunction

function SetLastSentence(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Last Sentence", akActor, value, "ActorVars")
endFunction

function SetTimesJailed(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Jailed", akActor, value, "ActorVars")
endFunction

function SetTimesEscaped(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Escaped", akActor, value, "ActorVars")
endFunction

function SetTimesStripped(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Stripped", akActor, value, "ActorVars")
endFunction

function SetTimesStrippedInPrison(RPB_Prison apPrison, Actor akActor, int value) global
    SetIntOnReference(apPrison.Name + "::Times Stripped", akActor, value, "ActorVars")
endFunction

function SetCurrentInfamy(Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Infamy Gained", akActor, value, "ActorVars")
endFunction


; ==========================================================
;                           Modifiers
; ==========================================================

function ModStat(string asStatName, Faction akFaction, Actor akActor, int value) global
    SetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::" + asStatName, akActor, value, "ActorVars")
endFunction

function ModCrimeGold(Faction akFaction, Actor akActor, int value, bool abViolent = false) global
    string bountyType = "Bounty Non-Violent"

    if (abViolent)
        bountyType = "Bounty Violent"
    endif

    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::" + bountyType
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor, "ActorVars") + value, "ActorVars", abDeleteOnNull = true)
endFunction

function ModCrimeGoldViolent(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Bounty Violent"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor, "ActorVars") + value, "ActorVars", abDeleteOnNull = true)
endFunction

function ModLatentCrimeGold(Faction akFaction, Actor akActor, int value, bool abViolent = false) global
    string bountyType = "Latent Bounty Non-Violent"

    if (abViolent)
        bountyType = "Latent Bounty Violent"
    endif

    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::" + bountyType
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor, "ActorVars") + value, "ActorVars", abDeleteOnNull = true)

    ; Debug("ActorVars::ModLatentCrimeGold", "Stat Key: " + statKey + ", New Value: " + GetIntOnReference(statKey, akActor, "ActorVars"))
endFunction

function ModLargestBounty(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Largest Bounty"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTotalBounty(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Total Bounty"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTimesArrested(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Times Arrested"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTimesFrisked(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Times Frisked"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor, "ActorVars") + value, "ActorVars")
endFunction

function ModTimeJailed(Faction akFaction, Actor akActor, float value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Time Jailed"
    SetFloatOnReference(statKey, akActor, GetFloatOnReference(statKey, akActor) + value, "ActorVars")
endFunction

function ModLongestSentence(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Longest Sentence"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor) + value, "ActorVars")
endFunction

function ModLastSentence(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Last Sentence"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor) + value, "ActorVars")
endFunction

function ModTimesJailed(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Times Jailed"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor) + value, "ActorVars")
endFunction

function ModTimesEscaped(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Times Escaped"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor) + value, "ActorVars")
endFunction

function ModTimesStripped(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Times Stripped"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor) + value, "ActorVars")
endFunction

function ModCurrentInfamy(Faction akFaction, Actor akActor, int value) global
    string statKey = RPB_Utility.GetFormNameCached(akFaction) + "::Infamy Gained"
    SetIntOnReference(statKey, akActor, GetIntOnReference(statKey, akActor) + value, "ActorVars")
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

    ; if (asStatName == "Time Jailed")
        ; Debug("ActorVars::ModifyStat", "Time Jailed: " + currentValue + ", Adding: " + modifyBy + ", New Value: " + GetStatFloat(asStatName, akFaction, akActor))
    ; endif
endFunction


;                       Prison Related
; ==========================================================
; BOTH FUNCTIONS UNUSED
function SetTimeJailedInPrison(RPB_Prison apPrison, RPB_Prisoner apPrisoner, float value) global
    SetFloatOnReference(apPrison.Name + "::Time Jailed", apPrisoner.GetActor(), value, "ActorVars")
endFunction

float function GetTimeJailedInPrison(RPB_Prison apPrison, Actor akActor) global
    return GetFloatOnReference(apPrison.Name + "::Time Jailed", akActor, "ActorVars")
endFunction


; ==========================================================
;                           Getters
; ==========================================================

int function GetStat(string asStatName, Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::" + asStatName, akActor, "ActorVars")
endFunction

float function GetStatFloat(string asStatName, Faction akFaction, Actor akActor) global
    return GetFloatOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::" + asStatName, akActor, "ActorVars")
endFunction

int function GetCrimeGold(Faction akFaction, Actor akActor) global
    return  GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Bounty Non-Violent", akActor, "ActorVars") + \
            GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Bounty Violent", akActor, "ActorVars")
endFunction

int function GetCrimeGoldNonViolent(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Bounty Non-Violent", akActor, "ActorVars")
endFunction

int function GetCrimeGoldViolent(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Bounty Violent", akActor, "ActorVars")
endFunction

int function GetLatentCrimeGold(Faction akFaction, Actor akActor) global
    return  GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Latent Bounty Non-Violent", akActor, "ActorVars") + \
            GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Latent Bounty Violent", akActor, "ActorVars")
endFunction

int function GetLatentCrimeGoldNonViolent(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Latent Bounty Non-Violent", akActor, "ActorVars")
endFunction

int function GetLatentCrimeGoldViolent(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Latent Bounty Violent", akActor, "ActorVars")
endFunction

int function GetLargestBounty(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Largest Bounty", akActor, "ActorVars")
endFunction

int function GetTotalBounty(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Total Bounty", akActor, "ActorVars")
endFunction

int function GetTimesArrested(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Arrested", akActor, "ActorVars")
endFunction

int function GetTimesFrisked(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Frisked", akActor, "ActorVars")
endFunction

int function GetArrestsEluded(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Arrests Eluded", akActor, "ActorVars")
endFunction

int function GetArrestsResisted(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Arrests Resisted", akActor, "ActorVars")
endFunction

int function GetBountiesPaid(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Bounties Paid", akActor, "ActorVars")
endFunction

float function GetTimeJailed(Faction akFaction, Actor akActor) global
    return GetFloatOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Time Jailed", akActor, "ActorVars")
endFunction

int function GetLongestSentence(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Longest Sentence", akActor, "ActorVars")
endFunction

int function GetLastSentence(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Last Sentence", akActor, "ActorVars")
endFunction

int function GetTimesJailed(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Jailed", akActor, "ActorVars")
endFunction

int function GetTimesEscaped(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Escaped", akActor, "ActorVars")
endFunction

int function GetTimesStripped(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Times Stripped", akActor, "ActorVars")
endFunction

int function GetCurrentInfamy(Faction akFaction, Actor akActor) global
    return GetIntOnReference(RPB_Utility.GetFormNameCached(akFaction) + "::Infamy Gained", akActor, "ActorVars")
endFunction

; ==========================================================
;                    Deletion & Management
; ==========================================================

function DeleteActorVars() global
    DeleteCategory("ActorVars")
endFunction

function DeleteFromForm(Form akForm) global
    DeleteCategoryOnReference(akForm, "ActorVars")
endFunction

function Unset(string asVarKey, Form akForm = none) global
    if (akForm)
        DeleteVariableOnReference(asVarKey, akForm, "ActorVars")
    else
        DeleteVariable(asVarKey, "ActorVars")
    endif
endFunction