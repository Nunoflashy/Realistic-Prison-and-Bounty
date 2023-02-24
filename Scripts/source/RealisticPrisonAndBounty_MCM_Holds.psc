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
    mcm.AddOptionText("Times Arrested", "0")
    mcm.AddOptionText("Times Frisked", "0")
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

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "When Arrested", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Allow Arrest Transfer",           mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER)
    mcm.AddOptionSlider("Unequip Hand Garments",           mcm.ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Unequip Head Garments",           mcm.ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Unequip Foot Garments",           mcm.ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY, "{0} Bounty")
    
    mcm.AddOptionCategory("Frisking")
    mcm.AddTextOption("", "When Arrested", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Allow Frisking",                         mcm.FRISKING_DEFAULT_ALLOW)
    mcm.AddOptionSlider("Minimum Bounty for Frisking",            mcm.FRISKING_DEFAULT_MIN_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Guaranteed Payable Bounty",              mcm.FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty",                 mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty (Chance)",        mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE, "{0}%")
    mcm.AddOptionSlider("Frisk Search Thoroughness",              mcm.FRISKING_DEFAULT_FRISK_THOROUGHNESS, "{0}x")

    mcm.AddTextOption("", "When Frisked", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Confiscate Stolen Items",                mcm.FRISKING_DEFAULT_CONFISCATE_ITEMS)
    mcm.AddOptionToggle("Strip Search if Stolen Items Found",     mcm.FRISKING_DEFAULT_STRIP_IF_STOLEN_FOUND)
    mcm.AddOptionSlider("Minimum No. of Stolen Items Required",   mcm.FRISKING_DEFAULT_NUMBER_STOLEN_ITEMS_REQUIRED, "{0} Items")

    mcm.AddOptionCategory("Release")
    mcm.AddTextOption("", "When Undressed", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Give items back on Release",             mcm.RELEASE_DEFAULT_GIVE_ITEMS_BACK)
    mcm.AddOptionSlider("Give items back on Release (Bounty)",    mcm.RELEASE_DEFAULT_GIVE_ITEMS_BACK_BOUNTY, "{0} Bounty")
    mcm.AddOptionToggle("Re-dress on Release",                    mcm.RELEASE_DEFAULT_REDRESS)

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddOptionCategory("Bounty Hunting")
    mcm.AddOptionToggle("Enable Bounty Hunters",        mcm.BOUNTY_HUNTERS_DEFAULT_ENABLE)
    mcm.AddOptionToggle("Allow Outlaw Bounty Hunters",  mcm.BOUNTY_HUNTERS_DEFAULT_ALLOW_OUTLAWS)
    mcm.AddOptionSlider("Minimum Bounty",               mcm.BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Bounty (Posse)",               mcm.BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY_GROUP, "{0} Bounty")
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    mcm.SetRenderedCategory("Stats")
    ; mcm.AddEmptyOption()
    mcm.AddTextOption("", mcm.CurrentPage, mcm.OPTION_DISABLED)
    mcm.AddOptionText("Days in Prison", "0 Days")
    mcm.AddOptionText("Longest Sentence", "0 Days")
    mcm.AddOptionText("Times Jailed", "0")
    mcm.AddOptionText("Times Escaped", "0")
    mcm.AddOptionText("Times Undressed", "0")
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Prison")
    mcm.AddOptionSlider("Bounty Exchange",                      mcm.PRISON_DEFAULT_BOUNTY_TO_SENTENCE, "{0} Violent Bounty = 100 Bounty")
    mcm.AddOptionSlider("Bounty to Sentence",                   mcm.PRISON_DEFAULT_BOUNTY_TO_SENTENCE, "{0} Bounty = 1 Day")
    mcm.AddOptionSlider("Minimum Sentence",                     mcm.PRISON_DEFAULT_MIN_SENTENCE_DAYS, "{0} Days")
    mcm.AddOptionSlider("Maximum Sentence",                     mcm.PRISON_DEFAULT_MAX_SENTENCE_DAYS, "{0} Days")
    mcm.AddOptionToggle("Allow Unconditional Imprisonment",     mcm.PRISON_DEFAULT_ALLOW_UNCONDITIONAL_PRISON)
    mcm.AddOptionToggle("Sentence pays Bounty",                 mcm.PRISON_DEFAULT_SENTENCE_PAYS_BOUNTY)
    mcm.AddOptionSlider("Cell Search Thoroughness",             mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, "{0}x")

    mcm.AddTextOption("", "WHEN IN PRISON",                 mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Fast Forward",                     mcm.PRISON_DEFAULT_FAST_FORWARD)
    mcm.AddOptionSlider("Day to fast forward from",         mcm.PRISON_DEFAULT_DAY_FAST_FORWARD)
    mcm.AddOptionMenu("Handle Skill Loss", "Random")
    mcm.AddOptionSlider("Day to start losing Skills",       mcm.PRISON_DEFAULT_DAY_START_LOSING_SKILLS)
    mcm.AddOptionSlider("Chance to lose Skills",            mcm.PRISON_DEFAULT_CHANCE_START_LOSING_SKILLS, "{0}% Each Day")
    mcm.AddOptionMenu("Cell Lock Level",                    mcm.PRISON_DEFAULT_CELL_LOCK_LEVEL)

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Undressing")
    mcm.AddOptionToggle("Allow Undressing",                 mcm.UNDRESSING_DEFAULT_ALLOW)
    mcm.AddOptionMenuKey("Handle Undressing On", "Handle Based On (Undressing)",                     "Minimum Sentence")
    mcm.AddOptionSlider("Minimum Bounty to Undress",        mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Minimum Violent Bounty to Undress",        mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, "{0} Violent Bounty")
    mcm.AddOptionSlider("Minimum Sentence to Undress",      0, "{0} Days")
    mcm.AddOptionToggle("Undress when Defeated",            mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED)
    mcm.AddOptionToggle("Undress at Cell",                  mcm.UNDRESSING_DEFAULT_AT_CELL)
    mcm.AddOptionToggle("Undress at Chest",                 mcm.UNDRESSING_DEFAULT_AT_CHEST)
    mcm.AddOptionSlider("Forced Undressing (Bounty)",       mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY, "{0} Bounty")
    mcm.AddOptionToggle("Forced Undressing when Defeated",  mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED)
    mcm.AddOptionSlider("Strip Search Thoroughness",        mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, "{0}x")

    mcm.AddTextOption("", "When Undressed", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Allow Wearing Clothes",            mcm.UNDRESSING_DEFAULT_ALLOW_CLOTHES)
    mcm.AddOptionMenuKey("Handle Clothing On", "Handle Based On (Clothing)",                      "Maximum Sentence")
    mcm.AddOptionToggle("When Defeated",                    mcm.UNDRESSING_DEFAULT_REDRESS_WHEN_DEFEATED)
    mcm.AddTextOption("OR", "", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Maximum Bounty",                   mcm.UNDRESSING_DEFAULT_REDRESS_BOUNTY, "{0} Bounty")
    mcm.AddOptionSlider("Maximum Violent Bounty",                   mcm.UNDRESSING_DEFAULT_REDRESS_BOUNTY, "{0} Violent Bounty")
    mcm.AddOptionSlider("Maximum Sentence",                   0, "{0} Days")

    if (mcm.CurrentPage == "The Reach")
        mcm.AddTextOption("", "Cidhna Mine", mcm.OPTION_DISABLED)
        mcm.AddOptionToggleKey("Allow Wearing Clothes", "Allow Wearing Clothes (Cidhna Mine)",   mcm.UNDRESSING_DEFAULT_ALLOW_CLOTHES)
        mcm.AddOptionToggleKey("When Defeated",  "When Defeated (Cidhna Mine)",                  mcm.UNDRESSING_DEFAULT_REDRESS_WHEN_DEFEATED)
        mcm.AddTextOption("OR", "", mcm.OPTION_DISABLED)
        mcm.AddOptionSliderKey("Maximum Bounty",  "Maximum Bounty (Cidhna Mine)",                 mcm.UNDRESSING_DEFAULT_REDRESS_BOUNTY, "{0} Bounty")
    endif

    mcm.AddOptionCategory("Escape")
    mcm.AddOptionSlider("Escape Bounty (%)",                mcm.ESCAPE_DEFAULT_BOUNTY_PERCENT, "{0}% of Bounty")
    mcm.AddOptionSlider("Escape Bounty",                    mcm.ESCAPE_DEFAULT_BOUNTY_FLAT, "{0} Bounty")
    mcm.AddOptionToggle("Allow Surrendering",               mcm.ESCAPE_DEFAULT_ALLOW_SURRENDER)
    mcm.AddOptionToggle("Frisk Search upon Captured",       mcm.ESCAPE_DEFAULT_FRISK_ON_CAPTURE)
    mcm.AddOptionToggle("Undress upon Captured",            mcm.ESCAPE_DEFAULT_UNDRESS_ON_CAPTURE)

    mcm.AddOptionCategory("Bounty Decaying")
    ; mcm.AddTextOption("", "Bounty Decay", mcm.OPTION_FLAG_DISABLED)
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

    bool allowUndressing                = mcm.GetOptionToggleState("Undressing::Allow Undressing")
    bool allowWearingClothes            = mcm.GetOptionToggleState("Undressing::Allow Wearing Clothes")
    bool isUndressingBountyHandling     = mcm.GetOptionMenuValue("Undressing::Handle Based On (Undressing)") == "Minimum Bounty"
    bool isUndressingSentenceHandling   = mcm.GetOptionMenuValue("Undressing::Handle Based On (Undressing)") == "Minimum Sentence"
    bool isClothingBountyHandling       = mcm.GetOptionMenuValue("Undressing::Handle Based On (Clothing)")   == "Maximum Bounty"
    bool isClothingSentenceHandling     = mcm.GetOptionMenuValue("Undressing::Handle Based On (Clothing)")   == "Maximum Sentence"

    mcm.SetOptionDependencyBool("Undressing::Handle Based On (Undressing)",         allowUndressing)
    mcm.SetOptionDependencyBool("Undressing::Minimum Bounty to Undress",            allowUndressing && isUndressingBountyHandling)
    mcm.SetOptionDependencyBool("Undressing::Minimum Violent Bounty to Undress",    allowUndressing && isUndressingBountyHandling)
    mcm.SetOptionDependencyBool("Undressing::Minimum Sentence to Undress",          allowUndressing && isUndressingSentenceHandling)
    mcm.SetOptionDependencyBool("Undressing::Undress when Defeated",                allowUndressing)
    mcm.SetOptionDependencyBool("Undressing::Undress at Cell",                      allowUndressing)
    mcm.SetOptionDependencyBool("Undressing::Undress at Chest",                     allowUndressing)
    mcm.SetOptionDependencyBool("Undressing::Forced Undressing (Bounty)",           allowUndressing)
    mcm.SetOptionDependencyBool("Undressing::Forced Undressing when Defeated",      allowUndressing)
    mcm.SetOptionDependencyBool("Undressing::Strip Search Thoroughness",            allowUndressing)

    ; Clothing
    mcm.SetOptionDependencyBool("Undressing::Allow Wearing Clothes",            allowUndressing)
    mcm.SetOptionDependencyBool("Undressing::Handle Based On (Clothing)",       allowUndressing && allowWearingClothes)
    mcm.SetOptionDependencyBool("Undressing::When Defeated",                    allowUndressing && allowWearingClothes)
    mcm.SetOptionDependencyBool("Undressing::Maximum Bounty",                   allowUndressing && allowWearingClothes && isClothingBountyHandling)
    mcm.SetOptionDependencyBool("Undressing::Maximum Violent Bounty",           allowUndressing && allowWearingClothes && isClothingBountyHandling)
    mcm.SetOptionDependencyBool("Undressing::Maximum Sentence",                 allowUndressing && allowWearingClothes && isClothingSentenceHandling)

    ; ==========================================================
    ;                      FRISKING:UNDRESSING
    ; ==========================================================

    mcm.SetOptionDependencyBool("Frisking::Strip Search if Stolen Items Found",     allowFrisking && confiscateStolenItems && allowUndressing)
    mcm.SetOptionDependencyBool("Frisking::Minimum No. of Stolen Items Required",   allowFrisking && confiscateStolenItems && stripSearchStolenItemsFound && allowUndressing)

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================

    bool enableFastForward = mcm.GetOptionToggleState("Prison::Fast Forward")

    mcm.SetOptionDependencyBool("Prison::Day to fast forward from", enableFastForward)

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
    bool undressUponCaptured     = mcm.GetOptionToggleState("Escape::Undress upon Captured")

    mcm.SetOptionDependencyBool("Escape::Frisk Search upon Captured",   !undressUponCaptured && allowFrisking)
    mcm.SetOptionDependencyBool("Escape::Undress upon Captured",        allowUndressing)

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

    elseif (option == "Stats::Days in Prison")
        mcm.SetInfoText("The amount of days you have spent in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Stats::Longest Sentence")
        mcm.SetInfoText("The longest sentence you have been given in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Stats::Times Jailed")
        mcm.SetInfoText("The times you have been jailed in " + mcm.CurrentPage + ".")

    elseif (option == "Stats::Times Escaped")
        mcm.SetInfoText("The times you have escaped from " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Stats::Times Undressed")
        mcm.SetInfoText("The times you have been stripped off in " + mcm.CurrentPage + "'s prison.")

    ; ==========================================================
    ;                           ARREST
    ; ==========================================================

    elseif (option == "Arrest::Minimum Bounty to Arrest") 
        mcm.SetInfoText("The minimum bounty required in order to be arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Guaranteed Payable Bounty")
        mcm.SetInfoText("The guaranteed amount of bounty that a guard will accept as payment before arresting you in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Maximum Payable Bounty")
        mcm.SetInfoText("The maximum amount of bounty that is payable before arresting you in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Maximum Payable Bounty (Chance)")
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")

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
        mcm.SetInfoText("Whether to allow an unconscious arrest after being defeated.")

    elseif (option == "Arrest::Unequip Hand Garments")
        mcm.SetInfoText("Whether to unequip any hand garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (option == "Arrest::Unequip Head Garments")
        mcm.SetInfoText("Whether to unequip any head garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required")

    elseif (option == "Arrest::Unequip Foot Garments")
        mcm.SetInfoText("Whether to unequip any foot garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required")
    
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
        mcm.SetInfoText("Whether to have the player undressed if stolen items are found. \n (Note: If the strip search takes place, you will be imprisoned regardless of the bounty for the arrest)")

    elseif (option == "Frisking::Minimum No. of Stolen Items Required")
        mcm.SetInfoText("The minimum number of stolen items required to have the player undressed.")

    ; ==========================================================
    ;                           PRISON
    ; ==========================================================

    elseif (option == "Prison::Bounty Exchange")
        mcm.SetInfoText("The amount of violent bounty to be exchanged to normal bounty in order to determine the sentence in " + mcm.CurrentPage + ".")

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

    elseif (option == "Prison::Handle Skill Loss")
        mcm.SetInfoText("The way to handle skill progression loss when in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Prison::Day to start losing Skills")
        mcm.SetInfoText("The day to start losing skills when in prison in " + mcm.CurrentPage + ". \n(Configured individually in General page)")

    elseif (option == "Prison::Chance to lose Skills")
        mcm.SetInfoText("The chance to lose skills each day while in prison in " + mcm.CurrentPage + ". \n(Stats lost are configured in General page)")

    elseif (option == "Prison::Cell Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the cell search, higher values mean a more thorough searching of the cell and possibly any items you left there to be confiscated.")

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

    elseif (option == "Undressing::Minimum Violent Bounty to Undress")
        mcm.SetInfoText("The minimum violent bounty required to be undressed in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Undressing::Minimum Sentence to Undress")
        mcm.SetInfoText("The minimum sentence required to be undressed in " + mcm.CurrentPage + "'s prison.")

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
        
    elseif (option == "Undressing::Maximum Violent Bounty")
        mcm.SetInfoText("The maximum amount of violent bounty you can have in order to be given clothes when imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Undressing::Maximum Sentence")
        mcm.SetInfoText("The maximum sentence you can be given in order to be given clothes when imprisoned in " + mcm.CurrentPage + ".")

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
    ;                       BOUNTY DECAYING
    ; ==========================================================

    elseif (option == "Bounty Decaying::Enable Bounty Decaying")
        mcm.SetInfoText("Whether to enable bounty loss over time in " + mcm.CurrentPage + ".")

    elseif (option == "Bounty Decaying::Decay while in Prison")
        mcm.SetInfoText("Whether to enable bounty decaying for " + mcm.CurrentPage + " while in prison.")

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

    elseif (option == "Prison::Bounty Exchange")
        minRange = 1
        maxRange = 100

    elseif (option == "Prison::Bounty to Sentence")
        minRange = 100
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

    elseif (option == "Prison::Chance to lose Skills")
        minRange = 0
        maxRange = 100
        defaultValue = mcm.PRISON_DEFAULT_CHANCE_START_LOSING_SKILLS

    elseif (option == "Prison::Day to start losing Skills")
        maxRange = mcm.GetOptionSliderValue("Prison::Maximum Sentence")
        defaultValue = 1

    elseif (option == "Prison::Cell Search Thoroughness")
        maxRange = 10

    elseif (option == "Prison::Hands Bound (Minimum Bounty)")
        intervalSteps = 100
        defaultValue = mcm.PRISON_DEFAULT_HANDS_BOUND_BOUNTY

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Undressing::Minimum Bounty to Undress")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_MIN_BOUNTY

    elseif (option == "Undressing::Minimum Violent Bounty to Undress")
        intervalSteps = 10
        defaultValue = mcm.UNDRESSING_DEFAULT_MIN_BOUNTY

    elseif (option == "Undressing::Minimum Sentence to Undress")
        minRange = mcm.GetOptionSliderValue("Prison::Minimum Sentence")
        maxRange = mcm.GetOptionSliderValue("Prison::Maximum Sentence")
        defaultValue = 20

    elseif (option == "Undressing::Forced Undressing (Bounty)")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY

    elseif (option == "Undressing::Strip Search Thoroughness")
        maxRange = 10
        defaultValue = mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS

    elseif (option == "Undressing::Maximum Bounty")
        intervalSteps = 100
        defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY

    elseif (option == "Undressing::Maximum Violent Bounty")
        intervalSteps = 10
        defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY

    elseif (option == "Undressing::Maximum Sentence")
        minRange = mcm.GetOptionSliderValue("Prison::Minimum Sentence")
        maxRange = mcm.GetOptionSliderValue("Prison::Maximum Sentence")
        defaultValue = float_if(60 > maxRange, maxRange, 60)

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
    
    elseif (option == "Prison::Bounty Exchange")
        formatString = "{0} Violent Bounty = 100 Bounty"

    elseif (option == "Prison::Bounty to Sentence")
        formatString = "{0} Bounty = 1 Day"

    elseif (option == "Prison::Minimum Sentence")
        formatString = "{0} Days"

    elseif (option == "Prison::Maximum Sentence")
        formatString = "{0} Days"

    elseif (option == "Prison::Cell Search Thoroughness")
        formatString = "{0}x"

    elseif (option == "Prison::Day to fast forward from")
        formatString = "{0}"

    elseif (option == "Prison::Day to start losing Skills")
        formatString = "{0}"

    elseif (option == "Prison::Chance to lose Skills")
        formatString = "{0}% Each Day"

    elseif (option == "Prison::Hands Bound (Minimum Bounty)")

    ; ==========================================================
    ;                         UNDRESSING
    ; ==========================================================

    elseif (option == "Undressing::Minimum Bounty to Undress")

    elseif (option == "Undressing::Minimum Violent Bounty to Undress")
        formatString = "{0} Violent Bounty"

    elseif (option == "Undressing::Minimum Sentence to Undress")
        formatString = "{0} Days"

    elseif (option == "Undressing::Forced Undressing (Bounty)")

    elseif (option == "Undressing::Strip Search Thoroughness")
        formatString = "{0}x"

    elseif (option == "Undressing::Maximum Bounty")

    elseif (option == "Undressing::Maximum Violent Bounty")
        formatString = "{0} Violent Bounty"

    elseif (option == "Undressing::Maximum Sentence")
        formatString = "{0} Days"

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
    ;                       BOUNTY DECAYING
    ; ==========================================================

    elseif (option == "Bounty Decaying::Bounty Lost (%)")
        formatString = "{0}% of Bounty"

    elseif (option == "Bounty Decaying::Bounty Lost")

    endif

    mcm.SetOptionSliderValue(option, value, formatString)
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    if (option == "Prison::Cell Lock Level")
        mcm.SetMenuDialogOptions(mcm.LockLevels)
        mcm.SetMenuDialogDefaultIndex(2) ; Adept

    elseif (option == "Prison::Handle Skill Loss")
        mcm.SetMenuDialogOptions(mcm.PrisonSkillHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.PrisonSkillHandlingOptions, "Random"))

    elseif (option == "Undressing::Handle Based On (Undressing)")
        mcm.SetMenuDialogOptions(mcm.UndressingHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Sentence"))

    elseif (option == "Undressing::Handle Based On (Clothing)")
        mcm.SetMenuDialogOptions(mcm.ClothingHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Sentence"))
    endif
endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, string option, int menuIndex) global
    if (option == "Prison::Cell Lock Level")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.LockLevels[menuIndex])
        endif

    elseif (option == "Prison::Handle Skill Loss")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.PrisonSkillHandlingOptions[menuIndex])
        endif

    elseif (option == "Undressing::Handle Based On (Undressing)")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.UndressingHandlingOptions[menuIndex])

            bool allowUndressing = mcm.GetOptionToggleState("Undressing::Allow Undressing")

            mcm.SetOptionDependencyBool("Undressing::Minimum Bounty to Undress",            allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Bounty"))
            mcm.SetOptionDependencyBool("Undressing::Minimum Violent Bounty to Undress",    allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Bounty"))
            mcm.SetOptionDependencyBool("Undressing::Minimum Sentence to Undress",          allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Sentence"))
        endif

    elseif (option == "Undressing::Handle Based On (Clothing)")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.ClothingHandlingOptions[menuIndex])

            bool allowWearingClothes = mcm.GetOptionToggleState("Undressing::Allow Wearing Clothes")

            mcm.SetOptionDependencyBool("Undressing::Maximum Bounty",           allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Bounty"))
            mcm.SetOptionDependencyBool("Undressing::Maximum Violent Bounty",   allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Bounty"))
            mcm.SetOptionDependencyBool("Undressing::Maximum Sentence",         allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Sentence"))
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
