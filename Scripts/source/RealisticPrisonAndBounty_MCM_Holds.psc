Scriptname RealisticPrisonAndBounty_MCM_Holds hidden

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_MCM

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.IsHoldCurrentPage() ; Only handle if the page rendered if any of the holds
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

    EndBenchmark(bench, mcm.CurrentPage + " page loaded -")
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("Arrest")
    mcm.AddTextOption("", "When Free", mcm.OPTION_DISABLED)
    ; mcm.AddOptionSlider("Minimum Bounty to Arrest", "{0} Bounty") ; Temporarily Removed
    mcm.AddOptionSlider("Guaranteed Payable Bounty", "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty", "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty (Chance)", "{0}%")
    ; mcm.AddOptionToggle("Always Arrest for Violent Crimes") ; Temporarily Removed
    mcm.AddEmptyOption()
    mcm.AddTextOption("", "When Eluding", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Additional Bounty when Eluding", "Additional Bounty when Eluding (%)", "{1}% of Bounty")
    mcm.AddOptionSlider("Additional Bounty when Eluding", "{0} Bounty")
    mcm.AddEmptyOption()
    mcm.AddTextOption("", "When Resisting", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Additional Bounty when Resisting", "Additional Bounty when Resisting (%)", "{1}% of Bounty")
    mcm.AddOptionSlider("Additional Bounty when Resisting", "{0} Bounty")
    mcm.AddEmptyOption()
    mcm.AddTextOption("", "When Defeated", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Additional Bounty when Defeated", "Additional Bounty when Defeated (%)", "{1}% of Bounty")
    mcm.AddOptionSlider("Additional Bounty when Defeated", "{0} Bounty")
    ; mcm.AddOptionToggle("Allow Civilian Capture") ; Temporarily Removed
    ; mcm.AddOptionToggle("Allow Unconscious Arrest") ; Temporarily Removed
    ; mcm.AddOptionToggle("Allow Unconditional Arrest") ; Temporarily Removed

    mcm.AddEmptyOption()
    
    mcm.AddOptionCategory("Infamy")
    mcm.AddOptionToggle("Enable Infamy")
    mcm.AddOptionSlider("Infamy Recognized Threshold", "{0} Infamy")
    mcm.AddOptionSlider("Infamy Known Threshold", "{0} Infamy")
    mcm.AddEmptyOption()
    mcm.AddTextOption("", "While Jailed", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Infamy Gained", "Infamy Gained (%)", "{2}% of Bounty")
    mcm.AddOptionSlider("Infamy Gained", "{0} Infamy")
    mcm.AddOptionSliderKey("Infamy Gain Modifier (Recognized)", "Infamy Gain Modifier (Recognized)", "{1}x")
    mcm.AddOptionSliderKey("Infamy Gain Modifier (Known)", "Infamy Gain Modifier (Known)", "{1}x")
    mcm.AddEmptyOption()
    mcm.AddTextOption("", "When Free", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Infamy Lost", "Infamy Lost (%)", "{2}% of Infamy")
    mcm.AddOptionSlider("Infamy Lost", "{0} Infamy")
    mcm.AddOptionSliderKey("Infamy Loss Modifier (Recognized)", "Infamy Loss Modifier (Recognized)", "{0}x")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Bounty Decaying")
    mcm.AddOptionToggle("Enable Bounty Decaying")
    mcm.AddOptionToggle("Decay if Known as Criminal")
    mcm.AddOptionSliderKey("Bounty Lost", "Bounty Lost (%)", "{1}% of Bounty")
    mcm.AddOptionSlider("Bounty Lost", "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Bounty Hunting")
    mcm.AddOptionToggle("Enable Bounty Hunters")
    mcm.AddOptionToggle("Allow Outlaw Bounty Hunters")
    mcm.AddOptionSlider("Minimum Bounty", "{0} Bounty")
    mcm.AddOptionSlider("Bounty (Posse)", "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Frisking")
    mcm.AddOptionToggle("Allow Frisking")
    ; mcm.AddOptionToggle("Unconditional Frisking")
    mcm.AddOptionSlider("Minimum Bounty for Frisking", "{0} Bounty")
    mcm.AddOptionSlider("Frisk Search Thoroughness", "{0}x")
    mcm.AddEmptyOption()        
    mcm.AddTextOption("", "When Frisked", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Confiscate Stolen Items")
    mcm.AddOptionToggle("Strip Search if Stolen Items Found")
    mcm.AddOptionSlider("Minimum No. of Stolen Items Required", "{0} Items")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Stripping")
    mcm.AddOptionToggle("Allow Stripping")
    mcm.AddOptionMenu("Handle Stripping On")
    mcm.AddOptionSlider("Minimum Bounty to Strip", "{0} Bounty",                                    defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Minimum Violent Bounty to Strip", "{0} Violent Bounty",                    defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Minimum Sentence to Strip", "{0} Days")
    ; mcm.AddOptionToggle("Strip when Defeated")
    mcm.AddOptionSlider("Strip Search Thoroughness", "{0}x")
    mcm.AddOptionSlider("Strip Search Thoroughness Modifier", "{0} Bounty = 1x")
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("Jail")
    mcm.AddTextOption("", "When Arrested", mcm.OPTION_DISABLED)
    ; mcm.AddOptionToggle("Unconditional Imprisonment")
    mcm.AddOptionSlider("Guaranteed Payable Bounty", "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty", "{0} Bounty")
    mcm.AddOptionSlider("Maximum Payable Bounty (Chance)", "{0}%")
    mcm.AddEmptyOption()
    mcm.AddOptionSlider("Bounty Exchange", "{0} Violent Bounty = 100 Bounty")
    mcm.AddOptionSlider("Bounty to Sentence", "{0} Bounty = 1 Day")
    mcm.AddOptionSlider("Minimum Sentence", "{0} Days")
    mcm.AddOptionSlider("Maximum Sentence", "{0} Days")
    mcm.AddOptionSlider("Cell Search Thoroughness", "{0}x")
    mcm.AddOptionMenu("Cell Lock Level")
    mcm.AddEmptyOption()
    mcm.AddTextOption("", "While Jailed", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Fast Forward")
    mcm.AddOptionSlider("Day to fast forward from")
    mcm.AddEmptyOption()

    mcm.AddOptionMenu("Handle Skill Loss")
    mcm.AddOptionSlider("Day to Start Losing Skills")
    mcm.AddOptionSlider("Chance to lose Skills", "{0}% Each Day")
    mcm.AddEmptyOption()

    mcm.AddOptionSlider("Recognized Criminal Penalty", "{1}% of Infamy")
    mcm.AddOptionSlider("Known Criminal Penalty", "{1}% of Infamy")
    mcm.AddOptionSlider("Minimum Bounty to Trigger", "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "WHEN RELEASED", mcm.OPTION_DISABLED)
    mcm.SetRenderedCategory("Release")
    mcm.AddOptionToggle("Enable Release Fees")
    mcm.AddOptionSlider("Chance for Event", "{0}%",                                         defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Minimum Bounty to owe Fees", "{0} Bounty",                         defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Release Fees", "Release Fees (%)", "{1}% of Bounty as Gold",    defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Release Fees", "{0} Gold",                                         defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Days Given to Pay", "{0} Days",                                    defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
    mcm.AddOptionToggle("Enable Item Retention")
    mcm.AddOptionSlider("Minimum Bounty to Retain Items", "{0} Bounty")
    mcm.AddOptionToggle("Auto Re-Dress on Release")

    mcm.AddEmptyOption()
    mcm.AddTextOption("", "WHEN ESCAPING", mcm.OPTION_DISABLED)
    mcm.SetRenderedCategory("Escape")
    mcm.AddOptionSliderKey("Escape Bounty", "Escape Bounty (%)", "{1}% of Bounty")
    mcm.AddOptionSlider("Escape Bounty", "{0} Bounty")
    ; mcm.AddOptionSlider("Escape Attempt Modifier", "{2}x per Escape")
    mcm.AddOptionToggle("Account for Time Served")
    ; mcm.AddOptionToggle("Allow Surrendering")
    mcm.AddOptionToggle("Frisk Search upon Captured", defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Strip Search upon Captured")

    ; mcm.AddEmptyOption()

    ; mcm.AddOptionCategory("Additional Charges")
    ; mcm.AddTextOption("", "During Processing", mcm.OPTION_DISABLED)
    ; mcm.AddOptionSlider("Bounty for Impersonation", "{0} Bounty")
    ; mcm.AddOptionSlider("Bounty for Enemy of Hold", "{0} Bounty")
    ; mcm.AddEmptyOption()
    ; mcm.AddTextOption("", "During Frisk or Strip Search", mcm.OPTION_DISABLED)
    ; mcm.AddOptionSlider("Bounty for Stolen Items", "{0} Bounty")
    ; mcm.AddOptionSlider("Bounty for Stolen Item", "{1}% of Item Value")
    ; mcm.AddOptionSlider("Bounty for Contraband", "{0} Bounty")
    ; mcm.AddOptionSlider("Bounty for Cell Key", "{0} Bounty")

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Clothing")
    mcm.AddTextOption("", "When Undressed", mcm.OPTION_DISABLED)
    mcm.AddOptionToggle("Allow Clothing")
    mcm.AddOptionMenu("Handle Clothing On",                                                                     defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Maximum Bounty to Clothe", "Maximum Bounty", "{0} Bounty",                          defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Maximum Violent Bounty to Clothe", "Maximum Violent Bounty", "{0} Violent Bounty",  defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Maximum Sentence to Clothe", "Maximum Sentence", "{0} Days",                        defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionToggleKey("Clothe When Defeated", "When Defeated",                                             defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionMenu("Outfit",                                                                                 defaultFlags = mcm.OPTION_DISABLED)
endFunction

function HandleDependencies(RealisticPrisonAndBounty_MCM mcm) global

    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    bool allowFrisking                  = mcm.GetOptionToggleState("Frisking::Allow Frisking")
    bool unconditionalFrisking          = mcm.GetOptionToggleState("Frisking::Unconditional Frisking")
    bool confiscateStolenItems          = mcm.GetOptionToggleState("Frisking::Confiscate Stolen Items")
    bool stripSearchStolenItemsFound    = mcm.GetOptionToggleState("Frisking::Strip Search if Stolen Items Found")

    mcm.SetOptionDependencyBool("Frisking::Unconditional Frisking",                 allowFrisking)
    mcm.SetOptionDependencyBool("Frisking::Minimum Bounty for Frisking",            allowFrisking && !unconditionalFrisking)
    mcm.SetOptionDependencyBool("Frisking::Frisk Search Thoroughness",              allowFrisking)
    mcm.SetOptionDependencyBool("Frisking::Confiscate Stolen Items",                allowFrisking)

    ; ==========================================================
    ;                          STRIPPING
    ; ==========================================================

    bool allowUndressing                = mcm.GetOptionToggleState("Stripping::Allow Stripping")
    bool isStrippingBountyHandling      = mcm.GetOptionMenuValue("Stripping::Handle Stripping On") == "Minimum Bounty"
    bool isStrippingSentenceHandling    = mcm.GetOptionMenuValue("Stripping::Handle Stripping On") == "Minimum Sentence"

    mcm.SetOptionDependencyBool("Stripping::Handle Stripping On",                   allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Minimum Bounty to Strip",               allowUndressing && isStrippingBountyHandling)
    mcm.SetOptionDependencyBool("Stripping::Minimum Violent Bounty to Strip",       allowUndressing && isStrippingBountyHandling)
    mcm.SetOptionDependencyBool("Stripping::Minimum Sentence to Strip",             allowUndressing && isStrippingSentenceHandling)
    mcm.SetOptionDependencyBool("Stripping::Strip when Defeated",                   allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Strip Search Thoroughness",             allowUndressing)
    mcm.SetOptionDependencyBool("Stripping::Strip Search Thoroughness Modifier",    allowUndressing)

    ; ==========================================================
    ;                           CLOTHING
    ; ==========================================================

    bool allowWearingClothes            = mcm.GetOptionToggleState("Clothing::Allow Clothing")
    bool isClothingBountyHandling       = mcm.GetOptionMenuValue("Clothing::Handle Clothing On")   == "Maximum Bounty"
    bool isClothingSentenceHandling     = mcm.GetOptionMenuValue("Clothing::Handle Clothing On")   == "Maximum Sentence"
    
    mcm.SetOptionDependencyBool("Clothing::Allow Clothing",                   allowUndressing)
    mcm.SetOptionDependencyBool("Clothing::Handle Clothing On",               allowUndressing && allowWearingClothes)
    mcm.SetOptionDependencyBool("Clothing::When Defeated",                    allowUndressing && allowWearingClothes)
    mcm.SetOptionDependencyBool("Clothing::Maximum Bounty",                   allowUndressing && allowWearingClothes && isClothingBountyHandling)
    mcm.SetOptionDependencyBool("Clothing::Maximum Violent Bounty",           allowUndressing && allowWearingClothes && isClothingBountyHandling)
    mcm.SetOptionDependencyBool("Clothing::Maximum Sentence",                 allowUndressing && allowWearingClothes && isClothingSentenceHandling)
    mcm.SetOptionDependencyBool("Clothing::Outfit",                           allowUndressing && allowWearingClothes)

    ; ==========================================================
    ;                      FRISKING:UNDRESSING
    ; ==========================================================

    mcm.SetOptionDependencyBool("Frisking::Strip Search if Stolen Items Found",     allowFrisking && confiscateStolenItems && allowUndressing)
    mcm.SetOptionDependencyBool("Frisking::Minimum No. of Stolen Items Required",   allowFrisking && confiscateStolenItems && stripSearchStolenItemsFound && allowUndressing)

    ; ==========================================================
    ;                      ADDITIONAL CHARGES
    ; ==========================================================
    
    mcm.SetOptionDependencyBool("Additional Charges::Bounty for Stolen Items",   (allowFrisking && confiscateStolenItems) || allowUndressing)
    mcm.SetOptionDependencyBool("Additional Charges::Bounty for Stolen Item",   (allowFrisking && confiscateStolenItems) || allowUndressing)
    mcm.SetOptionDependencyBool("Additional Charges::Bounty for Contraband",    (allowFrisking && confiscateStolenItems) || allowUndressing)
    mcm.SetOptionDependencyBool("Additional Charges::Bounty for Cell Key",      (allowFrisking && confiscateStolenItems) || allowUndressing)

    ; ==========================================================
    ;                           INFAMY
    ; ==========================================================

    bool isInfamyEnabled = mcm.GetOptionToggleState("Infamy::Enable Infamy")

    mcm.SetOptionDependencyBool("Infamy::Infamy Recognized Threshold",          isInfamyEnabled)
    mcm.SetOptionDependencyBool("Infamy::Infamy Known Threshold",               isInfamyEnabled)
    mcm.SetOptionDependencyBool("Infamy::Infamy Gained (%)",                    isInfamyEnabled)
    mcm.SetOptionDependencyBool("Infamy::Infamy Gained",                        isInfamyEnabled)
    mcm.SetOptionDependencyBool("Infamy::Infamy Lost (%)",                      isInfamyEnabled)
    mcm.SetOptionDependencyBool("Infamy::Infamy Lost",                          isInfamyEnabled)

    ; ==========================================================
    ;                           JAIL
    ; ==========================================================

    bool unconditionalImprisonment  = mcm.GetOptionToggleState("Jail::Unconditional Imprisonment")
    bool enableFastForward          = mcm.GetOptionToggleState("Jail::Fast Forward")

    mcm.SetOptionDependencyBool("Jail::Guaranteed Payable Bounty",          !unconditionalImprisonment)
    mcm.SetOptionDependencyBool("Jail::Maximum Payable Bounty",             !unconditionalImprisonment)
    mcm.SetOptionDependencyBool("Jail::Maximum Payable Bounty (Chance)",    !unconditionalImprisonment)
    mcm.SetOptionDependencyBool("Jail::Day to fast forward from",           enableFastForward)
    mcm.SetOptionDependencyBool("Jail::Recognized Criminal Penalty",        isInfamyEnabled)
    mcm.SetOptionDependencyBool("Jail::Known Criminal Penalty",             isInfamyEnabled)
    mcm.SetOptionDependencyBool("Jail::Minimum Bounty to Trigger",          isInfamyEnabled)


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
    
    mcm.SetOptionDependencyBool("Bounty Decaying::Decay if Known as Criminal",      enableBountyDecay && isInfamyEnabled)
    mcm.SetOptionDependencyBool("Bounty Decaying::Bounty Lost (%)",                 enableBountyDecay)
    mcm.SetOptionDependencyBool("Bounty Decaying::Bounty Lost",                     enableBountyDecay)

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================
    
    bool friskSearchUponCaptured = mcm.GetOptionToggleState("Escape::Frisk Search upon Captured")
    bool undressUponCaptured     = mcm.GetOptionToggleState("Escape::Strip Search upon Captured")

    mcm.SetOptionDependencyBool("Escape::Frisk Search upon Captured",   (!undressUponCaptured && allowFrisking) || (!allowUndressing && allowFrisking))
    mcm.SetOptionDependencyBool("Escape::Strip Search upon Captured",   allowUndressing)

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    bool retainItemsOnRelease = mcm.GetOptionToggleState("Release::Enable Item Retention")
    bool enableAdditionalFees = mcm.GetOptionToggleState("Release::Enable Release Fees")

    mcm.SetOptionDependencyBool("Release::Chance for Event",                enableAdditionalFees)
    mcm.SetOptionDependencyBool("Release::Minimum Bounty to owe Fees",      enableAdditionalFees)
    mcm.SetOptionDependencyBool("Release::Release Fees (%)",                enableAdditionalFees)
    mcm.SetOptionDependencyBool("Release::Release Fees",                    enableAdditionalFees)
    mcm.SetOptionDependencyBool("Release::Days Given to Pay",               enableAdditionalFees)
    mcm.SetOptionDependencyBool("Release::Minimum Bounty to Retain Items",  retainItemsOnRelease)
    mcm.SetOptionDependencyBool("Release::Auto Re-Dress on Release",        allowUndressing)

endFunction

function HandleSliderOptionDependency(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

    ; ==========================================================
    ;                           JAIL
    ; ==========================================================
    
    if (option == "Jail::Minimum Sentence")
        float minimumSentenceToUndressValue = mcm.GetOptionSliderValue("Stripping::Minimum Sentence to Strip")
        float maximumSentenceToClothe       = mcm.GetOptionSliderValue("Clothing::Maximum Sentence")

        if (minimumSentenceToUndressValue < value)
            mcm.SetOptionSliderValue("Stripping::Minimum Sentence to Strip", value, "{0} Days")
        endif

        if(maximumSentenceToClothe < value)
            mcm.SetOptionSliderValue("Clothing::Maximum Sentence", value, "{0} Days")
        endif

    elseif (option == "Jail::Maximum Sentence")
        float minimumSentenceToUndressValue = mcm.GetOptionSliderValue("Stripping::Minimum Sentence to Strip")
        float maximumSentenceToClothe       = mcm.GetOptionSliderValue("Clothing::Maximum Sentence")
        float dayToStartLosingSkills        = mcm.GetOptionSliderValue("Jail::Day to Start Losing Skills")
        float dayToFastForwardFrom          = mcm.GetOptionSliderValue("Jail::Day to Fast Forward From")

        if (minimumSentenceToUndressValue > value)
            mcm.SetOptionSliderValue("Stripping::Minimum Sentence to Strip", value, "{0} Days")
        endif

        if (maximumSentenceToClothe > value)
            mcm.SetOptionSliderValue("Clothing::Maximum Sentence", value, "{0} Days")
        endif

        if (dayToStartLosingSkills > value)
            mcm.SetOptionSliderValue("Jail::Day to Start Losing Skills", value, "{0}")
        endif

        if (dayToFastForwardFrom > value)
            mcm.SetOptionSliderValue("Jail::Day to Fast Forward From", value, "{0}")
        endif
    endif
endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

    ; string city = mcm.config.GetCityNameFromHold(mcm.CurrentPage)
    string city = mcm.miscVars.GetString("City["+ mcm.CurrentPage +"]")

    ; ==========================================================
    ;                           ARREST
    ; ==========================================================

    ; if (option == "Arrest::Minimum Bounty to Arrest") 
    ;     mcm.SetInfoText("The minimum bounty required in order to be arrested in " + mcm.CurrentPage + ".")

    if (option == "Arrest::Guaranteed Payable Bounty")
        mcm.SetInfoText("The guaranteed amount of bounty that a guard will accept as payment before being arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Maximum Payable Bounty")
        mcm.SetInfoText("The maximum amount of bounty that is payable before being arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Maximum Payable Bounty (Chance)")
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")

    elseif (option == "Arrest::Always Arrest for Violent Crimes")
        mcm.SetInfoText("Whether to always arrest if any of the crimes committed are violent.")

    elseif (option == "Arrest::Additional Bounty when Eluding (%)")
        mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when eluding arrest in "  + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Eluding")
        mcm.SetInfoText("The bounty that will be added when eluding arrest in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
        mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when resisting arrest in "  + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Resisting")
        mcm.SetInfoText("The bounty that will be added when resisting arrest in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Defeated (%)")
        mcm.SetInfoText("The bounty that will be added as a percentage of your current bounty, when defeated and arrested in " + mcm.CurrentPage + ".")

    elseif (option == "Arrest::Additional Bounty when Defeated")
        mcm.SetInfoText("The bounty that will be added when defeated and arrested in " + mcm.CurrentPage)

    ; elseif (option == "Arrest::Allow Civilian Capture")
    ;     mcm.SetInfoText("Whether to allow civilians to bring you to a guard, to be arrested in " + mcm.CurrentPage)

    ; elseif (option == "Arrest::Allow Arrest Transfer")
    ;     mcm.SetInfoText("Whether to allow a guard to take over the arrest if the current one dies.")

    ; elseif (option == "Arrest::Allow Unconscious Arrest")
    ;     mcm.SetInfoText("Whether to allow an unconscious arrest after being defeated.")

    ; elseif (option == "Arrest::Allow Unconditional Arrest")
    ;     mcm.SetInfoText("Whether to allow an unconditional arrest without a bounty in " + mcm.CurrentPage + ".")

    ; elseif (option == "Arrest::Unequip Hand Garments")
    ;     mcm.SetInfoText("Whether to unequip any hand garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required.")

    ; elseif (option == "Arrest::Unequip Head Garments")
    ;     mcm.SetInfoText("Whether to unequip any head garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required.")

    ; elseif (option == "Arrest::Unequip Foot Garments")
    ;     mcm.SetInfoText("Whether to unequip any foot garment when arrested.\n-100 - Disable\n0 - Always unequip.\n Any other value is the bounty required.")
    
    ; ==========================================================
    ;                           INFAMY
    ; ==========================================================

    elseif (option == "Infamy::Enable Infamy")
        mcm.SetInfoText("Whether to enable the infamy system in " + mcm.CurrentPage + ". Infamy works like a criminal history for each hold, the longer you are in prison, the more likely the guards are to recognize you, and eventually know you as a criminal.\n" + \
            "Being recognized or known will make it so that you are possibly punished more harshly when going to prison for any crimes you commit after the fact.\n" + \
            "Infamy has three stages: if the Recognized threshold has not been met, it will not have any effect, if the Recognized threshold has been met, part or all of the infamy can " + \
            "be considered when you are sentenced but is temporary and you can lose it if you don't commit crimes for long enough until it's gone. If the Known threshold has been met, " + \
            "then you will have the same penalties as being Recognized but the infamy is permanent and you will not lose it anymore in the hold.")

    elseif (option == "Infamy::Infamy Recognized Threshold")
        mcm.SetInfoText("The infamy threshold that a suspect must meet in order to be recognized by the guards in " + city + ".")

    elseif (option == "Infamy::Infamy Known Threshold")
        mcm.SetInfoText("The infamy threshold that a suspect must meet in order to be known as a criminal by the guards in " + city + ".")

    elseif (option == "Infamy::Infamy Gained (%)")
        mcm.SetInfoText("The infamy gained daily as a percentage of the current bounty for this arrest while jailed in " + city + ".")

    elseif (option == "Infamy::Infamy Gained")
        mcm.SetInfoText("The infamy gained daily while jailed in " + city + ".")

    elseif (option == "Infamy::Infamy Lost (%)")
        int infamyDecayUpdateInterval = mcm.GetSliderOptionValue("General", "General::Infamy Decay (Update Interval)") as int
        mcm.SetInfoText("The amount of infamy lost as a percentage of your current infamy in " + city + " each " + string_if(infamyDecayUpdateInterval == 1, "day.", infamyDecayUpdateInterval + " days.") + " (Configured in General page)\n" + \
            "Note: Infamy will only decay if the Known threshold has not yet been reached, at which point it becomes permanent.")

    elseif (option == "Infamy::Infamy Lost")
        int infamyDecayUpdateInterval = mcm.GetSliderOptionValue("General", "General::Infamy Decay (Update Interval)") as int
        mcm.SetInfoText("The amount of infamy lost in " + city + " each " + string_if(infamyDecayUpdateInterval == 1, "day.", infamyDecayUpdateInterval + " days.") + " (Configured in General page)\n" + \
            "Note: Infamy will only decay if the Known threshold has not yet been reached, at which point it becomes permanent.")


    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Allow Frisking")
        mcm.SetInfoText("Determines if you can be frisked in " + city + " when you are under arrest.")

    elseif (option == "Frisking::Unconditional Frisking")
        mcm.SetInfoText("If enabled, you will be frisk searched regardless of your bounty in " + mcm.CurrentPage + ".")

    elseif (option == "Frisking::Minimum Bounty for Frisking")
        mcm.SetInfoText("The minimum bounty required to be frisked in " + city + ".")

    elseif (option == "Frisking::Guaranteed Payable Bounty")
        mcm.SetInfoText("The guaranteed amount of bounty that is payable during frisking before considering imprisonment in " + city + ".")

    elseif (option == "Frisking::Maximum Payable Bounty")
        mcm.SetInfoText("The maximum amount of bounty that is payable during frisking before considering imprisonment in "  + city + ".")

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
    ;                           JAIL
    ; ==========================================================

    ; elseif (option == "Jail::Unconditional Imprisonment")
    ;     mcm.SetInfoText("If enabled, you will be jailed regardless of your bounty when you go to jail in " + city + ", otherwise, a bounty condition will be used.")

    elseif (option == "Jail::Guaranteed Payable Bounty")
        mcm.SetInfoText("The guaranteed amount of bounty that is payable when arriving at the jail, before considering imprisonment in " + city + ".")

    elseif (option == "Jail::Maximum Payable Bounty")
        mcm.SetInfoText("The maximum amount of bounty that is payable when arriving at the jail, before imprisonment in "  + city + ".")

    elseif (option == "Jail::Maximum Payable Bounty (Chance)")
        mcm.SetInfoText("The chance of being able to pay the bounty if it exceeds the guaranteed amount but is within the maximum limit.")

    elseif (option == "Jail::Bounty Exchange")
        mcm.SetInfoText("The amount of violent bounty to be exchanged to normal bounty in order to determine the jail sentence in " + city + ".")

    elseif (option == "Jail::Bounty to Sentence")
        mcm.SetInfoText("Sets the relation between bounty and the sentence given in " + city + "'s jail.")

    elseif (option == "Jail::Minimum Sentence")
        mcm.SetInfoText("Determines the minimum sentence in days for " + city + "'s jail.")

    elseif (option == "Jail::Maximum Sentence")
        mcm.SetInfoText("Determines the maximum sentence in days for " + city + "'s jail.")

    elseif (option == "Jail::Fast Forward")
        mcm.SetInfoText("Whether to fast forward to the release in " + city + ".")

    elseif (option == "Jail::Day to fast forward from")
        mcm.SetInfoText("The day to fast forward from to release in " + city + ".")

    elseif (option == "Jail::Handle Skill Loss")
        mcm.SetInfoText("The way to handle skill progression loss while jailed in " + city + ".")

    elseif (option == "Jail::Day to Start Losing Skills")
        mcm.SetInfoText("The day to start losing skills while jailed in " + city + ". \n(Configured individually in General page)")

    elseif (option == "Jail::Chance to lose Skills")
        mcm.SetInfoText("The chance to lose skills each day while jailed in " + city + ". \n(Stats lost are configured in General page)")

    elseif (option == "Jail::Recognized Criminal Penalty")
        mcm.SetInfoText("The amount of infamy to be added as a criminal charge when you are recognized as a criminal while being sentenced in " + city + " jail.\n" + \
            "Note: The penalty will only be applied if the Recognized threshold is met.")

    elseif (option == "Jail::Known Criminal Penalty")
        mcm.SetInfoText("The amount of infamy to be added as a criminal charge when you are a known criminal being sentenced in " + city + " jail.\n" + \
            "Note: The penalty will only be applied if the Known threshold is met.")

    elseif (option == "Jail::Minimum Bounty to Trigger")
        mcm.SetInfoText("The minimum amount of bounty when arrested to trigger the Infamy penalties upon being jailed in " + city + ".")

    elseif (option == "Jail::Cell Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the cell search, higher values mean a more thorough searching of the cell and possibly any items you left there to be confiscated.")

    elseif (option == "Jail::Hands Bound in Prison")
        mcm.SetInfoText("Whether to have hands restrained during imprisonment in " + city + ".")

    elseif (option == "Jail::Hands Bound (Minimum Bounty)")
        mcm.SetInfoText("The minimum bounty required to have hands restrained during imprisonment in " + city + ".")

    elseif (option == "Jail::Hands Bound (Randomize)") 
        mcm.SetInfoText("Randomize whether to be restrained or not, while in prison in " + city + ".")

    elseif (option == "Jail::Cell Lock Level")
        mcm.SetInfoText("Determines the cell's door lock level")

    ; ==========================================================
    ;                         STRIPPING
    ; ==========================================================

    elseif (option == "Stripping::Allow Stripping")
        mcm.SetInfoText("Determines if you can be stripped off in " + city + "'s jail.")

    elseif (option == "Stripping::Handle Stripping On")
        mcm.SetInfoText("Determines which rules to use to know whether stripping should take place in " + city + "'s jail.\n" + \
            "Minimum Bounty - Stripping will only happen if the minimum bounty for this arrest is met.\n" + \
            "Minimum Sentence - Stripping will only happen if the sentence given falls within the minimum value.\n" + \
            "Unconditionally - Stripping will always happen regardless of bounty or sentence.")

    elseif (option == "Stripping::Minimum Bounty to Strip")
        mcm.SetInfoText("The minimum bounty required in order to be stripped off in " + city + "'s jail.")

    elseif (option == "Stripping::Minimum Violent Bounty to Strip")
        mcm.SetInfoText("The minimum violent bounty required in order to be stripped off in " + city + "'s jail.")

    elseif (option == "Stripping::Minimum Sentence to Strip")
        mcm.SetInfoText("The minimum sentence required in order to be stripped off in " + city + "'s jail.")

    elseif (option == "Stripping::Strip when Defeated")
        mcm.SetInfoText("Whether to have you stripped off when defeated in " + city + "'s jail.")

    elseif (option == "Stripping::Strip Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the strip search, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                     "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped off.")

    elseif (option == "Stripping::Strip Search Thoroughness Modifier")
        mcm.SetInfoText("The amount of additional thoroughness that is applied to Strip Search Thoroughness through a bounty modifier.")
                     

    ; ==========================================================
    ;                         CLOTHING
    ; ==========================================================

    elseif (option == "Clothing::Allow Clothing")
        mcm.SetInfoText("Determines if you are allowed clothing in " + city + " jail.")

    elseif (option == "Clothing::Handle Clothing On")
        mcm.SetInfoText("Determines which rules to use to know whether clothing should be given in " + city + " jail.\n" + \
            "Maximum Bounty - Allow clothing only if the bounty for this arrest does not exceed the maximum.\n" + \
            "Maximum Sentence - Allow clothing only if the sentence given does not exceed the maximum set.\n" + \
            "Unconditionally - Always allow clothing regardless of bounty or sentence.")

    elseif (option == "Clothing::When Defeated")
        mcm.SetInfoText("Determines if you are given clothing when defeated in " + city + " jail.")

    elseif (option == "Clothing::Maximum Bounty")
        mcm.SetInfoText("The maximum amount of bounty you can have in order to be given clothing in " + city + " jail.")

    elseif (option == "Clothing::Maximum Violent Bounty")
        mcm.SetInfoText("The maximum amount of violent bounty you can have in order to be given clothing in " + city + " jail.")

    elseif (option == "Clothing::Maximum Sentence")
        mcm.SetInfoText("The maximum sentence you can be given in order to get clothing in " + city + " jail.")

    ; ==========================================================
    ;                      ADDITIONAL CHARGES
    ; ==========================================================

    elseif (option == "Additional Charges::Bounty for Impersonation")
        mcm.SetInfoText("The bounty that will be added to the sentence if you're charged with impersonation of a hold's guard.")

    elseif (option == "Additional Charges::Bounty for Enemy of Hold")
        mcm.SetInfoText("The bounty that will be added to the sentence if you're charged with being an enemy of the hold.")

    elseif (option == "Additional Charges::Bounty for Stolen Items")
        mcm.SetInfoText("The bounty that will be added to the sentence if you're charged with the possession of stolen items.")

    elseif (option == "Additional Charges::Bounty for Stolen Item")
        mcm.SetInfoText("The amount of gold of each stolen item's worth that will be added as a criminal charge when being processed in jail.")

    elseif (option == "Additional Charges::Bounty for Contraband")
        mcm.SetInfoText("The bounty that will be added to the sentence if you're charged with the possession of contraband.")

    elseif (option == "Additional Charges::Bounty for Cell Key")
        mcm.SetInfoText("The bounty that will be added to the sentence if you're charged with the possession of the jail's cell key.")

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Enable Release Fees")
        mcm.SetInfoText("Whether to enable the event of having to pay additional fees upon being released from jail.")
    
    elseif (option == "Release::Chance for Event")
        mcm.SetInfoText("The chance of the event that you are ordered to pay additional fees upon being released from jail.")

    elseif (option == "Release::Minimum Bounty to owe Fees")
        mcm.SetInfoText("The minimum bounty that you must have at the time of arrest in order to be required to pay fees to the hold upon being released from jail.")

    elseif (option == "Release::Release Fees (%)")
        mcm.SetInfoText("The additional gold fees that you are ordered to pay as a percentage of your bounty at the time of the arrest upon being released from jail.")

    elseif (option == "Release::Release Fees")
        mcm.SetInfoText("The additional gold fees that you are ordered to pay upon being released from jail.")

    elseif (option == "Release::Days Given to Pay")
        mcm.SetInfoText("The time in days that you have to pay the amount ordered by the jail before it becomes a bounty on you.")

    elseif (option == "Release::Enable Item Retention")
        mcm.SetInfoText("Determines whether the items can be retained when released from " + city + "'s jail.")

    elseif (option == "Release::Minimum Bounty to Retain Items")
        mcm.SetInfoText("The minimum amount of bounty required in order to have the items retained in " + city + "'s jail.")

    elseif (option == "Release::Re-Dress on Release")
        mcm.SetInfoText("Determines whether you should be re-dressed on release, if you were undressed while in " + city + "'s jail.")

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================

    elseif (option == "Escape::Escape Bounty (%)")
        mcm.SetInfoText("The bounty added as a percentage of your current bounty, when escaping jail in " + city + ".")

    elseif (option == "Escape::Escape Bounty")
        mcm.SetInfoText("The bounty added when escaping jail in " + city + ".")

    elseif (option == "Escape::Account for Time Served")
        mcm.SetInfoText("When escaping jail, takes into account the time already served and does not count it as a bounty.")

    elseif (option == "Escape::Allow Surrendering")
        mcm.SetInfoText("Whether the guards will allow you to surrender after escaping jail in " + city + ".")

    elseif (option == "Escape::Frisk Search upon Captured")
        mcm.SetInfoText("Whether to have a frisk search be performed upon being captured in "  + city + ".\n" + "(Note: The frisk search will take place regardless of whether the conditions are met in Frisking)")

    elseif (option == "Escape::Strip Search upon Captured")
        mcm.SetInfoText("Whether to have a strip search be performed upon being captured in " + city + ".\n (Note: The strip search will take place regardless of whether the conditions are met in Stripping)")

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

    elseif (option == "Bounty Decaying::Decay if Known as Criminal")
        mcm.SetInfoText("Whether to enable bounty decaying in " + mcm.CurrentPage + " if you are a known criminal.")

    elseif (option == "Bounty Decaying::Bounty Lost (%)")
        int bountyDecayUpdateInterval = mcm.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)") as int
        mcm.SetInfoText("The amount of bounty lost as a percentage of your current bounty in " + mcm.CurrentPage + " each " + bountyDecayUpdateInterval + " hours. (Configured in General page)")

    elseif (option == "Bounty Decaying::Bounty Lost")
        int bountyDecayUpdateInterval = mcm.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)") as int
        mcm.SetInfoText("The amount of bounty lost in " + mcm.CurrentPage + " each " + bountyDecayUpdateInterval + " hours. (Configured in General page)")
    endif
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    mcm.ToggleOption(option)
    HandleDependencies(mcm)
endFunction

function LoadSliderOptions(RealisticPrisonAndBounty_MCM mcm, string option, float currentSliderValue) global
    float minRange = 1
    float maxRange = 100000
    float intervalSteps = 1
    float defaultValue = mcm.GetOptionDefaultFloat(option)

    ; ==========================================================
    ;                           ARREST
    ; ==========================================================

    ; if (option == "Arrest::Minimum Bounty to Arrest")
    ;     intervalSteps = 50

    if (option == "Arrest::Guaranteed Payable Bounty")
        minRange = 0
        intervalSteps = 50

    elseif (option == "Arrest::Maximum Payable Bounty")
        intervalSteps = 100

    elseif (option == "Arrest::Maximum Payable Bounty (Chance)")
        minRange = 0
        maxRange = 100

    elseif (option == "Arrest::Additional Bounty when Eluding (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Arrest::Additional Bounty when Eluding")
        minRange = 0
        intervalSteps = 100

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Arrest::Additional Bounty when Resisting")
        minRange = 0
        intervalSteps = 100

    elseif (option == "Arrest::Additional Bounty when Defeated (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Arrest::Additional Bounty when Defeated")
        minRange = 0
        intervalSteps = 100

    ; ==========================================================
    ;                            INFAMY
    ; ==========================================================

    elseif (option == "Infamy::Infamy Recognized Threshold")
        minRange = 100
        maxRange = 100000
        intervalSteps = 100

    elseif (option == "Infamy::Infamy Known Threshold")
        minRange = 100
        maxRange = 100000
        intervalSteps = 100

    elseif (option == "Infamy::Infamy Gained (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.01

    elseif (option == "Infamy::Infamy Gained")
        minRange = 0
        maxRange = 1000
        intervalSteps = 1

    elseif (option == "Infamy::Infamy Gain Modifier (Recognized)")
        minRange = -100
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Infamy::Infamy Gain Modifier (Known)")
        minRange = -100
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Infamy::Infamy Lost (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.01

    elseif (option == "Infamy::Infamy Lost")
        minRange = 0
        maxRange = 1000
        intervalSteps = 1

    elseif (option == "Infamy::Infamy Loss Modifier (Recognized)")
        minRange = -100
        maxRange = 100
        intervalSteps = 0.1

    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Minimum Bounty for Frisking")
        minRange = 100
        intervalSteps = 100

    elseif (option == "Frisking::Guaranteed Payable Bounty")
        minRange = 0
        intervalSteps = 100

    elseif (option == "Frisking::Maximum Payable Bounty")
        minRange = 0
        intervalSteps = 100

    elseif (option == "Frisking::Maximum Payable Bounty (Chance)")
        minRange = 0
        maxRange = 100

    elseif (option == "Frisking::Frisk Search Thoroughness")
        maxRange = 10

    elseif (option == "Frisking::Minimum No. of Stolen Items Required")
        maxRange = 1000

    ; ==========================================================
    ;                           JAIL
    ; ==========================================================

    elseif (option == "Jail::Guaranteed Payable Bounty")
        minRange = 0
        intervalSteps = 50

    elseif (option == "Jail::Maximum Payable Bounty")
        intervalSteps = 100

    elseif (option == "Jail::Maximum Payable Bounty (Chance)")
        minRange = 0
        maxRange = 100

    elseif (option == "Jail::Bounty Exchange")
        minRange = 1
        maxRange = 100

    elseif (option == "Jail::Bounty to Sentence")
        minRange = 10
        intervalSteps = 10

    elseif (option == "Jail::Minimum Sentence")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence") - 1

    elseif (option == "Jail::Maximum Sentence")
        minRange = mcm.GetOptionSliderValue("Jail::Minimum Sentence") + 1
        maxRange = 365

    elseif (option == "Jail::Day to fast forward from")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")

    elseif (option == "Jail::Chance to lose Skills")
        minRange = 0
        maxRange = 100

    elseif (option == "Jail::Day to Start Losing Skills")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")

    elseif (option == "Jail::Recognized Criminal Penalty")
        minRange = 0
        maxRange = 500
        intervalSteps = 0.1

    elseif (option == "Jail::Known Criminal Penalty")
        minRange = 0
        maxRange = 500
        intervalSteps = 0.1

    elseif (option == "Jail::Minimum Bounty to Trigger")
        minRange = 100
        maxRange = 100000
        intervalSteps = 100

    elseif (option == "Jail::Cell Search Thoroughness")
        maxRange = 10

    elseif (option == "Jail::Hands Bound (Minimum Bounty)")
        intervalSteps = 100

    ; ==========================================================
    ;                         STRIPPING
    ; ==========================================================

    elseif (option == "Stripping::Minimum Bounty to Strip")
        intervalSteps = 100

    elseif (option == "Stripping::Minimum Violent Bounty to Strip")
        intervalSteps = 10

    elseif (option == "Stripping::Minimum Sentence to Strip")
        minRange = mcm.GetOptionSliderValue("Jail::Minimum Sentence")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")

    elseif (option == "Stripping::Strip Search Thoroughness")
        maxRange = 10
    
    elseif (option == "Stripping::Strip Search Thoroughness Modifier")
        maxRange = 10000
        intervalSteps = 10
    
    ; ==========================================================
    ;                         CLOTHING
    ; ==========================================================

    elseif (option == "Clothing::Maximum Bounty")
        intervalSteps = 100

    elseif (option == "Clothing::Maximum Violent Bounty")
        intervalSteps = 10

    elseif (option == "Clothing::Maximum Sentence")
        minRange = mcm.GetOptionSliderValue("Jail::Minimum Sentence")
        maxRange = mcm.GetOptionSliderValue("Jail::Maximum Sentence")

    ; ==========================================================
    ;                      ADDITIONAL CHARGES
    ; ==========================================================

    elseif (option == "Additional Charges::Bounty for Impersonation")
        minRange = 0
        maxRange = 100000
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Enemy of Hold")
        minRange = 0
        maxRange = 100000
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Stolen Items")
        minRange = 0
        maxRange = 100000
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Stolen Item")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Additional Charges::Bounty for Contraband")
        intervalSteps = 100

    elseif (option == "Additional Charges::Bounty for Cell Key")
        intervalSteps = 100

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Chance for Event")
        minRange = 1
        maxRange = 100
        intervalSteps = 1

    elseif (option == "Release::Minimum Bounty to owe Fees")
        minRange = 100
        maxRange = 100000
        intervalSteps = 100

    elseif (option == "Release::Release Fees (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Release::Release Fees")
        minRange = 0
        maxRange = 100000
        intervalSteps = 100
    
    elseif (option == "Release::Days Given to Pay")
        minRange = 1
        maxRange = 100
        intervalSteps = 1

    elseif (option == "Release::Minimum Bounty to Retain Items")
        intervalSteps = 100

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================

    elseif (option == "Escape::Escape Bounty (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Escape::Escape Bounty")
        minRange = 0
        intervalSteps = 100

    ; ==========================================================
    ;                       BOUNTY HUNTING
    ; ==========================================================

    elseif (option == "Bounty Hunting::Minimum Bounty")
        intervalSteps = 100

    elseif (option == "Bounty Hunting::Bounty (Posse)")
        intervalSteps = 100

    ; ==========================================================
    ;                       BOUNTY DECAYING
    ; ==========================================================

    elseif (option == "Bounty Decaying::Bounty Lost (%)")
        minRange = 0
        maxRange = 100
        intervalSteps = 0.1

    elseif (option == "Bounty Decaying::Bounty Lost")
        intervalSteps = 10
    endif

    defaultValue = float_if (defaultValue > maxRange, maxRange, defaultValue)
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

    ; if (option == "Arrest::Minimum Bounty to Arrest")

    if (option == "Arrest::Guaranteed Payable Bounty")

    elseif (option == "Arrest::Maximum Payable Bounty")

    elseif (option == "Arrest::Maximum Payable Bounty (Chance)")
        formatString = "{0}%"

    elseif (option == "Arrest::Additional Bounty when Eluding (%)")
        formatString = "{1}% of Bounty"

    elseif (option == "Arrest::Additional Bounty when Eluding")

    elseif (option == "Arrest::Additional Bounty when Resisting (%)")
        formatString = "{1}% of Bounty"

    elseif (option == "Arrest::Additional Bounty when Resisting")

    elseif (option == "Arrest::Additional Bounty when Defeated (%)")
        formatString = "{1}% of Bounty"

    elseif (option == "Arrest::Additional Bounty when Defeated")

    ; ==========================================================
    ;                            INFAMY
    ; ==========================================================

    elseif (option == "Infamy::Infamy Recognized Threshold")
        formatString = "{0} Infamy"

    elseif (option == "Infamy::Infamy Known Threshold")
        formatString = "{0} Infamy"

    elseif (option == "Infamy::Infamy Gained (%)")
        formatString = "{2}% of Bounty"

    elseif (option == "Infamy::Infamy Gained")
        formatString = "{0} Infamy"

    elseif (option == "Infamy::Infamy Gain Modifier (Recognized)")
        formatString = "{1}x"

    elseif (option == "Infamy::Infamy Gain Modifier (Known)")
        formatString = "{1}x"

    elseif (option == "Infamy::Infamy Lost (%)")
        formatString = "{2}% of Infamy"

    elseif (option == "Infamy::Infamy Lost")
        formatString = "{0} Infamy"

    elseif (option == "Infamy::Infamy Loss Modifier (Recognized)")
        formatString = "{1}x"

    ; ==========================================================
    ;                           FRISKING
    ; ==========================================================

    elseif (option == "Frisking::Minimum Bounty for Frisking")

    elseif (option == "Frisking::Frisk Search Thoroughness")
        formatString = "{0}x"

    elseif (option == "Frisking::Minimum No. of Stolen Items Required")
        formatString = "{0} Items"

    ; ==========================================================
    ;                           JAIL
    ; ==========================================================
    
    elseif (option == "Jail::Guaranteed Payable Bounty")

    elseif (option == "Jail::Maximum Payable Bounty")

    elseif (option == "Jail::Maximum Payable Bounty (Chance)")
        formatString = "{0}%"

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

    elseif (option == "Jail::Day to Start Losing Skills")
        formatString = "{0}"

    elseif (option == "Jail::Chance to lose Skills")
        formatString = "{0}% Each Day"

    elseif (option == "Jail::Recognized Criminal Penalty")
        formatString = "{1}% of Infamy"

    elseif (option == "Jail::Known Criminal Penalty")
        formatString = "{1}% of Infamy"

    elseif (option == "Jail::Minimum Bounty to Trigger")
        formatString = "{0} Bounty"

    ; ==========================================================
    ;                     ADDITIONAL CHARGES
    ; ==========================================================

    elseif (option == "Additional Charges::Bounty for Stolen Item")
        formatString = "{1}% of Item Value"

    ; ==========================================================
    ;                         STRIPPING
    ; ==========================================================

    elseif (option == "Stripping::Minimum Bounty to Strip")

    elseif (option == "Stripping::Minimum Violent Bounty to Strip")
        formatString = "{0} Violent Bounty"

    elseif (option == "Stripping::Minimum Sentence to Strip")
        formatString = "{0} Days"

    elseif (option == "Stripping::Strip Search Thoroughness")
        formatString = "{0}x"

    elseif (option == "Stripping::Strip Search Thoroughness Modifier")
        formatString = "{0} Bounty = 1x"

    ; ==========================================================
    ;                         CLOTHING
    ; ==========================================================

    elseif (option == "Clothing::Maximum Bounty")

    elseif (option == "Clothing::Maximum Violent Bounty")
        formatString = "{0} Violent Bounty"

    elseif (option == "Clothing::Maximum Sentence")
        formatString = "{0} Days"

    ; ==========================================================
    ;                           RELEASE
    ; ==========================================================

    elseif (option == "Release::Chance for Event")
        formatString = "{0}%"

    elseif (option == "Release::Minimum Bounty to owe Fees")

    elseif (option == "Release::Release Fees (%)")
        formatString = "{1}% of Bounty as Gold"

    elseif (option == "Release::Release Fees")
        formatString = "{0} Gold"

    elseif (option == "Release::Days Given to Pay")
        formatString = "{0} Days"

    elseif (option == "Release::Minimum Bounty to Retain Items")

    ; ==========================================================
    ;                           ESCAPE
    ; ==========================================================

    elseif (option == "Escape::Escape Bounty (%)")
        formatString = "{1}% of Bounty"

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
        formatString = "{1}% of Bounty"

    elseif (option == "Bounty Decaying::Bounty Lost")

    endif

    ; Handle any slider option that depends on the current option being set
    HandleSliderOptionDependency(mcm, option, value)

    ; Set the main option value
    mcm.SetOptionSliderValue(option, value, formatString)

    ; Send option changed event
    mcm.SendModEvent("RPB_SliderOptionChanged", option, value)

    mcm.Debug("Holds::OnSliderAccept", "Option: " + option + ", Value: " + value, true)

    mcm.Debug("OnSliderAccept", "GetSliderOptionValue("+  option +") = " + mcm.GetSliderOptionValue(mcm.CurrentPage, option))
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    string defaultValue = mcm.GetOptionDefaultString(option)

    if (option == "Jail::Cell Lock Level")
        mcm.SetMenuDialogOptions(mcm.LockLevels)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.LockLevels, defaultValue))

    elseif (option == "Jail::Handle Skill Loss")
        mcm.SetMenuDialogOptions(mcm.PrisonSkillHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.PrisonSkillHandlingOptions, defaultValue))

    elseif (option == "Stripping::Handle Stripping On")
        mcm.SetMenuDialogOptions(mcm.UndressingHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.UndressingHandlingOptions, defaultValue))

    elseif (option == "Clothing::Handle Clothing On")
        mcm.SetMenuDialogOptions(mcm.ClothingHandlingOptions)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.ClothingHandlingOptions, defaultValue))

    elseif (option == "Clothing::Outfit")
        mcm.SetMenuDialogOptions(mcm.ClothingOutfits)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.ClothingOutfits, defaultValue))
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

    elseif (option == "Stripping::Handle Stripping On")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.UndressingHandlingOptions[menuIndex])

            bool allowUndressing = mcm.GetOptionToggleState("Stripping::Allow Stripping")

            mcm.SetOptionDependencyBool("Stripping::Minimum Bounty to Strip",            allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Bounty"))
            mcm.SetOptionDependencyBool("Stripping::Minimum Violent Bounty to Strip",    allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Bounty"))
            mcm.SetOptionDependencyBool("Stripping::Minimum Sentence to Strip",          allowUndressing && menuIndex == GetOptionIndexFromKey(mcm.UndressingHandlingOptions, "Minimum Sentence"))
        endif

    elseif (option == "Clothing::Handle Clothing On")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.ClothingHandlingOptions[menuIndex])

            bool allowWearingClothes = mcm.GetOptionToggleState("Clothing::Allow Clothing")

            mcm.SetOptionDependencyBool("Clothing::Maximum Bounty",           allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Bounty"))
            mcm.SetOptionDependencyBool("Clothing::Maximum Violent Bounty",   allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Bounty"))
            mcm.SetOptionDependencyBool("Clothing::Maximum Sentence",         allowWearingClothes && menuIndex == GetOptionIndexFromKey(mcm.ClothingHandlingOptions, "Maximum Sentence"))
        endif

    elseif (option == "Clothing::Outfit")
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.ClothingOutfits[menuIndex])
        endif
    endif

    mcm.Debug("OnOptionMenuAccept", "GetMenuOptionValue("+  option +") = " + mcm.GetMenuOptionValue(mcm.CurrentPage, option))

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
    
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid, false), value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid, false), menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid, false), color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid, false), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid, false), inputValue)
endFunction
