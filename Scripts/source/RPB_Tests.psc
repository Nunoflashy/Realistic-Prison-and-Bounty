scriptname RPB_Tests extends ObjectReference hidden

import RPB_Utility
import RPB_Memory

bool property ENABLE_TRACING            = false autoreadonly
bool property ENABLE_DEBUGGING          = false autoreadonly
bool property ENABLE_LOGGING            = false autoreadonly
bool property DISPLAY_ASSERT_IN_GAME    = false autoreadonly
; Was false - a test run produced nothing on-screen unless this had already been flipped
; and the script recompiled first. Defaulting it on makes "press F1, run a test" show a
; result immediately with no source-editing step beforehand; the noisier per-step tracing
; flags above stay opt-in/log-only.
bool property DISPLAY_RESULT_IN_GAME    = true autoreadonly

function SetTests()
    self.AddTest("00 - Run All Tests", "__RUN_ALL__")
    self.AddTest("00 - No Test", "")
    self.AddTest("01 - 25 Days after 26th Frostfall is 20th of Sun's Dusk", "Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk")
    self.AddTest("02 - Get Prison For Actor Globally", "Test_Can_Get_Prison_For_Actor_Globally")
    self.AddTest("03 - Imprison Actor without Arresting", "Test_Can_Imprison_Actor_Without_Arresting")
    ; Not chainable: spawns 4 permanent NPCs with no cleanup - see KNOWN_ISSUES.md
    self.AddTest("04 - Imprison Multiple Actors", "Test_Imprison_Multiple_Actors", abChainable = false)
    ; Not chainable: a real arrest/escort Scene, not something to fire unattended in a chain
    self.AddTest("05 - Arrest and Imprison Multiple Actors with Scene", "Test_Arrest_And_Imprison_Multiple_Actors_With_Scene", abChainable = false)
    ; Not chainable: hangs when run as part of "00 - Run All Tests" - root cause not yet
    ; diagnosed (unlike 09's), mitigated here until there's evidence to chase further
    self.AddTest("06 - Imprisonment In Cell Should Not Allow Overcrowding", "Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", abChainable = false)
    self.AddTest("07 - Imprison Player Without Arresting - Required Bounty", "Test_Imprison_Player_Without_Arresting_Required_Bounty")
    self.AddTest("08 - Can Add Prisoners to PrisonerList", "Test_Can_Add_Prisoners_To_PrisonerList")
    ; Not chainable: unsets all prison slots with nothing in this suite to reconfigure them
    ; afterward (Test_Configure_Prisons' own reconfiguration call is dead) - see KNOWN_ISSUES.md
    self.AddTest("09 - Unset Prisons", "Test_Unset_Prisons", abChainable = false)
    self.AddTest("10 - Configure Prisons", "Test_Configure_Prisons")
    ; Not chainable: a real arrest/escort Scene, not something to fire unattended in a chain
    self.AddTest("11 - Arrest Selected NPC with Escort Scene", "Test_Arrest_Selected_NPC_Escort_Scene", abChainable = false)
    self.AddTest("12 - ActiveMagicEffectContainer: Page-Boundary Crossing", "Test_ActiveMagicEffectContainer_PageBoundary")
    ; Not chainable: stalls "00 - Run All Tests" with no log detail captured yet - root cause
    ; not diagnosed, mitigated here until there's evidence to chase further (same pattern as 06)
    self.AddTest("13 - Test Prisoner Has Bounty in Prison", "Test_PrisonerHasBountyInPrison", abChainable = false)
    self.AddTest("14 - Test Prisoner Gets Correct Escape Penalty", "Test_PrisonerEscapeGetsCorrectPenalty")
    self.AddTest("15 - Test List Algorithms", "Test_ListAlgorithms")
    self.AddTest("17 - Test New Serialization - Compare with Old", "Test_NewSerializationCompareWithOld")
    self.AddTest("18 - Test Prison Root Objects", "Test_PrisonRootObjects")
    self.AddTest("19 - Test JSON Conditions", "Test_JSONConditions")
    self.AddTest("20 - Test Data Structures", "Test_DataStructures")
    ; Not chainable: 1600 iterations, a benchmark not a correctness test - heavy for a routine chain
    self.AddTest("21 - Benchmark StorageVars", "Benchmark_StorageVars", abChainable = false)
    self.AddTest("22 - ActorList: Add and Retrieve (Prisoner/Arrestee/Captor)", "Test_ActorList_Add_And_Retrieve")
    self.AddTest("23 - ActorList: Multiple Adds and GetKeys()", "Test_ActorList_Multiple_And_GetKeys")
    self.AddTest("24 - ActorList: Remove and Reindex", "Test_ActorList_Remove_And_Reindex")
    self.AddTest("25 - ActiveMagicEffectContainer: Dense Packing After Interleaved Add/Remove", "Test_ActiveMagicEffectContainer_DensePacking")
    self.AddTest("26 - CaptorList: Remove Path (protected_remove)", "Test_CaptorList_Remove_Path")
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21
    self.AddTest("27 - Benchmark: Raw JMap vs RPB_Memory FastMap", "Benchmark_RawJMap_vs_FastMap", abChainable = false)
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27
    self.AddTest("28 - Benchmark: 32x32 vs 128x8 Page Dispatch at ~1000 Entries", "Benchmark_PageDispatch_32x32_vs_128x8", abChainable = false)
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27/28
    self.AddTest("29 - Benchmark: FindKeyForIndex Scan Cost at 150 Entries", "Benchmark_FindKeyForIndexScanCost", abChainable = false)
endFunction

state Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk
    function Setup()
        int twentyFiveDaysAfter26thFrostfall = RPB_Utility.GetDateFromDaysPassed(26, 10, 201, 25)
        int day     = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "day")
        int month   = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "month")
        int year    = RPB_Utility.GetStructMemberInt(twentyFiveDaysAfter26thFrostfall, "year")
    
        bool dateMatches = assert_true( \
            day == 20 && month == 11 && year == 201, \
            "Date: " + RPB_Utility.GetDateFormat(day, month, year, format = "d M Y") \
        )
    
        display_result(dateMatches)
    endFunction
endState

state Test_Can_Get_Prison_For_Actor_Globally
    function Setup()
        ; Use this Prison
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        ; Use this Actor
        Actor testPrisoner = Game.GetFormEx(0x14) as Actor

        RPB_Arrestee arrestee = (RPB_API.GetArrest()).AwaitArresteeReference(testPrisoner)
        arrestee.SetArrestParameters((RPB_API.GetArrest()).ARREST_TYPE_TELEPORT_TO_CELL, none, solitudePrison.PrisonFaction)

        ; Add the actor to Prison
        RPB_Prisoner prisoner = arrestee.MakePrisoner()

        RPB_Prison foundPrison = (RPB_API.GetPrisonManager()).FindPrisonByPrisoner(testPrisoner)
        Utility.Wait(0.1)

        bool samePrisons = assert_equals(solitudePrison, foundPrison, "The prisons do not match")

        display_result(samePrisons)
        arrestee.Destroy()
        prisoner.Destroy()
    endFunction
endState

state Test_Can_Imprison_Actor_Without_Arresting
    function Setup()
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        Actor selectedActor = Game.GetCurrentConsoleRef() as Actor
    
        RPB_Prisoner prisonerRef = solitudePrison.MakePrisoner(selectedActor)
        prisonerRef.SetBelongingsContainer()
        prisonerRef.SetSentence(4)
        
        bool isValidPrisoner = assert_true(prisonerRef, "Prisoner reference is null!")
        bool isNotImprisoned = assert_false(prisonerRef.IsImprisoned, "Prisoner is already imprisoned!")

        ; Set showable options
        prisonerRef.ShowReleaseTime          = true
        prisonerRef.ShowSentence             = true
        prisonerRef.ShowTimeServed           = true
        prisonerRef.ShowTimeLeftInSentence   = true
        prisonerRef.ShowBounty               = true
    
        prisonerRef.AssignCell()
        prisonerRef.MoveToCell()
    
        bool hasBeenAssignedCell = assert_true(prisonerRef.JailCell, "Could not assign a jail cell")

        prisonerRef.OnSentenceSet(4, now())

        display_result(isValidPrisoner && isNotImprisoned && hasBeenAssignedCell)
    endFunction
endState

state Test_Imprison_Player_Without_Arresting_Required_Bounty
    function Setup()
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player              = Game.GetFormEx(0x14) as Actor
        RPB_Prisoner prisonerRef  = solitudePrison.MakePrisoner(player)

        prisonerRef.IsUndeterminedSentence = true
        prisonerRef.HideBounty()
        prisonerRef.SetSentence()
        prisonerRef.IsUndeterminedSentence = false

        ; Set showable options
        prisonerRef.ShowReleaseTime          = true
        prisonerRef.ShowSentence             = true
        prisonerRef.ShowTimeServed           = true
        prisonerRef.ShowTimeLeftInSentence   = true
        prisonerRef.ShowBounty               = true

        prisonerRef.AssignCell()
        prisonerRef.MoveToCell()

        bool isValidPrisoner = assert_true(prisonerRef, "Prisoner reference is null!")
        display_result(isValidPrisoner)
    endFunction
endState

state Test_Imprison_Multiple_Actors
    function Setup()
        ; Use this Prison
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        Actor player = Game.GetFormEx(0x14) as Actor

        ; ReferenceAlias wanderInCellAlias = RPB_API.GetSceneManager().GetAliasByName("Prisoner1") as ReferenceAlias
        ; Quest cellPackages = GetFormFromMod(0x1F8CC) as Quest
        ; ReferenceAlias wanderInCellAlias = cellPackages.GetAliasByName("WanderInCell01") as ReferenceAlias
        ; log("wanderInCellAlias: " + wanderInCellAlias)
        ; Package RPB_WanderInCell = Game.GetFormEx(0x1414E) as Package

        ; ActorBase vivienneOnisBase = Game.GetFormEx(0x132AE) as ActorBase
        ActorBase vivienneOnisBase = Game.GetFormEx(0x132A1) as ActorBase
        int npcCount = 4
        int i = 0
        while (i < npcCount)
            Actor vivienne = player.PlaceActorAtMe(vivienneOnisBase, 1)
            ; BindAliasTo(wanderInCellAlias, vivienne)
            vivienne.EvaluatePackage()
            solitudePrison.ImprisonActorImmediately(vivienne)
            ; ActorUtil.AddPackageOverride(vivienne, Game.GetFormEx(0x200F547) as Package, 100)
            i += 1
        endWhile
        ; solitudePrison.ImprisonActorImmediately(player)
        ; solitudePrison.ProcessImprisonmentForQueuedPrisoners()
    endFunction
endState

state Test_Arrest_And_Imprison_Multiple_Actors_With_Scene
    function Setup()
        RPB_Arrest arrest = RPB_API.GetArrest()

        Actor player = Game.GetFormEx(0x14) as Actor
    
        Actor guard = RPB_Utility.GetNearestActor(player, 2000)
    
        ; ActorBase vivienneOnisBase = Game.GetFormEx(0x132AE) as ActorBase
        ActorBase playerBase = player.GetBaseObject() as ActorBase
        ; int npcCount = 1
        ; int i = 0
        ; while (i < npcCount)
        ;     ; Actor vivienne = player.PlaceActorAtMe(vivienneOnisBase, 1)
        ;     Actor playerCopy = player.PlaceActorAtMe(playerBase, 1)
        ;     RPB_Arrestee arresteeRef = arrest.AwaitArresteeReference(playerCopy)
        ;     ; arrest.OnArrestBegin(arresteeRef, guard, guard.GetCrimeFaction(), arrest.ARREST_TYPE_ESCORT_TO_JAIL)
        ;     ; arrest.ArrestActor(guard, vivienne, arrest.ARREST_TYPE_ESCORT_TO_JAIL)
        ;     i += 1
        ; endWhile
        Actor playerCopy = player.PlaceActorAtMe(playerBase, 1)
        RPB_Arrestee playerCopyRef = arrest.AwaitArresteeReference(playerCopy)
        RPB_Captor captorRef = arrest.AwaitCaptorReference(guard)
    
        RPB_Arrestee arresteeRef = arrest.AwaitArresteeReference(player)
        arrest.OnArrestBegin(arresteeRef, captorRef, guard.GetCrimeFaction(), arrest.ARREST_TYPE_ESCORT_TO_JAIL)
        ; RPB_Utility.BindAliasTo(RPB_API.GetSceneManager().GetEscortee(1), playerCopy)
    endFunction
endState

state Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding
    function Setup()
        RPB_Prison solitudePrison = RPB_API.GetPrisonManager().GetPrison("Haafingar")
        RPB_JailCell selectedCell = solitudePrison.GetCellByID("Cell 01")
        
        bool hasPrison = assert_true(solitudePrison != none, "Prison is null ["+ solitudePrison +"]")
        bool hasCell = assert_true(selectedCell != none, "Jail Cell is null ["+ selectedCell +"]")
        bool cellCannotAllowOvercrowding = assert_false(selectedCell.AllowOvercrowding, "Cell is allowing overcrowding") 
    
        ; Prisoners
        Actor player = Game.GetFormEx(0x14) as Actor
        ActorBase playerBase = player.GetBaseObject() as ActorBase
    
        Actor playerCopy    = selectedCell.PlaceActorAtMe(playerBase, 1)
        Actor playerCopy2   = selectedCell.PlaceActorAtMe(playerBase, 1)
    
        RPB_Prisoner playerPrisonerRef  = solitudePrison.MakePrisoner(playerCopy2)
        RPB_Prisoner npcPrisonerRef     = solitudePrison.MakePrisoner(playerCopy)
    
        bool playerPrisonerNotNull  = assert_true(playerPrisonerRef, "Player Prisoner reference is null")
        bool npcPrisonerNotNull     = assert_true(npcPrisonerRef, "NPC Prisoner reference is null")
        
        ; Assign the same cell to both
        solitudePrison.AssignPrisonerToCell(playerPrisonerRef, selectedCell)
        solitudePrison.AssignPrisonerToCell(npcPrisonerRef, selectedCell)
    
        ; Set their sentences
        playerPrisonerRef.SetSentence()
        npcPrisonerRef.SetSentence(100)
    
        bool playerPrisonerHasCell  = assert_equals(selectedCell, playerPrisonerRef.JailCell, "Could not assign the selected cell to the Player Prisoner")
        bool npcPrisonerHasCell     = assert_equals(selectedCell, npcPrisonerRef.JailCell, "Could not assign the selected cell to the NPC Prisoner")
    
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
    
        bool prisonersNotOvercrowding   = assert_true((prisonersInCell <= cellMaxPrisoners), "Prisoners exceed the Cell's Maximum Prisoners")
        bool cellHasPrisoners           = assert_true((prisonersInCell > 0), "No Prisoners in the cell")
    
        bool result = playerPrisonerNotNull && npcPrisonerNotNull && (playerPrisonerHasCell || npcPrisonerHasCell) && prisonersNotOvercrowding && cellCannotAllowOvercrowding && cellHasPrisoners && hasPrison && hasCell
        display_result(result)
    endFunction
endState

state Test_Can_Add_Prisoners_To_PrisonerList
    function Setup()
        RPB_Prison solitudePrison = RPB_API.GetPrisonManager().GetPrison("Haafingar")
        bool isValidPrison = assert_true(solitudePrison != none, "Prison is null")

        Actor player = Game.GetForm(0x14) as Actor
        RPB_Prisoner prisoner = solitudePrison.MakePrisoner(player)
        solitudePrison.RegisterPrisoner(prisoner)

        bool isValidPrisoner    = assert_true(prisoner != none, "Prisoner is null")
        bool isOnList           = assert_true(solitudePrison.Prisoners.Exists(prisoner), "Prisoner is not on the Prisoner list")
        bool listNotEmpty       = assert_true(solitudePrison.Prisoners.Count > 0, "Prisoner List is empty")

        display_result(isValidPrison && isValidPrison && isOnList && listNotEmpty)
    endFunction

    function Teardown()
        RPB_Prison solitudePrison = RPB_API.GetPrisonManager().GetPrison("Haafingar")
        Actor player = Game.GetForm(0x14) as Actor
        RPB_Prisoner prisoner = solitudePrison.GetPrisonerReference(player)
        solitudePrison.UnregisterPrisoner(prisoner)
    endFunction
endState

state Test_Configure_Prisons
    function Setup()
        ; Simulate LoadGame when Prisons are set up
        RPB_PrisonManager prisonManager         = RPB_API.GetPrisonManager()
        RPB_Config config  = API.Config

        ; API.Config.SetPrisons()

        ; Bug fix: this loop used to bound on prisonManager.PrisonSlots (41 - a fixed,
        ; CK-authored quest alias count, over-provisioned for future 1-hold-to-many-prisons
        ; expansion), not config.Holds.Length (8 real configured holds right now - "The
        ; Reach"/Markarth content isn't finished yet). That read config.Holds out of bounds
        ; for i = 8..40 every single run (Papyrus silently returns "" past a string[]'s
        ; length), producing a blank-hold assertion flood, AND read config.Holds 2-3x per
        ; iteration - its getter is uncached, re-parsing data.json from disk on every access
        ; (RPB_Config.psc) - so this was ~120+ synchronous disk reads in one tight loop with
        ; no Utility.Wait, a real risk of stalling the whole Papyrus VM for a moment. Reading
        ; it once into a local fixes both problems at once. See KNOWN_ISSUES.md.
        string[] holds = config.Holds

        bool validPrisons = true
        int i = 0
        while (i < holds.Length)
            RPB_Prison holdPrison = prisonManager.GetPrison(holds[i])
            bool validPrison = assert_true(holdPrison != none && holdPrison.Hold == holds[i], holdPrison.Name + " from hold "+ holds[i] +" is null")
            if (!validPrison)
                validPrisons = false
            endif
            i += 1
        endWhile

        ; Assert that this is Solitude Prison
        RPB_Prison solitudePrison = prisonManager.GetPrison("Haafingar")

        ; Diagnostic logging - the combined assertion below doesn't say which of its three
        ; clauses is false, and it's been failing with no detail to go on. Log the real
        ; values so the next run pinpoints the actual cause instead of guessing.
        log("solitudePrison.Name=" + solitudePrison.Name + " (expected: Castle Dour Dungeon)")
        log("solitudePrison.ID=" + solitudePrison.ID + ", GetPrisonByID(ID).ID=" + prisonManager.GetPrisonByID(solitudePrison.ID as int).ID)
        log("solitudePrison.Hold=" + solitudePrison.Hold + " (expected: Haafingar)")

        bool isSolitudePrison = assert_true( \
            solitudePrison.Name == "Castle Dour Dungeon" && \
            solitudePrison.ID == prisonManager.GetPrisonByID(solitudePrison.ID as int).ID && \
            solitudePrison.Hold == "Haafingar", \
            "This is not Solitude Prison" \
        )

        display_result(validPrisons && isSolitudePrison)
    endFunction
endState

state Test_Unset_Prisons
    function Setup()
        EnableDebugging()
        RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
        ; prisonManager.UninitializePrisons()

        int availablePrisonSlots = prisonManager.GetNumberOfAvailableSlots()
        log("(START) Number of Available Prison Slots: " + availablePrisonSlots)

        bool noPrisonsInitialized = true

        int i = 0
        while (i < prisonManager.PrisonSlots)
            RPB_Prison prison = prisonManager.GetPrisonByID(i)
            bool wasPrisonInitialized = prison.Active
            string prisonName = prison.Name
            prisonManager.UninitializeNthPrison(i)
            log("Unsetting Prison (ID "+ i +" ["+ prisonName +"]) | Unset: " + (!prison.Active), wasPrisonInitialized)
            bool prisonNotInitialized = assert_false(prison.Active, "The prison is initialized ("+ prisonName +")")
            if (!prisonNotInitialized)
                noPrisonsInitialized = false
            endif
            i += 1
        endWhile

        availablePrisonSlots = prisonManager.GetNumberOfAvailableSlots()
        log("(END) Number of Available Prison Slots: " + availablePrisonSlots)

        display_result(noPrisonsInitialized)
    endFunction
endState

state Test_Arrest_Selected_NPC_Escort_Scene
    function Setup()
        Actor selectedNPC = Game.GetCurrentConsoleRef() as Actor
        Actor randomGuard = RPB_Utility.GetNearestGuard(selectedNPC, 500, selectedNPC)

        ; Check if Guard is currently in a Scene, if so, queue the arrest otherwise Scene gets broken

        bool hasSelectedNPC = assert_true(selectedNPC != none, "There's no NPC selected for the arrest.")
        bool hasRandomGuard = assert_true(randomGuard != none, "There's no guard to perform the arrest.")

        if (selectedNPC.GetFormID() != 0x14)
            RPB_ActorVars.SetCrimeGold(randomGuard.GetCrimeFaction(), selectedNPC, 2000)
        else
            randomGuard.GetCrimeFaction().SetCrimeGold(2000)
        endif
        ; Get reference to arrest script
        RPB_Arrest arrest = API.Arrest
        arrest.ArrestActor(randomGuard, selectedNPC, arrest.ARREST_TYPE_ESCORT_TO_JAIL)
        ; ReferenceAlias escortee1 = API.SceneManager.GetEscortee(1)
        ; BindAliasTo(escortee1, API.Config.Player)
        ; arrest.ArrestActor(randomGuard, selectedNPC, arrest.ARREST_TYPE_TELEPORT_TO_CELL)
        ; RPB_Prison castleDourDungeon = API.PrisonManager.GetPrison("Haafingar")
        ; castleDourDungeon.ImprisonActorImmediately(selectedNPC)


        display_result(hasSelectedNPC && hasRandomGuard)
    endFunction
endState

;/
    Exercises the container's page-dispatch/dense-packing directly via cheap synthetic keys
    and a None payload - no real Actors, no AddSpell, no Utility.Wait needed, this is pure
    Papyrus/JContainers bookkeeping, so it's fast. Uses the real, live ArresteeList container
    instance (the same alias this test used to just cast and do nothing with) - every synthetic
    entry it adds gets removed again before the test ends, so nothing is left behind.
/;
state Test_ActiveMagicEffectContainer_PageBoundary
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer

        int startCount = _container.Count
        int entriesToAdd = 150 ; PAGE_SIZE is 32, so this spans pages 0-4 - a more thorough
                                ; crossing test than a single boundary

        int i = 0
        while (i < entriesToAdd)
            _container.AddElement(none, "PageBoundaryTest_" + i)
            i += 1
        endWhile

        bool countCorrect = assert_true(_container.Count == startCount + entriesToAdd, "Expected Count == " + (startCount + entriesToAdd) + ", got " + _container.Count)

        ; Index 33 falls inside page 1 (33 / 32 == 1) - confirms the page0/page1 boundary was
        ; actually crossed, not just that 150 items were stored somehow
        bool crossedPage = assert_true(_container.HasKey("PageBoundaryTest_33"), "Entry that should be in page 1 (index 33) is missing")

        ; Remove an early (page 0) entry and confirm dense-packing backfilled it correctly
        _container.RemoveElement("PageBoundaryTest_5")
        bool removedCorrectly = assert_true(_container.Count == startCount + entriesToAdd - 1, "Expected Count to drop by 1 after removal, got " + _container.Count)
        bool goneKeyGone      = assert_true(!_container.HasKey("PageBoundaryTest_5"), "Removed key is still reported as present")

        ; Clean up every synthetic entry this test added (including the one already removed)
        i = 0
        while (i < entriesToAdd)
            string _key = "PageBoundaryTest_" + i
            if (_container.HasKey(_key))
                _container.RemoveElement(_key, dispel = false)
            endif
            i += 1
        endWhile

        bool cleanedUp = assert_true(_container.Count == startCount, "Container did not return to its original Count after cleanup, got " + _container.Count)

        display_result(countCorrect && crossedPage && removedCorrectly && goneKeyGone && cleanedUp)
    endFunction
endState

state Test_PrisonerHasBountyInPrison
    function Setup()
        RPB_Prison castleDourDungeon    = API.PrisonManager.GetPrison("Haafingar")
        RPB_Prisoner playerPrisonerRef  = castleDourDungeon.AwaitPrisonerReference(Game.GetForm(0x14) as Actor)

        bool hasBounty = assert_true(playerPrisonerRef.Bounty > 0, "Prisoner does not have a bounty while in prison!")
        display_result(hasBounty)
    endFunction
endState

state Test_PrisonerEscapeGetsCorrectPenalty
    function Setup()
        ; Use this Prison
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        ; Use this Actor
        Actor testPrisoner = Game.GetFormEx(0x14) as Actor

        RPB_Arrestee arrestee = (RPB_API.GetArrest()).AwaitArresteeReference(testPrisoner)
        arrestee.SetCrimeGold(6000)

        RPB_Prisoner prisoner = arrestee.MakePrisoner()
        prisoner.AssignCell()
        prisoner.Imprison()
        prisoner.SetEscaped()
    endFunction

    function Teardown()
        
    endFunction
endState

state Test_ListAlgorithms
    function Setup()
        SetLoggingEnabled("DEBUG",  true)
        SetLoggingEnabled("LOG",  true)

        ; Test list instance
        RPB_TestList testList = (self as ObjectReference) as RPB_TestList
        testList.__private_initialize()

        begin_step("Add Elements", "Adding elements to the list...")
            testList.__private_add_at("Taarie", "Prisoner[104611]")
            testList.__private_add_at("Evette San", "Prisoner[104610]")
            testList.__private_add_at("Vivienne Onis", "Prisoner[104620]")
            testList.__private_add_at("Jala", "Prisoner[104623]")
            testList.__private_add_at("Sorex Vinius", "Prisoner[104627]")
            testList.__private_add_at("Lisette", "Prisoner[104637]")
            testList.__private_add_at("Greta", "Prisoner[104659]")
            testList.__private_add_at("Addvar", "Prisoner[104660]")
            testList.__private_add_at("Noster Eagle-Eye", "Prisoner[108087]")
            testList.__private_add_at("Priscilla", "Prisoner[108612]")
            testList.__private_add_at("Johanne", "Prisoner[109118]")
        end_step("Add Elements", testList.getListLength() == 11 && !testList.isEmpty())

        int arrayLength = testList.getListLength()

        log("List Length: "     + arrayLength)
        log("Indices: "         + testList.__private_get_indices())
        log("Keys: "            + testList.__private_get_keys())
        log("Elements: "        + testList.__private_get_elements())
        log("Indices to Keys: " + testList.__private_list_indices_relation_to_keys())
        ; testList.__private_list_data()

        begin_step("Remove Elements", "Removing Greta & Vivienne Onis from the list...")
            testList.__private_remove_at("Prisoner[104659]") ; Greta
            testList.__private_remove_at("Prisoner[104620]") ; Vivienne Onis
        end_step("Remove Elements", testList.getListLength() == (arrayLength - 2))

        begin_step("Reindex Elements")
            testList.__private_reindex()

        ; begin_step("Sort Elements")
        ;     testList.__private_sort()

        ; Print out the results for verification
        arrayLength = testList.getListLength()
        ; int i = 0
        ; while (i < arrayLength)
        ;     string element1 = testList.__private_get_value_by_index(i)
        ;     string elementKey = testList.__private_get_key_for_index(i)
        ;     int indexForKey = testList.__private_get_index_for_key(elementKey)
        ;     Debug("Test Result", "Element at index " + i + ": " + element1 + " (key: " + elementKey + ", Index for Key: "+ indexForKey +")")
        ;     i += 1
        ; endWhile

        ; ; Print out the JMap indices
        ; i = 0
        ; while (i < arrayLength)
        ;     string elementKey = testList.__private_get_key_for_index(i)
        ;     int index = testList.__private_get_index_for_key(elementKey)
        ;     Debug("JMap", "Key: " + elementKey + ", Index: " + index)
        ;     i += 1
        ; endWhile

        log("[STEP: Reindexing Elements] Indices: "         + testList.__private_get_indices())
        log("[STEP: Reindexing Elements] Keys: "            + testList.__private_get_keys())
        log("[STEP: Reindexing Elements] Elements: "        + testList.__private_get_elements())
        log("[STEP: Reindexing Elements] Indices to Keys: " + testList.__private_list_indices_relation_to_keys())

        begin_step("Check Elements Validity")
            string taarieKey    = "Prisoner[104611]"
            string evetteKey    = "Prisoner[104610]"
            string vivienneKey  = "Prisoner[104620]"
            string jalaKey      = "Prisoner[104623]"
            string sorexKey     = "Prisoner[104627]"
            string lisetteKey   = "Prisoner[104637]"
            string gretaKey     = "Prisoner[104659]"
            string addvarKey    = "Prisoner[104660]"
            string nosterKey    = "Prisoner[108087]"
            string priscillaKey = "Prisoner[108612]"
            string johanneKey   = "Prisoner[109118]"

            bool taarieResult       = assert_equals("Taarie",           testList.__private_get_value_by_key(taarieKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(taarieKey) +")")
            bool evetteResult       = assert_equals("Evette San",       testList.__private_get_value_by_key(evetteKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(evetteKey) +")")
            ; bool vivienneResult     = assert_equals("Vivienne Onis",    testList.__private_get_value_by_key(vivienneKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(vivienneKey) +")")
            bool jalaResult         = assert_equals("Jala",             testList.__private_get_value_by_key(jalaKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(jalaKey) +")")
            bool sorexResult        = assert_equals("Sorex Vinius",     testList.__private_get_value_by_key(sorexKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(sorexKey) +")")
            bool lisetteResult      = assert_equals("Lisette",          testList.__private_get_value_by_key(lisetteKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(lisetteKey) +")")
            ; bool gretaResult        = assert_equals("Greta",            testList.__private_get_value_by_key(gretaKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(gretaKey) +")")
            bool addvarResult       = assert_equals("Addvar",           testList.__private_get_value_by_key(addvarKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(addvarKey) +")")
            bool nosterResult       = assert_equals("Noster Eagle-Eye", testList.__private_get_value_by_key(nosterKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(nosterKey) +")")
            bool priscillaResult    = assert_equals("Priscilla",        testList.__private_get_value_by_key(priscillaKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(priscillaKey) +")")
            bool johanneResult      = assert_equals("Johanne",          testList.__private_get_value_by_key(johanneKey), "Does not get the correct result after reindexing! (Index: "+ testList.__private_get_index_for_key(johanneKey) +")")

            bool stepPassed = taarieResult && evetteResult && jalaResult && sorexResult && lisetteResult && addvarResult && nosterResult && priscillaResult && johanneResult
        end_step("Check Elements Validity", stepPassed)
    endFunction

    function Teardown()
        
    endFunction
endState

; Test_ActiveMagicEffectListAlgorithms removed - it directly called the container's dead
; __string_* prototype methods (a parallel, unused shadow store) on the real, live Haafingar
; PrisonerList, mutating production data's container to exercise abandoned scratch code. That
; whole __string_* implementation was deleted as part of the RPB_ActiveMagicEffectContainer
; refactor - see Test_ActiveMagicEffectContainer_PageBoundary (test 12) and
; Test_ActiveMagicEffectContainer_DensePacking (test 25) for its real replacement coverage.

state Test_NewSerializationCompareWithOld
    function Setup()
        RPB_Prison prison = API.PrisonManager.GetPrison("Haafingar")
        RPB_JailCell jailCell = Game.GetFormEx(0x36897) as RPB_JailCell ; 1st Jail Cell for this prison
        int cellsDataObject = prison.Children("Cells")

        bool oldBool = jailCell.GetOptionOfTypeBool("Bool")
        bool newBool = RPB_Data.GetPropertyOfTypeInteger(cellsDataObject, jailCell + "//Bool") as bool

        begin_step("Bool Operations")
        bool passBool = assert_true(oldBool == newBool, "Functions value mismatch!")

        int oldInteger = jailCell.GetPropertyOfTypeInt("Integer")
        int newInteger = RPB_Data.GetPropertyOfTypeInteger(cellsDataObject, jailCell + "//Integer")

        begin_step("Integer Operations")
        bool passInt = assert_true(oldInteger == newInteger, "Functions value mismatch!")

        string oldString = jailCell.GetPropertyOfTypeString("String")
        string newString = RPB_Data.GetPropertyOfTypeString(cellsDataObject, jailCell + "//String")

        begin_step("String Operations")
        bool passString = assert_equals(oldString, newString, "Functions value mismatch!")

        log( \
            "\n\t jailCell.GetPropertyOfTypeBool(Bool): " + jailCell.GetPropertyOfTypeBool("Bool") + \
            "\n\t RPB_Data.GetPropertyOfTypeInteger(cellsDataObject, " + jailCell + "//Bool): " + RPB_Data.GetPropertyOfTypeInteger(cellsDataObject, jailCell + "//Bool") + \
            "\n\t jailCell.GetPropertyOfTypeInt(Integer): " + jailCell.GetPropertyOfTypeInt("Integer") + \
            "\n\t RPB_Data.GetPropertyOfTypeInt(cellsDataObject, " + jailCell + "//Integer): " + RPB_Data.GetPropertyOfTypeInteger(cellsDataObject, jailCell + "//Integer") + \
            "\n\t jailCell.GetPropertyOfTypeString(String): " + jailCell.GetPropertyOfTypeString("String") + \
            "\n\t RPB_Data.GetPropertyOfTypeString(cellsDataObject, " + jailCell + "//String): " + RPB_Data.GetPropertyOfTypeString(cellsDataObject, jailCell + "//String") \
        )

        display_result(passBool && passInt && passString)
    endFunction
endState

state Benchmark_StorageVars
    function Setup()
        ; NOTE: this was previously wrapped in a ";/ const /;" block comment (Papyrus has no
        ; const keyword - see CODE_PRACTICES.md), which meant ITERATIONS was never actually
        ; declared. That's a compile error waiting to happen the next time this file gets a
        ; real recompile - fixed here as a prerequisite for adding anything else to this file.
        int ITERATIONS = 400

        Actor testReference = Game.GetFormEx(0x14) as Actor

        ; Setters
        float bench = StartBenchmark()
        int i = 1
        while (i <= ITERATIONS)
            RPB_StorageVars.SetStringOnReference("Test" + i, testReference, "(" + i + ") Test String To Add To Benchmark These Reference Functions")
            i += 1
        endWhile
        EndBenchmark(bench, "StorageVars Reference Setter Functions Benchmark ("+ ITERATIONS +" iterations)")

        ; Setters
        bench = StartBenchmark()
        i = 1
        while (i <= ITERATIONS)
            RPB_StorageVars.SetStringOnReference("Test" + i, testReference, "(" + i + ") Test String To Add To Benchmark These Form Functions")
            i += 1
        endWhile
        EndBenchmark(bench, "StorageVars Form Setter Functions Benchmark ("+ ITERATIONS +" iterations)")

        ; Getters
        bench = StartBenchmark()
        i = 1
        while (i <= ITERATIONS)
            RPB_StorageVars.GetStringOnReference("Test" + i, testReference)
            i += 1
        endWhile
        EndBenchmark(bench, "StorageVars Reference Getter Functions Benchmark ("+ ITERATIONS +" iterations)")

        ; Getters
        bench = StartBenchmark()

        i = 1
        while (i <= ITERATIONS)
            RPB_StorageVars.GetStringOnReference("Test" + i, testReference)
            i += 1
        endWhile
        EndBenchmark(bench, "StorageVars Form Getter Functions Benchmark ("+ ITERATIONS +" iterations)")
    endFunction
endState

;/
    Compares raw JMap calls against RPB_Memory's FastMap_* wrappers doing the identical
    operations RPB_ActiveMagicEffectContainer needs (Set+HasKey+Get+Remove per iteration,
    mirroring one Add+Remove cycle through the container) - real evidence for whether the
    planned RPB_Memory refactor of that container has any measurable call-overhead cost,
    before doing it. See RPB_MCM.psc's own FastMap conversion (TROUBLESHOOTING_NOTES.md) for
    the precedent this follows: measure first, then convert.
/;
state Benchmark_RawJMap_vs_FastMap
    function Setup()
        int ITERATIONS = 500

        ; Raw JMap - matches RPB_ActiveMagicEffectContainer's current implementation
        int rawMap = JMap.object()
        JValue.retain(rawMap)

        float rawBench = StartBenchmark()
        int i = 0
        while (i < ITERATIONS)
            string rawKey = "Key_" + i
            JMap.setInt(rawMap, rawKey, i)
            bool rawExists = JMap.hasKey(rawMap, rawKey)
            int rawValue = JMap.getInt(rawMap, rawKey)
            JMap.removeKey(rawMap, rawKey)
            i += 1
        endWhile
        int rawElapsed = EndBenchmark(rawBench, "Raw JMap: " + ITERATIONS + " Set+HasKey+Get+Remove cycles")

        ; RPB_Memory FastMap - matches the proposed refactor
        int fastMap = FastMap("<string>", true)

        float fastBench = StartBenchmark()
        i = 0
        while (i < ITERATIONS)
            string fastKey = "Key_" + i
            FastMap_SetInt(fastMap, fastKey, i)
            bool fastExists = FastMap_HasKey(fastMap, fastKey)
            int fastValue = FastMap_GetInt(fastMap, fastKey)
            FastMap_RemoveKey(fastMap, fastKey)
            i += 1
        endWhile
        int fastElapsed = EndBenchmark(fastBench, "FastMap: " + ITERATIONS + " Set+HasKey+Get+Remove cycles")

        log("Raw JMap: " + rawElapsed + " ms, FastMap: " + fastElapsed + " ms, difference: " + (fastElapsed - rawElapsed) + " ms")
        Debug.Notification("Raw: " + rawElapsed + "ms, FastMap: " + fastElapsed + "ms")

        display_result(true, showTimeElapsed = false)
    endFunction
endState

;/
    Isolates exactly the one variable in question - page-dispatch branch count - rather than
    re-testing the whole container. Two local, self-contained page layouts (32x32, matching
    the current RPB_ActiveMagicEffectContainer; 128x8, matching its original design), each
    with its own FastMap key index (identical on both sides, so it cancels out of the
    comparison), pushed to ~1000 entries - just under the shared 1024 ceiling, so EVERY page
    in both layouts actually gets used, not just the first few like test 12's 150 entries do.
/;
state Benchmark_PageDispatch_32x32_vs_128x8
    function Setup()
        int ENTRIES = 1000

        ; --- Layout A: 32-size pages x 32 (matches the current real container) ---
        ActiveMagicEffect[] a0 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a1 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a2 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a3 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a4 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a5 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a6 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a7 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a8 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a9 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a10 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a11 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a12 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a13 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a14 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a15 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a16 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a17 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a18 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a19 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a20 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a21 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a22 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a23 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a24 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a25 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a26 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a27 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a28 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a29 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a30 = new ActiveMagicEffect[32]
        ActiveMagicEffect[] a31 = new ActiveMagicEffect[32]

        int aKeyToIndex = FastMap("<string>", true)

        float aBench = StartBenchmark()
        int i = 0
        while (i < ENTRIES)
            int aPage = i / 32
            int aSlot = i % 32

            if (aPage == 0)
                a0[aSlot] = none
            elseif (aPage == 1)
                a1[aSlot] = none
            elseif (aPage == 2)
                a2[aSlot] = none
            elseif (aPage == 3)
                a3[aSlot] = none
            elseif (aPage == 4)
                a4[aSlot] = none
            elseif (aPage == 5)
                a5[aSlot] = none
            elseif (aPage == 6)
                a6[aSlot] = none
            elseif (aPage == 7)
                a7[aSlot] = none
            elseif (aPage == 8)
                a8[aSlot] = none
            elseif (aPage == 9)
                a9[aSlot] = none
            elseif (aPage == 10)
                a10[aSlot] = none
            elseif (aPage == 11)
                a11[aSlot] = none
            elseif (aPage == 12)
                a12[aSlot] = none
            elseif (aPage == 13)
                a13[aSlot] = none
            elseif (aPage == 14)
                a14[aSlot] = none
            elseif (aPage == 15)
                a15[aSlot] = none
            elseif (aPage == 16)
                a16[aSlot] = none
            elseif (aPage == 17)
                a17[aSlot] = none
            elseif (aPage == 18)
                a18[aSlot] = none
            elseif (aPage == 19)
                a19[aSlot] = none
            elseif (aPage == 20)
                a20[aSlot] = none
            elseif (aPage == 21)
                a21[aSlot] = none
            elseif (aPage == 22)
                a22[aSlot] = none
            elseif (aPage == 23)
                a23[aSlot] = none
            elseif (aPage == 24)
                a24[aSlot] = none
            elseif (aPage == 25)
                a25[aSlot] = none
            elseif (aPage == 26)
                a26[aSlot] = none
            elseif (aPage == 27)
                a27[aSlot] = none
            elseif (aPage == 28)
                a28[aSlot] = none
            elseif (aPage == 29)
                a29[aSlot] = none
            elseif (aPage == 30)
                a30[aSlot] = none
            elseif (aPage == 31)
                a31[aSlot] = none
            endif

            FastMap_SetInt(aKeyToIndex, "Key_" + i, i)
            i += 1
        endWhile
        int aElapsed = EndBenchmark(aBench, "32-size pages (32 pages): " + ENTRIES + " adds")

        ; --- Layout B: 128-size pages x 8 (matches the container's original design) ---
        ActiveMagicEffect[] b0 = new ActiveMagicEffect[128]
        ActiveMagicEffect[] b1 = new ActiveMagicEffect[128]
        ActiveMagicEffect[] b2 = new ActiveMagicEffect[128]
        ActiveMagicEffect[] b3 = new ActiveMagicEffect[128]
        ActiveMagicEffect[] b4 = new ActiveMagicEffect[128]
        ActiveMagicEffect[] b5 = new ActiveMagicEffect[128]
        ActiveMagicEffect[] b6 = new ActiveMagicEffect[128]
        ActiveMagicEffect[] b7 = new ActiveMagicEffect[128]

        int bKeyToIndex = FastMap("<string>", true)

        float bBench = StartBenchmark()
        i = 0
        while (i < ENTRIES)
            int bPage = i / 128
            int bSlot = i % 128

            if (bPage == 0)
                b0[bSlot] = none
            elseif (bPage == 1)
                b1[bSlot] = none
            elseif (bPage == 2)
                b2[bSlot] = none
            elseif (bPage == 3)
                b3[bSlot] = none
            elseif (bPage == 4)
                b4[bSlot] = none
            elseif (bPage == 5)
                b5[bSlot] = none
            elseif (bPage == 6)
                b6[bSlot] = none
            elseif (bPage == 7)
                b7[bSlot] = none
            endif

            FastMap_SetInt(bKeyToIndex, "Key_" + i, i)
            i += 1
        endWhile
        int bElapsed = EndBenchmark(bBench, "128-size pages (8 pages): " + ENTRIES + " adds")

        log("32x32: " + aElapsed + " ms, 128x8: " + bElapsed + " ms, delta: " + (aElapsed - bElapsed) + " ms")
        Debug.Notification("32x32: " + aElapsed + "ms, 128x8: " + bElapsed + "ms, delta: " + (aElapsed - bElapsed) + "ms")

        display_result(true, showTimeElapsed = false)
    endFunction
endState

;/
    Mirrors RPB_ActiveMagicEffectContainer.__FindKeyForIndex() exactly, but taking the map as
    a parameter so it can be reused against the ad-hoc FastMap built for
    Benchmark_FindKeyForIndexScanCost below, without needing a real container instance.
/;
string function __ScanForKeyAtIndex(int aiMap, int aiIndex)
    string[] keys = FastMap_KeysAsPapyrusArray(aiMap)

    int i = 0
    while (i < keys.Length)
        if (FastMap_GetInt(aiMap, keys[i]) == aiIndex)
            return keys[i]
        endif
        i += 1
    endWhile

    return ""
endFunction

;/
    Isolates RemoveElement()'s O(n) __FindKeyForIndex() reverse-lookup scan as its own cost,
    independent of page size entirely (the scan only ever touches the FastMap key index, never
    the page arrays) - built to answer a real question raised by comparing test 12 (150
    entries, full Add+Remove-drain, ~6250ms) against Benchmark_PageDispatch's isolated
    Add-only numbers (1000 entries, ~2900ms/~1700ms): those aren't the same workload, so the
    isolated benchmark's delta can't be extrapolated to test 12's. Two removal passes over
    identical 150-entry data: one mirroring RemoveElement's real scan-based swap-reindex
    pattern, one a bare-minimum direct removal by already-known key. The delta between them is
    the scan's real cost at test-12 scale - if it accounts for most of the gap, page size
    isn't the main driver of test 12's slowness; the scan is, and it's a separate concern from
    the 32x32-vs-128x8 decision.
/;
state Benchmark_FindKeyForIndexScanCost
    function Setup()
        int ENTRIES = 150

        ; --- Pass A: scan-based removal, mirrors RemoveElement()'s real pattern ---
        int mapA = FastMap("<string>", true)
        int i = 0
        while (i < ENTRIES)
            FastMap_SetInt(mapA, "Key_" + i, i)
            i += 1
        endWhile

        float scanBench = StartBenchmark()
        int countA = ENTRIES
        i = 0
        while (i < ENTRIES)
            string removeKeyA = "Key_" + i
            int removedIndexA = FastMap_GetInt(mapA, removeKeyA)
            int lastIndexA = countA - 1

            if (removedIndexA != lastIndexA)
                string lastKeyA = self.__ScanForKeyAtIndex(mapA, lastIndexA)
                if (lastKeyA != "")
                    FastMap_SetInt(mapA, lastKeyA, removedIndexA)
                endif
            endif

            FastMap_RemoveKey(mapA, removeKeyA)
            countA -= 1
            i += 1
        endWhile
        int scanElapsed = EndBenchmark(scanBench, "Scan-based removal: " + ENTRIES + " removes with O(n) reverse lookup")

        ; --- Pass B: direct removal by already-known key, no scan - the bare-minimum baseline ---
        int mapB = FastMap("<string>", true)
        i = 0
        while (i < ENTRIES)
            FastMap_SetInt(mapB, "Key_" + i, i)
            i += 1
        endWhile

        float directBench = StartBenchmark()
        i = 0
        while (i < ENTRIES)
            FastMap_RemoveKey(mapB, "Key_" + i)
            i += 1
        endWhile
        int directElapsed = EndBenchmark(directBench, "Direct removal: " + ENTRIES + " removes, no scan")

        log("Scan-based: " + scanElapsed + " ms, Direct: " + directElapsed + " ms, scan cost: " + (scanElapsed - directElapsed) + " ms")
        Debug.Notification("Scan-based: " + scanElapsed + "ms, Direct: " + directElapsed + "ms, scan cost: " + (scanElapsed - directElapsed) + "ms")

        display_result(true, showTimeElapsed = false)
    endFunction
endState

; ==========================================================
;   ActiveMagicEffectContainer / ActorList hierarchy tests
;
;   These exercise RPB_ActorList/RPB_PrisonerList/RPB_ArresteeList/RPB_CaptorList
;   (and, through them, the shared RPB_ActiveMagicEffectContainer they all extend)
;   through their real public API only - Add/Remove via the production
;   AwaitPrisonerReference()/AwaitArresteeReference()/AwaitCaptorReference()/
;   UnregisterPrisoner()/UnregisterArrestee()/UnregisterCaptor() helpers, same as
;   real gameplay uses. Written ahead of a planned refactor of the container (see
;   KNOWN_ISSUES.md) specifically to get real in-game evidence instead of relying
;   on static reading alone.
;
;   Deliberately reuses the real Haafingar/Solitude prison and the real RPB_Arrest
;   singleton (same fixture the original tests 02/08 already use) rather than a
;   dedicated isolated test list - a genuinely isolated fixture would need a new
;   ReferenceAlias added to a quest in the Creation Kit, which isn't something this
;   pass can do from source alone. Isolation instead comes from every test's
;   Teardown() fully unregistering (and disabling/deleting) every temp actor it
;   placed via __SpawnTempActor()/__TeardownAllTempActors(), so re-running the suite
;   leaves the prison/arrest state exactly as it found it.
; ==========================================================

state Test_ActorList_Add_And_Retrieve
    function Setup()
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_Arrest arrest = RPB_API.GetArrest()

        Actor tempArrestee = __SpawnTempActor()
        Actor tempCaptor   = __SpawnTempActor()
        Actor tempPrisoner = __SpawnTempActor()

        bool allPassed = true

        RPB_Arrestee arresteeRef = arrest.AwaitArresteeReference(tempArrestee)
        if (!assert_true(arresteeRef != none, "AwaitArresteeReference returned None"))
            allPassed = false
        else
            allPassed = assert_true(arrest.Arrestees.Exists(arresteeRef), "Arrestee not found via Exists() after Add") && allPassed
            allPassed = assert_true(arrest.Arrestees.AtKey(tempArrestee) == arresteeRef, "AtKey() did not return the same Arrestee instance") && allPassed
        endif

        RPB_Captor captorRef = arrest.AwaitCaptorReference(tempCaptor)
        if (!assert_true(captorRef != none, "AwaitCaptorReference returned None"))
            allPassed = false
        else
            allPassed = assert_true(arrest.Captors.Exists(captorRef), "Captor not found via Exists() after Add") && allPassed
            allPassed = assert_true(arrest.Captors.AtKey(tempCaptor) == captorRef, "AtKey() did not return the same Captor instance") && allPassed
        endif

        RPB_Prisoner prisonerRef = solitudePrison.AwaitPrisonerReference(tempPrisoner)
        if (!assert_true(prisonerRef != none, "AwaitPrisonerReference returned None"))
            allPassed = false
        else
            allPassed = assert_true(solitudePrison.Prisoners.Exists(prisonerRef), "Prisoner not found via Exists() after Add") && allPassed
            allPassed = assert_true(solitudePrison.Prisoners.AtKey(tempPrisoner) == prisonerRef, "AtKey() did not return the same Prisoner instance") && allPassed
        endif

        display_result(allPassed)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

state Test_ActorList_Multiple_And_GetKeys
    function Setup()
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        ; Utility.Wait() between each spawn+register - back-to-back AddSpell/registration
        ; calls with no breathing room can back up the engine's own script/magic-effect
        ; queue (real in-game evidence: RPB_Utility.AwaitEntityReference's default timeout
        ; is left untouched deliberately, see CODE_PRACTICES.md/KNOWN_ISSUES.md - the fix is
        ; giving the engine time, not cutting the wait short).
        Actor tempA = __SpawnTempActor()
        solitudePrison.AwaitPrisonerReference(tempA)
        Utility.Wait(1.0)

        Actor tempB = __SpawnTempActor()
        solitudePrison.AwaitPrisonerReference(tempB)
        Utility.Wait(1.0)

        Actor tempC = __SpawnTempActor()
        solitudePrison.AwaitPrisonerReference(tempC)

        bool countCorrect = assert_true(solitudePrison.Prisoners.Count == 3, "Expected Prisoners.Count == 3, got " + solitudePrison.Prisoners.Count)

        string[] keys = solitudePrison.Prisoners.GetKeys()
        bool hasA = __KeysContain(keys, "Prisoner["+ tempA.GetFormID() +"]")
        bool hasB = __KeysContain(keys, "Prisoner["+ tempB.GetFormID() +"]")
        bool hasC = __KeysContain(keys, "Prisoner["+ tempC.GetFormID() +"]")

        bool allKeysFound = assert_true(hasA && hasB && hasC, "GetKeys() is missing one or more expected keys. Got: " + keys)

        display_result(countCorrect && allKeysFound)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

state Test_ActorList_Remove_And_Reindex
    function Setup()
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        Actor tempA = __SpawnTempActor()
        RPB_Prisoner prisonerA = solitudePrison.AwaitPrisonerReference(tempA)
        log("After adding A: Count=" + solitudePrison.Prisoners.Count + ", Keys=" + solitudePrison.Prisoners.GetKeys())
        Utility.Wait(1.0)

        Actor tempB = __SpawnTempActor()
        RPB_Prisoner prisonerB = solitudePrison.AwaitPrisonerReference(tempB)
        log("After adding B: Count=" + solitudePrison.Prisoners.Count + ", Keys=" + solitudePrison.Prisoners.GetKeys())
        Utility.Wait(1.0)

        Actor tempC = __SpawnTempActor()
        RPB_Prisoner prisonerC = solitudePrison.AwaitPrisonerReference(tempC)
        log("After adding C: Count=" + solitudePrison.Prisoners.Count + ", Keys=" + solitudePrison.Prisoners.GetKeys())
        ; Same breathing-room fix as between Adds - RemoveSpell()/OnEffectFinish()/OnDestroy()
        ; is its own engine-queued operation, no different from an Add in that respect, and
        ; firing it immediately after the 3rd rapid Add hit the same congestion tests 23 hit
        ; before its fix.
        Utility.Wait(1.0)

        ; Remove the middle one - this is the case that actually exercises reindexing
        solitudePrison.UnregisterPrisoner(prisonerB)
        log("After removing B: Count=" + solitudePrison.Prisoners.Count + ", Keys=" + solitudePrison.Prisoners.GetKeys())

        bool countCorrect  = assert_true(solitudePrison.Prisoners.Count == 2, "Expected Prisoners.Count == 2 after removing the middle Prisoner, got " + solitudePrison.Prisoners.Count)
        bool aStillThere   = assert_true(solitudePrison.Prisoners.Exists(prisonerA), "Prisoner A missing after an unrelated removal")
        bool cStillThere   = assert_true(solitudePrison.Prisoners.Exists(prisonerC), "Prisoner C missing after an unrelated removal")
        bool bIsGone       = assert_true(!solitudePrison.Prisoners.Exists(prisonerB), "Removed Prisoner B is still reported as Exists()")

        display_result(countCorrect && aStillThere && cStillThere && bIsGone)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Replaces the old dataKeys probe - dataKeys (and DebugGetDataKeysCount(), built specifically
    to inspect it) no longer exist; the RPB_ActiveMagicEffectContainer refactor's dense-packing
    design has no separate order-tracking structure left to probe. This instead confirms the
    property that actually matters now: Count and key presence stay correct and gap-free
    through a mix of interleaved adds and removes. Cheap synthetic keys on the real, live
    ArresteeList container (same pattern as test 12) - no real Actors needed, nothing left
    behind afterward.
/;
state Test_ActiveMagicEffectContainer_DensePacking
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count

        ; Add 5, remove 2 from the middle, add 3 more (net +6) - exercises the swap-to-fill
        ; compaction from both directions, not just a straight append or a straight drain
        _container.AddElement(none, "DensePackTest_A")
        _container.AddElement(none, "DensePackTest_B")
        _container.AddElement(none, "DensePackTest_C")
        _container.AddElement(none, "DensePackTest_D")
        _container.AddElement(none, "DensePackTest_E")

        _container.RemoveElement("DensePackTest_B", dispel = false)
        _container.RemoveElement("DensePackTest_D", dispel = false)

        _container.AddElement(none, "DensePackTest_F")
        _container.AddElement(none, "DensePackTest_G")
        _container.AddElement(none, "DensePackTest_H")

        bool countCorrect = assert_true(_container.Count == startCount + 6, "Expected Count == " + (startCount + 6) + ", got " + _container.Count)

        bool allSurvivorsPresent = \
            _container.HasKey("DensePackTest_A") && \
            _container.HasKey("DensePackTest_C") && \
            _container.HasKey("DensePackTest_E") && \
            _container.HasKey("DensePackTest_F") && \
            _container.HasKey("DensePackTest_G") && \
            _container.HasKey("DensePackTest_H")
        allSurvivorsPresent = assert_true(allSurvivorsPresent, "One or more surviving entries went missing after interleaved add/remove")

        bool removedStaysGone = assert_true(!_container.HasKey("DensePackTest_B") && !_container.HasKey("DensePackTest_D"), "A removed entry is still reported as present")

        ; Clean up
        _container.RemoveElement("DensePackTest_A", dispel = false)
        _container.RemoveElement("DensePackTest_C", dispel = false)
        _container.RemoveElement("DensePackTest_E", dispel = false)
        _container.RemoveElement("DensePackTest_F", dispel = false)
        _container.RemoveElement("DensePackTest_G", dispel = false)
        _container.RemoveElement("DensePackTest_H", dispel = false)

        bool cleanedUp = assert_true(_container.Count == startCount, "Container did not return to its original Count after cleanup, got " + _container.Count)

        display_result(countCorrect && allSurvivorsPresent && removedStaysGone && cleanedUp)
    endFunction
endState

state Test_CaptorList_Remove_Path
    function Setup()
        RPB_Arrest arrest = RPB_API.GetArrest()
        Actor tempCaptor = __SpawnTempActor()

        RPB_Captor captorRef = arrest.AwaitCaptorReference(tempCaptor)
        bool wasAdded = assert_true(captorRef != none && arrest.Captors.Exists(captorRef), "Captor was not added correctly")

        ; CaptorList.Remove() goes through protected_remove(), a different removal path
        ; than PrisonerList/ArresteeList's RemoveElement() - worth checking on its own.
        arrest.UnregisterCaptor(captorRef, true)

        bool countIsZero    = assert_true(arrest.Captors.Count == 0, "Expected Captors.Count == 0 after removal, got " + arrest.Captors.Count)
        bool noLongerExists = assert_true(!arrest.Captors.Exists(captorRef), "Removed Captor still reported as Exists() (protected_remove path)")

        display_result(wasAdded && countIsZero && noLongerExists)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

state Test_PrisonRootObjects
    function Setup()
        EnableDebugging()
        ; Castle Dour Dungeon
        RPB_Prison prison = API.PrisonManager.GetPrison("Haafingar")
        int holdRootObject      = RPB_Data.GetRootObject("Haafingar")
        ; Only one prison object for now, later when 1:N, this must be iterated through to get all prison objects
        int prisonRootObject    = RPB_Data.GetPropertyOfTypeObject(holdRootObject, "Jail")
        ; RPB_StorageVars.SetIntOnReference("Hold Root Object", prison.UUID, holdRootObject)
        ; RPB_StorageVars.SetIntOnReference("Root Object", prison.UUID, prisonRootObject)
        
        ; log("Root Object 1: " + prison.GetSerializableRootObject())
        ; log("Root Object 2: " + prison.GetSerializableRootObject1())

        ; log("Root Object 1 Content: " + GetContainerList(prison.GetSerializableRootObject()))
        ; log("Root Object 2 Content: " + GetContainerList(prison.GetSerializableRootObject1()))
    endFunction
endState

state Test_JSONConditions
    function Setup()
        int testObject      = RPB_Data.GetObjectInPath("tests/jsonConditions.json")
        Form[] testForms    = RPB_Data.QueryFormArray(testObject, "*", "{ 'active': true }")
        begin_step("Test JSON Condition", "Displaying result of testForms")
        log(testForms)
    endFunction
endState

state Test_DataStructures
    function Setup()
        int parentContainer
        int totalObjects = 100

        start_test("Data Structures - Execution Times")

        ; JC
        parentContainer                     = JMap.object()
        int jcMemoryTimes                   = JC_Flat(parentContainer, JArray.object(), totalObjects)
        float jcObjectCreationTime          = JMap.getFlt(jcMemoryTimes, "Object Creation")
        float jcObjectReadTime              = JMap.getFlt(jcMemoryTimes, "Object Read")
        float jcObjectWriteTime             = JMap.getFlt(jcMemoryTimes, "Object Write")
        float jcObjectDeleteTime            = JMap.getFlt(jcMemoryTimes, "Object Delete")
        float jcObjectVerifyRead            = JMap.getInt(jcMemoryTimes, "Object Verify Read")
        float jcObjectVerifyCreate          = JMap.getInt(jcMemoryTimes, "Object Verify Create")
        int jcObject                        = JMap.getObj(jcMemoryTimes, "Object")
        bool jcHasValidCreateIntegrity      = JMap.getInt(jcMemoryTimes, "Object Verify Create: Integrity") as bool
        bool jcHasValidReadIntegrity        = JMap.getInt(jcMemoryTimes, "Object Verify Read: Integrity") as bool
        bool jcHasValidDeleteIntegrity      = JMap.getInt(jcMemoryTimes, "Object Verify Delete: Integrity") as bool

        ; RPB_Memory
        parentContainer                     = RPB_Memory.Map("<string>")
        int rpbMemoryTimes                  = RPB_Flat(parentContainer, RPB_Memory.Array("<int>"), totalObjects)
        ; int rpbMemoryTimes                  = RPB_Flat(parentContainer, RPB_Memory.Object("int[]", "{ 'length': 3 }"), totalObjects)
        float rpbObjectCreationTime         = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Creation")
        float rpbObjectReadTime             = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Read")
        float rpbObjectWriteTime            = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Write")
        float rpbObjectDeleteTime           = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Delete")
        float rpbObjectVerifyRead           = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Read")
        float rpbObjectVerifyCreate         = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Create")
        int rpbObject                       = RPB_Memory.Map_GetObject(rpbMemoryTimes, "Object")
        bool rpbHasValidCreateIntegrity     = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Create: Integrity") as bool
        bool rpbHasValidReadIntegrity       = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Read: Integrity") as bool
        bool rpbHasValidDeleteIntegrity     = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Delete: Integrity") as bool

        ; RPB_Memory Fast
        parentContainer                           = RPB_Memory.FastMap("<string>")
        int unsafeRpbMemoryTimes                  = RPB_Fast_Flat(parentContainer, RPB_Memory.FastArray("<int>"), totalObjects)
        float unsafeRpbObjectCreationTime         = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Creation")
        float unsafeRpbObjectReadTime             = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Read")
        float unsafeRpbObjectWriteTime            = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Write")
        float unsafeRpbObjectDeleteTime           = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Delete")
        float unsafeRpbObjectVerifyRead           = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Read")
        float unsafeRpbObjectVerifyCreate         = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Create")
        int unsafeRpbObject                       = RPB_Memory.FastMap_GetObject(unsafeRpbMemoryTimes, "Object")
        bool unsafeRpbHasValidCreateIntegrity     = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Create: Integrity") as bool
        bool unsafeRpbHasValidReadIntegrity       = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Read: Integrity") as bool
        bool unsafeRpbHasValidDeleteIntegrity     = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Delete: Integrity") as bool


        log("Object Performance (objects: "+ totalObjects +") \n"+ \ 
            "[UNIT LOG] \tJContainers: \n" + \ 
                "[UNIT LOG] \t - Creation: "+ (jcObjectCreationTime as int) +" ms ("+ FormatFloat(jcObjectCreationTime as float / totalObjects) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Read: "+ (jcObjectReadTime as int) +" ms ("+ FormatFloat(jcObjectReadTime as float / totalObjects) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Write: "+ (jcObjectWriteTime as int) +" ms ("+ FormatFloat(jcObjectWriteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Delete: "+ (jcObjectDeleteTime as int) +" ms ("+ FormatFloat(jcObjectDeleteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Create: "+ (jcObjectVerifyCreate as int) +" ms ("+ FormatFloat(jcObjectVerifyCreate as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Read: "+ (jcObjectVerifyRead as int) +" ms ("+ FormatFloat(jcObjectVerifyRead as float / totalObjects) +" ms per object)\n\n" + \
            "[UNIT LOG] \tRPB_Memory: \n" + \ 
                "[UNIT LOG] \t - Creation: "+ (rpbObjectCreationTime as int) +" ms ("+ FormatFloat(rpbObjectCreationTime as float / totalObjects) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Read: "+ (rpbObjectReadTime as int) +" ms ("+ FormatFloat(rpbObjectReadTime as float / totalObjects) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Write: "+ (rpbObjectWriteTime as int) +" ms ("+ FormatFloat(rpbObjectWriteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Delete: "+ (rpbObjectDeleteTime as int) +" ms ("+ FormatFloat(rpbObjectDeleteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Create: "+ (rpbObjectVerifyCreate as int) +" ms ("+ FormatFloat(rpbObjectVerifyCreate as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Read: "+ (rpbObjectVerifyRead as int) +" ms ("+ FormatFloat(rpbObjectVerifyRead as float / totalObjects) +" ms per object)\n\n" + \
            "[UNIT LOG] \tRPB_Memory (Fast): \n" + \ 
                "[UNIT LOG] \t - Creation: "+ (unsafeRpbObjectCreationTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectCreationTime as float / totalObjects) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Read: "+ (unsafeRpbObjectReadTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectReadTime as float / totalObjects) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Write: "+ (unsafeRpbObjectWriteTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectWriteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Delete: "+ (unsafeRpbObjectDeleteTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectDeleteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Create: "+ (unsafeRpbObjectVerifyCreate as int) +" ms ("+ FormatFloat(unsafeRpbObjectVerifyCreate as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Read: "+ (unsafeRpbObjectVerifyRead as int) +" ms ("+ FormatFloat(unsafeRpbObjectVerifyRead as float / totalObjects) +" ms per object)\n\n" \
        )
 
        display_step("JContainers -> Create Integrity", jcHasValidCreateIntegrity)
        display_step("JContainers -> Read Integrity", jcHasValidReadIntegrity)
        display_step("JContainers -> Delete Integrity", jcHasValidDeleteIntegrity)

        display_step("RPB_Memory -> Create Integrity", rpbHasValidCreateIntegrity)
        display_step("RPB_Memory -> Read Integrity", rpbHasValidReadIntegrity)
        display_step("RPB_Memory -> Delete Integrity", rpbHasValidDeleteIntegrity)

        display_step("RPB_Memory (Fast) -> Create Integrity", unsafeRpbHasValidCreateIntegrity)
        display_step("RPB_Memory (Fast) -> Read Integrity", unsafeRpbHasValidReadIntegrity)
        display_step("RPB_Memory (Fast) -> Delete Integrity", unsafeRpbHasValidDeleteIntegrity)

        debug.trace("\n")

        int nestingDepth = 30
        ; JC
        jcMemoryTimes                   = JC_Nested(nestingDepth)
        jcObjectCreationTime            = JMap.getInt(jcMemoryTimes, "Object Creation")
        jcObjectReadTime                = JMap.getInt(jcMemoryTimes, "Object Read")
        jcObjectWriteTime               = JMap.getInt(jcMemoryTimes, "Object Write")
        jcObjectDeleteTime              = JMap.getFlt(jcMemoryTimes, "Object Delete")
        jcObjectVerifyRead              = JMap.getInt(jcMemoryTimes, "Object Verify Read")
        jcObjectVerifyCreate            = JMap.getInt(jcMemoryTimes, "Object Verify Create")
        jcObject                        = JMap.getObj(jcMemoryTimes, "Object")
        jcHasValidCreateIntegrity       = JMap.getInt(jcMemoryTimes, "Object Verify Create: Integrity") as bool
        jcHasValidReadIntegrity         = JMap.getInt(jcMemoryTimes, "Object Verify Read: Integrity") as bool
        jcHasValidDeleteIntegrity       = JMap.getInt(jcMemoryTimes, "Object Verify Delete: Integrity") as bool

        ; RPB_Memory
        rpbMemoryTimes                  = RPB_Nested(nestingDepth)
        rpbObjectCreationTime           = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Creation")
        rpbObjectReadTime               = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Read")
        rpbObjectWriteTime              = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Write")
        rpbObjectDeleteTime             = RPB_Memory.Map_GetFloat(rpbMemoryTimes, "Object Delete")
        rpbObjectVerifyRead             = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Read")
        rpbObjectVerifyCreate           = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Create")
        rpbObject                       = RPB_Memory.Map_GetObject(rpbMemoryTimes, "Object")
        rpbHasValidCreateIntegrity      = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Create: Integrity") as bool
        rpbHasValidReadIntegrity        = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Read: Integrity") as bool
        rpbHasValidDeleteIntegrity      = RPB_Memory.Map_GetInt(rpbMemoryTimes, "Object Verify Delete: Integrity") as bool

        ; RPB_Memory Fast
        unsafeRpbMemoryTimes                = RPB_Fast_Nested(nestingDepth)
        unsafeRpbObjectCreationTime         = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Creation")
        unsafeRpbObjectReadTime             = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Read")
        unsafeRpbObjectWriteTime            = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Write")
        unsafeRpbObjectDeleteTime           = RPB_Memory.FastMap_GetFloat(unsafeRpbMemoryTimes, "Object Delete")
        unsafeRpbObjectVerifyRead           = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Read")
        unsafeRpbObjectVerifyCreate         = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Create")
        unsafeRpbObject                     = RPB_Memory.FastMap_GetObject(unsafeRpbMemoryTimes, "Object")
        unsafeRpbHasValidCreateIntegrity    = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Create: Integrity") as bool
        unsafeRpbHasValidReadIntegrity      = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Read: Integrity") as bool
        unsafeRpbHasValidDeleteIntegrity    = RPB_Memory.FastMap_GetInt(unsafeRpbMemoryTimes, "Object Verify Delete: Integrity") as bool

        log("Object Nested Performance (Nesting Depth: "+ nestingDepth +") \n"+ \ 
            "[UNIT LOG] \tJContainers: \n" + \ 
                "[UNIT LOG] \t - Creation: "+ (jcObjectCreationTime as int) +" ms ("+ FormatFloat(jcObjectCreationTime as float / nestingDepth) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Read: "+ (jcObjectReadTime as int) +" ms ("+ FormatFloat(jcObjectReadTime as float / nestingDepth) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Write: "+ (jcObjectWriteTime as int) +" ms ("+ FormatFloat(jcObjectWriteTime as float / nestingDepth) +" ms per object)\n" + \
                "[UNIT LOG] \t - Delete: "+ (jcObjectDeleteTime as int) +" ms ("+ FormatFloat(jcObjectDeleteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Create: "+ (jcObjectVerifyCreate as int) +" ms ("+ FormatFloat(jcObjectVerifyCreate as float / nestingDepth) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Read: "+ (jcObjectVerifyRead as int) +" ms ("+ FormatFloat(jcObjectVerifyRead as float / nestingDepth) +" ms per object)\n\n" + \
            "[UNIT LOG] \tRPB_Memory: \n" + \ 
                "[UNIT LOG] \t - Creation: "+ (rpbObjectCreationTime as int) +" ms ("+ FormatFloat(rpbObjectCreationTime as float / nestingDepth) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Read: "+ (rpbObjectReadTime as int) +" ms ("+ FormatFloat(rpbObjectReadTime as float / nestingDepth) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Write: "+ (rpbObjectWriteTime as int) +" ms ("+ FormatFloat(rpbObjectWriteTime as float / nestingDepth) +" ms per object)\n" + \
                "[UNIT LOG] \t - Delete: "+ (rpbObjectDeleteTime as int) +" ms ("+ FormatFloat(rpbObjectDeleteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Create: "+ (rpbObjectVerifyCreate as int) +" ms ("+ FormatFloat(rpbObjectVerifyCreate as float / nestingDepth) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Read: "+ (rpbObjectVerifyRead as int) +" ms ("+ FormatFloat(rpbObjectVerifyRead as float / nestingDepth) +" ms per object)\n\n" + \
            "[UNIT LOG] \tRPB_Memory (Fast): \n" + \ 
                "[UNIT LOG] \t - Creation: "+ (unsafeRpbObjectCreationTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectCreationTime as float / nestingDepth) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Read: "+ (unsafeRpbObjectReadTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectReadTime as float / nestingDepth) +" ms per object)\n" + \ 
                "[UNIT LOG] \t - Write: "+ (unsafeRpbObjectWriteTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectWriteTime as float / nestingDepth) +" ms per object)\n" + \
                "[UNIT LOG] \t - Delete: "+ (unsafeRpbObjectDeleteTime as int) +" ms ("+ FormatFloat(unsafeRpbObjectDeleteTime as float / totalObjects) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Create: "+ (unsafeRpbObjectVerifyCreate as int) +" ms ("+ FormatFloat(unsafeRpbObjectVerifyCreate as float / nestingDepth) +" ms per object)\n" + \
                "[UNIT LOG] \t - Verify Read: "+ (unsafeRpbObjectVerifyRead as int) +" ms ("+ FormatFloat(unsafeRpbObjectVerifyRead as float / nestingDepth) +" ms per object)\n\n" \
        )

        display_step("JContainers -> Create Integrity", jcHasValidCreateIntegrity)
        display_step("JContainers -> Read Integrity", jcHasValidReadIntegrity)
        display_step("JContainers -> Delete Integrity", jcHasValidDeleteIntegrity)

        display_step("RPB_Memory -> Create Integrity", rpbHasValidCreateIntegrity)
        display_step("RPB_Memory -> Read Integrity", rpbHasValidReadIntegrity)
        display_step("RPB_Memory -> Delete Integrity", rpbHasValidDeleteIntegrity)

        display_step("RPB_Memory (Fast) -> Create Integrity", unsafeRpbHasValidCreateIntegrity)
        display_step("RPB_Memory (Fast) -> Read Integrity", unsafeRpbHasValidReadIntegrity)
        display_step("RPB_Memory (Fast) -> Delete Integrity", unsafeRpbHasValidDeleteIntegrity)
        debug.trace("\n")

        ; log("(Object) RPB_Memory -> " + GetContainerList(rpbObject))
    endFunction
endState

int function JC_Flat(int parentContainer, int object, int objectCount)
    float startTime
    float endTime
    bool hasIntegrity = true
    int benchmarks = JMap.object()
    int totalObjects = objectCount

    startTime = Utility.GetCurrentRealTime()
    ; Object Creation
    while (objectCount > 0)
        int obj = object
        JMap.setObj(parentContainer, "obj:" + objectCount, obj)
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Creation", ((endTime - startTime) * 1000))


    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    ; Object Write
    while (objectCount > 0)
        JMap.setStr(parentContainer, "Key:" + objectCount, "Gatinha Cheia de Metropolitanas")
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Write", ((endTime - startTime) * 1000))


    objectCount = totalObjects
    startTime = Utility.GetCurrentRealTime()
    ; Object Read
    while (objectCount > 0)
        JMap.getStr(parentContainer, "Key:" + objectCount)
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Read", ((endTime - startTime) * 1000))

    ; Object Verify Create
    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    while (objectCount > 0)
        bool hasKey = JMap.hasKey(parentContainer, "obj:" + objectCount)
        if (!hasKey)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Verify Create", ((endTime - startTime) * 1000))
    JMap.setInt(benchmarks, "Object Verify Create: Integrity", hasIntegrity as int)

    ; Object Verify Read
    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    while (objectCount > 0)
        bool contentsMatch = JMap.getStr(parentContainer, "Key:" + objectCount) == "Gatinha Cheia de Metropolitanas"
        if (!contentsMatch)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Verify Read", ((endTime - startTime) * 1000))
    JMap.setInt(benchmarks, "Object Verify Read: Integrity", hasIntegrity as int)

    ; Object Delete
    objectCount = totalObjects
    startTime = Utility.GetCurrentRealTime()
    hasIntegrity = true
    while (objectCount > 0)
        hasIntegrity = JMap.removeKey(parentContainer, "Key:" + objectCount)
        if (!hasIntegrity)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Delete", ((endTime - startTime) * 1000))
    JMap.setInt(benchmarks, "Object Verify Delete: Integrity", hasIntegrity as int)


    return benchmarks
endFunction

int function RPB_Flat(int parentContainer, int object, int objectCount)
    float startTime
    float endTime
    bool hasIntegrity = true
    int benchmarks = RPB_Memory.Map("<string>")
    int totalObjects = objectCount

    startTime = Utility.GetCurrentRealTime()
    ; Object Creation
    while (objectCount > 0)
        int obj = object
        RPB_Memory.Map_SetObject(parentContainer, "obj:" + objectCount, obj)
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Creation", ((endTime - startTime) * 1000))

    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    ; Object Write
    while (objectCount > 0)
        RPB_Memory.Map_SetString(parentContainer, "Key:" + objectCount, "Gatinha Cheia de Metropolitanas")
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Write", ((endTime - startTime) * 1000))

    objectCount = totalObjects
    startTime = Utility.GetCurrentRealTime()
    ; Object Read
    while (objectCount > 0)
        RPB_Memory.Map_GetString(parentContainer, "Key:" + objectCount)
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Read", ((endTime - startTime) * 1000))

    ; Object Verify Create
    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    while (objectCount > 0)
        bool hasKey = RPB_Memory.Map_HasKey(parentContainer, "obj:" + objectCount)
        if (!hasKey)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Verify Create", ((endTime - startTime) * 1000))
    RPB_Memory.Map_SetInt(benchmarks, "Object Verify Create: Integrity", hasIntegrity as int)

    ; Object Verify Read
    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    while (objectCount > 0)
        bool contentsMatch = RPB_Memory.Map_GetString(parentContainer, "Key:" + objectCount) == "Gatinha Cheia de Metropolitanas"
        if (!contentsMatch)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Verify Read", ((endTime - startTime) * 1000))
    RPB_Memory.Map_SetInt(benchmarks, "Object Verify Read: Integrity", hasIntegrity as int)

    ; Object Delete
    objectCount = totalObjects
    startTime = Utility.GetCurrentRealTime()
    hasIntegrity = true
    while (objectCount > 0)
        hasIntegrity = RPB_Memory.Map_RemoveKey(parentContainer, "Key:" + objectCount)
        if (!hasIntegrity)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Delete", ((endTime - startTime) * 1000))
    RPB_Memory.Map_SetInt(benchmarks, "Object Verify Delete: Integrity", hasIntegrity as int)

    return benchmarks
endFunction

int function JC_Nested(int nestingDepth)
    int rootContainer = JMap.object()
    int benchmarks = JMap.object()
    bool hasIntegrity = true

    ; Object Creation
    float startTime = Utility.GetCurrentRealTime()
    int currentContainer = rootContainer

    int i = 1
    while (i < nestingDepth)
        int newContainer = JMap.object()
        JMap.setObj(currentContainer, "Child:" + i, newContainer)
        currentContainer = newContainer
        i += 1
    endWhile
    float endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Creation", ((endTime - startTime) * 1000))

    ; Object Read
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer = JMap.getObj(currentContainer, "Child:" + i)
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Read", ((endTime - startTime) * 1000))

    ; Object Write
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer = JMap.getObj(currentContainer, "Child:"+ i)
        JMap.setInt(currentContainer, "TestKey", 100)
        i += 1
    endWhile

    JMap.setInt(currentContainer, "TestKey", 100)
    self.AddTestElementsToContainer(currentContainer, "JC")
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Write", ((endTime - startTime) * 1000))
    JMap.setObj(benchmarks, "Object", rootContainer)

    ; Object Verify Create
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        bool hasKey         = JMap.hasKey(currentContainer, "Child:" + i)
        currentContainer    = JMap.getObj(currentContainer, "Child:"+ i)

        if (!hasKey)
            hasIntegrity = false
        endif
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Verify Create", ((endTime - startTime) * 1000))
    JMap.setInt(benchmarks, "Object Verify Create: Integrity", hasIntegrity as int)

    ; Object Verify Read
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer   = JMap.getObj(currentContainer, "Child:"+ i)
        bool contentsMatch = JMap.getInt(currentContainer, "TestKey") == 100

        if (!contentsMatch)
            hasIntegrity = false
        endif
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Verify Read", ((endTime - startTime) * 1000))
    JMap.setInt(benchmarks, "Object Verify Read: Integrity", hasIntegrity as int)

    ; Object Delete
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    hasIntegrity = true
    i = 1
    while (i < nestingDepth)
        currentContainer = JMap.getObj(currentContainer, "Child:"+ i)
        hasIntegrity = JMap.removeKey(currentContainer, "TestKey")
        if (!hasIntegrity)
            hasIntegrity = false
        endif
        i += 1
    endWhile

    endTime = Utility.GetCurrentRealTime()
    JMap.setFlt(benchmarks, "Object Delete", ((endTime - startTime) * 1000))
    JMap.setInt(benchmarks, "Object Verify Delete: Integrity", hasIntegrity as int)

    return benchmarks
endFunction

int function RPB_Nested(int nestingDepth)
    int rootContainer = RPB_Memory.Map("<string>")
    int benchmarks = RPB_Memory.Map("<string>")
    bool hasIntegrity = true

    ; Object Creation
    float startTime = Utility.GetCurrentRealTime()
    int currentContainer = rootContainer

    int i = 1
    while (i < nestingDepth)
        int newContainer = RPB_Memory.Map("<string>")
        RPB_Memory.Map_SetObject(currentContainer, "Child:" + i, newContainer)
        currentContainer = newContainer
        i += 1
    endWhile
    float endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Creation", ((endTime - startTime) * 1000))

    ; Object Read
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer = RPB_Memory.Map_GetObject(currentContainer, "Child:" + i)
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Read", ((endTime - startTime) * 1000))

    ; Object Write
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer = RPB_Memory.Map_GetObject(currentContainer, "Child:"+ i)
        RPB_Memory.Map_SetInt(currentContainer, "TestKey", 100)
        i += 1
    endWhile

    RPB_Memory.Map_SetInt(currentContainer, "TestKey", 100)
    self.AddTestElementsToContainer(currentContainer, "RPB")
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Write", ((endTime - startTime) * 1000))

    RPB_Memory.Map_SetObject(benchmarks, "Object", rootContainer)

    ; Object Verify Create
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        bool hasKey         = RPB_Memory.Map_HasKey(currentContainer, "Child:" + i)
        currentContainer    = RPB_Memory.Map_GetObject(currentContainer, "Child:"+ i)

        if (!hasKey)
            hasIntegrity = false
        endif
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Verify Create", ((endTime - startTime) * 1000))
    RPB_Memory.Map_SetInt(benchmarks, "Object Verify Create: Integrity", hasIntegrity as int)

    ; Object Verify Read
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer   = RPB_Memory.Map_GetObject(currentContainer, "Child:"+ i)
        bool contentsMatch = RPB_Memory.Map_GetInt(currentContainer, "TestKey") == 100

        if (!contentsMatch)
            hasIntegrity = false
        endif
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Verify Read", ((endTime - startTime) * 1000))
    RPB_Memory.Map_SetInt(benchmarks, "Object Verify Read: Integrity", hasIntegrity as int)

    ; Object Delete
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    hasIntegrity = true
    i = 1
    while (i < nestingDepth)
        currentContainer = RPB_Memory.Map_GetObject(currentContainer, "Child:" + i)
        hasIntegrity = RPB_Memory.Map_RemoveKey(currentContainer, "TestKey")
        if (!hasIntegrity)
            hasIntegrity = false
        endif
        i += 1
    endWhile

    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.Map_SetFloat(benchmarks, "Object Delete", ((endTime - startTime) * 1000))
    RPB_Memory.Map_SetInt(benchmarks, "Object Verify Delete: Integrity", hasIntegrity as int)

    return benchmarks
endFunction

int function RPB_Fast_Flat(int parentContainer, int object, int objectCount)
    float startTime
    float endTime
    bool hasIntegrity = true
    int benchmarks = RPB_Memory.FastMap("<string>")
    int totalObjects = objectCount

    startTime = Utility.GetCurrentRealTime()
    ; Object Creation
    while (objectCount > 0)
        int obj = object
        RPB_Memory.FastMap_SetObject(parentContainer, "obj:" + objectCount, obj)
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Creation", ((endTime - startTime) * 1000))

    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    ; Object Write
    while (objectCount > 0)
        RPB_Memory.FastMap_SetString(parentContainer, "Key:" + objectCount, "Gatinha Cheia de Metropolitanas")
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Write", ((endTime - startTime) * 1000))

    objectCount = totalObjects
    startTime = Utility.GetCurrentRealTime()
    ; Object Read
    while (objectCount > 0)
        RPB_Memory.FastMap_GetString(parentContainer, "Key:" + objectCount)
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Read", ((endTime - startTime) * 1000))

    ; Object Verify Create
    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    while (objectCount > 0)
        bool hasKey = RPB_Memory.FastMap_HasKey(parentContainer, "obj:" + objectCount)
        if (!hasKey)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Verify Create", ((endTime - startTime) * 1000))
    RPB_Memory.FastMap_SetInt(benchmarks, "Object Verify Create: Integrity", hasIntegrity as int)

    ; Object Verify Read
    objectCount = totalObjects
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    while (objectCount > 0)
        bool contentsMatch = RPB_Memory.FastMap_GetString(parentContainer, "Key:" + objectCount) == "Gatinha Cheia de Metropolitanas"
        if (!contentsMatch)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Verify Read", ((endTime - startTime) * 1000))
    RPB_Memory.FastMap_SetInt(benchmarks, "Object Verify Read: Integrity", hasIntegrity as int)

    ; Object Delete
    objectCount = totalObjects
    startTime = Utility.GetCurrentRealTime()
    hasIntegrity = true
    while (objectCount > 0)
        hasIntegrity = RPB_Memory.FastMap_RemoveKey(parentContainer, "Key:" + objectCount)
        if (!hasIntegrity)
            hasIntegrity = false
        endif
        objectCount -= 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Delete", ((endTime - startTime) * 1000))
    RPB_Memory.FastMap_SetInt(benchmarks, "Object Verify Delete: Integrity", hasIntegrity as int)

    return benchmarks
endFunction

int function RPB_Fast_Nested(int nestingDepth)
    int rootContainer = RPB_Memory.FastMap("<string>")
    int benchmarks = RPB_Memory.FastMap("<string>")
    bool hasIntegrity = true

    ; Object Creation
    float startTime = Utility.GetCurrentRealTime()
    int currentContainer = rootContainer

    int i = 1
    while (i < nestingDepth)
        int newContainer = RPB_Memory.FastMap("<string>")
        RPB_Memory.FastMap_SetObject(currentContainer, "Child:" + i, newContainer)
        currentContainer = newContainer
        i += 1
    endWhile
    float endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Creation", ((endTime - startTime) * 1000))

    ; Object Read
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer = RPB_Memory.FastMap_GetObject(currentContainer, "Child:" + i)
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Read", ((endTime - startTime) * 1000))

    ; Object Write
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer = RPB_Memory.FastMap_GetObject(currentContainer, "Child:"+ i)
        RPB_Memory.FastMap_SetInt(currentContainer, "TestKey", 100)
        i += 1
    endWhile

    RPB_Memory.FastMap_SetInt(currentContainer, "TestKey", 100)
    self.AddTestElementsToContainer(currentContainer, "RPB_Fast")
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Write", ((endTime - startTime) * 1000))

    RPB_Memory.FastMap_SetObject(benchmarks, "Object", rootContainer)

    ; Object Verify Create
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        bool hasKey         = RPB_Memory.FastMap_HasKey(currentContainer, "Child:" + i)
        currentContainer    = RPB_Memory.FastMap_GetObject(currentContainer, "Child:"+ i)

        if (!hasKey)
            hasIntegrity = false
        endif
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Verify Create", ((endTime - startTime) * 1000))
    RPB_Memory.FastMap_SetInt(benchmarks, "Object Verify Create: Integrity", hasIntegrity as int)

    ; Object Verify Read
    hasIntegrity = true
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    i = 1
    while (i < nestingDepth)
        currentContainer   = RPB_Memory.FastMap_GetObject(currentContainer, "Child:"+ i)
        bool contentsMatch = RPB_Memory.FastMap_GetInt(currentContainer, "TestKey") == 100

        if (!contentsMatch)
            hasIntegrity = false
        endif
        i += 1
    endWhile
    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Verify Read", ((endTime - startTime) * 1000))
    RPB_Memory.FastMap_SetInt(benchmarks, "Object Verify Read: Integrity", hasIntegrity as int)

    ; Object Delete
    startTime = Utility.GetCurrentRealTime()
    currentContainer = rootContainer
    hasIntegrity = true
    i = 1
    while (i < nestingDepth)
        currentContainer = RPB_Memory.FastMap_GetObject(currentContainer, "Child:" + i)
        hasIntegrity = RPB_Memory.FastMap_RemoveKey(currentContainer, "TestKey")
        if (!hasIntegrity)
            hasIntegrity = false
        endif
        i += 1
    endWhile

    endTime = Utility.GetCurrentRealTime()
    RPB_Memory.FastMap_SetFloat(benchmarks, "Object Delete", ((endTime - startTime) * 1000))
    RPB_Memory.FastMap_SetInt(benchmarks, "Object Verify Delete: Integrity", hasIntegrity as int)

    return benchmarks
endFunction

function AddTestElementsToContainer(int parentObject, string library = "RPB")
    if (library == "JC")
        JMap.setStr(parentObject, "Deleveling::Heavy Armor", "Deleveling::Heavy Armor")
        JMap.setStr(parentObject, "Deleveling::Light Armor", "Deleveling::Light Armor")
        JMap.setStr(parentObject, "Deleveling::Sneak", "Deleveling::Sneak")
        JMap.setStr(parentObject, "Deleveling::One-Handed", "Deleveling::One-Handed")
        JMap.setStr(parentObject, "Deleveling::Two-Handed", "Deleveling::Two-Handed")
        JMap.setStr(parentObject, "Deleveling::Archery", "Deleveling::Archery")
        JMap.setStr(parentObject, "Deleveling::Block", "Deleveling::Block")
        JMap.setStr(parentObject, "Deleveling::Smithing", "Deleveling::Smithing")
        JMap.setStr(parentObject, "Deleveling::Speechcraft", "Deleveling::Speechcraft")
        JMap.setStr(parentObject, "Deleveling::Pickpocketing", "Deleveling::Pickpocketing")
        JMap.setStr(parentObject, "Deleveling::Lockpicking", "Deleveling::Lockpicking")
        JMap.setStr(parentObject, "Deleveling::Alteration", "Deleveling::Alteration")
        JMap.setStr(parentObject, "Deleveling::Conjuration", "Deleveling::Conjuration")
        JMap.setStr(parentObject, "Deleveling::Destruction", "Deleveling::Destruction")
        JMap.setStr(parentObject, "Deleveling::Illusion", "Deleveling::Illusion")
        JMap.setStr(parentObject, "Deleveling::Restoration", "Deleveling::Restoration")
        JMap.setStr(parentObject, "Deleveling::Enchanting", "Deleveling::Enchanting")
        JMap.setStr(parentObject, "Deleveling::Alchemy", "Deleveling::Alchemy")
        JMap.setStr(parentObject, "Level Caps::Heavy Armor", "Level Caps::Heavy Armor")
        JMap.setStr(parentObject, "Level Caps::Light Armor", "Level Caps::Light Armor")
        JMap.setStr(parentObject, "Level Caps::Sneak", "Level Caps::Sneak")
        JMap.setStr(parentObject, "Level Caps::One-Handed", "Level Caps::One-Handed")
        JMap.setStr(parentObject, "Level Caps::Two-Handed", "Level Caps::Two-Handed")
        JMap.setStr(parentObject, "Level Caps::Archery", "Level Caps::Archery")
        JMap.setStr(parentObject, "Level Caps::Block", "Level Caps::Block")
        JMap.setStr(parentObject, "Level Caps::Smithing", "Level Caps::Smithing")
        JMap.setStr(parentObject, "Level Caps::Speechcraft", "Level Caps::Speechcraft")
        JMap.setStr(parentObject, "Level Caps::Pickpocketing", "Level Caps::Pickpocketing")
        JMap.setStr(parentObject, "Level Caps::Lockpicking", "Level Caps::Lockpicking")
        JMap.setStr(parentObject, "Level Caps::Alteration", "Level Caps::Alteration")
        JMap.setStr(parentObject, "Level Caps::Conjuration", "Level Caps::Conjuration")
        JMap.setStr(parentObject, "Level Caps::Destruction", "Level Caps::Destruction")
        JMap.setStr(parentObject, "Level Caps::Illusion", "Level Caps::Illusion")
        JMap.setStr(parentObject, "Level Caps::Restoration", "Level Caps::Restoration")
        JMap.setStr(parentObject, "Level Caps::Enchanting", "Level Caps::Enchanting")
        JMap.setStr(parentObject, "Level Caps::Alchemy", "Level Caps::Alchemy")

    elseif (library == "RPB")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Heavy Armor", "Deleveling::Heavy Armor")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Light Armor", "Deleveling::Light Armor")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Sneak", "Deleveling::Sneak")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::One-Handed", "Deleveling::One-Handed")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Two-Handed", "Deleveling::Two-Handed")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Archery", "Deleveling::Archery")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Block", "Deleveling::Block")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Smithing", "Deleveling::Smithing")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Speechcraft", "Deleveling::Speechcraft")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Pickpocketing", "Deleveling::Pickpocketing")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Lockpicking", "Deleveling::Lockpicking")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Alteration", "Deleveling::Alteration")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Conjuration", "Deleveling::Conjuration")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Destruction", "Deleveling::Destruction")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Illusion", "Deleveling::Illusion")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Restoration", "Deleveling::Restoration")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Enchanting", "Deleveling::Enchanting")
        RPB_Memory.Map_SetString(parentObject, "Deleveling::Alchemy", "Deleveling::Alchemy")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Heavy Armor", "Level Caps::Heavy Armor")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Light Armor", "Level Caps::Light Armor")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Sneak", "Level Caps::Sneak")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::One-Handed", "Level Caps::One-Handed")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Two-Handed", "Level Caps::Two-Handed")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Archery", "Level Caps::Archery")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Block", "Level Caps::Block")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Smithing", "Level Caps::Smithing")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Speechcraft", "Level Caps::Speechcraft")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Pickpocketing", "Level Caps::Pickpocketing")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Lockpicking", "Level Caps::Lockpicking")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Alteration", "Level Caps::Alteration")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Conjuration", "Level Caps::Conjuration")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Destruction", "Level Caps::Destruction")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Illusion", "Level Caps::Illusion")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Restoration", "Level Caps::Restoration")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Enchanting", "Level Caps::Enchanting")
        RPB_Memory.Map_SetString(parentObject, "Level Caps::Alchemy", "Level Caps::Alchemy")

    elseif (library == "RPB_Fast")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Heavy Armor", "Deleveling::Heavy Armor")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Light Armor", "Deleveling::Light Armor")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Sneak", "Deleveling::Sneak")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::One-Handed", "Deleveling::One-Handed")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Two-Handed", "Deleveling::Two-Handed")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Archery", "Deleveling::Archery")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Block", "Deleveling::Block")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Smithing", "Deleveling::Smithing")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Speechcraft", "Deleveling::Speechcraft")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Pickpocketing", "Deleveling::Pickpocketing")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Lockpicking", "Deleveling::Lockpicking")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Alteration", "Deleveling::Alteration")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Conjuration", "Deleveling::Conjuration")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Destruction", "Deleveling::Destruction")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Illusion", "Deleveling::Illusion")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Restoration", "Deleveling::Restoration")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Enchanting", "Deleveling::Enchanting")
        RPB_Memory.FastMap_SetString(parentObject, "Deleveling::Alchemy", "Deleveling::Alchemy")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Heavy Armor", "Level Caps::Heavy Armor")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Light Armor", "Level Caps::Light Armor")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Sneak", "Level Caps::Sneak")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::One-Handed", "Level Caps::One-Handed")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Two-Handed", "Level Caps::Two-Handed")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Archery", "Level Caps::Archery")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Block", "Level Caps::Block")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Smithing", "Level Caps::Smithing")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Speechcraft", "Level Caps::Speechcraft")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Pickpocketing", "Level Caps::Pickpocketing")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Lockpicking", "Level Caps::Lockpicking")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Alteration", "Level Caps::Alteration")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Conjuration", "Level Caps::Conjuration")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Destruction", "Level Caps::Destruction")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Illusion", "Level Caps::Illusion")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Restoration", "Level Caps::Restoration")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Enchanting", "Level Caps::Enchanting")
        RPB_Memory.FastMap_SetString(parentObject, "Level Caps::Alchemy", "Level Caps::Alchemy")
    endif
endFunction

function ImprisonActor(RPB_Prison apPrison)
    Actor player = Game.GetFormEx(0x14) as Actor
    
    RPB_Prisoner prisonerRef = apPrison.MakePrisoner(player)
    prisonerRef.SetSentence(4)
    
    ; Set showable options
    prisonerRef.ShowReleaseTime          = true
    prisonerRef.ShowSentence             = true
    prisonerRef.ShowTimeServed           = true
    prisonerRef.ShowTimeLeftInSentence   = true
    prisonerRef.ShowBounty               = true

    prisonerRef.AssignCell()
    prisonerRef.MoveToCell()

    prisonerRef.OnSentenceSet(4, now())
endFunction


; ==========================================================
;                       Test Management
; ==========================================================

function Setup()
endFunction

function Teardown()
endFunction

; ----------------------------------------------------------
;   Shared temp-actor helpers for tests 22-26 (ActorList/ActiveMagicEffectContainer)
; ----------------------------------------------------------

Actor[] __testTempActors
int __testTempActorCount = 0

;/
    Spawns a disposable NPC (cloned from the same base the original tests already use -
    see e.g. Test_Imprison_Multiple_Actors) and tracks it so __TeardownAllTempActors()
    can clean it up afterward. Up to 10 per test - plenty for these.
/;
Actor function __SpawnTempActor()
    if (!__testTempActors)
        __testTempActors = new Actor[10]
    endif

    ActorBase npcBase = Game.GetFormEx(0x132A1) as ActorBase
    Actor player = Game.GetFormEx(0x14) as Actor
    ; Signature: ObjectReference.PlaceActorAtMe(ActorBase akActorToPlace, int aiLevelMod = 4,
    ; EncounterZone akZone = None) - only 3 params, no abForcePersist (that's PlaceAtMe, a
    ; different native, not this one). The "1" below is aiLevelMod (a level modifier), not an
    ; actor count - this call always places exactly one actor. An earlier attempt here to
    ; force reference persistence (as a guard against temporary-reference FormID recycling)
    ; assumed a param that doesn't exist on this native and was removed; turned out
    ; unnecessary anyway - the real fix for the 23/24/25 stalls was spacing successive
    ; registrations out with Utility.Wait(), not reference persistence.
    Actor temp = player.PlaceActorAtMe(npcBase, 1)

    __testTempActors[__testTempActorCount] = temp
    __testTempActorCount += 1

    return temp
endFunction

;/
    Fully unregisters every temp actor spawned this test from all three lists
    (Prisoner/Arrestee/Captor - a temp actor may only be in one, this just checks all
    three so a single helper works for every test above) and disables+deletes it, then
    resets tracking. Call from every test's Teardown() that used __SpawnTempActor().
/;
function __TeardownAllTempActors()
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
    RPB_Arrest arrest = RPB_API.GetArrest()

    int i = 0
    while (i < __testTempActorCount)
        Actor tempActor = __testTempActors[i]

        if (tempActor)
            RPB_Prisoner prisonerRef = solitudePrison.Prisoners.AtKey(tempActor)
            if (prisonerRef)
                solitudePrison.UnregisterPrisoner(prisonerRef)
            endif

            RPB_Arrestee arresteeRef = arrest.Arrestees.AtKey(tempActor)
            if (arresteeRef)
                arrest.UnregisterArrestee(arresteeRef)
            endif

            RPB_Captor captorRef = arrest.Captors.AtKey(tempActor)
            if (captorRef)
                arrest.UnregisterCaptor(captorRef, true)
            endif

            tempActor.Disable()
            tempActor.Delete()
        endif

        i += 1
    endWhile

    __testTempActors = none
    __testTempActorCount = 0
endFunction

bool function __KeysContain(string[] asKeys, string asTarget)
    int i = 0
    while (i < asKeys.Length)
        if (asKeys[i] == asTarget)
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

int testMap

;/ FastMap<int> - test display name -> 1, only present for tests NOT safe to auto-chain /;
int nonChainableMap

;/
    Registers a test under @asName (shown in the F1 list), running @asTestMethodName's state
    when selected.

    string  @asName: The display name shown in the F1 list.
    string  @asTestMethodName: The state to GotoState() into when this test runs.
    bool?   @abChainable: Whether RunAllTests() ("00 - Run All Tests") is allowed to run this
        test as part of a chained run. Defaults true; set false for tests confirmed unsafe to
        run back-to-back with others (destructive with no self-restore, a real Scene, or just
        too heavy for a routine chained run) - see KNOWN_ISSUES.md for why each one is marked.
/;
function AddTest(string asName, string asTestMethodName, bool abChainable = true)
    if (JValue.empty(testMap))
        testMap = JMap.object()
        JValue.retain(testMap)
    endif

    if (JValue.empty(nonChainableMap))
        nonChainableMap = JMap.object()
        JValue.retain(nonChainableMap)
    endif

    if (!abChainable)
        JMap.setInt(nonChainableMap, asName, 1)
    endif

    ; int testMethods = JMap.allValues(testMap)
    ; int currentTestIndex = 0
    
    ; while (currentTestIndex < JArray.count(testMethods))
    ;     string testMethod = JArray.getStr(testMethods, currentTestIndex)
    ;     if (asTestMethodName == testMethod)
    ;         ; Existing Test

    ;     endif
    ;     currentTestIndex += 1
    ; endWhile
    
    ; if (JValue.count(testMap) == 0)
        ; int testCount       = JValue.count(testMap)
        ; string testIndex    = string_if (testCount < 10, "0" + (testCount), (testCount))
        ; string testName     = testIndex + " - " + asName

        ; log("testCount: " + testCount + ", testIndex: " + testIndex + ", testName: " + testName)

        JMap.setStr(testMap, asName, asTestMethodName)
        RPB_StorageVars.SetStringOnReference(asName, self, asTestMethodName)
    ; endif
endFunction

event OnInit()
    testMap = JMap.object()
    JValue.retain(testMap)

    nonChainableMap = JMap.object()
    JValue.retain(nonChainableMap)
endEvent

string[] function GetTestNames()
    self.SetTests()
    ; return RPB_StorageVars.GetStringsOnForm()
    return JMap.allKeysPArray(testMap)
endFunction

bool function IsTestChainable(string asTestName)
    return !JMap.hasKey(nonChainableMap, asTestName)
endFunction

string[] function GetTestMethodNames()
    return JArray.asStringArray(JMap.allValues(testMap))
endFunction

string function GetTest(string asTestName)
    return RPB_StorageVars.GetStringOnReference(asTestName, self)
    return JMap.getStr(testMap, asTestName)
endFunction

string function GetCurrentTest()
    return self.GetState()
endFunction

function ExecuteTest(string asTestKeyName)
    string testToExecute = self.GetTest(asTestKeyName)

    if (testToExecute == "__RUN_ALL__")
        self.RunAllTests()
        return
    endif

    if (testToExecute != "")
        ; Silence logs - DEBUG was previously commented out here (its restore line below
        ; wasn't), so production DEBUG:-prefixed logging was never actually silenced during
        ; a test run. Mirrors the already-working TRACE/LOG pattern now.
        SetLoggingEnabled("TRACE",  IsTracingEnabled()   && ENABLE_TRACING)
        SetLoggingEnabled("DEBUG",  IsDebuggingEnabled() && ENABLE_DEBUGGING)
        SetLoggingEnabled("LOG",    IsLoggingEnabled()   && ENABLE_LOGGING)

        start_test(testToExecute)   ; Log test start
        GotoState(testToExecute)
        Setup()
        Teardown()
        GotoState("")

        ; Return logs
        SetLoggingEnabled("TRACE",  IsTracingEnabled()   || !ENABLE_TRACING)
        SetLoggingEnabled("DEBUG",  IsDebuggingEnabled() || !ENABLE_DEBUGGING)
        SetLoggingEnabled("LOG",    IsLoggingEnabled()   || !ENABLE_LOGGING)
    endif
endFunction

;/
    Runs every registered CHAINABLE test back-to-back (skipping "00 - No Test", this entry
    itself, and anything registered non-chainable via AddTest's abChainable param - see
    KNOWN_ISSUES.md for why each one is marked) and reports one aggregated
    pass/fail/no-result/skipped summary, instead of having to read Papyrus.0.log one test
    at a time. Relies on __lastResultState, which display_result() sets and start_test()
    resets to "not recorded" before each test - so a test that never calls display_result()
    (several of the original 21 don't) is counted separately as "no result", not silently
    miscounted as a pass or fail.
/;
function RunAllTests()
    string[] testNames = self.GetTestNames()

    int passed = 0
    int failed = 0
    int noResult = 0
    int skipped = 0
    string failedNames = ""
    string noResultNames = ""
    string skippedNames = ""

    int i = 0
    while (i < testNames.Length)
        string testName = testNames[i]
        string stateName = self.GetTest(testName)

        if (stateName != "" && stateName != "__RUN_ALL__")
            if (!self.IsTestChainable(testName))
                skipped += 1
                skippedNames += testName + "; "
            else
                SetLoggingEnabled("TRACE",  IsTracingEnabled()   && ENABLE_TRACING)
                SetLoggingEnabled("DEBUG",  IsDebuggingEnabled() && ENABLE_DEBUGGING)
                SetLoggingEnabled("LOG",    IsLoggingEnabled()   && ENABLE_LOGGING)

                start_test(stateName)
                GotoState(stateName)
                Setup()
                Teardown()
                GotoState("")

                SetLoggingEnabled("TRACE",  IsTracingEnabled()   || !ENABLE_TRACING)
                SetLoggingEnabled("DEBUG",  IsDebuggingEnabled() || !ENABLE_DEBUGGING)
                SetLoggingEnabled("LOG",    IsLoggingEnabled()   || !ENABLE_LOGGING)

                if (__lastResultState == 1)
                    passed += 1
                elseif (__lastResultState == 0)
                    failed += 1
                    failedNames += testName + "; "
                else
                    noResult += 1
                    noResultNames += testName + "; "
                endif
            endif
        endif

        i += 1
    endWhile

    string summary = "Tests: " + passed + " passed, " + failed + " failed, " + noResult + " no-result, " + skipped + " skipped (of " + (passed + failed + noResult + skipped) + ")"
    if (failed > 0)
        summary += "\nFailed: " + failedNames
    endif
    summary += "\nSkipped (not chainable, run individually): " + skippedNames

    base_log("[UNIT SUMMARY]", summary + "\nNo result: " + noResultNames, "Tests::RunAll")
    ; Notification, not MessageBox - a modal popup at the end of a chained run (on top of the
    ; one that would've fired per-test below) is exactly the kind of thing DISPLAY_RESULT_IN_GAME
    ; was originally turned off to avoid. The full summary is always in the log either way.
    Debug.Notification("Tests: " + passed + " passed, " + failed + " failed, " + noResult + " no-result, " + skipped + " skipped")
endFunction


float __testStartTime
int __lastResultState = -1 ; -1 = not recorded yet, 0 = last display_result() was a fail, 1 = pass
function start_test(string testName = "")
    __testStartTime = Utility.GetCurrentRealTime()
    __lastResultState = -1
    base_log("[UNIT]", "Starting Test: " + testName, "Tests::" + testName)
endFunction

function begin_step(string stepName, string msg = "")
    base_log("[UNIT STEP] (START) " + stepName + " @", msg, "Tests::" + self.GetCurrentTest())
endFunction

function end_step(string stepName, bool condition, string additionalInfoOnFail = "")
    string testResult = string_if (condition, stepName + " Passed!", stepName + " Failed!" + " ("+ additionalInfoOnFail +")")
    base_log("[UNIT STEP] " + string_if (condition, "(PASS)", "(FAIL)") + " " + stepName + " @", testResult, "Tests::" + self.GetCurrentTest())

    ; Notification, not MessageBox - a modal popup per step is exactly what
    ; DISPLAY_RESULT_IN_GAME was originally turned off to avoid.
    if (DISPLAY_RESULT_IN_GAME)
        Debug.Notification(self.GetCurrentTest() + ": " + testResult)
    endif
endFunction

function display_step(string stepName, bool condition, string additionalInfoOnFail = "")
    string testResult = string_if (condition, stepName + " Passed!", stepName + " Failed!" + " ("+ additionalInfoOnFail +")")
    base_log("[UNIT STEP] " + string_if (condition, "(PASS)", "(FAIL)"), testResult, "Tests::" + self.GetCurrentTest())

    if (DISPLAY_RESULT_IN_GAME)
        Debug.Notification(self.GetCurrentTest() + ": " + testResult)
    endif
endFunction

function display_result(bool condition, bool showTimeElapsed = true)
    string testResult = ""
    if (showTimeElapsed)
        float testEndTime = Utility.GetCurrentRealTime()
        int elapsedTime = ((testEndTime - __testStartTime) * 1000) as int
        testResult = string_if (condition, "Test Passed!", "Test Failed!") + " (execution took "+ elapsedTime +" ms)"
    else
        testResult = string_if (condition, "Test Passed!", "Test Failed!")
    endif
    
    base_log("[UNIT RESULT] " + string_if (condition, "(PASS)", "(FAIL)"), testResult, "Tests::" + self.GetCurrentTest())

    ; Notification (auto-fading, no dismissal needed), not MessageBox (modal) - one popup per
    ; test in a chained "00 - Run All Tests" run is exactly what DISPLAY_RESULT_IN_GAME was
    ; originally turned off to avoid. Prefixed with the test name so it's identifiable on its
    ; own when several fire in sequence; the full detail is always in the log either way.
    if (DISPLAY_RESULT_IN_GAME)
        Debug.Notification(self.GetCurrentTest() + ": " + testResult)
    endif

    __lastResultState = int_if(condition, 1, 0)
    __testStartTime = 0
endFunction

;/
    Guard-assertion convention: assert_true()/assert_equals()/etc. only log and return a
    bool - they can't unwind Setup() on their own (Papyrus has no exceptions). For a
    precondition a later line depends on (e.g. "this reference isn't None"), guard it
    explicitly instead of letting a bad assumption become a raw None-dereference crash
    a few lines later:

        if (!assert_true(prisonerRef != none, "AwaitPrisonerReference returned None"))
            display_result(false)
            return
        endif

    Not retrofitted onto the original 21 tests - applied going forward, see tests 22-26
    below for worked examples.
/;
bool function assert_true(bool condition, string failMessage = "")
    if (!condition)
        base_log("[ASSERT]", "Assertion Failed: " + failMessage, "Tests::" + self.GetCurrentTest())
        if (DISPLAY_ASSERT_IN_GAME)
            Debug.MessageBox("Assertion Failed: " + failMessage)
        endif
    endif

    return condition
endFunction

bool function assert_false(bool condition, string failMessage = "")
    return assert_true(!condition, failMessage)
endFunction

bool function assert_equals(string expectedValue, string gottenValue, string failMessage = "", bool showResult = false)
    bool passed = gottenValue == expectedValue
    if (!passed)
        base_log("[ASSERT]", "Assertion Failed: " + failMessage + " (Expected: " + expectedValue + ", Got: " + gottenValue + ")", "Tests::" + self.GetCurrentTest())
        if (DISPLAY_ASSERT_IN_GAME)
            Debug.MessageBox("Assertion Failed: " + failMessage)
        endif
    endif
    
    if (showResult)
        base_log("[UNIT STEP]", string_if (passed, "[PASS]", "[FAIL]") + " Expected: " + expectedValue + ", Got: " + gottenValue, "Tests::" + self.GetCurrentTest())
    endif

    return passed
endFunction

bool function assert_not_equals(string expectedValue, string gottenValue, string failMessage = "", bool showResult = false)
    bool passed = gottenValue != expectedValue
    if (!passed)
        base_log("[ASSERT]", "Assertion Failed: " + failMessage + " (Expected: " + expectedValue + ", Got: " + gottenValue + ")", "Tests::" + self.GetCurrentTest())
        if (DISPLAY_ASSERT_IN_GAME)
            Debug.MessageBox("Assertion Failed: " + failMessage)
        endif
    endif

    if (showResult)
        base_log("[UNIT STEP]", string_if (passed, "[PASS]", "[FAIL]") + " Expected: " + expectedValue + ", Got: " + gottenValue, "Tests::" + self.GetCurrentTest())
    endif

    return passed
endFunction

function log(string msg, bool condition = true)
    if (condition)
        base_log("[UNIT LOG]", msg, "Tests::" + self.GetCurrentTest())
    endif
endFunction


RPB_API __api
RPB_API property API
    RPB_API function get()
        if (__api)
            return __api
        endif

        __api = RPB_API.GetSelf()
        return __api
    endFunction
endProperty