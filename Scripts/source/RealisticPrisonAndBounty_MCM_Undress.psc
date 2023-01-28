Scriptname RealisticPrisonAndBounty_MCM_Undress hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Undressing"
endFunction

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == GetPageName()
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)
endFunction

function RenderOptions(RealisticPrisonAndBounty_MCM mcm, int index) global
    mcm.oid_undressing_allow[index] = mcm.AddToggleOption("Allow Undressing", mcm.undressing_allow_state[index])
;     mcm.oid_undressing_allow[index]                         = mcm.AddToggleOption("Allow Undressing",                       bool_if(GetOptionBoolValue(mcm.oid_undressing_allow[index],                         mcm.UNDRESSING_DEFAULT_ALLOW) == TRUE, true, false))
    ; Allow Undressing is off, disable all options, else enabled them.
    int flags = int_if (mcm.undressing_allow_state[mcm.CurrentOptionIndex], mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)

    int redressBountyFlags          = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex], mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)
    int redressWhenDefeatedFlags    = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex], mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)
    int redressAtCellFlags          = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex], mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)
    int redressAtChestFlags         = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex], mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)


    mcm.oid_undressing_whenDefeated[index]                  = mcm.AddToggleOption("Undress when Defeated",                  GetOptionBoolValue(mcm.oid_undressing_whenDefeated[index],                  mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED), flags)
    mcm.oid_undressing_atCell[index]                        = mcm.AddToggleOption("Undress at Cell",                        GetOptionBoolValue(mcm.oid_undressing_atCell[index],                        mcm.UNDRESSING_DEFAULT_AT_CELL), flags)
    mcm.oid_undressing_atChest[index]                       = mcm.AddToggleOption("Undress at Chest",                       GetOptionBoolValue(mcm.oid_undressing_atChest[index],                       mcm.UNDRESSING_DEFAULT_AT_CHEST), flags)
    mcm.oid_undressing_forcedUndressingMinBounty[index]     = mcm.AddSliderOption("Forced Undressing (Minimum Bounty)",     GetOptionIntValue(mcm.oid_undressing_forcedUndressingMinBounty[index],      mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY), "{0} Bounty", flags)
    mcm.oid_undressing_forcedUndressingWhenDefeated[index]  = mcm.AddToggleOption("Forced Undressing when Defeated",        GetOptionBoolValue(mcm.oid_undressing_forcedUndressingWhenDefeated[index],  mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED), flags)
    mcm.oid_undressing_stripSearchThoroughness[index]       = mcm.AddSliderOption("Strip Search Thoroughness",              GetOptionIntValue(mcm.oid_undressing_stripSearchThoroughness[index],        mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS), "{0}x", flags)
    mcm.oid_undressing_allowWearingClothes[index]           = mcm.AddToggleOption("Allow Wearing Clothes",                  GetOptionBoolValue(mcm.oid_undressing_allowWearingClothes[index],           mcm.UNDRESSING_DEFAULT_ALLOW_CLOTHES), flags)

    mcm.oid_undressing_redressBounty[index]                 = mcm.AddSliderOption("Bounty to Re-dress",                     GetOptionIntValue(mcm.oid_undressing_redressBounty[index],                  mcm.UNDRESSING_DEFAULT_REDRESS_BOUNTY), "{0} Bounty", redressBountyFlags)
    mcm.oid_undressing_redressWhenDefeated[index]           = mcm.AddToggleOption("Re-dress when Defeated",                 GetOptionBoolValue(mcm.oid_undressing_redressWhenDefeated[index],           mcm.UNDRESSING_DEFAULT_REDRESS_WHEN_DEFEATED), redressWhenDefeatedFlags)
    mcm.oid_undressing_redressAtCell[index]                 = mcm.AddToggleOption("Re-dress at Cell",                       GetOptionBoolValue(mcm.oid_undressing_redressAtCell[index],                 mcm.UNDRESSING_DEFAULT_REDRESS_AT_CELL), redressAtCellFlags)
    mcm.oid_undressing_redressAtChest[index]                = mcm.AddToggleOption("Re-dress at Chest",                      GetOptionBoolValue(mcm.oid_undressing_redressAtChest[index],                mcm.UNDRESSING_DEFAULT_REDRESS_AT_CHEST), redressAtChestFlags)

endFunction

;  function RenderOptions(RealisticPrisonAndBounty_MCM mcm, int index) global
;     Log(mcm, "Undressing::RenderOptions", "called")

;     mcm.oid_undressing_allow[index]                         = mcm.AddToggleOption("Allow Undressing",                       bool_if(GetOptionBoolValue(mcm.oid_undressing_allow[index],                         mcm.UNDRESSING_DEFAULT_ALLOW) == TRUE, true, false))
;     ; Allow Undressing is off, disable all options, else enabled them.
;     int flags = int_if (GetOptionBoolValue(mcm.oid_undressing_allow[index]), mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)

;     int redressBountyFlags          = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]), mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)
;     int redressWhenDefeatedFlags    = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]), mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)
;     int redressAtCellFlags          = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]), mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)
;     int redressAtChestFlags         = int_if (GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]), mcm.OPTION_ENABLED, mcm.OPTION_DISABLED)

;     mcm.oid_undressing_minimumBounty[index]                 = mcm.AddSliderOption("Minimum Bounty to Undress",              GetOptionIntValue(mcm.oid_undressing_minimumBounty[index],                  mcm.UNDRESSING_DEFAULT_MIN_BOUNTY), "{0} Bounty", flags)
;     mcm.oid_undressing_whenDefeated[index]                  = mcm.AddToggleOption("Undress when Defeated",                  GetOptionBoolValue(mcm.oid_undressing_whenDefeated[index],                  mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED), flags)
;     mcm.oid_undressing_atCell[index]                        = mcm.AddToggleOption("Undress at Cell",                        GetOptionBoolValue(mcm.oid_undressing_atCell[index],                        mcm.UNDRESSING_DEFAULT_AT_CELL), flags)
;     mcm.oid_undressing_atChest[index]                       = mcm.AddToggleOption("Undress at Chest",                       GetOptionBoolValue(mcm.oid_undressing_atChest[index],                       mcm.UNDRESSING_DEFAULT_AT_CHEST), flags)
;     mcm.oid_undressing_forcedUndressingMinBounty[index]     = mcm.AddSliderOption("Forced Undressing (Minimum Bounty)",     GetOptionIntValue(mcm.oid_undressing_forcedUndressingMinBounty[index],      mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY), "{0} Bounty", flags)
;     mcm.oid_undressing_forcedUndressingWhenDefeated[index]  = mcm.AddToggleOption("Forced Undressing when Defeated",        GetOptionBoolValue(mcm.oid_undressing_forcedUndressingWhenDefeated[index],  mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED), flags)
;     mcm.oid_undressing_stripSearchThoroughness[index]       = mcm.AddSliderOption("Strip Search Thoroughness",              GetOptionIntValue(mcm.oid_undressing_stripSearchThoroughness[index],        mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS), "{0}x", flags)
;     mcm.oid_undressing_allowWearingClothes[index]           = mcm.AddToggleOption("Allow Wearing Clothes",                  GetOptionBoolValue(mcm.oid_undressing_allowWearingClothes[index],           mcm.UNDRESSING_DEFAULT_ALLOW_CLOTHES), flags)

;     mcm.oid_undressing_redressBounty[index]                 = mcm.AddSliderOption("Bounty to Re-dress",                     GetOptionIntValue(mcm.oid_undressing_redressBounty[index],                  mcm.UNDRESSING_DEFAULT_REDRESS_BOUNTY), "{0} Bounty", redressBountyFlags)
;     mcm.oid_undressing_redressWhenDefeated[index]           = mcm.AddToggleOption("Re-dress when Defeated",                 GetOptionBoolValue(mcm.oid_undressing_redressWhenDefeated[index],           mcm.UNDRESSING_DEFAULT_REDRESS_WHEN_DEFEATED), redressWhenDefeatedFlags)
;     mcm.oid_undressing_redressAtCell[index]                 = mcm.AddToggleOption("Re-dress at Cell",                       GetOptionBoolValue(mcm.oid_undressing_redressAtCell[index],                 mcm.UNDRESSING_DEFAULT_REDRESS_AT_CELL), redressAtCellFlags)
;     mcm.oid_undressing_redressAtChest[index]                = mcm.AddToggleOption("Re-dress at Chest",                      GetOptionBoolValue(mcm.oid_undressing_redressAtChest[index],                mcm.UNDRESSING_DEFAULT_REDRESS_AT_CHEST), redressAtChestFlags)

    
;     ; mcm.SetOptionDependencyBoolSingle(mcm.oid_undressing_redressBounty[index],       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]))
;     ; mcm.SetOptionDependencyBoolSingle(mcm.oid_undressing_redressWhenDefeated[index], GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]))
;     ; mcm.SetOptionDependencyBoolSingle(mcm.oid_undressing_redressAtCell[index],       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]))
;     ; mcm.SetOptionDependencyBoolSingle(mcm.oid_undressing_redressAtChest[index],      GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[index]) && GetOptionIntValue(mcm.oid_undressing_allow[index]))  

; endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    int i = mcm.LeftPanelIndex
    while (i < mcm.LeftPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    int i = mcm.RightPanelIndex
    while (i < mcm.RightPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction


; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global

    string[] holds = mcm.GetHoldNames()
    string hold = holds[mcm.CurrentOptionIndex]

    int allowUndressing                 = mcm.GetOptionInListByOID(mcm.oid_undressing_allow, oid)
    int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
    int undressWhenDefeated             = mcm.GetOptionInListByOID(mcm.oid_undressing_whenDefeated, oid)
    int undressAtCell                   = mcm.GetOptionInListByOID(mcm.oid_undressing_atCell, oid)
    int undressAtChest                  = mcm.GetOptionInListByOID(mcm.oid_undressing_atChest, oid)
    int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
    int forcedUndressingWhenDefeated    = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingWhenDefeated, oid)
    int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
    int allowWearingClothes             = mcm.GetOptionInListByOID(mcm.oid_undressing_allowWearingClothes, oid)
    int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)
    int redressWhenDefeated             = mcm.GetOptionInListByOID(mcm.oid_undressing_redressWhenDefeated, oid)
    int redressAtCell                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressAtCell, oid)
    int redressAtChest                  = mcm.GetOptionInListByOID(mcm.oid_undressing_redressAtChest, oid)

    if (oid == allowUndressing)
        mcm.SetInfoText("Determines if you can be undressed while imprisoned in " + hold + ".")
    elseif (oid == minimumBounty)
        mcm.SetInfoText("The minimum bounty required to be undressed in " + hold + "'s prison.")
    elseif (oid == undressWhenDefeated)
        mcm.SetInfoText("Whether to have you undressed when defeated and imprisoned in " + hold + ".")
    elseif (oid == undressAtCell)
        mcm.SetInfoText("Whether to be undressed at the cell in " + hold + "'s prison.")
    elseif (oid == undressAtChest)
        mcm.SetInfoText("Whether to be undressed at the chest in "  + hold + "'prison.")
    elseif (oid == forcedUndressingMinBounty)
        mcm.SetInfoText("The minimum bounty required to be force undressed (You will have no possibility of action)")
    elseif (oid == forcedUndressingWhenDefeated)
        mcm.SetInfoText("Whether to be force undressed when defeated and imprisoned in " + hold + ".")
    elseif (oid == stripSearchThoroughness)
        mcm.SetInfoText("The thoroughness of the strip search when undressed, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                 "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped bare.")
    elseif (oid == allowWearingClothes)
        mcm.SetInfoText("Whether to allow wearing clothes while imprisoned in " + hold + ".")
    elseif (oid == redressBounty)
        mcm.SetInfoText("The maximum bounty you can have in order to be re-dressed while imprisoned in " + hold + ".")
    elseif (oid == redressWhenDefeated)
        mcm.SetInfoText("Whether to have you re-dressed when defeated (Note: If the bounty exceeds the maximum, this option will have no effect.)")
    elseif (oid == redressAtCell)
        mcm.SetInfoText("Whether to be re-dressed at the cell in " + hold + "'prison.")
    elseif (oid == redressAtChest)
        mcm.SetInfoText("Whether to be re-dressed at the chest in " + hold + "'prison.")
    endif

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (oid == mcm.oid_undressing_allow[mcm.CurrentOptionIndex])
        mcm.undressing_allow_state[mcm.CurrentOptionIndex] = ! mcm.undressing_allow_state[mcm.CurrentOptionIndex]
        mcm.SetToggleOptionValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex], mcm.undressing_allow_state[mcm.CurrentOptionIndex])
        Log(mcm, "Undressing::OnOptionSelect", "mcm.undressing_allow_state[" + mcm.CurrentOptionIndex + "] = " + mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    endif
    mcm.SetOptionDependencyBool(mcm.oid_undressing_minimumBounty,                   mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_whenDefeated,                    mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_atCell,                          mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_atChest,                         mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingMinBounty,       mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingWhenDefeated,    mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_stripSearchThoroughness,         mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_allowWearingClothes,             mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_redressBounty,       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_redressWhenDefeated, GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtCell,       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex])
    mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtChest,      GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && mcm.undressing_allow_state[mcm.CurrentOptionIndex])  


endFunction

; function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
;     bool optionState = mcm.ToggleOption(oid)

;     int allowUndressing                 = mcm.GetOptionInListByOID(mcm.oid_undressing_allow, oid)
;     int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
;     int undressWhenDefeated             = mcm.GetOptionInListByOID(mcm.oid_undressing_whenDefeated, oid)
;     int undressAtCell                   = mcm.GetOptionInListByOID(mcm.oid_undressing_atCell, oid)
;     int undressAtChest                  = mcm.GetOptionInListByOID(mcm.oid_undressing_atChest, oid)
;     int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
;     int forcedUndressingWhenDefeated    = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingWhenDefeated, oid)
;     int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
;     int allowWearingClothes             = mcm.GetOptionInListByOID(mcm.oid_undressing_allowWearingClothes, oid)
;     int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)
;     int redressWhenDefeated             = mcm.GetOptionInListByOID(mcm.oid_undressing_redressWhenDefeated, oid)
;     int redressAtCell                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressAtCell, oid)
;     int redressAtChest                  = mcm.GetOptionInListByOID(mcm.oid_undressing_redressAtChest, oid)


;     mcm.SetOptionDependencyBool(mcm.oid_undressing_minimumBounty,                   GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_whenDefeated,                    GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_atCell,                          GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_atChest,                         GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingMinBounty,       GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingWhenDefeated,    GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_stripSearchThoroughness,         GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_allowWearingClothes,             GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressBounty,       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressWhenDefeated, GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtCell,       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtChest,      GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))  


;     ; if (oid == allowUndressing)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_minimumBounty, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_whenDefeated, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_atCell, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_atChest, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingMinBounty, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingWhenDefeated, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_stripSearchThoroughness, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_allowWearingClothes, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressBounty, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressWhenDefeated, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtCell, optionState)
;     ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtChest, optionState)

;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_minimumBounty[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_whenDefeated[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_atCell[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_atChest[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingMinBounty[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_forcedUndressingWhenDefeated[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_stripSearchThoroughness[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressBounty[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressWhenDefeated[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtCell[mcm.CurrentOptionIndex], optionState)
;     ;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtChest[mcm.CurrentOptionIndex], optionState)

;     ; ; elseif (oid == allowWearingClothes)
;     ; ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressBounty, optionState)
;     ; ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressWhenDefeated, optionState)
;     ; ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtCell, optionState)
;     ; ;     mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtChest, optionState)   
;     ; endif

;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressBounty,       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressWhenDefeated, GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtCell,       GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))
;     ; mcm.SetOptionDependencyBool(mcm.oid_undressing_redressAtChest,      GetOptionIntValue(mcm.oid_undressing_allowWearingClothes[mcm.CurrentOptionIndex]) && GetOptionIntValue(mcm.oid_undressing_allow[mcm.CurrentOptionIndex]))  

; endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    int optionValue = GetOptionIntValue(oid)

    int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
    int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
    int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
    int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)

    if (oid == minimumBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 500, startValue = int_if(optionValue, optionValue, 500))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == forcedUndressingMinBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 1000, startValue = int_if(optionValue, optionValue, 1000))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == stripSearchThoroughness)
        mcm.SetSliderOptions(minRange = 1, maxRange = 1000, intervalSteps = 1, defaultValue = 200, startValue = int_if(optionValue, optionValue, 200))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")

    elseif (oid == redressBounty)
        mcm.SetSliderOptions(minRange = 1, maxRange = 100000, intervalSteps = 1, defaultValue = 25, startValue = int_if(optionValue, optionValue, 25))
        Log(mcm, "OnOptionSliderOpen", "This is a test: " + "[oid: " + oid + ", startValue: " + optionValue + "]")
    endif

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

    int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
    int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
    int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
    int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)

    mcm.SetSliderOptionValue(oid, value, string_if(oid == stripSearchThoroughness, "{0}", "{0} Bounty"))
    ; if (oid == minimumBounty)
    ;     SetOptionValueIntByKey("oid_undressing_minimumBounty" + mcm.CurrentOptionIndex , value as int)
    ; elseif (oid == forcedUndressingMinBounty)
    ;     SetOptionValueIntByKey("oid_undressing_forcedUndressingMinBounty" + mcm.CurrentOptionIndex , value as int)
    ; elseif (oid == stripSearchThoroughness)
    ;     SetOptionValueIntByKey("oid_undressing_stripSearchThoroughness" + mcm.CurrentOptionIndex , value as int)
    ; elseif (oid == redressBounty)
    ;     SetOptionValueIntByKey("oid_undressing_redressBounty" + mcm.CurrentOptionIndex , value as int)
    ; endif

    SetOptionValueInt(oid, value as int)
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string input) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionHighlight(mcm, oid)
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, oid)
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, oid)
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, oid)
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, oid, value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, oid)
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, oid, menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, oid)
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, oid, color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, oid, keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, oid)
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, oid, inputValue)
endFunction
