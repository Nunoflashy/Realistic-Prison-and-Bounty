scriptname RPB_Tests extends ObjectReference hidden

import RPB_Utility

bool property ENABLE_TRACING            = false autoreadonly
bool property ENABLE_DEBUGGING          = false autoreadonly
bool property ENABLE_LOGGING            = false autoreadonly
bool property DISPLAY_ASSERT_IN_GAME    = false autoreadonly
bool property DISPLAY_RESULT_IN_GAME    = false autoreadonly

function SetTests()
    self.AddTest("00 - No Test", "")
    self.AddTest("01 - 25 Days after 26th Frostfall is 20th of Sun's Dusk", "Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk")
    self.AddTest("02 - Get Prison For Actor Globally", "Test_Can_Get_Prison_For_Actor_Globally")
    self.AddTest("03 - Imprison Actor without Arresting", "Test_Can_Imprison_Actor_Without_Arresting")
    self.AddTest("04 - Imprison Multiple Actors", "Test_Imprison_Multiple_Actors")
    self.AddTest("05 - Arrest and Imprison Multiple Actors with Scene", "Test_Arrest_And_Imprison_Multiple_Actors_With_Scene")
    self.AddTest("06 - Imprisonment In Cell Should Not Allow Overcrowding", "Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding")
    self.AddTest("07 - Imprison Player Without Arresting - Required Bounty", "Test_Imprison_Player_Without_Arresting_Required_Bounty")
    self.AddTest("08 - Can Add Prisoners to PrisonerList", "Test_Can_Add_Prisoners_To_PrisonerList")
    self.AddTest("09 - Unset Prisons", "Test_Unset_Prisons")
    self.AddTest("10 - Configure Prisons", "Test_Configure_Prisons")
    self.AddTest("11 - Arrest Selected NPC with Escort Scene", "Test_Arrest_Selected_NPC_Escort_Scene")
    self.AddTest("12 - Test ActiveMagicEffect List", "Test_ActiveMagicEffectList_Works_Correctly")
    self.AddTest("13 - Test Prisoner Has Bounty in Prison", "Test_PrisonerHasBountyInPrison")
    self.AddTest("14 - Test Prisoner Gets Correct Escape Penalty", "Test_PrisonerEscapeGetsCorrectPenalty")
    self.AddTest("15 - Test List Algorithms", "Test_ListAlgorithms")
    self.AddTest("16 - Test ActiveMagicEffectList Algorithms", "Test_ActiveMagicEffectListAlgorithms")
    self.AddTest("17 - Test New Serialization - Compare with Old", "Test_NewSerializationCompareWithOld")
    self.AddTest("18 - Test Prison Root Objects", "Test_PrisonRootObjects")
    self.AddTest("19 - Test JSON Conditions", "Test_JSONConditions")
    self.AddTest("20 - Test Data Structures", "Test_DataStructures")
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

        bool validPrisons = true
        int i = 0
        while (i < prisonManager.PrisonSlots)
            RPB_Prison holdPrison = prisonManager.GetPrison(config.Holds[i])
            bool validPrison = assert_true(holdPrison != none && holdPrison.Hold == config.Holds[i], holdPrison.Name + " from hold "+ config.Holds[i] +" is null")
            if (!validPrison)
                validPrisons = false
            endif
            i += 1
        endWhile

        ; Assert that this is Solitude Prison
        RPB_Prison solitudePrison = prisonManager.GetPrison("Haafingar")
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

state Test_ActiveMagicEffectList_Works_Correctly
    function Setup()
        RPB_ActiveMagicEffectContainer ameList = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        
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

state Test_ActiveMagicEffectListAlgorithms
    function Setup()
        SetLoggingEnabled("DEBUG",  true)
        SetLoggingEnabled("LOG",  true)
        ; Test list instance
        RPB_PrisonerList testList = API.PrisonManager.GetPrison("Haafingar").Prisoners
        testList.__string_add_at("Taarie", "Prisoner[104611]")
        testList.__string_add_at("Evette San", "Prisoner[104610]")
        testList.__string_add_at("Vivienne Onis", "Prisoner[104620]")
        testList.__string_add_at("Jala", "Prisoner[104623]")
        testList.__string_add_at("Sorex Vinius", "Prisoner[104627]")
        testList.__string_add_at("Lisette", "Prisoner[104637]")
        testList.__string_add_at("Greta", "Prisoner[104659]")
        testList.__string_add_at("Addvar", "Prisoner[104660]")
        testList.__string_add_at("Noster Eagle-Eye", "Prisoner[108087]")
        testList.__string_add_at("Priscilla", "Prisoner[108612]")
        testList.__string_add_at("Johanne", "Prisoner[109118]")

        int arrayLength = testList.__string_get_length()
        int[] indexes   = testList.__string_get_indexes()

        log("Array Length: " + arrayLength)
        log("Indexes: " + indexes)
        testList.__string_list_data()

        string element = testList.__string_remove_element("Prisoner[104659]") ; Greta
        log("element: " + element)
        
        testList.__string_remove_element("Prisoner[104620]")

        log("\nBefore Reindexing\n")
        ; int j = 0
        ; while (j < arrayLength)
        ;     string storedValue = testList.__string_get_value(j)
        ;     string elementKey = testList.__string_get_key_for_index(j)
        ;     log("data["+j+"]: " + storedValue + " (Key: "+ elementKey +")")
        ;     j += 1
        ; endWhile

        log("\nAfter Reindexing\n")
        testList.__string_reindex_data()
        testList.__string_sort_data()

        ; Print out the results for verification
        arrayLength = testList.__string_get_length()
        int i = 0
        while (i < arrayLength)
            string element1 = testList.__string_get_value(i)
            string elementKey = testList.__string_get_key_for_index(i)
            int indexForKey = testList.__string_get_index_for_key(elementKey)
            Debug("Test Result", "Element at index " + i + ": " + element1 + " (key: " + elementKey + ", Index for Key: "+ indexForKey +")")
            i += 1
        endWhile

        ; Print out the JMap indices
        i = 0
        while (i < arrayLength)
            string elementKey = testList.__string_get_key_for_index(i)
            int index = testList.__string_get_index_for_key(elementKey)
            Debug("JMap", "Key: " + elementKey + ", Index: " + index)
            i += 1
        endWhile

        string addvarKey = "Prisoner[104660]"
        int addvarIndex = testList.__string_get_index_for_key(addvarKey)
        string addvar = testList.__string_get_value_by_key(addvarKey)
        bool addvarTestResult = assert_equals("Addvar", addvar, "Does not get the correct result after reindexing!")
        display_step("Addvar Test", addvarTestResult, "Key: "+ addvarKey +", Index: "+ addvarIndex +", Value: "+ addvar)

        log("Array Length: " + arrayLength)
        log("Indexes: " + testList.__string_get_indexes())

        display_result(addvarTestResult)

    endFunction

    function Teardown()
        RPB_PrisonerList testList = API.PrisonManager.GetPrison("Haafingar").Prisoners
        testList.__string_clear()
    endFunction
endState

state Test_NewSerializationCompareWithOld
    function Setup()
        RPB_Prison prison = API.PrisonManager.GetPrison("Haafingar")
        RPB_JailCell jailCell = Game.GetFormEx(0x36897) as RPB_JailCell ; 1st Jail Cell for this prison
        int cellsDataObject = prison.GetDataObject("Cells")

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

int testMap
function AddTest(string asName, string asTestMethodName)
    if (JValue.empty(testMap))
        testMap = JMap.object()
        JValue.retain(testMap)
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
        RPB_StorageVars.SetStringOnForm(asName, self, asTestMethodName)
    ; endif
endFunction

event OnInit()
    testMap = JMap.object()
    JValue.retain(testMap)
endEvent

string[] function GetTestNames()
    self.SetTests()
    ; return RPB_StorageVars.GetStringsOnForm()
    return JMap.allKeysPArray(testMap)
endFunction

string[] function GetTestMethodNames()
    return JArray.asStringArray(JMap.allValues(testMap))
endFunction

string function GetTest(string asTestName)
    return RPB_StorageVars.GetStringOnForm(asTestName, self)
    return JMap.getStr(testMap, asTestName)
endFunction

string function GetCurrentTest()
    return self.GetState()
endFunction

function ExecuteTest(string asTestKeyName)
    string testToExecute = self.GetTest(asTestKeyName)

    if (testToExecute != "")
        ; Silence logs
        SetLoggingEnabled("TRACE",  IsTracingEnabled()   && ENABLE_TRACING)
        ; SetLoggingEnabled("DEBUG",  IsDebuggingEnabled() && ENABLE_DEBUGGING)
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


float __testStartTime
function start_test(string testName = "")
    __testStartTime = Utility.GetCurrentRealTime()
    base_log("[UNIT]", "Starting Test: " + testName, "Tests::" + testName)
endFunction

function begin_step(string stepName, string msg = "")
    base_log("[UNIT STEP] (START) " + stepName + " @", msg, "Tests::" + self.GetCurrentTest())
endFunction

function end_step(string stepName, bool condition, string additionalInfoOnFail = "")
    string testResult = string_if (condition, stepName + " Passed!", stepName + " Failed!" + " ("+ additionalInfoOnFail +")")
    base_log("[UNIT STEP] " + string_if (condition, "(PASS)", "(FAIL)") + " " + stepName + " @", testResult, "Tests::" + self.GetCurrentTest())

    if (DISPLAY_RESULT_IN_GAME)
        Debug.MessageBox(testResult)
    endif
endFunction

function display_step(string stepName, bool condition, string additionalInfoOnFail = "")
    string testResult = string_if (condition, stepName + " Passed!", stepName + " Failed!" + " ("+ additionalInfoOnFail +")")
    base_log("[UNIT STEP] " + string_if (condition, "(PASS)", "(FAIL)"), testResult, "Tests::" + self.GetCurrentTest())

    if (DISPLAY_RESULT_IN_GAME)
        Debug.MessageBox(testResult)
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

    if (DISPLAY_RESULT_IN_GAME)
        Debug.MessageBox(testResult)
    endif

    __testStartTime = 0
endFunction

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