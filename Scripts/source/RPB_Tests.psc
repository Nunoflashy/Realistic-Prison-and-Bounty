scriptname RPB_Tests hidden

import RPB_Utility

function start_test(string testName = "", string msg = "") global
    base_log("TEST", "Starting Test: " + testName + msg, "Tests::" + testName)
endFunction

function display_result(string testName = "", bool condition) global
    base_log("TEST", string_if (condition, "Test Passed!", "Test Failed!"), "Tests::" + testName)
endFunction

function log(string testName = "", string msg) global
    base_log("TEST", msg, "Tests::" + testName)
endFunction

bool function assert_true(string testName = "", bool condition, string failMessage = "") global
    if (!condition)
        base_log("ASSERT", "Assertion Failed: " + failMessage, "Tests::" + testName)
    endif

    return condition
endFunction

bool function assert_false(string testName = "", bool condition, string failMessage = "") global
    return assert_true(testName, !condition, failMessage)
endFunction

bool function assert_equals(string testName = "", string expectedValue, string gottenValue, string failMessage = "") global
    if (gottenValue != expectedValue)
        base_log("ASSERT", "Assertion Failed: " + failMessage + " (Expected: " + expectedValue + ", Got: " + gottenValue + ")", "Tests::" + testName)
    endif

    return gottenValue == expectedValue
endFunction

bool function assert_not_equals(string testName = "", string expectedValue, string gottenValue, string failMessage = "") global
    if (gottenValue == expectedValue)
        base_log("ASSERT", "Assertion Failed: " + failMessage + " (Expected: " + expectedValue + ", Got: " + gottenValue + ")", "Tests::" + testName)
    endif

    return gottenValue != expectedValue
endFunction

function RunAllTests() global
    start_test("DisplayNextDaysOfWeek", "\n\n")
    DisplayNextDaysOfWeek()
    
    start_test("DisplayPreviousDaysOfWeek", "\n\n")
    DisplayPreviousDaysOfWeek()

    start_test("Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk", "\n\n")
    Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk()

    start_test("Test_Can_Get_Prison_For_Actor_Globally", "\n\n")
    Test_Can_Get_Prison_For_Actor_Globally()

    start_test("Test_Can_Get_Prisoner_Without_Arrest", "\n\n")
    Test_Can_Get_Prisoner_Without_Arrest()

    start_test("Test_Can_Imprison_Actor_Without_Arresting", "\n\n")
    Test_Can_Imprison_Actor_Without_Arresting()

    start_test("Test_Imprison_Actor", "\n\n")
    Test_Imprison_Actor()

    start_test("Test_Imprison_Multiple_Actors", "\n\n")
    Test_Imprison_Multiple_Actors()

    start_test("Test_Arrest_And_Imprison_Multiple_Actors_With_Scene", "\n\n")
    Test_Arrest_And_Imprison_Multiple_Actors_With_Scene()
endFunction

function DisplayNextDaysOfWeek() global
    int firstDayOfWeek  = RPB_Utility.GetDayOfWeekByName("Sundas")
    int lastDayOfWeek   = RPB_Utility.GetDayOfWeekByName("Loredas")

    int currentDayOfWeek = firstDayOfWeek
    while (currentDayOfWeek <= lastDayOfWeek)
        int nextDayOfWeek = RPB_Utility.GetNextDayOfWeekFromDate(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), currentDayOfWeek)
        int daysTillDayOfWeek = RPB_Utility.GetStructMemberInt(nextDayOfWeek, "daysFromNow")
        string dayOfWeekName = RPB_Utility.GetDayOfWeekName(currentDayOfWeek)
        string dayOfWeekFormatted = RPB_Utility.GetNextDayOfWeekDateFormatted(dayOfWeekName)
        
        RPB_Utility.Debug("Tests::DisplayNextDaysOfWeek", "Next " + dayOfWeekName + ": ")
        RPB_Utility.Debug("Tests::DisplayNextDaysOfWeek", dayOfWeekFormatted)
        RPB_Utility.Debug("Tests::DisplayNextDaysOfWeek", "In " + daysTillDayOfWeek + " Days\n")

        currentDayOfWeek += 1
    endWhile
endFunction

function DisplayPreviousDaysOfWeek() global
    int firstDayOfWeek  = RPB_Utility.GetDayOfWeekByName("Sundas")
    int lastDayOfWeek   = RPB_Utility.GetDayOfWeekByName("Loredas")

    int currentDayOfWeek = firstDayOfWeek
    while (currentDayOfWeek <= lastDayOfWeek)
        int previousDayOfWeek = RPB_Utility.GetPreviousDayOfWeekFromDate(RPB_Utility.GetCurrentDay(), RPB_Utility.GetCurrentMonth(), RPB_Utility.GetCurrentYear(), currentDayOfWeek)
        int daysFromDayOfWeek = RPB_Utility.GetStructMemberInt(previousDayOfWeek, "daysAgo")
        string dayOfWeekName = RPB_Utility.GetDayOfWeekName(currentDayOfWeek)
        string dayOfWeekFormatted = RPB_Utility.GetPreviousDayOfWeekDateFormatted(dayOfWeekName)
        
        RPB_Utility.Debug("Tests::DisplayPreviousDaysOfWeek", "Previous " + dayOfWeekName + ": ")
        RPB_Utility.Debug("Tests::DisplayPreviousDaysOfWeek", dayOfWeekFormatted)
        RPB_Utility.Debug("Tests::DisplayPreviousDaysOfWeek", daysFromDayOfWeek + " Days Ago\n")

        currentDayOfWeek += 1
    endWhile
endFunction

function Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk() global
    int twentyFiveDaysAfter26thFrostfall = RPB_Utility.GetDateFromDaysPassed(26, 10, 201, 25)
    int day     = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "day")
    int month   = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "month")
    int year    = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "year")

    bool dateMatches = assert_true( \
        "Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk", \
        day == 20 && month == 11 && year == 201, \
        "Date: " + RPB_Utility.GetDateFormat(day, month, year, format = "d M Y") \
    )

    display_result("Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk", dateMatches)
endFunction

function Test_Can_Get_Prison_For_Actor_Globally() global
    ; Use this Prison
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

    ; Use this Actor
    Actor testPrisoner = Game.GetFormEx(0x14) as Actor

    RPB_Arrestee arrestee = (RPB_API.GetArrest()).MakeArrestee(testPrisoner)
    arrestee.SetArrestParameters((RPB_API.GetArrest()).ARREST_TYPE_TELEPORT_TO_CELL, none, solitudePrison.PrisonFaction)

    ; Add the actor to Prison
    RPB_Prisoner prisoner = arrestee.MakePrisoner()

    RPB_Prison foundPrison = (RPB_API.GetPrisonManager()).FindPrisonByPrisoner(testPrisoner)
    Utility.Wait(0.1)

    bool samePrisons = assert_equals("Test_Can_Get_Prison_For_Actor_Globally", solitudePrison, foundPrison, "The prisons do not match")

    display_result("Test_Can_Get_Prison_For_Actor_Globally", samePrisons)
    arrestee.Destroy()
    prisoner.Destroy()
endFunction

function Test_Can_Get_Prisoner_Without_Arrest() global
    RealisticPrisonAndBounty_Arrest arrest = RPB_API.GetArrest()
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

    Actor player = Game.GetFormEx(0x14) as Actor

    RPB_StorageVars.SetFormOnForm("Faction", player, solitudePrison.PrisonFaction, "Arrest")
    RPB_StorageVars.SetFormOnForm("Arrestee", player, player, "Arrest")
    RPB_StorageVars.SetStringOnForm("Arrest Type", player, arrest.ARREST_TYPE_TELEPORT_TO_CELL, "Arrest")
    RPB_StorageVars.SetStringOnForm("Hold", player, solitudePrison.Hold, "Arrest")
    RPB_StorageVars.SetFloatOnForm("Time of Arrest", player, RPB_Utility.GetCurrentTime(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Minute of Arrest", player, RPB_Utility.GetCurrentMinute(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Hour of Arrest", player, RPB_Utility.GetCurrentHour(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Day of Arrest", player, RPB_Utility.GetCurrentDay(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Month of Arrest", player, RPB_Utility.GetCurrentMonth(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Year of Arrest", player, RPB_Utility.GetCurrentYear(), "Jail")

    RPB_Prisoner prisonerRef = solitudePrison.MakePrisoner(player)

    assert_true("Test_Can_Get_Prisoner_Without_Arrest", prisonerRef, "Prisoner reference is null!")
endFunction

function Test_Can_Imprison_Actor_Without_Arresting() global
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

    Actor player = Game.GetFormEx(0x14) as Actor

    ; RPB_StorageVars.SetFormOnForm("Faction", player, solitudePrison.PrisonFaction, "Arrest")
    RPB_StorageVars.SetStringOnForm("Hold", player, solitudePrison.Hold, "Jail")
    RPB_StorageVars.SetIntOnForm("Sentence", player, 40, "Jail")
    RPB_StorageVars.SetIntOnForm("Prison ID", player, solitudePrison.GetID(), "Jail")
    ; RPB_StorageVars.SetFormOnForm("Cell", player, Game.GetFormEx(0x2003879) as RPB_JailCell, "Jail")

    RPB_Prisoner prisonerRef = solitudePrison.MakePrisoner(player)
    
    ; Set showable options
    prisonerRef.ShowReleaseTime          = false
    prisonerRef.ShowSentence             = false
    prisonerRef.ShowTimeServed           = true
    prisonerRef.ShowTimeLeftInSentence   = false
    prisonerRef.IsUndeterminedSentence   = true
    prisonerRef.ShowBounty               = false

    prisonerRef.AssignCell()
    prisonerRef.MoveToCell()

    bool isValidPrisoner = assert_true("Test_Can_Get_Prisoner_Without_Arrest", prisonerRef, "Prisoner reference is null!")
    display_result("Test_Can_Get_Prisoner_Without_Arrest", isValidPrisoner)
endFunction

function Test_Imprison_Actor() global
    ; Use this Prison
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

    ; Use this Actor
    Actor testPrisoner = Game.GetFormEx(0x14) as Actor

    solitudePrison.ImprisonActorImmediately(testPrisoner)
    solitudePrison.ProcessImprisonmentForQueuedPrisoners()
endFunction

function Test_Imprison_Multiple_Actors() global
    ; Use this Prison
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

    Actor player = Game.GetFormEx(0x14) as Actor

    ActorBase vivienneOnisBase = Game.GetFormEx(0x132AE) as ActorBase
    int npcCount = 4
    int i = 0
    while (i < npcCount)
        Actor vivienne = player.PlaceActorAtMe(vivienneOnisBase, 1)
        solitudePrison.ImprisonActorImmediately(vivienne)
        ActorUtil.AddPackageOverride(vivienne, Game.GetFormEx(0x200F547) as Package, 100)
        i += 1
    endWhile
    solitudePrison.ImprisonActorImmediately(player)
    solitudePrison.ProcessImprisonmentForQueuedPrisoners()
endFunction

function Test_Arrest_And_Imprison_Multiple_Actors_With_Scene() global
    RealisticPrisonAndBounty_Arrest arrest = RPB_API.GetArrest()

    Actor player = Game.GetFormEx(0x14) as Actor

    Actor guard = RealisticPrisonAndBounty_Util.GetNearestActor(player, 2000)

    ; ActorBase vivienneOnisBase = Game.GetFormEx(0x132AE) as ActorBase
    ActorBase playerBase = player.GetBaseObject() as ActorBase
    ; int npcCount = 1
    ; int i = 0
    ; while (i < npcCount)
    ;     ; Actor vivienne = player.PlaceActorAtMe(vivienneOnisBase, 1)
    ;     Actor playerCopy = player.PlaceActorAtMe(playerBase, 1)
    ;     RPB_Arrestee arresteeRef = arrest.MakeArrestee(playerCopy)
    ;     ; arrest.OnArrestBegin(arresteeRef, guard, guard.GetCrimeFaction(), arrest.ARREST_TYPE_ESCORT_TO_JAIL)
    ;     ; arrest.ArrestActor(guard, vivienne, arrest.ARREST_TYPE_ESCORT_TO_JAIL)
    ;     i += 1
    ; endWhile
    Actor playerCopy = player.PlaceActorAtMe(playerBase, 1)
    RPB_Arrestee playerCopyRef = arrest.MakeArrestee(playerCopy)

    RPB_Arrestee arresteeRef = arrest.MakeArrestee(player)
    arrest.OnArrestBegin(arresteeRef, guard, guard.GetCrimeFaction(), arrest.ARREST_TYPE_ESCORT_TO_JAIL)
    RPB_Utility.BindAliasTo(RPB_API.GetSceneManager().GetEscortee(1), playerCopy)

endFunction

function Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding() global
    RPB_Prison solitudePrison = RPB_API.GetPrisonManager().GetPrison("Haafingar")
    RPB_JailCell selectedCell = solitudePrison.JailCells[0] as RPB_JailCell

    bool cellCannotAllowOvercrowding = assert_false("Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", selectedCell.AllowOvercrowding, "Cell is allowing overcrowding") 

    ; Prisoners
    Actor player = Game.GetFormEx(0x14) as Actor
    ActorBase vivienneOnisBase = Game.GetFormEx(0x132AE) as ActorBase
    ; ActorBase banditFemale = Game.GetFormEx(0x3CF5C) as ActorBase
    ActorBase playerBase = player.GetBaseObject() as ActorBase

    Package RPB_WanderInCell = Game.GetFormEx(0x200F547) as Package

    Actor playerCopy = player.PlaceActorAtMe(playerBase, 1)
    Actor playerCopy2 = player.PlaceActorAtMe(playerBase, 1)

    ; Set the prison for the prisoners
    RPB_StorageVars.SetIntOnForm("Prison ID", playerCopy2, solitudePrison.GetID(), "Jail")
    RPB_StorageVars.SetIntOnForm("Prison ID", playerCopy, solitudePrison.GetID(), "Jail")

    RPB_Prisoner playerPrisonerRef  = solitudePrison.MakePrisoner(playerCopy2)
    RPB_Prisoner npcPrisonerRef     = solitudePrison.MakePrisoner(playerCopy)

    bool playerPrisonerNotNull  = assert_true("Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", playerPrisonerRef, "Player Prisoner reference is null")
    bool npcPrisonerNotNull     = assert_true("Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", npcPrisonerRef, "NPC Prisoner reference is null")
    
    ; Assign the same cell to both
    solitudePrison.AssignPrisonerToCell(playerPrisonerRef, selectedCell)
    solitudePrison.AssignPrisonerToCell(npcPrisonerRef, selectedCell)

    ; Make their sentences undetermined
    playerPrisonerRef.IsUndeterminedSentence = true
    ; npcPrisonerRef.IsUndeterminedSentence = true
    solitudePrison.SetSentence(npcPrisonerRef, 100)

    bool playerPrisonerHasCell  = assert_equals("Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", selectedCell, playerPrisonerRef.JailCell, "Could not assign the selected cell to the Player Prisoner")
    bool npcPrisonerHasCell     = assert_equals("Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", selectedCell, npcPrisonerRef.JailCell, "Could not assign the selected cell to the NPC Prisoner")

    playerPrisonerRef.MoveToCell()
    npcPrisonerRef.MoveToCell()

    playerPrisonerRef.ShowReleaseTime          = true
    playerPrisonerRef.ShowSentence             = true
    playerPrisonerRef.ShowTimeServed           = true
    playerPrisonerRef.ShowTimeLeftInSentence   = true

    npcPrisonerRef.ShowReleaseTime          = true
    npcPrisonerRef.ShowSentence             = true
    npcPrisonerRef.ShowTimeServed           = true
    npcPrisonerRef.ShowTimeLeftInSentence   = true

    int cellMaxPrisoners    = selectedCell.MaxPrisoners
    int prisonersInCell     = selectedCell.PrisonerCount

    bool prisonersNotOvercrowding = assert_true("Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", (prisonersInCell <= cellMaxPrisoners) && (prisonersInCell > 0), "Prisoners exceed the Cell's Maximum Prisoners")
    bool result = playerPrisonerNotNull && npcPrisonerNotNull && (playerPrisonerHasCell || npcPrisonerHasCell) && prisonersNotOvercrowding && cellCannotAllowOvercrowding

    display_result("Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", result)
endFunction

function Test_Initialize_All_Jail_Cells()

endFunction

; function Test_GetDateFromDaysPassedOldVsNew() global
;     int day     = 10
;     int month   = 1
;     int year    = 201

;     int yearIndex = 201
;     int monthIndex = 1
;     int dayIndex = 1
    
;     string firstMonthName   = RPB_Utility.GetMonthName(month)
;     string firstDayOrdinal  = RPB_Utility.ToOrdinalNthDay(day)

;     int daysProcessed = 1
;     while (monthIndex <= 12)
;         string monthName = RPB_Utility.GetMonthName(monthIndex)
;         while (dayIndex <= RPB_Utility.GetDaysOfMonth(monthIndex))
;             string dayOrdinal = RPB_Utility.ToOrdinalNthDay(dayIndex)
            
;             int newAlgorithmResult = RPB_Utility.GetDateFromDaysPassedFast(day, month, year, daysProcessed)
;             int oldAlgorithmResult = RPB_Utility.GetDateFromDaysPassedStruct(day, month, year, daysProcessed)

;             int newAlgorithmDay = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "day")
;             int oldAlgorithmDay = RPB_Utility.GetStructMemberInt(oldAlgorithmResult, "day")

;             int newAlgorithmMonth = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "month")
;             int oldAlgorithmMonth = RPB_Utility.GetStructMemberInt(oldAlgorithmResult, "month")

;             int newAlgorithmYear = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "year")
;             int oldAlgorithmYear = RPB_Utility.GetStructMemberInt(oldAlgorithmResult, "year")
;             int newAlgorithmMonthsAdvanced = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "debug_monthsIncreased")
;             int newAlgorithmDaysIncreased = RPB_Utility.GetStructMemberInt(newAlgorithmResult, "debug_daysIncreased")

;             string oldAlgorithmDate = RPB_Utility.GetDateFormat(oldAlgorithmDay, oldAlgorithmMonth, oldAlgorithmYear)
;             string newAlgorithmDate = RPB_Utility.GetDateFormat(newAlgorithmDay, newAlgorithmMonth, newAlgorithmYear)

;             bool hasDayPassedTest = newAlgorithmDay == oldAlgorithmDay
;             string testResultStr = string_if (hasDayPassedTest, "[PASSED]", "[FAILED]")
;             RPB_Utility.Debug("Tests::Test_GetDateFromDaysPassedOldVsNew", testResultStr + " - Testing " + (daysProcessed) + " days after " + firstDayOrdinal + " of " + firstMonthName + "... " + string_if (!hasDayPassedTest, "("+ "Expected: " + oldAlgorithmDate + ", Got: " + newAlgorithmDate +")" + " ["+ "Months Advanced: " + newAlgorithmMonthsAdvanced +"]" + " ["+ "Days Increased: " + newAlgorithmDaysIncreased +"]", "(Result: "+ newAlgorithmDate +")"))

;             dayIndex += 1
;             daysProcessed += 1
;         endWhile

;         dayIndex = 1
;         monthIndex += 1
;     endWhile
; endFunction