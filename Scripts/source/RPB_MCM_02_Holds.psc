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

function RenderPrisonsEx(RPB_MCM_02 mcm, Faction akCrimeFaction = none, Actor akActor = none) global
    RPB_API api     = mcm.API
    RPB_Config cfg  = api.Config

    if (!akCrimeFaction)
        akCrimeFaction = cfg.GetFaction(mcm.CurrentPage) ; Assume current page is hold (Player)
    endif

    if (!akActor)
        akActor = cfg.Player
    endif

    string hold = akCrimeFaction.GetName()
    RPB_Prison holdPrison = api.PrisonManager.GetPrison(hold) ; Later 1:N (Hold to Prison), for now just one prison per hold

    if (!holdPrison)
        Debug("MCM_02_Holds::RenderPrisonsEx", "There was no prison found, cannot render hold!")
        return
    endif

    string actorName = akActor.GetBaseObject().GetName()

    ; RenderHoldInfoHeader(mcm, holdPrison)

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
; ==========================================================
;                           Left
; ==========================================================

    mcm.AddOptionText("", hold + " Statistics - " + actorName, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()




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

    string lastJailedPrisonId   = RPB_StorageVars.GetStringOnReference("Last Jailed - Prison", holdCrimeFaction, "PrisonLastJailed")
    bool hasLastJailedPrison = RPB_Utility.WasPlayerLastJailedInHold(holdCrimeFaction)
    bool isLastJailedPrison  = hasLastJailedPrison && holdPrison.UUID == lastJailedPrisonId

    ; mcm.AddOptionText("", hold + " Statistics", defaultFlags = mcm.OPTION_DISABLED)
    ; mcm.AddEmptyOption()

    DisplayHoldInfo(mcm, player, holdPrison)

    ; if (isLastJailedPrison)
    ;     if (isPlayerImprisoned)
    ;         RPB_Prisoner playerPrisoner = holdPrison.AwaitPrisonerReference(Game.GetForm(0x14) as Actor)
    ;         string cellId = playerPrisoner.JailCell.ID
    ;         mcm.AddOptionText("", "Currently Jailed", defaultFlags = mcm.OPTION_DISABLED)
    ;         mcm.AddOptionText("", "In " + holdPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
    ;     else
    ;         int lastJailedDay       = RPB_Utility.GetPlayerPrisonLastJailedTime("Day", holdCrimeFaction)
    ;         int lastJailedMonth     = RPB_Utility.GetPlayerPrisonLastJailedTime("Month", holdCrimeFaction)
    ;         int lastJailedYear      = RPB_Utility.GetPlayerPrisonLastJailedTime("Year", holdCrimeFaction)

    ;         mcm.AddOptionText("", "Last Jailed On " + RPB_Utility.GetDateFormat(lastJailedDay, lastJailedMonth, lastJailedYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
    ;         mcm.AddOptionText("", "In " + holdPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
    ;     endif

    ;     mcm.AddEmptyOption()
    ;     if (!isPlayerImprisoned)
    ;         int lastReleasedPrison = RPB_StorageVars.GetIntOnReference("Last Released - Prison", holdCrimeFaction, "PrisonLastReleased")

    ;         if (lastReleasedPrison)
    ;             int releaseDay       = RPB_Utility.GetPlayerPrisonLastReleasedTime("Day", holdCrimeFaction)
    ;             int releaseMonth     = RPB_Utility.GetPlayerPrisonLastReleasedTime("Month", holdCrimeFaction)
    ;             int releaseYear      = RPB_Utility.GetPlayerPrisonLastReleasedTime("Year", holdCrimeFaction)
    ;             mcm.AddOptionText("", "Released On " + RPB_Utility.GetDateFormat(releaseDay, releaseMonth, releaseYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
            
    ;         else
    ;             ; No Release, check for Escape
    ;             int lastEscapedPrison = RPB_StorageVars.GetIntOnReference("Last Escaped - Prison", holdCrimeFaction, "PrisonLastEscaped")
    ;             if (lastEscapedPrison)
    ;                 int escapeDay       = RPB_Utility.GetPlayerPrisonLastEscapedTime("Day", holdCrimeFaction)
    ;                 int escapeMonth     = RPB_Utility.GetPlayerPrisonLastEscapedTime("Month", holdCrimeFaction)
    ;                 int escapeYear      = RPB_Utility.GetPlayerPrisonLastEscapedTime("Year", holdCrimeFaction)
    ;                 mcm.AddOptionText("", "Escaped On " + RPB_Utility.GetDateFormat(escapeDay, escapeMonth, escapeYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
    ;             endif
    ;         endif

    ;     endif
    ; else ; TODO: Add case to display "Last Arrested on Xth of Month, 4E 2XX, In Hold"
    ;     mcm.AddOptionText("", "You have not been arrested", defaultFlags = mcm.OPTION_DISABLED)
    ;     mcm.AddOptionText("", "In " + hold, defaultFlags = mcm.OPTION_DISABLED)
    ;     mcm.AddEmptyOption()
    ;     ; mcm.AddOptionText("", "In any of " + hold + "'s prisons", defaultFlags = mcm.OPTION_DISABLED) ; Saved for future updates when 1:N Hold to Prison
    ; endif
    
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
    ; if (isLastJailedPrison && !isPlayerImprisoned)
    ;     mcm.AddEmptyOption()
    ; endif

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

    ; DisplayHoldInfoHeader(mcm, holdPrison)

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
    Displays the Header section info with the status of this Actor for the Hold.
/;
function DisplayHoldInfo(RPB_MCM_02 mcm, Actor akActor, RPB_Prison apPrison = none) global
    RPB_API api                     = mcm.API
    RPB_Config cfg                  = api.Config
    RPB_PrisonManager prisonManager = api.PrisonManager

    string actorName        = akActor.GetBaseObject().GetName()
    string hold             = apPrison.Hold
    Faction crimeFaction    = apPrison.PrisonFaction
    bool isPrisoner         = apPrison.IsActorPrisoner(akActor)
    bool isArrested         = RPB_Utility.IsActorArrested(akActor)

    mcm.AddOptionText("", hold + " Statistics - " + actorName, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()

    if (isArrested)
        mcm.AddOptionText("", "Currently Arrested", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddEmptyOption()
        mcm.AddEmptyOption()
        return
    endif

    if (isPrisoner)
        RPB_Prisoner prisoner   = apPrison.GetPrisoner(akActor)
        string cellId = prisoner.JailCell.ID
        ; mcm.AddOptionText("", "Currently Jailed", defaultFlags = mcm.OPTION_DISABLED)
        ; mcm.AddOptionText("", "In " + apPrison.Name + ", " + cellId, defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", "Currently In Prison", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", apPrison.Name + ", " + cellId, defaultFlags = mcm.OPTION_DISABLED)
        
        mcm.AddEmptyOption()
        return
    endif

    ; Check if not a prisoner anymore, display last jailed at, and where it happened (How to know which to display, state is the same for all 3)
    ; bool hasLastJailedPrison = RPB_Utility.WasPlayerLastJailedInHold(crimeFaction)
    ; if (hasLastJailedPrison)
    ;     string lastJailedPrisonId   = RPB_StorageVars.GetStringOnReference("Last Jailed - Prison", crimeFaction, "PrisonLastJailed")
    ;     bool isLastJailedPrison     = apPrison.UUID == lastJailedPrisonId
    ;     int lastJailedDay       = RPB_Utility.GetPlayerPrisonLastJailedTime("Day", crimeFaction)
    ;     int lastJailedMonth     = RPB_Utility.GetPlayerPrisonLastJailedTime("Month", crimeFaction)
    ;     int lastJailedYear      = RPB_Utility.GetPlayerPrisonLastJailedTime("Year", crimeFaction)

    ;     mcm.AddOptionText("", "Last Jailed On " + RPB_Utility.GetDateFormat(lastJailedDay, lastJailedMonth, lastJailedYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
    ;     mcm.AddOptionText("", "In " + apPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
    ;     mcm.AddEmptyOption()
    ;     return
    ; endif

    ; Check if not a prisoner anymore, released on {date -> day month year} (How to know which to display, state is the same for all 3)
    int lastReleasedPrison = RPB_StorageVars.GetIntOnReference("Last Released - Prison", crimeFaction, "PrisonLastReleased")
    if (lastReleasedPrison)
        int releaseDay       = RPB_Utility.GetPlayerPrisonLastReleasedTime("Day", crimeFaction)
        int releaseMonth     = RPB_Utility.GetPlayerPrisonLastReleasedTime("Month", crimeFaction)
        int releaseYear      = RPB_Utility.GetPlayerPrisonLastReleasedTime("Year", crimeFaction)
        mcm.AddOptionText("", "Released On " + RPB_Utility.GetDateFormat(releaseDay, releaseMonth, releaseYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", "From " + apPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
        ; mcm.AddEmptyOption()
        mcm.AddEmptyOption()
        return
    endif

    ; Check if not a prisoner anymore, escaped on {date -> day month year} (How to know which to display, state is the same for all 3)
    int lastEscapedPrison = RPB_StorageVars.GetIntOnReference("Last Escaped - Prison", crimeFaction, "PrisonLastEscaped")
    if (lastEscapedPrison)
        int escapeDay       = RPB_Utility.GetPlayerPrisonLastEscapedTime("Day", crimeFaction)
        int escapeMonth     = RPB_Utility.GetPlayerPrisonLastEscapedTime("Month", crimeFaction)
        int escapeYear      = RPB_Utility.GetPlayerPrisonLastEscapedTime("Year", crimeFaction)
        mcm.AddOptionText("", "Escaped On " + RPB_Utility.GetDateFormat(escapeDay, escapeMonth, escapeYear, format = "D M Y"), defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", "From " + apPrison.Name, defaultFlags = mcm.OPTION_DISABLED)
        ; mcm.AddEmptyOption()
        mcm.AddEmptyOption()
        return
    endif

    ; Else display Actor has not been arrested in {hold} yet
    ; TODO: Add case to display "Last Arrested on Xth of Month, 4E 2XX, In Hold"
    mcm.AddOptionText("", "You have not been arrested", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("", "In " + hold, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
endFunction

;/
    Displays the Header section info with the Hold stats.
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
    Faction holdFaction = apPrison.PrisonFaction
    float bench = StartBenchmark()
    apPrison.UpdateInfamyLost(akActor)

    RPB_Actor actorState = RPB_Actor.GetActorStateReference(akActor)

    if (!actorState)
        RPB_Actor.ApplyEffect(akActor)
        RPB_BountyDecayable.Attach(akActor)
    endif

    if (actorState)
        (actorState.GetScriptState(RPB_BountyDecayable.className()) as RPB_BountyDecayable).UpdateBountyLost(holdFaction)
    endif

    EndBenchmark(bench, "RefreshActorUI")
endFunction