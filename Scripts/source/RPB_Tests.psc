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

        RPB_Arrestee arrestee = (RPB_API.GetArrest()).MakeArrestee(testPrisoner)
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
        ;     RPB_Arrestee arresteeRef = arrest.MakeArrestee(playerCopy)
        ;     ; arrest.OnArrestBegin(arresteeRef, guard, guard.GetCrimeFaction(), arrest.ARREST_TYPE_ESCORT_TO_JAIL)
        ;     ; arrest.ArrestActor(guard, vivienne, arrest.ARREST_TYPE_ESCORT_TO_JAIL)
        ;     i += 1
        ; endWhile
        Actor playerCopy = player.PlaceActorAtMe(playerBase, 1)
        RPB_Arrestee playerCopyRef = arrest.MakeArrestee(playerCopy)
        RPB_Captor captorRef = arrest.MakeOrGetCaptor(guard)
    
        RPB_Arrestee arresteeRef = arrest.MakeArrestee(player)
        arrest.OnArrestBegin(arresteeRef, captorRef, guard.GetCrimeFaction(), arrest.ARREST_TYPE_ESCORT_TO_JAIL)
        RPB_Utility.BindAliasTo(RPB_API.GetSceneManager().GetEscortee(1), playerCopy)
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

        API.Config.SetPrisons()

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
            solitudePrison.ID == prisonManager.GetPrisonByID(solitudePrison.ID).ID && \
            solitudePrison.Hold == "Haafingar", \ 
            "This is not Solitude Prison" \
        )

        display_result(validPrisons && isSolitudePrison)
    endFunction
endState

state Test_Unset_Prisons
    function Setup()
        RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
        ; prisonManager.UninitializePrisons()

        int availablePrisonSlots = prisonManager.GetNumberOfAvailableSlots()
        log("(START) Number of Available Prison Slots: " + availablePrisonSlots)

        bool noPrisonsInitialized = true

        int i = 0
        while (i < prisonManager.PrisonSlots)
            RPB_Prison prison = prisonManager.GetPrisonByID(i)
            bool wasPrisonInitialized = prison.Initialized
            string prisonName = prison.Name
            prisonManager.UninitializePrisonByID(i)
            log("Unsetting Prison (ID "+ i +" ["+ prisonName +"]) | Unset: " + (!prison.Initialized), wasPrisonInitialized)
            bool prisonNotInitialized = assert_false(prison.Initialized, "The prison is initialized ("+ prisonName +")")
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
        RPB_Prisoner playerPrisonerRef  = castleDourDungeon.GetPrisoner(Game.GetForm(0x14) as Actor)

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

        RPB_Arrestee arrestee = (RPB_API.GetArrest()).MakeArrestee(testPrisoner)
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