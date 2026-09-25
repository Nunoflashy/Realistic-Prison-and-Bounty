scriptname RPB_Tests extends ObjectReference hidden

;/
@properties:
    bool ENABLE_TRACING
    bool ENABLE_DEBUGGING
    bool ENABLE_LOGGING
    bool DISPLAY_ASSERT_IN_GAME
    bool DISPLAY_RESULT_IN_GAME
    RPB_API API
@functions:
    function SetTests()
    function Setup()
    function Teardown()
    int function JC_Flat(int parentContainer, int object, int objectCount)
    int function RPB_Flat(int parentContainer, int object, int objectCount)
    int function JC_Nested(int nestingDepth)
    int function RPB_Nested(int nestingDepth)
    int function RPB_Fast_Flat(int parentContainer, int object, int objectCount)
    int function RPB_Fast_Nested(int nestingDepth)
    function AddTestElementsToContainer(int parentObject, string library = "RPB")
    function ImprisonActor(RPB_Prison apPrison)
    function AddTest(string asName, string asTestMethodName, bool abChainable = true)
    string[] function GetTestNames()
    bool function IsTestChainable(string asTestName)
    string[] function GetTestMethodNames()
    string function GetTest(string asTestName)
    string function GetCurrentTest()
    function ExecuteTest(string asTestKeyName)
    function RunAllTests()
    function start_test(string testName = "")
    function begin_step(string stepName, string msg = "")
    function end_step(string stepName, bool condition, string additionalInfoOnFail = "")
    function display_step(string stepName, bool condition, string additionalInfoOnFail = "")
    function display_result(bool condition, bool showTimeElapsed = true)
    bool function assert_true(bool condition, string failMessage = "")
    bool function assert_false(bool condition, string failMessage = "")
    bool function assert_equals(string expectedValue, string gottenValue, string failMessage = "", bool showResult = false)
    bool function assert_not_equals(string expectedValue, string gottenValue, string failMessage = "", bool showResult = false)
    function log(string msg, bool condition = true)
@events:
    event OnConcurrencyWorker(string asEventName, string asMode, float afWorkerIndex, Form akSender)
    event OnThreadLockProbeWorker(string asEventName, string asMode, float afWorkerIndex, Form akSender)
    event OnNativeProbeWorker(string asEventName, string asMode, float afWorker, Form akSender)
    event OnInit()
/;

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
    self.AddTest("000 - Run All Tests", "__RUN_ALL__")
    self.AddTest("000 - No Test", "")
    self.AddTest("001 - 25 Days after 26th Frostfall is 20th of Sun's Dusk", "Test_25Days_After_26th_Frostfall_Is_20th_Suns_Dusk")
    self.AddTest("002 - Get Prison For Actor Globally", "Test_Can_Get_Prison_For_Actor_Globally")
    self.AddTest("003 - Imprison Actor without Arresting", "Test_Can_Imprison_Actor_Without_Arresting")
    ; Not chainable: spawns 4 permanent NPCs with no cleanup - see KNOWN_ISSUES.md
    self.AddTest("004 - Imprison Multiple Actors", "Test_Imprison_Multiple_Actors", abChainable = false)
    ; Not chainable: a real arrest/escort Scene, not something to fire unattended in a chain
    self.AddTest("005 - Arrest and Imprison Multiple Actors with Scene", "Test_Arrest_And_Imprison_Multiple_Actors_With_Scene", abChainable = false)
    ; Not chainable: hangs when run as part of "00 - Run All Tests" - root cause not yet
    ; diagnosed (unlike 09's), mitigated here until there's evidence to chase further
    self.AddTest("006 - Imprisonment In Cell Should Not Allow Overcrowding", "Test_Imprisonment_In_Cell_Should_Not_Allow_Overcrowding", abChainable = false)
    self.AddTest("007 - Imprison Player Without Arresting - Required Bounty", "Test_Imprison_Player_Without_Arresting_Required_Bounty")
    self.AddTest("008 - Can Add Prisoners to PrisonerList", "Test_Can_Add_Prisoners_To_PrisonerList")
    ; Not chainable: unsets all prison slots with nothing in this suite to reconfigure them
    ; afterward (Test_Configure_Prisons' own reconfiguration call is dead) - see KNOWN_ISSUES.md
    self.AddTest("009 - Unset Prisons", "Test_Unset_Prisons", abChainable = false)
    self.AddTest("010 - Configure Prisons", "Test_Configure_Prisons")
    ; Not chainable: a real arrest/escort Scene, not something to fire unattended in a chain
    self.AddTest("011 - Arrest Selected NPC with Escort Scene", "Test_Arrest_Selected_NPC_Escort_Scene", abChainable = false)
    self.AddTest("012 - ActiveMagicEffectContainer: Page-Boundary Crossing", "Test_ActiveMagicEffectContainer_PageBoundary")
    ; Not chainable: stalls "00 - Run All Tests" with no log detail captured yet - root cause
    ; not diagnosed, mitigated here until there's evidence to chase further (same pattern as 06)
    self.AddTest("013 - Test Prisoner Has Bounty in Prison", "Test_PrisonerHasBountyInPrison", abChainable = false)
    self.AddTest("014 - Test Prisoner Gets Correct Escape Penalty", "Test_PrisonerEscapeGetsCorrectPenalty")
    self.AddTest("015 - Test List Algorithms", "Test_ListAlgorithms")
    self.AddTest("017 - Test New Serialization - Compare with Old", "Test_NewSerializationCompareWithOld")
    self.AddTest("018 - Test Prison Root Objects", "Test_PrisonRootObjects")
    self.AddTest("019 - Test JSON Conditions", "Test_JSONConditions")
    self.AddTest("020 - Test Data Structures", "Test_DataStructures")
    ; Not chainable: 1600 iterations, a benchmark not a correctness test - heavy for a routine chain
    self.AddTest("021 - Benchmark StorageVars", "Benchmark_StorageVars", abChainable = false)
    self.AddTest("022 - ActorList: Add and Retrieve (Prisoner/Arrestee/Captor)", "Test_ActorList_Add_And_Retrieve")
    self.AddTest("023 - ActorList: Multiple Adds and GetKeys()", "Test_ActorList_Multiple_And_GetKeys")
    self.AddTest("024 - ActorList: Remove and Reindex", "Test_ActorList_Remove_And_Reindex")
    self.AddTest("025 - ActiveMagicEffectContainer: Dense Packing After Interleaved Add/Remove", "Test_ActiveMagicEffectContainer_DensePacking")
    self.AddTest("026 - CaptorList: Remove Path (protected_remove)", "Test_CaptorList_Remove_Path")
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21
    self.AddTest("027 - Benchmark: Raw JMap vs RPB_Memory FastMap", "Benchmark_RawJMap_vs_FastMap", abChainable = false)
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27
    self.AddTest("028 - Benchmark: 32x32 vs 128x8 Page Dispatch at ~1000 Entries", "Benchmark_PageDispatch_32x32_vs_128x8", abChainable = false)
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27/28
    self.AddTest("029 - Benchmark: FindKeyForIndex Scan Cost at 150 Entries", "Benchmark_FindKeyForIndexScanCost", abChainable = false)
    self.AddTest("030 - ActiveMagicEffectContainer: Forward/Reverse Index Maps Stay In Sync", "Test_ActiveMagicEffectContainer_IndexMapsInSync")
    self.AddTest("031 - ActiveMagicEffectContainer: Reverse Map Rebuilds After Missing (Old-Save Migration)", "Test_ActiveMagicEffectContainer_ReverseMapMigration")
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27/28/29
    self.AddTest("032 - Benchmark: Scan-Based vs Reverse-Index Removal", "Benchmark_ScanVsReverseIndexRemoval", abChainable = false)
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27/28/29/32
    self.AddTest("033 - Benchmark: Container Per-Operation Overhead Breakdown", "Benchmark_ContainerOverheadBreakdown", abChainable = false)
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27/28/29/32/33
    self.AddTest("034 - Benchmark: Page Allocation/Free Cost", "Benchmark_PageAllocationCost", abChainable = false)
    ; Not chainable: a benchmark, not a correctness test - same treatment as 21/27/28/29/32/33/34
    self.AddTest("035 - Benchmark: Function Size vs Call Cost", "Benchmark_FunctionSizeCallCost", abChainable = false)
    ; Not chainable: fills the container to its full 1024-entry capacity, takes a while
    self.AddTest("036 - ActiveMagicEffectContainer: Full Capacity (All 32 Pages)", "Test_ActiveMagicEffectContainer_FullCapacity", abChainable = false)
    self.AddTest("037 - ActiveMagicEffectContainer: Real Payload Identity Through Swaps", "Test_ActiveMagicEffectContainer_PayloadIdentity")
    self.AddTest("038 - ActiveMagicEffectContainer: Duplicate and Missing Keys", "Test_ActiveMagicEffectContainer_DuplicateAndMissingKeys")
    ; Not chainable: fires concurrent worker threads at the live ArresteeList, must start empty
    self.AddTest("039 - ActiveMagicEffectContainer: Concurrent Access (8 Worker Threads)", "Test_ActiveMagicEffectContainer_ConcurrentAccess", abChainable = false)
    self.AddTest("040 - ActiveMagicEffectContainer: No Per-Operation JContainers Allocation", "Test_ActiveMagicEffectContainer_HandleStability")
    ; Await<T>Reference investigation (47-51): measure where the ~1.7s per await goes, how registration behaves with several
    ; actors at once, and what the effect start needs. All spawn real temp actors and can take a while, so not chainable.
    self.AddTest("047 - Await: Latency Breakdown (prisoner/arrestee/captor)", "Test_Await_LatencyBreakdown", abChainable = false)
    self.AddTest("048 - Await: Burst Registration Stress (prisoners, K=3/6/10)", "Test_Await_BurstPrisoners", abChainable = false)
    self.AddTest("049 - Await: Burst Arrestees/Captors and Spaced Prisoners (K=6)", "Test_Await_BurstOtherKinds", abChainable = false)
    self.AddTest("050 - Await: What the Effect Start Needs (settle / disabled)", "Test_Await_EffectStartPrerequisites", abChainable = false)
    self.AddTest("051 - Await: Group Flow, Sequential API vs Burst (N=5)", "Test_Await_GroupFlow", abChainable = false)
    self.AddTest("052 - Await: After the Fast-Polling / Unloaded-Actor / None-Safety Fixes", "Test_Await_AfterFixes", abChainable = false)
    self.AddTest("053 - Await: A Stale 'Initialized' Flag Blocks Prisoner Registration", "Test_Await_StaleInitializedFlag", abChainable = false)
    self.AddTest("054 - Prisoner.Initialize(): Per-Step Profile", "Test_Prisoner_InitializeProfile", abChainable = false)
    self.AddTest("055 - Prison: A Failed Imprisonment Cleans the Prisoner's State Up", "Test_Prison_ImprisonmentFailCleansUp", abChainable = false)
    self.AddTest("056 - LockPrisonerSettings: Per-Operation Cost Split (Reads vs Writes)", "Test_LockPrisonerSettings_CostSplit", abChainable = false)
    self.AddTest("057 - StorageVars: Cached Reference Key and Cached Hold Give Identical Data", "Test_StorageVars_CachedKeyEquivalence", abChainable = false)
    self.AddTest("058 - StorageVars: Deletes Work With the Cached Reference Key (Second Arrest Regression)", "Test_StorageVars_DeletesWithCachedKey", abChainable = false)
    self.AddTest("059 - Prison Settings Snapshot: Locking From the Snapshot Equals the Direct Way", "Test_SettingsSnapshot_EqualsDirect", abChainable = false)
    self.AddTest("060 - Prison Settings Snapshot: An MCM Change Invalidates It, Earlier Prisoners Keep Their Values", "Test_SettingsSnapshot_McmChange", abChainable = false)
    self.AddTest("061 - Prison Settings Snapshot: A Prisoner Gets the Snapshot's Data, Not a Recomputation", "Test_SettingsSnapshot_ComesFromSnapshot", abChainable = false)
    self.AddTest("062 - Prison Settings Snapshot: Per-Hold Versions (Another Hold Does Not Invalidate It)", "Test_SettingsSnapshot_PerHoldVersion", abChainable = false)
    self.AddTest("063 - Prisoner.DetermineStrippingType(): Cost Breakdown", "Test_Prisoner_StrippingTypeBreakdown", abChainable = false)
    self.AddTest("064 - Prisoner.DetermineStrippingType(): Decision Table and New Equals the Original", "Test_Prisoner_StrippingTypeEquivalence", abChainable = false)
    self.AddTest("065 - Utility.GetSlotMaskValue(): Closed Form Equals the Original Loop", "Test_Utility_SlotMaskEquivalence", abChainable = false)
    self.AddTest("066 - StorageVars: Cheaper Path/Key Building Equals the Original Byte for Byte", "Test_StorageVars_PathEquivalence", abChainable = false)
    self.AddTest("067 - Prisoner.StrippingThoroughness: Uses the Locked Setting (Bug Fix)", "Test_Prisoner_ThoroughnessUsesLockedSetting", abChainable = false)
    self.AddTest("068 - Prisoner.Name and Message Building: Cost Breakdown", "Test_Prisoner_NameCostBreakdown", abChainable = false)
    self.AddTest("069 - Native Call Census: Which Natives Cost a Frame", "Test_Natives_Census", abChainable = false)
    self.AddTest("070 - ActorBase.Name: Cached Name Equals the Native One", "Test_ActorBase_CachedName", abChainable = false)
    self.AddTest("071 - Utility.GetFormNameCached(): Equals Faction.GetName() and Makes Bounty Reads Cheap", "Test_Utility_FormNameCache", abChainable = false)
    self.AddTest("072 - Native Cost Probe: Distribution, Back-to-Back, and Parallel Stacks", "Test_Natives_Probe", abChainable = false)
    self.AddTest("073 - MCM: Every Option Default Exists Without Visiting an MCM Page (New Save)", "Test_MCM_DefaultsWithoutPageVisit", abChainable = false)
    self.AddTest("074 - MCM: Defaults Are Rebuilt After the Default Map Is Replaced (OnConfigInit Order)", "Test_MCM_DefaultsAfterMapReplaced", abChainable = false)
    self.AddTest("075 - Flow Profiler: Off Records Nothing, On Records and Reports", "Test_FlowProfiler", abChainable = false)
    self.AddTest("076 - Arrest Flow Stress: One Actor, Three Full Cycles (Arrest -> Imprison -> Release)", "Test_ArrestStress_SingleCycles", abChainable = false)
    self.AddTest("077 - Arrest Flow Stress: Concurrent Burst (N = 3, then 6) Arrested, Imprisoned and Released Together", "Test_ArrestStress_Burst", abChainable = false)
    self.AddTest("078 - Arrest Flow Stress: Staggered Arrests (N = 6, 0.3s apart, like ArrestActors) and Repeated Bursts", "Test_ArrestStress_Staggered", abChainable = false)
    self.AddTest("079 - Arrestee: InitializeState() Returns true for Every Caller (First-Caller Race)", "Test_Arrestee_InitializeStateReturnsTrue", abChainable = false)
    self.AddTest("080 - PrisonMonitor: Next Wake Schedule Maths (Lowest Sentence, Empty, Away, Served)", "Test_PrisonMonitor_ScheduleMaths", abChainable = false)
    self.AddTest("081 - PrisonMonitor: What an Away Prisoner Looks Like (Effect Gone, List Entry, Restore)", "Test_PrisonMonitor_AwayPrisoner", abChainable = false)
    self.AddTest("082 - PrisonMonitor: Foreground / Background Handoff State", "Test_PrisonMonitor_Handoff", abChainable = false)
    self.AddTest("083 - PrisonManager: Prisons-With-Prisoners Count Is Cheap and Matches a Slow Recount", "Test_PrisonManager_CountIsCheap", abChainable = false)
    self.AddTest("084 - PrisonMonitor: Releases an Away Prisoner Whose Sentence Is Served (Headless)", "Test_PrisonMonitor_HeadlessRelease", abChainable = false)
    self.AddTest("085 - Prisoner: Day Events Per Update Are Bounded (Extreme Elapsed Time)", "Test_Prisoner_DayEventBound", abChainable = false)
    self.AddTest("086 - PrisonMonitor: Release Queue Order, No Duplicates, One Per Wake (Dry Run)", "Test_PrisonMonitor_ReleaseQueue", abChainable = false)
    self.AddTest("087 - Time Skip: NPCs Are Released in Order, Each at Its Own Release Time (Dry Run, Passes Game Days)", "Test_Prison_ReleaseTimeline", abChainable = false)
    self.AddTest("088 - Prisoner: The NPC's Original Outfit and Underwear Survive the Effect Being Replaced", "Test_Prisoner_OutfitSurvivesInstanceReplacement", abChainable = false)
    self.AddTest("089 - Prisoner: Worn Armor Is Snapshotted Before Stripping and Re-equipped After Release (Guards Have No Outfit)", "Test_Prisoner_WornArmorRestored", abChainable = false)
    self.AddTest("090 - Time Skip: An NPC With the Same Sentence Imprisoned Earlier Is Released Before the Player (Dry Run)", "Test_Prison_EqualSentenceOrder", abChainable = false)
    self.AddTest("091 - Prisoner: Only the Prisoner's Own Belongings Are Returned From a Shared Container", "Test_Prisoner_OwnBelongingsReturned", abChainable = false)
    self.AddTest("092 - Mass Imprisonment: 45 NPCs In Waves Into a Full Prison (No Overcrowding), Overflow, Recovery, Mass Release", "Test_MassImprisonment", abChainable = false)
    self.AddTest("093 - Mass Time Skip: 40 Prisoners, Release Order and Cost (Dry Run, Passes ~10 Game Days)", "Test_TimeSkipManyPrisoners", abChainable = false)
    self.AddTest("094 - Mass Imprisonment With the Real Cell Data (Overcrowding As Configured): Package Pool Limit", "Test_MassImprisonmentRealData", abChainable = false)
    self.AddTest("095 - Console Probe: A Marker Before Each Read the Mass Tests Do at Their Start (Find the JContainers Warning)", "Test_ConsoleProbe", abChainable = false)
    self.AddTest("096 - Mass Imprisonment of Imperial Soldiers (0xBED96, Real Cell Data)", "Test_MassSoldiers", abChainable = false)
    self.AddTest("097 - Mass Imprisonment of Bandits (0x37BFF, Real Cell Data)", "Test_MassBandits", abChainable = false)
    self.AddTest("098 - Imperial Soldier Fodder Smoke Test: Can 0xE77F9 Be Imprisoned At All? (3 Clones)", "Test_MassSoldiersSmokeTest", abChainable = false)
    self.AddTest("099 - Hostile Prisoner: Neutralized While Imprisoned, Hostility Restored a While After Release", "Test_HostilePrisoner_NeutralizedThenRestored", abChainable = false)
    self.AddTest("100 - Hostile Player (Disguise Mod): Neutralized While Imprisoned, Hostility Restored a While After Release", "Test_HostilePlayer_NeutralizedThenRestored", abChainable = false)
    ; Not chainable: genuinely moves the player far away for real (no dev override exists for IsFarFromPlayer()),
    ; not something to fire unattended in a chain
    self.AddTest("101 - Multi-Prisoner Off-Screen Escort: AI Disabled and Correctly Placed for All of Them", "Test_MultiPrisonerOffScreenAIAndPlacement", abChainable = false)
    ; Not chainable: kills a real guard NPC, not something to fire unattended in a chain
    self.AddTest("102 - Captor Dies Mid-Arrest: Arrest Reverts Quickly Instead of the Old ~24s Stall", "Test_CaptorDeathRevertsArrestQuickly", abChainable = false)
    self.AddTest("041 - ActiveMagicEffectContainer: Stuck Lock Self-Heals", "Test_ActiveMagicEffectContainer_StuckLockSelfHeals")
    self.AddTest("042 - ThreadLock: JAtomic Primitive Semantics and Registry", "Test_ThreadLock_PrimitiveSemantics")
    ; Not chainable: fires concurrent worker threads
    self.AddTest("043 - ThreadLock: Mutual Exclusion Proof (control vs locked)", "Test_ThreadLock_MutualExclusion", abChainable = false)
    self.AddTest("044 - ThreadLock: Concurrent Registry Creation and Stuck-Lock Recovery", "Test_ThreadLock_RegistryAndStuckLock", abChainable = false)
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
        bool syncedAfterAdds = self.__AssertContainerInSync(_container, "after " + entriesToAdd + " adds across pages 0-4")

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
        bool syncedAfterCleanup = self.__AssertContainerInSync(_container, "after draining every page-boundary entry")

        display_result(countCorrect && syncedAfterAdds && crossedPage && removedCorrectly && goneKeyGone && cleanedUp && syncedAfterCleanup)
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

        ; Retained above for the timing loops only - release so repeated runs don't leave
        ; permanent objects behind in the save
        JValue.release(rawMap)
        FastMap_Release(fastMap)

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

        FastMap_Release(aKeyToIndex)
        FastMap_Release(bKeyToIndex)

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

        FastMap_Release(mapA)
        FastMap_Release(mapB)

        log("Scan-based: " + scanElapsed + " ms, Direct: " + directElapsed + " ms, scan cost: " + (scanElapsed - directElapsed) + " ms")
        Debug.Notification("Scan-based: " + scanElapsed + "ms, Direct: " + directElapsed + "ms, scan cost: " + (scanElapsed - directElapsed) + "ms")

        display_result(true, showTimeElapsed = false)
    endFunction
endState

; ==========================================================
;   ActiveMagicEffectContainer: forward/reverse index map tests
;
;   RPB_ActiveMagicEffectContainer keeps a key -> index map and its mirror, index -> key, so
;   RemoveElement()'s swap step is O(1). These tests prove the two never drift apart, using
;   the container's own ValidateIndexConsistency() (Count vs both map sizes, every key round-
;   tripping through both maps, every index in [0, Count) owned by exactly one key) plus
;   independent checks through the public API. All of them use cheap synthetic keys and a None
;   payload on the real, live ArresteeList container and remove everything they add.
; ==========================================================

;/
    Asserts the container's forward and reverse maps are consistent right now. @asStage only
    labels the failure message so a failing run says WHERE the maps first diverged.
/;
bool function __AssertContainerInSync(RPB_ActiveMagicEffectContainer apContainer, string asStage)
    string problem = apContainer.ValidateIndexConsistency()
    return assert_true(problem == "", "Index maps out of sync " + asStage + ": " + problem)
endFunction

;/
    Compares the container against a shadow model of what should be present: @abPresent[i] says
    whether key (@asKeyPrefix + i) should currently exist. Checks every key's HasKey() result
    and that Count equals the baseline plus the number expected present.
/;
bool function __ContainerMatchesShadow(RPB_ActiveMagicEffectContainer apContainer, bool[] abPresent, string asKeyPrefix, int aiStartCount, string asStage)
    int expectedPresent = 0
    int mismatches = 0
    bool isPresent = false
    string firstMismatch = ""

    int i = 0
    while (i < abPresent.Length)
        isPresent = apContainer.HasKey(asKeyPrefix + i)
        if (abPresent[i])
            expectedPresent += 1
        endif
        if (isPresent != abPresent[i])
            mismatches += 1
            if (firstMismatch == "")
                firstMismatch = asKeyPrefix + i + " (expected " + abPresent[i] + ", HasKey said " + isPresent + ")"
            endif
        endif
        i += 1
    endWhile

    bool keysMatch = assert_true(mismatches == 0, "HasKey disagrees with shadow model " + asStage + ": " + mismatches + " mismatch(es), first: " + firstMismatch)
    bool countMatches = assert_true(apContainer.Count == aiStartCount + expectedPresent, "Count " + apContainer.Count + " != expected " + (aiStartCount + expectedPresent) + " " + asStage)
    return keysMatch && countMatches
endFunction

state Test_ActiveMagicEffectContainer_IndexMapsInSync
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        int ENTRIES = 70 ; pages 0, 1 and 2 (32 + 32 + 6) - crosses two page boundaries
        string PREFIX = "SyncTest_"

        bool ok = true
        bool step = false

        step = self.__AssertContainerInSync(_container, "at baseline, before this test touched anything")
        ok = ok && step

        ; --- Phase 1: straight appends. Dense packing means the entry added i-th lands at
        ; index startCount + i, so the reverse map can be checked directly through the public API
        bool[] present = new bool[70]
        int i = 0
        while (i < ENTRIES)
            _container.AddElement(none, PREFIX + i)
            present[i] = true
            i += 1
        endWhile

        step = self.__AssertContainerInSync(_container, "after " + ENTRIES + " appends")
        ok = ok && step
        step = assert_equals(PREFIX + 0, _container.GetKeyAtIndex(startCount + 0), "Reverse map: wrong key at first appended index")
        ok = ok && step
        step = assert_equals(PREFIX + 33, _container.GetKeyAtIndex(startCount + 33), "Reverse map: wrong key at an index inside page 1")
        ok = ok && step
        step = assert_equals(PREFIX + 69, _container.GetKeyAtIndex(startCount + 69), "Reverse map: wrong key at the last appended index")
        ok = ok && step
        step = assert_equals("", _container.GetKeyAtIndex(startCount + ENTRIES), "GetKeyAtIndex should return \"\" one past the last live index")
        ok = ok && step

        ; --- Phase 2: the three distinct removal shapes, each verified individually ---
        ; (a) remove the FIRST entry: the last one (69) must be swapped into its slot, and the
        ; reverse map must now say so
        _container.RemoveElement(PREFIX + 0, dispel = false)
        present[0] = false
        step = assert_equals(PREFIX + 69, _container.GetKeyAtIndex(startCount + 0), "Swap: last entry should now occupy the freed first slot")
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after removing the first entry (swap from the end)")
        ok = ok && step

        ; (b) remove whatever is CURRENTLY last - the removedIndex == lastIndex path, where no
        ; swap happens and only the reverse map's trailing entry has to go
        step = assert_equals(PREFIX + 68, _container.GetKeyAtIndex(_container.Count - 1), "Expected entry 68 to be last after entry 69 was swapped forward")
        ok = ok && step
        _container.RemoveElement(PREFIX + 68, dispel = false)
        present[68] = false
        step = self.__AssertContainerInSync(_container, "after removing the current last entry (no-swap path)")
        ok = ok && step

        ; (c) remove a middle entry that sits in a different page from the last one
        _container.RemoveElement(PREFIX + 33, dispel = false)
        present[33] = false
        step = self.__AssertContainerInSync(_container, "after removing a middle entry across a page boundary")
        ok = ok && step
        step = self.__ContainerMatchesShadow(_container, present, PREFIX, startCount, "after the three targeted removals")
        ok = ok && step

        ; --- Phase 3: deterministic pseudo-random churn against a shadow model. Each op toggles
        ; one slot (present -> remove, absent -> add). The generator is a small full-period LCG so
        ; every run replays the exact same sequence; a failure is reproducible, not flaky.
        int seed = 12345
        int slot = 0
        int op = 0
        while (op < 150)
            seed = (seed * 75 + 74) % 65537
            slot = seed % ENTRIES

            if (present[slot])
                _container.RemoveElement(PREFIX + slot, dispel = false)
                present[slot] = false
            else
                _container.AddElement(none, PREFIX + slot)
                present[slot] = true
            endif

            op += 1
            if ((op % 15) == 0)
                step = self.__AssertContainerInSync(_container, "during churn, after op " + op)
                ok = ok && step
                step = self.__ContainerMatchesShadow(_container, present, PREFIX, startCount, "during churn, after op " + op)
                ok = ok && step
            endif
        endWhile

        ; --- Phase 4: drain everything left, then confirm the container is back where it began
        i = 0
        while (i < ENTRIES)
            if (present[i])
                _container.RemoveElement(PREFIX + i, dispel = false)
                present[i] = false
            endif
            i += 1
        endWhile

        step = self.__AssertContainerInSync(_container, "after draining every synthetic entry")
        ok = ok && step
        step = assert_true(_container.Count == startCount, "Container did not return to its original Count after cleanup, got " + _container.Count)
        ok = ok && step

        display_result(ok)
    endFunction
endState

;/
    The old-save migration path. An alias saved before __indexToKey existed loads with a valid
    __keyToIndex and Count but an unset (0) reverse map, and OnInit() doesn't re-fire. That's
    exactly what DebugSimulateMissingReverseIndex() recreates, so this proves - without needing
    an old save - that (1) the next ordinary call rebuilds the mirror, (2) it does so WITHOUT
    touching Count or losing entries (unlike the invalid-__keyToIndex recovery, which
    deliberately resets both), and (3) removal, which depends on the rebuilt mirror to swap
    correctly, works straight afterwards. Any real entries already in ArresteeList are part of
    the rebuild too, so this also covers real state, not just synthetic keys.
/;
state Test_ActiveMagicEffectContainer_ReverseMapMigration
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        int ENTRIES = 40 ; spans page 0 and page 1
        string PREFIX = "MigrationTest_"

        bool ok = true
        bool step = false

        int i = 0
        while (i < ENTRIES)
            _container.AddElement(none, PREFIX + i)
            i += 1
        endWhile

        step = self.__AssertContainerInSync(_container, "before simulating the missing reverse map")
        ok = ok && step

        ; --- Round 1: healed by an ordinary read (HasKey), not by the validator itself ---
        _container.DebugSimulateMissingReverseIndex()

        step = assert_true(_container.HasKey(PREFIX + 17), "Entry lost after the reverse map went missing")
        ok = ok && step
        step = assert_true(_container.Count == startCount + ENTRIES, "Count must survive the rebuild untouched, expected " + (startCount + ENTRIES) + ", got " + _container.Count)
        ok = ok && step
        step = assert_equals(PREFIX + 17, _container.GetKeyAtIndex(startCount + 17), "Rebuilt reverse map returned the wrong key")
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after the rebuild triggered by HasKey")
        ok = ok && step

        ; --- Round 2: healed by RemoveElement itself, the operation that depends on it most ---
        _container.DebugSimulateMissingReverseIndex()
        _container.RemoveElement(PREFIX + 3, dispel = false)

        step = assert_false(_container.HasKey(PREFIX + 3), "Removed key still present after rebuild-then-remove")
        ok = ok && step
        step = assert_equals(PREFIX + 39, _container.GetKeyAtIndex(startCount + 3), "Removal straight after a rebuild swapped the wrong entry into the freed slot")
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after removing straight after a rebuild")
        ok = ok && step

        ; --- Round 3: healed by AddElement, then confirm the new entry is reverse-mapped too ---
        _container.DebugSimulateMissingReverseIndex()
        _container.AddElement(none, PREFIX + "Late")

        step = assert_equals(PREFIX + "Late", _container.GetKeyAtIndex(_container.Count - 1), "Entry added straight after a rebuild is missing from the reverse map")
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after adding straight after a rebuild")
        ok = ok && step

        ; Cleanup
        _container.RemoveElement(PREFIX + "Late", dispel = false)
        i = 0
        while (i < ENTRIES)
            if (_container.HasKey(PREFIX + i))
                _container.RemoveElement(PREFIX + i, dispel = false)
            endif
            i += 1
        endWhile

        step = self.__AssertContainerInSync(_container, "after cleanup")
        ok = ok && step
        step = assert_true(_container.Count == startCount, "Container did not return to its original Count after cleanup, got " + _container.Count)
        ok = ok && step

        display_result(ok)
    endFunction
endState

;/
    Times the bookkeeping half of RemoveElement() with and without the reverse map. Both modes
    do the identical add-then-drain over a fresh FastMap; the only difference is how the swap
    step finds "which key owns the last index": an O(n) scan (the pre-reverse-map behavior,
    via __ScanForKeyAtIndex, which mirrors the old __FindKeyForIndex exactly) or an O(1) lookup
    in a second map that Add/Remove keep up to date (the current behavior). Returns
    [add milliseconds, remove milliseconds], totalled across @aiRepeats runs - repeats exist so
    the small, real-scale sizes accumulate a measurable time instead of rounding to zero.
/;
float[] function __RunBookkeepingBench(int aiEntries, int aiRepeats, bool abUseReverseIndex)
    float addSeconds = 0.0
    float removeSeconds = 0.0
    float startTime = 0.0
    int keyToIndex = 0
    int indexToKey = 0
    int liveCount = 0
    int removedIndex = 0
    int lastIndex = 0
    string removeKey = ""
    string lastKey = ""

    int rep = 0
    while (rep < aiRepeats)
        keyToIndex = FastMap("<string>", true)
        if (abUseReverseIndex)
            indexToKey = FastMap("<int>", true)
        endif

        startTime = Utility.GetCurrentRealTime()
        int i = 0
        while (i < aiEntries)
            FastMap_SetInt(keyToIndex, "Key_" + i, i)
            if (abUseReverseIndex)
                FastIntMap_SetString(indexToKey, i, "Key_" + i)
            endif
            i += 1
        endWhile
        addSeconds += Utility.GetCurrentRealTime() - startTime

        startTime = Utility.GetCurrentRealTime()
        liveCount = aiEntries
        i = 0
        while (i < aiEntries)
            removeKey = "Key_" + i
            removedIndex = FastMap_GetInt(keyToIndex, removeKey)
            lastIndex = liveCount - 1

            if (removedIndex != lastIndex)
                if (abUseReverseIndex)
                    lastKey = FastIntMap_GetString(indexToKey, lastIndex)
                else
                    lastKey = self.__ScanForKeyAtIndex(keyToIndex, lastIndex)
                endif

                if (lastKey != "")
                    FastMap_SetInt(keyToIndex, lastKey, removedIndex)
                    if (abUseReverseIndex)
                        FastIntMap_SetString(indexToKey, removedIndex, lastKey)
                    endif
                endif
            endif

            FastMap_RemoveKey(keyToIndex, removeKey)
            if (abUseReverseIndex)
                FastIntMap_RemoveKey(indexToKey, lastIndex)
            endif
            liveCount -= 1
            i += 1
        endWhile
        removeSeconds += Utility.GetCurrentRealTime() - startTime

        FastMap_Release(keyToIndex)
        if (abUseReverseIndex)
            FastMap_Release(indexToKey)
        endif
        rep += 1
    endWhile

    float[] result = new float[2]
    result[0] = addSeconds * 1000.0
    result[1] = removeSeconds * 1000.0
    return result
endFunction

;/
    Answers "what did the reverse map actually buy, and what did it cost": the same add+drain
    workload with and without it, at the container's real scale (15 entries, the documented
    ceiling, repeated 20x) and at the 150-entry stress size test 12/29 use, then the real
    container's own end-to-end Add+drain at 150 entries (test 12's exact workload, whose
    pre-reverse-map figure was ~6250ms, ~2361ms of it the scan).
/;
state Benchmark_ScanVsReverseIndexRemoval
    function Setup()
        float[] scanSmall = self.__RunBookkeepingBench(15, 20, false)
        float[] indexSmall = self.__RunBookkeepingBench(15, 20, true)
        float[] scanLarge = self.__RunBookkeepingBench(150, 1, false)
        float[] indexLarge = self.__RunBookkeepingBench(150, 1, true)

        log("BENCH real scale (15 entries x20 runs) - scan: add " + (scanSmall[0] as int) + "ms, remove " + (scanSmall[1] as int) + "ms | reverse map: add " + (indexSmall[0] as int) + "ms, remove " + (indexSmall[1] as int) + "ms")
        log("BENCH stress (150 entries x1 run) - scan: add " + (scanLarge[0] as int) + "ms, remove " + (scanLarge[1] as int) + "ms | reverse map: add " + (indexLarge[0] as int) + "ms, remove " + (indexLarge[1] as int) + "ms")
        Debug.Notification("15x20 remove: scan " + (scanSmall[1] as int) + "ms vs map " + (indexSmall[1] as int) + "ms")
        Debug.Notification("150 remove: scan " + (scanLarge[1] as int) + "ms vs map " + (indexLarge[1] as int) + "ms")

        ; --- The real container, test 12's exact workload ---
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        int ENTRIES = 150

        float realBench = StartBenchmark()
        int i = 0
        while (i < ENTRIES)
            _container.AddElement(none, "BenchReverseIdx_" + i)
            i += 1
        endWhile
        i = 0
        while (i < ENTRIES)
            _container.RemoveElement("BenchReverseIdx_" + i, dispel = false)
            i += 1
        endWhile
        int realElapsed = EndBenchmark(realBench, "Real container: " + ENTRIES + " adds + full drain (reverse map; test 12 measured ~6250ms before it)")

        log("BENCH real container 150 add+drain: " + realElapsed + "ms (was ~6250ms scan-based, test 12)")
        Debug.Notification("Real container 150 add+drain: " + realElapsed + "ms (was ~6250)")

        bool inSync = self.__AssertContainerInSync(_container, "after the real-container benchmark drain")
        bool backToStart = assert_true(_container.Count == startCount, "Container did not return to its original Count, got " + _container.Count)

        display_result(inSync && backToStart, showTimeElapsed = false)
    endFunction
endState

;/
    Breaks the real container's per-operation cost into its parts, to find where the ~3.5s of
    overhead in test 12's workload (150 adds + full drain = 4003ms, versus ~484ms of bare map
    bookkeeping in benchmark 32) actually goes. Everything runs against the live ArresteeList
    with cheap synthetic keys and a None payload, and only READS the container's public API -
    nothing about the container is changed by this test. Each phase is timed on its own:

      - string concat floor: building the same "prefix + i" key strings, no container involved
      - call floor:          a trivial cross-script call (GetSize) - the price of just reaching
                             the container from here, before it does any work
      - AddElement only:     150 adds (compare: ~165ms of bare map writes in benchmark 32)
      - HasKey:              150 hits + 150 misses
      - remove from FRONT:   ascending keys, so every removal takes the swap path
      - remove from BACK:    descending keys, so every removal is the last element (no swap)

    Per-call microseconds are logged next to each total so phases with different call counts
    compare directly.
/;
state Benchmark_ContainerOverheadBreakdown
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        int ENTRIES = 150
        string PREFIX = "OverheadBench_"

        int i = 0
        int sinkInt = 0
        bool sinkBool = false
        string sinkString = ""
        float bench = 0.0

        ; --- string concat floor ---
        bench = StartBenchmark()
        i = 0
        while (i < ENTRIES * 2)
            sinkString = PREFIX + i
            i += 1
        endWhile
        int concatMs = EndBenchmark(bench, "String concat floor: " + (ENTRIES * 2) + " x (prefix + i)")

        ; --- cross-script call floor ---
        bench = StartBenchmark()
        i = 0
        while (i < ENTRIES * 2)
            sinkInt = _container.GetSize()
            i += 1
        endWhile
        int callFloorMs = EndBenchmark(bench, "Cross-script call floor: " + (ENTRIES * 2) + " x GetSize()")

        ; --- AddElement only ---
        bench = StartBenchmark()
        i = 0
        while (i < ENTRIES)
            _container.AddElement(none, PREFIX + i)
            i += 1
        endWhile
        int addMs = EndBenchmark(bench, "AddElement: " + ENTRIES + " adds")

        ; --- HasKey: 150 hits + 150 misses ---
        bench = StartBenchmark()
        i = 0
        while (i < ENTRIES)
            sinkBool = _container.HasKey(PREFIX + i)
            sinkBool = _container.HasKey(PREFIX + "miss_" + i)
            i += 1
        endWhile
        int hasKeyMs = EndBenchmark(bench, "HasKey: " + ENTRIES + " hits + " + ENTRIES + " misses")

        ; --- remove from the FRONT: ascending keys, swap path every time ---
        bench = StartBenchmark()
        i = 0
        while (i < ENTRIES)
            _container.RemoveElement(PREFIX + i, dispel = false)
            i += 1
        endWhile
        int frontMs = EndBenchmark(bench, "RemoveElement from the front (swap path): " + ENTRIES + " removes")

        ; --- re-add (untimed), then remove from the BACK: descending keys, never a swap ---
        i = 0
        while (i < ENTRIES)
            _container.AddElement(none, PREFIX + i)
            i += 1
        endWhile

        bench = StartBenchmark()
        i = ENTRIES - 1
        while (i >= 0)
            _container.RemoveElement(PREFIX + i, dispel = false)
            i -= 1
        endWhile
        int backMs = EndBenchmark(bench, "RemoveElement from the back (no-swap path): " + ENTRIES + " removes")

        log("OVERHEAD (ms total | us per call) - concat floor " + concatMs + " | " + ((concatMs * 1000.0 / (ENTRIES * 2)) as int) + ", call floor " + callFloorMs + " | " + ((callFloorMs * 1000.0 / (ENTRIES * 2)) as int) + ", add " + addMs + " | " + ((addMs * 1000.0 / ENTRIES) as int) + ", hasKey " + hasKeyMs + " | " + ((hasKeyMs * 1000.0 / (ENTRIES * 2)) as int) + ", remove front " + frontMs + " | " + ((frontMs * 1000.0 / ENTRIES) as int) + ", remove back " + backMs + " | " + ((backMs * 1000.0 / ENTRIES) as int))
        Debug.Notification("Add " + addMs + "ms, HasKey " + hasKeyMs + "ms, remove front " + frontMs + "ms, back " + backMs + "ms")
        Debug.Notification("Floors: concat " + concatMs + "ms, call " + callFloorMs + "ms")

        bool inSync = self.__AssertContainerInSync(_container, "after the overhead benchmark")
        bool backToStart = assert_true(_container.Count == startCount, "Container did not return to its original Count, got " + _container.Count)

        display_result(inSync && backToStart, showTimeElapsed = false)
    endFunction
endState

;/
    Tests a specific suspicion raised by benchmark 33: that allocating and freeing a page
    (new ActiveMagicEffect[32] / = none) is the expensive part of the container's cost, not the
    call count - 150 adds took ~1496ms (~10ms each) versus ~1.1ms for the same map writes in
    benchmark 32, and 150 entries cross exactly 5 pages. If so, free-on-empty means an
    arrestee/prisoner list that flips between 0 and 1 entries pays that cost on every Add and
    every Remove.

    Four measurements, 20 cycles each:
      - raw [32] alloc + free into a local (no container)
      - raw [128] alloc + free into a local (does array size matter?)
      - real container, cycle Add+Remove one key with the container sitting exactly on a page
        boundary (Count % 32 == 0), so every Add opens a new page and every Remove frees it
      - the same cycle with the page kept occupied by one extra entry, so no page event happens
    The last two differ only by the page alloc+free, so their delta / 20 is what one alloc+free
    really costs through the container. Filling to a boundary works whatever real entries the
    live ArresteeList already holds. Everything synthetic is removed afterwards.
/;
state Benchmark_PageAllocationCost
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        int CYCLES = 20
        int PAGE_SIZE_ASSUMED = 32 ; matches RPB_ActiveMagicEffectContainer.PAGE_SIZE

        int i = 0
        float bench = 0.0

        ; --- raw array allocation, no container ---
        ActiveMagicEffect[] rawPage = none
        bench = StartBenchmark()
        i = 0
        while (i < CYCLES)
            rawPage = new ActiveMagicEffect[32]
            rawPage = none
            i += 1
        endWhile
        int raw32Ms = EndBenchmark(bench, "Raw new ActiveMagicEffect[32] + free: " + CYCLES + " cycles")

        bench = StartBenchmark()
        i = 0
        while (i < CYCLES)
            rawPage = new ActiveMagicEffect[128]
            rawPage = none
            i += 1
        endWhile
        int raw128Ms = EndBenchmark(bench, "Raw new ActiveMagicEffect[128] + free: " + CYCLES + " cycles")

        ; --- fill to exactly a page boundary ---
        int fillCount = 0
        while ((_container.Count % PAGE_SIZE_ASSUMED) != 0)
            _container.AddElement(none, "AllocBenchFill_" + fillCount)
            fillCount += 1
        endWhile

        ; --- churn: every Add opens a page, every Remove frees it ---
        bench = StartBenchmark()
        i = 0
        while (i < CYCLES)
            _container.AddElement(none, "AllocBenchCycle")
            _container.RemoveElement("AllocBenchCycle", dispel = false)
            i += 1
        endWhile
        int churnMs = EndBenchmark(bench, "Container Add+Remove ON a page boundary: " + CYCLES + " cycles")

        ; --- same cycle, page kept occupied by one extra entry, so no page event ---
        _container.AddElement(none, "AllocBenchFill_" + fillCount)
        fillCount += 1

        bench = StartBenchmark()
        i = 0
        while (i < CYCLES)
            _container.AddElement(none, "AllocBenchCycle")
            _container.RemoveElement("AllocBenchCycle", dispel = false)
            i += 1
        endWhile
        int steadyMs = EndBenchmark(bench, "Container Add+Remove WITHIN a page: " + CYCLES + " cycles")

        ; --- cleanup ---
        i = 0
        while (i < fillCount)
            _container.RemoveElement("AllocBenchFill_" + i, dispel = false)
            i += 1
        endWhile

        int deltaMs = churnMs - steadyMs
        log("PAGE ALLOC (ms total | ms per cycle) - raw[32] " + raw32Ms + " | " + (raw32Ms * 1.0 / CYCLES) + ", raw[128] " + raw128Ms + " | " + (raw128Ms * 1.0 / CYCLES) + ", container on-boundary " + churnMs + " | " + (churnMs * 1.0 / CYCLES) + ", within-page " + steadyMs + " | " + (steadyMs * 1.0 / CYCLES) + ", delta " + deltaMs + " => " + (deltaMs * 1.0 / CYCLES) + "ms per page alloc+free")
        Debug.Notification("Raw[32] " + raw32Ms + "ms, raw[128] " + raw128Ms + "ms per " + CYCLES + " cycles")
        Debug.Notification("Container: boundary " + churnMs + "ms vs within-page " + steadyMs + "ms")

        bool inSync = self.__AssertContainerInSync(_container, "after the page-allocation benchmark")
        bool backToStart = assert_true(_container.Count == startCount, "Container did not return to its original Count, got " + _container.Count)

        display_result(inSync && backToStart, showTimeElapsed = false)
    endFunction
endState

;/
    Helpers for Benchmark_FunctionSizeCallCost: identical behavior (return a constant chosen by
    an if/elseif chain), differing only in how many branches - i.e. how large - the function is.
/;
int function __BenchSmallFn(int aiValue)
    return aiValue
endFunction

int function __BenchBig8Fn(int aiValue)
    if (aiValue == 0)
        return 100
    elseif (aiValue == 1)
        return 101
    elseif (aiValue == 2)
        return 102
    elseif (aiValue == 3)
        return 103
    elseif (aiValue == 4)
        return 104
    elseif (aiValue == 5)
        return 105
    elseif (aiValue == 6)
        return 106
    elseif (aiValue == 7)
        return 107
    endif
    return -1
endFunction

int function __BenchBig32Fn(int aiValue)
    if (aiValue == 0)
        return 100
    elseif (aiValue == 1)
        return 101
    elseif (aiValue == 2)
        return 102
    elseif (aiValue == 3)
        return 103
    elseif (aiValue == 4)
        return 104
    elseif (aiValue == 5)
        return 105
    elseif (aiValue == 6)
        return 106
    elseif (aiValue == 7)
        return 107
    elseif (aiValue == 8)
        return 108
    elseif (aiValue == 9)
        return 109
    elseif (aiValue == 10)
        return 110
    elseif (aiValue == 11)
        return 111
    elseif (aiValue == 12)
        return 112
    elseif (aiValue == 13)
        return 113
    elseif (aiValue == 14)
        return 114
    elseif (aiValue == 15)
        return 115
    elseif (aiValue == 16)
        return 116
    elseif (aiValue == 17)
        return 117
    elseif (aiValue == 18)
        return 118
    elseif (aiValue == 19)
        return 119
    elseif (aiValue == 20)
        return 120
    elseif (aiValue == 21)
        return 121
    elseif (aiValue == 22)
        return 122
    elseif (aiValue == 23)
        return 123
    elseif (aiValue == 24)
        return 124
    elseif (aiValue == 25)
        return 125
    elseif (aiValue == 26)
        return 126
    elseif (aiValue == 27)
        return 127
    elseif (aiValue == 28)
        return 128
    elseif (aiValue == 29)
        return 129
    elseif (aiValue == 30)
        return 130
    elseif (aiValue == 31)
        return 131
    endif
    return -1
endFunction

int function __BenchBig128Fn(int aiValue)
    if (aiValue == 0)
        return 100
    elseif (aiValue == 1)
        return 101
    elseif (aiValue == 2)
        return 102
    elseif (aiValue == 3)
        return 103
    elseif (aiValue == 4)
        return 104
    elseif (aiValue == 5)
        return 105
    elseif (aiValue == 6)
        return 106
    elseif (aiValue == 7)
        return 107
    elseif (aiValue == 8)
        return 108
    elseif (aiValue == 9)
        return 109
    elseif (aiValue == 10)
        return 110
    elseif (aiValue == 11)
        return 111
    elseif (aiValue == 12)
        return 112
    elseif (aiValue == 13)
        return 113
    elseif (aiValue == 14)
        return 114
    elseif (aiValue == 15)
        return 115
    elseif (aiValue == 16)
        return 116
    elseif (aiValue == 17)
        return 117
    elseif (aiValue == 18)
        return 118
    elseif (aiValue == 19)
        return 119
    elseif (aiValue == 20)
        return 120
    elseif (aiValue == 21)
        return 121
    elseif (aiValue == 22)
        return 122
    elseif (aiValue == 23)
        return 123
    elseif (aiValue == 24)
        return 124
    elseif (aiValue == 25)
        return 125
    elseif (aiValue == 26)
        return 126
    elseif (aiValue == 27)
        return 127
    elseif (aiValue == 28)
        return 128
    elseif (aiValue == 29)
        return 129
    elseif (aiValue == 30)
        return 130
    elseif (aiValue == 31)
        return 131
    elseif (aiValue == 32)
        return 132
    elseif (aiValue == 33)
        return 133
    elseif (aiValue == 34)
        return 134
    elseif (aiValue == 35)
        return 135
    elseif (aiValue == 36)
        return 136
    elseif (aiValue == 37)
        return 137
    elseif (aiValue == 38)
        return 138
    elseif (aiValue == 39)
        return 139
    elseif (aiValue == 40)
        return 140
    elseif (aiValue == 41)
        return 141
    elseif (aiValue == 42)
        return 142
    elseif (aiValue == 43)
        return 143
    elseif (aiValue == 44)
        return 144
    elseif (aiValue == 45)
        return 145
    elseif (aiValue == 46)
        return 146
    elseif (aiValue == 47)
        return 147
    elseif (aiValue == 48)
        return 148
    elseif (aiValue == 49)
        return 149
    elseif (aiValue == 50)
        return 150
    elseif (aiValue == 51)
        return 151
    elseif (aiValue == 52)
        return 152
    elseif (aiValue == 53)
        return 153
    elseif (aiValue == 54)
        return 154
    elseif (aiValue == 55)
        return 155
    elseif (aiValue == 56)
        return 156
    elseif (aiValue == 57)
        return 157
    elseif (aiValue == 58)
        return 158
    elseif (aiValue == 59)
        return 159
    elseif (aiValue == 60)
        return 160
    elseif (aiValue == 61)
        return 161
    elseif (aiValue == 62)
        return 162
    elseif (aiValue == 63)
        return 163
    elseif (aiValue == 64)
        return 164
    elseif (aiValue == 65)
        return 165
    elseif (aiValue == 66)
        return 166
    elseif (aiValue == 67)
        return 167
    elseif (aiValue == 68)
        return 168
    elseif (aiValue == 69)
        return 169
    elseif (aiValue == 70)
        return 170
    elseif (aiValue == 71)
        return 171
    elseif (aiValue == 72)
        return 172
    elseif (aiValue == 73)
        return 173
    elseif (aiValue == 74)
        return 174
    elseif (aiValue == 75)
        return 175
    elseif (aiValue == 76)
        return 176
    elseif (aiValue == 77)
        return 177
    elseif (aiValue == 78)
        return 178
    elseif (aiValue == 79)
        return 179
    elseif (aiValue == 80)
        return 180
    elseif (aiValue == 81)
        return 181
    elseif (aiValue == 82)
        return 182
    elseif (aiValue == 83)
        return 183
    elseif (aiValue == 84)
        return 184
    elseif (aiValue == 85)
        return 185
    elseif (aiValue == 86)
        return 186
    elseif (aiValue == 87)
        return 187
    elseif (aiValue == 88)
        return 188
    elseif (aiValue == 89)
        return 189
    elseif (aiValue == 90)
        return 190
    elseif (aiValue == 91)
        return 191
    elseif (aiValue == 92)
        return 192
    elseif (aiValue == 93)
        return 193
    elseif (aiValue == 94)
        return 194
    elseif (aiValue == 95)
        return 195
    elseif (aiValue == 96)
        return 196
    elseif (aiValue == 97)
        return 197
    elseif (aiValue == 98)
        return 198
    elseif (aiValue == 99)
        return 199
    elseif (aiValue == 100)
        return 200
    elseif (aiValue == 101)
        return 201
    elseif (aiValue == 102)
        return 202
    elseif (aiValue == 103)
        return 203
    elseif (aiValue == 104)
        return 204
    elseif (aiValue == 105)
        return 205
    elseif (aiValue == 106)
        return 206
    elseif (aiValue == 107)
        return 207
    elseif (aiValue == 108)
        return 208
    elseif (aiValue == 109)
        return 209
    elseif (aiValue == 110)
        return 210
    elseif (aiValue == 111)
        return 211
    elseif (aiValue == 112)
        return 212
    elseif (aiValue == 113)
        return 213
    elseif (aiValue == 114)
        return 214
    elseif (aiValue == 115)
        return 215
    elseif (aiValue == 116)
        return 216
    elseif (aiValue == 117)
        return 217
    elseif (aiValue == 118)
        return 218
    elseif (aiValue == 119)
        return 219
    elseif (aiValue == 120)
        return 220
    elseif (aiValue == 121)
        return 221
    elseif (aiValue == 122)
        return 222
    elseif (aiValue == 123)
        return 223
    elseif (aiValue == 124)
        return 224
    elseif (aiValue == 125)
        return 225
    elseif (aiValue == 126)
        return 226
    elseif (aiValue == 127)
        return 227
    endif
    return -1
endFunction

;/
    Tests whether the cost of calling a function depends on the function's SIZE rather than on
    the work it does. Benchmark 33/34 showed every container operation costing ~7-12ms while its
    JContainers writes are ~1-2ms, and the container's page helpers are each a 32-branch
    if/elseif function called several times per operation. If a call's price grows with the
    function's size (frame/temporaries set-up), that would explain it.

    Same-script member calls, like the container's own internal calls. Every function returns
    a constant from an if/elseif chain; only the branch count differs (1, 8, 32, 128). Argument
    0 hits the FIRST branch, so all the "first branch" runs execute one comparison and differ
    only in function size; the "last branch" runs additionally execute every comparison. Two
    rounds each, summed, to damp run-to-run noise. Empty-loop floor included.
      - times track function size, first-branch runs:  size matters (hypothesis confirmed)
      - last-branch runs far above first-branch ones:  executed comparisons matter
      - everything about equal:                        neither; the hypothesis is refuted
/;
state Benchmark_FunctionSizeCallCost
    function Setup()
        int CALLS = 500
        int ROUNDS = 2

        int sinkInt = 0
        int i = 0
        float bench = 0.0
        int round = 0

        int tFloor = 0
        int tSmall = 0
        int t8First = 0
        int t32First = 0
        int t128First = 0
        int t32Last = 0
        int t128Last = 0

        while (round < ROUNDS)
            bench = StartBenchmark()
            i = 0
            while (i < CALLS)
                i += 1
            endWhile
            tFloor = tFloor + EndBenchmark(bench, "Empty loop floor: " + CALLS + " iterations")

        bench = StartBenchmark()
        i = 0
        while (i < CALLS)
            sinkInt = self.__BenchSmallFn(0)
            i += 1
        endWhile
        tSmall = tSmall + EndBenchmark(bench, "small: " + CALLS + " calls")

        bench = StartBenchmark()
        i = 0
        while (i < CALLS)
            sinkInt = self.__BenchBig8Fn(0)
            i += 1
        endWhile
        t8First = t8First + EndBenchmark(bench, "big8, first branch: " + CALLS + " calls")

        bench = StartBenchmark()
        i = 0
        while (i < CALLS)
            sinkInt = self.__BenchBig32Fn(0)
            i += 1
        endWhile
        t32First = t32First + EndBenchmark(bench, "big32, first branch: " + CALLS + " calls")

        bench = StartBenchmark()
        i = 0
        while (i < CALLS)
            sinkInt = self.__BenchBig128Fn(0)
            i += 1
        endWhile
        t128First = t128First + EndBenchmark(bench, "big128, first branch: " + CALLS + " calls")

        bench = StartBenchmark()
        i = 0
        while (i < CALLS)
            sinkInt = self.__BenchBig32Fn(31)
            i += 1
        endWhile
        t32Last = t32Last + EndBenchmark(bench, "big32, last branch: " + CALLS + " calls")

        bench = StartBenchmark()
        i = 0
        while (i < CALLS)
            sinkInt = self.__BenchBig128Fn(127)
            i += 1
        endWhile
        t128Last = t128Last + EndBenchmark(bench, "big128, last branch: " + CALLS + " calls")

            round += 1
        endWhile

        int totalCalls = CALLS * ROUNDS
        log("FUNCTION SIZE (us per call, " + totalCalls + " calls each) - loop floor " + ((tFloor * 1000.0 / totalCalls) as int) + ", small " + ((tSmall * 1000.0 / totalCalls) as int) + ", big8 first " + ((t8First * 1000.0 / totalCalls) as int) + ", big32 first " + ((t32First * 1000.0 / totalCalls) as int) + ", big128 first " + ((t128First * 1000.0 / totalCalls) as int) + ", big32 last " + ((t32Last * 1000.0 / totalCalls) as int) + ", big128 last " + ((t128Last * 1000.0 / totalCalls) as int))
        Debug.Notification("us/call: small " + ((tSmall * 1000.0 / totalCalls) as int) + ", big8 " + ((t8First * 1000.0 / totalCalls) as int) + ", big32 " + ((t32First * 1000.0 / totalCalls) as int) + ", big128 " + ((t128First * 1000.0 / totalCalls) as int))

        display_result(true, showTimeElapsed = false)
    endFunction
endState

;/
    Fills the live ArresteeList container to its full 1024-entry capacity (32 pages x 32 slots,
    counting whatever real entries it already holds), so every one of the 32 page branches in
    __GetSlot/__SetSlot/__FreePageIfNowUnused actually runs - tests 12/25/30 only reach pages
    0-4. Verifies Count, the forward/reverse maps, and the key stored at an index inside a
    spread of pages; that one Add past capacity is rejected without changing anything (the
    container logs an "is full" error line for that on purpose); then drains everything by
    ascending key, which takes the swap path across every page boundary on the way down, and
    confirms the container is back where it started. Slow by design (~2000 container
    operations), so not chainable. Fill and drain times are logged as a bonus.
/;
state Test_ActiveMagicEffectContainer_FullCapacity
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        int CAPACITY = 1024
        string PREFIX = "CapacityTest_"

        bool ok = true
        bool step = false

        int syntheticCount = CAPACITY - startCount
        if (syntheticCount <= 0)
            log("ArresteeList already holds " + startCount + " entries - cannot fill it to capacity for this test")
            display_result(false)
            return
        endif

        ; --- fill to capacity ---
        float bench = StartBenchmark()
        int i = 0
        while (i < syntheticCount)
            _container.AddElement(none, PREFIX + i)
            i += 1
        endWhile
        int fillMs = EndBenchmark(bench, "Fill to capacity: " + syntheticCount + " adds")

        step = assert_true(_container.Count == CAPACITY, "Expected Count == " + CAPACITY + " after filling, got " + _container.Count)
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "at full capacity")
        ok = ok && step

        ; Spot-check the key at an index inside pages 0, 4, 8, ... 28 and the very last slot of page 31
        int page = 0
        int globalIndex = 0
        while (page < 32)
            globalIndex = page * 32 + 5
            if (globalIndex < startCount)
                globalIndex = startCount
            endif
            step = assert_equals(PREFIX + (globalIndex - startCount), _container.GetKeyAtIndex(globalIndex), "Wrong key at global index " + globalIndex + " (page " + (globalIndex / 32) + ")")
            ok = ok && step
            page += 4
        endWhile
        step = assert_equals(PREFIX + (syntheticCount - 1), _container.GetKeyAtIndex(CAPACITY - 1), "Wrong key in the last slot of page 31")
        ok = ok && step

        ; --- one past capacity must be rejected, changing nothing ---
        _container.AddElement(none, PREFIX + "Overflow")
        step = assert_true(_container.Count == CAPACITY, "Count changed after an Add at full capacity: " + _container.Count)
        ok = ok && step
        step = assert_false(_container.HasKey(PREFIX + "Overflow"), "An Add past capacity was accepted")
        ok = ok && step

        ; --- drain ascending: swap path across every page boundary ---
        bench = StartBenchmark()
        i = 0
        while (i < syntheticCount)
            _container.RemoveElement(PREFIX + i, dispel = false)
            i += 1
            if (i == syntheticCount / 2)
                step = self.__AssertContainerInSync(_container, "halfway through the drain")
                ok = ok && step
            endif
        endWhile
        int drainMs = EndBenchmark(bench, "Drain from capacity: " + syntheticCount + " removes")

        step = assert_true(_container.Count == startCount, "Container did not return to its original Count after draining, got " + _container.Count)
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after draining from capacity")
        ok = ok && step

        log("FULL CAPACITY: fill " + fillMs + "ms, drain " + drainMs + "ms for " + syntheticCount + " entries each way")
        Debug.Notification("Full capacity: fill " + fillMs + "ms, drain " + drainMs + "ms")

        display_result(ok)
    endFunction
endState

; ==========================================================
;   ActiveMagicEffectContainer: state-integrity tests (payload identity, duplicate/missing
;   keys, concurrent access, JContainers handle stability)
;
;   Tests 30-36 use a None payload, so they prove keys/indices/Count but not that the actual
;   ActiveMagicEffect follows its key. These close that gap and the "no overwrite, no lost
;   entry" questions, on the live ArresteeList with synthetic keys.
; ==========================================================

;/
    Asserts that for every key marked present in @abPresent, the container returns exactly the
    payload the shadow model expects: key i must carry @apPayloads[i % apPayloads.Length]. A swap
    that moved the wrong payload, or an Add that overwrote another key's payload, fails here
    even when Count, keys and both index maps all look fine.
/;
bool function __ContainerPayloadsMatch(RPB_ActiveMagicEffectContainer apContainer, bool[] abPresent, string asKeyPrefix, ActiveMagicEffect[] apPayloads, string asStage)
    int mismatches = 0
    string firstMismatch = ""
    ActiveMagicEffect found = none

    int i = 0
    while (i < abPresent.Length)
        if (abPresent[i])
            found = apContainer.GetAt(asKeyPrefix + i)
            if (found != apPayloads[i % apPayloads.Length])
                mismatches += 1
                if (firstMismatch == "")
                    firstMismatch = asKeyPrefix + i
                endif
            endif
        endif
        i += 1
    endWhile

    return assert_true(mismatches == 0, "Payload mismatch " + asStage + ": " + mismatches + " key(s) returned the wrong ActiveMagicEffect, first: " + firstMismatch)
endFunction

;/
    Same churn as test 30 (deterministic, shadow-modelled, crossing page boundaries), but every
    entry carries one of three REAL ActiveMagicEffects (RPB_Arrestee instances from three
    disposable actors), assigned cyclically. After each checkpoint every present key must
    return exactly its own effect.
/;
state Test_ActiveMagicEffectContainer_PayloadIdentity
    function Setup()
        RPB_Arrest arrest = RPB_API.GetArrest()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer

        ; Spacing between registrations: same engine-queue courtesy as tests 23/24
        Actor tempA = __SpawnTempActor()
        RPB_Arrestee arresteeA = arrest.AwaitArresteeReference(tempA)
        Utility.Wait(1.0)
        Actor tempB = __SpawnTempActor()
        RPB_Arrestee arresteeB = arrest.AwaitArresteeReference(tempB)
        Utility.Wait(1.0)
        Actor tempC = __SpawnTempActor()
        RPB_Arrestee arresteeC = arrest.AwaitArresteeReference(tempC)

        if (!assert_true(arresteeA != none && arresteeB != none && arresteeC != none, "Could not obtain three real Arrestee effects to use as payloads"))
            display_result(false)
            return
        endif

        ActiveMagicEffect[] payloads = new ActiveMagicEffect[3]
        payloads[0] = arresteeA
        payloads[1] = arresteeB
        payloads[2] = arresteeC

        int startCount = _container.Count
        int ENTRIES = 70
        string PREFIX = "PayloadTest_"
        bool ok = true
        bool step = false
        bool[] present = new bool[70]

        int i = 0
        while (i < ENTRIES)
            _container.AddElement(payloads[i % 3], PREFIX + i)
            present[i] = true
            i += 1
        endWhile
        step = self.__ContainerPayloadsMatch(_container, present, PREFIX, payloads, "after " + ENTRIES + " appends")
        ok = ok && step

        ; Front removal (swap from the end), current-last removal (no swap), middle removal
        _container.RemoveElement(PREFIX + 0, dispel = false)
        present[0] = false
        _container.RemoveElement(PREFIX + 68, dispel = false)
        present[68] = false
        _container.RemoveElement(PREFIX + 33, dispel = false)
        present[33] = false
        step = self.__ContainerPayloadsMatch(_container, present, PREFIX, payloads, "after the three targeted removals")
        ok = ok && step

        int seed = 24680
        int slot = 0
        int op = 0
        while (op < 150)
            seed = (seed * 75 + 74) % 65537
            slot = seed % ENTRIES

            if (present[slot])
                _container.RemoveElement(PREFIX + slot, dispel = false)
                present[slot] = false
            else
                _container.AddElement(payloads[slot % 3], PREFIX + slot)
                present[slot] = true
            endif

            op += 1
            if ((op % 15) == 0)
                step = self.__ContainerPayloadsMatch(_container, present, PREFIX, payloads, "during churn, after op " + op)
                ok = ok && step
                step = self.__AssertContainerInSync(_container, "during churn, after op " + op)
                ok = ok && step
            endif
        endWhile

        ; Drain - every removal must leave the remaining keys' payloads intact
        i = 0
        while (i < ENTRIES)
            if (present[i])
                _container.RemoveElement(PREFIX + i, dispel = false)
                present[i] = false
                if ((i % 10) == 0)
                    step = self.__ContainerPayloadsMatch(_container, present, PREFIX, payloads, "during drain, after removing " + i)
                    ok = ok && step
                endif
            endif
            i += 1
        endWhile

        step = assert_true(_container.Count == startCount, "Container did not return to its original Count after cleanup, got " + _container.Count)
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after draining")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    "No overwrites": adding a key that already exists must leave the container, the existing
    payload and Count exactly as they were (the container logs an "already exists" error for
    each rejected Add, on purpose); removing a key that doesn't exist must be a no-op; and
    Add/Remove of the same key over and over must never leave stale state behind (a re-added key
    returns its NEW payload, not the previous one).
/;
state Test_ActiveMagicEffectContainer_DuplicateAndMissingKeys
    function Setup()
        RPB_Arrest arrest = RPB_API.GetArrest()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer

        Actor tempA = __SpawnTempActor()
        RPB_Arrestee arresteeA = arrest.AwaitArresteeReference(tempA)
        Utility.Wait(1.0)
        Actor tempB = __SpawnTempActor()
        RPB_Arrestee arresteeB = arrest.AwaitArresteeReference(tempB)

        if (!assert_true(arresteeA != none && arresteeB != none, "Could not obtain two real Arrestee effects to use as payloads"))
            display_result(false)
            return
        endif

        int startCount = _container.Count
        bool ok = true
        bool step = false

        ; --- duplicate Add must not overwrite ---
        _container.AddElement(arresteeA, "DupTest")
        step = assert_true(_container.Count == startCount + 1, "Count should be startCount + 1 after the first Add, got " + _container.Count)
        ok = ok && step
        step = assert_true(_container.GetAt("DupTest") == arresteeA, "First Add did not store the expected payload")
        ok = ok && step

        _container.AddElement(arresteeB, "DupTest")
        step = assert_true(_container.Count == startCount + 1, "A duplicate Add changed Count to " + _container.Count)
        ok = ok && step
        step = assert_true(_container.GetAt("DupTest") == arresteeA, "A duplicate Add OVERWROTE the existing payload")
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after a rejected duplicate Add")
        ok = ok && step

        ; --- removing a key that isn't there is a no-op ---
        _container.RemoveElement("DupTest_DoesNotExist", dispel = false)
        step = assert_true(_container.Count == startCount + 1, "Removing a missing key changed Count to " + _container.Count)
        ok = ok && step
        step = assert_true(_container.GetAt("DupTest") == arresteeA, "Removing a missing key disturbed an existing entry")
        ok = ok && step

        ; --- remove, then a second remove of the same key is a no-op ---
        _container.RemoveElement("DupTest", dispel = false)
        step = assert_true(_container.Count == startCount, "Count should be back to startCount after Remove, got " + _container.Count)
        ok = ok && step
        step = assert_true(!_container.HasKey("DupTest") && _container.GetAt("DupTest") == none, "Removed key is still retrievable")
        ok = ok && step
        _container.RemoveElement("DupTest", dispel = false)
        step = assert_true(_container.Count == startCount, "A second Remove of the same key changed Count to " + _container.Count)
        ok = ok && step

        ; --- same key, 50 add/remove cycles with alternating payloads: no stale state ---
        int i = 0
        ActiveMagicEffect expected = none
        while (i < 50)
            if ((i % 2) == 0)
                expected = arresteeA
            else
                expected = arresteeB
            endif

            _container.AddElement(expected, "DupTestCycle")
            if (_container.GetAt("DupTestCycle") != expected || _container.Count != startCount + 1)
                step = assert_true(false, "Cycle " + i + ": re-added key returned the wrong payload or Count is off (Count " + _container.Count + ")")
                ok = false
                i = 50 ; stop early, the state is already known bad
            else
                _container.RemoveElement("DupTestCycle", dispel = false)
                i += 1
            endif
        endWhile

        step = assert_true(_container.Count == startCount, "Container did not return to its original Count, got " + _container.Count)
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after the add/remove cycles")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

; ----------------------------------------------------------
;   Concurrency: several worker threads hit one container at once
;
;   Papyrus can switch between threads whenever a script makes a call, and AddElement/
;   RemoveElement are multi-step (read Count, write a slot, write two maps, bump Count). Two
;   actors registering in the same window could read the same Count and overwrite each other.
;   Worker threads here are separate stacks: the test fires the same SKSE mod event once per
;   worker, and each delivery runs OnConcurrencyWorker on its own stack, all against the same
;   container.
; ----------------------------------------------------------

RPB_ActiveMagicEffectContainer __concurrencyContainer
bool[] __concurrencyDone
int __concurrencyOpsPerWorker = 20

event OnConcurrencyWorker(string asEventName, string asMode, float afWorkerIndex, Form akSender)
    int worker = afWorkerIndex as int
    int ops = __concurrencyOpsPerWorker
    int i = 0

    while (i < ops)
        if (asMode == "add")
            __concurrencyContainer.AddElement(none, "Concurrent_" + worker + "_" + i)
        elseif (asMode == "remove")
            __concurrencyContainer.RemoveElement("Concurrent_" + worker + "_" + i, dispel = false)
        else ; "mixed": add key i, then remove this worker's key from 5 iterations ago
            __concurrencyContainer.AddElement(none, "Concurrent_" + worker + "_" + i)
            if (i >= 5)
                __concurrencyContainer.RemoveElement("Concurrent_" + worker + "_" + (i - 5), dispel = false)
            endif
        endif
        i += 1
    endWhile

    ; Each worker only ever writes its own slot - no shared counter to race on
    __concurrencyDone[worker] = true
endEvent

;/
    Starts @aiWorkers workers in @asMode and waits (up to ~3 minutes) until every one reports
    done. Returns false if any never finished - which itself means a worker died mid-operation.
/;
bool function __RunConcurrencyWave(string asMode, int aiWorkers)
    __concurrencyDone = new bool[16]

    int i = 0
    while (i < aiWorkers)
        self.SendModEvent("RPB_ConcurrencyWorker", asMode, i)
        i += 1
    endWhile

    float waited = 0.0
    bool allDone = false
    while (!allDone && waited < 180.0)
        Utility.Wait(0.5)
        waited += 0.5

        allDone = true
        i = 0
        while (i < aiWorkers)
            if (!__concurrencyDone[i])
                allDone = false
            endif
            i += 1
        endWhile
    endWhile

    return allDone
endFunction

;/
    Checks which of the workers' keys are present. @asMode "add": all of them; "remove": none;
    "mixed": only each worker's last 5 keys. Returns the number of wrong answers.
/;
int function __CountConcurrentKeyMismatches(RPB_ActiveMagicEffectContainer apContainer, string asMode, int aiWorkers, int aiOps)
    int mismatches = 0
    bool shouldExist = false
    int w = 0
    int k = 0

    while (w < aiWorkers)
        k = 0
        while (k < aiOps)
            if (asMode == "add")
                shouldExist = true
            elseif (asMode == "remove")
                shouldExist = false
            else
                shouldExist = k >= aiOps - 5
            endif

            if (apContainer.HasKey("Concurrent_" + w + "_" + k) != shouldExist)
                mismatches += 1
            endif
            k += 1
        endWhile
        w += 1
    endWhile

    return mismatches
endFunction

;/
    Three waves against the live ArresteeList (which must start empty - a corrupted run is
    cleaned up with DebugForceReset(), which is only safe on an empty list): 8 workers adding 20
    keys each; the same 8 removing them; then 8 workers each doing add-then-remove-5-back for 20
    iterations, leaving 5 keys per worker. After every wave: expected Count, both maps in sync,
    and every key present or absent exactly as expected. Any lost or overwritten entry, or a
    hole left behind by two workers reading the same Count, fails one of those.
/;
state Test_ActiveMagicEffectContainer_ConcurrentAccess
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int WORKERS = 8
        int OPS = 20

        if (_container.Count != 0)
            log("ArresteeList already holds " + _container.Count + " entries - this test needs it empty (a corrupted run is repaired with a full reset)")
            display_result(false)
            return
        endif

        __concurrencyContainer = _container
        __concurrencyOpsPerWorker = OPS
        self.RegisterForModEvent("RPB_ConcurrencyWorker", "OnConcurrencyWorker")

        bool ok = true
        bool step = false
        int mismatches = 0
        string problem = ""
        int w = 0
        int k = 0

        ; --- wave 1: concurrent adds ---
        step = self.__RunConcurrencyWave("add", WORKERS)
        step = assert_true(step, "Wave 1 (concurrent adds): a worker never finished")
        ok = ok && step
        mismatches = self.__CountConcurrentKeyMismatches(_container, "add", WORKERS, OPS)
        step = assert_true(mismatches == 0, "Wave 1: " + mismatches + " key(s) missing after concurrent adds (lost or overwritten entries)")
        ok = ok && step
        step = assert_true(_container.Count == WORKERS * OPS, "Wave 1: Count is " + _container.Count + ", expected " + (WORKERS * OPS))
        ok = ok && step
        problem = _container.ValidateIndexConsistency()
        step = assert_true(problem == "", "Wave 1: index maps inconsistent: " + problem)
        ok = ok && step

        ; --- wave 2: concurrent removes ---
        step = self.__RunConcurrencyWave("remove", WORKERS)
        step = assert_true(step, "Wave 2 (concurrent removes): a worker never finished")
        ok = ok && step
        mismatches = self.__CountConcurrentKeyMismatches(_container, "remove", WORKERS, OPS)
        step = assert_true(mismatches == 0, "Wave 2: " + mismatches + " key(s) still present after concurrent removes")
        ok = ok && step
        step = assert_true(_container.Count == 0, "Wave 2: Count is " + _container.Count + ", expected 0")
        ok = ok && step
        problem = _container.ValidateIndexConsistency()
        step = assert_true(problem == "", "Wave 2: index maps inconsistent: " + problem)
        ok = ok && step

        ; --- wave 3: concurrent adds and removes interleaved ---
        step = self.__RunConcurrencyWave("mixed", WORKERS)
        step = assert_true(step, "Wave 3 (concurrent mixed): a worker never finished")
        ok = ok && step
        mismatches = self.__CountConcurrentKeyMismatches(_container, "mixed", WORKERS, OPS)
        step = assert_true(mismatches == 0, "Wave 3: " + mismatches + " wrong key state(s) after mixed concurrent add/remove")
        ok = ok && step
        step = assert_true(_container.Count == WORKERS * 5, "Wave 3: Count is " + _container.Count + ", expected " + (WORKERS * 5))
        ok = ok && step
        problem = _container.ValidateIndexConsistency()
        step = assert_true(problem == "", "Wave 3: index maps inconsistent: " + problem)
        ok = ok && step

        ; --- wave 4: twice the contention, 16 workers interleaving adds and removes. Wave 3's
        ; survivors use the same key names for workers 0-7, so clear them out sequentially first ---
        if (ok)
            w = 0
            while (w < WORKERS)
                k = 0
                while (k < OPS)
                    if (_container.HasKey("Concurrent_" + w + "_" + k))
                        _container.RemoveElement("Concurrent_" + w + "_" + k, dispel = false)
                    endif
                    k += 1
                endWhile
                w += 1
            endWhile

            step = self.__RunConcurrencyWave("mixed", 16)
            step = assert_true(step, "Wave 4 (16 concurrent workers): a worker never finished")
            ok = ok && step
            mismatches = self.__CountConcurrentKeyMismatches(_container, "mixed", 16, OPS)
            step = assert_true(mismatches == 0, "Wave 4: " + mismatches + " wrong key state(s) with 16 concurrent workers")
            ok = ok && step
            step = assert_true(_container.Count == 16 * 5, "Wave 4: Count is " + _container.Count + ", expected " + (16 * 5))
            ok = ok && step
            problem = _container.ValidateIndexConsistency()
            step = assert_true(problem == "", "Wave 4: index maps inconsistent: " + problem)
            ok = ok && step
        endif

        ; --- cleanup, sequentially. If anything above went wrong the state may be corrupt, so
        ; fall back to a full reset (safe: the list started empty) rather than leave it broken ---
        self.UnregisterForModEvent("RPB_ConcurrencyWorker")
        if (ok)
            w = 0
            while (w < 16)
                k = 0
                while (k < OPS)
                    if (_container.HasKey("Concurrent_" + w + "_" + k))
                        _container.RemoveElement("Concurrent_" + w + "_" + k, dispel = false)
                    endif
                    k += 1
                endWhile
                w += 1
            endWhile
        endif

        if (!ok || _container.Count != 0 || _container.ValidateIndexConsistency() != "")
            log("Concurrency test left the container unclean - forcing a full reset of the (previously empty) ArresteeList")
            _container.DebugForceReset()
        endif

        log("CONCURRENCY: " + WORKERS + " workers x " + OPS + " ops per wave (16 in the last), final Count " + _container.Count)
        display_result(ok)
    endFunction
endState

;/
    A thread that dies mid-Add/Remove (a runtime error skips the release) would leave the
    container's thread lock held forever. The bounded wait must force-take it rather than
    deadlock the list. Simulates exactly that stuck state, then does a normal Add: it must
    complete after the timeout (~5s, the container logs an error line for that on purpose), the
    entry must exist, the maps stay in sync, and ordinary calls work again afterwards.
/;
state Test_ActiveMagicEffectContainer_StuckLockSelfHeals
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        bool ok = true
        bool step = false

        _container.DebugSimulateStuckLock()

        float bench = StartBenchmark()
        _container.AddElement(none, "StuckLockTest")
        int waitedMs = EndBenchmark(bench, "Add against a stuck lock (self-heal)")

        step = assert_true(_container.HasKey("StuckLockTest"), "The Add never completed after the stuck lock should have been force-released")
        ok = ok && step
        step = assert_true(_container.Count == startCount + 1, "Count should be " + (startCount + 1) + " after the healed Add, got " + _container.Count)
        ok = ok && step
        ; It should have waited for a real timeout, not sailed straight through
        step = assert_true(waitedMs >= 2000, "The Add returned after only " + waitedMs + "ms - it did not actually wait on the stuck lock")
        ok = ok && step

        ; The lock must be genuinely released again: a second Add/Remove must be fast
        bench = StartBenchmark()
        _container.RemoveElement("StuckLockTest", dispel = false)
        int normalMs = EndBenchmark(bench, "Remove after the lock healed")
        step = assert_true(normalMs < 2000, "Remove took " + normalMs + "ms - the container is still stuck on its thread lock")
        ok = ok && step

        step = assert_true(_container.Count == startCount, "Container did not return to its original Count, got " + _container.Count)
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after the stuck-lock self-heal")
        ok = ok && step

        display_result(ok)
    endFunction
endState

;/
    Add and Remove must never allocate JContainers objects: the container's two maps are created
    once, and everything after is reads and writes into them. A leak would show as a map handle
    that changes across many operations, or one that stops existing. There is no global
    object-count API in this JContainers version, so this checks the handles directly. Also
    exercises the reverse-map rebuild (which must release the old map and create exactly one new
    one) five times and checks the forward map's handle never moves.
/;
state Test_ActiveMagicEffectContainer_HandleStability
    function Setup()
        RPB_ActiveMagicEffectContainer _container = API.Arrest.GetAliasByName("ArresteeList") as RPB_ActiveMagicEffectContainer
        int startCount = _container.Count
        bool ok = true
        bool step = false

        ; Touch the container first so any lazy init has already happened
        step = _container.HasKey("HandleTest")

        int keyHandle = _container.DebugGetKeyToIndexHandle()
        int indexHandle = _container.DebugGetIndexToKeyHandle()

        step = assert_true(keyHandle != 0 && JValue.isExists(keyHandle), "key -> index map handle " + keyHandle + " is unset or doesn't exist")
        ok = ok && step
        step = assert_true(indexHandle != 0 && JValue.isExists(indexHandle), "index -> key map handle " + indexHandle + " is unset or doesn't exist")
        ok = ok && step

        int i = 0
        while (i < 200)
            _container.AddElement(none, "HandleTest")
            _container.RemoveElement("HandleTest", dispel = false)
            i += 1
        endWhile

        step = assert_true(_container.DebugGetKeyToIndexHandle() == keyHandle, "key -> index handle changed during 200 add/remove cycles: " + keyHandle + " -> " + _container.DebugGetKeyToIndexHandle())
        ok = ok && step
        step = assert_true(_container.DebugGetIndexToKeyHandle() == indexHandle, "index -> key handle changed during 200 add/remove cycles: " + indexHandle + " -> " + _container.DebugGetIndexToKeyHandle())
        ok = ok && step

        ; Rebuild path: each cycle drops the reverse map and lets the next call recreate it
        int rebuilt = 0
        i = 0
        while (i < 5)
            _container.DebugSimulateMissingReverseIndex()
            step = _container.HasKey("HandleTest")

            rebuilt = _container.DebugGetIndexToKeyHandle()
            step = assert_true(rebuilt != 0 && JValue.isExists(rebuilt), "Rebuild " + i + ": reverse map handle " + rebuilt + " is unset or doesn't exist")
            ok = ok && step
            step = assert_true(_container.DebugGetKeyToIndexHandle() == keyHandle, "Rebuild " + i + ": the forward map handle changed")
            ok = ok && step
            i += 1
        endWhile

        step = assert_true(_container.Count == startCount, "Container did not return to its original Count, got " + _container.Count)
        ok = ok && step
        step = self.__AssertContainerInSync(_container, "after the handle stability run")
        ok = ok && step

        display_result(ok)
    endFunction
endState

; ==========================================================
;   RPB_ThreadLock (JAtomic-based mutual exclusion between Papyrus threads)
;
;   42 checks the JAtomic primitives really behave as a lock needs, 43 is the "is it a true
;   lock" proof (worker threads against a deliberately racy critical section, with an unlocked
;   control to show the probe can actually see a race), 44 checks atomic creation of registered
;   locks under contention and stuck-lock recovery. (Tests 45/46, a one-time head-to-head
;   against the container's earlier Busy-state guard, were retired once the container switched
;   to the thread lock; the numbers are in TROUBLESHOOTING_NOTES.md.)
; ==========================================================

; Shared state for the probe workers. Everything here is deliberately plain script variables,
; the kind of state a real lock has to protect.
int __probeLock
int __probeCounter
int __probeInside
int __probeViolations
int __probeIterations = 10
bool[] __probeDone
int[] __probeHandles
string __probeName

;/ The yield point inside the critical section. A plain call, or, when harsh, a latent wait, which suspends the thread while it still holds the lock - the hardest case for a lock. /;
function __ProbeYield(bool abHarsh)
    if (abHarsh)
        Utility.WaitMenuMode(0.005)
    endif
endFunction

event OnThreadLockProbeWorker(string asEventName, string asMode, float afWorkerIndex, Form akSender)
    int worker = afWorkerIndex as int

    if (asMode == "registry")
        __probeHandles[worker] = RPB_ThreadLock.Get(__probeName)
        __probeDone[worker] = true
        return
    endif

    bool useLock = asMode == "lock" || asMode == "lock_wait"
    bool harsh = asMode == "control_wait" || asMode == "lock_wait"
    int value = 0
    int i = 0

    while (i < __probeIterations)
        if (useLock)
            RPB_ThreadLock.Acquire(__probeLock)
        endif

        ; Critical section: read-modify-write of shared state with a yield point in the middle.
        ; If two threads are ever inside at once, the second sees __probeInside already set.
        if (__probeInside != 0)
            __probeViolations += 1
        endif
        __probeInside = 1
        value = __probeCounter
        self.__ProbeYield(harsh)
        __probeCounter = value + 1
        __probeInside = 0

        if (useLock)
            RPB_ThreadLock.Release(__probeLock)
        endif

        i += 1
    endWhile

    __probeDone[worker] = true
endEvent

;/ Runs @aiWorkers probe workers in @asMode and waits for all of them. False if one never finished. /;
bool function __RunProbeWave(string asMode, int aiWorkers)
    __probeCounter = 0
    __probeInside = 0
    __probeViolations = 0
    __probeDone = new bool[16]
    __probeHandles = new int[16]

    int i = 0
    while (i < aiWorkers)
        self.SendModEvent("RPB_ThreadLockProbe", asMode, i)
        i += 1
    endWhile

    float waited = 0.0
    bool allDone = false
    while (!allDone && waited < 180.0)
        Utility.Wait(0.25)
        waited += 0.25

        allDone = true
        i = 0
        while (i < aiWorkers)
            if (!__probeDone[i])
                allDone = false
            endif
            i += 1
        endWhile
    endWhile

    return allDone
endFunction

;/
    Single-threaded: does JAtomic behave the way a lock needs? Logs the raw values it returns.
    A missing native would return 0 for everything (a fake lock that always "acquires"), so the
    second acquire failing is the key assertion.
/;
state Test_ThreadLock_PrimitiveSemantics
    function Setup()
        bool ok = true
        bool step = false

        step = assert_true(RPB_ThreadLock.IsWorking(), "RPB_ThreadLock.IsWorking() is false - the JAtomic natives don't behave like a lock here")
        ok = ok && step

        ; --- raw primitives, on a private lock object ---
        int lockObj = RPB_ThreadLock.CreatePrivate()

        int cas1 = JAtomic.compareExchangeInt(lockObj, ".locked", 1, 0)
        int cas2 = JAtomic.compareExchangeInt(lockObj, ".locked", 1, 0)
        int exch = JAtomic.exchangeInt(lockObj, ".locked", 0)
        int add1 = JAtomic.fetchAddInt(lockObj, ".counter", 5, 0, true)
        int add2 = JAtomic.fetchAddInt(lockObj, ".counter", 5, 0, true)
        int counterNow = JMap.getInt(lockObj, "counter")
        log("JATOMIC raw: compareExchange #1 -> " + cas1 + " (want 0), #2 -> " + cas2 + " (want 1), exchange -> " + exch + " (want 1), fetchAdd #1 -> " + add1 + " (want 0), #2 -> " + add2 + " (want 5), counter now " + counterNow + " (want 10)")

        ; --- informational: what does compareExchangeObj actually do? (An earlier RPB_ThreadLock.Get()
        ; relied on it to register locks under a nested JDB path and got private, unshared locks
        ; back; this records the real behavior. Nothing here is asserted.) ---
        int diagMap = JMap.object()
        JValue.retain(diagMap)
        int diagChild = JMap.object()
        JValue.retain(diagChild)
        int objSingle = JAtomic.compareExchangeObj(diagMap, ".slot", diagChild, 0, true)
        int storedSingle = JMap.getObj(diagMap, "slot")
        int objNested = JAtomic.compareExchangeObj(diagMap, ".a.b", diagChild, 0, true)
        int storedNested = JValue.solveObj(diagMap, ".a.b")
        int objRoot = JAtomic.compareExchangeObj(JDB.root(), ".RPB_T42_Diag", diagChild, 0, true)
        int storedRoot = JDB.solveObj(".RPB_T42_Diag")
        log("JATOMIC compareExchangeObj (child handle " + diagChild + "): single-level on a private map returned " + objSingle + ", stored " + storedSingle + " | two-level (.a.b) returned " + objNested + ", stored " + storedNested + " | single-level on JDB.root() returned " + objRoot + ", stored " + storedRoot)
        JMap.removeKey(JDB.root(), "RPB_T42_Diag")
        JValue.release(diagChild)
        JValue.release(diagMap)

        step = assert_true(cas1 == 0, "First compareExchange should return the previous value 0, got " + cas1)
        ok = ok && step
        step = assert_true(cas2 == 1, "Second compareExchange should fail and return 1, got " + cas2)
        ok = ok && step
        step = assert_true(exch == 1, "exchange should return the previous value 1, got " + exch)
        ok = ok && step
        step = assert_true(add1 == 0 && add2 == 5 && counterNow == 10, "fetchAdd should return the previous value each time (0 then 5) and leave 10, got " + add1 + ", " + add2 + ", " + counterNow)
        ok = ok && step

        ; --- TryAcquire / Release ---
        step = assert_true(RPB_ThreadLock.TryAcquire(lockObj), "TryAcquire on a free lock should succeed")
        ok = ok && step
        step = assert_true(!RPB_ThreadLock.TryAcquire(lockObj), "TryAcquire on a held lock should fail")
        ok = ok && step
        RPB_ThreadLock.Release(lockObj)
        step = assert_true(RPB_ThreadLock.TryAcquire(lockObj), "TryAcquire after Release should succeed")
        ok = ok && step
        RPB_ThreadLock.Release(lockObj)
        FastMap_Release(lockObj)

        ; --- registry: same name -> same lock, different names -> different locks ---
        string suffix = ((Utility.GetCurrentRealTime() * 1000.0) as int) as string
        string nameA = "T42_A_" + suffix
        string nameB = "T42_B_" + suffix
        string nameNeg = "T42_n5_3_" + suffix
        string nameHyphen = "T42_-5_3_" + suffix

        int handleA = RPB_ThreadLock.Get(nameA)
        int handleA2 = RPB_ThreadLock.Get(nameA)
        int handleB = RPB_ThreadLock.Get(nameB)
        step = assert_true(handleA != 0 && JValue.isExists(handleA), "Get() returned an invalid handle: " + handleA)
        ok = ok && step
        step = assert_true(handleA == handleA2, "Get() with the same name returned different handles: " + handleA + " vs " + handleA2)
        ok = ok && step
        step = assert_true(handleB != 0 && handleB != handleA, "Get() with a different name should return a different lock: " + handleA + " vs " + handleB)
        ok = ok && step
        step = assert_true(RPB_ThreadLock.TryAcquire(handleA) && RPB_ThreadLock.TryAcquire(handleB), "Registered locks should be independent and free at creation")
        ok = ok && step
        step = assert_true(!RPB_ThreadLock.TryAcquire(handleA), "A registered lock that is held should refuse a second acquire")
        ok = ok && step
        RPB_ThreadLock.Release(handleA)
        RPB_ThreadLock.Release(handleB)

        int handleNeg = RPB_ThreadLock.Get(nameNeg)
        step = assert_true(handleNeg != 0 && RPB_ThreadLock.Get(nameNeg) == handleNeg, "A name built from a negative id segment (n5) didn't round-trip")
        ok = ok && step

        ; Informational: does a literal '-' in a name survive the JContainers path syntax?
        int handleHyphen = RPB_ThreadLock.Get(nameHyphen)
        bool hyphenOk = handleHyphen != 0 && RPB_ThreadLock.Get(nameHyphen) == handleHyphen
        log("THREADLOCK names: a '-' in a lock name " + hyphenOk + " (the container avoids it by writing negative ids as n<id> anyway)")

        RPB_ThreadLock.Forget(nameA)
        RPB_ThreadLock.Forget(nameB)
        RPB_ThreadLock.Forget(nameNeg)
        RPB_ThreadLock.Forget(nameHyphen)

        display_result(ok)
    endFunction
endState

;/
    The "is it a true lock" proof. N worker threads run a critical section that is deliberately
    unsafe on its own: read a shared counter, yield, write counter + 1, with a flag that any
    second thread entering at the same time trips. Four runs:
      control        no lock, the yield is just a function call
      lock           locked,  the yield is just a function call
      control_wait   no lock, the yield is a latent wait (the thread is suspended mid-section)
      lock_wait      locked,  same latent wait: the lock must hold across a suspension
    Locked runs must show ZERO violations and the exact counter. The harsh control must show
    races (violations or lost updates) - if it doesn't, the probe can't see a race and a clean
    locked run would prove nothing, so that fails as "inconclusive" instead of passing.
/;
state Test_ThreadLock_MutualExclusion
    function Setup()
        int WORKERS = 8
        int expected = WORKERS * __probeIterations

        if (!RPB_ThreadLock.IsWorking())
            log("RPB_ThreadLock.IsWorking() is false - the JAtomic natives don't behave like a lock here, aborting")
            display_result(false)
            return
        endif

        __probeLock = RPB_ThreadLock.CreatePrivate()
        self.RegisterForModEvent("RPB_ThreadLockProbe", "OnThreadLockProbeWorker")

        bool ok = true
        bool step = false
        bool finished = false

        finished = self.__RunProbeWave("control", WORKERS)
        int controlCounter = __probeCounter
        int controlViolations = __probeViolations
        step = assert_true(finished, "control run: a worker never finished")
        ok = ok && step

        finished = self.__RunProbeWave("lock", WORKERS)
        int lockCounter = __probeCounter
        int lockViolations = __probeViolations
        step = assert_true(finished, "lock run: a worker never finished")
        ok = ok && step
        step = assert_true(lockViolations == 0 && lockCounter == expected, "LOCKED run (function-call yield) broke mutual exclusion: " + lockViolations + " violation(s), counter " + lockCounter + " of " + expected)
        ok = ok && step

        finished = self.__RunProbeWave("control_wait", WORKERS)
        int controlWaitCounter = __probeCounter
        int controlWaitViolations = __probeViolations
        step = assert_true(finished, "control_wait run: a worker never finished")
        ok = ok && step
        step = assert_true(controlWaitViolations > 0 || controlWaitCounter != expected, "Inconclusive: the UNLOCKED control with a latent wait showed no race (0 violations, counter " + controlWaitCounter + " of " + expected + "), so a clean locked run would prove nothing")
        ok = ok && step

        finished = self.__RunProbeWave("lock_wait", WORKERS)
        int lockWaitCounter = __probeCounter
        int lockWaitViolations = __probeViolations
        step = assert_true(finished, "lock_wait run: a worker never finished")
        ok = ok && step
        step = assert_true(lockWaitViolations == 0 && lockWaitCounter == expected, "LOCKED run (latent wait inside) broke mutual exclusion: " + lockWaitViolations + " violation(s), counter " + lockWaitCounter + " of " + expected)
        ok = ok && step

        self.UnregisterForModEvent("RPB_ThreadLockProbe")
        FastMap_Release(__probeLock)

        log("MUTUAL EXCLUSION (" + WORKERS + " workers x " + __probeIterations + ", expected counter " + expected + ") - control: counter " + controlCounter + ", " + controlViolations + " violation(s) | lock: counter " + lockCounter + ", " + lockViolations + " | control+wait: counter " + controlWaitCounter + ", " + controlWaitViolations + " | lock+wait: counter " + lockWaitCounter + ", " + lockWaitViolations)
        Debug.Notification("Lock+wait: counter " + lockWaitCounter + "/" + expected + ", violations " + lockWaitViolations + " (control " + controlWaitCounter + ", " + controlWaitViolations + ")")

        display_result(ok)
    endFunction
endState

;/
    16 workers ask for the SAME brand-new lock name at the same moment: the registry's atomic
    compare-exchange must install exactly one object and hand every caller that same handle.
    Then a lock is left held on purpose and Acquire() must give up waiting and force-take it
    after a real wait (the error line it logs is expected), after which normal use is fast again.
/;
state Test_ThreadLock_RegistryAndStuckLock
    function Setup()
        bool ok = true
        bool step = false

        string suffix = ((Utility.GetCurrentRealTime() * 1000.0) as int) as string
        __probeName = "T44_Reg_" + suffix
        self.RegisterForModEvent("RPB_ThreadLockProbe", "OnThreadLockProbeWorker")

        step = self.__RunProbeWave("registry", 16)
        step = assert_true(step, "registry run: a worker never finished")
        ok = ok && step

        int first = __probeHandles[0]
        int mismatches = 0
        int i = 0
        while (i < 16)
            if (__probeHandles[i] != first)
                mismatches += 1
            endif
            i += 1
        endWhile
        step = assert_true(first != 0 && JValue.isExists(first), "Registry handle is invalid: " + first)
        ok = ok && step
        step = assert_true(mismatches == 0, mismatches + " of 16 concurrent Get() calls returned a DIFFERENT lock than worker 0 - creation isn't atomic")
        ok = ok && step
        step = assert_true(RPB_ThreadLock.Get(__probeName) == first, "A later Get() for the same name returned a different lock")
        ok = ok && step
        log("THREADLOCK registry: 16 concurrent Get() -> " + mismatches + " mismatch(es), handle " + first)

        self.UnregisterForModEvent("RPB_ThreadLockProbe")

        ; --- stuck lock: hold it, then try to acquire it again with a short wait budget ---
        int stuck = RPB_ThreadLock.Get("T44_Stuck_" + suffix)
        step = assert_true(RPB_ThreadLock.Acquire(stuck), "First Acquire on a free lock should succeed normally")
        ok = ok && step

        float bench = StartBenchmark()
        bool normal = RPB_ThreadLock.Acquire(stuck, 25)
        int waitedMs = EndBenchmark(bench, "Acquire against a held lock (25 tries, then force-take)")
        step = assert_true(!normal, "Acquire against a held lock should report it had to force-take it")
        ok = ok && step
        step = assert_true(waitedMs >= 500, "Acquire returned after only " + waitedMs + "ms - it did not actually wait on the held lock")
        ok = ok && step

        RPB_ThreadLock.Release(stuck)
        bench = StartBenchmark()
        bool afterRelease = RPB_ThreadLock.Acquire(stuck)
        int quickMs = EndBenchmark(bench, "Acquire after Release")
        RPB_ThreadLock.Release(stuck)
        step = assert_true(afterRelease && quickMs < 300, "Acquire after Release should be immediate and normal, got " + afterRelease + " in " + quickMs + "ms")
        ok = ok && step

        RPB_ThreadLock.Forget(__probeName)
        RPB_ThreadLock.Forget("T44_Stuck_" + suffix)

        display_result(ok)
    endFunction
endState

; ==========================================================
;   Await<T>Reference investigation (tests 47-51)
;
;   AwaitPrisonerReference/AwaitArresteeReference/AwaitCaptorReference add a spell to an actor
;   (its magic effect starts LATER, on its own thread, and registers the actor in the list from
;   OnEffectStart) and poll the list with exponential backoff until the registration shows up.
;   These tests measure that mechanism from the outside using the same public pieces
;   (RPB_Utility.Ensure...SpellAndBinding + the lists), so nothing in production is changed:
;   how long each phase takes, what happens with several actors at once, and what the effect
;   start needs. Every wait has a hard timeout, so a stall is reported as data instead of
;   freezing the test.
; ==========================================================

int __burstRegistered
int __burstMaxMs
int __burstAvgMs
int __burstTotalMs

int function __Ms(float afSeconds)
    return (afSeconds * 1000.0) as int
endFunction

;/ Adds the spell (and, for prisoners, the prison binding) for @asKind: "prisoner", "arrestee" or "captor". /;
function __EnsureKind(string asKind, Actor akActor, RPB_Prison apPrison)
    if (asKind == "prisoner")
        RPB_Utility.EnsurePrisonerSpellAndBinding(akActor, apPrison)
    elseif (asKind == "arrestee")
        RPB_Utility.EnsureArresteeSpellAndBinding(akActor, none)
    else
        RPB_Utility.EnsureCaptorSpellAndBinding(akActor)
    endif
endFunction

;/ Has @akActor been registered in the list for @asKind yet? Returns the registered reference or None. /;
RPB_ActorBase function __LookupKind(string asKind, Actor akActor, RPB_Prison apPrison)
    if (asKind == "prisoner")
        return apPrison.Prisoners.AtKeyEx(akActor) as RPB_ActorBase
    elseif (asKind == "arrestee")
        return (RPB_API.GetArrest()).Arrestees.AtKeyEx(akActor) as RPB_ActorBase
    endif

    return (RPB_API.GetArrest()).Captors.AtKeyEx(akActor) as RPB_ActorBase
endFunction

;/ Why hasn't this actor registered? Everything that could plausibly matter, at the moment of giving up. /;
function __LogNotRegistered(Actor akActor, string asKind, float afWaitedSeconds)
    log("NOT REGISTERED after " + (afWaitedSeconds as int) + "s: " + akActor + " (" + asKind + ") | has prisoner spell " + akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()) + ", arrestee spell " + akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell()) + ", captor spell " + akActor.HasSpell(RPB_Utility.RPB_CaptorSpell()) + " | disabled " + akActor.IsDisabled() + ", 3D loaded " + akActor.Is3DLoaded() + ", cell " + akActor.GetParentCell() + ", dead " + akActor.IsDead())
endFunction

;/
    Registers @aiCount freshly spawned actors as @asKind with NO waiting between the spell
    adds (or @afSpacing seconds apart), then polls (every ~25ms) until every one shows up in
    its list or 45s pass. Time-to-registered is measured per actor from its own spell add.
    Results are left in __burst* (registered count, max/average ms, total ms incl. optional
    Initialize()) and logged. Up to 16 actors.
/;
function __RunBurst(string asKind, int aiCount, float afSpacing, bool abInitialize)
    RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
    Actor[] actors = new Actor[16]
    float[] spellAt = new float[16]
    int[] regMs = new int[16]

    int i = 0
    while (i < aiCount)
        actors[i] = __SpawnTempActor()
        regMs[i] = -1
        i += 1
    endWhile

    float tStart = Utility.GetCurrentRealTime()
    i = 0
    while (i < aiCount)
        self.__EnsureKind(asKind, actors[i], prison)
        spellAt[i] = Utility.GetCurrentRealTime()
        if (afSpacing > 0.0 && i < aiCount - 1)
            Utility.Wait(afSpacing)
        endif
        i += 1
    endWhile

    int pending = aiCount
    float now = 0.0
    while (pending > 0 && (Utility.GetCurrentRealTime() - tStart) < 45.0)
        i = 0
        while (i < aiCount)
            if (regMs[i] < 0)
                if (self.__LookupKind(asKind, actors[i], prison))
                    now = Utility.GetCurrentRealTime()
                    regMs[i] = self.__Ms(now - spellAt[i])
                    pending -= 1
                endif
            endif
            i += 1
        endWhile

        if (pending > 0)
            Utility.Wait(0.025)
        endif
    endWhile

    if (abInitialize && asKind == "prisoner")
        i = 0
        while (i < aiCount)
            if (regMs[i] >= 0)
                (self.__LookupKind(asKind, actors[i], prison) as RPB_Prisoner).Initialize()
            endif
            i += 1
        endWhile
    endif
    __burstTotalMs = self.__Ms(Utility.GetCurrentRealTime() - tStart)

    __burstRegistered = 0
    __burstMaxMs = 0
    int sumMs = 0
    string perActor = ""
    i = 0
    while (i < aiCount)
        if (regMs[i] >= 0)
            __burstRegistered += 1
            sumMs += regMs[i]
            if (regMs[i] > __burstMaxMs)
                __burstMaxMs = regMs[i]
            endif
        else
            self.__LogNotRegistered(actors[i], asKind, Utility.GetCurrentRealTime() - spellAt[i])
        endif
        perActor += regMs[i] + " "
        i += 1
    endWhile

    __burstAvgMs = 0
    if (__burstRegistered > 0)
        __burstAvgMs = sumMs / __burstRegistered
    endif

    log("BURST " + asKind + " K=" + aiCount + " spacing " + afSpacing + "s: registered " + __burstRegistered + "/" + aiCount + " | ms from own spell add to registered: [" + perActor + "] avg " + __burstAvgMs + ", max " + __burstMaxMs + " | total " + __burstTotalMs + "ms" + self.__StringIf(abInitialize, " (incl. Initialize)"))
endFunction

string function __StringIf(bool abCondition, string asText)
    if (abCondition)
        return asText
    endif

    return ""
endFunction

;/
    Where does one await's ~1.7s go? For each kind, N actors one after another (1s apart, like
    the existing tests): the spell add, the wait until the effect registers the actor (polled
    every ~25ms, so overshoot is negligible), and Initialize() (prisoners), timed separately.
    Then the SAME number of fresh actors through the plain public await, to compare: the
    difference is what the exponential-backoff polling costs on top.
/;
state Test_Await_LatencyBreakdown
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_Arrest arrest = RPB_API.GetArrest()
        int N = 3
        bool ok = true

        string[] kinds = new string[3]
        kinds[0] = "prisoner"
        kinds[1] = "arrestee"
        kinds[2] = "captor"

        int k = 0
        while (k < 3)
            string kind = kinds[k]
            int sumSpell = 0
            int sumReg = 0
            int sumInit = 0
            int sumPlain = 0
            int missing = 0

            int i = 0
            while (i < N)
                Actor a = __SpawnTempActor()
                float t0 = Utility.GetCurrentRealTime()
                self.__EnsureKind(kind, a, prison)
                float tSpell = Utility.GetCurrentRealTime()

                RPB_ActorBase reg = none
                int polls = 0
                while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
                    reg = self.__LookupKind(kind, a, prison)
                    if (!reg)
                        Utility.Wait(0.025)
                        polls += 1
                    endif
                endWhile
                float tReg = Utility.GetCurrentRealTime()

                float tInit = tReg
                if (reg && kind == "prisoner")
                    (reg as RPB_Prisoner).Initialize()
                    tInit = Utility.GetCurrentRealTime()
                endif

                if (reg)
                    sumSpell += self.__Ms(tSpell - t0)
                    sumReg += self.__Ms(tReg - t0)
                    sumInit += self.__Ms(tInit - tReg)
                else
                    missing += 1
                    self.__LogNotRegistered(a, kind, tReg - t0)
                endif
                log("BREAKDOWN " + kind + " #" + i + ": spell add call " + self.__Ms(tSpell - t0) + "ms, registered after " + self.__Ms(tReg - t0) + "ms (" + polls + " polls), Initialize " + self.__Ms(tInit - tReg) + "ms, total " + self.__Ms(tInit - t0) + "ms")
                Utility.Wait(1.0)
                i += 1
            endWhile

            ; The same number of fresh actors through the plain public await
            i = 0
            while (i < N)
                Actor b = __SpawnTempActor()
                float tp = Utility.GetCurrentRealTime()
                if (kind == "prisoner")
                    prison.AwaitPrisonerReference(b)
                elseif (kind == "arrestee")
                    arrest.AwaitArresteeReference(b)
                else
                    arrest.AwaitCaptorReference(b)
                endif
                sumPlain += self.__Ms(Utility.GetCurrentRealTime() - tp)
                Utility.Wait(1.0)
                i += 1
            endWhile

            int done = N - missing
            if (done > 0)
                log("LATENCY " + kind + " (avg of " + done + "): spell add call " + (sumSpell / done) + "ms, registered after " + (sumReg / done) + "ms, Initialize " + (sumInit / done) + "ms, manual total " + ((sumReg + sumInit) / done) + "ms | plain AwaitReference avg " + (sumPlain / N) + "ms | polling overhead vs manual " + ((sumPlain / N) - ((sumReg + sumInit) / done)) + "ms")
            endif
            ok = assert_true(missing == 0, kind + ": " + missing + " actor(s) never registered within 30s") && ok
            k += 1
        endWhile

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    The multi-actor case: K prisoners get their spell at the same instant, nothing spaced.
    Runs K=3, 6 and 10 (cleaning up between runs). The interesting numbers: does time-to-
    registered grow with K (a serialized effect queue) or stay flat (parallel)? Does anyone
    fail to register? A stalled actor is reported with its state, this being the closest
    thing we have to a reproducer for the intermittent 23/24 hangs.
/;
state Test_Await_BurstPrisoners
    function Setup()
        bool ok = true

        __LogRuntimeState("burst prisoners start")
        self.__RunBurst("prisoner", 3, 0.0, false)
        ok = assert_true(__burstRegistered == 3, "K=3 burst: only " + __burstRegistered + "/3 registered") && ok
        __TeardownAllTempActors()
        Utility.Wait(3.0)

        self.__RunBurst("prisoner", 6, 0.0, false)
        ok = assert_true(__burstRegistered == 6, "K=6 burst: only " + __burstRegistered + "/6 registered") && ok
        __TeardownAllTempActors()
        Utility.Wait(3.0)

        self.__RunBurst("prisoner", 10, 0.0, false)
        ok = assert_true(__burstRegistered == 10, "K=10 burst: only " + __burstRegistered + "/10 registered") && ok

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Same burst for arrestees and captors (K=6 each), then prisoners spaced 1s apart (the
    workaround the tests currently use), to see whether spacing changes anything.
/;
state Test_Await_BurstOtherKinds
    function Setup()
        bool ok = true

        self.__RunBurst("arrestee", 6, 0.0, false)
        ok = assert_true(__burstRegistered == 6, "arrestees burst: only " + __burstRegistered + "/6 registered") && ok
        __TeardownAllTempActors()
        Utility.Wait(3.0)

        self.__RunBurst("captor", 6, 0.0, false)
        ok = assert_true(__burstRegistered == 6, "captors burst: only " + __burstRegistered + "/6 registered") && ok
        __TeardownAllTempActors()
        Utility.Wait(3.0)

        self.__RunBurst("prisoner", 6, 1.0, false)
        ok = assert_true(__burstRegistered == 6, "prisoners spaced 1s: only " + __burstRegistered + "/6 registered") && ok

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    What does the effect start depend on? One prisoner at a time under three conditions, each
    timed from the spell add to registration (30s cap): (a) spell added the instant the actor
    is spawned, (b) after letting the actor settle for 1s, (c) added to an actor that was
    disabled right after spawning. Logs Is3DLoaded / IsDisabled / cell at both ends.
/;
state Test_Await_EffectStartPrerequisites
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        int repeat = 0

        while (repeat < 2)
            int cond = 0
            while (cond < 3)
                Actor a = __SpawnTempActor()
                string label = "immediate"
                if (cond == 1)
                    Utility.Wait(1.0)
                    label = "after 1s settle"
                elseif (cond == 2)
                    a.Disable()
                    label = "disabled first"
                endif

                bool loadedBefore = a.Is3DLoaded()
                bool disabledBefore = a.IsDisabled()
                float t0 = Utility.GetCurrentRealTime()
                self.__EnsureKind("prisoner", a, prison)

                RPB_ActorBase reg = none
                while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
                    reg = self.__LookupKind("prisoner", a, prison)
                    if (!reg)
                        Utility.Wait(0.025)
                    endif
                endWhile
                float elapsed = Utility.GetCurrentRealTime() - t0

                if (reg)
                    log("PREREQ [" + label + "] round " + repeat + ": registered after " + self.__Ms(elapsed) + "ms | 3D loaded " + loadedBefore + " -> " + a.Is3DLoaded() + ", disabled " + disabledBefore + " -> " + a.IsDisabled() + ", cell " + a.GetParentCell())
                else
                    self.__LogNotRegistered(a, "prisoner", elapsed)
                    log("PREREQ [" + label + "] round " + repeat + ": DID NOT REGISTER in 30s")
                endif
                ; A disabled actor failing to register would itself be the finding, not a test failure;
                ; only the two ordinary conditions must register
                if (cond < 2)
                    ok = assert_true(reg != none, "[" + label + "] never registered within 30s") && ok
                endif

                Utility.Wait(1.0)
                cond += 1
            endWhile
            repeat += 1
        endWhile

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    What a group costs today versus what batching could do, N=5 prisoners: (1) one after
    another through the public AwaitPrisonerReference, exactly what EventManager's loops do;
    (2) all five spells first, then wait for all of them (and Initialize each).
/;
state Test_Await_GroupFlow
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        int N = 5
        bool ok = true

        Actor[] actors = new Actor[16]
        int i = 0
        while (i < N)
            actors[i] = __SpawnTempActor()
            i += 1
        endWhile

        float t0 = Utility.GetCurrentRealTime()
        i = 0
        while (i < N)
            prison.AwaitPrisonerReference(actors[i])
            i += 1
        endWhile
        int sequentialMs = self.__Ms(Utility.GetCurrentRealTime() - t0)
        log("GROUP sequential AwaitPrisonerReference x" + N + ": " + sequentialMs + "ms (" + (sequentialMs / N) + "ms each)")
        ok = assert_true(prison.Prisoners.Count >= N, "Sequential run registered fewer than " + N + " prisoners: " + prison.Prisoners.Count) && ok

        __TeardownAllTempActors()
        Utility.Wait(3.0)

        self.__RunBurst("prisoner", N, 0.0, true)
        log("GROUP burst x" + N + ": " + __burstTotalMs + "ms total (spells at once, wait for all, Initialize each) vs sequential " + sequentialMs + "ms")
        ok = assert_true(__burstRegistered == N, "Burst run registered only " + __burstRegistered + "/" + N) && ok

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Behavior after the Await changes (RPB_Utility.AwaitEntityReference): short capped polling
    that returns the moment the registration is seen, a bounded wait for the actor's 3D to load,
    and AwaitPrisonerReference no longer calling Initialize() on None.
      1. Polling overhead per kind: the same measurement as test 47 (manual poll at ~25ms vs the
         plain public await). Before the change the overhead was 417ms (prisoner), 204ms
         (arrestee) and 209ms (captor); now it should be well under those.
      2. An actor that never loads (disabled right after spawn): AwaitPrisonerReference must come
         back with None in roughly the load grace period (5s) instead of polling for minutes, log why,
         and not raise a runtime error (which would abort this test with no result).
      3. An actor that is ALREADY registered must come back immediately even if it is unloaded:
         load state must not delay a lookup that has nothing to wait for.
/;
state Test_Await_AfterFixes
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_Arrest arrest = RPB_API.GetArrest()
        int N = 3
        bool ok = true
        bool step = false

        string[] kinds = new string[3]
        kinds[0] = "prisoner"
        kinds[1] = "arrestee"
        kinds[2] = "captor"

        ; --- 1. polling overhead ---
        int k = 0
        while (k < 3)
            string kind = kinds[k]
            int sumManual = 0
            int sumPlain = 0
            int i = 0
            while (i < N)
                Actor a = __SpawnTempActor()
                float t0 = Utility.GetCurrentRealTime()
                self.__EnsureKind(kind, a, prison)
                RPB_ActorBase reg = none
                while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
                    reg = self.__LookupKind(kind, a, prison)
                    if (!reg)
                        Utility.Wait(0.025)
                    endif
                endWhile
                if (reg && kind == "prisoner")
                    (reg as RPB_Prisoner).Initialize()
                endif
                sumManual += self.__Ms(Utility.GetCurrentRealTime() - t0)
                Utility.Wait(1.0)

                Actor b = __SpawnTempActor()
                float tp = Utility.GetCurrentRealTime()
                RPB_ActorBase plainRef = none
                if (kind == "prisoner")
                    plainRef = prison.AwaitPrisonerReference(b)
                elseif (kind == "arrestee")
                    plainRef = arrest.AwaitArresteeReference(b)
                else
                    plainRef = arrest.AwaitCaptorReference(b)
                endif
                sumPlain += self.__Ms(Utility.GetCurrentRealTime() - tp)
                step = assert_true(reg != none && plainRef != none, kind + " #" + i + ": did not register (manual " + reg + ", plain " + plainRef + ")")
                ok = ok && step
                Utility.Wait(1.0)
                i += 1
            endWhile

            int overhead = (sumPlain / N) - (sumManual / N)
            int limit = 175
            if (kind == "prisoner")
                limit = 250
            endif
            log("AFTER FIX " + kind + ": manual avg " + (sumManual / N) + "ms, plain AwaitReference avg " + (sumPlain / N) + "ms, polling overhead " + overhead + "ms (was " + self.__StringIf(kind == "prisoner", "417") + self.__StringIf(kind == "arrestee", "204") + self.__StringIf(kind == "captor", "209") + "ms; limit " + limit + "ms)")
            step = assert_true(overhead < limit, kind + ": polling overhead " + overhead + "ms is not below " + limit + "ms")
            ok = ok && step
            k += 1
        endWhile

        ; --- 2. an actor that never loads: must return None promptly, without a runtime error ---
        Actor unloaded = __SpawnTempActor()
        unloaded.Disable()
        Utility.Wait(0.5)
        float tu = Utility.GetCurrentRealTime()
        RPB_Prisoner unloadedRef = prison.AwaitPrisonerReference(unloaded)
        int unloadedMs = self.__Ms(Utility.GetCurrentRealTime() - tu)
        log("AFTER FIX unloaded actor: AwaitPrisonerReference returned " + unloadedRef + " after " + unloadedMs + "ms (grace period is 5000ms; before the change: ~2 minutes of polling, then Initialize() on None)")
        step = assert_true(unloadedRef == none, "AwaitPrisonerReference on an unloaded actor should return None, got " + unloadedRef)
        ok = ok && step
        step = assert_true(unloadedMs < 9000, "Await on an unloaded actor took " + unloadedMs + "ms - it should give up within about the 5s load grace")
        ok = ok && step

        ; --- 3. already registered: must not wait, whatever the load state ---
        Actor loaded = __SpawnTempActor()
        RPB_Prisoner loadedRef = prison.AwaitPrisonerReference(loaded)
        step = assert_true(loadedRef != none, "Setup for the already-registered check failed: nothing registered")
        ok = ok && step
        loaded.Disable()
        Utility.Wait(0.5)
        float tl = Utility.GetCurrentRealTime()
        RPB_Prisoner againRef = prison.AwaitPrisonerReference(loaded)
        int againMs = self.__Ms(Utility.GetCurrentRealTime() - tl)
        log("AFTER FIX already registered (now disabled/unloaded): AwaitPrisonerReference returned " + againRef + " in " + againMs + "ms")
        step = assert_true(againRef == loadedRef && againMs < 3000, "An already-registered actor should be returned at once, got " + againRef + " after " + againMs + "ms")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Deterministic proof of what was making tests 22/23/24/47/48 stall after other tests had run.
    RPB_Prisoner.OnInitialize() returns before registering when the "Initialized" StorageVars flag
    (category "Jail") is already true. That flag is keyed by the actor's reference string and was left
    behind by an earlier, deleted temp actor with the same recycled FormID. Here the same stale flag is
    planted by hand on a fresh, loaded actor:
      1. with the flag set, adding the prisoner spell must NOT register the actor (4s watch);
      2. remove the spell, wipe the actor's state, add the spell again: it must register promptly.
    If (1) registers anyway, the theory is wrong and the failure message says so.
/;
state Test_Await_StaleInitializedFlag
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_StorageVars.SetBoolOnReference("Initialized", a, true, "Jail")
        step = assert_true(RPB_StorageVars.GetBoolOnReference("Initialized", a, "Jail"), "Could not plant the stale 'Initialized' flag")
        ok = ok && step

        self.__EnsureKind("prisoner", a, prison)
        float t0 = Utility.GetCurrentRealTime()
        RPB_ActorBase reg = none
        while (!reg && (Utility.GetCurrentRealTime() - t0) < 4.0)
            reg = self.__LookupKind("prisoner", a, prison)
            if (!reg)
                Utility.Wait(0.05)
            endif
        endWhile
        log("STALE FLAG: with 'Initialized' already true, registration after 4s watch -> " + reg + " (expected: not registered)")
        step = assert_true(reg == none, "The actor registered even though 'Initialized' was already true - the stale-flag theory does not hold")
        ok = ok && step

        ; Cure: take the spell off, wipe the actor's state, add the spell again
        a.RemoveSpell(RPB_Utility.RPB_PrisonerSpell())
        Utility.Wait(0.5)
        RPB_StorageVars.DeleteAllOnReference(a)
        step = assert_false(RPB_StorageVars.GetBoolOnReference("Initialized", a, "Jail"), "Wiping the actor's state did not clear the flag")
        ok = ok && step

        self.__EnsureKind("prisoner", a, prison)
        t0 = Utility.GetCurrentRealTime()
        reg = none
        while (!reg && (Utility.GetCurrentRealTime() - t0) < 8.0)
            reg = self.__LookupKind("prisoner", a, prison)
            if (!reg)
                Utility.Wait(0.05)
            endif
        endWhile
        log("STALE FLAG: after wiping the state and re-adding the spell, registered after " + self.__Ms(Utility.GetCurrentRealTime() - t0) + "ms -> " + reg)
        step = assert_true(reg != none, "The actor still did not register after the stale state was wiped")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

; ----------------------------------------------------------
;   Prisoner.Initialize() profile (test 54): a stopwatch that adds each step's elapsed time to a slot
; ----------------------------------------------------------

float __lapStart
int[] __lapTotals

function __LapBegin()
    __lapStart = Utility.GetCurrentRealTime()
endFunction

;/ Adds the time since the last LapBegin/LapEnd to slot @aiSlot and starts the next lap. /;
function __LapEnd(int aiSlot)
    float now = Utility.GetCurrentRealTime()
    __lapTotals[aiSlot] = __lapTotals[aiSlot] + self.__Ms(now - __lapStart)
    __lapStart = now
endFunction

;/
    Where do the ~1127ms of RPB_Prisoner.Initialize() go (81% of a prisoner await)? Initialize() is a
    fixed sequence of public calls, so this registers 3 prisoners the normal way, then replays
    Initialize()'s body on each one step by step with its own stopwatch, and prints the steps ranked by
    time. A control run of the real Initialize() on 3 more prisoners shows the replay matches it.
    Nothing in production is changed. Timer resolution is coarse (~10-16ms), so treat steps of a few
    ms as noise; the big ones stand out.
/;
state Test_Prisoner_InitializeProfile
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        int N = 3
        bool ok = true

        string[] names = new string[12]
        names[0] = "Prison.IsPrisoner check"
        names[1] = "SetSentence"
        names[2] = "RegisterSleepEvents = true"
        names[3] = "RegisterForTrackedStats"
        names[4] = "LockPrisonerSettings"
        names[5] = "Show* property writes (5)"
        names[6] = "DetermineStrippingType"
        names[7] = "DetermineClothingOutfit"
        names[8] = "SetReleaseLocation"
        names[9] = "UpdateInfamyLost"
        names[10] = "TriggerInfamyPenalty"
        names[11] = "error check + SetBool Initialized"

        __lapTotals = new int[16]

        ; --- replay of Initialize()'s body, step by step ---
        int i = 0
        while (i < N)
            Actor a = __SpawnTempActor()
            self.__EnsureKind("prisoner", a, prison)
            RPB_ActorBase reg = none
            float t0 = Utility.GetCurrentRealTime()
            while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
                reg = self.__LookupKind("prisoner", a, prison)
                if (!reg)
                    Utility.Wait(0.025)
                endif
            endWhile

            RPB_Prisoner p = reg as RPB_Prisoner
            if (!p)
                ok = assert_true(false, "Prisoner #" + i + " never registered, cannot profile") && ok
            else
                self.__LapBegin()

                bool isPrisoner = prison.IsPrisoner(p)
                self.__LapEnd(0)

                if (!p.Sentence)
                    p.SetSentence()
                endif
                self.__LapEnd(1)

                p.RegisterSleepEvents = true
                self.__LapEnd(2)

                p.RegisterForTrackedStats()
                self.__LapEnd(3)

                p.LockPrisonerSettings()
                self.__LapEnd(4)

                p.ShowSentence = true
                p.ShowReleaseTime = true
                p.ShowTimeLeftInSentence = true
                p.ShowTimeServed = true
                p.ShowBounty = true
                self.__LapEnd(5)

                p.DetermineStrippingType()
                self.__LapEnd(6)

                p.DetermineClothingOutfit()
                self.__LapEnd(7)

                p.SetReleaseLocation()
                self.__LapEnd(8)

                p.UpdateInfamyLost()
                self.__LapEnd(9)

                p.TriggerInfamyPenalty()
                self.__LapEnd(10)

                int errors = RPB_Memory.FastArray("<string>")
                if (!(p.WillBeStrippedNaked || p.WillBeStrippedToUnderwear))
                    errors = EnsureTrue(false, "Could not determine the stripping type for Prisoner " + p.Name, errors)
                endif
                if (!p.TeleportReleaseLocation)
                    errors = EnsureTrue(false, "Could not determine the release location for Prisoner " + p.Name, errors)
                endif
                bool hasErrors = RPB_Memory.FastArray_Size(errors) > 0
                p.SetBool("Initialized", true)
                self.__LapEnd(11)

                ; Calibration: an empty lap costs what the lap timer itself costs (Utility.GetCurrentRealTime() is an engine
                ; native, about one frame at ~90 FPS), and that cost is inside every step's number above
                self.__LapEnd(12)
            endif

            Utility.Wait(1.0)
            i += 1
        endWhile

        ; --- control: the real Initialize() on fresh prisoners ---
        int controlTotal = 0
        i = 0
        while (i < N)
            Actor c = __SpawnTempActor()
            self.__EnsureKind("prisoner", c, prison)
            RPB_ActorBase creg = none
            float tc = Utility.GetCurrentRealTime()
            while (!creg && (Utility.GetCurrentRealTime() - tc) < 30.0)
                creg = self.__LookupKind("prisoner", c, prison)
                if (!creg)
                    Utility.Wait(0.025)
                endif
            endWhile
            if (creg)
                float ti = Utility.GetCurrentRealTime()
                (creg as RPB_Prisoner).Initialize()
                controlTotal += self.__Ms(Utility.GetCurrentRealTime() - ti)
            endif
            Utility.Wait(1.0)
            i += 1
        endWhile

        ; --- report, ranked by time ---
        int grand = 0
        int k = 0
        while (k < 12)
            grand += __lapTotals[k]
            k += 1
        endWhile

        int timerOverhead = __lapTotals[12] / N
        log("INITIALIZE PROFILE timer: one lap costs ~" + timerOverhead + "ms by itself (an empty lap); every step below includes it")
        bool[] printed = new bool[12]
        int rank = 0
        while (rank < 12)
            int best = -1
            k = 0
            while (k < 12)
                if (!printed[k] && (best < 0 || __lapTotals[k] > __lapTotals[best]))
                    best = k
                endif
                k += 1
            endWhile
            printed[best] = true

            int avg = __lapTotals[best] / N
            int share = 0
            if (grand > 0)
                share = (__lapTotals[best] * 100) / grand
            endif
            int net = avg - timerOverhead
            if (net < 0)
                net = 0
            endif
            log("INITIALIZE PROFILE #" + (rank + 1) + ": " + names[best] + " - " + avg + "ms avg (" + share + "%), net of the timer ~" + net + "ms")
            rank += 1
        endWhile

        log("INITIALIZE PROFILE total: replay " + (grand / N) + "ms avg per prisoner vs the real Initialize() " + (controlTotal / N) + "ms avg")
        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

string function __PerOp(int aiTotalMs, int aiCount)
    float perOp = (aiTotalMs as float) / (aiCount as float)
    int hundredths = (perOp * 100.0) as int
    return (hundredths / 100) + "." + self.__StringIf((hundredths % 100) < 10, "0") + (hundredths % 100) + "ms"
endFunction

;/
    LockPrisonerSettings() is 64% of Prisoner.Initialize() (~813ms for ~68 settings, ~12ms each) and the
    profile can't say whether that is the Prison.X reads (each one is Config.IsXEnabled(hold) ->
    MCM.GetOption...(name, hold)), the path building in RPB_StorageVars.GetVarPathOnReference, or the
    JDB write itself. This times each part on its own, over batches (the timer is coarse), and prints
    the cost per operation and what that means for 68 settings. Nothing in production is changed.
      READ      : prison.AllowStripping / MinimumSentenceToStrip / InfamyGainedDaily / HandleStrippingOn
      WRITE     : the full abstraction (p.SetBool -> ActorBase -> StorageVars.SetBoolOnReference)
      PATH      : GetVarPathOnReference alone
      JC WRITE  : JDB.solveIntSetter on a prebuilt path (the JC part of a write)
      HANDLE    : RPB_Memory.FastMap_SetInt and JMap.setInt on the actor's category map (path resolved once)
/;
state Test_LockPrisonerSettings_CostSplit
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true

        Actor a = __SpawnTempActor()
        self.__EnsureKind("prisoner", a, prison)
        RPB_ActorBase reg = none
        float t0 = Utility.GetCurrentRealTime()
        while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
            reg = self.__LookupKind("prisoner", a, prison)
            if (!reg)
                Utility.Wait(0.025)
            endif
        endWhile
        RPB_Prisoner p = reg as RPB_Prisoner
        if (!p)
            display_result(assert_true(false, "Prisoner never registered, cannot measure"))
            return
        endif

        int B = 40
        int C = 400
        int i = 0
        float t = 0.0
        int msRead = 0
        int msWrite = 0
        int msPath = 0
        int msJC = 0
        int msFast = 0
        int msJMap = 0
        bool sinkB = false
        int sinkI = 0
        float sinkF = 0.0
        string sinkS = ""

        ; --- READ: four different Prison.X properties (bool, int, float, string), B rounds each ---
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < B)
            sinkB = prison.AllowStripping
            i += 1
        endWhile
        int msReadBool = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < B)
            sinkI = prison.MinimumSentenceToStrip
            i += 1
        endWhile
        int msReadInt = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < B)
            sinkF = prison.InfamyGainedDaily
            i += 1
        endWhile
        int msReadFloat = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < B)
            sinkS = prison.HandleStrippingOn
            i += 1
        endWhile
        int msReadString = self.__Ms(Utility.GetCurrentRealTime() - t)
        msRead = msReadBool + msReadInt + msReadFloat + msReadString

        ; --- WRITE: the full abstraction, as LockPrisonerSettings does it ---
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < B)
            p.SetBool("Bench Bool", true)
            i += 1
        endWhile
        msWrite = self.__Ms(Utility.GetCurrentRealTime() - t)

        ; --- PATH: only the string building ---
        string path = ""
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < B)
            path = RPB_StorageVars.GetVarPathOnReference("Bench Bool", a, "Jail")
            i += 1
        endWhile
        msPath = self.__Ms(Utility.GetCurrentRealTime() - t)

        ; --- JC WRITE: only the JDB setter on a prebuilt path ---
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < C)
            JDB.solveIntSetter(path, 1, true)
            i += 1
        endWhile
        msJC = self.__Ms(Utility.GetCurrentRealTime() - t)

        ; --- HANDLE: resolve the category map once, then write by key ---
        string mapPath = StringUtil.Substring(path, 0, StringUtil.GetLength(path) - StringUtil.GetLength(".Bench Bool"))
        int map = JDB.solveObj(mapPath)
        log("category map handle " + map + " at " + mapPath)
        if (map == 0)
            ok = assert_true(false, "The actor's category map does not exist at " + mapPath) && ok
        else
            t = Utility.GetCurrentRealTime()
            i = 0
            while (i < C)
                RPB_Memory.FastMap_SetInt(map, "Bench Int", i)
                i += 1
            endWhile
            msFast = self.__Ms(Utility.GetCurrentRealTime() - t)

            t = Utility.GetCurrentRealTime()
            i = 0
            while (i < C)
                JMap.setInt(map, "Bench Int", i)
                i += 1
            endWhile
            msJMap = self.__Ms(Utility.GetCurrentRealTime() - t)

            ok = assert_true(JDB.solveInt(mapPath + ".Bench Int") == C - 1, "A handle write did not land at the path the abstraction reads") && ok
        endif

        log("COST SPLIT read  bool " + self.__PerOp(msReadBool, B) + " | int " + self.__PerOp(msReadInt, B) + " | float " + self.__PerOp(msReadFloat, B) + " | string " + self.__PerOp(msReadString, B) + "  (Prison.X property)")
        log("COST SPLIT write (p.SetBool, full abstraction) " + self.__PerOp(msWrite, B) + " per write")
        log("COST SPLIT   of which GetVarPathOnReference " + self.__PerOp(msPath, B) + " | JDB.solveIntSetter on a prebuilt path " + self.__PerOp(msJC, C))
        log("COST SPLIT handle write: FastMap_SetInt " + self.__PerOp(msFast, C) + " | JMap.setInt " + self.__PerOp(msJMap, C))
        log("COST SPLIT for 68 settings: reads ~" + ((msRead * 68) / (B * 4)) + "ms, full-abstraction writes ~" + ((msWrite * 68) / B) + "ms, handle writes via FastMap ~" + ((msFast * 68) / C) + "ms (Initialize() has 813ms in LockPrisonerSettings)")

        RPB_StorageVars.DeleteVariableOnReference("Bench Bool", a, "Jail")
        RPB_StorageVars.DeleteVariableOnReference("Bench Int", a, "Jail")
        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Correctness of the speed-ups in RPB_ActorBase (cached "(Reference <id>)" key) and RPB_Prison (cached Hold):
      1. the key derived from the Actor gives exactly the path StorageVars derives itself, and passing the
         already-normalized key gives the same path again;
      2. after LockPrisonerSettings(), values written through the cached key read back identically through the
         plain Actor path (an independent route), for a bool, int, float and string setting, and equal the
         Prison's live property value (nothing changed in the MCM in between);
      3. Prison.Hold is non-empty and equals what StorageVars holds.
/;
state Test_StorageVars_CachedKeyEquivalence
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        self.__EnsureKind("prisoner", a, prison)
        RPB_ActorBase reg = none
        float t0 = Utility.GetCurrentRealTime()
        while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
            reg = self.__LookupKind("prisoner", a, prison)
            if (!reg)
                Utility.Wait(0.025)
            endif
        endWhile
        RPB_Prisoner p = reg as RPB_Prisoner
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif

        string refKey = RPB_StorageVars.GetReferenceKey(a)
        string viaActor = RPB_StorageVars.GetVarPathOnReference("Some Key", a, "Jail")
        string viaKey = RPB_StorageVars.GetVarPathOnReference("Some Key", refKey, "Jail")
        log("KEY " + refKey + " | path via Actor " + viaActor + " | path via key " + viaKey)
        step = assert_true(viaActor == viaKey, "The cached-key path differs from the Actor path: " + viaKey + " vs " + viaActor)
        ok = ok && step

        string prefix = RPB_StorageVars.GetPathPrefixOnReference(refKey, "Jail")
        step = assert_true(prefix + "Some Key" == viaActor, "The path prefix + key differs from the Actor path: " + prefix + "Some Key vs " + viaActor)
        ok = ok && step
        step = assert_true(RPB_StorageVars.GetPathPrefixOnReference("", "Jail") == "null", "An empty reference should give the 'null' prefix")
        ok = ok && step

        ; A write through the cached prefix (p.SetInt) must be readable through the plain Actor path, and back
        p.SetInt("Prefix Probe", 1234)
        step = assert_true(RPB_StorageVars.GetIntOnReference("Prefix Probe", a, "Jail") == 1234, "A write through the cached prefix is not readable through the plain Actor path")
        ok = ok && step
        RPB_StorageVars.SetIntOnReference("Prefix Probe", a, 4321, "Jail")
        step = assert_true(p.GetInt("Prefix Probe") == 4321, "A write through the plain Actor path is not readable through the cached prefix")
        ok = ok && step
        RPB_StorageVars.DeleteVariableOnReference("Prefix Probe", a, "Jail")

        p.LockPrisonerSettings()

        step = assert_true(p.GetBool("Allow Stripping") == prison.AllowStripping, "Allow Stripping differs from the Prison value")
        ok = ok && step
        step = assert_true(RPB_StorageVars.GetBoolOnReference("Allow Stripping", a, "Jail") == prison.AllowStripping, "Allow Stripping differs when read through the plain Actor path")
        ok = ok && step
        step = assert_true(p.GetInt("Minimum Sentence") == prison.MinimumSentence && RPB_StorageVars.GetIntOnReference("Minimum Sentence", a, "Jail") == prison.MinimumSentence, "Minimum Sentence differs")
        ok = ok && step
        step = assert_true(p.GetFloat("Infamy Gained Daily") == prison.InfamyGainedDaily && RPB_StorageVars.GetFloatOnReference("Infamy Gained Daily", a, "Jail") == prison.InfamyGainedDaily, "Infamy Gained Daily differs")
        ok = ok && step
        step = assert_true(p.GetString("Handle Stripping On") == prison.HandleStrippingOn && RPB_StorageVars.GetStringOnReference("Handle Stripping On", a, "Jail") == prison.HandleStrippingOn, "Handle Stripping On differs")
        ok = ok && step

        string hold = prison.Hold
        step = assert_true(hold != "", "Prison.Hold is empty")
        ok = ok && step
        step = assert_true(hold == prison.GetLocalPropertyOfTypeString("Hold"), "Cached Hold '" + hold + "' differs from the stored one")
        ok = ok && step
        log("HOLD '" + hold + "'")

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Regression test for the "second arrest fails after a release" bug. ActorBase passes its cached
    "(Reference <id>)" key to StorageVars, and GetObjectHandleOnReference() (behind every delete) only understood the
    "[Script < (ID)>]" form, so Remove()/RemoveAll()/OnDestroy()/Destroy() silently cleared nothing: "Arrested" and
    "Is Initialized" survived a release. Checks every delete route on a registered temp prisoner, reading back through
    the plain Actor path (an independent route):
      a) Remove(); b) RemoveAll() (Jail category); c) DeleteCategoryOnReference() with the normalized key ("Actor"
      category, what OnDestroy does); d) Destroy() clears "Initialized"; e) DeleteAllOnReference() removes the actor's
      entry from the storage root.
/;
state Test_StorageVars_DeletesWithCachedKey
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        self.__EnsureKind("prisoner", a, prison)
        RPB_ActorBase reg = none
        float t0 = Utility.GetCurrentRealTime()
        while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
            reg = self.__LookupKind("prisoner", a, prison)
            if (!reg)
                Utility.Wait(0.025)
            endif
        endWhile
        RPB_Prisoner p = reg as RPB_Prisoner
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif

        string refKey = RPB_StorageVars.GetReferenceKey(a)

        ; a) Remove()
        p.SetBool("Probe A", true)
        step = assert_true(RPB_StorageVars.GetBoolOnReference("Probe A", a, "Jail"), "Probe A was not written")
        ok = ok && step
        p.Remove("Probe A")
        step = assert_false(RPB_StorageVars.GetBoolOnReference("Probe A", a, "Jail"), "Remove() did not delete the variable")
        ok = ok && step

        ; b) RemoveAll() of the prisoner's own category
        p.SetBool("Probe B", true)
        p.SetInt("Probe C", 5)
        p.RemoveAll()
        step = assert_false(RPB_StorageVars.GetBoolOnReference("Probe B", a, "Jail"), "RemoveAll() did not delete Probe B")
        ok = ok && step
        step = assert_true(RPB_StorageVars.GetIntOnReference("Probe C", a, "Jail") == 0, "RemoveAll() did not delete Probe C")
        ok = ok && step

        ; c) DeleteCategoryOnReference() with the normalized key, the way OnDestroy() wipes "Actor" and "Temporary"
        RPB_StorageVars.SetBoolOnReference("Probe D", a, true, "Actor")
        RPB_StorageVars.SetBoolOnReference("Probe E", a, true, "Temporary")
        RPB_StorageVars.DeleteCategoryOnReference(refKey, "Actor")
        RPB_StorageVars.DeleteCategoryOnReference(refKey, "Temporary")
        step = assert_false(RPB_StorageVars.GetBoolOnReference("Probe D", a, "Actor"), "DeleteCategoryOnReference(normalized key) did not clear the Actor category")
        ok = ok && step
        step = assert_false(RPB_StorageVars.GetBoolOnReference("Probe E", a, "Temporary"), "DeleteCategoryOnReference(normalized key) did not clear the Temporary category")
        ok = ok && step

        ; d) Destroy() clears the flag that gates re-registration
        p.SetBool("Initialized", true)
        step = assert_true(RPB_StorageVars.GetBoolOnReference("Initialized", a, "Jail"), "Could not set Initialized")
        ok = ok && step
        p.Destroy()
        step = assert_false(RPB_StorageVars.GetBoolOnReference("Initialized", a, "Jail"), "Destroy() left 'Initialized' behind")
        ok = ok && step

        ; e) DeleteAllOnReference() removes the actor's entry from the storage root
        RPB_StorageVars.SetBoolOnReference("Probe F", a, true, "Jail")
        int root = RPB_StorageVars.GetObjectHandle()
        step = assert_true(JMap.hasKey(root, refKey), "The actor has no entry in the storage root, cannot test DeleteAllOnReference")
        ok = ok && step
        RPB_StorageVars.DeleteAllOnReference(a)
        step = assert_false(JMap.hasKey(root, refKey), "DeleteAllOnReference() left the actor's entry in the storage root")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

; Registers a prisoner through the normal spell route and waits for it (up to 30s). None if it never registers.
RPB_Prisoner function __RegisterPrisonerAndWait(Actor akActor, RPB_Prison akPrison)
    self.__EnsureKind("prisoner", akActor, akPrison)
    RPB_ActorBase reg = none
    float t0 = Utility.GetCurrentRealTime()
    while (!reg && (Utility.GetCurrentRealTime() - t0) < 30.0)
        reg = self.__LookupKind("prisoner", akActor, akPrison)
        if (!reg)
            Utility.Wait(0.025)
        endif
    endWhile
    return reg as RPB_Prisoner
endFunction

; True when the two JMaps hold the same type and value under @asKey
bool function __JMapValueMatches(int aiMapA, int aiMapB, string asKey)
    int typeA = JMap.valueType(aiMapA, asKey)
    int typeB = JMap.valueType(aiMapB, asKey)

    if (typeA != typeB || typeA == 0)
        return false
    endif

    if (typeA == 2)
        return JMap.getInt(aiMapA, asKey) == JMap.getInt(aiMapB, asKey)
    elseif (typeA == 3)
        return JMap.getFlt(aiMapA, asKey) == JMap.getFlt(aiMapB, asKey)
    elseif (typeA == 4)
        return JMap.getForm(aiMapA, asKey) == JMap.getForm(aiMapB, asKey)
    elseif (typeA == 6)
        return JMap.getStr(aiMapA, asKey) == JMap.getStr(aiMapB, asKey)
    endif

    return false
endFunction

;/
    The Prison settings snapshot must lock exactly what the direct way locks (72 settings, one read and write each).
    P1 is locked the direct way, P2 from the snapshot; every snapshot key must exist in both prisoners' "Jail"
    maps with the same type and value, and every key the direct way wrote must be in the snapshot.
    Also times both, to show what the snapshot buys.
/;
state Test_SettingsSnapshot_EqualsDirect
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a1 = __SpawnTempActor()
        Actor a2 = __SpawnTempActor()
        RPB_Prisoner p1 = self.__RegisterPrisonerAndWait(a1, prison)
        RPB_Prisoner p2 = self.__RegisterPrisonerAndWait(a2, prison)
        if (!p1 || !p2)
            display_result(assert_true(false, "A prisoner never registered"))
            return
        endif

        int map1 = RPB_StorageVars.GetObjectHandleOnReference(a1, "Jail")
        string[] keysBefore = JMap.allKeysPArray(map1)

        float t = Utility.GetCurrentRealTime()
        p1.__LockPrisonerSettingsDirect()
        int msDirect = self.__Ms(Utility.GetCurrentRealTime() - t)

        ; First call builds the snapshot (reads every setting once), the lock afterwards only copies it
        t = Utility.GetCurrentRealTime()
        int snapshot = prison.GetSettingsSnapshot()
        int msBuild = self.__Ms(Utility.GetCurrentRealTime() - t)
        t = Utility.GetCurrentRealTime()
        p2.LockPrisonerSettings()
        int msCopy = self.__Ms(Utility.GetCurrentRealTime() - t)

        map1 = RPB_StorageVars.GetObjectHandleOnReference(a1, "Jail")
        int map2 = RPB_StorageVars.GetObjectHandleOnReference(a2, "Jail")
        string[] snapKeys = JMap.allKeysPArray(snapshot)
        string[] keysAfter = JMap.allKeysPArray(map1)
        log("SNAPSHOT keys " + snapKeys.Length + " | direct " + msDirect + "ms | snapshot build (first prisoner after a change) " + msBuild + "ms | copy into a prisoner " + msCopy + "ms")

        step = assert_true(snapKeys.Length >= 60, "The snapshot has only " + snapKeys.Length + " keys")
        ok = ok && step

        int missing = 0
        int mismatched = 0
        int dotted = 0
        int i = 0
        while (i < snapKeys.Length)
            ; StorageVars keys go into a JContainers path where '.' is the separator: a dotted key silently nests
            if (StringUtil.Find(snapKeys[i], ".") >= 0)
                dotted += 1
                log("SNAPSHOT key contains a '.', which StorageVars paths cannot address: '" + snapKeys[i] + "'")
            endif

            ; The provenance keys are not settings, the direct way does not write them (the prisoner still gets them)
            if (StringUtil.Find(snapKeys[i], "Settings Snapshot") != 0)
                if (!self.__JMapValueMatches(snapshot, map1, snapKeys[i]))
                    mismatched += 1
                    log("SNAPSHOT differs from the direct way for '" + snapKeys[i] + "'")
                endif
            endif
            if (!self.__JMapValueMatches(snapshot, map2, snapKeys[i]))
                missing += 1
                log("SNAPSHOT copy is missing or different in the second prisoner for '" + snapKeys[i] + "'")
            endif
            i += 1
        endWhile
        step = assert_true(dotted == 0, dotted + " snapshot key(s) contain a '.'")
        ok = ok && step
        step = assert_true(mismatched == 0, mismatched + " snapshot value(s) differ from the direct way")
        ok = ok && step
        step = assert_true(missing == 0, missing + " snapshot value(s) missing or different in the prisoner locked from the snapshot")
        ok = ok && step

        ; Every key the direct way added must be in the snapshot (keys that already existed cannot be told apart)
        int extra = 0
        i = 0
        while (i < keysAfter.Length)
            if (keysBefore.Find(keysAfter[i]) < 0 && snapKeys.Find(keysAfter[i]) < 0)
                extra += 1
                log("The direct way wrote '" + keysAfter[i] + "' which the snapshot does not have")
            endif
            i += 1
        endWhile
        step = assert_true(extra == 0, extra + " key(s) written by the direct way are not in the snapshot")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    An MCM change must invalidate the snapshot, and earlier prisoners must keep the values they were locked with:
      P1 locked; a second lock with no change does not rebuild the snapshot;
      an option is changed through the MCM; P2 locked -> new value, exactly one rebuild, P1 still has the old value;
      the option is restored; P3 locked -> old value again (another rebuild).
    Uses "Stripping::Minimum Sentence to Strip" on the Haafingar page, which Prisoner stores as "Sentence to Strip".
/;
state Test_SettingsSnapshot_McmChange
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_MCM mcm = prison.Config.MCM
        bool ok = true
        bool step = false
        string optionKey = "Stripping::Minimum Sentence to Strip"
        string page = prison.Hold

        Actor a1 = __SpawnTempActor()
        Actor a2 = __SpawnTempActor()
        Actor a3 = __SpawnTempActor()
        RPB_Prisoner p1 = self.__RegisterPrisonerAndWait(a1, prison)
        RPB_Prisoner p2 = self.__RegisterPrisonerAndWait(a2, prison)
        RPB_Prisoner p3 = self.__RegisterPrisonerAndWait(a3, prison)
        if (!p1 || !p2 || !p3)
            display_result(assert_true(false, "A prisoner never registered"))
            return
        endif

        float original = mcm.GetOptionSliderValue(optionKey, page)
        int originalInt = original as int

        p1.LockPrisonerSettings()
        int builds = prison.SettingsSnapshotBuilds
        step = assert_true(p1.GetInt("Sentence to Strip") == originalInt, "P1 did not lock the current value " + originalInt)
        ok = ok && step

        ; Locking again with no MCM change must not rebuild the snapshot
        p1.LockPrisonerSettings()
        step = assert_true(prison.SettingsSnapshotBuilds == builds, "The snapshot was rebuilt although nothing changed (" + builds + " -> " + prison.SettingsSnapshotBuilds + ")")
        ok = ok && step

        ; Change the option through the MCM
        mcm.SetOptionValueFloat(optionKey, original + 7.0, page)
        p2.LockPrisonerSettings()
        step = assert_true(p2.GetInt("Sentence to Strip") == originalInt + 7, "P2 did not get the changed value: " + p2.GetInt("Sentence to Strip") + " (expected " + (originalInt + 7) + ")")
        ok = ok && step
        step = assert_true(prison.SettingsSnapshotBuilds == builds + 1, "Expected exactly one rebuild after the change (" + builds + " -> " + prison.SettingsSnapshotBuilds + ")")
        ok = ok && step
        step = assert_true(p1.GetInt("Sentence to Strip") == originalInt, "P1's locked value changed with the MCM: " + p1.GetInt("Sentence to Strip"))
        ok = ok && step

        ; Restore the option: the next prisoner gets the old value again
        mcm.SetOptionValueFloat(optionKey, original, page)
        p3.LockPrisonerSettings()
        step = assert_true(p3.GetInt("Sentence to Strip") == originalInt, "P3 did not get the restored value: " + p3.GetInt("Sentence to Strip"))
        ok = ok && step
        step = assert_true(p2.GetInt("Sentence to Strip") == originalInt + 7, "P2's locked value changed after the restore: " + p2.GetInt("Sentence to Strip"))
        ok = ok && step
        log("MCM CHANGE original " + originalInt + ", changed " + (originalInt + 7) + ", rebuilds " + builds + " -> " + prison.SettingsSnapshotBuilds)

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


;/
    Deterministic proof that LockPrisonerSettings() COPIES the snapshot instead of recomputing the settings:
    an impossible sentinel is written into the snapshot map only (no MCM change, no version bump); the prisoner
    locked next must carry the sentinel. Then the snapshot is invalidated and the next prisoner must carry the real
    MCM value. The provenance keys ("Settings Snapshot Build" / "Version", copied into every prisoner) must say
    which build each prisoner came from, and a third prisoner locked with no change must be identical to the second.
/;
state Test_SettingsSnapshot_ComesFromSnapshot
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_MCM mcm = prison.Config.MCM
        bool ok = true
        bool step = false
        int SENTINEL = 987654

        Actor a1 = __SpawnTempActor()
        Actor a2 = __SpawnTempActor()
        Actor a3 = __SpawnTempActor()
        RPB_Prisoner p1 = self.__RegisterPrisonerAndWait(a1, prison)
        RPB_Prisoner p2 = self.__RegisterPrisonerAndWait(a2, prison)
        RPB_Prisoner p3 = self.__RegisterPrisonerAndWait(a3, prison)
        if (!p1 || !p2 || !p3)
            display_result(assert_true(false, "A prisoner never registered"))
            return
        endif

        int snapshot = prison.GetSettingsSnapshot()
        int builds = prison.SettingsSnapshotBuilds

        ; 1. Poison the snapshot only: a prisoner that copies it carries the sentinel, one that recomputes would not
        RPB_Memory.FastMap_SetInt(snapshot, "Bounty to Strip", SENTINEL)
        p1.LockPrisonerSettings()
        step = assert_true(p1.GetInt("Bounty to Strip") == SENTINEL, "P1 did not carry the sentinel (" + p1.GetInt("Bounty to Strip") + "): it did not copy the snapshot")
        ok = ok && step
        step = assert_true(prison.SettingsSnapshotBuilds == builds, "The snapshot was rebuilt for P1 (" + builds + " -> " + prison.SettingsSnapshotBuilds + ")")
        ok = ok && step
        step = assert_true(p1.GetInt("Settings Snapshot Build") == builds, "P1's snapshot build is " + p1.GetInt("Settings Snapshot Build") + ", expected " + builds)
        ok = ok && step

        ; 2. Invalidate: the next prisoner gets the real MCM value from a fresh build
        prison.InvalidateSettingsSnapshot()
        p2.LockPrisonerSettings()
        int real = prison.MinimumBountyToStrip
        step = assert_true(real != SENTINEL, "The real setting equals the sentinel, pick another sentinel")
        ok = ok && step
        step = assert_true(p2.GetInt("Bounty to Strip") == real, "P2 did not get the real value " + real + ": " + p2.GetInt("Bounty to Strip"))
        ok = ok && step
        step = assert_true(prison.SettingsSnapshotBuilds == builds + 1, "Expected one rebuild after Invalidate (" + builds + " -> " + prison.SettingsSnapshotBuilds + ")")
        ok = ok && step
        step = assert_true(p2.GetInt("Settings Snapshot Build") == builds + 1, "P2's snapshot build is " + p2.GetInt("Settings Snapshot Build") + ", expected " + (builds + 1))
        ok = ok && step
        step = assert_true(p2.GetInt("Settings Snapshot Version") == mcm.GetSettingsVersion(prison.Hold), "P2's snapshot version does not match the MCM's for " + prison.Hold)
        ok = ok && step
        step = assert_true(p1.GetInt("Bounty to Strip") == SENTINEL, "P1's locked value changed with the rebuild")
        ok = ok && step

        ; 3. A third prisoner with no change in between: same build, every value equal to the second one's
        p3.LockPrisonerSettings()
        step = assert_true(p3.GetInt("Settings Snapshot Build") == p2.GetInt("Settings Snapshot Build"), "P3 came from another build than P2")
        ok = ok && step
        step = assert_true(prison.SettingsSnapshotBuilds == builds + 1, "P3 caused a rebuild")
        ok = ok && step

        int map2 = RPB_StorageVars.GetObjectHandleOnReference(a2, "Jail")
        int map3 = RPB_StorageVars.GetObjectHandleOnReference(a3, "Jail")
        string[] keys = JMap.allKeysPArray(prison.GetSettingsSnapshot())
        int different = 0
        int i = 0
        while (i < keys.Length)
            if (!self.__JMapValueMatches(map2, map3, keys[i]))
                different += 1
                log("P3 differs from P2 for '" + keys[i] + "'")
            endif
            i += 1
        endWhile
        step = assert_true(different == 0, different + " of " + keys.Length + " settings differ between P2 and P3 (same snapshot build)")
        ok = ok && step
        log("SNAPSHOT PROOF sentinel carried by P1 (build " + p1.GetInt("Settings Snapshot Build") + "), P2 real value " + real + " (build " + p2.GetInt("Settings Snapshot Build") + "), P3 identical to P2 over " + keys.Length + " keys")

        display_result(ok)
    endFunction

    function Teardown()
        ; Never leave the sentinel in the shared snapshot if the test stopped early
        ((RPB_API.GetPrisonManager()).GetPrison("Haafingar")).InvalidateSettingsSnapshot()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Per-Hold versions: another Hold's page must not invalidate this Prison's snapshot, its own page must, and a
    non-Hold page (General) must (it counts for every Hold). Each option is re-set to its current value: the version
    bumps on every write, so nothing actually changes.
/;
state Test_SettingsSnapshot_PerHoldVersion
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_MCM mcm = prison.Config.MCM
        bool ok = true
        bool step = false
        string hold = prison.Hold
        string optionKey = "Stripping::Minimum Sentence to Strip"

        string otherHold = ""
        string[] holds = prison.Config.Holds
        int i = 0
        while (i < holds.Length && otherHold == "")
            if (holds[i] != hold)
                otherHold = holds[i]
            endif
            i += 1
        endWhile
        step = assert_true(otherHold != "", "No other Hold found to test with")
        ok = ok && step

        prison.GetSettingsSnapshot()
        int builds = prison.SettingsSnapshotBuilds
        int versionBefore = mcm.GetSettingsVersion(hold)
        int otherVersionBefore = mcm.GetSettingsVersion(otherHold)

        ; 1. Another Hold's page: this Prison's snapshot and version stay
        mcm.SetOptionValueFloat(optionKey, mcm.GetOptionSliderValue(optionKey, otherHold), otherHold)
        prison.GetSettingsSnapshot()
        step = assert_true(prison.SettingsSnapshotBuilds == builds, "Changing " + otherHold + " rebuilt " + hold + "'s snapshot (" + builds + " -> " + prison.SettingsSnapshotBuilds + ")")
        ok = ok && step
        step = assert_true(mcm.GetSettingsVersion(hold) == versionBefore, hold + "'s settings version changed when only " + otherHold + " was edited")
        ok = ok && step
        step = assert_true(mcm.GetSettingsVersion(otherHold) > otherVersionBefore, otherHold + "'s settings version did not increase")
        ok = ok && step

        ; 2. This Hold's own page: exactly one rebuild
        mcm.SetOptionValueFloat(optionKey, mcm.GetOptionSliderValue(optionKey, hold), hold)
        prison.GetSettingsSnapshot()
        step = assert_true(prison.SettingsSnapshotBuilds == builds + 1, "Changing " + hold + " did not rebuild its snapshot once (" + builds + " -> " + prison.SettingsSnapshotBuilds + ")")
        ok = ok && step

        ; 3. A non-Hold page counts for every Hold
        mcm.SetOptionValueFloat("General::Bounty Decay (Update Interval)", mcm.GetOptionSliderValue("General::Bounty Decay (Update Interval)", "General"), "General")
        prison.GetSettingsSnapshot()
        step = assert_true(prison.SettingsSnapshotBuilds == builds + 2, "Changing the General page did not rebuild the snapshot (" + builds + " -> " + prison.SettingsSnapshotBuilds + ")")
        ok = ok && step

        log("PER-HOLD VERSION " + hold + " " + versionBefore + " -> " + mcm.GetSettingsVersion(hold) + " | " + otherHold + " " + otherVersionBefore + " -> " + mcm.GetSettingsVersion(otherHold) + " | rebuilds " + builds + " -> " + prison.SettingsSnapshotBuilds)
        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


;/
    DetermineStrippingType() is ~119ms of Prisoner.Initialize(). Times each thing it does on its own (R rounds each,
    the timer is coarse) and the whole function, and prints them ranked:
      HasUnderwear()                          two GetUnderwear calls, each reads a Config slot from the MCM
      Config.HasNudeBodyModInstalled          MCM read (always evaluated: Papyrus && / || do not short-circuit)
      Config.HasUnderwearBodyModInstalled     MCM read (same)
      StrippingThoroughness                   read TWICE by the function (Prison modifier + StorageVars + Bounty)
      Bounty                                  Prisoner.Bounty -> GetLatentBounty()
      Prison.StrippingThoroughnessModifier    MCM read chain
      SendError(..., false)                   the message string is built even when the condition is false
      DetermineStrippingType() (whole)
    Tests only, nothing in production is changed.
/;
state Test_Prisoner_StrippingTypeBreakdown
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor a = __SpawnTempActor()
        RPB_Prisoner p = self.__RegisterPrisonerAndWait(a, prison)
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif

        ; Same state Initialize() has when it gets here
        p.LockPrisonerSettings()

        int R = 15
        string[] names = new string[8]
        int[] totals = new int[8]
        names[0] = "HasUnderwear()"
        names[1] = "Config.HasNudeBodyModInstalled"
        names[2] = "Config.HasUnderwearBodyModInstalled"
        names[3] = "StrippingThoroughness (read once; the function reads it twice)"
        names[4] = "Bounty"
        names[5] = "Prison.StrippingThoroughnessModifier"
        names[6] = "SendError(msg built, condition false)"
        names[7] = "DetermineStrippingType() whole"

        bool sinkB = false
        int sinkI = 0
        int i = 0
        float t = 0.0

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkB = p.HasUnderwear()
            i += 1
        endWhile
        totals[0] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkB = p.Config.HasNudeBodyModInstalled
            i += 1
        endWhile
        totals[1] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkB = p.Config.HasUnderwearBodyModInstalled
            i += 1
        endWhile
        totals[2] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = p.StrippingThoroughness
            i += 1
        endWhile
        totals[3] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = p.Bounty
            i += 1
        endWhile
        totals[4] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = prison.StrippingThoroughnessModifier
            i += 1
        endWhile
        totals[5] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            p.EventManager.SendError("An error has occurred, cannot strip prisoner both naked and to underwear, logic error!", "("+ p.Name +") Prisoner::DetermineStrippingType", false)
            i += 1
        endWhile
        totals[6] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            p.DetermineStrippingType()
            i += 1
        endWhile
        totals[7] = self.__Ms(Utility.GetCurrentRealTime() - t)

        ; --- ranked report ---
        bool[] printed = new bool[8]
        int rank = 0
        while (rank < 8)
            int best = -1
            int k = 0
            while (k < 8)
                if (!printed[k] && (best < 0 || totals[k] > totals[best]))
                    best = k
                endif
                k += 1
            endWhile
            printed[best] = true
            log("STRIPPING BREAKDOWN #" + (rank + 1) + ": " + names[best] + " - " + self.__PerOp(totals[best], R) + " per call")
            rank += 1
        endWhile
        log("STRIPPING BREAKDOWN state: bounty " + p.Bounty + ", thoroughness " + p.StrippingThoroughness + ", modifier " + prison.StrippingThoroughnessModifier + ", naked " + p.WillBeStrippedNaked + ", underwear " + p.WillBeStrippedToUnderwear)

        display_result(true)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


; ---- originals kept as references for the equivalence tests 64-66 ----

; The original stripping-type decision, literally (Papyrus && / || evaluate both sides, so this is the old formula)
int function __StrippingTypeReference(bool abNudeBodyMod, bool abUnderwearBodyMod, bool abHasUnderwearWorn, int aiThoroughness)
    bool isAbleToStripNaked         = abNudeBodyMod
    bool isAbleToStripToUnderwear   = (isAbleToStripNaked && abUnderwearBodyMod && abHasUnderwearWorn) || !isAbleToStripNaked
    bool naked      = (isAbleToStripNaked       && (aiThoroughness >= 10 || !isAbleToStripToUnderwear))
    bool underwear  = (isAbleToStripToUnderwear && (aiThoroughness < 10  || !isAbleToStripNaked))
    int result = 0
    if (naked)
        result += 1
    endif
    if (underwear)
        result += 2
    endif
    return result
endFunction

; The original slot mask loop
int function __SlotMaskReference(int slotMask)
    int currentSlotMask = 30
    int slotMaskValue = 0x00000001
    while (currentSlotMask <= 61)
        if (slotMask == currentSlotMask)
            return slotMaskValue
        endif
        currentSlotMask += 1
        slotMaskValue *= 2
    endWhile

    return -1
endFunction

; The original GetVarPathOnReference / GetReferenceKey, before the cheaper key building
string function __PathReference(string asKey, string apReference, string asCategory)
    if (apReference == "null" || apReference == "")
        return "null"
    endif

    bool isPapyrusReference = RPB_Utility.String_StartsEndsWith(apReference, "[", "]")

    if (apReference && isPapyrusReference)
        string referenceId = RPB_Utility.ExtractReferenceID(apReference)
        apReference = "(" + "Reference" + " <" + referenceId + ">" + ")"
    endif

    if (asCategory != "null" && asCategory != "")
        return RPB_StorageVars.GetRootPath() + "." + apReference + "." + asCategory + "." + asKey
    else
        return RPB_StorageVars.GetRootPath() + "." + apReference + "." + asKey
    endif
endFunction

string function __KeyReference(string apReference)
    if (apReference == "null" || apReference == "")
        return apReference
    endif

    if (RPB_Utility.String_StartsEndsWith(apReference, "[", "]"))
        return "(" + "Reference" + " <" + RPB_Utility.ExtractReferenceID(apReference) + ">" + ")"
    endif

    return apReference
endFunction

;/
    The decision itself is pure, so it is checked exhaustively (nude mod x underwear mod x underwear worn x
    thoroughness 5 / 15) against the original formula, and it must always pick exactly one of naked / underwear.
    Then the instance function (lazy inputs, one thoroughness read, guarded error) must equal the original body
    (__DetermineStrippingTypeReference) for every nude-mod / underwear-mod setting, with a locked thoroughness of 5
    and 15 (bounty modifier off so the bounty does not interfere). The dummy NPC wears no underwear, so the
    "underwear worn" input is covered by the table only. The MCM toggles are restored afterwards.
/;
state Test_Prisoner_StrippingTypeEquivalence
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_MCM mcm = prison.Config.MCM
        bool ok = true
        bool step = false

        ; ---- 1. exhaustive table of the pure decision ----
        int wrong = 0
        int notExactlyOne = 0
        int combo = 0
        while (combo < 16)
            bool nude = (combo % 2) == 1
            bool underwearMod = ((combo / 2) % 2) == 1
            bool hasUnderwear = ((combo / 4) % 2) == 1
            int thoroughness = 5
            if (combo >= 8)
                thoroughness = 15
            endif

            int expected = self.__StrippingTypeReference(nude, underwearMod, hasUnderwear, thoroughness)
            int actual = RPB_Prisoner.ResolveStrippingType(nude, underwearMod, hasUnderwear, thoroughness)
            if (actual != expected)
                wrong += 1
                log("DECISION differs for nude " + nude + ", underwear mod " + underwearMod + ", underwear worn " + hasUnderwear + ", thoroughness " + thoroughness + ": expected " + expected + ", got " + actual)
            endif
            if (actual != 1 && actual != 2)
                notExactlyOne += 1
            endif
            combo += 1
        endWhile
        step = assert_true(wrong == 0, wrong + " of 16 decisions differ from the original formula")
        ok = ok && step
        step = assert_true(notExactlyOne == 0, notExactlyOne + " decisions were not exactly one of naked / underwear")
        ok = ok && step

        ; ---- 2. instance function against the original body ----
        Actor a = __SpawnTempActor()
        RPB_Prisoner p = self.__RegisterPrisonerAndWait(a, prison)
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif

        string nudeKey = "Configuration::NudeBodyModInstalled"
        string underwearKey = "Configuration::UnderwearModInstalled"
        bool originalNude = mcm.GetOptionToggleState(nudeKey, "Clothing")
        bool originalUnderwear = mcm.GetOptionToggleState(underwearKey, "Clothing")

        p.LockPrisonerSettings()
        p.SetInt("Stripping Thoroughness Modifier", 0)

        int differing = 0
        int c = 0
        while (c < 8)
            bool nudeSetting = (c % 2) == 1
            bool underwearSetting = ((c / 2) % 2) == 1
            int locked = 5
            if (c >= 4)
                locked = 15
            endif

            mcm.SetOptionValueBool(nudeKey, nudeSetting, "Clothing")
            mcm.SetOptionValueBool(underwearKey, underwearSetting, "Clothing")
            p.SetInt("Stripping Thoroughness", locked)

            p.__DetermineStrippingTypeReference()
            bool refNaked = p.WillBeStrippedNaked
            bool refUnderwear = p.WillBeStrippedToUnderwear

            p.DetermineStrippingType()
            if (p.WillBeStrippedNaked != refNaked || p.WillBeStrippedToUnderwear != refUnderwear)
                differing += 1
                log("INSTANCE differs for nude mod " + nudeSetting + ", underwear mod " + underwearSetting + ", thoroughness " + locked + ": original naked " + refNaked + "/underwear " + refUnderwear + ", new naked " + p.WillBeStrippedNaked + "/underwear " + p.WillBeStrippedToUnderwear)
            endif
            c += 1
        endWhile

        mcm.SetOptionValueBool(nudeKey, originalNude, "Clothing")
        mcm.SetOptionValueBool(underwearKey, originalUnderwear, "Clothing")

        step = assert_true(differing == 0, differing + " of 8 instance runs differ from the original body")
        ok = ok && step
        log("STRIPPING EQUIVALENCE decision table 16/16 checked, instance runs 8 checked, MCM toggles restored (nude " + originalNude + ", underwear " + originalUnderwear + ")")

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    GetSlotMaskValue() is now 2^(slot - 30) by shifting instead of a loop of up to 32 iterations: every slot from
    29 to 62 (both sides of the valid 30..61 range) must give exactly what the original loop gives.
/;
state Test_Utility_SlotMaskEquivalence
    function Setup()
        bool ok = true
        int differing = 0
        int slot = 29
        while (slot <= 62)
            int expected = self.__SlotMaskReference(slot)
            int actual = RPB_Utility.GetSlotMaskValue(slot)
            if (actual != expected)
                differing += 1
                log("SLOT MASK differs for slot " + slot + ": original " + expected + ", new " + actual)
            endif
            slot += 1
        endWhile
        ok = assert_true(differing == 0, differing + " of 34 slots differ from the original loop")
        log("SLOT MASK slots 29..62 checked; 30 -> " + RPB_Utility.GetSlotMaskValue(30) + ", 52 -> " + RPB_Utility.GetSlotMaskValue(52) + ", 61 -> " + RPB_Utility.GetSlotMaskValue(61))
        display_result(ok)
    endFunction
endState

;/
    GetVarPathOnReference() and GetReferenceKey() build the "(Reference <id>)" key with fewer concatenations and
    inlined checks. This function once broke every delete when its input contract was misunderstood, so the new
    versions are compared byte for byte with the originals over Actor and Form strings, an already-normalized key,
    "null", "", plain strings, an unterminated "[..." and an odd bracketed string, with and without categories.
/;
state Test_StorageVars_PathEquivalence
    function Setup()
        bool ok = true
        Actor a = __SpawnTempActor()

        string[] refs = new string[10]
        refs[0] = a as string
        refs[1] = (Game.GetForm(0x14)) as string
        refs[2] = "[Actor < (00000014)>]"
        refs[3] = "[WIDeadBodyCleanupScript < (FF000E02)>]"
        refs[4] = "(Reference <00000014>)"
        refs[5] = "null"
        refs[6] = ""
        refs[7] = "plain.custom.id"
        refs[8] = "[unterminated"
        refs[9] = "[Something odd here]"

        string[] cats = new string[4]
        cats[0] = "Jail"
        cats[1] = "ActorVars"
        cats[2] = "null"
        cats[3] = ""

        int differing = 0
        int checked = 0
        int r = 0
        while (r < refs.Length)
            string expectedKey = self.__KeyReference(refs[r])
            string actualKey = RPB_StorageVars.GetReferenceKey(refs[r])
            checked += 1
            if (actualKey != expectedKey)
                differing += 1
                log("KEY differs for '" + refs[r] + "': original '" + expectedKey + "', new '" + actualKey + "'")
            endif

            int c = 0
            while (c < cats.Length)
                string expectedPath = self.__PathReference("Some Key", refs[r], cats[c])
                string actualPath = RPB_StorageVars.GetVarPathOnReference("Some Key", refs[r], cats[c])
                checked += 1
                if (actualPath != expectedPath)
                    differing += 1
                    log("PATH differs for '" + refs[r] + "' / '" + cats[c] + "': original '" + expectedPath + "', new '" + actualPath + "'")
                endif
                c += 1
            endWhile
            r += 1
        endWhile

        ok = assert_true(differing == 0, differing + " of " + checked + " keys/paths differ from the original")
        log("PATH EQUIVALENCE " + checked + " keys/paths compared, first Actor path: " + RPB_StorageVars.GetVarPathOnReference("K", refs[0], "Jail"))
        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    The thoroughness bug: the property read its base from category "Stripping", which nothing writes, so the MCM's
    thoroughness was ignored (always 0 + bounty part). It now reads the locked value (and the locked modifier):
      a prisoner locked from the snapshot carries the MCM's current thoroughness;
      a locked thoroughness of 15 with the modifier off gives 15 (it gave 0);
      with modifier 1000 and a latent bounty of 3000 it gives 15 + Round(3000 / 1000) = 18.
/;
state Test_Prisoner_ThoroughnessUsesLockedSetting
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = self.__RegisterPrisonerAndWait(a, prison)
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif

        ; 1. Locked from the snapshot: the MCM's own value (bounty is 0 for a fresh dummy)
        p.LockPrisonerSettings()
        int mcmThoroughness = prison.StrippingThoroughness
        step = assert_true(p.GetInt("Stripping Thoroughness") == mcmThoroughness, "The locked thoroughness " + p.GetInt("Stripping Thoroughness") + " is not the MCM's " + mcmThoroughness)
        ok = ok && step
        step = assert_true(p.StrippingThoroughness == mcmThoroughness + self.__BountyPart(p), "StrippingThoroughness " + p.StrippingThoroughness + " is not the MCM value " + mcmThoroughness + " plus the bounty part")
        ok = ok && step

        ; 2. A locked 15 with the modifier off is 15 (it was 0: the base came from an unwritten category)
        p.SetInt("Stripping Thoroughness", 15)
        p.SetInt("Stripping Thoroughness Modifier", 0)
        step = assert_true(p.StrippingThoroughness == 15, "Locked 15, modifier off: got " + p.StrippingThoroughness)
        ok = ok && step

        ; 3. Modifier on: adds Round(bounty / modifier)
        RPB_StorageVars.SetIntOnReference(prison.PrisonFaction.GetName() + "::Latent Bounty Non-Violent", a, 3000, "ActorVars")
        p.SetInt("Stripping Thoroughness Modifier", 1000)
        step = assert_true(p.Bounty == 3000, "The test bounty was not applied: " + p.Bounty)
        ok = ok && step
        step = assert_true(p.StrippingThoroughness == 18, "Locked 15, modifier 1000, bounty 3000: expected 18, got " + p.StrippingThoroughness)
        ok = ok && step
        log("THOROUGHNESS MCM value " + mcmThoroughness + " | locked 15, modifier off -> 15 | modifier 1000 with bounty 3000 -> " + p.StrippingThoroughness)

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

; The bounty part of the thoroughness for the prisoner's current bounty and locked modifier
int function __BountyPart(RPB_Prisoner apPrisoner)
    int modifier = apPrisoner.GetInt("Stripping Thoroughness Modifier")
    if (modifier > 0)
        return Math.Floor((apPrisoner.Bounty / modifier) as float)
    endif
    return 0
endFunction


;/
    Test 63 left SendError(msg built, condition false) at ~22ms although SendError now returns at once, so the cost
    is at the call site. "(" + Name + ")" style messages are built all over the mod, and Prisoner.Initialize()'s
    "error check + SetBool" step (59ms) has two of them. Times, R rounds each, what such a call is made of:
      p.Name                              property -> GetName() -> this.GetBaseObject().GetName()
      p.GetName()                         the same without the property call
      GetBaseObject() alone               one native on the Actor
      GetBaseObject().GetName()           two natives
      p.EventManager                      property chain to the EventManager
      message built from a read name      two concatenations only
      SendError(prebuilt, caller, false)  the (now early-returning) call itself
      EnsureTrue(true, msg)               with the message already built
      the whole thing as production writes it: SendError("..." + p.Name + "...", caller, false)
    Tests only, nothing in production is changed.
/;
state Test_Prisoner_NameCostBreakdown
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor a = __SpawnTempActor()
        RPB_Prisoner p = self.__RegisterPrisonerAndWait(a, prison)
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif

        int R = 20
        int N = 9
        string[] names = new string[9]
        int[] totals = new int[9]
        names[0] = "p.Name"
        names[1] = "p.GetName()"
        names[2] = "Actor.GetBaseObject() alone"
        names[3] = "Actor.GetBaseObject().GetName()"
        names[4] = "p.EventManager"
        names[5] = "message built from an already read name (2 concats)"
        names[6] = "SendError(prebuilt msg, caller, false)"
        names[7] = "EnsureTrue(true, prebuilt msg)"
        names[8] = "production style: SendError(msg + p.Name + ..., caller, false)"

        string sinkS = ""
        Form sinkF = none
        RPB_EventManager em = p.EventManager
        string nm = p.Name
        string msg = ""
        int failed = 0
        int i = 0
        float t = 0.0

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkS = p.Name
            i += 1
        endWhile
        totals[0] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkS = p.GetName()
            i += 1
        endWhile
        totals[1] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkF = a.GetBaseObject()
            i += 1
        endWhile
        totals[2] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkS = a.GetBaseObject().GetName()
            i += 1
        endWhile
        totals[3] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            em = p.EventManager
            i += 1
        endWhile
        totals[4] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            msg = "Could not determine the release location for Prisoner " + nm
            i += 1
        endWhile
        totals[5] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            em.SendError(msg, "(x) Prisoner::DetermineStrippingType", false)
            i += 1
        endWhile
        totals[6] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            failed = EnsureTrue(true, msg, failed)
            i += 1
        endWhile
        totals[7] = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            p.EventManager.SendError("An error has occurred, cannot strip prisoner both naked and to underwear, logic error!", "("+ p.Name +") Prisoner::DetermineStrippingType", false)
            i += 1
        endWhile
        totals[8] = self.__Ms(Utility.GetCurrentRealTime() - t)

        ; --- ranked report ---
        bool[] printed = new bool[9]
        int rank = 0
        while (rank < N)
            int best = -1
            int k = 0
            while (k < N)
                if (!printed[k] && (best < 0 || totals[k] > totals[best]))
                    best = k
                endif
                k += 1
            endWhile
            printed[best] = true
            log("NAME BREAKDOWN #" + (rank + 1) + ": " + names[best] + " - " + self.__PerOp(totals[best], R) + " per call")
            rank += 1
        endWhile

        display_result(true)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Which natives cost a frame? Test 68 found Actor.GetBaseObject() ~12ms and Form.GetName() ~13ms (about one frame
    at ~90 FPS) while StringUtil / JContainers / plain Papyrus are sub-millisecond. This times 24 representative
    calls, R rounds each, ranked, so the "engine natives on game objects cost a frame each" rule rests on a census
    and not on one pair of natives. The numbers scale with the frame time: note the FPS overlay when running it.
    Tests only, nothing in production is changed.
/;
state Test_Natives_Census
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor a = __SpawnTempActor()
        Actor player = Game.GetPlayer()
        Form baseObject = a.GetBaseObject()
        Faction crimeFaction = prison.PrisonFaction
        Spell prisonerSpell = RPB_Utility.RPB_PrisonerSpell()
        string sample = "[WIDeadBodyCleanupScript < (FF000E02)>]"
        int map = JMap.object()

        int R = 20
        int N = 24
        string[] names = new string[24]
        int[] totals = new int[24]

        int sinkI = 0
        float sinkF = 0.0
        bool sinkB = false
        string sinkS = ""
        Form sinkO = none
        ActorBase sinkAB = none
        Cell sinkC = none
        Actor sinkA = none
        int i = 0
        float t = 0.0

        names[0] = "[engine] Actor.GetFormID()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = a.GetFormID()
            i += 1
        endWhile
        totals[0] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[1] = "[engine] Actor.GetBaseObject()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkO = a.GetBaseObject()
            i += 1
        endWhile
        totals[1] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[2] = "[engine] Actor.GetActorBase()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkAB = a.GetActorBase()
            i += 1
        endWhile
        totals[2] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[3] = "[engine] Form.GetName() on a read base object"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkS = baseObject.GetName()
            i += 1
        endWhile
        totals[3] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[4] = "[engine] Faction.GetName()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkS = crimeFaction.GetName()
            i += 1
        endWhile
        totals[4] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[5] = "[engine] Actor.GetWornForm(slot)"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkO = a.GetWornForm(0x00000004)
            i += 1
        endWhile
        totals[5] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[6] = "[engine] Actor.HasSpell(spell)"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkB = a.HasSpell(prisonerSpell)
            i += 1
        endWhile
        totals[6] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[7] = "[engine] Actor.IsDead()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkB = a.IsDead()
            i += 1
        endWhile
        totals[7] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[8] = "[engine] Actor.Is3DLoaded()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkB = a.Is3DLoaded()
            i += 1
        endWhile
        totals[8] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[9] = "[engine] Actor.IsEnabled()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkB = a.IsEnabled()
            i += 1
        endWhile
        totals[9] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[10] = "[engine] Actor.GetLevel()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = a.GetLevel()
            i += 1
        endWhile
        totals[10] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[11] = "[engine] Actor.GetParentCell()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkC = a.GetParentCell()
            i += 1
        endWhile
        totals[11] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[12] = "[engine] ObjectReference.GetPositionX()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkF = a.GetPositionX()
            i += 1
        endWhile
        totals[12] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[13] = "[engine] Actor.GetDistance(player)"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkF = a.GetDistance(player)
            i += 1
        endWhile
        totals[13] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[14] = "[engine] Game.GetPlayer()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkA = Game.GetPlayer()
            i += 1
        endWhile
        totals[14] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[15] = "[engine] Utility.GetCurrentGameTime()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkF = Utility.GetCurrentGameTime()
            i += 1
        endWhile
        totals[15] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[16] = "[engine] Utility.GetCurrentRealTime()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkF = Utility.GetCurrentRealTime()
            i += 1
        endWhile
        totals[16] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[17] = "[SKSE] StringUtil.GetLength()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = StringUtil.GetLength(sample)
            i += 1
        endWhile
        totals[17] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[18] = "[SKSE] StringUtil.Substring()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkS = StringUtil.Substring(sample, 2, 5)
            i += 1
        endWhile
        totals[18] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[19] = "[Papyrus] Math.LeftShift()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = Math.LeftShift(1, 5)
            i += 1
        endWhile
        totals[19] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[20] = "[JC] JMap.getInt()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = JMap.getInt(map, "k")
            i += 1
        endWhile
        totals[20] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[21] = "[JC] JMap.setInt()"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            JMap.setInt(map, "k", 1)
            i += 1
        endWhile
        totals[21] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[22] = "[JC] JDB.solveInt(path)"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = JDB.solveInt(".rpb_root.storage.census")
            i += 1
        endWhile
        totals[22] = self.__Ms(Utility.GetCurrentRealTime() - t)

        names[23] = "[Papyrus] trivial own function call (baseline)"
        t = Utility.GetCurrentRealTime()
        i = 0
        while (i < R)
            sinkI = self.__Ms(0.0)
            i += 1
        endWhile
        totals[23] = self.__Ms(Utility.GetCurrentRealTime() - t)

        JValue.release(map)

        ; --- ranked report ---
        bool[] printed = new bool[24]
        int rank = 0
        while (rank < N)
            int best = -1
            int k = 0
            while (k < N)
                if (!printed[k] && (best < 0 || totals[k] > totals[best]))
                    best = k
                endif
                k += 1
            endWhile
            printed[best] = true
            log("NATIVE CENSUS #" + (rank + 1) + ": " + names[best] + " - " + self.__PerOp(totals[best], R) + " per call")
            rank += 1
        endWhile

        display_result(true)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


;/
    ActorBase.GetName() now caches the name (GetBaseObject() + GetName() are ~25ms of engine natives). The cached
    value must equal the native one, the second read must be much cheaper than the first, and every registered kind
    (prisoner, arrestee, captor) must return the same name for the same actor.
/;
state Test_ActorBase_CachedName
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = self.__RegisterPrisonerAndWait(a, prison)
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif

        string nativeName = a.GetBaseObject().GetName()

        float t = Utility.GetCurrentRealTime()
        string first = p.Name
        int msFirst = self.__Ms(Utility.GetCurrentRealTime() - t)

        t = Utility.GetCurrentRealTime()
        string second = ""
        int i = 0
        while (i < 20)
            second = p.Name
            i += 1
        endWhile
        int msCached = self.__Ms(Utility.GetCurrentRealTime() - t)

        step = assert_true(first == nativeName, "First read '" + first + "' differs from the nativeName name '" + nativeName + "'")
        ok = ok && step
        step = assert_true(second == nativeName, "Cached read '" + second + "' differs from the nativeName name '" + nativeName + "'")
        ok = ok && step
        step = assert_true(p.GetName() == nativeName, "GetName() differs from the nativeName name")
        ok = ok && step
        step = assert_true(nativeName != "", "The dummy has no name, cannot prove anything")
        ok = ok && step
        log("CACHED NAME '" + nativeName + "' | first read (may already be cached by registration) " + msFirst + "ms | 20 cached reads " + msCached + "ms")

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


;/
    GetFormNameCached() must give exactly Faction.GetName() (first call, which reads the engine, and repeated calls),
    for two different factions and for None (""), and it makes Prisoner.Bounty (two faction-name reads per call) cheap
    while the value stays the same (bounty 3000 set through the same ActorVars key as test 67).
/;
state Test_Utility_FormNameCache
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Faction crimeFaction = prison.PrisonFaction
        string otherHold = ""
        string[] holds = prison.Config.Holds
        int i = 0
        while (i < holds.Length && otherHold == "")
            if (holds[i] != prison.Hold)
                otherHold = holds[i]
            endif
            i += 1
        endWhile
        Faction otherFaction = RPB_Utility.GetCrimeFactionByHold(otherHold)

        ; Forget the cached entries so the first call really reads the engine
        int names = JDB.solveObj(".rpb_root.form_names")
        if (names)
            JFormMap.removeKey(names, crimeFaction)
            JFormMap.removeKey(names, otherFaction)
        endif

        float t = Utility.GetCurrentRealTime()
        string first = RPB_Utility.GetFormNameCached(crimeFaction)
        int msFirst = self.__Ms(Utility.GetCurrentRealTime() - t)
        t = Utility.GetCurrentRealTime()
        string second = ""
        i = 0
        while (i < 20)
            second = RPB_Utility.GetFormNameCached(crimeFaction)
            i += 1
        endWhile
        int msCached = self.__Ms(Utility.GetCurrentRealTime() - t)

        step = assert_true(first == crimeFaction.GetName() && first != "", "First read '" + first + "' differs from Faction.GetName() '" + crimeFaction.GetName() + "'")
        ok = ok && step
        step = assert_true(second == first, "Cached read '" + second + "' differs from the first read '" + first + "'")
        ok = ok && step
        step = assert_true(otherFaction != none && RPB_Utility.GetFormNameCached(otherFaction) == otherFaction.GetName(), "The second faction (" + otherHold + ") name differs from Faction.GetName()")
        ok = ok && step
        step = assert_true(RPB_Utility.GetFormNameCached(none) == "", "None should give an empty name")
        ok = ok && step
        log("FORM NAME CACHE '" + first + "' | first (engine) read " + msFirst + "ms | 20 cached reads " + msCached + "ms")

        ; Bounty: same value, cheaper
        Actor a = __SpawnTempActor()
        RPB_Prisoner p = self.__RegisterPrisonerAndWait(a, prison)
        if (!p)
            display_result(assert_true(false, "Prisoner never registered"))
            return
        endif
        RPB_StorageVars.SetIntOnReference(RPB_Utility.GetFormNameCached(crimeFaction) + "::Latent Bounty Non-Violent", a, 3000, "ActorVars")
        step = assert_true(p.Bounty == 3000, "Bounty is " + p.Bounty + ", expected 3000")
        ok = ok && step

        t = Utility.GetCurrentRealTime()
        int sink = 0
        i = 0
        while (i < 10)
            sink = p.Bounty
            i += 1
        endWhile
        log("FORM NAME CACHE 10 Bounty reads " + self.__Ms(Utility.GetCurrentRealTime() - t) + "ms (about 22ms each before the cache)")

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


; ----------------------------------------------------------
;   Native cost probe (test 72)
;
;   Test 69 found every vanilla engine native costs ~one frame (10.5-12.9ms at 90 FPS) while SKSE / JContainers /
;   Math natives and plain Papyrus do not, but not WHY. This probe answers the questions the census cannot:
;     1. distribution: is the cost a constant ~1/FPS (structural frame-locking) or variable (contention)?
;     2. is it per native or per stack resume: do 3 natives back to back cost 3 frames or 1?
;     3. do parallel stacks pay in parallel (K stacks x M natives ~ M frames) or serialized (K x M frames)?
;   Every sample is the difference between two consecutive Utility.GetCurrentRealTime() reads (that read is itself
;   one engine native, so "timer only" is the baseline and the other sequences are read against it).
; ----------------------------------------------------------

Actor __probeActor
Actor __probeSinkA
int __probeSinkI
bool __probeSinkB
int __probeMap
int __probeParallelIterations
bool[] __probeWorkerDone
int[] __probeWorkerMs

; ~0.75ms of plain Papyrus per unit
function __ProbeBusy(int aiUnits)
    int i = 0
    while (i < aiUnits)
        __probeSinkI = self.__Ms(0.0)
        i += 1
    endWhile
endFunction

function __ProbeNatives(int aiMode)
    if (aiMode == 1)
        __probeSinkA = Game.GetPlayer()
    elseif (aiMode == 2)
        __probeSinkA = Game.GetPlayer()
        __probeSinkI = __probeActor.GetFormID()
        __probeSinkB = __probeActor.IsDead()
    elseif (aiMode == 3)
        __probeSinkI = StringUtil.GetLength("probe")
        __probeSinkI = JMap.getInt(__probeMap, "k")
    elseif (aiMode == 4)
        self.__ProbeBusy(5)
    elseif (aiMode == 5)
        __probeSinkA = Game.GetPlayer()
        self.__ProbeBusy(5)
        __probeSinkI = __probeActor.GetFormID()
        self.__ProbeBusy(5)
    endif
endFunction

; One sample per iteration: the time from the previous timer read to this one
float[] function __ProbeRun(int aiMode, int aiIterations)
    float[] samples = new float[64]
    float last = Utility.GetCurrentRealTime()
    int i = 0
    while (i < aiIterations && i < 64)
        self.__ProbeNatives(aiMode)
        float now = Utility.GetCurrentRealTime()
        samples[i] = now - last
        last = now
        i += 1
    endWhile
    return samples
endFunction

; Insertion sort of the first @aiCount entries
float[] function __ProbeSorted(float[] akSamples, int aiCount)
    float[] sorted = new float[64]
    int i = 0
    while (i < aiCount)
        float value = akSamples[i]
        int j = i - 1
        while (j >= 0 && sorted[j] > value)
            sorted[j + 1] = sorted[j]
            j -= 1
        endWhile
        sorted[j + 1] = value
        i += 1
    endWhile
    return sorted
endFunction

event OnNativeProbeWorker(string asEventName, string asMode, float afWorker, Form akSender)
    int worker = afWorker as int
    float t0 = Utility.GetCurrentRealTime()
    float[] samples = self.__ProbeRun(1, __probeParallelIterations)
    __probeWorkerMs[worker] = self.__Ms(Utility.GetCurrentRealTime() - t0)
    __probeWorkerDone[worker] = true
endEvent

;/
    See the header above. Logs, per sequence, min / median / max of N consecutive samples in ms:
      timer only            baseline (one engine native per sample)
      GetPlayer             + 1 engine native
      3 engine natives      GetPlayer + GetFormID + IsDead back to back
      SKSE natives          StringUtil.GetLength + JMap.getInt
      plain Papyrus ~3.7ms  5 own function calls
      natives with Papyrus  GetPlayer, ~3.7ms of Papyrus, GetFormID, ~3.7ms of Papyrus
    then the parallel probe: 1 stack vs 4 stacks each doing M "GetPlayer" samples, wall clock each.
    Note the FPS overlay when running it; run again at another frame cap / with XPMSE and Nemesis off to compare.
/;
state Test_Natives_Probe
    function Setup()
        Actor a = __SpawnTempActor()
        __probeActor = a
        __probeMap = JMap.object()
        int N = 40

        string[] labels = new string[6]
        labels[0] = "timer only (1 engine native per sample)"
        labels[1] = "timer + Game.GetPlayer()"
        labels[2] = "timer + 3 engine natives back to back (GetPlayer, GetFormID, IsDead)"
        labels[3] = "timer + 2 SKSE natives (StringUtil.GetLength, JMap.getInt)"
        labels[4] = "timer + ~3.7ms of plain Papyrus"
        labels[5] = "timer + GetPlayer, Papyrus, GetFormID, Papyrus (natives separated by work)"

        float baselineMedian = 0.0
        int mode = 0
        while (mode < 6)
            float[] samples = self.__ProbeRun(mode, N)
            float[] sorted = self.__ProbeSorted(samples, N)
            float minMs = sorted[0] * 1000.0
            float medianMs = sorted[N / 2] * 1000.0
            float maxMs = sorted[N - 1] * 1000.0
            if (mode == 0)
                baselineMedian = medianMs
            endif
            log("NATIVE PROBE " + labels[mode] + ": min " + (minMs as int) + " | median " + (medianMs as int) + " | max " + (maxMs as int) + " ms, +" + ((medianMs - baselineMedian) as int) + "ms over timer only (N=" + N + ")")
            mode += 1
        endWhile

        ; --- parallel stacks: 1 worker vs 4, each M GetPlayer samples ---
        __probeParallelIterations = 20
        self.RegisterForModEvent("RPB_NativeProbe", "OnNativeProbeWorker")

        int[] wall = new int[2]
        int run = 0
        while (run < 2)
            int workers = 1
            if (run == 1)
                workers = 4
            endif
            __probeWorkerDone = new bool[8]
            __probeWorkerMs = new int[8]

            float tStart = Utility.GetCurrentRealTime()
            int w = 0
            while (w < workers)
                self.SendModEvent("RPB_NativeProbe", "go", w)
                w += 1
            endWhile

            bool allDone = false
            while (!allDone && (Utility.GetCurrentRealTime() - tStart) < 60.0)
                Utility.Wait(0.05)
                allDone = true
                w = 0
                while (w < workers)
                    if (!__probeWorkerDone[w])
                        allDone = false
                    endif
                    w += 1
                endWhile
            endWhile
            wall[run] = self.__Ms(Utility.GetCurrentRealTime() - tStart)
            log("NATIVE PROBE parallel: " + workers + " stack(s) x " + __probeParallelIterations + " samples of timer + GetPlayer: wall " + wall[run] + "ms | each stack's own time " + __probeWorkerMs[0] + "/" + __probeWorkerMs[1] + "/" + __probeWorkerMs[2] + "/" + __probeWorkerMs[3] + " ms" + self.__StringIf(!allDone, " (NOT all finished)"))
            run += 1
        endWhile
        log("NATIVE PROBE parallel verdict: 1 stack " + wall[0] + "ms vs 4 stacks " + wall[1] + "ms (overlapped ~equal, serialized ~4x)")

        JValue.release(__probeMap)
        display_result(true)
    endFunction

    function Teardown()
        self.UnregisterForModEvent("RPB_NativeProbe")
        __TeardownAllTempActors()
    endFunction
endState


;/
    New-save bug: option defaults were only registered when an MCM page rendered, so on a new game every setting
    read 0 / false / "" (a prisoner got no sentence) until the Haafingar page had been opened. EnsureAllOptionDefaults()
    registers the mcm.json defaults of every config shape at setup / game load / OnConfigInit. Proof:
      1. every registered default is forgotten (DebugClearOptionDefaults): "Jail::Minimum Sentence" and
         "Jail::Bounty to Sentence" read 0, like on a new game before any page is opened;
      2. EnsureAllOptionDefaults() with no page visited: every option in mcm.json that has a "Default" (bool, number
         or string) has exactly that default again, the two sentence options read their JSON value, and the outfit
         names (hardcoded defaults) are back;
      3. a second call changes nothing (same settings version, and much cheaper).
    The defaults are deterministic (they come from mcm.json), so the live save ends in the same state as before.
/;
state Test_MCM_DefaultsWithoutPageVisit
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_MCM mcm = prison.Config.MCM
        bool ok = true
        bool step = false

        int optionsObj = RPB_Data.MCM_GetOptionObject()
        string[] shapes = JMap.allKeysPArray(optionsObj)
        log("MCM DEFAULTS config shapes in mcm.json: " + shapes.Length)

        ; 1. Forget every default: a new game before any page is opened
        mcm.DebugClearOptionDefaults()
        step = assert_true(mcm.GetOptionDefaultFloat("Jail::Minimum Sentence") == 0.0 && mcm.GetOptionDefaultFloat("Jail::Bounty to Sentence") == 0.0, "The defaults were not cleared")
        ok = ok && step

        ; 2. Register them without visiting any page
        float t = Utility.GetCurrentRealTime()
        mcm.EnsureAllOptionDefaults()
        int msEnsure = self.__Ms(Utility.GetCurrentRealTime() - t)

        int checked = 0
        int wrong = 0
        int s = 0
        while (s < shapes.Length)
            int pageObj = JMap.getObj(optionsObj, shapes[s])
            string[] optionKeys = JMap.allKeysPArray(pageObj)
            int o = 0
            while (o < optionKeys.Length)
                int optionMap = JMap.getObj(pageObj, optionKeys[o])

                if (JMap.hasKey(optionMap, "Default"))
                    int defaultType = JMap.valueType(optionMap, "Default")
                    bool matches = true

                    if (defaultType == 2 && mcm.IsPropertyValueOfTypeBool(optionMap, "Default"))
                        matches = mcm.GetOptionDefaultBool(optionKeys[o]) == (JMap.getInt(optionMap, "Default") as bool)
                    elseif (defaultType == 2 || defaultType == 3)
                        matches = mcm.GetOptionDefaultFloat(optionKeys[o]) == JMap.getFlt(optionMap, "Default")
                    elseif (defaultType == 6)
                        matches = mcm.GetOptionDefaultString(optionKeys[o]) == JMap.getStr(optionMap, "Default")
                    endif

                    checked += 1
                    if (!matches)
                        wrong += 1
                        if (wrong <= 5)
                            log("MCM DEFAULTS missing or different: " + shapes[s] + " / " + optionKeys[o])
                        endif
                    endif
                endif
                o += 1
            endWhile
            s += 1
        endWhile

        step = assert_true(checked >= 50, "Only " + checked + " defaults were found in mcm.json, expected many more")
        ok = ok && step
        step = assert_true(wrong == 0, wrong + " of " + checked + " defaults are missing or different after EnsureAllOptionDefaults() without visiting a page")
        ok = ok && step

        float jsonMinimumSentence = JMap.getFlt(JMap.getObj(JMap.getObj(optionsObj, "Hold"), "Jail::Minimum Sentence"), "Default")
        float jsonBountyToSentence = JMap.getFlt(JMap.getObj(JMap.getObj(optionsObj, "Hold"), "Jail::Bounty to Sentence"), "Default")
        step = assert_true(mcm.GetOptionDefaultFloat("Jail::Minimum Sentence") == jsonMinimumSentence && jsonMinimumSentence > 0.0, "Jail::Minimum Sentence default is " + mcm.GetOptionDefaultFloat("Jail::Minimum Sentence") + ", expected " + jsonMinimumSentence)
        ok = ok && step
        step = assert_true(mcm.GetOptionDefaultFloat("Jail::Bounty to Sentence") == jsonBountyToSentence && jsonBountyToSentence > 0.0, "Jail::Bounty to Sentence default is " + mcm.GetOptionDefaultFloat("Jail::Bounty to Sentence") + ", expected " + jsonBountyToSentence)
        ok = ok && step
        step = assert_true(mcm.GetOptionDefaultString("Outfit 1::Name") == "Outfit 1", "The hardcoded outfit name defaults were not restored")
        ok = ok && step

        ; 3. A second call changes nothing and is much cheaper
        int versionBefore = mcm.GetSettingsVersion(prison.Hold)
        t = Utility.GetCurrentRealTime()
        mcm.EnsureAllOptionDefaults()
        int msSecond = self.__Ms(Utility.GetCurrentRealTime() - t)
        step = assert_true(mcm.GetSettingsVersion(prison.Hold) == versionBefore, "A second EnsureAllOptionDefaults() changed the settings version")
        ok = ok && step

        log("MCM DEFAULTS " + checked + " defaults checked across " + shapes.Length + " shapes, " + wrong + " wrong | first Ensure " + msEnsure + "ms, second (nothing to do) " + msSecond + "ms | Jail::Minimum Sentence " + mcm.GetOptionDefaultFloat("Jail::Minimum Sentence") + ", Jail::Bounty to Sentence " + mcm.GetOptionDefaultFloat("Jail::Bounty to Sentence"))
        display_result(ok)
    endFunction
endState


int __mcmDefaultsChecked

; How many of mcm.json's options that declare a "Default" do not have exactly that default registered right now
int function __CountWrongMcmDefaults(RPB_MCM akMcm)
    int optionsObj = RPB_Data.MCM_GetOptionObject()
    string[] shapes = JMap.allKeysPArray(optionsObj)
    __mcmDefaultsChecked = 0
    int wrong = 0

    int s = 0
    while (s < shapes.Length)
        int pageObj = JMap.getObj(optionsObj, shapes[s])
        string[] optionKeys = JMap.allKeysPArray(pageObj)
        int o = 0
        while (o < optionKeys.Length)
            int optionMap = JMap.getObj(pageObj, optionKeys[o])

            if (JMap.hasKey(optionMap, "Default"))
                int defaultType = JMap.valueType(optionMap, "Default")
                bool matches = true

                if (defaultType == 2 && akMcm.IsPropertyValueOfTypeBool(optionMap, "Default"))
                    matches = akMcm.GetOptionDefaultBool(optionKeys[o]) == (JMap.getInt(optionMap, "Default") as bool)
                elseif (defaultType == 2 || defaultType == 3)
                    matches = akMcm.GetOptionDefaultFloat(optionKeys[o]) == JMap.getFlt(optionMap, "Default")
                elseif (defaultType == 6)
                    matches = akMcm.GetOptionDefaultString(optionKeys[o]) == JMap.getStr(optionMap, "Default")
                endif

                __mcmDefaultsChecked += 1
                if (!matches)
                    wrong += 1
                endif
            endif
            o += 1
        endWhile
        s += 1
    endWhile

    return wrong
endFunction

;/
    OnConfigInit -> InitializeOptions() replaces optionsDefaultValueMap with a new empty map, and the persisted
    "warmed shapes" marker used to survive that, so EnsureAllOptionDefaults() (from PerformSetup or the next game load)
    skipped every shape and the defaults stayed empty: the new-save bug again, depending on which of PerformSetup and
    OnConfigInit ran first. The test warms everything, replaces the default map exactly as InitializeOptions() does
    (test hook, marker untouched), checks the defaults are gone, calls EnsureAllOptionDefaults() and checks that every
    default is back.
/;
state Test_MCM_DefaultsAfterMapReplaced
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_MCM mcm = prison.Config.MCM
        bool ok = true
        bool step = false

        mcm.EnsureAllOptionDefaults()
        int wrongBefore = self.__CountWrongMcmDefaults(mcm)
        step = assert_true(wrongBefore == 0 && __mcmDefaultsChecked >= 50, "Precondition failed: " + wrongBefore + " of " + __mcmDefaultsChecked + " defaults wrong before the map was replaced")
        ok = ok && step

        ; What OnConfigInit -> InitializeOptions() does to the default map, marker untouched
        mcm.DebugReplaceOptionDefaultsMap()
        int wrongAfterReplace = self.__CountWrongMcmDefaults(mcm)
        step = assert_true(wrongAfterReplace > 0, "The replaced default map still holds the defaults, cannot prove anything")
        ok = ok && step

        mcm.EnsureAllOptionDefaults()
        int wrongAfterEnsure = self.__CountWrongMcmDefaults(mcm)
        step = assert_true(wrongAfterEnsure == 0, wrongAfterEnsure + " of " + __mcmDefaultsChecked + " defaults are still missing after EnsureAllOptionDefaults() on a replaced default map (the warmed marker was trusted)")
        ok = ok && step
        log("MCM DEFAULTS after map replaced: " + wrongAfterReplace + " missing right after the replacement, " + wrongAfterEnsure + " after EnsureAllOptionDefaults() (of " + __mcmDefaultsChecked + ")")

        display_result(ok)
    endFunction
endState


;/
    The flow profiler must cost (almost) nothing and record nothing when off, and when on it records marks and
    reports them at FlowEnd(): FlowBegin/FlowMark are no-ops with profiling off (Count stays 0); with it on, three marks
    give Count 3 and FlowEnd() closes the flow (later marks are ignored); a run through Utility.Wait shows a phase of
    roughly the waited time in the log ("FLOW:" lines). The setting is restored afterwards.
/;
state Test_FlowProfiler
    function Setup()
        bool ok = true
        bool step = false
        bool wasEnabled = RPB_Utility.IsFlowProfilingEnabled()

        ; Off: nothing is recorded, and a mark is cheap
        RPB_Utility.DisableFlowProfiling()
        RPB_Utility.FlowBegin("test off")
        RPB_Utility.FlowMark("ignored")
        step = assert_true(RPB_StorageVars.GetInt("Count", "Profile") == 0, "Marks were recorded with profiling off")
        ok = ok && step

        float t = Utility.GetCurrentRealTime()
        int i = 0
        while (i < 20)
            RPB_Utility.FlowMark("ignored")
            i += 1
        endWhile
        log("FLOW PROFILER 20 marks with profiling off: " + self.__Ms(Utility.GetCurrentRealTime() - t) + "ms (includes two timer frames)")

        ; On: marks are recorded, FlowEnd reports and closes the flow
        RPB_Utility.EnableFlowProfiling()
        RPB_Utility.FlowBegin("test flow")
        RPB_Utility.FlowMark("phase A (no work)")
        Utility.Wait(0.5)
        RPB_Utility.FlowMark("phase B (waited 0.5s)")
        RPB_Utility.FlowEnd("phase C (end)")
        step = assert_true(RPB_StorageVars.GetInt("Count", "Profile") == 3, "Expected 3 recorded marks, got " + RPB_StorageVars.GetInt("Count", "Profile"))
        ok = ok && step
        step = assert_true(RPB_StorageVars.GetInt("Active", "Profile") == 0, "The flow is still active after FlowEnd()")
        ok = ok && step

        RPB_Utility.FlowMark("after the end (ignored)")
        step = assert_true(RPB_StorageVars.GetInt("Count", "Profile") == 3, "A mark after FlowEnd() was recorded")
        ok = ok && step

        ; FlowEnsure starts a flow only when none is running
        RPB_Utility.FlowEnsure("ensured")
        RPB_Utility.FlowMark("one")
        RPB_Utility.FlowEnsure("ensured again (must not reset)")
        RPB_Utility.FlowMark("two")
        step = assert_true(RPB_StorageVars.GetInt("Count", "Profile") == 2, "FlowEnsure restarted a running flow (Count " + RPB_StorageVars.GetInt("Count", "Profile") + ")")
        ok = ok && step
        RPB_Utility.FlowEnd()

        if (!wasEnabled)
            RPB_Utility.DisableFlowProfiling()
        endif
        log("FLOW PROFILER look for the 'FLOW:' lines above: phase B should be about 500ms")
        display_result(ok)
    endFunction
endState


; ==========================================================
;   Arrest -> Imprison -> Release stress tests (no blind delays)
;
;   The fixed Utility.Wait()s in Arrestee.Destroy()/RevertArrest() were removed. Papyrus is timing sensitive (modlist
;   weight, number of actors in flight), so these run the REAL flow (Arrest.ArrestActor -> mod event -> arrestee ->
;   prisoner -> cell -> Imprisoned -> release) on temp NPCs, alone and in bursts, and poll the actual state with a
;   bounded timeout instead of sleeping. A failure names the actor and the state it got stuck in.
;   Needs the player to be near Haafingar with a guard around (same as the F1 "arrest selected NPC" test).
; ==========================================================

; Waits (bounded, polling) until the actor is imprisoned; returns the ms it took, or -1 on timeout
;/
    After the test actors were torn down: nothing may be left behind. The prisoner list is back to its size before the
    test, its index maps are consistent, and the manager's "prisons with prisoners" number matches (it used to be an
    event-driven counter that drifted under concurrency and left the MCM's "Check Prisoner" page visible).
/;
bool function __StressAssertNoLeaks(RPB_Prison akPrison, RPB_PrisonManager akManager, int aiBaseCount, int aiBasePrisons)
    Utility.Wait(1.0)
    bool ok = true
    bool step = assert_true(akPrison.Prisoners.Count == aiBaseCount, "The prisoner list holds " + akPrison.Prisoners.Count + " entries after the test, expected " + aiBaseCount + " (leaked entries)")
    ok = ok && step
    string consistency = akPrison.Prisoners.ValidateIndexConsistency()
    step = assert_true(consistency == "", "The prisoner list's index maps are inconsistent: " + consistency)
    ok = ok && step
    step = assert_true(akManager.PrisonsWithPrisonersCount == aiBasePrisons, "PrisonsWithPrisonersCount is " + akManager.PrisonsWithPrisonersCount + " after the test, expected " + aiBasePrisons)
    ok = ok && step
    log("STRESS leak check: prisoner list " + akPrison.Prisoners.Count + " (was " + aiBaseCount + "), consistency '" + consistency + "', prisons with prisoners " + akManager.PrisonsWithPrisonersCount + " (was " + aiBasePrisons + ")")
    return ok
endFunction

int function __StressWaitImprisoned(Actor akActor, float afTimeout)
    float t0 = Utility.GetCurrentRealTime()
    while ((Utility.GetCurrentRealTime() - t0) < afTimeout)
        if (RPB_Utility.IsActorImprisoned(akActor))
            return self.__Ms(Utility.GetCurrentRealTime() - t0)
        endif
        Utility.Wait(0.1)
    endWhile
    return -1
endFunction

; Waits (bounded, polling) until the actor is no longer a registered prisoner of the prison; returns ms, or -1
int function __StressWaitReleased(Actor akActor, RPB_Prison akPrison, float afTimeout)
    float t0 = Utility.GetCurrentRealTime()
    while ((Utility.GetCurrentRealTime() - t0) < afTimeout)
        if (!RPB_Utility.IsActorImprisoned(akActor) && akPrison.Prisoners.AtKey(akActor) == none)
            return self.__Ms(Utility.GetCurrentRealTime() - t0)
        endif
        Utility.Wait(0.1)
    endWhile
    return -1
endFunction

; Gives the actor a bounty and starts a teleport-to-cell arrest through the real event flow
function __StressArrest(Actor akGuard, Actor akActor)
    RPB_Utility.ClearCrumbs(akActor)
    RPB_ActorVars.SetCrimeGold(akGuard.GetCrimeFaction(), akActor, 2000)
    RPB_API.GetArrest().ArrestActor(akGuard, akActor, RPB_API.GetArrest().ARREST_TYPE_TELEPORT_TO_CELL)
endFunction

; The state an actor is left in: everything the arrest/prison flow stores must be gone after a release
string function __StressLeftovers(Actor akActor, RPB_Prison akPrison)
    string left = ""
    if (RPB_Utility.IsActorArrested(akActor))
        left += " [Arrested still set]"
    endif
    if (RPB_Utility.IsActorImprisoned(akActor))
        left += " [Imprisoned still set]"
    endif
    if (RPB_API.GetArrest().Arrestees.AtKey(akActor) != none)
        left += " [still a registered arrestee]"
    endif
    if (akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell()))
        left += " [arrestee spell still on the actor]"
    endif
    if (akPrison.Prisoners.AtKey(akActor) != none)
        left += " [still a registered prisoner]"
    endif
    return left
endFunction

;/
    One NPC, three full cycles back to back: arrest -> imprisoned -> release. The second and third cycles catch stale
    state (the delete-path regression showed up exactly there) and anything the removed waits used to hide.
/;
state Test_ArrestStress_SingleCycles
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        Actor guard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
        bool ok = true
        bool step = false

        step = assert_true(guard != none, "No guard near the player to perform the arrests (stand near a guard in Solitude)")
        ok = ok && step
        if (!guard)
            display_result(false)
            return
        endif

        Actor a = __SpawnTempActor()
        int cycle = 1
        while (cycle <= 3 && ok)
            self.__StressArrest(guard, a)
            int msImprison = self.__StressWaitImprisoned(a, 30.0)
            step = assert_true(msImprison >= 0, "Cycle " + cycle + ": the actor never reached Imprisoned (60 s)" + self.__StressLeftovers(a, prison))
            ok = ok && step
            if (!step)
                log("STRESS cycle " + cycle + ": stuck, arrested=" + RPB_Utility.IsActorArrested(a) + " arrestee=" + (RPB_API.GetArrest().Arrestees.AtKey(a) != none) + " prisoner=" + (prison.Prisoners.AtKey(a) != none))
            else
                RPB_Prisoner prisoner = prison.Prisoners.AtKey(a)
                step = assert_true(prisoner != none && prisoner.JailCell != none, "Cycle " + cycle + ": imprisoned but no prisoner reference / cell")
                ok = ok && step
                if (prisoner)
                    prison.SendReleaseRequest(prisoner)
                endif
                int msRelease = self.__StressWaitReleased(a, prison, 30.0)
                step = assert_true(msRelease >= 0, "Cycle " + cycle + ": the actor was not released cleanly (30 s)" + self.__StressLeftovers(a, prison))
                ok = ok && step
                log("STRESS cycle " + cycle + ": imprisoned after " + msImprison + " ms, released after " + msRelease + " ms")
            endif
            cycle += 1
        endWhile

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    A burst of N NPCs arrested in the same frame with no spacing (what the removed waits used to hide), all imprisoned,
    then all released together, then all re-arrested. Reports per-phase counts and timings.
/;
;/
    What a stuck actor looks like: which registrations and flags exist, i.e. how far the arrest got.
/;
string function __StressDiagnose(Actor akActor, RPB_Prison akPrison, Actor akGuard)
    RPB_Arrest arrest = RPB_API.GetArrest()
    string d = "arrestee=" + (arrest.Arrestees.AtKey(akActor) != none)
    d += " prisoner=" + (akPrison.Prisoners.AtKey(akActor) != none)
    d += " guardIsCaptor=" + (arrest.Captors.AtKey(akGuard) != none)
    d += " Arrest{Arrested=" + RPB_StorageVars.GetBoolOnReference("Arrested", akActor, "Arrest")
    d += " Captured=" + RPB_StorageVars.GetBoolOnReference("Captured", akActor, "Arrest")
    d += " Initialized=" + RPB_StorageVars.GetBoolOnReference("Initialized", akActor, "Arrest") + "}"
    d += " Jail{Initialized=" + RPB_StorageVars.GetBoolOnReference("Initialized", akActor, "Jail")
    d += " Imprisoned=" + RPB_StorageVars.GetBoolOnReference("Imprisoned", akActor, "Jail") + "}"
    d += " hasArresteeSpell=" + akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell())
    d += " hasPrisonerSpell=" + akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell())
    d += " 3DLoaded=" + akActor.Is3DLoaded() + " cell=" + akActor.GetParentCell() + " effects{arrestee/prisoner spells above}"
    d += " " + RPB_Utility.DumpCrumbs(akActor)
    return d
endFunction

bool __stressProfilerWasOn

; The flow profiler is a single global flow: concurrent arrests would interleave its marks, so it is off for the stress bursts
function __StressProfilerOff()
    RPB_Utility.EnableCrumbs()
    __stressProfilerWasOn = RPB_Utility.IsFlowProfilingEnabled()
    if (__stressProfilerWasOn)
        RPB_Utility.DisableFlowProfiling()
    endif
endFunction

function __StressProfilerRestore()
    RPB_Utility.DisableCrumbs()
    if (__stressProfilerWasOn)
        RPB_Utility.EnableFlowProfiling()
        __stressProfilerWasOn = false
    endif
endFunction

int function __StressRunBurst(RPB_Prison akPrison, Actor akGuard, int aiCount, float afStagger = 0.0)
    Actor[] burst = new Actor[10]
    int i = 0
    while (i < aiCount)
        burst[i] = __SpawnTempActor()
        i += 1
    endWhile

    int failures = 0
    int round = 1
    while (round <= 2) ; round 2 = re-arrest the same actors after the burst release
        ; A released NPC gets its AI back and walks off (this dummy has a package that leads into Castle Dour, where its 3D
        ; unloads and no effect can start): put every actor back where __SpawnTempActor had it before each round
        Actor stressPlayer = Game.GetFormEx(0x14) as Actor
        i = 0
        while (i < aiCount)
            burst[i].EnableAI(false)
            burst[i].MoveTo(stressPlayer)
            float loadWait = Utility.GetCurrentRealTime()
            while (!burst[i].Is3DLoaded() && (Utility.GetCurrentRealTime() - loadWait) < 5.0)
                Utility.Wait(0.1)
            endWhile
            i += 1
        endWhile

        float t0 = Utility.GetCurrentRealTime()
        i = 0
        while (i < aiCount)
            self.__StressArrest(akGuard, burst[i])
            if (afStagger > 0.0)
                Utility.Wait(afStagger)
            endif
            i += 1
        endWhile

        int imprisoned = 0
        i = 0
        while (i < aiCount)
            int ms = self.__StressWaitImprisoned(burst[i], 30.0)
            if (ms >= 0)
                imprisoned += 1
            else
                failures += 1
                log("STRESS burst N=" + aiCount + " round " + round + ": actor " + i + " never reached Imprisoned" + self.__StressLeftovers(burst[i], akPrison))
                log("STRESS   stuck actor " + i + " (" + burst[i] + "): " + self.__StressDiagnose(burst[i], akPrison, akGuard))
            endif
            i += 1
        endWhile
        int msAllImprisoned = self.__Ms(Utility.GetCurrentRealTime() - t0)

        ; Release everyone at once
        i = 0
        while (i < aiCount)
            RPB_Prisoner prisoner = akPrison.Prisoners.AtKey(burst[i])
            if (prisoner)
                akPrison.SendReleaseRequest(prisoner)
            endif
            i += 1
        endWhile

        int released = 0
        i = 0
        while (i < aiCount)
            if (self.__StressWaitReleased(burst[i], akPrison, 30.0) >= 0)
                released += 1
            else
                failures += 1
                log("STRESS burst N=" + aiCount + " round " + round + ": actor " + i + " was not released cleanly" + self.__StressLeftovers(burst[i], akPrison))
            endif
            i += 1
        endWhile

        log("STRESS burst N=" + aiCount + " round " + round + ": " + imprisoned + "/" + aiCount + " imprisoned (all after " + msAllImprisoned + " ms), " + released + "/" + aiCount + " released")
        round += 1
    endWhile

    return failures
endFunction

state Test_ArrestStress_Burst
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        Actor guard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
        bool ok = true
        bool step = false

        step = assert_true(guard != none, "No guard near the player to perform the arrests (stand near a guard in Solitude)")
        ok = ok && step
        if (!guard)
            display_result(false)
            return
        endif

        RPB_PrisonManager stressManager = RPB_API.GetPrisonManager()
        int baseCount = prison.Prisoners.Count
        int basePrisons = stressManager.PrisonsWithPrisonersCount

        self.__StressProfilerOff()
        int failures3 = self.__StressRunBurst(prison, guard, 3)
        step = assert_true(failures3 == 0, failures3 + " failures in the N=3 burst (arrest, imprison, release, re-arrest)")
        ok = ok && step

        __TeardownAllTempActors()

        int failures6 = self.__StressRunBurst(prison, guard, 6)
        step = assert_true(failures6 == 0, failures6 + " failures in the N=6 burst (arrest, imprison, release, re-arrest)")
        ok = ok && step

        ok = ok && self.__StressAssertNoLeaks(prison, stressManager, baseCount, basePrisons)

        self.__StressProfilerRestore()
        display_result(ok)
    endFunction

    function Teardown()
        self.__StressProfilerRestore()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Control for the burst: the same N=6 arrests but 0.3 s apart (what Arrest.ArrestActors does), run three times. If the
    same-frame burst fails and this passes, the trigger is concurrent handling of arrests that start in the same frame.
/;
state Test_ArrestStress_Staggered
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        Actor guard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
        bool ok = true
        bool step = false

        step = assert_true(guard != none, "No guard near the player to perform the arrests (stand near a guard in Solitude)")
        ok = ok && step
        if (!guard)
            display_result(false)
            return
        endif

        RPB_PrisonManager stressManager = RPB_API.GetPrisonManager()
        int baseCount = prison.Prisoners.Count
        int basePrisons = stressManager.PrisonsWithPrisonersCount

        self.__StressProfilerOff()
        int total = 0
        int run = 1
        while (run <= 3)
            int failures = self.__StressRunBurst(prison, guard, 6, 0.3)
            log("STRESS staggered run " + run + ": " + failures + " failures")
            total += failures
            __TeardownAllTempActors()
            run += 1
        endWhile
        step = assert_true(total == 0, total + " failures over 3 staggered N=6 runs (arrest, imprison, release, re-arrest)")
        ok = ok && step

        ok = ok && self.__StressAssertNoLeaks(prison, stressManager, baseCount, basePrisons)

        self.__StressProfilerRestore()
        display_result(ok)
    endFunction

    function Teardown()
        self.__StressProfilerRestore()
        __TeardownAllTempActors()
    endFunction
endState


;/
    Two callers run RPB_Arrestee.InitializeState() for a fresh arrestee: the effect's own OnInitialize() and
    EventManager.OnArrestBegin(). Whoever ran the body first used to get false (the function fell off the end without a
    return), so when the event handler won the race it aborted the arrest and left the actor stuck as an arrestee (found
    by the stress test 77 breadcrumbs). Proof: forget the "Initialized" flag, then call it twice; both must return true
    and the flag must be set. The second half calls it while a second arrestee is still starting up.
/;
state Test_Arrestee_InitializeStateReturnsTrue
    function Setup()
        RPB_Arrest arrest = RPB_API.GetArrest()
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Arrestee arrestee = arrest.AwaitArresteeReference(a)
        step = assert_true(arrestee != none, "Could not register the arrestee used for this test")
        ok = ok && step
        if (!arrestee)
            display_result(false)
            return
        endif

        ; The effect's own call has already run: make the state look fresh again
        arrestee.Remove("Initialized")
        step = assert_false(arrestee.Was("Initialized"), "Precondition: the Initialized flag should be gone")
        ok = ok && step

        bool first = arrestee.InitializeState()
        bool second = arrestee.InitializeState()
        step = assert_true(first, "The first InitializeState() call returned false (missing return): the event handler would abort the arrest")
        ok = ok && step
        step = assert_true(second, "The second InitializeState() call returned false")
        ok = ok && step
        step = assert_true(arrestee.Was("Initialized"), "The Initialized flag was not set")
        ok = ok && step

        ; Second half: an arrestee whose effect is still starting up, called immediately from here (the handler's position)
        Actor b = __SpawnTempActor()
        RPB_Arrest arrestRef = RPB_API.GetArrest()
        Spell arresteeSpell = RPB_Utility.RPB_ArresteeSpell()
        b.AddSpell(arresteeSpell, false)
        RPB_Arrestee raced = none
        float t0 = Utility.GetCurrentRealTime()
        while (!raced && (Utility.GetCurrentRealTime() - t0) < 15.0)
            raced = arrestRef.Arrestees.AtKey(b)
            if (!raced)
                Utility.Wait(0.01)
            endif
        endWhile
        step = assert_true(raced != none, "The second arrestee did not register")
        ok = ok && step
        if (raced)
            step = assert_true(raced.InitializeState(), "InitializeState() returned false right after registration (race with the effect's own call)")
            ok = ok && step
            step = assert_true(raced.InitializeState(), "A repeated InitializeState() returned false")
            ok = ok && step
        endif

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


bool function __Near(float afA, float afB, float afTolerance = 0.01)
    float d = afA - afB
    if (d < 0.0)
        d = -d
    endif
    return d <= afTolerance
endFunction

;/
    The monitor used to compute "lowest sentence * 24 + buffer" and then ignore it (a hardcoded 3 hour poll). The pure
    function ComputeNextWakeHours() is the schedule: earliest release + buffer among the prisoners that need a wake, never
    below the minimum, nothing (-1, no error) when there is nothing to monitor, and a bounded re-check while a prisoner is
    away and cannot be read.
/;
state Test_PrisonMonitor_ScheduleMaths
    function Setup()
        bool ok = true
        bool step = false

        ; The example from the design: ten prisoners with two months or more, one with 20 days left -> 20 days + buffer
        float[] left = Utility.CreateFloatArray(11)
        bool[] excluded = Utility.CreateBoolArray(11, false)
        int i = 0
        while (i < 10)
            left[i] = 60.0 + i
            excluded[i] = false ; CreateBoolArray's fill cannot be trusted: assign every element
            i += 1
        endWhile
        left[10] = 20.0
        excluded[10] = false
        float hours = RPB_PrisonMonitor.ComputeNextWakeHours(left, excluded)
        step = assert_true(self.__Near(hours, 480.1), "ten long sentences and one with 20 days left: expected 480.1 hours (20 days + 0.1 buffer), got " + hours)
        ok = ok && step

        ; Nothing eligible: only the Player / an undetermined sentence -> nothing to monitor
        float[] one = Utility.CreateFloatArray(1)
        bool[] oneExcluded = Utility.CreateBoolArray(1, false)
        one[0] = 5.0
        oneExcluded[0] = true
        hours = RPB_PrisonMonitor.ComputeNextWakeHours(one, oneExcluded)
        step = assert_true(self.__Near(hours, -1.0), "only excluded prisoners: expected -1, got " + hours)
        ok = ok && step

        ; Only an away prisoner (unreadable): bounded re-check, default 24 hours
        hours = RPB_PrisonMonitor.ComputeNextWakeHours(one, oneExcluded, true)
        step = assert_true(self.__Near(hours, 24.0), "only an away prisoner: expected the 24 hour re-check, got " + hours)
        ok = ok && step

        ; A readable long sentence plus an away prisoner: the sooner of the two (the re-check)
        left[10] = 20.0
        hours = RPB_PrisonMonitor.ComputeNextWakeHours(left, excluded, true)
        step = assert_true(self.__Near(hours, 24.0), "20 days left plus an away prisoner: expected the 24 hour re-check, got " + hours)
        ok = ok && step

        ; A readable short sentence plus an away prisoner: the short sentence wins (0.5 day = 12 h + 0.1)
        one[0] = 0.5
        oneExcluded[0] = false
        hours = RPB_PrisonMonitor.ComputeNextWakeHours(one, oneExcluded, true)
        step = assert_true(self.__Near(hours, 12.1), "half a day left plus an away prisoner: expected 12.1, got " + hours)
        ok = ok && step

        ; Already served (negative days left): wake at the minimum so the monitor cannot spin
        one[0] = -2.0
        hours = RPB_PrisonMonitor.ComputeNextWakeHours(one, oneExcluded)
        step = assert_true(self.__Near(hours, 1.0), "an already served prisoner: expected the 1 hour minimum, got " + hours)
        ok = ok && step

        ; A huge sentence is scheduled exactly (no cap): 3650 days + buffer
        one[0] = 3650.0
        hours = RPB_PrisonMonitor.ComputeNextWakeHours(one, oneExcluded)
        step = assert_true(self.__Near(hours, 87600.1, 0.5), "a 3650 day sentence: expected 87600.1 hours, got " + hours)
        ok = ok && step

        ; The lowest one wins wherever it is, and an excluded lower one is ignored
        left[0] = 1.0
        excluded[0] = true
        hours = RPB_PrisonMonitor.ComputeNextWakeHours(left, excluded)
        step = assert_true(self.__Near(hours, 480.1), "an excluded 1 day prisoner must be ignored: expected 480.1 hours, got " + hours)
        ok = ok && step

        display_result(ok)
    endFunction
endState

;/
    Characterization: what does the prison's prisoner list hold for an NPC prisoner whose actor goes away (its cell
    unloads, so its effect ends: Disable() does NOT do that) and comes back. The monitor's background processing has no
    RPB_Prisoner object to work with for an away prisoner if the entry goes None. Only registration is asserted; the rest is
    logged: entry / list count / effect state while away, and whether the imprisonment resumed after it loaded again.
/;
state Test_PrisonMonitor_AwayPrisoner
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = __RegisterPrisonerAndWait(a, prison)
        step = assert_true(p != none, "Could not register the prisoner used for this test")
        ok = ok && step
        if (!p)
            display_result(false)
            return
        endif

        log("AWAY before: list Count=" + prison.Prisoners.Count + ", entry for the actor=" + (prison.Prisoners.AtKey(a) != none) + ", effect active=" + p.IsEffectActive + ", GetActors().Length=" + prison.Prisoners.GetActors().Length)

        ; Away: into a jail cell (another cell than the player's, so it unloads)
        ObjectReference farPlace = prison.JailCells[0] as ObjectReference
        step = assert_true(farPlace != none, "The prison has no jail cell to send the actor away to")
        ok = ok && step
        if (!farPlace)
            display_result(false)
            return
        endif

        RPB_Utility.EnableCrumbs()
        RPB_Utility.ClearCrumbs(a)

        a.MoveTo(farPlace)
        Utility.Wait(20.0) ; fixed: the cell unloads a few seconds after the player is not there (an early-exit condition made the first version useless)
        RPB_Prisoner whileAway = prison.Prisoners.AtKey(a)
        log("AWAY 20s after MoveTo(jail cell): 3D loaded=" + a.Is3DLoaded() + ", entry for the actor present=" + (whileAway != none) + ", list Count=" + prison.Prisoners.Count + ", GetActors().Length=" + prison.Prisoners.GetActors().Length + ", cell=" + a.GetParentCell() + ", consistency='" + prison.Prisoners.ValidateIndexConsistency() + "'")
        log("AWAY " + RPB_Utility.DumpCrumbs(a))

        ; Back near the player: the effect starts again
        a.MoveTo(player)
        Utility.Wait(6.0)
        RPB_Prisoner again = prison.Prisoners.AtKey(a)
        string stateBack = ""
        if (again)
            stateBack = again.GetState()
        endif
        log("AWAY 6s after coming back: entry present=" + (again != none) + ", list Count=" + prison.Prisoners.Count + ", state='" + stateBack + "', 3D loaded=" + a.Is3DLoaded())
        step = assert_true(again != none && again.IsEffectActive, "After the actor came back the prisoner list still holds a stale (ended) effect instance")
        ok = ok && step
        step = assert_true(prison.Prisoners.Count == 1 && prison.Prisoners.ValidateIndexConsistency() == "", "The prisoner list is inconsistent after the away/back cycle (Count " + prison.Prisoners.Count + ")")
        ok = ok && step
        log("AWAY " + RPB_Utility.DumpCrumbs(a))
        RPB_Utility.DisableCrumbs()

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    The foreground/background handoff of the prison's monitor without depending on where the player stands: the
    handlers' logic (EnterForeground / EnterBackground) is called directly. Checks the state, IsMonitoring and the pending
    wake, that repeated calls are harmless, and that a request while in the foreground registers nothing. The monitor is
    put back in the state it was found in.
/;
state Test_PrisonMonitor_Handoff
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_PrisonMonitor mon = prison.Monitor
        bool ok = true
        bool step = false

        string originalState = mon.GetState()

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = __RegisterPrisonerAndWait(a, prison)
        step = assert_true(p != none, "Could not register the NPC prisoner used for this test")
        ok = ok && step

        float now = Utility.GetCurrentGameTime()

        mon.EnterBackground()
        step = assert_true(mon.IsMonitoring, "EnterBackground() with an NPC prisoner registered should be monitoring")
        ok = ok && step
        step = assert_true(mon.GetState() == "", "EnterBackground() should leave the default state, is '" + mon.GetState() + "'")
        ok = ok && step
        step = assert_true(mon.NextWakeAt >= now + (1.0 / 24.0) - 0.001, "the pending wake should be at least one game hour away (NextWakeAt " + mon.NextWakeAt + ", now " + now + ")")
        ok = ok && step

        mon.EnterBackground()
        step = assert_true(mon.IsMonitoring && mon.NextWakeAt > 0.0, "EnterBackground() twice should stay monitoring with a wake")
        ok = ok && step

        mon.EnterForeground()
        step = assert_false(mon.IsMonitoring, "EnterForeground() should stop monitoring")
        ok = ok && step
        step = assert_true(mon.GetState() == "Inactive", "EnterForeground() should set the Inactive state, is '" + mon.GetState() + "'")
        ok = ok && step
        step = assert_true(mon.NextWakeAt < 0.0, "EnterForeground() should clear the background wake (NextWakeAt " + mon.NextWakeAt + ")")
        ok = ok && step

        mon.SendRequest()
        step = assert_false(mon.IsMonitoring, "a monitoring request while the player is in the cell (Inactive) must not schedule a background wake")
        ok = ok && step

        mon.EnterForeground()
        step = assert_true(mon.GetState() == "Inactive" && !mon.IsMonitoring, "EnterForeground() twice should stay inactive")
        ok = ok && step

        mon.EnterBackground()
        step = assert_true(mon.IsMonitoring && mon.GetState() == "", "EnterBackground() after the foreground should monitor again")
        ok = ok && step

        ; Put the monitor back the way it was found
        if (originalState == "Inactive")
            mon.EnterForeground()
        else
            mon.EnterBackground()
        endif

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        if (prison.Monitor.GetState() != "Inactive")
            prison.Monitor.Reschedule()
        endif
    endFunction
endState


;/
    PrisonsWithPrisonersCount is read several times while the MCM builds its pages. It loops the prisons' own lists (drift
    free) but must be cheap: the active prisons are cached, so a read is a handful of script property reads instead of a vanilla
    native per quest alias slot (~0.45 s a read). Compares against a slow recount too.
/;
state Test_PrisonManager_CountIsCheap
    function Setup()
        RPB_PrisonManager mgr = RPB_API.GetPrisonManager()
        bool ok = true
        bool step = false

        int first = mgr.PrisonsWithPrisonersCount ; may build the cache

        float t0 = Utility.GetCurrentRealTime()
        int last = 0
        int i = 0
        while (i < 10)
            last = mgr.PrisonsWithPrisonersCount
            i += 1
        endWhile
        int ms = self.__Ms(Utility.GetCurrentRealTime() - t0)

        ; Slow recount straight from the alias slots
        int slow = 0
        int slot = 0
        while (slot < mgr.PrisonSlots)
            RPB_Prison prison = mgr.GetNthAlias(slot) as RPB_Prison
            if (prison && prison.Active && prison.Prisoners.Count > 0)
                slow += 1
            endif
            slot += 1
        endWhile

        step = assert_true(last == slow && first == slow, "PrisonsWithPrisonersCount (" + last + ") differs from a slow recount (" + slow + ")")
        ok = ok && step
        step = assert_true(ms < 100, "10 reads of PrisonsWithPrisonersCount took " + ms + " ms (cached reads should be a few ms)")
        ok = ok && step
        log("COUNT 10 reads took " + ms + " ms, value " + last + " (slow recount " + slow + ")")

        display_result(ok)
    endFunction
endState

;/
    The monitor's core promise: a prisoner whose sentence ends while they are away (3D unloaded, their effect ended) is
    released in the background. Imprisons a temp NPC through the real flow, makes the sentence served (stored time of
    imprisonment far in the past), waits until the actor is away, then runs one monitor pass and checks that the prisoner was
    released and removed from the list, and that nothing leaked.
/;
state Test_PrisonMonitor_HeadlessRelease
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        Actor guard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
        bool ok = true
        bool step = false

        step = assert_true(guard != none, "No guard near the player to perform the arrest (stand near a guard in Solitude)")
        ok = ok && step
        if (!guard)
            display_result(false)
            return
        endif

        RPB_PrisonManager mgr = RPB_API.GetPrisonManager()
        int baseCount = prison.Prisoners.Count
        int basePrisons = mgr.PrisonsWithPrisonersCount

        Actor a = __SpawnTempActor()
        self.__StressArrest(guard, a)
        int msImprison = self.__StressWaitImprisoned(a, 30.0)
        step = assert_true(msImprison >= 0, "The temp NPC was never imprisoned (30 s)" + self.__StressLeftovers(a, prison))
        ok = ok && step
        if (msImprison < 0)
            display_result(false)
            return
        endif

        RPB_Prisoner p = prison.Prisoners.AtKey(a)
        step = assert_true(p != none, "Imprisoned but no prisoner reference")
        ok = ok && step
        if (!p)
            display_result(false)
            return
        endif

        ; Sentence served: imprisoned two days more than the sentence ago (a huge value ran one stack for ~7 minutes, see test 85)
        p.SetFloat("Time of Imprisonment", Utility.GetCurrentGameTime() - (p.Sentence + 2))
        step = assert_true(p.IsSentenceServed, "Precondition: the sentence should count as served")
        ok = ok && step

        ; Make sure it is away (the flow put it in a jail cell; the player is elsewhere)
        Utility.Wait(20.0)
        RPB_Prisoner whileAway = prison.Prisoners.AtKey(a)
        bool activeWhileAway = false
        if (whileAway)
            activeWhileAway = whileAway.IsEffectActive
        endif
        log("HEADLESS before the monitor pass: 3D loaded=" + a.Is3DLoaded() + ", entry present=" + (whileAway != none) + ", effect active=" + activeWhileAway + ", cell=" + a.GetParentCell() + ", imprisoned=" + RPB_Utility.IsActorImprisoned(a))

        prison.Monitor.AwaitPrisoners()

        float t0 = Utility.GetCurrentRealTime()
        while (prison.Prisoners.AtKey(a) != none && (Utility.GetCurrentRealTime() - t0) < 20.0)
            Utility.Wait(0.5)
        endWhile
        step = assert_true(prison.Prisoners.AtKey(a) == none, "The away prisoner (sentence served) was not released by the monitor pass" + self.__StressLeftovers(a, prison))
        ok = ok && step
        step = assert_false(RPB_Utility.IsActorImprisoned(a), "The actor is still flagged as imprisoned after the monitor pass")
        ok = ok && step
        log("HEADLESS after the monitor pass: released=" + (prison.Prisoners.AtKey(a) == none) + ", imprisoned=" + RPB_Utility.IsActorImprisoned(a) + ", list Count=" + prison.Prisoners.Count)

        __TeardownAllTempActors()
        ok = ok && self.__StressAssertNoLeaks(prison, mgr, baseCount, basePrisons)

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState


;/
    A prisoner's day events ran once per elapsed day with no bound: a 100000 day gap (an unrealistic served time in test 84)
    kept one script stack busy for ~7 minutes (about 4 ms per event) and delayed everything else, the player's release included.
    UpdateTimeJailed() now clamps the number of day events (and the Time Jailed stat) to GetMaxDayEventsPerUpdate() (40 years
    by default). The test lowers the bound to 50 and lets 500 days elapse: it must finish quickly and count at most 50 days.
/;
state Test_Prisoner_DayEventBound
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = __RegisterPrisonerAndWait(a, prison)
        step = assert_true(p != none, "Could not register the prisoner used for this test")
        ok = ok && step
        if (!p)
            display_result(false)
            return
        endif

        RPB_Utility.SetMaxDayEventsPerUpdate(50)
        p.SetFloat("Time of Imprisonment", Utility.GetCurrentGameTime() - 500.0)

        float statBefore = p.QueryStat("Time Jailed")
        float t0 = Utility.GetCurrentRealTime()
        p.UpdateTimeJailed()
        int ms = self.__Ms(Utility.GetCurrentRealTime() - t0)
        float counted = p.QueryStat("Time Jailed") - statBefore

        RPB_Utility.SetMaxDayEventsPerUpdate(0) ; back to the default bound

        step = assert_true(ms < 30000, "UpdateTimeJailed() took " + ms + " ms for a 500 day gap with a 50 day bound")
        ok = ok && step
        step = assert_true(counted <= 50.5 && counted > 0.0, "The Time Jailed stat grew by " + counted + " days, expected at most the 50 day bound")
        ok = ok && step
        log("DAYBOUND 500 elapsed days, bound 50: took " + ms + " ms, Time Jailed grew by " + counted)

        display_result(ok)
    endFunction

    function Teardown()
        RPB_Utility.SetMaxDayEventsPerUpdate(0)
        __TeardownAllTempActors()
    endFunction
endState

;/
    The monitor's release queue: due NPC prisoners are released one per wake, ordered by release time, with no duplicates,
    on the monitor's own stack (never inline in the caller). Runs as a dry run (the monitor only records the order it
    would release in), with two bare registered prisoners whose sentences differ.
/;
state Test_PrisonMonitor_ReleaseQueue
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_PrisonMonitor mon = prison.Monitor
        bool ok = true
        bool step = false

        Actor a1 = __SpawnTempActor()
        RPB_Prisoner p1 = __RegisterPrisonerAndWait(a1, prison)
        Actor a2 = __SpawnTempActor()
        RPB_Prisoner p2 = __RegisterPrisonerAndWait(a2, prison)
        step = assert_true(p1 != none && p2 != none, "Could not register the two prisoners used for this test")
        ok = ok && step
        if (!p1 || !p2)
            display_result(false)
            return
        endif

        float now = Utility.GetCurrentGameTime()
        p1.SetInt("Sentence", 10)
        p1.SetFloat("Time of Imprisonment", now)
        p2.SetInt("Sentence", 3)
        p2.SetFloat("Time of Imprisonment", now)

        mon.DebugDryRunReleases = true
        mon.ClearDryRunReleaseOrder()

        mon.QueueRelease(p1) ; the later release is queued first
        mon.QueueRelease(p1) ; duplicate: ignored
        mon.QueueRelease(p2)
        step = assert_true(mon.ReleaseQueueLength >= 1 && mon.ReleaseQueueLength <= 2, "Expected the queue to hold the 2 prisoners (or already be processing them), it holds " + mon.ReleaseQueueLength)
        ok = ok && step

        float t0 = Utility.GetCurrentRealTime()
        while ((mon.ReleaseQueueLength > 0 || mon.GetDryRunReleaseOrder().Length < 2) && (Utility.GetCurrentRealTime() - t0) < 15.0)
            Utility.Wait(0.2)
        endWhile

        Form[] order = mon.GetDryRunReleaseOrder()
        mon.DebugDryRunReleases = false

        step = assert_true(order.Length == 2, "Expected exactly 2 releases (no duplicates), saw " + order.Length)
        ok = ok && step
        if (order.Length == 2)
            step = assert_true(order[0] == a2 as Form && order[1] == a1 as Form, "Expected the 3 day sentence (a2) released before the 10 day sentence (a1)")
            ok = ok && step
        endif
        step = assert_true(mon.ReleaseQueueLength == 0, "The queue should be empty afterwards, holds " + mon.ReleaseQueueLength)
        ok = ok && step
        log("RELEASEQUEUE order: " + order.Length + " releases, queue length now " + mon.ReleaseQueueLength)

        display_result(ok)
    endFunction

    function Teardown()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        prison.Monitor.DebugDryRunReleases = false
        __TeardownAllTempActors()
    endFunction
endState


;/
    The NPC side of the player's time skip is a chronological timeline: two NPC prisoners with 2 and 4 days left and a
    player with 6 days left. They must be released in order of release time, each when ITS time comes (game time passes by
    the difference, not the whole time left each time), and 4 days pass in total here. Dry run (only the order and the game
    time of each release are recorded). NOTE: this really advances the game clock by ~4 days.
/;
state Test_Prison_ReleaseTimeline
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_PrisonMonitor mon = prison.Monitor
        bool ok = true
        bool step = false

        Actor a1 = __SpawnTempActor()
        RPB_Prisoner p1 = __RegisterPrisonerAndWait(a1, prison)
        Actor a2 = __SpawnTempActor()
        RPB_Prisoner p2 = __RegisterPrisonerAndWait(a2, prison)
        step = assert_true(p1 != none && p2 != none, "Could not register the two prisoners used for this test")
        ok = ok && step
        if (!p1 || !p2)
            display_result(false)
            return
        endif

        float start = Utility.GetCurrentGameTime()
        p1.SetInt("Sentence", 4)
        p1.SetFloat("Time of Imprisonment", start)
        p2.SetInt("Sentence", 2)
        p2.SetFloat("Time of Imprisonment", start)

        mon.DebugDryRunReleases = true
        mon.ClearDryRunReleaseOrder()

        int passed = prison.ReleaseDueNPCsInOrder(6.0)

        Form[] order = mon.GetDryRunReleaseOrder()
        float t1 = mon.GetDryRunReleaseTime(a1)
        float t2 = mon.GetDryRunReleaseTime(a2)
        mon.DebugDryRunReleases = false
        log("TIMELINE passed " + passed + " days; a2 (2 day sentence) released at +" + (t2 - start) + ", a1 (4 day sentence) at +" + (t1 - start))

        step = assert_true(order.Length == 2 && order[0] == a2 as Form && order[1] == a1 as Form, "Expected the 2 day sentence released before the 4 day sentence")
        ok = ok && step
        step = assert_true(t2 >= 0.0 && t1 > t2 + 0.9, "The second release should come at least a day after the first (t2 +" + (t2 - start) + ", t1 +" + (t1 - start) + ")")
        ok = ok && step
        ; Not cumulative: the 4 day NPC is released about 4 days in (a cumulative pass would put it around 6)
        step = assert_true((t1 - start) < 5.5 && (t1 - start) >= 3.0, "The 4 day NPC should be released about 4 days in, was +" + (t1 - start))
        ok = ok && step
        step = assert_true(passed >= 3 && passed <= 5, "Expected about 4 days passed by the NPC timeline, passed " + passed)
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        prison.Monitor.DebugDryRunReleases = false
        __TeardownAllTempActors()
    endFunction
endState

;/
    The NPC's original outfit and underwear used to be script variables of the RPB_Prisoner effect instance: an unload ends
    the effect, a reload starts a new instance with empty variables, and the NPC never got his outfit back on release.
    They live in the storage on the actor now. Saves the outfit (and two armors as underwear), sends the actor away and
    back so a new instance starts, and checks the new instance still has them.
/;
state Test_Prisoner_OutfitSurvivesInstanceReplacement
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = __RegisterPrisonerAndWait(a, prison)
        step = assert_true(p != none, "Could not register the prisoner used for this test")
        ok = ok && step
        if (!p)
            display_result(false)
            return
        endif

        p.NPC_SaveOriginalOutfit()
        Outfit saved = p.NPC_OriginalOutfit
        step = assert_true(saved != none, "The original outfit was not saved (the dummy's base outfit may be the naked one)")
        ok = ok && step

        ; Stand-ins for the underwear: two parts of the saved outfit (any two armors will do). Not every NPC has underwear, so the
        ; "no underwear" case (two empty entries) is checked too, further down.
        Armor top = none
        Armor bottom = none
        if (saved)
            int n = saved.GetNumParts()
            int k = 0
            while (k < n)
                Armor part = saved.GetNthPart(k) as Armor
                if (part)
                    if (!top)
                        top = part
                    elseIf (!bottom)
                        bottom = part
                    endif
                endif
                k += 1
            endWhile
        endif
        if (!top)
            top = a.GetWornForm(0x4) as Armor
        endif
        if (!top)
            top = player.GetWornForm(0x4) as Armor
        endif
        if (!bottom)
            bottom = top
        endif
        bool haveStandIn = (top != none)
        if (!haveStandIn)
            log("INCONCLUSIVE: no armor found to use as underwear stand-in, the underwear survival part is skipped")
        endif

        p.NPC_SaveUnderwear(top, bottom)
        if (haveStandIn)
            step = assert_true(p.NPC_GetUnderwearTop() == top, "The underwear was not saved (top " + p.NPC_GetUnderwearTop() + ", raw " + p.GetForm("NPC Underwear Top") + ", expected " + top + ")")
            ok = ok && step
        endif

        ObjectReference farPlace = prison.JailCells[0] as ObjectReference
        a.MoveTo(farPlace)
        Utility.Wait(20.0)
        a.MoveTo(player)
        Utility.Wait(6.0)

        RPB_Prisoner again = prison.Prisoners.AtKey(a)
        step = assert_true(again != none, "The prisoner is not in the list after coming back")
        ok = ok && step
        if (again)
            log("OUTFIT new instance: " + (again != p) + ", saved outfit " + saved + ", after " + again.NPC_OriginalOutfit)
            step = assert_true(again.NPC_OriginalOutfit == saved, "The original outfit did not survive the effect being replaced")
            ok = ok && step
            if (haveStandIn)
                step = assert_true(again.NPC_GetUnderwearTop() == top && again.NPC_GetUnderwearBottom() == bottom, "The underwear did not survive the effect being replaced")
                ok = ok && step
            endif

            ; An NPC without underwear: two empty entries. The property must still return an array (its consumers index it)
            again.NPC_SaveUnderwear(none, none)
            Armor[] none_underwear = again.NPC_GetUnderwear()
            log("NOUNDERWEAR top=" + again.NPC_GetUnderwearTop() + " bottom=" + again.NPC_GetUnderwearBottom() + " array=" + none_underwear)
            step = assert_true(again.NPC_GetUnderwearTop() == none && again.NPC_GetUnderwearBottom() == none, "An NPC without underwear should read back no top and no bottom")
            ok = ok && step
            step = assert_true(none_underwear != none && none_underwear.Length == 2, "NPC_GetUnderwear() should always return a two element array")
            ok = ok && step
        endif

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Guards wear their gear through templates: their base Outfit is none, so restoring the Outfit gives them nothing back.
    The armor an NPC wears is snapshotted before the strip and equipped again after the release. The test dresses the dummy,
    takes the snapshot, undresses it, and checks NPC_ReequipSavedWornArmor() puts the armor on again.
/;
state Test_Prisoner_WornArmorRestored
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = __RegisterPrisonerAndWait(a, prison)
        step = assert_true(p != none, "Could not register the prisoner used for this test")
        ok = ok && step
        if (!p)
            display_result(false)
            return
        endif

        ; Any body armor will do: the player's, or one from the dummy's own outfit
        Armor body = player.GetWornForm(0x4) as Armor
        Outfit o = a.GetActorBase().GetOutfit()
        if (!body && o)
            int n = o.GetNumParts()
            int k = 0
            while (k < n && !body)
                body = o.GetNthPart(k) as Armor
                k += 1
            endWhile
        endif
        if (!body)
            log("INCONCLUSIVE: no armor found to dress the dummy with")
            display_result(ok)
            return
        endif

        a.AddItem(body, 1, true)
        a.EquipItem(body, false, true)
        Utility.Wait(1.0)
        p.NPC_SaveWornArmor()
        a.UnequipAll()
        Utility.Wait(1.0)
        log("WORN before re-equip: " + a.IsEquipped(body))

        int count = p.NPC_ReequipSavedWornArmor()
        Utility.Wait(1.0)
        step = assert_true(count >= 1, "No saved worn armor was re-equipped, count " + count)
        ok = ok && step
        ; The temporary dummy does not always show the equip (no 3D / AI state): observed, not asserted
        log("WORN after re-equip: " + a.IsEquipped(body) + " (observation only)")

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    An NPC with the same sentence that was imprisoned before the player has slightly less time left: it must be part of the
    time skip timeline and be released before the player, not an hour later by the monitor. Dry run, two NPC prisoners:
    a1 has a little less time left than the "player" value passed in, a2 the same, a3 more (not released). NOTE: this really advances the game clock by ~2 days.
/;
state Test_Prison_EqualSentenceOrder
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_PrisonMonitor mon = prison.Monitor
        bool ok = true
        bool step = false

        Actor a1 = __SpawnTempActor()
        RPB_Prisoner p1 = __RegisterPrisonerAndWait(a1, prison)
        Actor a2 = __SpawnTempActor()
        RPB_Prisoner p2 = __RegisterPrisonerAndWait(a2, prison)
        Actor a3 = __SpawnTempActor()
        RPB_Prisoner p3 = __RegisterPrisonerAndWait(a3, prison)
        step = assert_true(p1 != none && p2 != none && p3 != none, "Could not register the three prisoners used for this test")
        ok = ok && step
        if (!p1 || !p2 || !p3)
            display_result(false)
            return
        endif

        float start = Utility.GetCurrentGameTime()
        p1.SetInt("Sentence", 2)
        p1.SetFloat("Time of Imprisonment", start - 0.2) ; imprisoned a few hours earlier: less time left
        p2.SetInt("Sentence", 2)
        p2.SetFloat("Time of Imprisonment", start)
        p3.SetInt("Sentence", 5)
        p3.SetFloat("Time of Imprisonment", start)

        float playerLeft = 2.0 ; the player has the same sentence and was imprisoned after a1 and together with a2
        mon.DebugDryRunReleases = true
        mon.ClearDryRunReleaseOrder()
        prison.ReleaseDueNPCsInOrder(playerLeft)
        Form[] order = mon.GetDryRunReleaseOrder()
        mon.DebugDryRunReleases = false
        log("EQUALORDER released " + order.Length + " NPCs")

        step = assert_true(order.Length == 2, "Expected the two NPCs with a sentence up to the player's to be released, saw " + order.Length)
        ok = ok && step
        if (order.Length == 2)
            step = assert_true(order[0] == a1 as Form && order[1] == a2 as Form, "Expected the earlier imprisoned NPC first, then the equal one")
            ok = ok && step
        endif

        display_result(ok)
    endFunction

    function Teardown()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        prison.Monitor.DebugDryRunReleases = false
        __TeardownAllTempActors()
    endFunction
endState

;/
    The belongings containers are shared between prisoners, so what a prisoner put there is recorded when it is stripped and
    only that is returned on release. Two prisoners are given different items, both are put in ONE container through the
    strip path, then one is given its belongings back: it must get its own item and not the other's.
/;
state Test_Prisoner_OwnBelongingsReturned
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a1 = __SpawnTempActor()
        RPB_Prisoner p1 = __RegisterPrisonerAndWait(a1, prison)
        Actor a2 = __SpawnTempActor()
        RPB_Prisoner p2 = __RegisterPrisonerAndWait(a2, prison)
        step = assert_true(p1 != none && p2 != none, "Could not register the two prisoners used for this test")
        ok = ok && step
        if (!p1 || !p2)
            display_result(false)
            return
        endif

        ObjectReference sharedBox = prison.GetRandomPrisonerContainer("Belongings") as ObjectReference
        step = assert_true(sharedBox != none, "The prison has no belongings sharedBox")
        ok = ok && step
        if (!sharedBox)
            display_result(false)
            return
        endif
        p1.SetForm("Prisoner Belongings Container", sharedBox)
        p2.SetForm("Prisoner Belongings Container", sharedBox)

        Form itemA = Game.GetFormEx(0xF) ; gold
        Form itemB = Game.GetFormEx(0xA) ; lockpick
        a1.RemoveAllItems()
        a2.RemoveAllItems()
        a1.AddItem(itemA, 7, true)
        a2.AddItem(itemB, 3, true)
        step = assert_true(a1.GetItemCount(itemA) == 7 && a2.GetItemCount(itemB) == 3, "The test items could not be added to the dummies")
        ok = ok && step
        int containerA = sharedBox.GetItemCount(itemA)
        int containerB = sharedBox.GetItemCount(itemB)

        p1.SaveBelongingsManifest()
        a1.RemoveAllItems(sharedBox, true, true)
        p2.SaveBelongingsManifest()
        a2.RemoveAllItems(sharedBox, true, true)

        p1.ReturnBelongings()
        Utility.Wait(1.0)
        log("OWNBELONGINGS a1 has " + a1.GetItemCount(itemA) + " of A and " + a1.GetItemCount(itemB) + " of B; sharedBox has " + sharedBox.GetItemCount(itemA) + " of A and " + sharedBox.GetItemCount(itemB) + " of B (before the test A " + containerA + ", B " + containerB + ")")
        step = assert_true(a1.GetItemCount(itemA) == 7, "The first prisoner did not get its own items back, has " + a1.GetItemCount(itemA))
        ok = ok && step
        step = assert_true(a1.GetItemCount(itemB) == 0, "The first prisoner took the other prisoner's items, has " + a1.GetItemCount(itemB))
        ok = ok && step
        step = assert_true(sharedBox.GetItemCount(itemB) == containerB + 3, "The other prisoner's items are no longer in the sharedBox")
        ok = ok && step

        p2.ReturnBelongings() ; leave the sharedBox as it was
        Utility.Wait(1.0)
        step = assert_true(a2.GetItemCount(itemB) == 3, "The second prisoner did not get its own items back, has " + a2.GetItemCount(itemB))
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Mass scenarios (civil war arrests: a whole faction is captured at once). Helpers.
/;
int function __MassCapacity(RPB_Prison akPrison)
    Form[] cells = akPrison.JailCells
    int total = 0
    int i = 0
    while (cells && i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell
        if (jailCell)
            total += jailCell.MaxPrisoners
        endif
        i += 1
    endWhile
    return total
endFunction

int function __MassOccupied(RPB_Prison akPrison)
    Form[] cells = akPrison.JailCells
    int total = 0
    int i = 0
    while (cells && i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell
        if (jailCell)
            total += jailCell.PrisonerCount
        endif
        i += 1
    endWhile
    return total
endFunction

; The cells holding more prisoners than they may (only cells that do not allow overcrowding), "" when none
string function __MassOvercrowded(RPB_Prison akPrison)
    Form[] cells = akPrison.JailCells
    string bad = ""
    int i = 0
    while (cells && i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell
        if (jailCell && !jailCell.AllowOvercrowding && jailCell.PrisonerCount > jailCell.MaxPrisoners)
            bad += " [" + jailCell + " holds " + jailCell.PrisonerCount + " of " + jailCell.MaxPrisoners + "]"
        endif
        i += 1
    endWhile
    return bad
endFunction

; One line per cell: what it holds against what it may hold
function __MassDumpCells(RPB_Prison akPrison, string asLabel)
    Form[] cells = akPrison.JailCells
    string dump = "MASS cells " + asLabel + ":"
    int i = 0
    while (cells && i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell
        if (jailCell)
            dump += " [" + jailCell.ID + " " + jailCell.PrisonerCount + "/" + jailCell.MaxPrisoners
            if (jailCell.AllowOvercrowding)
                dump += " overcrowding allowed"
            endif
            if (jailCell.IsGenderExclusive)
                dump += string_if (jailCell.IsFemaleOnly, " F", " M")
            endif
            dump += "]"
        endif
        i += 1
    endWhile
    log(dump)
endFunction

int function __MassCellsAllowingOvercrowding(RPB_Prison akPrison)
    Form[] cells = akPrison.JailCells
    int n = 0
    int i = 0
    while (cells && i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell
        if (jailCell && jailCell.AllowOvercrowding)
            n += 1
        endif
        i += 1
    endWhile
    return n
endFunction

;/ Wears something of its outfit (or a body armor): what "dressed" means for the report after the release /;
string function __MassOutfitParts(Actor akActor)
    Outfit worn = akActor.GetActorBase().GetOutfit()
    int total = 0
    int carried = 0
    int equippedParts = 0
    if (worn)
        total = worn.GetNumParts()
        int k = 0
        while (k < total)
            Armor part = worn.GetNthPart(k) as Armor
            if (part)
                if (akActor.GetItemCount(part) > 0)
                    carried += 1
                endif
                if (akActor.IsEquipped(part))
                    equippedParts += 1
                endif
            endif
            k += 1
        endWhile
    endif
    return "carried " + carried + ", worn " + equippedParts + " of " + total
endFunction

bool function __MassIsDressed(Actor akActor)
    ; Fully dressed = every outfit part the actor carries is worn (underwear and clothes are worn together): one worn boot is not "dressed"
    Outfit worn = akActor.GetActorBase().GetOutfit()
    int carried = 0
    int equippedParts = 0
    if (worn)
        int n = worn.GetNumParts()
        int k = 0
        while (k < n)
            Armor part = worn.GetNthPart(k) as Armor
            if (part && akActor.GetItemCount(part) > 0)
                carried += 1
                if (akActor.IsEquipped(part))
                    equippedParts += 1
                endif
            endif
            k += 1
        endWhile
    endif

    if (carried > 0)
        return equippedParts == carried
    endif
    ; No carried outer part to check: a body armor counts
    return akActor.GetWornForm(0x4) != none
endFunction

; Per part status of an actor that is not fully dressed: what stands in the way
string function __MassPartsDump(Actor akActor)
    string dump = "parts:"
    Outfit worn = akActor.GetActorBase().GetOutfit()
    if (worn)
        int n = worn.GetNumParts()
        int k = 0
        while (k < n)
            Armor part = worn.GetNthPart(k) as Armor
            if (part)
                dump += " [" + part.GetName() + " " + part + " carried " + akActor.GetItemCount(part) + " worn " + akActor.IsEquipped(part) + "]"
            endif
            k += 1
        endWhile
    endif
    dump += " | body slot " + akActor.GetWornForm(0x4) + ", pelvis slot " + akActor.GetWornForm(0x8000)
    return dump
endFunction

int function __MassCountImprisoned(Actor[] akActors, int aiCount)
    int n = 0
    int i = 0
    while (i < aiCount)
        if (akActors[i] && RPB_Utility.IsActorImprisoned(akActors[i]))
            n += 1
        endif
        i += 1
    endWhile
    return n
endFunction

;/
    Waits until every actor in [0, aiCount) has settled: imprisoned, or no longer in a transitional state (a registered
    arrestee, or a registered prisoner that is not imprisoned yet) for 3 seconds in a row, after at least 5 seconds. Bounded.
    Also reports the slowest poll: a poll that should take 0.5 s and takes seconds is what a stalled script engine looks like.
    returns (int): ms taken.
/;
int function __MassSettle(RPB_Prison akPrison, Actor[] akActors, int aiCount, float afTimeout)
    RPB_Arrest arrest = RPB_API.GetArrest()
    float t0 = Utility.GetCurrentRealTime()
    float stableSince = -1.0
    float maxPollMs = 0.0
    while ((Utility.GetCurrentRealTime() - t0) < afTimeout)
        float pollStart = Utility.GetCurrentRealTime()
        int transitional = 0
        int i = 0
        while (i < aiCount)
            Actor a = akActors[i]
            if (a && !RPB_Utility.IsActorImprisoned(a) && (arrest.Arrestees.AtKey(a) != none || akPrison.Prisoners.AtKey(a) != none))
                transitional += 1
            endif
            i += 1
        endWhile

        float elapsed = Utility.GetCurrentRealTime() - t0
        if (elapsed >= 5.0 && transitional == 0)
            if (stableSince < 0.0)
                stableSince = elapsed
            elseIf (elapsed - stableSince >= 3.0)
                log("MASS settled after " + self.__Ms(elapsed) + " ms, slowest poll " + (maxPollMs as int) + " ms over its 500 ms wait")
                return self.__Ms(elapsed)
            endif
        else
            stableSince = -1.0
        endif

        Utility.Wait(0.5)
        float overMs = (Utility.GetCurrentRealTime() - pollStart) * 1000.0 - 500.0
        if (overMs > maxPollMs)
            maxPollMs = overMs
        endif
    endWhile
    log("MASS DID NOT SETTLE within " + (afTimeout as int) + " s, slowest poll " + (maxPollMs as int) + " ms over its 500 ms wait")
    return self.__Ms(Utility.GetCurrentRealTime() - t0)
endFunction

function __MassPutBack(Actor akActor)
    Actor massPlayer = Game.GetFormEx(0x14) as Actor
    akActor.EnableAI(false)
    akActor.MoveTo(massPlayer)
    float loadWait = Utility.GetCurrentRealTime()
    while (!akActor.Is3DLoaded() && (Utility.GetCurrentRealTime() - loadWait) < 5.0)
        Utility.Wait(0.1)
    endWhile
endFunction

bool function __MassRun(bool abNoOvercrowding, int aiBaseFormId = 0x132AE, int aiTotal = 45)
    RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
    Actor player = Game.GetFormEx(0x14) as Actor
    Actor guard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
    bool ok = true
    bool step = false

    step = assert_true(guard != none, "No guard near the player to perform the arrests (stand near a guard in Solitude)")
    ok = ok && step
    if (!guard)
        return false
    endif

    int TOTAL = aiTotal
    int WAVE = 10
    int BASE = aiBaseFormId
    if (TOTAL > 64)
        TOTAL = 64 ; the actor arrays hold 64
    endif
    log("MASS base actor " + Game.GetFormEx(BASE) + ", " + TOTAL + " clones")

    RPB_PrisonManager massManager = RPB_API.GetPrisonManager()
    int baseCount = prison.Prisoners.Count
    int basePrisons = massManager.PrisonsWithPrisonersCount
    ; A cell that allows overcrowding never fills up, so the prison would never overflow: switch overcrowding off for this test
    RPB_Utility.SetOvercrowdingDisabled(abNoOvercrowding)
    int capacity = self.__MassCapacity(prison)
    int occupiedBefore = self.__MassOccupied(prison)
    int free = capacity - occupiedBefore
    log("MASS cell package capacity " + massManager.GetCellPackageCapacity("S") + " (size S)")
    log("MASS capacity " + capacity + " (occupied before " + occupiedBefore + ", free " + free + "), arresting " + TOTAL + " in waves of " + WAVE + ", " + self.__MassCellsAllowingOvercrowding(prison) + " cells allow overcrowding")
    self.__MassDumpCells(prison, "before")

    self.__StressProfilerOff()
    float tStart = Utility.GetCurrentRealTime()

    Actor[] all = new Actor[64]
    bool[] everImprisoned = new bool[64]
    int spawned = 0
    int spawnFailures = 0
    int waveNumber = 1
    while (spawned < TOTAL)
        int waveEnd = spawned + WAVE
        if (waveEnd > TOTAL)
            waveEnd = TOTAL
        endif

        int k = spawned
        while (k < waveEnd)
            all[k] = __SpawnTempActorOf(BASE)
            if (!all[k])
                spawnFailures += 1
            endif
            k += 1
        endWhile

        float tWave = Utility.GetCurrentRealTime()
        k = spawned
        while (k < waveEnd)
            if (all[k])
                self.__StressArrest(guard, all[k])
                Utility.Wait(0.3)
            endif
            k += 1
        endWhile
        int settleMs = self.__MassSettle(prison, all, waveEnd, 90.0)
        log("MASS wave " + waveNumber + ": actors " + spawned + ".." + (waveEnd - 1) + " arrested, imprisoned so far " + self.__MassCountImprisoned(all, waveEnd) + ", cells hold " + self.__MassOccupied(prison) + " of " + capacity + ", wave took " + self.__Ms(Utility.GetCurrentRealTime() - tWave) + " ms")
        spawned = waveEnd
        waveNumber += 1
    endWhile

    ; Classify: imprisoned / cleanly reverted / stuck
    int imprisoned = 0
    int reverted = 0
    int stuck = 0
    int placed = 0
    int i = 0
    while (i < TOTAL)
        if (all[i])
            placed += 1
            if (RPB_Utility.IsActorImprisoned(all[i]))
                imprisoned += 1
                everImprisoned[i] = true
            elseIf (self.__StressLeftovers(all[i], prison) == "")
                reverted += 1
            else
                stuck += 1
                if (stuck <= 5)
                    log("MASS stuck actor " + i + " (" + all[i] + "):" + self.__StressLeftovers(all[i], prison) + " | " + self.__StressDiagnose(all[i], prison, guard))
                endif
            endif
        endif
        i += 1
    endWhile
    int totalMs = self.__Ms(Utility.GetCurrentRealTime() - tStart)
    self.__MassDumpCells(prison, "after the arrests")

    ; Every imprisoned NPC needs an AI package that keeps it in its cell; the package groups are finite
    int withPackage = 0
    i = 0
    while (i < TOTAL)
        if (all[i] && RPB_Utility.IsActorImprisoned(all[i]))
            RPB_Prisoner pkgPrisoner = prison.Prisoners.AtKey(all[i])
            if (pkgPrisoner && pkgPrisoner.HasCellPackage)
                withPackage += 1
            endif
        endif
        i += 1
    endWhile
    log("MASS packages: " + withPackage + " of " + imprisoned + " imprisoned NPCs hold a cell package")
    log("MASS RESULT placed " + placed + " (spawn failures " + spawnFailures + "): imprisoned " + imprisoned + ", cleanly reverted " + reverted + ", stuck " + stuck + "; free capacity was " + free + "; cells now hold " + self.__MassOccupied(prison) + "; " + totalMs + " ms")

    step = assert_true(spawnFailures == 0, spawnFailures + " NPCs could not be placed, the scenario is incomplete")
    ok = ok && step
    step = assert_true(stuck == 0, stuck + " NPCs are stuck half way (neither imprisoned nor cleanly reverted)")
    ok = ok && step
    if (abNoOvercrowding)
        step = assert_true(imprisoned <= free, "Imprisoned " + imprisoned + " NPCs but only " + free + " places were free")
        ok = ok && step
    endif
    string overcrowded = self.__MassOvercrowded(prison)
    step = assert_true(overcrowded == "", "Cells over their maximum:" + overcrowded)
    ok = ok && step
    int poolSize = massManager.GetCellPackageCapacity("S")
    if (poolSize > 0)
        step = assert_true(imprisoned <= poolSize, "Imprisoned " + imprisoned + " NPCs but there are only " + poolSize + " cell packages")
        ok = ok && step
    endif
    step = assert_true(withPackage >= imprisoned, (imprisoned - withPackage) + " imprisoned NPCs have no cell package (nothing keeps them in their cell)")
    ok = ok && step
    if (imprisoned < free && imprisoned < placed)
        log("MASS NOTE: " + imprisoned + " imprisoned although " + free + " places were free and " + (placed - imprisoned) + " NPCs were left out (gender exclusive cell rules?)")
    endif

    ; Recovery: free two places, arrest two of the NPCs that were turned away, they must get those places
    if (imprisoned >= 2 && reverted >= 2)
        int released2 = 0
        i = 0
        while (i < TOTAL && released2 < 2)
            if (all[i] && RPB_Utility.IsActorImprisoned(all[i]))
                RPB_Prisoner freeing = prison.Prisoners.AtKey(all[i])
                if (freeing)
                    prison.SendReleaseRequest(freeing)
                    int freedMs = self.__StressWaitReleased(all[i], prison, 30.0)
                    step = assert_true(freedMs >= 0, "Prisoner " + i + " was not released while making room")
                    ok = ok && step
                    if (freedMs < 0)
                        log("MASS release stuck while making room, actor " + i + " (" + all[i] + "): " + self.__StressDiagnose(all[i], prison, guard))
                    endif
                    released2 += 1
                endif
            endif
            i += 1
        endWhile

        int retried = 0
        int retriedImprisoned = 0
        i = 0
        while (i < TOTAL && retried < 2)
            if (all[i] && !RPB_Utility.IsActorImprisoned(all[i]) && self.__StressLeftovers(all[i], prison) == "")
                self.__MassPutBack(all[i])
                self.__StressArrest(guard, all[i])
                retried += 1
            endif
            i += 1
        endWhile
        self.__MassSettle(prison, all, TOTAL, 60.0)
        i = 0
        while (i < TOTAL)
            if (all[i] && RPB_Utility.IsActorImprisoned(all[i]))
                retriedImprisoned += 1
                everImprisoned[i] = true
            endif
            i += 1
        endWhile
        log("MASS RECOVERY freed " + released2 + ", re-arrested " + retried + " turned away NPCs, imprisoned now " + retriedImprisoned + " (was " + (imprisoned - released2) + " after the releases)")
        step = assert_true(retriedImprisoned >= (imprisoned - released2) + retried, "The freed cells were not reused: " + retriedImprisoned + " imprisoned, expected " + ((imprisoned - released2) + retried))
        ok = ok && step
    else
        log("MASS RECOVERY skipped (imprisoned " + imprisoned + ", reverted " + reverted + "): the prison did not overflow, raise TOTAL")
    endif

    ; What the belongings manifests hold, before everybody is released
    int manifestsWithItems = 0
    int manifestsEmpty = 0
    int manifestsMissing = 0
    i = 0
    while (i < TOTAL)
        if (all[i] && RPB_Utility.IsActorImprisoned(all[i]))
            if (RPB_StorageVars.GetIntOnReference("Belongings Manifest", all[i], "Jail") == 0)
                manifestsMissing += 1
                string missingDump = RPB_Utility.DumpCrumbs(all[i])
                int strippedAt = StringUtil.Find(missingDump, "Teleported:")
                if (strippedAt >= 0)
                    missingDump = StringUtil.Substring(missingDump, strippedAt)
                endif
                log("MASS manifest missing: actor " + i + " (" + all[i] + "), belongings container " + RPB_StorageVars.GetFormOnReference("Prisoner Belongings Container", all[i], "Jail") + ", Stripped " + RPB_StorageVars.GetBoolOnReference("Stripped", all[i], "Jail") + ", crumbs from the teleport: " + missingDump)
            elseIf (RPB_StorageVars.GetFormsOnReference("Belongings Forms", all[i], "Jail").Length > 0)
                manifestsWithItems += 1
            else
                manifestsEmpty += 1
            endif
        endif
        i += 1
    endWhile
    log("MASS manifests before the release: with items " + manifestsWithItems + ", empty " + manifestsEmpty + ", missing " + manifestsMissing)
    ; What the dress-up will have to work with: saved original outfit and saved body armor (read from the storage before the release)
    int outfitSaved = 0
    int bodySaved = 0
    i = 0
    while (i < TOTAL)
        if (all[i] && RPB_Utility.IsActorImprisoned(all[i]))
            if (RPB_StorageVars.GetFormOnReference("NPC Original Outfit", all[i], "Jail"))
                outfitSaved += 1
            endif
            if (RPB_StorageVars.GetFormOnReference("NPC Worn Armor 32", all[i], "Jail"))
                bodySaved += 1
            endif
        endif
        i += 1
    endWhile
    log("MASS restore data before the release: original outfit saved for " + outfitSaved + " actors, body armor saved for " + bodySaved + " actors")

    ; Mass release: everybody at once
    prison.ResetDressCost()
    float tRelease = Utility.GetCurrentRealTime()
    int toRelease = 0
    bool[] releasing = new bool[64]
    float sendTotalMs = 0.0
    float sendSlowestMs = 0.0
    bool[] dressedRightAfter = new bool[64]
    i = 0
    while (i < TOTAL)
        if (all[i])
            RPB_Prisoner leaving = prison.Prisoners.AtKey(all[i])
            if (leaving)
                releasing[i] = true
                float sendT0 = Utility.GetCurrentRealTime()
                prison.SendReleaseRequest(leaving)
                float sendMs = (Utility.GetCurrentRealTime() - sendT0) * 1000.0
                sendTotalMs += sendMs
            dressedRightAfter[i] = self.__MassIsDressed(all[i]) ; the release equips synchronously and verifies: is it dressed now?
                if (sendMs > sendSlowestMs)
                    sendSlowestMs = sendMs
                endif
                toRelease += 1
            endif
        endif
        i += 1
    endWhile

    log("MASS release requests: " + toRelease + " sent, " + (sendTotalMs as int) + " ms in total, slowest " + (sendSlowestMs as int) + " ms")

    ; Only the actors that were sent for release count (the reverted ones are not prisoners either, and used to be counted)
    int releasedAll = 0
    float releaseDeadline = Utility.GetCurrentRealTime() + 120.0
    while (releasedAll < toRelease && Utility.GetCurrentRealTime() < releaseDeadline)
        releasedAll = 0
        i = 0
        while (i < TOTAL)
            if (releasing[i] && !RPB_Utility.IsActorImprisoned(all[i]) && prison.Prisoners.AtKey(all[i]) == none)
                releasedAll += 1
            endif
            i += 1
        endWhile
        if (releasedAll < toRelease)
            Utility.Wait(0.5)
        endif
    endWhile
    log("MASS RELEASE " + releasedAll + " of " + toRelease + " released in " + self.__Ms(Utility.GetCurrentRealTime() - tRelease) + " ms")
    step = assert_true(releasedAll >= toRelease, "Only " + releasedAll + " of " + toRelease + " prisoners were released in 120 s")
    ok = ok && step

    ; A released NPC must not be registered as a prisoner again (a new effect instance did that after the move)
    Utility.Wait(3.0)
    int ghosts = 0
    i = 0
    while (i < TOTAL)
        if (releasing[i] && prison.Prisoners.AtKey(all[i]) != none)
            ghosts += 1
        endif
        i += 1
    endWhile
    log("MASS ghosts: " + ghosts + " released actors are registered as prisoners again")
    step = assert_true(ghosts == 0, ghosts + " released NPCs were registered as prisoners again")
    ok = ok && step

    ; The delayed re-dress pass (Prison) looks at every released NPC again a few seconds after its release: wait for it before judging
    float passWaitStart = Utility.GetCurrentRealTime()
    while (prison.PendingDressCount() > 0 && (Utility.GetCurrentRealTime() - passWaitStart) < 60.0)
        Utility.Wait(0.5)
    endWhile
    log("MASS dress-up cost (natives only, without waits): " + prison.DressCostSummary())
    log("MASS re-dress pass finished after " + self.__Ms(Utility.GetCurrentRealTime() - passWaitStart) + " ms, still queued " + prison.PendingDressCount())
    if (releasedAll < toRelease)
        int shown = 0
        i = 0
        while (i < TOTAL && shown < 5)
            if (releasing[i] && (RPB_Utility.IsActorImprisoned(all[i]) || prison.Prisoners.AtKey(all[i]) != none))
                log("MASS release stuck, actor " + i + " (" + all[i] + "): " + self.__StressDiagnose(all[i], prison, guard))
                shown += 1
            endif
            i += 1
        endWhile
    endif

    ; How many left dressed: body armor worn, or (when the engine has unloaded them) unknown. Reported, not asserted.
    Utility.Wait(3.0)
    int dressed = 0
    int bareNoBoots = 0
    int underwearOnly = 0
    int unloaded = 0
    i = 0
    while (i < TOTAL)
        if (all[i] && everImprisoned[i])
            if (!all[i].Is3DLoaded())
                unloaded += 1
            elseIf (self.__MassIsDressed(all[i]))
                dressed += 1
            else
                underwearOnly += 1
                string partsDump = self.__MassPartsDump(all[i])
                bool wantCrumbs = underwearOnly <= 3
                if (!wantCrumbs && bareNoBoots < 2 && StringUtil.Find(partsDump, "carried 0") >= 0)
                    wantCrumbs = true ; a part is missing altogether (the other pattern: tunic worn, boots lost)
                    bareNoBoots += 1
                endif
                string bareCrumbs = ""
                if (wantCrumbs)
                    ; only the release part: a log line is cut at about 4100 characters, before it reaches the release entries
                    string bareDump = RPB_Utility.DumpCrumbs(all[i])
                    int releaseAt = StringUtil.Find(bareDump, "Release: start")
                    if (releaseAt >= 0)
                        bareDump = StringUtil.Substring(bareDump, releaseAt)
                    endif
                    bareCrumbs = " | release crumbs: " + bareDump
                endif
                log("MASS bare actor " + i + " (" + all[i] + "): items " + all[i].GetNumItems() + ", base outfit " + all[i].GetActorBase().GetOutfit() + ", outfit parts " + self.__MassOutfitParts(all[i]) + " | " + partsDump + bareCrumbs)
            endif
        endif
        i += 1
    endWhile
    log("MASS DRESSED after the release (NPCs that were imprisoned): dressed " + dressed + ", bare " + underwearOnly + ", 3D unloaded (unknown) " + unloaded + " (see the 'Re-equipped' INFO lines for the per NPC counts)")

    ; Was it dressed right after its release, and lost the clothes later? (separates "the equip never took" from "undone afterwards")
    int rightAfterCount = 0
    int undoneLater = 0
    i = 0
    while (i < TOTAL)
        if (releasing[i] && everImprisoned[i])
            if (dressedRightAfter[i])
                rightAfterCount += 1
                if (all[i].Is3DLoaded() && !self.__MassIsDressed(all[i]))
                    undoneLater += 1
                    log("MASS undone later: actor " + i + " (" + all[i] + ") was dressed right after its release and is not at the end, " + self.__MassPartsDump(all[i]))
                endif
            endif
        endif
        i += 1
    endWhile
    log("MASS dressed right after the release: " + rightAfterCount + " of " + toRelease + "; dressed right after but not at the end: " + undoneLater + "; not dressed even right after: " + (toRelease - rightAfterCount))

    __TeardownAllTempActors()
    RPB_Utility.SetOvercrowdingDisabled(false)
    ok = ok && self.__StressAssertNoLeaks(prison, massManager, baseCount, basePrisons)
    step = assert_true(self.__MassOccupied(prison) == occupiedBefore, "The cells hold " + self.__MassOccupied(prison) + " prisoners after the test, expected " + occupiedBefore)
    ok = ok && step

    self.__StressProfilerRestore()
    return ok
endFunction

;/
    Civil war scenario: 45 NPCs (base 0x132AE) are arrested in waves of 10 (0.3 s apart, what Arrest.ArrestActors does) into a
    prison that cannot hold them all (cells do not allow overcrowding). Every actor must end in exactly one of two states:
    imprisoned, or cleanly reverted (arrest undone, nothing left behind); none may be stuck half way, no cell may exceed its
    maximum, and imprisoned actors may not exceed the free capacity. Then two prisoners are released and two of the reverted
    NPCs are arrested again (the freed cells must be reused), then everybody is released at once and the list must end clean.
    What to do with the overflow (transfer to another prison, a holding area, overcrowding) is a design question; this test
    pins what must hold whatever is chosen: no stuck state, no leaks, no over-capacity.
    NOTE: the free cells of Haafingar are used, run it somewhere with an empty prison (only the player stands near Solitude).
/;
state Test_MassImprisonment
    function Setup()
        display_result(self.__MassRun(true))
    endFunction

    function Teardown()
        RPB_Utility.SetOvercrowdingDisabled(false)
        self.__StressProfilerRestore()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Same scenario as test 92 but with the prison's own cell data (Cell 04 allows overcrowding), so the cells no longer limit the
    number of prisoners: what limits it now is the cell package pool (an NPC without a package walks out of its cell). Every
    imprisoned NPC must hold a package, the imprisoned NPCs may not exceed the pool, and the rest is cleanly reverted.
/;
state Test_MassImprisonmentRealData
    function Setup()
        display_result(self.__MassRun(false))
    endFunction

    function Teardown()
        RPB_Utility.SetOvercrowdingDisabled(false)
        self.__StressProfilerRestore()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Same scenario as test 94 with Imperial Soldiers (GuardSolitudeImperialJail, 0xBED96): generic actors whose outfit comes from
    a template (the base outfit is none), so what they wear again depends on the worn-armor snapshot and the re-dress pass alone.
    Not dunCGImperialSoldierFodderC01 (0xE77F9, test 96 originally): that base crashed the game twice during wave 1 (10 clones
    spawned/arrested at once), with no Papyrus error and no crash dump available to explain it. dunCG is the Civil War radiant
    dungeon-assault actor template; whether the crash is that actor's own quest scripting/data or a spawn-concurrency/asset
    spike unrelated to it is untested (see test 98, a small-scale run of the original base, and KNOWN_ISSUES.md).
/;
state Test_MassSoldiers
    function Setup()
        display_result(self.__MassRun(false, 0xBED96, 45))
    endFunction

    function Teardown()
        RPB_Utility.SetOvercrowdingDisabled(false)
        self.__StressProfilerRestore()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Same scenario as test 94 with Bandits (EncBandit01MissileNordF, 0x37BFF): template outfit like the soldiers, plus weapons and
    gear in the belongings.
/;
state Test_MassBandits
    function Setup()
        display_result(self.__MassRun(false, 0x37BFF, 45))
    endFunction

    function Teardown()
        RPB_Utility.SetOvercrowdingDisabled(false)
        self.__StressProfilerRestore()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Smoke test for the base that crashed the game in test 96 (dunCGImperialSoldierFodderC01, 0xE77F9), at a scale (3 clones, one
    wave) far below the 10 that preceded both crashes. If this alone crashes, the actor's own data/scripting is implicated
    regardless of concurrency; if it passes, the crash in test 96 was more likely a spawn-concurrency/asset-loading spike from
    10 heavy-geared clones loading at once, not something about this specific actor.
/;
state Test_MassSoldiersSmokeTest
    function Setup()
        display_result(self.__MassRun(false, 0xE77F9, 3))
    endFunction

    function Teardown()
        RPB_Utility.SetOvercrowdingDisabled(false)
        self.__StressProfilerRestore()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Escorts several NPCs to their cells with the player genuinely moved far away (there is no dev override for
    IsFarFromPlayer() - it's a real distance check, so this actually relocates the player rather than faking it),
    then checks every one of them for the two things round 9's off-screen fix was about: AI disabled, and physically
    placed in their own jail cell. Exists so this gets checked with one F1 run instead of a manual retest each time.

    Uses ARREST_TYPE_ESCORT_TO_CELL specifically (unlike __StressArrest/__MassRun's ARREST_TYPE_TELEPORT_TO_CELL,
    which deliberately skips the escort/off-screen question entirely) since the real Escort-to-Cell Scene path is
    exactly what's being checked here.

    Deliberately does not assert on IsInCell: already known (round 5/9) to be GetDistance-blind for an off-screen
    actor, so it isn't a meaningful pass/fail signal for this test - only logged, for visibility, same as
    Action_CheckPrisonersAI (RPB_Actions.psc) already does. That function itself can't be called headlessly (it
    always opens an interactive prison-picker menu), so its exact log line is reproduced here inline instead.
/;
; Scratch state for Test_MultiPrisonerOffScreenAIAndPlacement, shared between its Setup() and Teardown() - a Papyrus
; state block can't itself declare member variables, so these live at script scope instead.
Actor[] __test101Actors
Actor __test101Player
Actor __test101Guard

state Test_MultiPrisonerOffScreenAIAndPlacement
    function Setup()
        int COUNT = 5
        int BASE = 0x37BFF ; Bandit - the same base test 097 already uses

        __test101Player = Game.GetFormEx(0x14) as Actor
        __test101Guard  = RPB_Utility.GetNearestGuard(__test101Player, 3000.0, __test101Player)

        bool step = assert_true(__test101Guard != none, "No guard near the player to perform the arrests (stand near a guard)")
        if (!__test101Guard)
            return
        endif

        ; __test101Guard itself is never used to make an arrest below - only as the base to clone disposable guards
        ; from, and as a stable "player, come back near here" anchor between bandits. See the loop comment for why.
        int guardBaseFormId = __test101Guard.GetBaseObject().GetFormID()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_Arrest arrest = RPB_API.GetArrest()

        __test101Actors = new Actor[5]
        int i = 0
        while (i < COUNT)
            ; Every bandit gets her own disposable guard (a temp clone of the real nearby guard's base, mirroring
            ; test 102's already-proven pattern - never the real persistent NPC), instead of reusing one real guard
            ; for all 5. Confrontation Scenes have exactly one "Escort" alias slot (ROADMAP.md) - binding it to a
            ; NEW arrest reassigns whatever Forced Package it was already driving for a PREVIOUS, still-in-progress
            ; arrest using the same guard, with no protection at the native alias level, regardless of any Papyrus-
            ; side queue timing. A real test watched this happen live: guard arrests bandit 1 (cuffed), bandit 2
            ; spawns, the SAME guard arrests her too, and bandit 1 is left stranded - cuffed, no Scene, nowhere to
            ; go. Separate guards remove this collision risk structurally instead of hoping a timeout is long enough.
            Actor guard = __SpawnTempActorOf(guardBaseFormId)
            __test101Actors[i] = __SpawnTempActorOf(BASE)

            if (guard && __test101Actors[i])
                ; __SpawnTempActorOf() disables AI to freeze the dummy in place - fine for every other consumer
                ; (they all use ARREST_TYPE_TELEPORT_TO_CELL, no confrontation Scene involved), but a Scene cannot
                ; make progress on an actor whose AI is disabled. Confirmed as the real cause of confrontation
                ; Scenes never confirming here: nothing else re-enables it before these actors are fed into a real
                ; Scene. Both Scene participants need it.
                guard.EnableAI(true)
                __test101Actors[i].EnableAI(true)

                RPB_Utility.ClearCrumbs(__test101Actors[i])
                RPB_ActorVars.SetCrimeGold(guard.GetCrimeFaction(), __test101Actors[i], 2000)
                arrest.ArrestActor(guard, __test101Actors[i], arrest.ARREST_TYPE_ESCORT_TO_CELL)

                ; Wait for the confrontation Scene to actually confirm before moving the player away - moving away any
                ; earlier can break the Scene outright (round 11 - a Scene needs the player nearby at least long
                ; enough to get through its first real phase). Arrestees.AtKey(actor) != none is NOT that signal: it
                ; becomes true as soon as the Arrestee effect attaches (EventManager.OnArrestBegin's very first step),
                ; well before the confrontation Scene is even asked to start - a real run confirmed every single
                ; bandit failing "never confirmed" once every bandit's own player-departure landed that early. The
                ; real signal is the same one AwaitConfrontationScene() itself polls: "Scene Confirmed", set the
                ; moment "Hands Behind Back" (the Scene's own first real phase cue) fires.
                RPB_Arrestee arresteeRef = arrest.Arrestees.AtKey(__test101Actors[i])
                float confirmWaitStart = Utility.GetCurrentRealTime()
                while ((!arresteeRef || !arresteeRef.GetBool("Scene Confirmed")) && (Utility.GetCurrentRealTime() - confirmWaitStart) < 30.0)
                    Utility.Wait(0.5)
                    arresteeRef = arrest.Arrestees.AtKey(__test101Actors[i])
                endWhile

                ; Now genuinely leave for the rest of THIS bandit's escort - the actual scenario round 9's fix is
                ; about: player present when the arrest started, then leaves mid-escort. Without this, every bandit
                ; would finish her WHOLE escort with the player still nearby, and round 9's off-screen correction
                ; (gated on IsFarFromPlayer() at the exact moment escort completes) would never even trigger - a
                ; real run confirmed exactly that: two bandits that did get imprisoned still failed "AI disabled".
                ; A huge offset relative to THIS bandit's own guard puts the player many cells away in the same
                ; worldspace, well beyond load range, without needing a hardcoded marker reference.
                __test101Player.MoveTo(guard, afXOffset = 50000.0, afYOffset = 50000.0)

                ; Raised from 30s to 120s: the earlier, weaker signal (just "tracked") only needed to survive to
                ; confrontation-confirm, but IsActorImprisoned needs a full confrontation+cuff+walk+strip+walk+lock
                ; cycle to complete, which a flat 30s wasn't enough time for - a real run's early timeouts were very
                ; likely genuinely-still-in-progress escorts, not stuck ones, misread as failures.
                float imprisonWaitStart = Utility.GetCurrentRealTime()
                while (!RPB_Utility.IsActorImprisoned(__test101Actors[i]) && (Utility.GetCurrentRealTime() - imprisonWaitStart) < 120.0)
                    Utility.Wait(0.5)
                endWhile

                if (!RPB_Utility.IsActorImprisoned(__test101Actors[i]))
                    log("101 " + __test101Actors[i].GetDisplayName() + " never confirmed the confrontation Scene within 120s")
                endif

                ; Back near the original guard's spot, ready for the next bandit's own confrontation to actually
                ; start (a fresh guard clone spawns at the player's current position).
                __test101Player.MoveTo(__test101Guard)
            endif
            i += 1
        endWhile

        ; Scaled with COUNT, not a flat budget: total settle time is roughly linear in how many prisoners are
        ; sharing one serialized Scene queue.
        int settleMs = self.__MassSettle(prison, __test101Actors, COUNT, COUNT * 30.0)
        log("101 settled after " + settleMs + " ms")

        int passed = 0
        i = 0
        while (i < COUNT)
            if (__test101Actors[i])
                RPB_Prisoner prisoner = prison.Prisoners.AtKey(__test101Actors[i])
                if (prisoner)
                    int nameLength  = StringUtil.GetLength(prisoner.Name)
                    string tabs     = string_if (nameLength >= 10, "\t", "\t\t")
                    LogNoType("["+ prisoner.Name +"] "+ tabs + prisoner.GetActor() +"\t{ AI: " + YesNo(prisoner.HasAI()) + " | In Cell: "+ YesNo(prisoner.IsInCell) +" | " + prisoner.JailCell.ID +" ("+ prisoner.JailCell + " [Package: "+ prisoner.CellPackage.GetName() +"]) | " + "Location: "+ prisoner.GetCurrentCell() +"}")

                    bool aiCorrect       = !prisoner.HasAI()
                    bool locationCorrect = prisoner.GetCurrentCell() == prisoner.JailCell.GetParentCell()
                    step = assert_true(aiCorrect, prisoner.Name + " should have AI disabled while the player is away")
                    step = assert_true(locationCorrect, prisoner.Name + " should be physically located in their jail cell") && step
                    if (aiCorrect && locationCorrect)
                        passed += 1
                    endif
                else
                    assert_true(false, __test101Actors[i].GetDisplayName() + " never became a tracked prisoner")
                endif
            endif
            i += 1
        endWhile

        display_result(passed == COUNT)
    endFunction

    function Teardown()
        if (__test101Player && __test101Guard)
            __test101Player.MoveTo(__test101Guard) ; bring the player back rather than leaving them 50000 units out in the wilderness
        endif
        __TeardownAllTempActors()
    endFunction
endState

;/
    Kills the escorting guard shortly after a real arrest begins, and confirms round 10's RPB_Captor.OnDeath fix
    actually reverts the arrest quickly instead of the old ~24s stall (AwaitConfrontationScene's own unrelated retry
    timeout, which only watches for the arrestee's own death, not the captor's). Couldn't be tested by hand - too
    hard to reproduce reliably - hence this test.

    The "guard" is a temp clone of a real nearby guard's base (same faction/behavior), never the real, persistent
    NPC itself - Kill() is permanent, and this test has no business leaving a lasting kill on the player's save.
/;
Actor __test102Actor
Actor __test102Guard

state Test_CaptorDeathRevertsArrestQuickly
    function Setup()
        int BASE = 0x37BFF ; Bandit - same base test 097/101 already use

        Actor player = Game.GetFormEx(0x14) as Actor
        Actor realGuard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
        bool step = assert_true(realGuard != none, "No guard near the player to find a guard base to clone")
        if (!realGuard)
            return
        endif

        __test102Guard = __SpawnTempActorOf(realGuard.GetBaseObject().GetFormID())
        step = assert_true(__test102Guard != none, "Failed to spawn a temp clone of the nearby guard") && step
        if (!__test102Guard)
            return
        endif
        ; __SpawnTempActorOf() disables AI to freeze the dummy in place - fine for every other consumer (they all
        ; use ARREST_TYPE_TELEPORT_TO_CELL, no confrontation Scene involved), but a Scene cannot make progress on an
        ; actor whose AI is disabled. Both Scene participants need it re-enabled here.
        __test102Guard.EnableAI(true)

        __test102Actor = __SpawnTempActorOf(BASE)
        step = assert_true(__test102Actor != none, "Failed to spawn the test actor") && step
        if (!__test102Actor)
            return
        endif
        __test102Actor.EnableAI(true)

        RPB_Utility.ClearCrumbs(__test102Actor)
        RPB_ActorVars.SetCrimeGold(__test102Guard.GetCrimeFaction(), __test102Actor, 2000)
        RPB_API.GetArrest().ArrestActor(__test102Guard, __test102Actor, RPB_API.GetArrest().ARREST_TYPE_ESCORT_TO_CELL)

        ; Wait for AssignArrestee to have actually run (the Captor's own Arrestee field set) before killing the guard.
        ; Arrestees.AtKey(actor) != none is NOT that signal: it becomes true as soon as the Arrestee effect attaches
        ; (EventManager.OnArrestBegin's very first step), well before AwaitCaptorReference/AssignArrestee (several
        ; steps later in that same event) ever run - killing right after that first signal lands squarely in the
        ; narrow pre-AssignArrestee window OnDeath's own fix deliberately doesn't chase (see RPB_Captor.OnDeath's doc
        ; comment), instead of the common case that fix targets (guard dies well after the link is made). A real run
        ; confirmed exactly this: OnDeath never fired, and the arrest only ever reverted via AwaitConfrontationScene's
        ; unrelated ~24s timeout. GetCaptor() (round 11, never force-registers) confirms the real, later signal.
        RPB_Arrest arrest = RPB_API.GetArrest()
        RPB_Captor captorRef = arrest.GetCaptor(__test102Guard)
        float waitStart = Utility.GetCurrentRealTime()
        while ((!captorRef || captorRef.Arrestee != __test102Actor) && (Utility.GetCurrentRealTime() - waitStart) < 10.0)
            Utility.Wait(0.2)
            captorRef = arrest.GetCaptor(__test102Guard)
        endWhile

        step = assert_true(captorRef != none && captorRef.Arrestee == __test102Actor, "Arrest never actually began within 10s") && step
        if (!captorRef || captorRef.Arrestee != __test102Actor)
            display_result(false)
            return
        endif

        float killTime = Utility.GetCurrentRealTime()
        __test102Guard.Kill()

        ; The old bug left the arrestee stuck for ~24s (3 retries x 8s, AwaitConfrontationScene's own unrelated
        ; timeout). Give the fix a generous few seconds, well short of that, to prove it's actually event-driven.
        float revertWaitStart = Utility.GetCurrentRealTime()
        while (arrest.Arrestees.AtKey(__test102Actor) != none && (Utility.GetCurrentRealTime() - revertWaitStart) < 8.0)
            Utility.Wait(0.2)
        endWhile

        float revertedAfter = Utility.GetCurrentRealTime() - killTime
        bool reverted = arrest.Arrestees.AtKey(__test102Actor) == none
        log("102 arrest reverted: " + reverted + ", " + revertedAfter + "s after the guard died")

        step = assert_true(reverted, "The arrest should have reverted quickly after the guard died, not stayed stuck") && step
        display_result(reverted)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
    endFunction
endState

;/
    Hostile prisoners (bandits, Civil War soldiers, Forsworn) are neutralized the moment their arrest is confirmed
    (RPB_Arrest.BeginArrest, via RPB_Utility.NeutralizeHostileActor - covers confrontation/escort/teleport, not just the cell),
    removed from whatever faction RPB_Utility.RPB_GetHostileFactions() resolves (so guards stop treating them as a target), and
    Prison's delayed queue restores it some time after release. Arrests a bandit, checks its hostile factions are already gone
    right after the arrest (before imprisonment even settles - proves BeginArrest's neutralize fired, not just Imprison()'s),
    checks they're still gone once imprisoned, releases it, checks they stay gone right after release, then uses the dev
    override to skip most of the delay and checks they come back.
    Needs RPB_GetHostileFactions() to resolve at least one faction (PO3 Papyrus Extender): logs INCONCLUSIVE, not a failure, if
    it doesn't (see test 100's header comment for the same note).
/;
state Test_HostilePrisoner_NeutralizedThenRestored
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        Actor guard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
        bool ok = true
        bool step = false

        step = assert_true(guard != none, "No guard near the player to perform the arrest (stand near a guard in Solitude)")
        ok = ok && step
        if (!guard)
            display_result(false)
            return
        endif

        Form[] hostileFactions = RPB_Utility.RPB_GetHostileFactions()
        if (!hostileFactions || hostileFactions.Length == 0)
            log("INCONCLUSIVE: RPB_GetHostileFactions resolved no factions (PO3 Papyrus Extender missing, or every editor ID failed - check the WARN lines); the neutralize/restore feature is a no-op until then")
            display_result(ok)
            return
        endif

        Actor a = __SpawnTempActorOf(0x37BFF) ; the bandit base used by test 97
        step = assert_true(a != none, "Could not spawn the test bandit")
        ok = ok && step
        if (!a)
            display_result(false)
            return
        endif

        Faction[] originalHostile = new Faction[16]
        int originalCount = 0
        int i = 0
        while (i < hostileFactions.Length && originalCount < 16)
            Faction f = hostileFactions[i] as Faction
            if (f && a.IsInFaction(f))
                originalHostile[originalCount] = f
                originalCount += 1
            endif
            i += 1
        endWhile

        if (originalCount == 0)
            log("INCONCLUSIVE: the test bandit (0x37BFF) is not a member of any faction RPB_GetHostileFactions() resolved, nothing to neutralize")
            display_result(ok)
            return
        endif

        RPB_Utility.SetHostilityRestoreOverrideHours(0.05) ; a few real seconds at the default time scale, not a real 24 game-hour wait
        Actor[] all = new Actor[1]
        all[0] = a
        self.__StressArrest(guard, a)

        ; Neutralize now happens at arrest time (RPB_Arrest.BeginArrest), well before Imprison() - the arrest events dispatch
        ; through a mod event, so poll briefly rather than asserting the instant __StressArrest returns.
        i = 0
        int stillHostileAtArrest = originalCount
        float arrestWaitStart = Utility.GetCurrentRealTime()
        while (stillHostileAtArrest > 0 && (Utility.GetCurrentRealTime() - arrestWaitStart) < 10.0)
            stillHostileAtArrest = 0
            i = 0
            while (i < originalCount)
                if (a.IsInFaction(originalHostile[i]))
                    stillHostileAtArrest += 1
                endif
                i += 1
            endWhile
            if (stillHostileAtArrest > 0)
                Utility.Wait(0.2)
            endif
        endWhile
        step = assert_true(stillHostileAtArrest == 0, stillHostileAtArrest + " of " + originalCount + " hostile factions were still present right after arrest (BeginArrest's neutralize did not fire)")
        ok = ok && step
        log("HOSTILE at arrest time (before imprisonment settles): " + stillHostileAtArrest + " of " + originalCount + " factions still present")

        self.__MassSettle(prison, all, 1, 60.0)

        RPB_Prisoner p = prison.Prisoners.AtKey(a)
        step = assert_true(p != none, "The test bandit was not imprisoned")
        ok = ok && step
        if (!p)
            display_result(false)
            return
        endif

        i = 0
        int stillHostile = 0
        while (i < originalCount)
            if (a.IsInFaction(originalHostile[i]))
                stillHostile += 1
            endif
            i += 1
        endWhile
        step = assert_true(stillHostile == 0, stillHostile + " of " + originalCount + " hostile factions were not removed while imprisoned")
        ok = ok && step
        log("HOSTILE while imprisoned: " + originalCount + " factions found before arrest, " + stillHostile + " still present, Aggression now " + a.GetActorValue("Aggression"))

        prison.SendReleaseRequest(p)
        int releasedMs = self.__StressWaitReleased(a, prison, 30.0)
        step = assert_true(releasedMs >= 0, "The test bandit was not released")
        ok = ok && step

        i = 0
        int hostileRightAfter = 0
        while (i < originalCount)
            if (a.IsInFaction(originalHostile[i]))
                hostileRightAfter += 1
            endif
            i += 1
        endWhile
        step = assert_true(hostileRightAfter == 0, hostileRightAfter + " of " + originalCount + " hostile factions came back immediately on release (should stay neutral for a while)")
        ok = ok && step

        ; Wait past the (overridden) restore delay
        float waitStart = Utility.GetCurrentRealTime()
        while (prison.PendingHostilityRestoreCount() > 0 && (Utility.GetCurrentRealTime() - waitStart) < 30.0)
            Utility.Wait(0.5)
        endWhile

        i = 0
        int restored = 0
        while (i < originalCount)
            if (a.IsInFaction(originalHostile[i]))
                restored += 1
            endif
            i += 1
        endWhile
        step = assert_true(restored == originalCount, "Only " + restored + " of " + originalCount + " hostile factions were restored after the delay")
        ok = ok && step
        log("HOSTILE restored: " + restored + " of " + originalCount + " factions back, Aggression now " + a.GetActorValue("Aggression") + ", still queued " + prison.PendingHostilityRestoreCount())

        display_result(ok)
    endFunction

    function Teardown()
        RPB_Utility.SetHostilityRestoreOverrideHours(0.0)
        __TeardownAllTempActors()
    endFunction
endState

;/
    The player gets the same treatment as an NPC (see test 99): a disguise mod such as Master of Disguise adds the PLAYER to a
    hostile faction while disguised (confirmed against its real source: Player.AddToFaction(disguiseFaction), no rank), and
    nearby guards then attack the disguised player the same way they'd attack a real bandit. Manually adds the player to a
    resolved hostile faction (standing in for what a disguise mod would already have done), imprisons the player through the
    real Imprison() (MakePrisoner + the same manual sentence/cell setup as Test_Imprison_Player_Without_Arresting_Required_Bounty),
    checks the faction is gone while imprisoned, releases through the real release path, checks it stays gone right after, then
    uses the dev override to skip most of the delay and checks it comes back - exactly test 99's shape, on the player instead
    of a temp bandit.
    Needs RPB_GetHostileFactions() to resolve at least one faction (same PO3/CK-free dependency as test 99): logs INCONCLUSIVE,
    not a failure, if it doesn't.
/;
state Test_HostilePlayer_NeutralizedThenRestored
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        Actor player = Game.GetFormEx(0x14) as Actor
        bool ok = true
        bool step = false

        Form[] hostileFactions = RPB_Utility.RPB_GetHostileFactions()
        if (!hostileFactions || hostileFactions.Length == 0)
            log("INCONCLUSIVE: RPB_GetHostileFactions resolved no factions (PO3 Papyrus Extender missing, or every editor ID failed - check the WARN lines); the neutralize/restore feature is a no-op until then")
            display_result(ok)
            return
        endif

        Faction disguiseFaction = hostileFactions[0] as Faction
        step = assert_true(disguiseFaction != none, "The first resolved hostile faction did not cast to Faction")
        ok = ok && step
        if (!disguiseFaction)
            display_result(false)
            return
        endif

        ; Stand in for what a disguise mod (e.g. Master of Disguise) already does while the player wears a disguise
        bool wasAlreadyInFaction = player.IsInFaction(disguiseFaction)
        if (!wasAlreadyInFaction)
            player.AddToFaction(disguiseFaction)
        endif
        float originalAggression = player.GetActorValue("Aggression")

        RPB_Utility.SetHostilityRestoreOverrideHours(0.05) ; a few real seconds at the default time scale, not a real 24 game-hour wait

        RPB_Prisoner prisonerRef = prison.MakePrisoner(player)
        step = assert_true(prisonerRef != none, "Could not make the player a prisoner")
        ok = ok && step
        if (!prisonerRef)
            self.__CleanupHostilePlayerTest(player, disguiseFaction, wasAlreadyInFaction, originalAggression)
            display_result(false)
            return
        endif

        ; Left true (not reset to false): HasStateRequiredForImprisonment needs Sentence || Bounty || IsUndeterminedSentence,
        ; and SetSentence() itself never sets a numeric Sentence while IsUndeterminedSentence is true (it just logs and
        ; returns) - that flag staying true IS how an undetermined sentence satisfies the precondition. SendReleaseRequest
        ; (used below) doesn't check sentence-served status, so a real Sentence value was never actually needed here.
        prisonerRef.IsUndeterminedSentence = true
        prisonerRef.HideBounty()
        prisonerRef.SetSentence()
        prisonerRef.AssignCell()
        prisonerRef.MoveToCell()

        prisonerRef.Imprison()
        step = assert_true(prisonerRef.IsImprisoned, "The player was not imprisoned (HasStateRequiredForImprisonment likely false)")
        ok = ok && step
        if (!prisonerRef.IsImprisoned)
            self.__CleanupHostilePlayerTest(player, disguiseFaction, wasAlreadyInFaction, originalAggression)
            display_result(false)
            return
        endif

        step = assert_true(!player.IsInFaction(disguiseFaction), "The player's disguise faction was not removed while imprisoned")
        ok = ok && step
        log("HOSTILE PLAYER while imprisoned: still in faction " + player.IsInFaction(disguiseFaction) + ", Aggression now " + player.GetActorValue("Aggression"))

        prison.SendReleaseRequest(prisonerRef)
        int releasedMs = self.__StressWaitReleased(player, prison, 30.0)
        step = assert_true(releasedMs >= 0, "The player was not released")
        ok = ok && step

        step = assert_true(!player.IsInFaction(disguiseFaction), "The player's disguise faction came back immediately on release (should stay neutral for a while)")
        ok = ok && step

        float waitStart = Utility.GetCurrentRealTime()
        while (prison.PendingHostilityRestoreCount() > 0 && (Utility.GetCurrentRealTime() - waitStart) < 30.0)
            Utility.Wait(0.5)
        endWhile

        bool restored = player.IsInFaction(disguiseFaction)
        step = assert_true(restored, "The player's disguise faction was not restored after the delay")
        ok = ok && step
        log("HOSTILE PLAYER restored: in faction " + restored + ", Aggression now " + player.GetActorValue("Aggression") + ", still queued " + prison.PendingHostilityRestoreCount())

        self.__CleanupHostilePlayerTest(player, disguiseFaction, wasAlreadyInFaction, originalAggression)
        display_result(ok)
    endFunction

    function Teardown()
        RPB_Utility.SetHostilityRestoreOverrideHours(0.0)
    endFunction
endState

; However the test above ends (pass, fail, or an early return), the dev's own player must not stay faction-flagged/Aggression-changed.
function __CleanupHostilePlayerTest(Actor akPlayer, Faction akDisguiseFaction, bool abWasAlreadyInFaction, float afOriginalAggression)
    if (!abWasAlreadyInFaction)
        akPlayer.RemoveFromFaction(akDisguiseFaction)
    endif
    akPlayer.SetActorValue("Aggression", afOriginalAggression)
endFunction

;/
    Finds the source of the console warning "access to non-existing object with id 0x64": it prints a marker to the in-game console
    before each read the mass tests do at their start, so the warning shows right after the marker of the read that causes it.
    Open the console before running it and note which PROBE line the warning follows.
/;
state Test_ConsoleProbe
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_PrisonManager probeManager = RPB_API.GetPrisonManager()
        Actor player = Game.GetFormEx(0x14) as Actor
        int n = 0

        MiscUtil.PrintConsole("PROBE 1: prison.Prisoners.Count")
        n = prison.Prisoners.Count
        MiscUtil.PrintConsole("PROBE 2: PrisonManager.PrisonsWithPrisonersCount")
        n = probeManager.PrisonsWithPrisonersCount
        MiscUtil.PrintConsole("PROBE 3: prison.JailCells")
        Form[] cells = prison.JailCells

        int i = 0
        while (cells && i < cells.Length)
            RPB_JailCell jailCell = cells[i] as RPB_JailCell
            if (jailCell)
                MiscUtil.PrintConsole("PROBE 4: " + jailCell.ID + " MaxPrisoners")
                n = jailCell.MaxPrisoners
                MiscUtil.PrintConsole("PROBE 5: " + jailCell.ID + " PrisonerCount")
                n = jailCell.PrisonerCount
                MiscUtil.PrintConsole("PROBE 6: " + jailCell.ID + " AllowOvercrowding")
                bool allow = jailCell.AllowOvercrowding
                MiscUtil.PrintConsole("PROBE 7: " + jailCell.ID + " IsGenderExclusive / IsFull")
                allow = jailCell.IsGenderExclusive || jailCell.IsFull
            endif
            i += 1
        endWhile

        MiscUtil.PrintConsole("PROBE 8: PrisonManager.GetCellPackageCapacity(S), step by step")
        probeManager.DebugProbeCapacity("S")
        MiscUtil.PrintConsole("PROBE 9: RPB_Utility.IsOvercrowdingDisabled")
        bool disabled = RPB_Utility.IsOvercrowdingDisabled()
        MiscUtil.PrintConsole("PROBE 10: RPB_Utility.SetOvercrowdingDisabled true then false")
        RPB_Utility.SetOvercrowdingDisabled(true)
        RPB_Utility.SetOvercrowdingDisabled(false)
        MiscUtil.PrintConsole("PROBE 11: RPB_Utility.GetNearestGuard")
        Actor guard = RPB_Utility.GetNearestGuard(player, 3000.0, player)
        MiscUtil.PrintConsole("PROBE 12: crumbs on/off (StressProfilerOff / Restore)")
        self.__StressProfilerOff()
        self.__StressProfilerRestore()
        MiscUtil.PrintConsole("PROBE END")

        log("PROBE done: see the console for the marker the warning follows")
        display_result(true)
    endFunction

    function Teardown()
        RPB_Utility.SetOvercrowdingDisabled(false)
    endFunction
endState

;/
    The time skip with a crowded prison: 40 NPC prisoners with sentences of 1 to 10 days (base 0x132AE, registered without
    the arrest flow, so the cell capacity does not apply) and ReleaseDueNPCsInOrder() as a dry run, which passes ~10 game
    days with all of them running their hourly and daily updates. Every prisoner must be recorded once, in order of
    release time, each at about the end of its own sentence, and the whole thing must finish (bounded, reported in ms).
    NOTE: this really advances the game clock by ~10 days.
/;
state Test_TimeSkipManyPrisoners
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        RPB_PrisonMonitor mon = prison.Monitor
        bool ok = true
        bool step = false

        int TOTAL = 40
        Actor[] all = new Actor[64]
        int[] sentence = new int[64]
        float start = Utility.GetCurrentGameTime()
        int registered = 0
        int i = 0
        while (i < TOTAL)
            Actor a = __SpawnTempActorOf(0x132AE)
            RPB_Prisoner p = none
            if (a)
                p = __RegisterPrisonerAndWait(a, prison)
            endif
            if (p)
                all[registered] = a
                sentence[registered] = (i % 10) + 1
                p.SetInt("Sentence", sentence[registered])
                p.SetFloat("Time of Imprisonment", start)
                registered += 1
            endif
            i += 1
        endWhile
        log("TIMESKIP registered " + registered + " of " + TOTAL + " prisoners")
        step = assert_true(registered == TOTAL, "Only " + registered + " of " + TOTAL + " prisoners could be registered")
        ok = ok && step

        mon.DebugDryRunReleases = true
        mon.ClearDryRunReleaseOrder()
        float t0 = Utility.GetCurrentRealTime()
        int passed = prison.ReleaseDueNPCsInOrder(11.0)
        int ms = self.__Ms(Utility.GetCurrentRealTime() - t0)
        Form[] order = mon.GetDryRunReleaseOrder()
        mon.DebugDryRunReleases = false
        log("TIMESKIP passed " + passed + " days with " + registered + " prisoners in " + ms + " ms real time, " + order.Length + " releases recorded")

        step = assert_true(order.Length == registered, "Expected " + registered + " releases, saw " + order.Length)
        ok = ok && step
        step = assert_true(ms < 300000, "The time skip took " + ms + " ms")
        ok = ok && step

        ; each at about the end of its own sentence, in non-decreasing order of release time
        float previous = -1.0
        int outOfOrder = 0
        int wrongTime = 0
        i = 0
        while (i < registered)
            float releasedAt = mon.GetDryRunReleaseTime(all[i])
            float expectedDays = sentence[i] as float
            if (releasedAt < 0.0 || (releasedAt - start) < expectedDays - 0.01 || (releasedAt - start) > expectedDays + 1.5)
                wrongTime += 1
            endif
            i += 1
        endWhile
        i = 0
        while (i < order.Length)
            float t = mon.GetDryRunReleaseTime(order[i] as Actor)
            if (t + 0.0001 < previous)
                outOfOrder += 1
            endif
            previous = t
            i += 1
        endWhile
        step = assert_true(outOfOrder == 0, outOfOrder + " releases were recorded out of order of release time")
        ok = ok && step
        step = assert_true(wrongTime == 0, wrongTime + " prisoners were released at a time that is not the end of their sentence")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        prison.Monitor.DebugDryRunReleases = false
        __TeardownAllTempActors()
    endFunction
endState

;/
    A failed imprisonment ("Assign Cell") used to unregister the prisoner without Destroy(), leaving its
    "Initialized" state behind: a later re-arrest of the same NPC then could not register (OnInitialize
    returns early on a stale flag) or would have kept the previous sentence and release location. Calls the
    fail event directly on a registered, initialized temp prisoner and checks the cleanup, including that the
    same actor can be registered again straight afterwards.
/;
state Test_Prison_ImprisonmentFailCleansUp
    function Setup()
        RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
        bool ok = true
        bool step = false

        Actor a = __SpawnTempActor()
        RPB_Prisoner p = prison.AwaitPrisonerReference(a)
        step = assert_true(p != none, "Could not register the prisoner used for this test")
        ok = ok && step
        if (!p)
            display_result(false)
            return
        endif
        step = assert_true(RPB_StorageVars.GetBoolOnReference("Initialized", a, "Jail"), "Precondition: the prisoner should be initialized (flag set)")
        ok = ok && step

        prison.OnPrisonerImprisonmentFail(p, "Assign Cell")
        Utility.Wait(1.5)

        step = assert_true(prison.Prisoners.AtKey(a) == none, "The prisoner is still in the list after a failed imprisonment")
        ok = ok && step
        step = assert_false(RPB_StorageVars.GetBoolOnReference("Initialized", a, "Jail"), "The 'Initialized' flag survived a failed imprisonment (stale state)")
        ok = ok && step
        step = assert_false(a.HasSpell(RPB_Utility.RPB_PrisonerSpell()), "The prisoner spell is still on the actor")
        ok = ok && step

        ; The same actor must be able to become a prisoner again
        RPB_Prisoner again = prison.AwaitPrisonerReference(a)
        step = assert_true(again != none, "The same actor could not be registered again after the failed imprisonment")
        ok = ok && step

        display_result(ok)
    endFunction

    function Teardown()
        __TeardownAllTempActors()
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

        __LogRuntimeState("test 22 start")

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
        ; BREADCRUMBS: this test has been seen to neither pass nor fail (silently stops). Each
        ; step logs where it is and how long the await took, so the last "T23" line in the
        ; log shows exactly where it stopped. A None result from an await is checked before use
        ; instead of letting a later call on it raise a runtime error that aborts the test.
        log("T23 start, Prisoners.Count at start = " + solitudePrison.Prisoners.Count)
        __LogRuntimeState("test 23 start")

        Actor tempA = __SpawnTempActor()
        log("T23 spawned A " + tempA)
        float benchA = StartBenchmark()
        RPB_Prisoner prisonerA = solitudePrison.AwaitPrisonerReference(tempA)
        log("T23 await A returned " + prisonerA + " after " + EndBenchmark(benchA, "T23 await A") + "ms")
        Utility.Wait(1.0)

        Actor tempB = __SpawnTempActor()
        log("T23 spawned B " + tempB)
        float benchB = StartBenchmark()
        RPB_Prisoner prisonerB = solitudePrison.AwaitPrisonerReference(tempB)
        log("T23 await B returned " + prisonerB + " after " + EndBenchmark(benchB, "T23 await B") + "ms")
        Utility.Wait(1.0)

        Actor tempC = __SpawnTempActor()
        log("T23 spawned C " + tempC)
        float benchC = StartBenchmark()
        RPB_Prisoner prisonerC = solitudePrison.AwaitPrisonerReference(tempC)
        log("T23 await C returned " + prisonerC + " after " + EndBenchmark(benchC, "T23 await C") + "ms")

        log("T23 all awaits done, Prisoners.Count = " + solitudePrison.Prisoners.Count)
        bool countCorrect = assert_true(solitudePrison.Prisoners.Count == 3, "Expected Prisoners.Count == 3, got " + solitudePrison.Prisoners.Count)

        string[] keys = solitudePrison.Prisoners.GetKeys()
        log("T23 GetKeys() returned " + keys.Length + " key(s)")
        bool hasA = __KeysContain(keys, "Prisoner["+ tempA.GetFormID() +"]")
        bool hasB = __KeysContain(keys, "Prisoner["+ tempB.GetFormID() +"]")
        bool hasC = __KeysContain(keys, "Prisoner["+ tempC.GetFormID() +"]")
        log("T23 key checks: A=" + hasA + " B=" + hasB + " C=" + hasC)

        bool allKeysFound = assert_true(hasA && hasB && hasC, "GetKeys() is missing one or more expected keys. Got: " + keys)

        log("T23 about to report result")
        display_result(countCorrect && allKeysFound)
        log("T23 result reported, Teardown follows")
    endFunction

    function Teardown()
        log("T23 Teardown start")
        __TeardownAllTempActors()
        log("T23 Teardown done")
    endFunction
endState

state Test_ActorList_Remove_And_Reindex
    function Setup()
        RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        ; BREADCRUMBS: this test has been seen to stop silently inside the first await after other
        ; tests ran; the last "T24" line shows where, and the STATE/PROBE lines show what was around
        log("T24 start")
        __LogRuntimeState("test 24 start")

        Actor tempA = __SpawnTempActor()
        log("T24 spawned A " + tempA + ", awaiting")
        float benchA = StartBenchmark()
        RPB_Prisoner prisonerA = solitudePrison.AwaitPrisonerReference(tempA)
        log("T24 await A returned " + prisonerA + " after " + EndBenchmark(benchA, "T24 await A") + "ms")
        log("After adding A: Count=" + solitudePrison.Prisoners.Count + ", Keys=" + solitudePrison.Prisoners.GetKeys())
        Utility.Wait(1.0)

        Actor tempB = __SpawnTempActor()
        log("T24 spawned B " + tempB + ", awaiting")
        float benchB = StartBenchmark()
        RPB_Prisoner prisonerB = solitudePrison.AwaitPrisonerReference(tempB)
        log("T24 await B returned " + prisonerB + " after " + EndBenchmark(benchB, "T24 await B") + "ms")
        log("After adding B: Count=" + solitudePrison.Prisoners.Count + ", Keys=" + solitudePrison.Prisoners.GetKeys())
        Utility.Wait(1.0)

        Actor tempC = __SpawnTempActor()
        log("T24 spawned C " + tempC + ", awaiting")
        float benchC = StartBenchmark()
        RPB_Prisoner prisonerC = solitudePrison.AwaitPrisonerReference(tempC)
        log("T24 await C returned " + prisonerC + " after " + EndBenchmark(benchC, "T24 await C") + "ms")
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
        bool syncedAfterChurn = self.__AssertContainerInSync(_container, "after interleaved add/remove")

        ; Clean up
        _container.RemoveElement("DensePackTest_A", dispel = false)
        _container.RemoveElement("DensePackTest_C", dispel = false)
        _container.RemoveElement("DensePackTest_E", dispel = false)
        _container.RemoveElement("DensePackTest_F", dispel = false)
        _container.RemoveElement("DensePackTest_G", dispel = false)
        _container.RemoveElement("DensePackTest_H", dispel = false)

        bool cleanedUp = assert_true(_container.Count == startCount, "Container did not return to its original Count after cleanup, got " + _container.Count)

        bool syncedAfterCleanup = self.__AssertContainerInSync(_container, "after cleanup")

        display_result(countCorrect && allSurvivorsPresent && removedStaysGone && syncedAfterChurn && cleanedUp && syncedAfterCleanup)
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
    can clean it up afterward. Up to 32 per test (between teardowns).
/;
Actor function __SpawnTempActor()
    return self.__SpawnTempActorOf(0x132A1)
endFunction

;/ Same, from any ActorBase (mass tests use 0x132AE, an NPC that behaves), up to 64 per test. Returns none when it cannot be placed. /;
Actor function __SpawnTempActorOf(int aiBaseFormId)
    if (!__testTempActors)
        __testTempActors = new Actor[64]
    endif

    ActorBase npcBase = Game.GetFormEx(aiBaseFormId) as ActorBase
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
    if (!temp)
        log("TEMP ACTOR COULD NOT BE PLACED from base " + aiBaseFormId)
        return none
    endif

    __testTempActors[__testTempActorCount] = temp
    __testTempActorCount += 1

    ; This base has an AI package that walks the NPC off to Castle Dour, where its 3D unloads (and an
    ; unloaded actor can't get its spell effect started). Freeze it in place: it is only a test dummy.
    temp.EnableAI(false)

    ; A temp actor whose 3D never loads can't get its spell effect started, so nothing registers and the
    ; test would sit in an await (this was the 23/24/48 "hang"). Give it a bounded time to load and say so
    ; loudly at the START of the test, together with where the player is, instead of stalling later.
    float loadWaited = 0.0
    while (!temp.Is3DLoaded() && loadWaited < 5.0)
        Utility.Wait(0.1)
        loadWaited += 0.1
    endWhile
    if (!temp.Is3DLoaded())
        log("TEMP ACTOR NOT LOADED after 5s: " + temp + " | its cell " + temp.GetParentCell() + " | player's cell " + (Game.GetFormEx(0x14) as Actor).GetParentCell() + " - registrations in this test will not work here; reload a save / move somewhere the cell loads")
    endif

    ; __LogTempActorProbe(temp)

    return temp
endFunction

; ----------------------------------------------------------
;   Diagnostics for the 23/24 hangs (tests that stop somewhere in AwaitPrisonerReference after
;   other tests have run, and pass again after reloading an earlier save). They only LOG: what
;   the lists and their thread locks look like, and whether a freshly spawned temp actor - whose
;   FormID is recycled from an earlier, deleted one - arrives with leftovers. The last STATE/PROBE
;   lines before a hang say which of "a list isn't empty", "a lock was left held" or "the actor
;   already had state" applies, or that none do (then it's the engine's spell/effect queue).
; ----------------------------------------------------------

;/ "name count N lock free|HELD" for one container. The lock word is read without taking the lock. /;
string function __ContainerStateString(string asName, RPB_ActiveMagicEffectContainer apContainer)
    string lockState = "free"
    if (JMap.getInt(apContainer.DebugGetThreadLockHandle(), "locked") != 0)
        lockState = "HELD"
    endif

    return asName + " " + apContainer.Count + " (lock " + lockState + ")"
endFunction

function __LogRuntimeState(string asLabel)
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
    RPB_Arrest arrest = RPB_API.GetArrest()

    log("STATE [" + asLabel + "] t=" + (Utility.GetCurrentRealTime() as int) + "s | " + \
        __ContainerStateString("tracked", RPB_API.GetActorListForTrackedActors() as RPB_ActiveMagicEffectContainer) + " | " + \
        __ContainerStateString("arrestees", arrest.Arrestees as RPB_ActiveMagicEffectContainer) + " | " + \
        __ContainerStateString("captors", arrest.Captors as RPB_ActiveMagicEffectContainer) + " | " + \
        __ContainerStateString("haafingar prisoners", solitudePrison.Prisoners as RPB_ActiveMagicEffectContainer))
endFunction

;/ Does this freshly spawned temp actor already carry state from an earlier, deleted actor with the same FormID? /;
function __LogTempActorProbe(Actor akTemp)
    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
    RPB_Arrest arrest = RPB_API.GetArrest()

    ; The flags that matter for registration: RPB_Prisoner.OnInitialize() returns BEFORE registering when
    ; Was("Initialized") is true (category "Jail" for prisoners, "Arrest" for arrestees, "Captor" for captors),
    ; and it is keyed by the reference string, so it survives a deleted temp actor and hits the next one that
    ; gets the same FormID. ("Is Initialized" in category "Actor" is a different flag, set at the end of OnEffectStart.)
    bool initJail = RPB_StorageVars.GetBoolOnReference("Initialized", akTemp, "Jail")
    bool initArrest = RPB_StorageVars.GetBoolOnReference("Initialized", akTemp, "Arrest")
    bool initCaptor = RPB_StorageVars.GetBoolOnReference("Initialized", akTemp, "Captor")
    bool isInitActor = RPB_StorageVars.GetBoolOnReference("Is Initialized", akTemp, "Actor")
    bool hasSpell = akTemp.HasSpell(RPB_Utility.RPB_PrisonerSpell()) || akTemp.HasSpell(RPB_Utility.RPB_ArresteeSpell()) || akTemp.HasSpell(RPB_Utility.RPB_CaptorSpell())
    bool inList = solitudePrison.Prisoners.AtKey(akTemp) != none || arrest.Arrestees.AtKey(akTemp) != none || arrest.Captors.AtKey(akTemp) != none || RPB_API.GetActorListForTrackedActors().AtKeyEx(akTemp) != none

    bool clean = akTemp.Is3DLoaded() && !initJail && !initArrest && !initCaptor && !hasSpell && !inList
    if (clean)
        log("PROBE clean " + akTemp + " (3D loaded, no leftover state" + self.__StringIf(isInitActor, ", 'Is Initialized' TRUE (harmless)") + ")")
    else
        log("PROBE UNUSUAL " + akTemp + " | 3D loaded " + akTemp.Is3DLoaded() + ", cell " + akTemp.GetParentCell() + \
            " | STALE 'Initialized': Jail " + initJail + ", Arrest " + initArrest + ", Captor " + initCaptor + " ('Is Initialized' " + isInitActor + ")" + \
            " | spells: prisoner " + akTemp.HasSpell(RPB_Utility.RPB_PrisonerSpell()) + ", arrestee " + akTemp.HasSpell(RPB_Utility.RPB_ArresteeSpell()) + ", captor " + akTemp.HasSpell(RPB_Utility.RPB_CaptorSpell()) + \
            " | already in a list: prisoners " + (solitudePrison.Prisoners.AtKey(akTemp) != none) + ", arrestees " + (arrest.Arrestees.AtKey(akTemp) != none) + ", captors " + (arrest.Captors.AtKey(akTemp) != none) + ", tracked " + (RPB_API.GetActorListForTrackedActors().AtKeyEx(akTemp) != none))
    endif
endFunction

;/
    Fully unregisters every temp actor spawned this test from all three lists
    (Prisoner/Arrestee/Captor - a temp actor may only be in one, this just checks all
    three so a single helper works for every test above) and disables+deletes it, then
    resets tracking. Call from every test's Teardown() that used __SpawnTempActor().
/;
function __TeardownAllTempActors()
    if (!__testTempActors)
        return ; nothing tracked (already torn down)
    endif

    RPB_Prison solitudePrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")
    RPB_Arrest arrest = RPB_API.GetArrest()

    ; Pass 1: unregister, and take the spells off so the effects finish
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

            tempActor.RemoveSpell(RPB_Utility.RPB_PrisonerSpell())
            tempActor.RemoveSpell(RPB_Utility.RPB_ArresteeSpell())
            tempActor.RemoveSpell(RPB_Utility.RPB_CaptorSpell())
        endif

        i += 1
    endWhile

    if (__testTempActorCount > 0)
        ; Let the effects' finish/destroy handlers run before wiping (they can write state themselves)
        Utility.Wait(0.5)
    endif

    ; Pass 2: wipe every StorageVars category for the temp actor and delete it. UnregisterPrisoner() alone
    ; never called Destroy(), so an initialized prisoner's "Initialized" flag survived the deleted actor and
    ; blocked registration of the next temp actor with the same (recycled) FormID - the 23/24/47/48 "hangs".
    i = 0
    while (i < __testTempActorCount)
        Actor tempActor2 = __testTempActors[i]

        if (tempActor2)
            RPB_StorageVars.DeleteAllOnReference(tempActor2)
            tempActor2.Disable()
            tempActor2.Delete()
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