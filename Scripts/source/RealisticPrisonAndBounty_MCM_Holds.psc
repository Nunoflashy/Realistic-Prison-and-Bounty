Scriptname RealisticPrisonAndBounty_MCM_Holds hidden

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_MCM

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage != "" && mcm.CurrentPage != "General" && mcm.CurrentPage != "Statistics" ; If the page is any hold, handle events
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    float bench = StartBenchmark()
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)

    HandleDependencies(mcm)

    EndBenchmark(bench, mcm.CurrentPage + " page loaded -")
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("Stats")
    mcm.AddOptionText("Current Bounty", "0 Bounty")
    mcm.AddOptionText("Largest Bounty", "0 Bounty")
    mcm.AddOptionText("Total Bounty", "0 Bounty")
    mcm.AddOptionText("Times Arrested", "0 Times")
    mcm.AddOptionText("Times Frisked", "0 Times")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Arrest")
    mcm.AddTextOption("", "When Free", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Minimum Bounty to Arrest",                         mcm.ARREST_DEFAULT_MIN_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Guaranteed Payable Bounty",                        mcm.ARREST_DEFAULT_GUARANTEED_PAYABLE_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty",                           mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty (Chance)",                  mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE, "{0}%")

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "When Resisting", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Additional Bounty when Resisting (%)",   mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT, "{0}% of Bounty")
    mcm.AddOptionSlider("Additional Bounty when Resisting",       mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT, "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "When Defeated", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Additional Bounty when Defeated (%)",          mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT, "{0}% of Bounty")
    mcm.AddOptionSlider("Additional Bounty when Defeated",              mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, "{0} Bounty")
    mcm.AddOptionToggle("Allow Civilian Capture",                       mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Allow Unconscious Arrest",                     mcm.ARREST_DEFAULT_ALLOW_UNCONSCIOUS_ARREST)
    mcm.AddOptionToggle("Allow Unconditional Arrest",                   mcm.ARREST_DEFAULT_ALLOW_UNCONDITIONAL_ARREST)

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "When Arrested", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Allow Arrest Transfer",           mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER)
    mcm.AddOptionSlider("Unequip Hand Garments",           mcm.ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Unequip Head Garments",           mcm.ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Unequip Foot Garments",           mcm.ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY, "{0} Bounty")
    
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Frisking")
    mcm.AddTextOption("", "When Arrested", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Allow Frisking",                         mcm.FRISKING_DEFAULT_ALLOW)
    mcm.AddOptionSlider("Minimum Bounty for Frisking",            mcm.FRISKING_DEFAULT_MIN_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Guaranteed Payable Bounty",              mcm.FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty",                 mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty (Chance)",        mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE, "{0}%")
    mcm.AddOptionSlider("Frisk Search Thoroughness",              mcm.FRISKING_DEFAULT_FRISK_THOROUGHNESS, "{0}x")

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "When Frisked", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Confiscate Stolen Items",                mcm.FRISKING_DEFAULT_CONFISCATE_ITEMS)
    mcm.AddOptionToggle("Strip Search if Stolen Items Found",     mcm.FRISKING_DEFAULT_STRIP_IF_STOLEN_FOUND)
    mcm.AddOptionSlider("Minimum No. of Stolen Items Required",   mcm.FRISKING_DEFAULT_NUMBER_STOLEN_ITEMS_REQUIRED, "{0} Items")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Release")
    mcm.AddOptionToggle("Retain Items on Release",             mcm.RELEASE_DEFAULT_GIVE_ITEMS_BACK)
    mcm.AddOptionSlider("Minimum Bounty to Retain Items",    mcm.RELEASE_DEFAULT_GIVE_ITEMS_BACK_BOUNTY, "{0} Bounty")
    
    mcm.AddEmptyOption()

    mcm.AddTextOption("", "When Undressed", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Auto Re-Dress on Release",                    mcm.RELEASE_DEFAULT_REDRESS)

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Escape")
    mcm.AddOptionSlider("Escape Bounty (%)",                mcm.ESCAPE_DEFAULT_BOUNTY_PERCENT, "{0}% of Bounty")
    mcm.AddOptionSlider("Escape Bounty",                    mcm.ESCAPE_DEFAULT_BOUNTY_FLAT, "{0} Bounty")
    mcm.AddOptionToggle("Allow Surrendering",               mcm.ESCAPE_DEFAULT_ALLOW_SURRENDER)
    mcm.AddOptionToggle("Frisk Search upon Captured",       mcm.ESCAPE_DEFAULT_FRISK_ON_CAPTURE, mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Strip Search upon Captured",            mcm.ESCAPE_DEFAULT_UNDRESS_ON_CAPTURE)
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    mcm.SetRenderedCategory("Stats")
    mcm.AddTextOption("", mcm.CurrentPage, mcm.OPTION_DISABLED)
    mcm.AddOptionText("Days in Jail", "0 Days")
    mcm.AddOptionText("Longest Sentence", "0 Days")
    mcm.AddOptionText("Times Jailed", "0 Times")
    mcm.AddOptionText("Times Escaped", "0 Times")
    mcm.AddOptionText("Times Stripped", "0 Times")
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Jail")
    mcm.AddOptionSlider("Bounty Exchange",                      mcm.PRISON_DEFAULT_BOUNTY_TO_SENTENCE, "{0} Violent Bounty = 100 Bounty")
    mcm.AddOptionSlider("Bounty to Sentence",                   mcm.PRISON_DEFAULT_BOUNTY_TO_SENTENCE, "{0} Bounty = 1 Day")
    mcm.AddOptionSlider("Minimum Sentence",                     mcm.PRISON_DEFAULT_MIN_SENTENCE_DAYS, "{0} Days")
    mcm.AddOptionSlider("Maximum Sentence",                     mcm.PRISON_DEFAULT_MAX_SENTENCE_DAYS, "{0} Days")
    ; mcm.AddOptionToggle("Allow Unconditional Imprisonment",     mcm.PRISON_DEFAULT_ALLOW_UNCONDITIONAL_PRISON)
    mcm.AddOptionToggle("Sentence pays Bounty",                 mcm.PRISON_DEFAULT_SENTENCE_PAYS_BOUNTY)
    mcm.AddOptionSlider("Cell Search Thoroughness",             mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, "{0}x")
    mcm.AddOptionMenu("Cell Lock Level",                    mcm.PRISON_DEFAULT_CELL_LOCK_LEVEL)

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "WHEN IN JAIL",                 mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Fast Forward",                     mcm.PRISON_DEFAULT_FAST_FORWARD)
    mcm.AddOptionSlider("Day to fast forward from",         mcm.PRISON_DEFAULT_DAY_FAST_FORWARD)
    mcm.AddOptionMenu("Handle Skill Loss", "Random")
    mcm.AddOptionSlider("Day to start losing Skills",       mcm.PRISON_DEFAULT_DAY_START_LOSING_SKILLS)
    mcm.AddOptionSlider("Chance to lose Skills",            mcm.PRISON_DEFAULT_CHANCE_START_LOSING_SKILLS, "{0}% Each Day")
    
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Stripping")
    mcm.AddOptionToggle("Allow Undressing",                     mcm.UNDRESSING_DEFAULT_ALLOW)
    mcm.AddOptionMenu("Handle Undressing On",                   mcm.UNDRESSING_DEFAULT_HANDLING_OPTION)
    mcm.AddOptionSlider("Minimum Bounty to Undress",            mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, "{0} Bounty", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Minimum Violent Bounty to Undress",    mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, "{0} Violent Bounty", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Minimum Sentence to Undress",          mcm.GetOptionSliderValue("Jail::Minimum Sentence"), "{0} Days")
    mcm.AddOptionToggle("Undress when Defeated",                mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED)
    ; mcm.AddOptionSlider("Forced Undressing (Bounty)",           mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY, "{0} Bounty")
    ; mcm.AddOptionToggle("Forced Undressing when Defeated",      mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED)
    mcm.AddOptionSlider("Strip Search Thoroughness",            mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, "{0}x")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Clothing")
    mcm.AddTextOption("", "When Undressed", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Allow Wearing Clothes",                                            mcm.CLOTHING_DEFAULT_ALLOW_CLOTHES)
    mcm.AddOptionMenu("Handle Clothing On",                                                 mcm.CLOTHING_DEFAULT_HANDLING_OPTION, mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Maximum Bounty to Clothe", "Maximum Bounty",                    mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY, "{0} Bounty", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Maximum Violent Bounty to Clothe", "Maximum Violent Bounty",    mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY, "{0} Violent Bounty", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Maximum Sentence to Clothe", "Maximum Sentence",                mcm.GetOptionSliderValue("Jail::Maximum Sentence"), "{0} Days", mcm.OPTION_DISABLED)
    mcm.AddOptionToggleKey("Clothe When Defeated", "When Defeated",                         mcm.CLOTHING_DEFAULT_REDRESS_WHEN_DEFEATED, mcm.OPTION_DISABLED)
    ; mcm.AddOptionMenu("Prison Outfit",                                                      mcm.CLOTHING_DEFAULT_PRISON_OUTFIT, mcm.OPTION_DISABLED)

    if (mcm.CurrentPage == "The Reach")
        mcm.AddTextOption("", "Cidhna Mine", mcm.OPTION_DISABLED)
        mcm.AddOptionToggleKey("Allow Wearing Clothes", "Allow Wearing Clothes (Cidhna Mine)",   mcm.CLOTHING_DEFAULT_ALLOW_CLOTHES)
        mcm.AddOptionToggleKey("When Defeated",  "When Defeated (Cidhna Mine)",                  mcm.CLOTHING_DEFAULT_REDRESS_WHEN_DEFEATED)
        mcm.AddOptionSliderKey("Maximum Bounty",  "Maximum Bounty (Cidhna Mine)",                mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY, "{0} Bounty")
    endif

    mcm.AddEmptyOption()


    mcm.AddOptionCategory("Additional Charges")
    mcm.AddTextOption("", "During Booking", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Bounty for Impersonation", 0, "{0} Bounty")
    mcm.AddOptionSlider("Bounty for Enemy of Hold", 0, "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "During Frisk or Strip Search", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Bounty for Stolen Item", 0, "{0} Bounty")
    mcm.AddOptionSlider("Bounty for Contraband", 0, "{0} Bounty")
    mcm.AddOptionSlider("Bounty for Cell Key", 0, "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Bounty Hunting")
    mcm.AddOptionToggle("Enable Bounty Hunters",        mcm.BOUNTY_HUNTERS_DEFAULT_ENABLE)
    mcm.AddOptionToggle("Allow Outlaw Bounty Hunters",  mcm.BOUNTY_HUNTERS_DEFAULT_ALLOW_OUTLAWS)
    mcm.AddOptionSlider("Minimum Bounty",               mcm.BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Bounty (Posse)",               mcm.BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY_GROUP, "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Bounty Decaying")
    mcm.AddOptionToggle("Enable Bounty Decaying",   mcm.BOUNTY_DEFAULT_ENABLE_DECAY)
    mcm.AddOptionToggle("Decay while in Prison",    mcm.BOUNTY_DEFAULT_DECAY_IN_PRISON)
    mcm.AddOptionSlider("Bounty Lost (%)",          mcm.BOUNTY_DEFAULT_BOUNTY_LOST_PERCENT, "{0}% of Bounty")
    mcm.AddOptionSlider("Bounty Lost",              mcm.BOUNTY_DEFAULT_BOUNTY_LOST_FLAT, "{0} Bounty")


endFunction

function HandleDependencies(RealisticPrisonAndBounty_MCM mcm) global

    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    bool allowFrisking                  = mcm.GetOptionToggleState("Frisking::Allow Frisking")
    bool confiscateStolenItems          = mcm.GetOptionToggleState("Frisking::Confiscate Stolen Items")
    bool stripSearchStolenItemsFound    = mcm.GetOptionToggleState("Frisking::Strip Search if Stolen Items Found")

    mcm.SetOptionDependencyBool("Frisking::Minimum Bounty for Frisking",            allowFrisking)
    mcm.SetOptionDependencyBool("Frisking::Guaranteed Payable Bounty",              allowFrisking)
    mcm.SetOptionDependencyBool("Frisking::Maximum Payable Bounty",                 allowFrisking)
    mcm.SetOptionDependencyBool("Frisking::Maximum Payable Bounty (Chance)",        allowFrisking)
    mcm.SetOptionDependencyBool("Frisking::Frisk Search Thoroughness",              allowFrisking)
    mcm.SetOptionDependencyBool("Frisking::Confiscate Stolen Items",                allowFrisking)

    ; ==========================================================
    ;                          UNDRESSING
    ; ==========================================================

    bool allowUndressing                = mcm.GetOptionToggleState("Stripping::Allow Undressing")
    bool isUndressingBountyHandling     = mcm.GetOptionMenuValue("Stripping::Handle Undressing On") == "Minimum Bounty"
    bool isUndressingSentenceHandling   = mcm.GetOptionMenuValue("Stripping::Handle Undressing On") == "Minimum Sentence"

    mcm.SetOptionDependencyBool("Stripping::Handle Undressing On",                 allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Minimum Bounty to Undress",            allowUndressing && isUndressingBountyHandling)
    mcm.SetOptionDependencyBool("Stripping::Minimum Violent Bounty to Undress",    allowUndressing && isUndressingBountyHandling)
    mcm.SetOptionDependencyBool("Stripping::Minimum Sentence to Undress",          allowUndressing && isUndressingSentenceHandling)
    mcm.SetOptionDependencyBool("Stripping::Undress when Defeated",                allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Undress at Cell",                      allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Undress at Chest",                     allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Forced Undressing (Bounty)",           allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Forced Undressing when Defeated",      allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Strip Search Thoroughness",            allowUndressing)

    ; ==========================================================
    ;                           CLOTHING
    ; ==========================================================

    bool allowWearingClothes            = mcm.GetOptionToggleState("Clothing::Allow Wearing Clothes")
    bool isClothingBountyHandling       = mcm.GetOptionMenuValue("Clothing::Handle Clothing On")   == "Maximum Bounty"
    bool isClothingSentenceHandling     = mcm.GetOptionMenuValue("Clothing::Handle Clothing On")   == "Maximum Sentence"
    
    mcm.SetOptionDependencyBool("Clothing::Allow Wearing Clothes",            allowUndressing)
    mcm.SetOptionDependencyBool("Clothing::Handle Clothing On",               allowUndressing && allowWearingClothes)
    mcm.SetOptionDependencyBool("Clothing::When Defeated",                    allowUndressing && allowWearingClothes)
    mcm.SetOptionDependencyBool("Clothing::Maximum Bounty",                   allowUndressing && allowWearingClothes && isClothingBountyHandling)
    mcm.SetOptionDependencyBool("Clothing::Maximum Violent Bounty",           allowUndressing && allowWearingClothes && isClothingBountyHandling)
    mcm.SetOptionDependencyBool("Clothing::Maximum Sentence",                 allowUndressing && allowWearingClothes && isClothingSentenceHandling)
    ; mcm.SetOptionDependencyBool("Clothing::Prison Outfit",                    allowUndressing && allowWearingClothes)

    ; ==========================================================
    ;                      FRISKING:UNDRESSING
    ; ==========================================================

    mcm.SetOptionDependencyBool("Frisking::Strip Search if Stolen Items Found",     allowFrisking && confiscateStolenItems && allowUndressing)
    mcm.SetOptionDependencyBool("Frisking::Minimum No. of Stolen Items Required",   allowFrisking && confiscateStolenItems && stripSearchStolenItemsFound && allowUndressing)

    ; ==========================================================
    ;                      ADDITIONAL CHARGES
    ; ==========================================================
    
    mcm.SetOptionDependencyBool("Additional Charges::Bounty for Stolen Item",   (allowFrisking && confiscateStolenItems) || allowUndressing)
    mcm.SetOptionDependencyBool("Additional Charges::Bounty for Contraband",    (allowFrisking && confiscateStolenItems) || allowUndressing)
    mcm.SetOptionDependencyBool("Additional Charges::Bounty for Cell Key",      (allowFrisking && confiscateStolenItems) || allowUndressing)

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================

    bool enableFastForward = mcm.GetOptionToggleState("Jail::Fast Forward")

    mcm.SetOptionDependencyBool("Jail::Day to fast forward from", enableFastForward)

    ; ==========================================================
    ;                       BOUNTY HUNTING
    ; ==========================================================

    bool enableBountyHunters = mcm.GetOptionToggleState("Bounty Hunting::Enable Bounty Hunters")

    mcm.SetOptionDependencyBool("Bounty Hunting::Allow Outlaw Bounty Hunters",  enableBountyHunters)
    mcm.SetOptionDependencyBool("Bounty Hunting::Minimum Bounty",               enableBountyHunters)
    mcm.SetOptionDependencyBool("Bounty Hunting::Bounty (Posse)",               enableBountyHunters)

    ; ==========================================================
    ;                       BOUNTY DECAYING
    ; ==========================================================

    bool enableBountyDecay = mcm.GetOptionToggleState("Bounty Decaying::Enable Bounty Decaying")
    
    mcm.SetOptionDependencyBool("Bounty Decaying::Decay while in Prison",   enableBountyDecay)
    mcm.SetOptionDependencyBool("Bounty Decaying::Bounty Lost (%)",         enableBountyDecay)
    mcm.SetOptionDependencyBool("Bounty Decaying::Bounty Lost",             enableBountyDecay)

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================
    
    bool friskSearchUponCaptured = mcm.GetOptionToggleState("Escape::Frisk Search upon Captured")
    bool undressUponCaptured     = mcm.GetOptionToggleState("Escape::Strip Search upon Captured")

    mcm.SetOptionDependencyBool("Escape::Frisk Search upon Captured",   !undressUponCaptured && allowFrisking)
    mcm.SetOptionDependencyBool("Escape::Strip Search upon Captured",        allowUndressing)

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    bool retainItemsOnRelease = mcm.GetOptionToggleState("Release::Retain Items on Release")

    mcm.SetOptionDependencyBool("Release::Minimum Bounty to Retain Items",  retainItemsOnRelease)
    mcm.SetOptionDependencyBool("Release::Auto Re-Dress on Release",        allowUndressing)

endFunction

function HandleSliderOptionDependency(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================
    
    if (option == "Jail::Minimum Sentence")
        string formatString = "{0} Days"
        float minimumSentenceToUndressValue = mcm.GetOptionSliderValue("Stripping::Minimum Sentence to Undress")
        float maximumSentenceToClothe       = mcm.GetOptionSliderValue("Clothing::Maximum Sentence")

        if (minimumSentenceToUndressValue < value)
            mcm.SetOptionSliderValue("Stripping::Minimum Sentence to Undress", value, formatString)
        endif

        if(maximumSentenceToClothe < value)
            mcm.SetOptionSliderValue("Clothing::Maximum Sentence", value, formatString)
        endif

    elseif (option == "Jail::Maximum Sentence")
        string formatString = "{0} Days"
        float minimumSentenceToUndressValue = mcm.GetOptionSliderValue("Stripping::Minimum Sentence to Undress")
        float maximumSentenceToClothe       = mcm.GetOptionSliderValue("Clothing::Maximum Sentence")

        if (minimumSentenceToUndressValue > value)
            mcm.SetOptionSliderValue("Stripping::Minimum Sentence to Undress", value, formatString)
        endif

        if(maximumSentenceToClothe > value)
            mcm.SetOptionSliderValue("Clothing::Maximum Sentence", value, formatString)
        endif
    endif
endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

    ; ==========================================================
    ;                            STATS
    ; ==========================================================

    if (option == "Stats::Current Bounty")
        mcm.SetInfoText("The bounty you currently have in " + mcm.CurrentPage + ".\n(Note: Inactive unpaid bounty after serving a sentence also counts towards this.)")

    elseif (option == "Stats::Largest Bounty")
        mcm.SetInfoText("The largest bounty you've had in " + mcm.CurrentPage + ".")
    
    elseif (option == "Stats::Total Bounty")
        mcm.SetInfoText("The total bounty you've accumulated in " + mcm.CurrentPage + ".")

    elseif (option == "Stats::Times Arrested")
        mcm.SetInfoText("The times you have been arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Stats::Times Frisked")
        mcm.SetInfoText("The times you have been frisk searched in " + mcm.CurrentPage + ".")

    elseif (option == "Stats::Days in Jail")
        mcm.SetInfoText("The amount of days you have spent in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Stats::Longest Sentence")
        mcm.SetInfoText("The longest sentence you have been given in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Stats::Times Jailed")
        mcm.SetInfoText("The times you have been jailed in " + mcm.CurrentPage + ".")

    elseif (option == "Stats::Times Escaped")
        mcm.SetInfoText("The times you have escaped from " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Stats::Times Stripped")
        mcm.SetInfoText("The times you have been strip searched in " + mcm.CurrentPage + "'s jail.")

    ; ==========================================================
    ;                           ARREST
    ; ==========================================================

    elseif (option == "Arrest::Minimum Bounty to Arrest") 
        mcm.SetInfoText("The minimum bounty required in order to be arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Guaranteed Payable Bounty")
        mcm.SetInfoText("The guaranteed amount of bounty that a guard will accept as payment before being arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Maximum Payable Bounty")
        mcm.SetInfoText("The maximum amount of bounty that is payable before being arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Maximum Payable Bounty (Chance)")
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
        mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when resisting arrest in "  + mcm.CurrentPage + ".")

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
        mcm.SetInfoText("Whether to allow an unconscious arrest after being defeated.")

    elseif (option == "Arrest::Allow Unconditional Arrest")
        mcm.SetInfoText("Whether to allow an unconditional arrest without a bounty in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Unequip Hand Garments")
        mcm.SetInfoText("Whether to unequip any hand garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required.")

    elseif (option == "Arrest::Unequip Head Garments")
        mcm.SetInfoText("Whether to unequip any head garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required.")

    elseif (option == "Arrest::Unequip Foot Garments")
        mcm.SetInfoText("Whether to unequip any foot garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required.")
    
    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Allow Frisking")
        mcm.SetInfoText("Determines if you can be frisked in " + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Minimum Bounty for Frisking")
        mcm.SetInfoText("The minimum bounty required to be frisked in " + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Guaranteed Payable Bounty")
        mcm.SetInfoText("The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Maximum Payable Bounty")
        mcm.SetInfoText("The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Maximum Payable Bounty (Chance)")
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")

    elseif (option == "Frisking::Frisk Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the frisk, higher values mean a more thorough search, more items found by the jailhouse, and possibly less items kept.")

    elseif (option == "Frisking::Confiscate Stolen Items")
        mcm.SetInfoText("Whether to confiscate any stolen items found during the frisking.")

    elseif (option == "Frisking::Strip Search if Stolen Items Found")
        mcm.SetInfoText("Whether to have the player strip searched if stolen items are found. \n (Note: If the strip search takes place, you will be jailed regardless of the bounty for the arrest)")

    elseif (option == "Frisking::Minimum No. of Stolen Items Required")
        mcm.SetInfoText("The minimum number of stolen items required to have the player be strip searched.")

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================

    elseif (option == "Jail::Bounty Exchange")
        mcm.SetInfoText("The amount of violent bounty to be exchanged to normal bounty in order to determine the sentence in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Bounty to Sentence")
        mcm.SetInfoText("Sets the relation between bounty and the sentence given in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Jail::Minimum Sentence")
        mcm.SetInfoText("Determines the minimum sentence in days for " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Jail::Maximum Sentence")
        mcm.SetInfoText("Determines the maximum sentence in days for " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Jail::Allow Unconditional Imprisonment")
        mcm.SetInfoText("Whether to allow unconditional imprisonment without a bounty in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Sentence pays Bounty")
        mcm.SetInfoText("Determines if serving the sentence pays the bounty in "  + mcm.CurrentPage + ".\nIf disabled, the bounty must be paid after serving the sentence in jail.")

    elseif (option == "Jail::Fast Forward")
        mcm.SetInfoText("Whether to fast forward to the release in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Day to fast forward from")
        mcm.SetInfoText("The day to fast forward from to release in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Handle Skill Loss")
        mcm.SetInfoText("The way to handle skill progression loss when jailed in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Day to start losing Skills")
        mcm.SetInfoText("The day to start losing skills when jailed in " + mcm.CurrentPage + ". \n(Configured individually in General page)")

    elseif (option == "Jail::Chance to lose Skills")
        mcm.SetInfoText("The chance to lose skills each day while jailed in " + mcm.CurrentPage + ". \n(Stats lost are configured in General page)")

    elseif (option == "Jail::Cell Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the cell search, higher values mean a more thorough searching of the cell and possibly any items you left there to be confiscated.")

    elseif (option == "Jail::Hands Bound in Prison")
        mcm.SetInfoText("Whether to have hands restrained during imprisonment in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Hands Bound (Minimum Bounty)")
        mcm.SetInfoText("The minimum bounty required to have hands restrained during imprisonment in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Hands Bound (Randomize)") 
        mcm.SetInfoText("Randomize whether to be restrained or not, while in prison in " + mcm.CurrentPage + ".")

    elseif (option == "Jail::Cell Lock Level")
        mcm.SetInfoText("Determines the cell's door lock level")

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Stripping::Allow Undressing")
        mcm.SetInfoText("Determines if you can be stripped off when imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Stripping::Handle Undressing On")
        mcm.SetInfoText("Determines which rules to use to know whether a strip search should take place in " + mcm.CurrentPage + ".")

    elseif (option == "Stripping::Minimum Bounty to Undress")
        mcm.SetInfoText("The minimum bounty required to be undressed in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Stripping::Minimum Violent Bounty to Undress")
        mcm.SetInfoText("The minimum violent bounty required to be undressed in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Stripping::Minimum Sentence to Undress")
        mcm.SetInfoText("The minimum sentence required to be undressed in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Stripping::Undress when Defeated")
        mcm.SetInfoText("Whether to have you undressed when defeated and imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Stripping::Strip Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the strip search, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                     "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped off.")

    elseif (option == "Clothing::Allow Wearing Clothes")
        mcm.SetInfoText("Determines if you are allowed to wear any clothes when imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Clothing::Handle Clothing On")
        mcm.SetInfoText("Determines which rules to use to know whether clothes should be given in " + mcm.CurrentPage + ".")

    elseif (option == "Clothing::When Defeated")
        mcm.SetInfoText("Determines if you are given clothes when defeated and imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Clothing::Maximum Bounty")
        mcm.SetInfoText("The maximum amount of bounty you can have in order to be given clothes when imprisoned in " + mcm.CurrentPage + ".")
        
    elseif (option == "Clothing::Maximum Violent Bounty")
        mcm.SetInfoText("The maximum amount of violent bounty you can have in order to be given clothes when imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Clothing::Maximum Sentence")
        mcm.SetInfoText("The maximum sentence you can be given in order to be given clothes when imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Clothing::Allow Wearing Clothes (Cidhna Mine)")
            mcm.SetInfoText("Determines if you are allowed to wear any clothes when imprisoned in Cidhna Mine.")

    elseif (option == "Clothing::When Defeated (Cidhna Mine)")
        mcm.SetInfoText("Determines if you are given clothes when defeated and imprisoned in Cidhna Mine.")

    elseif (option == "Clothing::Maximum Bounty (Cidhna Mine)")
        mcm.SetInfoText("The maximum amount of bounty you can have in order to be given clothes when imprisoned in Cidhna Mine.")

    ; ==========================================================
    ;                      ADDITIONAL CHARGES
    ; ==========================================================

    elseif (option == "Additional Charges::Bounty for Impersonation")
        mcm.SetInfoText("The additional bounty to be imposed as a charge when impersonating a guard in " + mcm.CurrentPage + ".")

    elseif (option == "Additional Charges::Bounty for Enemy of Hold")
        mcm.SetInfoText("The additional bounty to be imposed as a charge when you are an enemy of " + mcm.CurrentPage + ".")

    elseif (option == "Additional Charges::Bounty for Stolen Item")
        mcm.SetInfoText("The additional bounty to be imposed as a charge for each stolen item found when searched in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Additional Charges::Bounty for Contraband")
        mcm.SetInfoText("The additional bounty to be imposed as a charge for each contraband item found when searched in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Additional Charges::Bounty for Cell Key")
        mcm.SetInfoText("The additional bounty to be imposed as a charge if the jail's cell key is found when searched in " + mcm.CurrentPage + "'s jail.")

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Retain Items on Release")
        mcm.SetInfoText("Determines whether the items should be retained when released from " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Release::Minimum Bounty to Retain Items")
        mcm.SetInfoText("The minimum amount of bounty required in order to have the items retained in " + mcm.CurrentPage + "'s jail.")

    elseif (option == "Release::Re-Dress on Release")
        mcm.SetInfoText("Determines whether you should be re-dressed on release, if undressed while in " + mcm.CurrentPage + "'s jail.")

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================

    elseif (option == "Escape::Escape Bounty (%)")
        mcm.SetInfoText("The bounty added as a percentage of your current bounty, when escaping jail in " + mcm.CurrentPage + ".")

    elseif (option == "Escape::Escape Bounty")
        mcm.SetInfoText("The bounty added when escaping jail in " + mcm.CurrentPage + ".")

    elseif (option == "Escape::Allow Surrendering")
        mcm.SetInfoText("Whether the guards will allow you to surrender after escaping jail in " + mcm.CurrentPage + ".")

    elseif (option == "Escape::Frisk Search upon Captured")
        mcm.SetInfoText("Whether to have a frisk search be performed upon being captured in "  + mcm.CurrentPage + ".\n" + "(Note: The frisk search will take place regardless of whether the conditions are met in Frisking)")

    elseif (option == "Escape::Strip Search upon Captured")
        mcm.SetInfoText("Whether to have a strip search be performed upon being captured in " + mcm.CurrentPage + ".\n (Note: The strip search will take place regardless of whether the conditions are met in Stripping)")

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
    ;                       BOUNTY DECAYING
    ; ==========================================================

    elseif (option == "Bounty Decaying::Enable Bounty Decaying")
        mcm.SetInfoText("Whether to enable bounty loss over time in " + mcm.CurrentPage + ".")

    elseif (option == "Bounty Decaying::Decay while in Prison")
        mcm.SetInfoText("Whether to enable bounty decaying for " + mcm.CurrentPage + " while in jail.")

    elseif (option == "Bounty Decaying::Bounty Lost (%)")
        int bountyDecayUpdateInterval = mcm.GetOptionSliderValue("General::Bounty Decay (Update Interval)", "General") as int
        mcm.SetInfoText("The amount of bounty lost as a percentage of your current bounty in " + mcm.CurrentPage + " each " + bountyDecayUpdateInterval + " in game hours. (Configured in General page)")

    elseif (option == "Bounty Decaying::Bounty Lost")
        int bountyDecayUpdateInterval = mcm.GetOptionSliderValue("General::Bounty Decay (Update Interval)", "General") as int
        mcm.SetInfoText("The amount of bounty lost in " + mcm.CurrentPage + " each " + bountyDecayUpdateInterval + " in game hours. (Configured in General page)")
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
        minRange = 0
        intervalSteps = 50
        defaultValue = mcm.ARREST_DEFAULT_GUARANTEED_PAYABLE_BOUNTY

    elseif (option == "Arrest::Maximum Payable Bounty")
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY

    elseif (option == "Arrest::Maximum Payable Bounty (Chance)")
        minRange = 0
        maxRange = 100
        defaultValue = mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
        minRange = 0
        maxRange = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT

    elseif (option == "Arrest::Additional Bounty when Resisting")
        minRange = 0
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT

    elseif (option == "Arrest::Additional Bounty when Defeated (%)")
        minRange = 0
        maxRange = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT

    elseif (option == "Arrest::Additional Bounty when Defeated")
        minRange = 0
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT

    elseif (option == "Arrest::Unequip Hand Garments")
        minRange = -100
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY

    elseif (option == "Arrest::Unequip Head Garments")
        minRange = -100
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY

    elseif (option == "Arrest::Unequip Foot Garments")
        minRange = -100
        intervalSteps = 100
        defaultValue = mcm.ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY

    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Minimum Bounty for Frisking")
        intervalSteps = 100
        defaultValue = mcm.FRISKING_DEFAULT_MIN_BOUNTY

    elseif (option == "Frisking::Guaranteed Payable Bounty")
        minRange = 0
        intervalSteps = 100
        defaultValue = mcm.FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY

    elseif (option == "Frisking::Maximum Payable Bounty")
        minRange = 0
        intervalSteps = 100
        defaultValue = mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY

    elseif (option == "Frisking::Maximum Payable Bounty (Chance)")
        minRange = 0
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

    elseif (option == "Jail::Bounty Exchange")
        minRange = 1
        maxRange = 100

    elseif (option == "Jail::Bounty to Sentence")
        minRange = 100
        intervalSteps = 100
        defaultValue = mcm.PRISON_DEFAULT_BOUNTY_TO_SENTENCE

    elseif (option == "Jail::Minimum Sentence")
        maxRange =  mcm.GetOptionSliderValue("Jail::Maximum Sentence") - 1
        defaultValue = float_if(mcm.PRISON_DEFAULT_MIN_SENTENCE_DAYS > maxRange, maxRange, mcm.PRISON_DEFAULT_MIN_SENTENCE_DAYS)

    elseif (option == "Jail::Maximum Sentence")
        minRange = mcm.GetOptionSliderValue("Jail::Minimum Sentence") + 1
        maxRange = 365
        defaultValue = float_if(mcm.PRISON_DEFAULT_MAX_SENTENCE_DAYS > maxRange, maxRange, mcm.PRISON_DEFAULT_MAX_SENTENCE_DAYS)

    elseif (option == "Jail::Day to fast forward from")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")
        defaultValue = float_if(mcm.PRISON_DEFAULT_DAY_FAST_FORWARD > maxRange, maxRange, mcm.PRISON_DEFAULT_DAY_FAST_FORWARD)

    elseif (option == "Jail::Chance to lose Skills")
        minRange = 0
        maxRange = 100
        defaultValue = mcm.PRISON_DEFAULT_CHANCE_START_LOSING_SKILLS

    elseif (option == "Jail::Day to start losing Skills")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")
        defaultValue = 1

    elseif (option == "Jail::Cell Search Thoroughness")
        maxRange = 10

    elseif (option == "Jail::Hands Bound (Minimum Bounty)")
        intervalSteps = 100
        defaultValue = mcm.PRISON_DEFAULT_HANDS_BOUND_BOUNTY

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Stripping::Minimum Bounty to Undress")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_MIN_BOUNTY

    elseif (option == "Stripping::Minimum Violent Bounty to Undress")
        intervalSteps = 10
        defaultValue = mcm.UNDRESSING_DEFAULT_MIN_BOUNTY

    elseif (option == "Stripping::Minimum Sentence to Undress")
        minRange = mcm.GetOptionSliderValue("Jail::Minimum Sentence")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")
        defaultValue = 20

    elseif (option == "Stripping::Forced Undressing (Bounty)")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY

    elseif (option == "Stripping::Strip Search Thoroughness")
        maxRange = 10
        defaultValue = mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS

    elseif (option == "Clothing::Maximum Bounty")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY

    elseif (option == "Clothing::Maximum Violent Bounty")
        intervalSteps = 10
        defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY

    elseif (option == "Clothing::Maximum Sentence")
        minRange = mcm.GetOptionSliderValue("Jail::Minimum Sentence")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")
        defaultValue = float_if(60 > maxRange, maxRange, 60)

    ; ==========================================================
    ;                      ADDITIONAL CHARGES
    ; ==========================================================

    elseif (option == "Additional Charges::Bounty for Impersonation")
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Enemy of Hold")
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Stolen Item")
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Contraband")
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Cell Key")
        intervalSteps = 100

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Minimum Bounty to Retain Items")
        intervalSteps = 100
        defaultValue = mcm.RELEASE_DEFAULT_GIVE_ITEMS_BACK_BOUNTY

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================
    elseif (option == "Escape::Escape Bounty (%)")
        minRange = 0
        maxRange = 100
        defaultValue = mcm.ESCAPE_DEFAULT_BOUNTY_PERCENT

    elseif (option == "Escape::Escape Bounty")
        minRange = 0
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
    ;                       BOUNTY DECAYING
    ; ==========================================================

    elseif (option == "Bounty Decaying::Bounty Lost (%)")
        maxRange = 100
        defaultValue = mcm.BOUNTY_DEFAULT_BOUNTY_LOST_PERCENT

    elseif (option == "Bounty Decaying::Bounty Lost")
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

    elseif (option == "Arrest::Maximum Payable Bounty (Chance)")
        formatString = "{0}%"

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
    
    elseif (option == "Jail::Bounty Exchange")
        formatString = "{0} Violent Bounty = 100 Bounty"

    elseif (option == "Jail::Bounty to Sentence")
        formatString = "{0} Bounty = 1 Day"

    elseif (option == "Jail::Minimum Sentence")
        formatString = "{0} Days"
    
    elseif (option == "Jail::Maximum Sentence")
        formatString = "{0} Days"

    elseif (option == "Jail::Cell Search Thoroughness")
        formatString = "{0}x"

    elseif (option == "Jail::Day to fast forward from")
        formatString = "{0}"

    elseif (option == "Jail::Day to start losing Skills")
        formatString = "{0}"

    elseif (option == "Jail::Chance to lose Skills")
        formatString = "{0}% Each Day"

    elseif (option == "Jail::Hands Bound (Minimum Bounty)")

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Stripping::Minimum Bounty to Undress")

    elseif (option == "Stripping::Minimum Violent Bounty to Undress")
        formatString = "{0} Violent Bounty"

    elseif (option == "Stripping::Minimum Sentence to Undress")
        formatString = "{0} Days"

    elseif (option == "Stripping::Forced Undressing (Bounty)")

    elseif (option == "Stripping::Strip Search Thoroughness")
        formatString = "{0}x"

    elseif (option == "Clothing::Maximum Bounty")

    elseif (option == "Clothing::Maximum Violent Bounty")
        formatString = "{0} Violent Bounty"

    elseif (option == "Clothing::Maximum Sentence")
        formatString = "{0} Days"

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Minimum Bounty to Retain Items")

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
    ;                       BOUNTY DECAYING
    ; ==========================================================

    elseif (option == "Bounty Decaying::Bounty Lost (%)")
        formatString = "{0}% of Bounty"

    elseif (option == "Bounty Decaying::Bounty Lost")

    endif

    ; Handle any slider option that depends on the current option being set
    HandleSliderOptionDependency(mcm, option, value)

    ; Set the main option value
    mcm.SetOptionSliderValue(option, value, formatString)
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    if (option == "Jail::Cell Lock Level")
        mcm.SetMenuDialogOptions(mcm.LockLevels)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.LockLevels, "Adept"))

    elseif (option == "Jail::Handle Skill Loss")
        mcm.SetMenuDialogOptions(mcm.PrisonSkillHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.PrisonSkillHandlingOptions, "Random"))

    elseif (option == "Stripping::Handle Undressing On")
        mcm.SetMenuDialogOptions(mcm.UndressingHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Sentence"))

    elseif (option == "Clothing::Handle Clothing On")
        mcm.SetMenuDialogOptions(mcm.ClothingHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Sentence"))
    endif
endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, string option, int menuIndex) global
    if (option == "Jail::Cell Lock Level")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.LockLevels[menuIndex])
        endif

    elseif (option == "Jail::Handle Skill Loss")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.PrisonSkillHandlingOptions[menuIndex])
        endif

    elseif (option == "Stripping::Handle Undressing On")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.UndressingHandlingOptions[menuIndex])

            bool allowUndressing = mcm.GetOptionToggleState("Stripping::Allow Undressing")

            mcm.SetOptionDependencyBool("Stripping::Minimum Bounty to Undress",            allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Bounty"))
            mcm.SetOptionDependencyBool("Stripping::Minimum Violent Bounty to Undress",    allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Bounty"))
            mcm.SetOptionDependencyBool("Stripping::Minimum Sentence to Undress",          allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Sentence"))
        endif

    elseif (option == "Clothing::Handle Clothing On")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.ClothingHandlingOptions[menuIndex])

            bool allowWearingClothes = mcm.GetOptionToggleState("Clothing::Allow Wearing Clothes")

            mcm.SetOptionDependencyBool("Clothing::Maximum Bounty",           allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Bounty"))
            mcm.SetOptionDependencyBool("Clothing::Maximum Violent Bounty",   allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Bounty"))
            mcm.SetOptionDependencyBool("Clothing::Maximum Sentence",         allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Sentence"))
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
