Scriptname RPB_MCM_02_Holds hidden

import RPB_Utility
import RPB_MCM_02

bool function ShouldHandleEvent(RPB_MCM_02 mcm) global
    return mcm.IsHoldCurrentPage()
endFunction

function RenderPrisonLeft(RPB_MCM_02 mcm, RPB_Prison apPrison, Actor akActor) global
    Faction prisonFaction = apPrison.PrisonFaction

    float timeJailed        = RPB_ActorVars.GetTimeJailed(prisonFaction, akActor)
    int lastSentence        = RPB_ActorVars.GetLastSentence(prisonFaction, akActor)
    int longestSentence     = RPB_ActorVars.GetLongestSentence(prisonFaction, akActor)
    int currentInfamy       = RPB_ActorVars.GetCurrentInfamy(prisonFaction, akActor)

    mcm.AddOptionCategory(apPrison.Name, flags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Time Jailed", RPB_Utility.GetTimeFormatted(timeJailed, asNullValue = "N/A"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Last Sentence", RPB_Utility.GetTimeFormatted(lastSentence, asNullValue = "N/A"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Longest Sentence", RPB_Utility.GetTimeFormatted(longestSentence, asNullValue = "N/A"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Infamy Gained", currentInfamy + " Infamy", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
endFunction

function RenderPrisonRight(RPB_MCM_02 mcm, RPB_Prison apPrison, Actor akActor) global
    Faction prisonFaction = apPrison.PrisonFaction

    int timesFrisked    = RPB_ActorVars.GetTimesFrisked(prisonFaction, akActor)
    int timesStripped   = RPB_ActorVars.GetTimesStripped(prisonFaction, akActor)
    int timesJailed     = RPB_ActorVars.GetTimesJailed(prisonFaction, akActor)
    int timesEscaped    = RPB_ActorVars.GetTimesEscaped(prisonFaction, akActor)

    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)

    mcm.AddOptionText("Times Jailed", timesJailed, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Times Escaped", timesEscaped, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Times Frisked", timesFrisked, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Times Stripped", timesStripped, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
endFunction

function RenderPrisons(RPB_MCM_02 mcm) global
    string hold = mcm.CurrentPage

    bool isPlayerImprisoned     = RPB_Utility.IsPlayerImprisoned()
    Faction holdCrimeFaction    = RPB_Utility.GetCrimeFactionByHold(hold)
    RPB_Prison holdPrison       = RPB_API.GetPrisonManager().GetPrison(hold)

    if (!holdPrison)
        Debug("MCM_02_Holds::RenderPrisons", "There was no prison found, cannot render hold!")
        return
    endif

    Actor player = Game.GetForm(0x14) as Actor

    RefreshActorUI(holdPrison, player)

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    ; ==========================================================
    ;                           Left
    ; ==========================================================

    string lastJailedPrisonId   = RPB_StorageVars.GetStringOnForm("Last Jailed - Prison", holdCrimeFaction, "PrisonLastJailed")
    bool hasLastJailedPrison = RPB_Utility.WasPlayerLastJailedInHold(holdCrimeFaction)
    bool isLastJailedPrison  = hasLastJailedPrison && holdPrison.UUID == lastJailedPrisonId

    mcm.AddOptionText("", hold + " Statistics", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    if (isLastJailedPrison)
        if (isPlayerImprisoned)
            RPB_Prisoner playerPrisoner = holdPrison.AwaitPrisonerReference(Game.GetForm(0x14) as Actor)
            string cellId = playerPrisoner.JailCell.ID
            mcm.AddOptionText("", "Currently Jailed", defaultFlags = mcm.OPTION_DISABLED)
            mcm.AddOptionText("", "In " + holdPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
        else
            int lastJailedDay       = RPB_Utility.GetPlayerPrisonLastJailedTime("Day", holdCrimeFaction)
            int lastJailedMonth     = RPB_Utility.GetPlayerPrisonLastJailedTime("Month", holdCrimeFaction)
            int lastJailedYear      = RPB_Utility.GetPlayerPrisonLastJailedTime("Year", holdCrimeFaction)

            mcm.AddOptionText("", "Last Jailed On " + RPB_Utility.GetDateFormat(lastJailedDay, lastJailedMonth, lastJailedYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
            mcm.AddOptionText("", "In " + holdPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
        endif

        mcm.AddEmptyOption()
        if (!isPlayerImprisoned)
            int lastReleasedPrison = RPB_StorageVars.GetIntOnForm("Last Released - Prison", holdCrimeFaction, "PrisonLastReleased")

            if (lastReleasedPrison)
                int releaseDay       = RPB_Utility.GetPlayerPrisonLastReleasedTime("Day", holdCrimeFaction)
                int releaseMonth     = RPB_Utility.GetPlayerPrisonLastReleasedTime("Month", holdCrimeFaction)
                int releaseYear      = RPB_Utility.GetPlayerPrisonLastReleasedTime("Year", holdCrimeFaction)
                mcm.AddOptionText("", "Released On " + RPB_Utility.GetDateFormat(releaseDay, releaseMonth, releaseYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
            
            else
                ; No Release, check for Escape
                int lastEscapedPrison = RPB_StorageVars.GetIntOnForm("Last Escaped - Prison", holdCrimeFaction, "PrisonLastEscaped")
                if (lastEscapedPrison)
                    int escapeDay       = RPB_Utility.GetPlayerPrisonLastEscapedTime("Day", holdCrimeFaction)
                    int escapeMonth     = RPB_Utility.GetPlayerPrisonLastEscapedTime("Month", holdCrimeFaction)
                    int escapeYear      = RPB_Utility.GetPlayerPrisonLastEscapedTime("Year", holdCrimeFaction)
                    mcm.AddOptionText("", "Escaped On " + RPB_Utility.GetDateFormat(escapeDay, escapeMonth, escapeYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
                endif
            endif

        endif
    else ; TODO: Add case to display "Last Arrested on Xth of Month, 4E 2XX, In Hold"
        mcm.AddOptionText("", "You have not been arrested", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", "In " + hold, defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddEmptyOption()
        ; mcm.AddOptionText("", "In any of " + hold + "'s prisons", defaultFlags = mcm.OPTION_DISABLED) ; Saved for future updates when 1:N Hold to Prison
    endif
    
    ; mcm.AddEmptyOption()
    ; mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    ; mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)

    RenderPrisonLeft(mcm, holdPrison, player)
    ; RenderPrisonLeft(mcm, "Another Test Prison")

    mcm.SetCursorPosition(1)
    ; ==========================================================
    ;                           Right
    ; ==========================================================
    
    DisplayHoldStats(mcm, player, holdCrimeFaction)

    ; Temporary
    if (isLastJailedPrison && !isPlayerImprisoned)
        mcm.AddEmptyOption()
    endif

    mcm.AddEmptyOption()

    RenderPrisonRight(mcm, holdPrison, player)
    ; RenderPrisonRight(mcm, "Another Test Prison")
endFunction

function Render(RPB_MCM_02 mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    RenderPrisons(mcm)
endFunction

; ==========================================================
;                           NPC
; ==========================================================

function NPC_RenderPrisons(RPB_MCM_02 mcm, RPB_Prisoner apPrisoner) global
    RPB_Prison holdPrison       = apPrisoner.Prison
    string hold                 = holdPrison.Hold
    Faction holdCrimeFaction    = RPB_Utility.GetCrimeFactionByHold(hold)

    if (!holdPrison)
        Debug("MCM_02_Holds::NPC_RenderPrisons", "There was no prison found, cannot render hold!")
        return
    endif

     RefreshPrisonerUI(apPrisoner)
    
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    ; ==========================================================
    ;                           Left
    ; ==========================================================

    mcm.AddOptionText("", hold + " Statistics - " + apPrisoner.Name, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    string cellId = apPrisoner.JailCell.ID
    mcm.AddOptionText("", "Currently Jailed", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "In " + holdPrison.Name + ", " + cellId, defaultFlags = mcm.OPTION_DISABLED)
    
    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

    RenderPrisonLeft(mcm, holdPrison, apPrisoner.GetActor())

    mcm.SetCursorPosition(1)
    ; ==========================================================
    ;                           Right
    ; ==========================================================
    
    DisplayHoldStats(mcm, apPrisoner.GetActor(), holdCrimeFaction)

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

    RenderPrisonRight(mcm, holdPrison, apPrisoner.GetActor())
endFunction

; ==========================================================
;                           Helpers
; ==========================================================

;/
    Displays the Header section info with the Hold info.
    The header's values, as well as their positioning, are controlled through the template in the MCM config file.
/;
function DisplayHoldStats(RPB_MCM_02 mcm, Actor akActor, Faction akHoldCrimeFaction) global
    string[] holdPlaceholders   = mcm.HoldStatsPlaceholders
    string[] holdStats = mcm.ConstructHoldStatValues( \
        aiBounty            = RPB_ActorBase.GetCurrentActiveAndLatentBountyForFaction(akActor, akHoldCrimeFaction), \
        aiViolentBounty     = RPB_ActorBase.GetCurrentActiveAndLatentBountyForFaction(akActor, akHoldCrimeFaction, abNonViolent = false), \ 
        aiLargestBounty     = RPB_ActorVars.GetLargestBounty(akHoldCrimeFaction, akActor), \ 
        aiTotalBounty       = RPB_ActorVars.GetTotalBounty(akHoldCrimeFaction, akActor), \ 
        aiTimesArrested     = RPB_ActorVars.GetTimesArrested(akHoldCrimeFaction, akActor), \
        aiTimesFrisked      = RPB_ActorVars.GetTimesFrisked(akHoldCrimeFaction, akActor), \
        aiArrestsEluded     = RPB_ActorVars.GetArrestsEluded(akHoldCrimeFaction, akActor), \ 
        aiArrestsResisted   = RPB_ActorVars.GetArrestsResisted(akHoldCrimeFaction, akActor), \ 
        aiBountiesPaid      = RPB_ActorVars.GetBountiesPaid(akHoldCrimeFaction, akActor) \ 
    )

    int optionIndex = 0
    int optionCount = mcm.HoldStatsTemplate.Length
    while (optionIndex < optionCount)
        string currentStatLineTemplate = mcm.HoldStatsTemplate[optionIndex]
        string statLine = RPB_Utility.Replace(currentStatLineTemplate, holdPlaceholders, holdStats)
        mcm.AddOptionText("", statLine, defaultFlags = mcm.OPTION_DISABLED)
        optionIndex += 1
    endWhile
endFunction

; ==========================================================
;                         UI Refresh
; ==========================================================

function RefreshPrisonerUI(RPB_Prisoner apPrisoner) global
    apPrisoner.UpdateTimeJailed()
    apPrisoner.UpdateInfamy()
endFunction

function RefreshActorUI(RPB_Prison apPrison, Actor akActor) global
    apPrison.UpdateInfamyLost(akActor)
endFunction