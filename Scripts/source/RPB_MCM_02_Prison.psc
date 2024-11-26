Scriptname RPB_MCM_02_Prison hidden

import RPB_Utility

; ==========================================================
;                           Arrest
; ==========================================================

function RenderArrest(RPB_MCM_02 mcm, RPB_Arrestee apArrestee) global
    int emptySpacesLeft     = 0
    int emptySpacesRight    = 0

    string hold           = apArrestee.Hold
    RPB_Arrestee arrestee = apArrestee

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    ; ==========================================================
    ;                           Left
    ; ==========================================================
    if (!arrestee.IsArrested)
        DebugWarn("MCM_02_Prison::RenderArrest", "The arrestee " + arrestee.Name + " is not arrested, no stats to show.")
        Warn("The arrestee " + arrestee.Name + " is not arrested, no stats to show.")
        return
    endif

    RPB_Prison potentialPrison = arrestee.GetPotentialPrison()

    string arrestTimeFormatted      = arrestee.GetTimeOfArrestFormatted()
    string timeElapsedSinceArrest   = arrestee.GetTimeElapsedSinceArrest()

    DisplayTimeHeader(mcm)
    emptySpacesLeft += 1

    if (arrestee.TimeOfArrest)
        mcm.AddOptionText("\t\t\t\tTime of Arrest", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", arrestTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
        if (timeElapsedSinceArrest)
            mcm.AddOptionText("", timeElapsedSinceArrest + " Ago", defaultFlags = mcm.OPTION_DISABLED)
        endif
        mcm.AddEmptyOption()
        emptySpacesLeft += 1
    endif

    mcm.AddEmptyOption()
    emptySpacesLeft += 1

    mcm.SetCursorPosition(1)
    ; ==========================================================
    ;                           Right
    ; ==========================================================

    DisplayArrestHeader(mcm, hold, arrestee)

    if (arrestee.Bounty)
        mcm.AddOptionText("Bounty for Arrest", \ 
            string_if (arrestee.BountyNonViolent > 0, arrestee.BountyNonViolent + " Bounty") + \ 
            string_if (arrestee.BountyNonViolent && arrestee.BountyViolent, " / ") + \
            string_if (arrestee.BountyViolent > 0, arrestee.BountyViolent + " Violent Bounty"), \ 
            defaultFlags = mcm.OPTION_DISABLED \
        )
    endif

    if (arrestee.Captor)
        RPB_Captor captor = arrestee.Captor
        mcm.AddOptionText("Captured By", captor.Name, defaultFlags = mcm.OPTION_DISABLED)
    endif

    if (potentialPrison)
        mcm.AddOptionText("Headed To", potentialPrison.Name + ", " + potentialPrison.City, defaultFlags = mcm.OPTION_DISABLED)
        ; mcm.AddOptionText("City", potentialPrison.City, defaultFlags = mcm.OPTION_DISABLED)
    endif

    mcm.AddEmptyOption()
    ; emptySpacesRight += 1

    while (emptySpacesRight < emptySpacesLeft)
        mcm.AddEmptyOption()
        emptySpacesRight += 1
    endWhile
endFunction

;/
    Displays the Header section info with the Arrest info.
    The header's values, as well as their position, are controlled through the template on the MCM config file.
/;
function DisplayArrestHeader(RPB_MCM_02 mcm, string asArrestHold, RPB_Arrestee apArrestee) global
    RPB_Prison potentialPrison = apArrestee.GetPotentialPrison()

    string[] headerPlaceholders = mcm.ArrestHeaderPlaceholders
    string[] arrestHeader = mcm.ConstructArrestHeaderValues( \ 
        asArrestHold          = apArrestee.Hold, \
        asArrestCity          = potentialPrison.City, \
        asPotentialPrisonName = potentialPrison.Name, \
        asArresteeName        = apArrestee.Name \
    )

    string template = mcm.ArrestHeaderTemplate
    string header   = RPB_Utility.Replace(template, headerPlaceholders, arrestHeader)

    mcm.AddOptionText("", header, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
endFunction

; ==========================================================
;                           Prison
; ==========================================================

function Render(RPB_MCM_02 mcm, RPB_Prisoner apPrisoner) global
    int emptySpacesLeft     = 0
    int emptySpacesRight    = 0

    RPB_Prison prison       = apPrisoner.Prison
    RPB_Prisoner prisoner   = apPrisoner

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
; ==========================================================
;                           Left
; ==========================================================

    ; Should probably be refactored, a prisoner should always be imprisoned (maybe?)
    if (!prisoner.IsImprisoned)
        DebugWarn("MCM_02_Prison::Render", "The prisoner " + prisoner.Name + " (Prisoner #"+ prisoner.Number +") " + " is not imprisoned, no stats to show.")
        Warn("The prisoner " + prisoner.Name + " (Prisoner #"+ prisoner.Number +") " + " is not imprisoned, no stats to show.")
        return
    endif

    string arrestTimeFormatted                  = prison.GetTimeOfArrestFormatted(prisoner)
    string imprisonmentTimeFormatted            = prison.GetTimeOfImprisonmentFormatted(prisoner)
    string timeElapsedSinceArrest               = prison.GetTimeElapsedSinceArrest(prisoner)
    string timeElapsedSinceImprisonment         = prison.GetTimeElapsedSinceImprisonment(prisoner)
    string timeLeftFormatted                    = prison.GetTimeLeftOfSentenceFormatted(prisoner)
    string releaseTimeFormatted                 = prison.GetTimeOfReleaseFormatted(prisoner)

    DisplayTimeHeader(mcm)
    emptySpacesLeft += 1

    if (prisoner.TimeOfArrest)
        mcm.AddOptionText("\t\t\t\tTime of Arrest", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", arrestTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
        if (timeElapsedSinceArrest)
            mcm.AddOptionText("", timeElapsedSinceArrest + " Ago", defaultFlags = mcm.OPTION_DISABLED)
        endif
        mcm.AddEmptyOption()
        emptySpacesLeft += 1
    endif

    if (prisoner.TimeOfImprisonment)
        mcm.AddOptionText("\t\t\t\tTime of Imprisonment", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", imprisonmentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
        if (timeElapsedSinceImprisonment)
            mcm.AddOptionText("", timeElapsedSinceImprisonment + " Ago", defaultFlags = mcm.OPTION_DISABLED)
        endif
        mcm.AddEmptyOption()
        emptySpacesLeft += 1
    endif

    if (prisoner.ShowReleaseTime && !prisoner.IsUndeterminedSentence)
        mcm.AddOptionText("\t\t\t\tTime of Release", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", releaseTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("", timeLeftFormatted + " from Now", defaultFlags = mcm.OPTION_DISABLED)
        ; mcm.AddOptionText("", "Execution Time: " + xBenchmark + " ms", defaultFlags = mcm.OPTION_DISABLED)
    endif

;     if (prisoner.IsReleaseOnWeekend())
;         mcm.AddOptionText("Release rounded to Morndas.", defaultFlags = mcm.OPTION_DISABLED)
;     endif

    ; RPB_Tests.DisplayNextDaysOfWeek()
    ; RPB_Tests.DisplayPreviousDaysOfWeek()

    mcm.AddEmptyOption()
    emptySpacesLeft += 1

    mcm.SetCursorPosition(1)
; ==========================================================
;                           Right
; ==========================================================

    DisplayPrisonHeader(mcm, prison, prisoner)

    if (prisoner.Bounty && prisoner.ShowBounty)
        mcm.AddOptionText("Bounty for Arrest", \ 
            string_if (prisoner.BountyNonViolent > 0, prisoner.BountyNonViolent + " Bounty") + \ 
            string_if (prisoner.BountyNonViolent && prisoner.BountyViolent, " / ") + \
            string_if (prisoner.BountyViolent > 0, prisoner.BountyViolent + " Violent Bounty"), \ 
            defaultFlags = mcm.OPTION_DISABLED \
        )
    endif

    if (prisoner.Captor)
        Actor prisonerCaptor = prisoner.Captor
        mcm.AddOptionText("Captured By", prisonerCaptor.GetBaseObject().GetName(), defaultFlags = mcm.OPTION_DISABLED)
    endif

    if (prisoner.ShowSentence && !prisoner.IsUndeterminedSentence)
        string sentenceFormatted = prison.GetSentenceFormatted(prisoner)
        mcm.AddOptionText("Sentence", sentenceFormatted, defaultFlags = mcm.OPTION_DISABLED)
    endif

    if (prisoner.ShowTimeLeftInSentence)
        if (!prisoner.IsUndeterminedSentence)
            mcm.AddOptionText("Time Remaining", timeLeftFormatted, defaultFlags = mcm.OPTION_DISABLED)
        else
            mcm.AddOptionText("Time Remaining", "Undetermined", defaultFlags = mcm.OPTION_DISABLED)
        endif
    endif

    if (prisoner.ShowTimeServed && prisoner.TimeServed >= 1)
        string timeServedFormatted  = prison.GetTimeServedFormatted(prisoner)
        mcm.AddOptionText(string_if (!prisoner.IsUndeterminedSentence, "Time Served", "Time in Prison"), timeServedFormatted, defaultFlags = mcm.OPTION_DISABLED)
    endif

    if (prisoner.HasCriminalPenalty)
        mcm.AddEmptyOption()
        mcm.AddEmptyOption()

        string infamyKnownText = "Due to being a known criminal, " + prisoner.Name + "'s sentence has been extended"
        string infamyRecognizedText = "Due to having been recognized, " + prisoner.Name + "'s sentence has been extended"
        
        mcm.AddOptionText("Prison Observations:", defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText(string_if (prisoner.IsInfamyKnown, infamyKnownText, infamyRecognizedText), defaultFlags = mcm.OPTION_DISABLED)
        mcm.AddOptionText("by " + prison.GetCriminalPenaltySentenceFormatted(prisoner) + ".", defaultFlags = mcm.OPTION_DISABLED)
    endif

    mcm.AddEmptyOption()
    ; emptySpacesRight += 1

    while (emptySpacesRight < emptySpacesLeft)
        mcm.AddEmptyOption()
        emptySpacesRight += 1
    endWhile
endFunction

function DisplayTimeHeader(RPB_MCM_02 mcm) global
    string currentTimeFormatted = RPB_Utility.GetCurrentDateFormatted()
    mcm.AddOptionText("", currentTimeFormatted, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
endFunction

;/
    Displays the Header section info with the Prison info.
    The header's values, as well as their position, are controlled through the template on the MCM config file.
/;
function DisplayPrisonHeader(RPB_MCM_02 mcm, RPB_Prison apPrison, RPB_Prisoner apPrisoner) global
    string[] headerPlaceholders = mcm.PrisonHeaderPlaceholders
    string[] prisonHeader = mcm.ConstructPrisonHeaderValues( \ 
        asPrisonHold    = apPrison.Hold, \
        asPrisonCity    = apPrison.City, \
        asPrisonName    = apPrison.Name, \
        asPrisonCell    = apPrisoner.JailCell.ID, \
        asPrisonerName  = apPrisoner.Name \
    )

    string prisonTemplate = mcm.PrisonHeaderTemplate
    string header = RPB_Utility.Replace(prisonTemplate, headerPlaceholders, prisonHeader)

    mcm.AddOptionText("", header, defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionCategory("", flags = mcm.OPTION_DISABLED)
    mcm.AddEmptyOption()
endFunction
