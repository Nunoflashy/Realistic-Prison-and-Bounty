Scriptname RealisticPrisonAndBounty_MCM_General hidden

import RealisticPrisonAndBounty_Util

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == "General"
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)

    HandleDependencies(mcm)
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("General")
    mcm.AddTextOption("", "WHEN FREE", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Timescale", 10)
    mcm.AddOptionSlider("Bounty Decay (Update Interval)", 12)

    mcm.AddEmptyOption()
    mcm.AddOptionCategory("Deleveling")
    mcm.AddOptionSlider("Max. Health", 0)
    mcm.AddOptionSlider("Max. Stamina", 0)
    mcm.AddOptionSlider("Max. Magicka", 0)

    mcm.AddOptionSlider("Heavy Armor", 0)
    mcm.AddOptionSlider("Light Armor", 0)
    mcm.AddOptionSlider("Sneak", 0)

    mcm.AddOptionSlider("One-Handed", 0)
    mcm.AddOptionSlider("Two-Handed", 0)
    mcm.AddOptionSlider("Archery", 0)
    mcm.AddOptionSlider("Block", 0)

endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddEmptyOption()
    mcm.AddTextOption("", "WHEN IN PRISON", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Timescale", "TimescalePrison", 10)

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

    mcm.AddOptionSlider("Smithing", 0)

    mcm.AddOptionSlider("Speechcraft", 0)
    mcm.AddOptionSlider("Pickpocketing", 0)
    mcm.AddOptionSlider("Lockpicking", 0)

    mcm.AddOptionSlider("Alteration", 0)
    mcm.AddOptionSlider("Conjuration", 0)
    mcm.AddOptionSlider("Destruction", 0)
    mcm.AddOptionSlider("Illusion", 0)
    mcm.AddOptionSlider("Restoration", 0)
    mcm.AddOptionSlider("Enchanting", 0)
    mcm.AddOptionSlider("Alchemy", 0)
endFunction

function HandleDependencies(RealisticPrisonAndBounty_MCM mcm) global

endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

    ; ==========================================================
    ;                           ARREST
    ; ==========================================================

    if (option == "Arrest::Minimum Bounty to Arrest") 
        mcm.SetInfoText("The minimum bounty required in order to be arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Guaranteed Payable Bounty")
            mcm.SetInfoText("The guaranteed amount of bounty that a guard will accept as payment before arresting you in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Maximum Payable Bounty")
            mcm.SetInfoText("The maximum amount of bounty that is payable before arresting you in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
            mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when resisting arrest in "  + mcm.CurrentPage + ".\n" + "If the bounty exceeds the guaranteed but is within the maximum, there's a chance not to go to prison.")

    elseif (option == "Arrest::Additional Bounty when Resisting")
            mcm.SetInfoText("The bounty that will be added when resisting arrest in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Defeated (%)")
            mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when defeated and arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Defeated")
            mcm.SetInfoText("The bounty that will be added when defeated and arrested in " + mcm.CurrentPage)

    elseif (option == "Arrest::Allow Civilian Capture")
            mcm.SetInfoText("Whether to allow civilians to bring you to a guard, to be arrested in " + mcm.CurrentPage)

    elseif (option == "Arrest::Allow Arrest Transfer")
            mcm.SetInfoText("Whether to allow a guard to take over the arrest if the current one dies.")

    elseif (option == "Arrest::Allow Unconscious Arrest")
            mcm.SetInfoText("Whether to allow an unconscious arrest after being defeated (You will wake up in prison).")

    elseif (option == "Arrest::Unequip Hand Garments")
            mcm.SetInfoText("Whether to unequip any hand garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (option == "Arrest::Unequip Head Garments")
            mcm.SetInfoText("Whether to unequip any head garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (option == "Arrest::Unequip Foot Garments")
            mcm.SetInfoText("Whether to unequip any foot garment when arrested.\n-1 - Disable\n0 - Always unequip.\n Any other value is the bounty required")
    
    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Allow Frisking")
        mcm.SetInfoText("Determines if you can be frisk searched in " + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Minimum Bounty for Frisking")
        mcm.SetInfoText("The minimum bounty required to be frisk searched in " + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Guaranteed Payable Bounty")
        mcm.SetInfoText("The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Maximum Payable Bounty")
        mcm.SetInfoText("The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Maximum Payable Bounty (Chance)")
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")

    elseif (option == "Frisking::Frisk Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the frisk search, higher values mean a more thorough search and possibly less items kept.")

    elseif (option == "Frisking::Confiscate Stolen Items")
        mcm.SetInfoText("Whether to confiscate any stolen items found during the frisking.")

    elseif (option == "Frisking::Strip Search if Stolen Items Found")
        mcm.SetInfoText("Whether to have the player undressed if stolen items are found.")

    elseif (option == "Frisking::Minimum No. of Stolen Items Required")
        mcm.SetInfoText("The minimum number of stolen items required to have the player undressed.")

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================

    elseif (option == "Prison::Timescale in Prison")
        mcm.SetInfoText("Sets the timescale while imprisoned.")

    elseif (option == "Prison::Bounty to Sentence")
        mcm.SetInfoText("Sets the relation between bounty and the sentence given in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Prison::Minimum Sentence")
        mcm.SetInfoText("Determines the minimum sentence in days for " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Prison::Maximum Sentence")
        mcm.SetInfoText("Determines the maximum sentence in days for " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Prison::Allow Unconditional Imprisonment")
        mcm.SetInfoText("Whether to allow unconditional imprisonment without a bounty in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Prison::Sentence pays Bounty")
        mcm.SetInfoText("Determines if serving the sentence pays the bounty in "  + mcm.CurrentPage + ".\nIf disabled, the bounty must be paid after serving the sentence.")

    elseif (option == "Prison::Fast Forward")
        mcm.SetInfoText("Whether to fast forward to the release in " + mcm.CurrentPage + ".")

    elseif (option == "Prison::Day to fast forward from")
        mcm.SetInfoText("The day to fast forward from to release in " + mcm.CurrentPage + ".")

    elseif (option == "Prison::Hands Bound in Prison")
        mcm.SetInfoText("Whether to have hands restrained during imprisonment in " + mcm.CurrentPage + ".")

    elseif (option == "Prison::Hands Bound (Minimum Bounty)")
        mcm.SetInfoText("The minimum bounty required to have hands restrained during imprisonment in " + mcm.CurrentPage + ".")

    elseif (option == "Prison::Hands Bound (Randomize)") 
        mcm.SetInfoText("Randomize whether to be restrained or not, while in prison in " + mcm.CurrentPage + ".")

    elseif (option == "Prison::Cell Lock Level")
        mcm.SetInfoText("Determines the cell's door lock level")

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Undressing::Allow Undressing")
        mcm.SetInfoText("Determines if you can be stripped off when imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Undressing::Minimum Bounty to Undress")
        mcm.SetInfoText("The minimum bounty required to be undressed in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Undressing::Undress when Defeated")
        mcm.SetInfoText("Whether to have you undressed when defeated and imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Undressing::Undress at Cell")
        mcm.SetInfoText("Whether to be undressed at the cell in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Undressing::Undress at Chest")
        mcm.SetInfoText("Whether to be undressed at the chest in "  + mcm.CurrentPage + "'s prison.")

    elseif (option == "Undressing::Forced Undressing (Bounty)")
        mcm.SetInfoText("The minimum bounty required to be force undressed (You will have no possibility of action)")

    elseif (option == "Undressing::Forced Undressing when Defeated")
        mcm.SetInfoText("Whether to be force undressed when defeated and imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Undressing::Strip Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the strip search when undressed, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                     "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped off.")

    elseif (option == "Undressing::Allow Wearing Clothes")
        mcm.SetInfoText("Determines if you are allowed to wear any clothes when imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Undressing::When Defeated")
        mcm.SetInfoText("Determines if you are given clothes when defeated and imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Undressing::Maximum Bounty")
        mcm.SetInfoText("The maximum amount of bounty you can have in order to be given clothes when imprisoned in " + mcm.CurrentPage + ".")
        
    elseif (option == "Undressing::Allow Wearing Clothes (Cidhna Mine)")
            mcm.SetInfoText("Determines if you are allowed to wear any clothes when imprisoned in Cidhna Mine.")

    elseif (option == "Undressing::When Defeated (Cidhna Mine)")
        mcm.SetInfoText("Determines if you are given clothes when defeated and imprisoned in Cidhna Mine.")
        
    elseif (option == "Undressing::Maximum Bounty (Cidhna Mine)")
        mcm.SetInfoText("The maximum amount of bounty you can have in order to be given clothes when imprisoned in Cidhna Mine.")
    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Give items back on Release")
        mcm.SetInfoText("Determines whether the items should be given back on release, if undressed while in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Release::Give items back on Release (Bounty)")
        mcm.SetInfoText("The maximum bounty in order to have the items given back when released from " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Release::Re-dress on Release")
        mcm.SetInfoText("Determines whether you should be re-dressed on release, if undressed while in " + mcm.CurrentPage + "'s prison.")

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================

    elseif (option == "Escape::Escape Bounty (%)")
        mcm.SetInfoText("The bounty added as a percentage of your current bounty, when escaping prison in " + mcm.CurrentPage + ".")

    elseif (option == "Escape::Escape Bounty")
        mcm.SetInfoText("The bounty added when escaping prison in " + mcm.CurrentPage + ".")

    elseif (option == "Escape::Allow Surrendering")
        mcm.SetInfoText("Whether the guards will allow you to surrender after escaping prison in " + mcm.CurrentPage + ".")

    elseif (option == "Escape::Frisk Search upon Captured")
        mcm.SetInfoText("Whether to allow a frisk upon being captured in "  + mcm.CurrentPage + ".\n" + "(Note: The frisk will take place regardless of whether the conditions are met in Frisking)")

    elseif (option == "Escape::Undress upon Captured")
        mcm.SetInfoText("Whether to allow being undressed upon being captured in " + mcm.CurrentPage + ".\n (Note: Undressing will take place regardless of whether the conditions are met in Undressing)")

    ; ==========================================================
    ;                       BOUNTY HUNTING
    ; ==========================================================

    elseif (option == "Bounty Hunting::Enable Bounty Hunters")
        mcm.SetInfoText("Whether to enable bounty hunters for " + mcm.CurrentPage + ".")

    elseif (option == "Bounty Hunting::Allow Outlaw Bounty Hunters")
        mcm.SetInfoText("Whether to allow outlaw bounty hunters working for " + mcm.CurrentPage + ".")

    elseif (option == "Bounty Hunting::Minimum Bounty")
        mcm.SetInfoText("The minimum bounty required to have bounty hunters hunt you in " + mcm.CurrentPage + ".")

    elseif (option == "Bounty Hunting::Bounty (Posse)")
        mcm.SetInfoText("The bounty required to have a group of bounty hunters hunt you in " + mcm.CurrentPage + ".")

    ; ==========================================================
    ;                           BOUNTY
    ; ==========================================================
    ; elseif (option == "Enable Bounty Hunters")
    ;     mcm.SetInfoText("Whether to enable bounty hunters for " + mcm.CurrentPage + ".")

    ; elseif (option == "Allow Outlaw Bounty Hunters")
    ;     mcm.SetInfoText("Whether to allow outlaw bounty hunters working for " + mcm.CurrentPage + ".")

    ; elseif (option == "Minimum Bounty")
    ;     mcm.SetInfoText("The minimum bounty required to have bounty hunters hunt you in " + mcm.CurrentPage + ".")

    ; elseif (option == "Bounty (Posse)")
    ;     mcm.SetInfoText("The bounty required to have a group of bounty hunters hunt you in " + mcm.CurrentPage + ".")

    endif
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = mcm.CurrentPage + "::" + option
    mcm.ToggleOption(optionKey)
    HandleDependencies(mcm)
endFunction

function LoadSliderOptions(RealisticPrisonAndBounty_MCM mcm, string option, float currentSliderValue) global
    float minRange = 1
    float maxRange = 100000
    int intervalSteps = 1
    float defaultValue = 0.0

    ; ==========================================================
    ;                           ARREST
    ; ==========================================================

    if (option == "Arrest::Minimum Bounty to Arrest")
        intervalSteps = 50
        defaultValue = mcm.ARREST_DEFAULT_MIN_BOUNTY

    elseif (option == "Arrest::Guaranteed Payable Bounty")
        intervalSteps = 50
        defaultValue = mcm.ARREST_DEFAULT_GUARANTEED_PAYABLE_BOUNTY

    elseif (option == "Arrest::Maximum Payable Bounty")
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
        maxRange = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT

    elseif (option == "Arrest::Additional Bounty when Resisting")
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT

    elseif (option == "Arrest::Additional Bounty when Defeated (%)")
        maxRange = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT

    elseif (option == "Arrest::Additional Bounty when Defeated")
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT

    elseif (option == "Arrest::Unequip Hand Garments")
        minRange = -1
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY

    elseif (option == "Arrest::Unequip Head Garments")
        minRange = -1
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY

    elseif (option == "Arrest::Unequip Foot Garments")
        minRange = -1
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY

    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Minimum Bounty for Frisking")
        intervalSteps = 100
        defaultValue = mcm.FRISKING_DEFAULT_MIN_BOUNTY

    elseif (option == "Frisking::Guaranteed Payable Bounty")
        intervalSteps = 100
        defaultValue = mcm.FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY

    elseif (option == "Frisking::Maximum Payable Bounty")
        intervalSteps = 100
        defaultValue = mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY

    elseif (option == "Frisking::Maximum Payable Bounty (Chance)")
        maxRange = 100
        defaultValue = mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE

    elseif (option == "Frisking::Frisk Search Thoroughness")
        maxRange = 10
        defaultValue = mcm.FRISKING_DEFAULT_FRISK_THOROUGHNESS

    elseif (option == "Frisking::Minimum No. of Stolen Items Required")
        maxRange = 1000
        defaultValue = mcm.FRISKING_DEFAULT_NUMBER_STOLEN_ITEMS_REQUIRED

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================

    elseif (option == "Prison::Bounty to Sentence")
        intervalSteps = 100
        defaultValue = mcm.PRISON_DEFAULT_BOUNTY_TO_SENTENCE

    elseif (option == "Prison::Minimum Sentence")
        maxRange =  mcm.GetOptionSliderValue("Prison::Maximum Sentence") - 1
        defaultValue = float_if(mcm.PRISON_DEFAULT_MIN_SENTENCE_DAYS > maxRange, maxRange, mcm.PRISON_DEFAULT_MIN_SENTENCE_DAYS)

    elseif (option == "Prison::Maximum Sentence")
        minRange = mcm.GetOptionSliderValue("Prison::Minimum Sentence") + 1
        maxRange = 365
        defaultValue = float_if(mcm.PRISON_DEFAULT_MAX_SENTENCE_DAYS > maxRange, maxRange, mcm.PRISON_DEFAULT_MAX_SENTENCE_DAYS)

    elseif (option == "Prison::Day to fast forward from")
        maxRange = mcm.GetOptionSliderValue("Prison::Maximum Sentence")
        defaultValue = float_if(mcm.PRISON_DEFAULT_DAY_FAST_FORWARD > maxRange, maxRange, mcm.PRISON_DEFAULT_DAY_FAST_FORWARD)

    elseif (option == "Prison::Hands Bound (Minimum Bounty)")
        intervalSteps = 100
        defaultValue = mcm.PRISON_DEFAULT_HANDS_BOUND_BOUNTY

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Undressing::Minimum Bounty to Undress")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_MIN_BOUNTY

    elseif (option == "Undressing::Forced Undressing (Bounty)")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY

    elseif (option == "Undressing::Strip Search Thoroughness")
        maxRange = 10
        defaultValue = mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================
    elseif (option == "Release::Give items back on Release (Bounty)")
        intervalSteps = 100
        defaultValue = mcm.RELEASE_DEFAULT_GIVE_ITEMS_BACK_BOUNTY

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================
    elseif (option == "Escape::Escape Bounty (%)")
        maxRange = 100
        defaultValue = mcm.ESCAPE_DEFAULT_BOUNTY_PERCENT

    elseif (option == "Escape::Escape Bounty")
        intervalSteps = 100
        defaultValue = mcm.ESCAPE_DEFAULT_BOUNTY_FLAT

    ; ==========================================================
    ;                       BOUNTY HUNTING
    ; ==========================================================

    elseif (option == "Bounty Hunting::Minimum Bounty")
        intervalSteps = 100
        defaultValue = mcm.BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY

    elseif (option == "Bounty Hunting::Bounty (Posse)")
        intervalSteps = 100
        defaultValue = mcm.BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY_GROUP

    ; ==========================================================
    ;                           BOUNTY
    ; ==========================================================

    elseif (option == "Bounty::Bounty Lost (%)")
        maxRange = 100
        defaultValue = mcm.BOUNTY_DEFAULT_BOUNTY_LOST_PERCENT

    elseif (option == "Bounty::Bounty Lost")
        intervalSteps = 50
        defaultValue = mcm.BOUNTY_DEFAULT_BOUNTY_LOST_FLAT
    endif

    float startValue = float_if (currentSliderValue > mcm.GENERAL_ERROR, currentSliderValue, defaultValue)
    mcm.SetSliderOptions(minRange, maxRange, intervalSteps, defaultValue, startValue)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    float sliderOptionValue = mcm.GetOptionSliderValue(option)
    LoadSliderOptions(mcm, option, sliderOptionValue)
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
    string formatString = "{0} Bounty"

    ; ==========================================================
    ;                           ARREST
    ; ==========================================================

    if (option == "Arrest::Minimum Bounty to Arrest")

    elseif (option == "Arrest::Guaranteed Payable Bounty")

    elseif (option == "Arrest::Maximum Payable Bounty")

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
        formatString = "{0}% of Bounty"

    elseif (option == "Arrest::Additional Bounty when Resisting")

    elseif (option == "Arrest::Additional Bounty when Defeated (%)")
        formatString = "{0}% of Bounty"

    elseif (option == "Arrest::Additional Bounty when Defeated")

    elseif (option == "Arrest::Unequip Hand Garments")

    elseif (option == "Arrest::Unequip Head Garments")

    elseif (option == "Arrest::Unequip Foot Garments")


    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Minimum Bounty for Frisking")

    elseif (option == "Frisking::Guaranteed Payable Bounty")

    elseif (option == "Frisking::Maximum Payable Bounty")

    elseif (option == "Frisking::Maximum Payable Bounty (Chance)")
        formatString = "{0}%"

    elseif (option == "Frisking::Frisk Search Thoroughness")
        formatString = "{0}x"

    elseif (option == "Frisking::Minimum No. of Stolen Items Required")
        formatString = "{0} Items"

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================

    elseif (option == "Prison::Bounty to Sentence")
        formatString = "{0} Bounty = 1 Day"

    elseif (option == "Prison::Minimum Sentence")
        formatString = "{0} Days"

    elseif (option == "Prison::Maximum Sentence")
        formatString = "{0} Days"

    elseif (option == "Prison::Day to fast forward from")

    elseif (option == "Prison::Hands Bound (Minimum Bounty)")

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Undressing::Minimum Bounty to Undress")

    elseif (option == "Undressing::Forced Undressing (Bounty)")

    elseif (option == "Undressing::Strip Search Thoroughness")
        formatString = "{0}x"

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Give items back on Release (Bounty)")

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================

    elseif (option == "Escape::Escape Bounty (%)")
        formatString = "{0}% of Bounty"

    elseif (option == "Escape::Escape Bounty")

    ; ==========================================================
    ;                       BOUNTY HUNTING
    ; ==========================================================

    elseif (option == "Bounty Hunting::Minimum Bounty")

    elseif (option == "Bounty Hunting::Bounty (Posse)")

    ; ==========================================================
    ;                           BOUNTY
    ; ==========================================================

    elseif (option == "Bounty::Bounty Lost (%)")
        formatString = "{0}% of Bounty"

    elseif (option == "Bounty::Bounty Lost")

    endif

    mcm.SetOptionSliderValue(option, value, formatString)
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    if (option == "Prison::Cell Lock Level")
        mcm.SetMenuDialogOptions(mcm.LockLevels)
    endif
endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, string option, int menuIndex) global
    if (option == "Prison::Cell Lock Level")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.LockLevels[menuIndex])
        endif
    endif
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, string option, string input) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid), value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid), menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid), color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid), inputValue)
endFunction
