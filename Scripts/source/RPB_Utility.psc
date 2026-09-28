scriptname RPB_Utility hidden

;/
@functions:
    string function ModName() global
    string function PluginName() global
    Form function GetFormFromMod(int formId) global
    GlobalVariable function RPB_ArrestGlobal(string asGlobal) global
    Quest function GetCellPackageGroup(string questPackageID) global
    RPB_PackageGroup function GetCellPackageGroupEx(string questPackageID) global
    WICourierScript function GetCourierQuest() global
    Message function ServeTimeMessage() global
    Spell function RPB_ActorSpell() global
    Spell function RPB_ArresteeSpell() global
    Spell function RPB_PrisonerSpell() global
    Spell function RPB_CaptorSpell() global
    Idle function BoundHandsBehindBack() global
    Armor function RPB_PrisonerHandCuffs() global
    Outfit function RPB_GetOutfit(string asOutfit) global
    bool function HealNakedBaseOutfit(Actor akActor) global
    Actor function GetOtherCombatTarget(Actor akActor, Actor akExcept) global
    int function RemoveCuffs(Actor akActor) global
    Form[] function RPB_GetHostileFactions() global
    Form[] function RPB_GetHostileFactionsFor(Actor akActor) global
    bool function IsHostileActor(Actor akActor) global
    function NeutralizeHostileActor(Actor akActor) global
    float function PACIFICATION_TIME_BUDGET_SECONDS() global
    function SustainArrestPacification(Actor akArrestee, Actor akCaptor) global
    bool function MaintainArrestPacification(Actor akArrestee, Actor akCaptor) global
    bool function IsTracingEnabled() global
    bool function IsDebuggingEnabled() global
    bool function IsLoggingEnabled() global
    function EnableDebugging() global
    function DisableDebugging() global
    function EnableLogging() global
    function DisableLogging() global
    function SetLoggingEnabled(string asLogType, bool abEnabled) global
    function base_log(string asLogType = "DEBUG", string asLogInfo, string asCaller = "", string asCallerArgs = "") global
    function Trace(string asCaller, string asLogInfo, bool abCondition = true) global
    function Debug(string asCaller, string asLogInfo, bool abCondition = true) global
    function NotImplemented(string asCaller, bool abCondition = true) global
    function FunctionNotImplemented(string asCaller, bool abCondition = true) global
    function EventNotImplemented(string asCaller, bool abCondition = true) global
    function DebugInfo(string asCaller, string asLogInfo, bool abCondition = true) global
    function DebugWarn(string asCaller, string asLogInfo, bool abCondition = true) global
    function DebugError(string asCaller, string asLogInfo, bool abCondition = true) global
    function DebugWithArgs(string asCaller, string asArgs, string asLogInfo, bool abCondition = true) global
    function DebugParams(string params, string paramNames = "", string caller = "", bool condition = true) global
    function LogNoType(string asLogInfo, string asCaller = "", bool abCondition = true) global
    function LogException(string asExceptionType, string asExceptionMessage, string asCaller = "", bool abCondition = true) global
    function Info(string asLogInfo, bool abCondition = true) global
    function Warn(string asLogInfo, bool abCondition = true) global
    function Error(string asLogInfo, bool abCondition = true) global
    function Fatal(string asLogInfo, bool abCondition = true) global
    function LogProperty(string prop, string asLogInfo, bool condition = true) global
    function ErrorProperty(string asProperty, string asLogInfo, bool condition = true) global
    float function Max(float a, float b) global
    float function Min(float a, float b) global
    int function Round(float value) global
    int function ClampInt(int value, int min, int max) global
    float function ClampFloat(float value, float min, float max) global
    float function PercentToDecimal(float percentToConvert) global
    float function float_if(bool condition, float afTrue, float afFalse = 0.0) global
    int function int_if(bool condition, int aiTrue, int aiFalse = 0) global
    bool function bool_if(bool condition, bool abTrue, bool abFalse = false) global
    string function string_if(bool condition, string asTrue, string asFalse = "") global
    Form function form_if(bool condition, Form akTrue, Form akFalse = none) global
    ActiveMagicEffect function ame_if (bool condition, ActiveMagicEffect apTrue, ActiveMagicEffect apFalse) global
    string function GetFormattedAsParams(string values, string keys = "", string keyPrefixes = "", string keySuffixes = "", string valuePrefixes = "", string valueSuffixes = "") global
    bool function String_StartsWith(string str, string needle) global
    bool function String_EndsWith(string str, string needle) global
    bool function String_StartsEndsWith(string str, string startChar, string endChar) global
    bool function String_Contains(string str, string needle) global
    string function String_Implode(string[] akStrArray, string asDelimiter = ",") global
    string[] function String_Explode(string asStr, string asDelimiter = ",") global
    string function ReplaceString(string str, string toFind, string replacement) global
    string[] function StringArray_Merge(string[] asArrayOne, string[] asArrayTwo) global
    string function Replace(string asTemplate, string[] akPlaceholders, string[] akReplacements) global
    function Array_ClearForms(Form[] akArray) global
    string function OR(int[] elements) global
    string function XOR(int[] elements) global
    string function AND(int[] elements) global
    int function BitwiseExpr(string bitfield) global
    function RetainAI(bool condition = true) global
    function ReleaseAI(bool condition = true) global
    function SetGameStat(string asStatName, int aiValue) global
    bool function IsActorArrested(Actor akActor) global
    bool function IsActorImprisoned(Actor akActor) global
    bool function IsPlayerArrested() global
    bool function IsPlayerImprisoned() global
    Faction function GetCrimeFactionByHold(string asHold) global
    bool function WasPlayerLastJailedInHold(Faction akCrimeFaction) global
    int function GetPlayerPrisonLastJailedTime(string asTimeType, Faction akCrimeFaction) global
    int function GetPlayerPrisonLastReleasedTime(string asTimeType, Faction akCrimeFaction) global
    int function GetPlayerPrisonLastEscapedTime(string asTimeType, Faction akCrimeFaction) global
    function UnequipHandsForActor(Actor akActor) global
    function UnequipWeaponForActor(Actor akActor, bool abLeftHand = false, bool abPreventEquip = false, bool abSilentUnequip = true) global
    function UnequipShieldForActor(Actor akActor, bool abPreventEquip = false, bool abSilentUnequip = true) global
    function UnequipSpellForActor(Actor akActor) global
    function UnequipShoutForActor(Actor akActor) global
    bool function ActorHasClothing(Actor akActor) global
    bool function IsActorMale(Actor akActor) global
    bool function IsActorFemale(Actor akActor) global
    bool function IsActorOfGender(Actor akActor, string asGender) global
    bool function HasActorsOfGenderInList(Form[] akActors, string asGender, bool abStrictlyMatchGender = false) global
    bool function HasMalesInList(Form[] akActors, bool abStrictlyMales = false) global
    bool function HasFemalesInList(Form[] akActors, bool abStrictlyFemales = false) global
    Form[] function GetActorsOfGenderInList(Form[] akActors, string asGender) global
    Form[] function GetMalesInList(Form[] akActors) global
    Form[] function GetFemalesInList(Form[] akActors) global
    RPB_ActorBase function AwaitEntityReference( Actor akEntity, RPB_ActorList apEntityList, RPB_Entity apEntity = none, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1 ) global
    RPB_ActorBase function AwaitExistingEntityReference( Actor akEntity, RPB_ActorList apEntityList, RPB_Entity apEntity = none, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1 ) global
    function EnsureArresteeSpellAndBinding(Actor akArrestee, RPB_Hold apHold) global
    function EnsurePrisonerSpellAndBinding(Actor akPrisoner, RPB_Prison apPrison) global
    function EnsureCaptorSpellAndBinding(Actor akCaptor) global
    Form[] function ActorToFormArray(Actor[] akActors) global
    function AddIntIfNotNone(int aiElement, int arr) global
    function AddFormIfNotNone(Form akForm, int arr) global
    int[] function IntList( int aiElement1, int aiElement2 = 0, int aiElement3 = 0, int aiElement4 = 0, int aiElement5 = 0, int aiElement6 = 0, int aiElement7 = 0, int aiElement8 = 0, int aiElement9 = 0, int aiElement10 = 0, int aiElement11 = 0, int aiElement12 = 0, int aiElement13 = 0, int aiElement14 = 0, int aiElement15 = 0, int aiElement16 = 0, int aiElement17 = 0, int aiElement18 = 0, int aiElement19 = 0, int aiElement20 = 0 ) global
    Form[] function BuildParamsObjectReference( ObjectReference akRef1, ObjectReference akRef2 = none, ObjectReference akRef3 = none, ObjectReference akRef4 = none, ObjectReference akRef5 = none, ObjectReference akRef6 = none, ObjectReference akRef7 = none, ObjectReference akRef8 = none, ObjectReference akRef9 = none, ObjectReference akRef10 = none, ObjectReference akRef11 = none, ObjectReference akRef12 = none, ObjectReference akRef13 = none, ObjectReference akRef14 = none, ObjectReference akRef15 = none, ObjectReference akRef16 = none, ObjectReference akRef17 = none, ObjectReference akRef18 = none, ObjectReference akRef19 = none, ObjectReference akRef20 = none ) global
    Form[] function BuildParamsActor( Actor akRef1, Actor akRef2 = none, Actor akRef3 = none, Actor akRef4 = none, Actor akRef5 = none, Actor akRef6 = none, Actor akRef7 = none, Actor akRef8 = none, Actor akRef9 = none, Actor akRef10 = none, Actor akRef11 = none, Actor akRef12 = none, Actor akRef13 = none, Actor akRef14 = none, Actor akRef15 = none, Actor akRef16 = none, Actor akRef17 = none, Actor akRef18 = none, Actor akRef19 = none, Actor akRef20 = none ) global
    function BindAliasTo(ReferenceAlias akAlias, ObjectReference akObjectReference) global
    function UnbindAlias(ReferenceAlias akAlias) global
    float function GetInfinityDistance() global
    float function UnitsToCM(int unit)
    float function UnitsToM(int unit)
    function OrientRelative(ObjectReference akObjA, ObjectReference akObjB, Float afRotX = 0.0, Float afRotY = 0.0, Float afRotZ = 0.0) Global
    bool function IsFarAwayFromObject(ObjectReference akObjectOne, ObjectReference akObjectTwo) global
    bool function IsWedgedTogether(Actor akActorOne, Actor akActorTwo, float afStuckDistance = 90.0) global
    function PushActorAwayFrom(Actor akActorToMove, Actor akAnchor, float afDistance) global
    bool function IsActorFarAwayFromPlayer(Actor akActor) global
    string function GenerateUUIDSection(int aiLength) global
    string function GenerateUUID() global
    int[] function Pair(int n1, int n2) global
    Form function GetFormFromString(string asFormIdentifier) global
    string function ExtractReferenceType(string asReference) global
    string function ExtractReferenceID(string asReference) global
    int function ParseInt(string asNumber) global
    int function ParseBinary(string asBin) global
    int function HexStringToInt(string asHexString) global
    int function BinStringToInt(string asBinString) global
    string function IntToHex(int i) global
    string function GetRandomHex() global
    Form function GetFormOfType(string asFormType) global
    int function GetSlotMask(string bodyPart) global
    bool function IsFlowProfilingEnabled() global
    function EnableFlowProfiling() global
    function DisableFlowProfiling() global
    bool function IsCrumbsEnabled() global
    function EnableCrumbs() global
    function DisableCrumbs() global
    function Crumb(Actor akActor, string asStage) global
    function ClearCrumbs(Actor akActor) global
    string function DumpCrumbs(Actor akActor) global
    int function GetMaxDayEventsPerUpdate() global
    function SetMaxDayEventsPerUpdate(int aiDays) global
    bool function IsOvercrowdingDisabled() global
    function SetOvercrowdingDisabled(bool abDisabled) global
    bool function IsConfrontationSceneForcedToFail() global
    function SetConfrontationSceneForcedToFail(bool abForced) global
    float function GetMonitorOverrideHours() global
    function SetMonitorOverrideHours(float afHours) global
    float function GetHostilityRestoreOverrideHours() global
    function SetHostilityRestoreOverrideHours(float afHours) global
    function FlowBegin(string asFlow) global
    function FlowEnsure(string asFlow) global
    function FlowMark(string asPhase) global
    function FlowEnd(string asPhase = "end") global
    string function GetFormNameCached(Form akForm) global
    int function GetSlotMaskValue(int slotMask) global
    string function YesNo(bool abValue) global
    int function EnsureTrue(bool condition, string messageWhenFalse, int failedConditionList = 0) global
    int function EnsureFalse(bool condition, string messageWhenTrue, int failedConditionList = 0) global
    string[] function GetAllSkillNames(bool abIncludeStatSkills = true, bool abIncludePerkSkills = true) global
    string function GetSkillName(string asSkillInternalReference) global
    string[] function GetAllSkills(bool abIncludeStatSkills = true, bool abIncludePerkSkills = true) global
    string[] function GetStatSkills() global
    string[] function GetPerkSkills() global
    bool function IsStatSkill(string asSkillName) global
    bool function IsPerkSkill(string asSkillName) global
    string function GetRandomSkill(string asSkillType = "Stat") global
    string[] function GetLockLevels() global
    string function GetDateTimeNow() global
    float function now() global
    float function GetCurrentTime() global
    int function GetDaysOfMonth(int aiMonth) global
    int function GetCurrentMinute() global
    int function GetCurrentHour() global
    float function GetCurrentHourFloat() global
    int function GetCurrentDay() global
    int function GetCurrentMonth() global
    int function GetCurrentYear() global
    int function GetDaysPassed() global
    int function GetLastDayOfMonth(int aiMonth) global
    float function GetElapsedTimeBetweenTimes(float afStartTime, float afEndTime) global
    float function GetElapsedTimeSincePointInTime(float afPointInTime) global
    bool function IsLastDayOfMonth() global
    bool function IsLastDayOfYear() global
    bool function SetGameHour(int aiGameHour) global
    bool function ModGameHour(float afIncrementByHours) global
    int function GetMinutesFromHour(float aiHour) global
    string function GetClockFormat(int aiHour, int aiMinutes = 0, string format = "12 Hour") global
    string function GetTimeAs12Hour(int aiHour, int aiMinutes = 0) global
    bool function IsLeapYear(int aiYear) global
    bool function IsWeekend(int aiDay, int aiMonth, int aiYear) global
    bool function IsLoredas(int aiDay, int aiMonth, int aiYear) global
    bool function IsSundas(int aiDay, int aiMonth, int aiYear) global
    bool function IsWeekday(int aiDay, int aiMonth, int aiYear) global
    int function CalculateDaysPassedFromDate(int aiDay, int aiMonth, int aiYear) global
    int function GetDayOfWeekByName(string asDayOfWeekName) global
    string function GetDayOfWeekName(int aiDayOfWeek) global
    string function GetDayOfWeekGregorianName(int aiDayOfWeek) global
    int function GetFirstDayOfWeek(int aiYear) global
    int function CalculateDayOfWeek(int aiDay, int aiMonth, int aiYear) global
    int function GetDateFromDaysPassed(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    string function GetDateFormat(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, string format = "d/m/Y") global
    int function GetPreviousDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    int function GetNextDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    string function GetMonthName(int aiMonth) global
    int function GetMonthByName(string asMonthName) global
    bool function Is28DayMonth(int aiMonth) global
    bool function Is30DayMonth(int aiMonth) global
    bool function Is31DayMonth(int aiMonth) global
    string function ToOrdinalNthDay(int aiDay) global
    string function GetDayOrdinality(int aiDay) global
    string function GetTimeFormatted(float afTime, bool abIncludeMinutes = false, bool abIncludeHours = true, bool abIncludeDays = true, bool abIncludeWeeks = true, bool abIncludeMonths = true, bool abIncludeYears = true, string asNullValue = "") global
    string function GetFormattedDate(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, bool abShowDayOfWeek = true, bool abShowDay = true, bool abShowTime = true, bool abShowYear = true) global
    string function GetFormattedDate24Hours(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0) global
    string function GetCurrentDateFormatted() global
    string function GetNextDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    string function GetPreviousDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    bool function PassTimeInDays(int aiPassByDays) global
    string function FormatFloat(float number) global
    function SendCourierDelivery(ReferenceAlias apItemAlias, Form akItem) global
    function ScheduleCourierDeliveryInGameTime(ReferenceAlias apItemAlias, Form akItem, float afTimeFromNow) global
    int function new_struct(bool abRetain = false, string asStructType = "") global
    bool function GetStructMemberBool(int apStructObject, string asMemberName) global
    int function GetStructMemberInt(int apStructObject, string asMemberName) global
    float function GetStructMemberFloat(int apStructObject, string asMemberName) global
    string function GetStructMemberString(int apStructObject, string asMemberName) global
    Form function GetStructMemberForm(int apStructObject, string asMemberName) global
    function SetStructMemberBool(int apStructObject, string asMemberName, bool value) global
    function SetStructMemberInt(int apStructObject, string asMemberName, int value) global
    function SetStructMemberFloat(int apStructObject, string asMemberName, float value) global
    function SetStructMemberString(int apStructObject, string asMemberName, string value) global
    function SetStructMemberForm(int apStructObject, string asMemberName, Form value) global
    function DestroyStruct(int apStructObject) global
    function DestroyStructsOfType(string asStructType) global
    float function StartBenchmark(bool condition = true) global
    int function EndBenchmark(float startTime, string _message = "", bool condition = true) global
    int function GetJailBaseDoorID(string hold) global
    ObjectReference function GetNearestJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    ObjectReference function GetNearestJailDoorOfTypeEx(Form akJailBaseDoor, ObjectReference akCenterRef, float afRadius) global
    ObjectReference function GetRandomJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    function OpenMultipleDoorsOfType(int jailBaseDoorId, ObjectReference scanFromWhere, float radius) global
    Actor function GetNearestActor(ObjectReference centerRef, float radius) global
    Actor function GetNearestActorFromList(Actor akRef, Form[] akRefs) global
    Actor function GetNearbyActorFromRefWithPrototype(ObjectReference akCenterRef, ActorBase akPrototype, float afMaxRadius = 1000.0) global
    Actor function GetNearbyGuardForFactionFromRef( ObjectReference akCenterRef, Faction akCrimeFaction = none, float afMinRadius = 50.0, float afMaxRadius = 1000.0, float afIncreaseRadiusBy = 100.0, int aiMaxScans = 30 ) global
    Actor function GetNearestGuard(ObjectReference centerRef, float radius, ObjectReference exclude) global
    bool function IsActorNearReference(Actor akActor, ObjectReference akReference, float radius = 80.0) global
    bool function IsWithin(int aiValue, int aiMin, int aiMax, bool abMinInclusive = true, bool abMaxInclusive = true) global
    string function GetContainerList( int _container, string includeStringFilter = "", string excludeStringFilter = "", int includeIntegerFilter = -1, int excludeIntegerFilter = -1, Form includeFormFilter = none, Form excludeFormFilter = none, int indentLevel = 1 ) global
@events:
/;

import Math
import RPB_Memory

string function ModName() global
    return "Realistic Prison and Bounty"
endFunction

string function PluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

Form function GetFormFromMod(int formId) global
    return Game.GetFormFromFile(formId, PluginName())
endFunction

; ==========================================================
;                           Globals
; ==========================================================

GlobalVariable function RPB_ArrestGlobal(string asGlobal) global
    if (asGlobal == "Surrender")
        return GetFormFromMod(0x26A2D) as GlobalVariable

    elseif (asGlobal == "No Dialogue")
        return GetFormFromMod(0x26A2E) as GlobalVariable
    endif

    return none
endFunction

; ==========================================================
;                       Form References
; ==========================================================

Quest function GetCellPackageGroup(string questPackageID) global
    ; return GetFormFromMod(0x1F8CC) as Quest
    string packageID = "RPB_" + questPackageID

    int packages = FastMap("<string>")
    FastMap_SetForm(packages, "RPB_CellPackages_S_01",      GetFormFromMod(0x21916))
    FastMap_SetForm(packages, "RPB_CellPackages_M_01",      GetFormFromMod(0x27A60))
    FastMap_SetForm(packages, "RPB_CellPackages_L_01",      GetFormFromMod(0x2A012))
    FastMap_SetForm(packages, "RPB_CellPackages_XL_01",     GetFormFromMod(0x1F8CC))
    FastMap_SetForm(packages, "RPB_CellPackages_2XL_01",    GetFormFromMod(0x2A013))

    if (!FastMap_HasKey(packages, packageID))
        ; Error, package quest does not exist
        return none
    endif

    return FastMap_GetForm(packages, packageID) as Quest
endFunction

RPB_PackageGroup function GetCellPackageGroupEx(string questPackageID) global
    ; return GetFormFromMod(0x1F8CC) as Quest
    string packageID = "RPB_" + questPackageID

    int packages = FastMap("<string>")
    FastMap_SetForm(packages, "RPB_CellPackages_S_01",      GetFormFromMod(0x21916))
    FastMap_SetForm(packages, "RPB_CellPackages_M_01",      GetFormFromMod(0x27A60))
    FastMap_SetForm(packages, "RPB_CellPackages_L_01",      GetFormFromMod(0x2A012))
    FastMap_SetForm(packages, "RPB_CellPackages_XL_01",     GetFormFromMod(0x1F8CC))
    FastMap_SetForm(packages, "RPB_CellPackages_2XL_01",    GetFormFromMod(0x2A013))

    if (!FastMap_HasKey(packages, packageID))
        ; Error, package quest does not exist
        return none
    endif

    return FastMap_GetForm(packages, packageID) as RPB_PackageGroup
endFunction

WICourierScript function GetCourierQuest() global
    return Game.GetFormEx(0x39F82) as WICourierScript
endFunction

; Quest function GetCellPackageGroup() global
;     ; return GetFormFromMod(0x1F8CC) as Quest
;     return GetFormFromMod(0x21916) as Quest
; endFunction

Message function ServeTimeMessage() global
    return GetFormFromMod(0x1EE08) as Message
endFunction

Spell function RPB_ActorSpell() global
    return GetFormFromMod(0x28523) as Spell
endFunction

Spell function RPB_ArresteeSpell() global
    return GetFormFromMod(0x187B3) as Spell
endFunction

Spell function RPB_PrisonerSpell() global
    return GetFormFromMod(0x197D7) as Spell
endFunction

Spell function RPB_CaptorSpell() global
    return GetFormFromMod(0x2293E) as Spell
endFunction

Idle function BoundHandsBehindBack() global
    return Game.GetFormEx(0xB600A) as Idle
endFunction

Armor function RPB_PrisonerHandCuffs() global
    return GetFormFromMod(0x23969) as Armor
endFunction

Outfit function RPB_GetOutfit(string asOutfit) global
    if (asOutfit == "Naked")
        return GetFormFromMod(0x259D4) as Outfit

    elseif (asOutfit == "Default")
        return GetFormFromMod(0x259D5) as Outfit

    elseif (asOutfit == "Default 2")
        return GetFormFromMod(0x259D6) as Outfit

    elseif (asOutfit == "Default no Shoes")
        return GetFormFromMod(0x259D7) as Outfit

    elseif (asOutfit == "Default 2 no Shoes")
        return GetFormFromMod(0x259D8) as Outfit
    endif
endFunction
;/
    Stripping sets the Outfit of the NPC's base to "Naked", and the base is shared by every NPC of it: if the stripped one
    goes away without its release (deleted, or a release that had nothing saved to restore), every later NPC of that base
    shows up naked. NPC_SaveOriginalOutfit remembers each base's real Outfit ("BaseOutfits"); this puts it back when the
    base is "Naked". True if it did.
/;
bool function HealNakedBaseOutfit(Actor akActor) global
    if (!akActor)
        return false
    endif

    ActorBase npcBase = akActor.GetActorBase()
    if (!npcBase || npcBase.GetOutfit() != RPB_GetOutfit("Naked"))
        return false
    endif

    Outfit remembered = RPB_StorageVars.GetForm("Original Outfit " + npcBase.GetFormID(), "BaseOutfits") as Outfit
    if (!remembered)
        return false
    endif

    akActor.SetOutfit(remembered)
    Debug("Utility::HealNakedBaseOutfit", "The base of " + akActor + " was left Naked, restored " + remembered)
    return true
endFunction

; Someone @akActor is fighting other than @akExcept (alive, enabled), or none. A guard arresting one bandit while another
; one keeps him busy: the arrest can't play its confrontation in that fight.
Actor function GetOtherCombatTarget(Actor akActor, Actor akExcept) global
    if (!akActor)
        return none
    endif

    Actor[] targets = PO3_SKSEFunctions.GetCombatTargets(akActor)
    int i = 0
    while (i < targets.Length)
        Actor target = targets[i]
        if (target && target != akExcept && !target.IsDead() && !target.IsDisabled())
            return target
        endif
        i += 1
    endWhile
    return none
endFunction

;/
    Takes every pair of the cuffs this mod puts on (ZaZ Animation Pack: backside rusty, front rusty, front shiny) off
    @akActor and deletes them - worn or just carried. They're the mod's, never the actor's: stripped into the prison's
    container they came back with the belongings at the release, and an uncuff that only looked at the worn slot left
    them in the inventory (or tried to remove None). Returns how many were removed.
/;
int function RemoveCuffs(Actor akActor) global
    if (!akActor)
        return 0
    endif

    int removed = 0
    int[] cuffIds = new int[3]
    cuffIds[0] = 0x81D2F
    cuffIds[1] = 0x81D33
    cuffIds[2] = 0x81D34

    int i = 0
    while (i < cuffIds.Length)
        Form cuffs = Game.GetFormFromFile(cuffIds[i], "ZaZAnimationPack.esm")
        if (cuffs)
            int count = akActor.GetItemCount(cuffs)
            if (count > 0)
                akActor.UnequipItem(cuffs, false, true)
                akActor.RemoveItem(cuffs, count, true) ; no container: deleted
                removed += count
            endif
        endif
        i += 1
    endWhile
    return removed
endFunction

;/
    The factions Prisoner.IsHostilePrisoner()/NeutralizeWhileImprisoned() check against: an Actor (NPC or the player) belonging
    to one of these is a hostile prisoner (a bandit, a Civil War soldier, Forsworn - or the player disguised via a mod like
    Master of Disguise, which adds the player to its OWN factions while disguised - see RPB_Compat_MasterOfDisguise, unioned
    in below) that guards would otherwise attack in its cell. Resolved by editor ID through PO3 Papyrus Extender (already a
    dependency of this profile) rather than a Creation Kit FormList: no new ESP record, and extending the list later is a
    one-line edit here, not a CK session. An editor ID that fails to resolve (typo, or the load order lacks that record) is
    skipped, not a crash; NeutralizeWhileImprisoned logs how many resolved.
/;
; Verified against the actual load order (zEdit), not recalled: "CWStormcloakFaction" (an earlier guess) does not exist - the
; real editor ID, following the same pattern as CWImperialFaction, is "CWSonsFaction" (in-lore "Sons of Skyrim"). The two
; "...FactionNPC" entries are separate records, explicitly authored "NPC faction (creates hostility to enemy)" - plausibly
; the actual drivers of guard hostility toward a Civil War soldier NPC, more so than the plain membership factions.
string[] function __HostileFactionEditorIDs() global
    string[] ids = new string[6]
    ids[0] = "BanditFaction"
    ids[1] = "CWImperialFaction"
    ids[2] = "CWImperialFactionNPC"
    ids[3] = "CWSonsFaction"
    ids[4] = "CWSonsFactionNPC"
    ids[5] = "ForswornFaction"
    return ids
endFunction

; RPB's own vanilla hostile factions only (not the union) - Form[], not Faction[]: a Papyrus array literal needs a
; compile-time constant size, so trimming to how many editor IDs actually resolved goes through Utility.CreateFormArray
; (the same convention RPB_Prisoner.__TrimForms uses). Callers cast each element.
Form[] function __ResolveVanillaHostileFactions() global
    string[] ids = __HostileFactionEditorIDs()
    Form[] factions = new Form[6] ; must match __HostileFactionEditorIDs()'s count
    int resolved = 0
    int i = 0
    while (i < ids.Length)
        Faction hostileFaction = PO3_SKSEFunctions.GetFormFromEditorID(ids[i]) as Faction
        if (hostileFaction)
            factions[resolved] = hostileFaction
            resolved += 1
        else
            Warn("RPB_GetHostileFactions could not resolve editor ID '" + ids[i] + "' to a Faction (PO3 Papyrus Extender missing, or the load order lacks that record)")
        endif
        i += 1
    endWhile

    if (resolved == ids.Length)
        return factions
    endif
    if (resolved == 0)
        return none
    endif

    Form[] trimmed = Utility.CreateFormArray(resolved)
    i = 0
    while (i < resolved)
        trimmed[i] = factions[i]
        i += 1
    endWhile
    return trimmed
endFunction

int function __AppendFormsToJArray(int aiJArray, Form[] akForms) global
    int added = 0
    if (!akForms)
        return added
    endif

    int i = 0
    while (i < akForms.Length)
        if (akForms[i])
            JArray.addForm(aiJArray, akForms[i])
            added += 1
        endif
        i += 1
    endWhile
    return added
endFunction

Form[] function __FormsFromJArray(int aiJArray) global
    int count = JArray.count(aiJArray)
    if (count == 0)
        return none
    endif

    Form[] forms = Utility.CreateFormArray(count)
    int i = 0
    while (i < count)
        forms[i] = JArray.getForm(aiJArray, i)
        i += 1
    endWhile
    return forms
endFunction

;/
    The union RPB's own vanilla hostile factions and RPB_Compat_MasterOfDisguise's 31 - resolved once and cached via JDB
    thereafter (mirrors RPB_ThreadLock.__GetRegistry()'s "resolve once, read the cached handle after" shape), so later calls
    read the cache instead of re-resolving editor IDs. Rebuilt only when Master of Disguise's installed state changes (it used
    to be cached forever, so installing MoD mid-save was never picked up). The vanilla-only half is cached alongside it, for
    RPB_GetHostileFactionsFor().
/;
Form[] function RPB_GetHostileFactions() global
    __EnsureHostileFactionsCached()
    return __FormsFromJArray(JDB.solveObj(".RPB_HostileFactionsCache"))
endFunction

;/
    The hostile factions worth checking for @akActor: every one for the player, only RPB's vanilla ones for an NPC. Master of
    Disguise only ever puts the PLAYER into its 31 disguise factions, and each membership check is a vanilla native that costs a
    frame - checking all 37 made every arrest ~0.5s slower per check for nothing on an NPC.
/;
Form[] function RPB_GetHostileFactionsFor(Actor akActor) global
    __EnsureHostileFactionsCached()
    if (akActor == Game.GetPlayer())
        return __FormsFromJArray(JDB.solveObj(".RPB_HostileFactionsCache"))
    endif
    return __FormsFromJArray(JDB.solveObj(".RPB_HostileFactionsVanillaCache"))
endFunction

function __EnsureHostileFactionsCached() global
    int modInstalled = RPB_Compat_MasterOfDisguise.IsInstalled() as int
    ; Objects, not ints: JDB owns (keeps alive) what it holds as an object. An older save holds the union as a plain int
    ; (retained by hand) - solveObj reads that as 0, so it gets rebuilt once here and replaced.
    int cached = JDB.solveObj(".RPB_HostileFactionsCache")
    int cachedVanilla = JDB.solveObj(".RPB_HostileFactionsVanillaCache")
    if (cached && cachedVanilla && JDB.solveInt(".RPB_HostileFactionsCacheMoD", -1) == modInstalled)
        return
    endif

    int vanilla = JArray.object()
    int fromVanilla = __AppendFormsToJArray(vanilla, __ResolveVanillaHostileFactions())
    int combined = JArray.object()
    JArray.addFromArray(combined, vanilla)
    int fromModCompat = __AppendFormsToJArray(combined, RPB_Compat_MasterOfDisguise.GetFactions())

    JDB.solveObjSetter(".RPB_HostileFactionsVanillaCache", vanilla, true)
    JDB.solveObjSetter(".RPB_HostileFactionsCache", combined, true)
    JDB.solveIntSetter(".RPB_HostileFactionsCacheMoD", modInstalled, true)

    Info("RPB_GetHostileFactions resolved and cached " + (fromVanilla + fromModCompat) + " hostile factions (" + fromVanilla + " vanilla, " + fromModCompat + " from Master of Disguise compat, installed: " + (modInstalled as bool) + ")")
endFunction

;/
    Hostile prisoners: guards attack them on sight because of a faction relationship, not because of their own Aggression stat,
    so IsHostileToActor has to read false for the imprisonment (and the arrest/escort leading up to it) to be peaceful. Applies
    to NPCs (bandits, Civil War soldiers, Forsworn) and to the player (a disguise mod such as fireundubh's Master of Disguise
    adds the PLAYER to the same kind of faction while disguised, e.g. BanditFaction). True if @akActor belongs to any faction
    in RPB_GetHostileFactionsFor(@akActor).

    Global and Actor-based (not a Prisoner/Arrestee instance method) on purpose: this needs to run from RPB_Arrest.BeginArrest,
    which only has a bare Actor and an RPB_Arrestee (not yet an RPB_Prisoner) - see NeutralizeHostileActor for why the storage
    is also Actor-keyed with a fixed category rather than going through the RPB_ActorBase per-subclass wrapper.
/;
bool function IsHostileActor(Actor akActor) global
    Form[] hostileFactions = RPB_GetHostileFactionsFor(akActor)
    if (!hostileFactions)
        return false
    endif

    int i = 0
    while (i < hostileFactions.Length)
        Faction hostileFaction = hostileFactions[i] as Faction
        if (hostileFaction && akActor.IsInFaction(hostileFaction))
            return true
        endif
        i += 1
    endWhile
    return false
endFunction

;/
    Removes @akActor from every hostile faction it belongs to (saving faction + rank so it can be restored later, see
    Prison.__QueueHostilityRestore) and zeroes its Aggression so it does not throw the first punch either. A no-op for the
    common (non-hostile) actor (see IsHostileActor).

    Called from three places, all meant to converge on the same storage: RPB_Arrest.BeginArrest (the moment an arrest is
    confirmed - covers confrontation/escort/teleport, before Imprison() ever runs), Prisoner.Imprison (a fallback for any path
    that reaches imprisonment without going through BeginArrest, e.g. a direct MakePrisoner() call in a test), and the hourly
    Imprisoned-state tick (in case a disguise mod re-flags the actor mid-sentence and it wasn't actually stripped - see
    KNOWN_ISSUES). Each call is idempotent: once removed, nothing matches and the next call no-ops without touching the storage.
    One pass over the factions, not IsHostileActor() first and then a second pass: every membership check costs a frame.

    Storage is written straight through RPB_StorageVars.*OnReference with a literal "Jail" category - deliberately NOT through
    the RPB_ActorBase SetForm/GetForm wrapper, whose default category resolves differently per subclass (GetScriptVarCategory:
    "Jail" on RPB_Prisoner, "Arrest" on RPB_Arrestee). Using the wrapper would mean a snapshot taken during arrest (as an
    Arrestee) lands in a different bucket than the one Prison.__QueueHostilityRestore reads on release (as a Prisoner) - the
    restore would silently find nothing. A literal category is the same regardless of which class (or none) calls this.
/;
function NeutralizeHostileActor(Actor akActor) global
    Form[] hostileFactions = RPB_GetHostileFactionsFor(akActor)
    FlowMark("Neutralize: faction list")
    if (!hostileFactions)
        return
    endif

    Form[] removedFactions = new Form[128]
    int[] removedRanks = new int[128]
    int removed = 0
    string ranksLogged = ""
    int i = 0
    while (i < hostileFactions.Length && removed < 128)
        Faction hostileFaction = hostileFactions[i] as Faction
        if (hostileFaction && akActor.IsInFaction(hostileFaction))
            int rank = akActor.GetFactionRank(hostileFaction)
            removedFactions[removed] = hostileFaction
            removedRanks[removed] = rank
            akActor.RemoveFromFaction(hostileFaction)
            ranksLogged += " " + hostileFaction + "=r" + rank
            removed += 1
        endif
        i += 1
    endWhile
    FlowMark("Neutralize: faction loop")

    if (removed == 0)
        return ; not hostile (the common case) - must not overwrite a snapshot an earlier call saved
    endif

    Form[] trimmedFactions = Utility.CreateFormArray(removed)
    int[] trimmedRanks = Utility.CreateIntArray(removed)
    i = 0
    while (i < removed)
        trimmedFactions[i] = removedFactions[i]
        trimmedRanks[i] = removedRanks[i]
        i += 1
    endWhile

    RPB_StorageVars.SetFormsOnReference("Hostile Factions", akActor, trimmedFactions, "Jail")
    RPB_StorageVars.SetIntsOnReference("Hostile Ranks", akActor, trimmedRanks, "Jail")
    RPB_StorageVars.SetFloatOnReference("Original Aggression", akActor, akActor.GetActorValue("Aggression"), "Jail")
    FlowMark("Neutralize: snapshot saved")
    akActor.SetActorValue("Aggression", 0.0)
    akActor.StopCombat()
    akActor.StopCombatAlarm()
    FlowMark("Neutralize: AV + StopCombat")

    ; Guarded with Info()'s own condition: the message calls GetDisplayName(), built before Info() could skip it
    if (IsLoggingEnabled() && !IsDebuggingEnabled())
        Info("Neutralized " + akActor.GetDisplayName() + " " + akActor + " (removed from " + removed + " hostile factions:" + ranksLogged + ")")
    endif
    FlowMark("Neutralize: Info")
endFunction

;/
    A hostile faction (see NeutralizeHostileActor) is only half the story: a disguise mod such as Master of Disguise attaches
    its OWN ability effect to a nearby guard the moment it detects the disguise, and that effect puts the GUARD directly into
    an active, alerted combat stance (SetAlert/DrawWeapon) - confirmed by reading Master of Disguise's real source
    (dubhFactionEnemyScript.psc): removing the arrestee's faction does not, by itself, make an already-fighting guard
    disengage. Skyrim also generally can't run a scene on an actor that's still actively in combat, which is why an arrest
    attempted mid-fight produced a broken half state (both effects attached, no escort scene, no cuffs): the arresting guard
    was still fighting when the scene should have started.

    Called from BeginArrest alongside/after NeutralizeHostileActor's first pass: stops combat on the known captor directly
    (the actor whose scene actually needs to run) and on every actor PO3_SKSEFunctions.GetCombatTargets(@akArrestee) returns,
    to also catch any OTHER guard(s) independently still fighting. Confirmed the same function already works for this exact
    purpose in the Surrender system (EventManager.OnSurrenderPreparing) - read it BEFORE calling StopCombat on anyone
    (stopping one combatant first can tear down the shared combat group/instance the query itself reads from).

    Root cause found in a real test with Master of Disguise actually installed: as long as the disguise stays equipped,
    the mod's own polling keeps RE-ADDING the hostile faction every time any nearby guard's independent effect instance
    decides its own chase is over (several guards each running their own instance can re-arm the faction while another is
    still fighting - matches the oscillating pass counts seen in testing). Removing the faction once, or even stopping
    combat repeatedly, does not help if a live external system keeps putting the faction back. I'm not shipping a
    compatibility patch that redistributes a modified copy of another author's script without their permission, so this
    stays a self-contained RPB mitigation instead: every pass also re-runs NeutralizeHostileActor, so even
    though the faction keeps getting reapplied, the window during which the actor actually reads hostile is kept to well
    under a second at a time - usually too short for a guard to newly acquire them as a combat target. The loop runs for up
    to PACIFICATION_TIME_BUDGET_SECONDS (a safety ceiling, not a fixed wait - it exits the moment a pass finds nothing left
    to do), longer than Master of Disguise's own initial-detection Suspend(5.0) window, since the ongoing chase (its
    State Alive, ~1 s polling) can run well past that.
/;
; A plain function, not a Property: RPB_Utility is a hidden, instance-less script, and a global function (no self) can't
; reference an instance property even when it's autoreadonly - matches the Warn/Info/RPB_GetOutfit convention already used
; for constants elsewhere in this file.
float function PACIFICATION_TIME_BUDGET_SECONDS() global
    return 30.0
endFunction

function SustainArrestPacification(Actor akArrestee, Actor akCaptor) global
    float startTime = Utility.GetCurrentRealTime()
    int passNumber = 0
    bool keepGoing = true
    while (keepGoing && (Utility.GetCurrentRealTime() - startTime) < PACIFICATION_TIME_BUDGET_SECONDS())
        passNumber += 1
        keepGoing = __ArrestPacificationPass(akArrestee, akCaptor, passNumber)
        if (keepGoing)
            Utility.Wait(0.5)
        endif
    endWhile
endFunction

; One sweep: strips whatever hostile faction is currently on the arrestee (no-op if none - the ordinary, non-hostile arrest
; costs nothing here), stops combat on the captor and everyone GetCombatTargets(@akArrestee) currently returns. Returns
; true if anything needed doing this pass (the caller keeps sweeping while true, up to its own time budget).
bool function __ArrestPacificationPass(Actor akArrestee, Actor akCaptor, int aiPassNumber) global
    bool wasHostile = IsHostileActor(akArrestee)
    if (wasHostile)
        NeutralizeHostileActor(akArrestee)
    endif

    Actor[] combatTargets = PO3_SKSEFunctions.GetCombatTargets(akArrestee)

    bool captorWasFighting = akCaptor && akCaptor.IsInCombat()
    if (akCaptor)
        akCaptor.StopCombat()
    endif

    int stopped = 0
    string stoppedLogged = ""
    if (combatTargets)
        int i = 0
        while (i < combatTargets.Length)
            Actor combatant = combatTargets[i]
            if (combatant && combatant != akCaptor)
                combatant.StopCombat()
                stoppedLogged += " " + combatant.GetDisplayName() + " " + combatant
                stopped += 1
            endif
            i += 1
        endWhile
    endif

    Info("SustainArrestPacification pass " + aiPassNumber + " on " + akArrestee.GetDisplayName() + " " + akArrestee + ": faction reapplied " + wasHostile + ", captor " + akCaptor + " was fighting " + captorWasFighting + ", GetCombatTargets found " + stopped + " more:" + stoppedLogged)
    return wasHostile || captorWasFighting || stopped > 0
endFunction

;/
    Called from RPB_Arrestee.OnUpdate() every tick for the WHOLE arrest/escort duration (unlike SustainArrestPacification's
    bounded burst at BeginArrest, which only covers the first ~30 s) - the actual fix for "half arrested": a real test
    showed BeginArrest's own check come back clean (nothing hostile yet) and stop watching, only for the faction to be
    reapplied later during the escort with nothing left monitoring for it.

    Deliberately cheap for the ordinary (ATTOW: non-hostile) arrest: the only cost every tick is one IsHostileActor() check
    (itself now cached, see RPB_GetHostileFactions) - the combat-side work (GetCombatTargets, StopCombat) only runs when
    that check is actually true, so an ordinary escort never pays for it. Returns true if it found and fixed something (the
    caller re-checks sooner next time instead of falling back to its normal pace).
/;
bool function MaintainArrestPacification(Actor akArrestee, Actor akCaptor) global
    if (!IsHostileActor(akArrestee))
        return false
    endif

    NeutralizeHostileActor(akArrestee)

    if (akCaptor)
        akCaptor.StopCombat()
    endif
    Actor[] combatTargets = PO3_SKSEFunctions.GetCombatTargets(akArrestee)
    if (combatTargets)
        int i = 0
        while (i < combatTargets.Length)
            Actor combatant = combatTargets[i]
            if (combatant && combatant != akCaptor)
                combatant.StopCombat()
            endif
            i += 1
        endWhile
    endif

    Info("MaintainArrestPacification re-neutralized " + akArrestee.GetDisplayName() + " " + akArrestee + " mid-arrest (a hostile faction was reapplied after the initial check)")
    return true
endFunction

; ==========================================================
;                        Log Functions
; ==========================================================


bool function IsTracingEnabled() global
    return IsDebuggingEnabled() && RPB_StorageVars.GetBool("TRACE", "Log", true)
endFunction

bool function IsDebuggingEnabled() global
    return RPB_StorageVars.GetBool("DEBUG", "Log", false) ; OFF by default: every passing Debug() line costs a frame (~370 ms per imprisonment)
endFunction

bool function IsLoggingEnabled() global
    return RPB_StorageVars.GetBool("LOG", "Log", true)
endFunction

function EnableDebugging() global
    RPB_StorageVars.SetBool("DEBUG", true, "Log")
endFunction

function DisableDebugging() global
    RPB_StorageVars.SetBool("DEBUG", false, "Log")
endFunction

function EnableLogging() global
    RPB_StorageVars.SetBool("LOG", true, "Log")
endFunction

function DisableLogging() global
    RPB_StorageVars.SetBool("LOG", false, "Log")
endFunction

function SetLoggingEnabled(string asLogType, bool abEnabled) global
    RPB_StorageVars.SetBool(asLogType, abEnabled, "Log")
endFunction

function base_log(string asLogType = "DEBUG", string asLogInfo, string asCaller = "", string asCallerArgs = "") global
    if (asCaller)
        debug.trace("["+ ModName() +"] " + asLogType + " " + asCaller + "("+ asCallerArgs +")" + " -> " + asLogInfo)
    else
        debug.trace("["+ ModName() +"] " + asLogType + " " + asLogInfo)
    endif
endFunction

function Trace(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsTracingEnabled())
        return
    endif

    base_log("TRACE:", asLogInfo, asCaller)
endFunction

function Debug(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("DEBUG:", asLogInfo, asCaller)
endFunction

function NotImplemented(string asCaller, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("IMPLEMENT:", asCaller + " has not been implemented!", asCaller)
endFunction

function FunctionNotImplemented(string asCaller, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("IMPLEMENT:", "Function " + asCaller + "() has not been implemented!", asCaller)
endFunction

function EventNotImplemented(string asCaller, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("IMPLEMENT:", "Event " + asCaller + "() has not been implemented!", asCaller)
endFunction

function DebugInfo(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("INFO:", asLogInfo, asCaller)
endFunction

function DebugWarn(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("WARN:", asLogInfo, asCaller)
endFunction

function DebugError(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("ERROR:", asLogInfo, asCaller)
endFunction

function DebugWithArgs(string asCaller, string asArgs, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("DEBUG:", asLogInfo, asCaller, asArgs)
endFunction

function DebugParams(string params, string paramNames = "", string caller = "", bool condition = true) global
    string[] splitParams    = StringUtil.Split(params, ",")
    string[] splitNames     = StringUtil.Split(paramNames, ", ")

    string msg = "[\n"
    int i = 0
    while (i < splitParams.Length)
        string paramName = string_if (splitNames[i], splitNames[i], i)
        msg += "\t" + paramName + ": " + splitParams[i]

        if (i < splitParams.Length - 1)
            msg += "\n"
        endif

        i += 1
    endWhile
    msg += "\n]"

    Debug(caller, msg, condition)
endFunction

function LogNoType(string asLogInfo, string asCaller = "", bool abCondition = true) global
    if (!abCondition || !IsLoggingEnabled())
        return
    endif

    debug.trace("["+ ModName() +"] " + asLogInfo)
endFunction

function LogException(string asExceptionType, string asExceptionMessage, string asCaller = "", bool abCondition = true) global
    if (!abCondition)
        return
    endif

    string caller = string_if (asCaller, asCaller + "() -> ", "")
    ; debug.trace("["+ ModName() +"] " + caller + asExceptionMessage)
    debug.trace("["+ ModName() +"] [" + asExceptionType + "]: " + caller + asExceptionMessage)

endFunction

function Info(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("INFO:", asLogInfo)
endFunction

function Warn(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("WARN:", asLogInfo)
endFunction

function Error(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("ERROR:", asLogInfo)
endFunction

function Fatal(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("FATAL:", asLogInfo)
endFunction

function LogProperty(string prop, string asLogInfo, bool condition = true) global
    if (!condition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif
    
    base_log("PROPERTY:", asLogInfo)
endFunction

function ErrorProperty(string asProperty, string asLogInfo, bool condition = true) global
    if (!condition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("ERROR (PROPERTY):", asLogInfo)
endFunction

; ==========================================================
;                       Math Functions
; ==========================================================

float function Max(float a, float b) global
    if (a > b)
        return a
    else
        return b
    endif
endFunction

float function Min(float a, float b) global
    if (a < b)
        return a
    else
        return b
    endif
endFunction

int function Round(float value) global
    float fractionalPart = value - math.floor(value)

    if (fractionalPart >= 0.5)
        return math.ceiling(value)
    else
        return math.floor(value)
    endif
endFunction


; ==========================================================
;                       Clamp Functions
; ==========================================================

int function ClampInt(int value, int min, int max) global
    if (value < min)
        return min
    elseif (value > max)
        return max
    else
        return value
    endif
endFunction

float function ClampFloat(float value, float min, float max) global
    if (value < min)
        return min
    elseif (value > max)
        return max
    else
        return value
    endif
endFunction

; int function ClampInt(int value, int min = 2147483647, int max = -2147483648) global
;     int NO_MIN = -2147483648
;     int NO_MAX = 2147483647

;     ; If user didn’t pass min, Papyrus fills in with default (2147483647)
;     if (min == 2147483647)
;         min = NO_MIN
;     endif

;     ; If user didn’t pass max, Papyrus fills in with default (-2147483648)
;     if (max == -2147483648)
;         max = NO_MAX
;     endif

;     Debug("ClampInt", "Min: " + min + ", Max: " + max + ", Value: " + value)

;     if (value < min)
;         return min
;     elseif (value > max)
;         return max
;     else
;         return value
;     endif
; endFunction

; float function ClampFloat(float value, float min = -99999999.0, float max = 99999999.0) global
;     float NO_MIN = -99999999.0
;     float NO_MAX =  99999999.0

;     ; Replace default sentinels with real unbounded values
;     if (min == -99999999.0)
;         min = NO_MIN
;     endif
;     if (max == 99999999.0)
;         max = NO_MAX
;     endif

;     if (value < min)
;         return min
;     elseif (value > max)
;         return max
;     else
;         return value
;     endif
; endFunction

; Converts the passed in percent number to its equivalent decimal percentage to do calculations.
; e.g: 5 becomes 0.05
float function PercentToDecimal(float percentToConvert) global
    if (percentToConvert <= 0)
        return 0.0
    endif
    
    return percentToConvert / 100
endFunction

; ==========================================================
;                 Ternary-Operator Functions
; ==========================================================

;/
	Ternary operator-like functions
	objective: float x = condition ? afTrue : afFalse
    usage: float x = float_if(condition, afTrue, afFalse)
    example: float x = float_if(y == 2, 4, 8)

/;
float function float_if(bool condition, float afTrue, float afFalse = 0.0) global
	if(condition)
		return afTrue
	endif
	return afFalse
endfunction

int function int_if(bool condition, int aiTrue, int aiFalse = 0) global
	if(condition)
		return aiTrue
	endif
	return aiFalse
endfunction

bool function bool_if(bool condition, bool abTrue, bool abFalse = false) global
	if(condition)
		return abTrue
	endif
	return abFalse
endfunction

string function string_if(bool condition, string asTrue, string asFalse = "") global
	if(condition)
		return asTrue
	endif
	return asFalse
endfunction

Form function form_if(bool condition, Form akTrue, Form akFalse = none) global
    if(condition)
        return akTrue
    else
        return akFalse
    endif
endfunction

ActiveMagicEffect function ame_if (bool condition, ActiveMagicEffect apTrue, ActiveMagicEffect apFalse) global
    if (condition)
        return apTrue
    else
        return apFalse
    endif
endFunction

; ==========================================================
;                      String Functions
; ==========================================================

string function GetFormattedAsParams(string values, string keys = "", string keyPrefixes = "", string keySuffixes = "", string valuePrefixes = "", string valueSuffixes = "") global
    string[] splitValues        = StringUtil.Split(values, ",")
    string[] splitKeys          = StringUtil.Split(keys, ", ")
    string[] splitKeyPrefixes   = StringUtil.Split(keyPrefixes, ", ")
    string[] splitKeySuffixes   = StringUtil.Split(keySuffixes, ", ")
    string[] splitValuePrefixes = StringUtil.Split(valuePrefixes, ", ")
    string[] splitValueSuffixes = StringUtil.Split(valueSuffixes, ", ")

    string msg = "[\n"
    int i = 0
    while (i < splitValues.Length)
        string paramName = string_if (splitKeys[i], splitKeys[i], i)
        string keyPrefix = ""
        string keySuffix = ""
        string valuePrefix = ""
        string valueSuffix = ""

        if (splitKeyPrefixes != none)
            keyPrefix = splitKeyPrefixes[i]
        endif

        if (splitValuePrefixes != none)
            valuePrefix = splitValuePrefixes[i]
        endif

        if (splitKeySuffixes != none)
            keySuffix = splitKeySuffixes[i]
        endif

        if (splitValueSuffixes != none)
            valueSuffix = splitValueSuffixes[i]
        endif

        msg += "\t" + keyPrefix + paramName + keySuffix + ": " + valuePrefix + splitValues[i] + valueSuffix

        if (i < splitValues.Length - 1)
            msg += "\n"
        endif

        i += 1
    endWhile
    msg += "\n]"

    return msg
endFunction

bool function String_StartsWith(string str, string needle) global
    if (StringUtil.GetLength(str) < StringUtil.GetLength(needle))
        return false
    endif

    string substring = StringUtil.Substring(str, 0, StringUtil.GetLength(needle))
    return substring == needle
endFunction

; TODO: Test
bool function String_EndsWith(string str, string needle) global
    if (StringUtil.GetLength(str) < StringUtil.GetLength(needle))
        return false
    endif

    string substring = StringUtil.Substring(str, StringUtil.GetLength(str) - StringUtil.GetLength(needle), StringUtil.GetLength(needle))
    return substring == needle
endFunction

bool function String_StartsEndsWith(string str, string startChar, string endChar) global
    if (StringUtil.GetLength(str) == 0)
        return false
    endif

    return StringUtil.GetNthChar(str, 0) == startChar && StringUtil.GetNthChar(str, StringUtil.GetLength(str) - 1) == endChar
endFunction

bool function String_Contains(string str, string needle) global
    return StringUtil.Find(str, needle) != -1
endFunction

string function String_Implode(string[] akStrArray, string asDelimiter = ",") global
    string result = ""

    int i = 0
    while (i < akStrArray.Length)
        result += akStrArray[i]

        if (i < (akStrArray.Length - 1))
            result += asDelimiter
        endif

        i += 1
    endWhile

    return result
endFunction

string[] function String_Explode(string asStr, string asDelimiter = ",") global
    return StringUtil.Split(asStr, asDelimiter)
endFunction

string function ReplaceString(string str, string toFind, string replacement) global
    int len = StringUtil.GetLength(str)
    string result = ""

    int i = 0
    while (i < len)
        int index = StringUtil.Find(str, toFind, i)
        if (index != -1)
            result += StringUtil.Substring(str, i, index - i)
            result += replacement

            i = index + StringUtil.GetLength(toFind)
        else
            result += StringUtil.Substring(str, i, len - i)
            return result
        endif
    endWhile

    return result
endFunction

; string function ReplaceChar(string str, string toFind, string replacement) global
;     int len = StringUtil.GetLength(str)
;     string result = ""
;     DebugWithArgs("Data::ReplaceChar", "toFind Length: " + StringUtil.GetLength(toFind) + ", replacement Length: " + StringUtil.GetLength(replacement), "")
;     int i = 0
;     while (i < len)
;         string currentChar = StringUtil.GetNthChar(str, i)
;         DebugWithArgs("", "Data::ReplaceChar", "Index: " + i + ", Current Char: " + currentChar + ", ToFind: " + toFind)

;         if (currentChar == toFind)
;             result += replacement
;             DebugWithArgs("Data::ReplaceChar", "str: " + str + ", toFind: " + toFind + ", replacement: " + replacement, "Found "+ currentChar +", appending " + replacement)
;         else
;             result += currentChar
;         endif
;         i += 1
;     endWhile
;     DebugWithArgs("Data::ReplaceChar", "str: " + str + ", toFind: " + toFind + ", replacement: " + replacement, "Returning " + result)

;     return result
; endFunction

string[] function StringArray_Merge(string[] asArrayOne, string[] asArrayTwo) global
    int newStringArray = JArray.object()
    int arrayOneObj = JArray.objectWithStrings(asArrayOne)
    int arrayTwoObj = JArray.objectWithStrings(asArrayTwo)

    JArray.addFromArray(newStringArray, arrayOneObj)
    JArray.addFromArray(newStringArray, arrayTwoObj)

    return JArray.asStringArray(newStringArray)
endFunction

string function Replace(string asTemplate, string[] akPlaceholders, string[] akReplacements) global
    int numberOfPlaceholders = akPlaceholders.Length
    int numberOfReplacements = akReplacements.Length

    if (numberOfPlaceholders != numberOfReplacements)
        return "Error: Number of placeholders does not match the number of replacements!"
    endif

    int startIndex = StringUtil.Find(asTemplate, "{", 0)
    int templateLength = StringUtil.GetLength(asTemplate)

    string result = ""

    int placeholderStartIndex = 0
    int placeholderEndIndex = 0

    bool outerBreak = false
    while (placeholderStartIndex < templateLength && !outerBreak)
        placeholderStartIndex = StringUtil.Find(asTemplate, "{", startIndex)
        if (placeholderStartIndex == -1)
            ; If no more placeholders found, append the remaining part of the template
            result += StringUtil.Substring(asTemplate, startIndex, templateLength - startIndex)
            ; Trace("Utility::Replace", "["+ placeholderStartIndex +"]: " + result)
            outerBreak = true
        else
            ; Append the part of the template before the placeholder
            if (startIndex > 0)
                result += StringUtil.Substring(asTemplate, startIndex, placeholderStartIndex - startIndex)
            endif
            ; result += StringUtil.Substring(asTemplate, startIndex, placeholderStartIndex - startIndex)
            ; Trace("Utility::Replace", "["+ placeholderStartIndex +"]: " + result)

            ; Find the end of the placeholder
            placeholderEndIndex = StringUtil.Find(asTemplate, "}", placeholderStartIndex)
            if (placeholderEndIndex == -1)
                return "Error: Unclosed placeholder."
            endif

            ; Get the placeholder name
            string placeholder = StringUtil.Substring(asTemplate, placeholderStartIndex + 1, placeholderEndIndex - placeholderStartIndex - 1)

            ; Find the index of the placeholder in the array
            int replacementIndex = -1
            int n = 0
            bool innerBreak = false
            while (n < numberOfPlaceholders && !innerBreak)
                if (placeholder == akPlaceholders[n])
                    replacementIndex = n
                    innerBreak = true
                endif
                n += 1
            endWhile

            ; If replacement found, append it; otherwise, append the original placeholder
            if (replacementIndex != -1)
                result += akReplacements[replacementIndex]
            else
                result += "{" + placeholder + "}"
            endif

            ; Move the start index to the character after the end of the placeholder
            startIndex = placeholderEndIndex + 1
        endif
    endWhile

    return result
endFunction

; ==========================================================
;                       Array Functions
; ==========================================================

function Array_ClearForms(Form[] akArray) global
    int i = 0
    while (i < akArray.Length)
        akArray[i] = none
        i += 1
    endWhile
endFunction

; ==========================================================
;                      Bitwise Functions
; ==========================================================

string function OR(int[] elements) global
    string orBitwiseExpr = ""

    int i = 0
    while (i < elements.Length)
        orBitwiseExpr += elements[i]
        if (i < (elements.Length - 1))
            orBitwiseExpr +=  " | "
        endif
        i += 1
    endWhile

    return orBitwiseExpr
endFunction

string function XOR(int[] elements) global
    string xorBitwiseExpr = ""

    int i = 0
    while (i < elements.Length)
        xorBitwiseExpr += elements[i]
        if (i < (elements.Length - 1))
            xorBitwiseExpr +=  " ^ "
        endif
        i += 1
    endWhile

    return xorBitwiseExpr
endFunction

string function AND(int[] elements) global
    string andBitwiseExpr = ""

    int i = 0
    while (i < elements.Length)
        andBitwiseExpr += elements[i]
        if (i < (elements.Length - 1))
            andBitwiseExpr +=  " & "
        endif
        i += 1
    endWhile

    return andBitwiseExpr
endFunction

; Temporary
int function BitwiseExpr(string bitfield) global
    ; Debug("BitwiseExpr", "["+i+"] " + "Bitfield: " + bitfield)

    int result = 0
    string currentOperator = ""
    string[] tokens = StringUtil.Split(bitfield, " ")

    ; Iterate over tokens to process the bitwise expression
    int i = 0
    while (i < tokens.length)
        string token = tokens[i]

        if (token == "|")
            currentOperator = "OR"
        elseif (token == "&")
            currentOperator = "AND"
        elseif (token == "<<")
            currentOperator = "LSHIFT"
        elseif (token == ">>")
            currentOperator = "RSHIFT"
        else
            bool isHexadecimal  = String_StartsWith(token, "0x")
            bool isBinary       = !isHexadecimal && String_StartsWith(token, "0b")
            bool isDecimal      = !isHexadecimal && !isBinary

            int currentValue = 0

            if (isHexadecimal)
                currentValue = HexStringToInt(token)
 
            elseif (isBinary)
                currentValue = BinStringToInt(token)

            elseif (isDecimal)
                currentValue = token as int
            endif

            ; Debug("BitwiseExpr", "["+i+"] " + currentValue)

            ; Apply the current operator
            if (currentOperator == "")
                result = currentValue
            elseif (currentOperator == "OR")
                result = Math.LogicalOr(result, currentValue)
            elseif (currentOperator == "AND")
                result = Math.LogicalAnd(result, currentValue)
            elseif (currentOperator == "LSHIFT")
                result = Math.LeftShift(result, currentValue)
            elseif (currentOperator == "RSHIFT")
                result = Math.RightShift(result, currentValue)
            endif

            ; Reset current operator after use
            currentOperator = ""
        endif

        i += 1
    endWhile

    return result
endFunction

; ==========================================================
;                        AI Functions
; ==========================================================

function RetainAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(true)
        ; Game.GetPlayer().EnableAI(true)
        Game.DisablePlayerControls( \
            abMovement = true, \
            abFighting = true, \
            abCamSwitch = false, \
            abLooking = false, \
            abSneaking = true, \
            abMenu = true, \
            abActivate = true, \
            abJournalTabs = false, \
            aiDisablePOVType = 0 \
        )
    endif
endFunction

function ReleaseAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(false)
        Game.EnablePlayerControls()
    endif
endFunction

function SetGameStat(string asStatName, int aiValue) global
    int statValue = Game.QueryStat(asStatName)
    Game.IncrementStat(asStatName, (-statValue) + aiValue)
endFunction

; ==========================================================
;                      External Functions
; ==========================================================

bool function IsActorArrested(Actor akActor) global
    return RPB_StorageVars.GetBoolOnReference("Arrested", akActor, "Arrest")
endFunction

bool function IsActorImprisoned(Actor akActor) global
    return RPB_StorageVars.GetBoolOnReference("Imprisoned", akActor, "Jail")
endFunction

bool function IsPlayerArrested() global
    return RPB_StorageVars.GetBoolOnReference("Arrested", Game.GetForm(0x14))
endFunction

bool function IsPlayerImprisoned() global
    return RPB_StorageVars.GetBoolOnReference("Imprisoned", Game.GetForm(0x14))
endFunction

;/
    Retrieves the Hold's Crime Faction through its name

    string  @asHold: The hold's crime faction.

    returns (Faction): The Hold's Crime Faction.
/;
Faction function GetCrimeFactionByHold(string asHold) global
    int holdObject = RPB_Data.GetRootObject(asHold)
    return RPB_Data.Hold_GetCrimeFaction(holdObject)
endFunction

bool function WasPlayerLastJailedInHold(Faction akCrimeFaction) global
    return RPB_StorageVars.HasVarOnReference("Last Jailed - Prison", akCrimeFaction, "PrisonLastJailed")
endFunction

int function GetPlayerPrisonLastJailedTime(string asTimeType, Faction akCrimeFaction) global
    if (asTimeType != "Day" && asTimeType != "Month" && asTimeType != "Year" && asTimeType != "Hour" && asTimeType != "Minute")
        return -1
    endif

    return RPB_StorageVars.GetIntOnReference("Last Jailed - " + asTimeType, akCrimeFaction, "PrisonLastJailed")
endFunction

int function GetPlayerPrisonLastReleasedTime(string asTimeType, Faction akCrimeFaction) global
    if (asTimeType != "Day" && asTimeType != "Month" && asTimeType != "Year" && asTimeType != "Hour" && asTimeType != "Minute")
        return -1
    endif

    return RPB_StorageVars.GetIntOnReference("Last Released - " + asTimeType, akCrimeFaction, "PrisonLastReleased")
endFunction

int function GetPlayerPrisonLastEscapedTime(string asTimeType, Faction akCrimeFaction) global
    if (asTimeType != "Day" && asTimeType != "Month" && asTimeType != "Year" && asTimeType != "Hour" && asTimeType != "Minute")
        return -1
    endif

    return RPB_StorageVars.GetIntOnReference("Last Escaped - " + asTimeType, akCrimeFaction, "PrisonLastEscaped")
endFunction

; ==========================================================
;                       Actor Functions
; ==========================================================

function UnequipHandsForActor(Actor akActor) global
    UnequipWeaponForActor(akActor, false)
    UnequipWeaponForActor(akActor, false)
    UnequipWeaponForActor(akActor, true)
    UnequipSpellForActor(akActor)
    UnequipShieldForActor(akActor)
endFunction

function UnequipWeaponForActor(Actor akActor, bool abLeftHand = false, bool abPreventEquip = false, bool abSilentUnequip = true) global
    Weapon kWeapon = akActor.GetEquippedWeapon(abLeftHand)
    if (kWeapon != None)
        akActor.UnequipItem(kWeapon, abPreventEquip, abSilentUnequip)
    endif
endFunction

function UnequipShieldForActor(Actor akActor, bool abPreventEquip = false, bool abSilentUnequip = true) global
    Armor kShield = akActor.GetEquippedShield()
    if (kShield != None)
        akActor.UnequipItem(kShield, abPreventEquip, abSilentUnequip)
    endif
endFunction

function UnequipSpellForActor(Actor akActor) global
    int leftHand  = 0
    int rightHand = 1

    Spell kSpell = akActor.GetEquippedSpell(leftHand)
    if (kSpell != None)
        akActor.UnequipSpell(kSpell, leftHand)
    endif

    kSpell = akActor.GetEquippedSpell(rightHand)
    if (kSpell != None)
        akActor.UnequipSpell(kSpell, rightHand)
    endif
endFunction

function UnequipShoutForActor(Actor akActor) global
    Shout kShout = akActor.GetEquippedShout()
    if (kShout != None)
        akActor.UnequipShout(kShout)
    endif
endFunction

bool function ActorHasClothing(Actor akActor) global
    ;/
        TODO: Possibly check for more slotMasks, but for now Body should be fine.
    /;
    return akActor.GetWornForm(GetSlotMask("Body")) != none
endFunction

;/
    Checks if the specified Actor is male.
    Actor @akActor: The Actor to check.
/;
bool function IsActorMale(Actor akActor) global
    return akActor.GetActorBase().GetSex() == 0
endFunction

;/
    Checks if the specified Actor is female.
    Actor @akActor: The Actor to check.
/;
bool function IsActorFemale(Actor akActor) global
    return akActor.GetActorBase().GetSex() == 1
endFunction

;/
    Checks if the specified Actor is of the specified gender.

    Actor @akActor: The Actor to check.
    string @asGender: The gender to check for.

    Returns true if the Actor is of the specified gender, false otherwise.
/;
bool function IsActorOfGender(Actor akActor, string asGender) global
    if (asGender == "Female" || asGender == "F")
        return IsActorFemale(akActor)
        
    elseif (asGender == "Male" || asGender == "M")
        return IsActorMale(akActor)
    endif

    return false
endFunction

;/
    Checks if there are any Actors in the list that are of the specified gender.
    Optionally, if @abStrictlyMatchGender is true, checks if all of the Actors are of the specified gender.

    Form[] @akActors: The list of Actors to check.
    string @asGender: The gender to check for.
    bool?  @abStrictlyMatchGender: Checks if all of the Actors are of the specified gender.

    Returns true if there are any Actors in the list that are of the specified gender,
    or if they are all of the specified gender when @abStrictlyMatchGender is true, false otherwise.
/;
bool function HasActorsOfGenderInList(Form[] akActors, string asGender, bool abStrictlyMatchGender = false) global
    if (!akActors)
        return false
    endif

    if (asGender != "Male" && asGender != "Female" && asGender != "M" && asGender != "F")
        return false
    endif

    int i = 0
    while (i < akActors.Length)
        Actor actorRef = akActors[i] as Actor
        if (actorRef && IsActorOfGender(actorRef, asGender))
            return true

        elseif (abStrictlyMatchGender)
            return false
        endif
        i += 1
    endWhile

    return false
endFunction

;/
    Checks if there are any Actors in the list that are Males.
    Optionally, if @abStrictlyMales is true, checks if all of the Actors are Males.

    Form[] @akActors: The list of Actors to check.
    bool?  @abStrictlyMales: Checks if all of the Actors are Males.

    Returns true if there are any Actors in the list that are Males,
    or if they are all Males when @abStrictlyMales is true, false otherwise.
/;
bool function HasMalesInList(Form[] akActors, bool abStrictlyMales = false) global
    return HasActorsOfGenderInList(akActors, "Male", abStrictlyMales)
endFunction

;/
    Checks if there are any Actors in the list that are Females.
    Optionally, if @abStrictlyFemales is true, checks if all of the Actors are Females.

    Form[] @akActors: The list of Actors to check.  
    bool?  @abStrictlyFemales: Checks if all of the Actors are Females.

    Returns true if there are any Actors in the list that are Females,
    or if they are all Females when @abStrictlyFemales is true, false otherwise.
/;
bool function HasFemalesInList(Form[] akActors, bool abStrictlyFemales = false) global
    return HasActorsOfGenderInList(akActors, "Female", abStrictlyFemales)
endFunction

;/
    Retrieves all Actors in the list that are of the specified gender.

    Form[] @akActors: The source list of Actors.
    string @asGender: The gender to check for.

    returns (Form[]): The Actors in the list that are of the specified gender.
/;
Form[] function GetActorsOfGenderInList(Form[] akActors, string asGender) global
    if (!akActors)
        return none
    endif

    if (asGender != "Male" && asGender != "Female" && asGender != "M" && asGender != "F")
        return none
    endif

    int actors = FastArray("<Form>")

    int i = 0
    while (i < akActors.Length)
        Actor actorRef = akActors[i] as Actor
        if (actorRef && IsActorOfGender(actorRef, asGender))
            FastArray_AddForm(actors, actorRef)
        endif
        i += 1
    endWhile

    return FastArray_ToFormArray(actors)
endFunction

;/
    Retrieves all Actors in the list that are Males.

    Form[] @akActors: The source list of Actors.

    returns (Form[]): The Actors in the list that are Males.
/;
Form[] function GetMalesInList(Form[] akActors) global
    return GetActorsOfGenderInList(akActors, "Male")
endFunction

;/
    Retrieves all Actors in the list that are Females.

    Form[] @akActors: The source list of Actors.

    returns (Form[]): The Actors in the list that are Females.
/;
Form[] function GetFemalesInList(Form[] akActors) global
    return GetActorsOfGenderInList(akActors, "Female")
endFunction


; ==========================================================
;                   Prison/Arrest Functions
; ==========================================================

;/
    Awaits a reference of RPB_ActorBase for the specified Actor.
    If the Actor is not of the Entity type yet, they will be made into one and bound to it. 

    Actor           @akEntity: The actor to retrieve the Prisoner reference from.
    RPB_ActorList   @apEntityList: The entity list to get the reference from.
    RPB_Entity      @apEntity: The entity to bind this Actor to.
    int?            @aiMaxTries: Ignored (kept so existing calls compile) - the wait policy is fixed inside: ~0.05-0.1s polling, ~12s budget.
    float?          @afInitialTimeBetweenTries: Ignored, see above.
    float?          @afMaxTimeBetweenTries: Ignored, see above.

    returns (RPB_ActorBase): The RPB_ActorBase reference for this Actor.
/;
RPB_ActorBase function AwaitEntityReference(\
    Actor akEntity, \
    RPB_ActorList apEntityList, \
    RPB_Entity apEntity = none, \
    int aiMaxTries = 120, \
    float afInitialTimeBetweenTries = 0.05, \
    float afMaxTimeBetweenTries = 0.1 \
) global
    ; Only set for the Arrestee list, the one the diagnostic below is for
    Spell diagnosedSpell

    if (apEntityList as RPB_PrisonerList)
        EnsurePrisonerSpellAndBinding(akEntity, apEntity as RPB_Prison)
        ; Debug("Utility::AwaitEntityReference", "("+ akEntity +") apEntityList: " + apEntityList)
        ; Debug("Utility::AwaitEntityReference", "(RPB_PrisonerList) ("+ akEntity +") apEntityList Keys: " + apEntityList.GetKeys())

    elseif (apEntityList as RPB_ArresteeList)
        EnsureArresteeSpellAndBinding(akEntity, apEntity as RPB_Hold)
        diagnosedSpell = RPB_ArresteeSpell()
        ; Debug("Utility::AwaitEntityReference", "(RPB_ArresteeList) ("+ akEntity +") apEntityList Keys: " + apEntityList.GetKeys())

     elseif (apEntityList as RPB_CaptorList)
         EnsureCaptorSpellAndBinding(akEntity)
    endif

    ; Already registered (the common case for an actor that was set up earlier, loaded or not)?
    ; Then there is nothing to wait for.
    RPB_ActorBase entityRef = apEntityList.AtKeyEx(akEntity) as RPB_ActorBase

    if (!entityRef)
        ; The spell's magic effect only starts once the actor's 3D is loaded (measured: registered
        ; ~260ms after AddSpell on a loaded actor, never on an unloaded/disabled one), and it is the
        ; effect that registers the actor. Waiting the whole budget for an actor that isn't loaded
        ; only turns "can't happen" into a long stall, so give it a short grace period to load and
        ; then say why.
        ;/ const /; float LOAD_GRACE_SECONDS = 5.0
        float loadWaitStart = Utility.GetCurrentRealTime()
        while (!akEntity.Is3DLoaded() && (Utility.GetCurrentRealTime() - loadWaitStart) < LOAD_GRACE_SECONDS)
            Utility.Wait(0.1)
        endWhile

        if (!akEntity.Is3DLoaded())
            DebugError("Utility::AwaitEntityReference ["+ apEntityList.ListIdentifier() +"]", "The Actor " + akEntity + " is not loaded (3D not loaded, disabled: " + akEntity.IsDisabled() + ", cell " + akEntity.GetParentCell() + ") after " + LOAD_GRACE_SECONDS + "s - its spell effect can't start until it is, so it can't be registered now.")
            Error(akEntity.GetBaseObject().GetName() + " is not loaded, cannot be registered right now!")
            return none
        endif

        ; Shared logic for awaiting reference. Wait first, then check, so the loop returns as soon as
        ; the registration is seen (it used to check, then wait one more full delay before leaving),
        ; and keep the delay short and capped: registration lands within ~0.2-1.5s, and a long
        ; backoff only adds up to ~50% overshoot to every await.
        ; The wait policy is fixed HERE on purpose, not taken from the parameters: Papyrus bakes a
        ; function's default argument values into every call site when THAT caller is compiled, so
        ; changing the defaults on the wrappers alone would leave every caller that isn't recompiled
        ; on the old slow exponential backoff. The parameters remain only so existing calls compile.
        ;/ const /; float POLL_FIRST_SECONDS = 0.05
        ;/ const /; float POLL_MAX_SECONDS = 0.1
        ;/ const /; float MAX_WAIT_SECONDS = 12.0
        ; An Arrestee effect normally registers within ~0.16-0.3s. Past this point, record why it hasn't (crumbs only).
        ; The one cause actually seen: the actor is dead - the Arrestee effect has no "No Death Dispel", so a corpse
        ; can't take it and a death ends it (test 97's hostile bandits getting killed by the guard while they waited).
        ; Re-casting doesn't help a corpse; the caller's clean revert handles the timeout.
        ;/ const /; float DIAGNOSE_AFTER_SECONDS = 3.0
        bool diagnosed = false
        float delay = POLL_FIRST_SECONDS
        float startTime = Utility.GetCurrentRealTime()

        ; Safeguard
        while (!entityRef && (Utility.GetCurrentRealTime() - startTime) < MAX_WAIT_SECONDS)
            Utility.Wait(delay)
            entityRef = apEntityList.AtKeyEx(akEntity) as RPB_ActorBase
            delay *= 1.5
            if (delay > POLL_MAX_SECONDS)
                delay = POLL_MAX_SECONDS
            endif

            if (!entityRef && !diagnosed && diagnosedSpell && (Utility.GetCurrentRealTime() - startTime) >= DIAGNOSE_AFTER_SECONDS)
                diagnosed = true
                if (IsCrumbsEnabled())
                    Crumb(akEntity, "AwaitEntityReference: not registered after " + DIAGNOSE_AFTER_SECONDS + "s [" + apEntityList.ListIdentifier() + "] (HasMagicEffect: " + akEntity.HasMagicEffect(diagnosedSpell.GetNthEffectMagicEffect(0)) + ", HasSpell: " + akEntity.HasSpell(diagnosedSpell) + ", dead: " + akEntity.IsDead() + ", health: " + akEntity.GetActorValue("Health") + ")")
                endif
            endif
        endWhile
    endif

    if (!entityRef)
        Crumb(akEntity, "AwaitEntityReference TIMEOUT [" + apEntityList.ListIdentifier() + "] (hasPrisonerSpell: " + akEntity.HasSpell(RPB_PrisonerSpell()) + ", hasArresteeSpell: " + akEntity.HasSpell(RPB_ArresteeSpell()) + ")")
        DebugError("Utility::AwaitEntityReference ["+ apEntityList.ListIdentifier() +"]", "The Actor " + akEntity + " is not in the provided list or there was a state mismatch!")
        Error(akEntity.GetBaseObject().GetName() + " is not in the provided list or there was a state mismatch!")
        return none
    endif
    ; Debug("Utility::AwaitEntityReference", "("+ akEntity +") Returned: " + entityRef)

    return entityRef
endFunction

;/
    Awaits a reference of RPB_ActorBase for the specified Actor.

    Actor           @akEntity: The actor to retrieve the Prisoner reference from.
    RPB_ActorList   @apEntityList: The entity list to get the reference from.
    RPB_Entity      @apEntity: The entity to bind this Actor to.
    int?            @aiMaxTries: Ignored (kept so existing calls compile) - the wait policy is fixed inside: ~0.05-0.1s polling, ~12s budget.
    float?          @afInitialTimeBetweenTries: Ignored, see above.
    float?          @afMaxTimeBetweenTries: Ignored, see above.

    returns (RPB_ActorBase): The RPB_ActorBase reference for this Actor.
/;
RPB_ActorBase function AwaitExistingEntityReference(\
    Actor akEntity, \
    RPB_ActorList apEntityList, \
    RPB_Entity apEntity = none, \
    int aiMaxTries = 120, \
    float afInitialTimeBetweenTries = 0.05, \
    float afMaxTimeBetweenTries = 0.1 \
) global
    ; Shared logic for awaiting reference
    RPB_ActorBase entityRef = apEntityList.AtKeyEx(akEntity) as RPB_ActorBase
    ; Same fixed wait policy as AwaitEntityReference (see the note there): the parameters are ignored
    ;/ const /; float POLL_FIRST_SECONDS = 0.05
    ;/ const /; float POLL_MAX_SECONDS = 0.1
    ;/ const /; float MAX_WAIT_SECONDS = 12.0
    float delay = POLL_FIRST_SECONDS
    float startTime = Utility.GetCurrentRealTime()

    ; Safeguard
    while (!entityRef && (Utility.GetCurrentRealTime() - startTime) < MAX_WAIT_SECONDS)
        Utility.Wait(delay)
        entityRef = apEntityList.AtKeyEx(akEntity) as RPB_ActorBase
        delay *= 1.5
        if (delay > POLL_MAX_SECONDS)
            delay = POLL_MAX_SECONDS
        endif
    endWhile

    if (!entityRef)
        DebugError("Utility::AwaitExistingEntityReference ["+ apEntityList.ListIdentifier() +"]", "The Actor " + akEntity + " is not in the provided list or there was a state mismatch!")
        Error(akEntity.GetBaseObject().GetName() + " is not in the provided list or there was a state mismatch!")
        return none
    endif

    return entityRef
endFunction

;/
    Ensures the Actor @akArrestee is an Arrestee, and binds it to @apHold.

    Actor       @akArrestee: The Actor to be ensured as an Arrestee.
    RPB_Hold    @apHold: The Prison to which the Actor should be bound as an Arrestee.
/;
function EnsureArresteeSpellAndBinding(Actor akArrestee, RPB_Hold apHold) global
    if (!akArrestee.HasSpell(RPB_ArresteeSpell()))
        ; Bind this Hold to the Arrestee (to retrieve it from RPB_Arrestee) BEFORE the spell is added: the effect starts on
        ; another thread as soon as AddSpell returns and reads this value in its OnInitialize (it used to be written after,
        ; so under load the effect could start without it).
        if (apHold)
            RPB_StorageVars.SetStringOnReference("Hold UUID", akArrestee, apHold.UUID, "Arrest")
        endif

        ; Cast the Arrestee spell (to bind the RPB_Arrestee instance script)
        akArrestee.AddSpell(RPB_ArresteeSpell(), false)
    endif
endFunction

;/
    Ensures the Actor @akPrisoner is a Prisoner, and binds it to @apPrison.

    Actor       @akPrisoner: The Actor to be ensured as a Prisoner.
    RPB_Prison  @apPrison: The Prison to which the Actor should be bound as a Prisoner.
/;
function EnsurePrisonerSpellAndBinding(Actor akPrisoner, RPB_Prison apPrison) global
    if (!akPrisoner.HasSpell(RPB_PrisonerSpell()))
        ; Bind this Prison to the Prisoner (to retrieve it from RPB_Prisoner) BEFORE the spell is added. The effect starts on
        ; another thread as soon as AddSpell returns and resolves its Prison from this value in OnInitialize; written after the
        ; spell, under load the effect could start first, find no Prison and never register (found by the stress test breadcrumbs:
        ; "Prisoner.OnInitialize: enter ... Prison: None").
        if (apPrison)
            RPB_StorageVars.SetStringOnReference("Prison UUID", akPrisoner, apPrison.UUID, "Jail")
        endif

        ; Cast the Prisoner spell (to bind the RPB_Prisoner instance script)
        Crumb(akPrisoner, "EnsurePrisonerSpellAndBinding: AddSpell prisoner")
        akPrisoner.AddSpell(RPB_PrisonerSpell(), false)
    endif
endFunction

function EnsureCaptorSpellAndBinding(Actor akCaptor) global
    if (!akCaptor.HasSpell(RPB_CaptorSpell()))
        akCaptor.AddSpell(RPB_CaptorSpell(), false)
    endif
endFunction

; ==========================================================
;                     Type Cast Functions
; ==========================================================

Form[] function ActorToFormArray(Actor[] akActors) global
    int arr = JArray.object()

    int i = 0
    while (i < akActors.Length)
        JArray.addForm(arr, akActors[i])
        i += 1
    endWhile

    return JArray.asFormArray(arr)
endFunction

; ==========================================================
;                       Param Functions
; ==========================================================

function AddIntIfNotNone(int aiElement, int arr) global
    if (aiElement)
        JArray.addInt(arr, aiElement)
    endif
endFunction

function AddFormIfNotNone(Form akForm, int arr) global
    if (akForm)
        JArray.addForm(arr, akForm)
    endif
endFunction

int[] function IntList( \
int aiElement1, \
int aiElement2 = 0, \
int aiElement3 = 0, \
int aiElement4 = 0, \
int aiElement5 = 0, \
int aiElement6 = 0, \
int aiElement7 = 0, \
int aiElement8 = 0, \
int aiElement9 = 0, \
int aiElement10 = 0, \
int aiElement11 = 0, \
int aiElement12 = 0, \
int aiElement13 = 0, \
int aiElement14 = 0, \
int aiElement15 = 0, \
int aiElement16 = 0, \
int aiElement17 = 0, \
int aiElement18 = 0, \
int aiElement19 = 0, \
int aiElement20 = 0 \
) global

    int arr = JArray.object()

    AddIntIfNotNone(aiElement1, arr)
    AddIntIfNotNone(aiElement2, arr)
    AddIntIfNotNone(aiElement3, arr)
    AddIntIfNotNone(aiElement4, arr)
    AddIntIfNotNone(aiElement5, arr)
    AddIntIfNotNone(aiElement6, arr)
    AddIntIfNotNone(aiElement7, arr)
    AddIntIfNotNone(aiElement8, arr)
    AddIntIfNotNone(aiElement9, arr)
    AddIntIfNotNone(aiElement10, arr)
    AddIntIfNotNone(aiElement11, arr)
    AddIntIfNotNone(aiElement12, arr)
    AddIntIfNotNone(aiElement13, arr)
    AddIntIfNotNone(aiElement14, arr)
    AddIntIfNotNone(aiElement15, arr)
    AddIntIfNotNone(aiElement16, arr)
    AddIntIfNotNone(aiElement17, arr)
    AddIntIfNotNone(aiElement18, arr)
    AddIntIfNotNone(aiElement19, arr)
    AddIntIfNotNone(aiElement20, arr)

    return JArray.asIntArray(arr)
endFunction

Form[] function BuildParamsObjectReference(\
    ObjectReference akRef1, \
    ObjectReference akRef2 = none, \
    ObjectReference akRef3 = none, \
    ObjectReference akRef4 = none, \
    ObjectReference akRef5 = none, \
    ObjectReference akRef6 = none, \
    ObjectReference akRef7 = none, \
    ObjectReference akRef8 = none, \
    ObjectReference akRef9 = none, \
    ObjectReference akRef10 = none, \
    ObjectReference akRef11 = none, \
    ObjectReference akRef12 = none, \
    ObjectReference akRef13 = none, \
    ObjectReference akRef14 = none, \
    ObjectReference akRef15 = none, \
    ObjectReference akRef16 = none, \
    ObjectReference akRef17 = none, \
    ObjectReference akRef18 = none, \
    ObjectReference akRef19 = none, \
    ObjectReference akRef20 = none \
) global

    int arr = JArray.object()

    AddFormIfNotNone(akRef1, arr)
    AddFormIfNotNone(akRef2, arr)
    AddFormIfNotNone(akRef3, arr)
    AddFormIfNotNone(akRef4, arr)
    AddFormIfNotNone(akRef5, arr)
    AddFormIfNotNone(akRef6, arr)
    AddFormIfNotNone(akRef7, arr)
    AddFormIfNotNone(akRef8, arr)
    AddFormIfNotNone(akRef9, arr)
    AddFormIfNotNone(akRef10, arr)
    AddFormIfNotNone(akRef11, arr)
    AddFormIfNotNone(akRef12, arr)
    AddFormIfNotNone(akRef13, arr)
    AddFormIfNotNone(akRef14, arr)
    AddFormIfNotNone(akRef15, arr)
    AddFormIfNotNone(akRef16, arr)
    AddFormIfNotNone(akRef17, arr)
    AddFormIfNotNone(akRef18, arr)
    AddFormIfNotNone(akRef19, arr)
    AddFormIfNotNone(akRef20, arr)

    return JArray.asFormArray(arr)
endFunction

Form[] function BuildParamsActor(\
    Actor akRef1, \
    Actor akRef2 = none, \
    Actor akRef3 = none, \
    Actor akRef4 = none, \
    Actor akRef5 = none, \
    Actor akRef6 = none, \
    Actor akRef7 = none, \
    Actor akRef8 = none, \
    Actor akRef9 = none, \
    Actor akRef10 = none, \
    Actor akRef11 = none, \
    Actor akRef12 = none, \
    Actor akRef13 = none, \
    Actor akRef14 = none, \
    Actor akRef15 = none, \
    Actor akRef16 = none, \
    Actor akRef17 = none, \
    Actor akRef18 = none, \
    Actor akRef19 = none, \
    Actor akRef20 = none \
) global

    int arr = JArray.object()

    AddFormIfNotNone(akRef1, arr)
    AddFormIfNotNone(akRef2, arr)
    AddFormIfNotNone(akRef3, arr)
    AddFormIfNotNone(akRef4, arr)
    AddFormIfNotNone(akRef5, arr)
    AddFormIfNotNone(akRef6, arr)
    AddFormIfNotNone(akRef7, arr)
    AddFormIfNotNone(akRef8, arr)
    AddFormIfNotNone(akRef9, arr)
    AddFormIfNotNone(akRef10, arr)
    AddFormIfNotNone(akRef11, arr)
    AddFormIfNotNone(akRef12, arr)
    AddFormIfNotNone(akRef13, arr)
    AddFormIfNotNone(akRef14, arr)
    AddFormIfNotNone(akRef15, arr)
    AddFormIfNotNone(akRef16, arr)
    AddFormIfNotNone(akRef17, arr)
    AddFormIfNotNone(akRef18, arr)
    AddFormIfNotNone(akRef19, arr)
    AddFormIfNotNone(akRef20, arr)

    return JArray.asFormArray(arr)

endFunction

; ==========================================================
;                       Alias Functions
; ==========================================================

function BindAliasTo(ReferenceAlias akAlias, ObjectReference akObjectReference) global
    if (akObjectReference != None)
        ; DebugWithArgs("Utility::BindAliasTo", "akAlias: " + akAlias + ", akObjectReference: " + akObjectReference, "Bound Alias to "+ akObjectReference)
        akAlias.ForceRefTo(akObjectReference)
    else
        akAlias.Clear()
    endif
endFunction

function UnbindAlias(ReferenceAlias akAlias) global
    akAlias.Clear()
endFunction

; ==========================================================
;           Distance/Position/Translation Functions
; ==========================================================

float function GetInfinityDistance() global
    return 340282346638528859811
endFunction

float function UnitsToCM(int unit)
    return unit * 1.428
endFunction

float function UnitsToM(int unit)
    return (unit * 1.428) / 100
endFunction

; Faces akObjA relative to akObjB
; 
; Examples:
; OrientRelative(objA, objB) 					; Sets A to face directly away from B
; OrientRelative(objA, objB, afRotZ = 180.0) 	; Sets A to face toward B
; 
function OrientRelative(ObjectReference akObjA, ObjectReference akObjB, Float afRotX = 0.0, Float afRotY = 0.0, Float afRotZ = 0.0) Global
	Float rotX = akObjB.GetAngleX()
	Float rotY = akObjB.GetAngleY()
	Float rotZ = akObjB.GetAngleZ()

	akObjA.SetAngle(rotX, rotY, rotZ)
endFunction

bool function IsFarAwayFromObject(ObjectReference akObjectOne, ObjectReference akObjectTwo) global
    float infinityDistance = 340282346638528859811 ; Obtained from GetDistance in another cell different from @akObjectOne
    return akObjectOne.GetDistance(akObjectTwo) >= infinityDistance
endFunction

;/
    A vanilla Skyrim AI-package pathing problem, not specific to this mod: an Actor walking up to approach another one
    (e.g. a guard closing in to cuff an arrestee) can end up physically wedged inside the target's own collision, and
    the package can never resolve out of it on its own. This is just the plain distance check used to detect that -
    the actual fix (teleporting one of the two a short distance apart) belongs with whichever caller knows which of the
    two Actors it's safe to move (see RPB_Arrestee.AwaitConfrontationScene).
/;
bool function IsWedgedTogether(Actor akActorOne, Actor akActorTwo, float afStuckDistance = 90.0) global
    if (!akActorOne || !akActorTwo)
        return false
    endif

    return akActorOne.GetDistance(akActorTwo) < afStuckDistance
endFunction

;/
    Moves akActorToMove to a point afDistance units further out, along the line already connecting it to akAnchor - a
    genuine "push directly away from wherever it actually was" position. Deliberately not ObjectReference.MoveTo's own
    offset parameters: those are relative to akAnchor's own local/facing space, not a function of akActorToMove's real
    prior position, which is why a MoveTo(afXOffset=...) nudge visibly moved a guard to the arrestee's side instead of
    straight back (confirmed in a real test) - and MoveTo's abMatchRotation also snaps the mover's facing to match the
    anchor's, an extra unwanted side effect this avoids by using SetPosition directly instead. No trigonometry needed:
    just the direction vector between the two current positions, normalized by their real distance.

    Actor   @akActorToMove: the Actor to reposition.
    Actor   @akAnchor: the point to push directly away from.
    float   @afDistance: how far to push, in the same units GetDistance() reports.
/;
function PushActorAwayFrom(Actor akActorToMove, Actor akAnchor, float afDistance) global
    if (!akActorToMove || !akAnchor)
        return
    endif

    float currentDistance = akActorToMove.GetDistance(akAnchor)
    if (currentDistance <= 0.0)
        return ; exactly co-located: no direction to push along (shouldn't happen given the wedge check that gates this)
    endif

    float deltaX = akActorToMove.GetPositionX() - akAnchor.GetPositionX()
    float deltaY = akActorToMove.GetPositionY() - akAnchor.GetPositionY()

    float newX = akActorToMove.GetPositionX() + (deltaX / currentDistance) * afDistance
    float newY = akActorToMove.GetPositionY() + (deltaY / currentDistance) * afDistance

    akActorToMove.SetPosition(newX, newY, akActorToMove.GetPositionZ())
endFunction

bool function IsActorFarAwayFromPlayer(Actor akActor) global
    if (!akActor)
        DebugError("Utility::IsActorFarAwayFromPlayer", "Actor is null, cannot measure the distance!")
        Error("Actor is null, cannot measure the distance!")
        return false
    endif
    
    return IsFarAwayFromObject(akActor, Game.GetPlayer())
endFunction

; ==========================================================
;                       UUID Functions
; ==========================================================

string function GenerateUUIDSection(int aiLength) global
    string result = ""
    while (aiLength > 0)
        result += GetRandomHex()
        aiLength -= 1
    endWhile

    return result
endFunction

string function GenerateUUID() global
    string section1 = GenerateUUIDSection(8)
    string section2 = GenerateUUIDSection(4)
    string section3 = "4" + GenerateUUIDSection(3) ; Force UUIDv4
    string section4 = IntToHex(Utility.RandomInt(8, 11)) + GenerateUUIDSection(3) ; Set 'N' to be 8, 9, A or B
    string section5 = GenerateUUIDSection(12)

    string uuid = section1 + "-" + section2 + "-" + section3 + "-" + section4 + "-" + section5
    return uuid
endFunction

; ==========================================================
;                       Misc Functions
; ==========================================================

int[] function Pair(int n1, int n2) global
    int[] pair = new int[2]
    pair[0] = n1
    pair[1] = n2

    return pair
endFunction

;/
    INFO: Slow function, execution takes ~25ms, avoid when looping

    Retrieves a Form from a string identifier (the string obtained when implicitly casting a Form to a string),
    which means a Form can be passed here.

    string  @asFormIdentifier: The Form's identifier when implicitly cast as a string, expressed like this: [Form < (00036897)>]
    Actor, ObjectReference, or any other Form type will work.

    returns (Form): The Form that matches its identifier.
/;
Form function GetFormFromString(string asFormIdentifier) global
    int formIdLength    = 8 ; FormID always has 8 digits
    int endOffset       = 3 ; )>]
    int len             = StringUtil.GetLength(asFormIdentifier)
    string hexFormID    = StringUtil.Substring(asFormIdentifier, len - endOffset - formIdLength, formIdLength)
    int formID          = HexStringToInt(hexFormID)

    return Game.GetFormEx(formID)
endFunction

;/
    Extracts the reference type (Actor, ObjectReference, etc.) from a Papyrus reference, implicitly castable to a string.

    string  @asReference: The Papyrus reference, implicitly castable to a string, expressed like this: [Actor < (00036897)>]

    returns (string): The reference type (Actor, ObjectReference, etc).
/;
string function ExtractReferenceType(string asReference) global
    int beginningIdGroupIndex = StringUtil.Find(asReference, " <", 1)
    return StringUtil.Substring(asReference, 1, beginningIdGroupIndex - 1)
endFunction

;/
    Extracts the reference ID from a Papyrus reference, implicitly castable to a string.

    string  @asReference: The Papyrus reference, implicitly castable to a string, expressed like this: [Actor < (00036897)>]

    returns (string): The reference ID (00036897).
/;
string function ExtractReferenceID(string asReference) global
    int idLength        = 8 ; Papyrus reference ID's always have 8 digits
    int endOffset       = 3 ; )>]
    int len             = StringUtil.GetLength(asReference)
    return StringUtil.Substring(asReference, len - endOffset - idLength, idLength)
endFunction

;/
    Parses the given number string as an integer in various formats.

    For Decimal numbers, @asNumber should simply be passed the number.
    For Hexadecimal numbers, prefix the number with '0x'.
    For Binary numbers, prefix the number with '0b'.

    returns (int): The given number as an integer in decimal format.
/;
int function ParseInt(string asNumber) global
    bool isHexadecimal  = String_StartsWith(asNumber, "0x")
    bool isBinary       = !isHexadecimal && String_StartsWith(asNumber, "0b")
    bool isDecimal      = !isHexadecimal && !isBinary

    if (isHexadecimal)
        return HexStringToInt(asNumber)

    elseif (isBinary)
        return BinStringToInt(asNumber)

    elseif (isDecimal)
        return asNumber as int
    endif

    return -1
endFunction

int function ParseBinary(string asBin) global
    int BIT_OFF = 0
    int BIT_ON  = 1
    int PREFIX_LEN = 2
    int result = 0
    int len = StringUtil.GetLength(asBin)

    bool hasBinPrefix = String_StartsWith(asBin, "0b")
    int i = int_if (hasBinPrefix, PREFIX_LEN, 0)
    
    while (i < len)
        string currentBit = StringUtil.GetNthChar(asBin, i)
        if (currentBit < BIT_OFF || currentBit > BIT_ON)
            return -1
        endif

        result += Math.Pow(2, (len - 1 - i)) as int
        i += 1
    endWhile

    return result
endFunction

int function HexStringToInt(string asHexString) global
    int result = 0
    int len = StringUtil.GetLength(asHexString)

    bool hasHexPrefix = \ 
        StringUtil.GetNthChar(asHexString, 0) == "0" && \
        StringUtil.GetNthChar(asHexString, 1) == "x"

    int i = int_if (hasHexPrefix, 2, 0)
    while (i < len)
        string currentChar = StringUtil.GetNthChar(asHexString, i)
        int value

        if (StringUtil.IsDigit(currentChar))
            value = (currentChar as int)
        elseif (currentChar == "A")
                value = 10
            elseif (currentChar == "B")
                value = 11
            elseif (currentChar == "C")
                value = 12
            elseif (currentChar == "D")
                value = 13
            elseif (currentChar == "E")
                value = 14
            elseif (currentChar == "F")
                value = 15
        else
            DebugError("Utility::HexStringToInt", "Invalid HEX character: " + currentChar)
            return -1
        endif

        result = result * 16 + value
        ; Debug("Utility::HexStringToInt", "["+ currentChar +"] result: " + result + " (value: "+ value +")")
        i += 1
    endWhile

    return result
endFunction

int function BinStringToInt(string asBinString) global
    int BIT_OFF = 0
    int BIT_ON  = 1
    int PREFIX_LEN = 2
    int result = 0
    int len = StringUtil.GetLength(asBinString)

    bool hasBinPrefix = String_StartsWith(asBinString, "0b")

    int i = int_if (hasBinPrefix, PREFIX_LEN, 0)
    while (i < len)
        string currentChar = StringUtil.GetNthChar(asBinString, i)
        result += Math.Pow(2, (len - 1 - i)) as int
        i += 1
    endWhile

    return result
endFunction

string function IntToHex(int i) global
    if (i >= 0 && i <= 9)
        return i as string

    elseif (i == 10)
        return "A"
    elseif (i == 11)
        return "B"
    elseif (i == 12)
        return "C"
    elseif (i == 13)
        return "D"
    elseif (i == 14)
        return "E"
    elseif (i == 15)
        return "F"
    endif

    return ""
endFunction

string function GetRandomHex() global
    int random = Utility.RandomInt(0, 15)
    return IntToHex(random)
endFunction


Form function GetFormOfType(string asFormType) global
    if (asFormType == "Gold")
        return Game.GetFormEx(0xF)

    elseif (asFormType == "Lockpick")
        return Game.GetFormEx(0xA)
    endif
endFunction

int function GetSlotMask(string bodyPart) global
    int kSlotMask30 = 0x00000001 ; HEAD
    int kSlotMask31 = 0x00000002 ; Hair
    int kSlotMask32 = 0x00000004 ; BODY
    int kSlotMask33 = 0x00000008 ; Hands
    int kSlotMask34 = 0x00000010 ; Forearms
    int kSlotMask35 = 0x00000020 ; Amulet
    int kSlotMask36 = 0x00000040 ; Ring
    int kSlotMask37 = 0x00000080 ; Feet
    int kSlotMask38 = 0x00000100 ; Calves
    int kSlotMask39 = 0x00000200 ; SHIELD
    int kSlotMask40 = 0x00000400 ; TAIL
    int kSlotMask41 = 0x00000800 ; LongHair
    int kSlotMask42 = 0x00001000 ; Circlet
    int kSlotMask43 = 0x00002000 ; Ears

    if (bodyPart == "Head")
        return kSlotMask30
    elseif (bodyPart == "Hair")
        return kSlotMask31
    elseif (bodyPart == "Body")
        return kSlotMask32
    elseif (bodyPart == "Hands")
        return kSlotMask33
    elseif (bodyPart == "Forearms")
        return kSlotMask34
    elseif (bodyPart == "Amulet")
        return kSlotMask35
    elseif (bodyPart == "Ring")
        return kSlotMask36
    elseif (bodyPart == "Feet")
        return kSlotMask37
    elseif (bodyPart == "Calves")
        return kSlotMask38
    elseif (bodyPart == "Shield")
        return kSlotMask39
    elseif (bodyPart == "Tail")
        return kSlotMask40
    elseif (bodyPart == "LongHair")
        return kSlotMask41
    elseif (bodyPart == "Circlet")
        return kSlotMask42
    elseif (bodyPart == "Ears")
        return kSlotMask43
    endif

endFunction

;/
    Flow phase profiler (opt-in). Marks a few named points along a flow (arrest -> imprison) and, at FlowEnd(), logs
    the time each phase took: `FLOW: #3 Arrestee.InitializeState done | +48ms (net ~39ms) | total 412ms`.
    Vanilla natives cost about one frame each (~11ms at 90 FPS), so a phase's milliseconds ~ its number of natives.

    - Off by default. EnableFlowProfiling() / DisableFlowProfiling() (in game: F4 Actions menu -> "[Debug] Toggle Flow Profiling").
    - Off, a mark is a single JDB read (~0.4ms, no native). On, a mark reads Utility.GetCurrentRealTime() (one frame)
      and stores it; NOTHING is logged until FlowEnd(), so the logging itself does not distort the phases.
    - FlowBegin() also measures the cost of one timer read (two consecutive reads): every phase includes it, and the
      report prints each phase net of it.
    - One flow at a time (state lives under the "Profile" storage category). Marks after FlowEnd() are ignored.
/;
bool function IsFlowProfilingEnabled() global
    return JDB.solveInt(".rpb_root.storage.Profile.FLOW") != 0
endFunction

function EnableFlowProfiling() global
    RPB_StorageVars.SetBool("FLOW", true, "Profile")
endFunction

function DisableFlowProfiling() global
    RPB_StorageVars.SetBool("FLOW", false, "Profile")
    RPB_StorageVars.SetInt("Active", 0, "Profile")
endFunction

;/
    Dev-only per-actor breadcrumbs. Unlike the flow profiler (one global flow), every actor gets its own trail, stored on the
    reference (so it survives an ActiveMagicEffect script that has died), which makes it possible to see exactly where one
    actor's arrest -> imprison stopped when several run at once. Off by default; the stress tests turn it on.
    Crumb() when off costs one JDB read.
/;
bool function IsCrumbsEnabled() global
    return JDB.solveInt(".rpb_root.storage.Profile.CRUMBS") != 0
endFunction

function EnableCrumbs() global
    RPB_StorageVars.SetBool("CRUMBS", true, "Profile")
endFunction

function DisableCrumbs() global
    RPB_StorageVars.SetBool("CRUMBS", false, "Profile")
endFunction

function Crumb(Actor akActor, string asStage) global
    if (!akActor || JDB.solveInt(".rpb_root.storage.Profile.CRUMBS") == 0)
        return
    endif

    int count = RPB_StorageVars.GetIntOnReference("Count", akActor, "Crumbs") + 1
    RPB_StorageVars.SetIntOnReference("Count", akActor, count, "Crumbs")
    RPB_StorageVars.SetStringOnReference("s" + count, akActor, asStage + " [3D " + akActor.Is3DLoaded() + ", t=" + Utility.GetCurrentRealTime() + "]", "Crumbs")
endFunction

function ClearCrumbs(Actor akActor) global
    RPB_StorageVars.DeleteCategoryOnReference(akActor, "Crumbs")
endFunction

string function DumpCrumbs(Actor akActor) global
    int count = RPB_StorageVars.GetIntOnReference("Count", akActor, "Crumbs")
    string trail = "crumbs(" + count + "):"
    int i = 1
    while (i <= count)
        trail += " | " + RPB_StorageVars.GetStringOnReference("s" + i, akActor, "Crumbs")
        i += 1
    endWhile
    return trail
endFunction

;/
    The most game days a single update processes per-day events for (and the most days PassTimeInDays passes): 40 years.
    A prisoner's day events used to run once per elapsed day with no bound, so a huge elapsed time (a very long wait, a
    stale reference time) monopolized one script stack for minutes (~4 ms per day event) and delayed everything else,
    the player's release included. Long sentences are legitimate (NPCs that are only ever free by escaping), but one
    update must stay bounded. A dev value (Profile.MAX_DAY_EVENTS, 0 = default) lets a test lower it.
/;
int function GetMaxDayEventsPerUpdate() global
    int configured = JDB.solveInt(".rpb_root.storage.Profile.MAX_DAY_EVENTS")
    if (configured > 0)
        return configured
    endif
    return 14610
endFunction

function SetMaxDayEventsPerUpdate(int aiDays) global
    RPB_StorageVars.SetInt("MAX_DAY_EVENTS", aiDays, "Profile")
endFunction

;/
    Dev override (Profile.NO_OVERCROWDING): when set, no jail cell allows overcrowding whatever its data says, so a test can
    fill a prison to its real capacity. Off (0) by default = the cells' own data.
/;
bool function IsOvercrowdingDisabled() global
    return JDB.solveInt(".rpb_root.storage.Profile.NO_OVERCROWDING") != 0
endFunction

function SetOvercrowdingDisabled(bool abDisabled) global
    RPB_StorageVars.SetInt("NO_OVERCROWDING", abDisabled as int, "Profile")
endFunction

;/
    Dev override (Profile.FORCE_CONFRONTATION_FAIL): when set, Arrestee.AwaitConfrontationScene() returns false
    immediately instead of ever starting a real confrontation Scene, for testing EscortToPrison()'s TeleportToCell
    fallback deterministically (test 103). Real confrontation Scenes turned out to be untestable via actor-state
    sabotage - disabling either participant's AI (tried both ways) still let the Scene's first phase confirm within
    seconds regardless, since that phase's completion isn't gated on either actor's AI-driven behavior at all (see
    KNOWN_ISSUES.md, rounds 22-24). Off (0) by default = the real Scene flow, untouched.
/;
bool function IsConfrontationSceneForcedToFail() global
    return JDB.solveInt(".rpb_root.storage.Profile.FORCE_CONFRONTATION_FAIL") != 0
endFunction

function SetConfrontationSceneForcedToFail(bool abForced) global
    RPB_StorageVars.SetInt("FORCE_CONFRONTATION_FAIL", abForced as int, "Profile")
endFunction

;/
    Dev override for the prison monitor's wake: when > 0 the monitor wakes every that many game hours instead of at the
    earliest release, so its behavior can be tested without waiting out a sentence. 0 (default) = the real schedule.
/;
float function GetMonitorOverrideHours() global
    return JDB.solveFlt(".rpb_root.storage.Profile.MONITOR_HOURS")
endFunction

function SetMonitorOverrideHours(float afHours) global
    RPB_StorageVars.SetFloat("MONITOR_HOURS", afHours, "Profile")
endFunction

;/
    Dev override for how long a neutralized hostile prisoner stays neutral after release: when > 0, used instead of
    Prison.HOSTILITY_RESTORE_DELAY_HOURS, so a test doesn't have to wait out the real delay. 0 (default) = the real schedule.
/;
float function GetHostilityRestoreOverrideHours() global
    return JDB.solveFlt(".rpb_root.storage.Profile.HOSTILITY_RESTORE_HOURS")
endFunction

function SetHostilityRestoreOverrideHours(float afHours) global
    RPB_StorageVars.SetFloat("HOSTILITY_RESTORE_HOURS", afHours, "Profile")
endFunction

function FlowBegin(string asFlow) global
    if (!IsFlowProfilingEnabled())
        return
    endif

    float t0 = Utility.GetCurrentRealTime()
    float t1 = Utility.GetCurrentRealTime() ; two consecutive reads: the cost of one mark's timer

    RPB_StorageVars.SetString("Name", asFlow, "Profile")
    RPB_StorageVars.SetInt("Count", 0, "Profile")
    RPB_StorageVars.SetFloat("Overhead", t1 - t0, "Profile")
    RPB_StorageVars.SetFloat("Start", t1, "Profile")
    RPB_StorageVars.SetInt("Active", 1, "Profile")
endFunction

; Starts the flow only when none is running (for entry points that can be reached from several places)
function FlowEnsure(string asFlow) global
    if (IsFlowProfilingEnabled() && JDB.solveInt(".rpb_root.storage.Profile.Active") == 0)
        FlowBegin(asFlow)
    endif
endFunction

function FlowMark(string asPhase) global
    if (JDB.solveInt(".rpb_root.storage.Profile.Active") == 0)
        return
    endif

    float now = Utility.GetCurrentRealTime()
    int count = RPB_StorageVars.GetInt("Count", "Profile")

    RPB_StorageVars.SetFloat("t" + count, now, "Profile")
    RPB_StorageVars.SetString("p" + count, asPhase, "Profile")
    RPB_StorageVars.SetInt("Count", count + 1, "Profile")
endFunction

; Marks the last phase and logs the whole flow
function FlowEnd(string asPhase = "end") global
    if (JDB.solveInt(".rpb_root.storage.Profile.Active") == 0)
        return
    endif

    FlowMark(asPhase)
    RPB_StorageVars.SetInt("Active", 0, "Profile")

    int count = RPB_StorageVars.GetInt("Count", "Profile")
    float previous = RPB_StorageVars.GetFloat("Start", "Profile")
    float start = previous
    int overhead = (RPB_StorageVars.GetFloat("Overhead", "Profile") * 1000.0) as int
    string flowName = RPB_StorageVars.GetString("Name", "Profile")
    int netTotal = 0

    base_log("FLOW:", "==== " + flowName + ": " + count + " phases, one timer read costs ~" + overhead + "ms and is inside every phase ====")

    int i = 0
    while (i < count)
        float t = RPB_StorageVars.GetFloat("t" + i, "Profile")
        int delta = ((t - previous) * 1000.0) as int
        int net = delta - overhead
        if (net < 0)
            net = 0
        endif
        netTotal += net
        base_log("FLOW:", "#" + (i + 1) + " " + RPB_StorageVars.GetString("p" + i, "Profile") + " | +" + delta + "ms (net ~" + net + "ms) | total " + (((t - start) * 1000.0) as int) + "ms")
        previous = t
        i += 1
    endWhile

    base_log("FLOW:", "==== " + flowName + " total " + (((previous - start) * 1000.0) as int) + "ms, ~" + netTotal + "ms net of the timer ====")
endFunction

;/
    A Form's name, read from the engine only the first time (per Form, for the whole save): Form.GetName() is an engine
    native that costs about a frame (~11ms at 90 FPS, test 69) and faction names are used to build every ActorVars key.
    Kept in a persisted JFormMap under the RPB root. Names of these Forms do not change at runtime. Returns "" for None.
/;
string function GetFormNameCached(Form akForm) global
    if (!akForm)
        return ""
    endif

    int names = JDB.solveObj(".rpb_root.form_names")

    if (!names)
        JDB.solveObjSetter(".rpb_root.form_names", JFormMap.object(), true)
        names = JDB.solveObj(".rpb_root.form_names")
    endif

    if (JFormMap.hasKey(names, akForm))
        return JFormMap.getStr(names, akForm)
    endif

    string formName = akForm.GetName()
    JFormMap.setStr(names, akForm, formName)

    return formName
endFunction

int function GetSlotMaskValue(int slotMask) global
    ; 2^(slot - 30): slot 30 -> 0x1 ... slot 61 -> 0x80000000 (wraps to a negative int, as repeated doubling did).
    ; This used to loop up to 32 times (~0.35ms per iteration); -1 for slots outside 30..61 as before.
    if (slotMask < 30 || slotMask > 61)
        return -1
    endif

    return Math.LeftShift(1, slotMask - 30)
endFunction

string function YesNo(bool abValue) global
    if (abValue)
        return "Yes"
    else
        return "No"
    endif
endFunction

int function EnsureTrue(bool condition, string messageWhenFalse, int failedConditionList = 0) global
    if (!condition && failedConditionList)
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenFalse)

    elseif (!condition)
        failedConditionList = RPB_Memory.FastArray("<string>")
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenFalse)
        DebugWarn("Utility::EnsureTrue", messageWhenFalse)
    endif

    return failedConditionList
endFunction

int function EnsureFalse(bool condition, string messageWhenTrue, int failedConditionList = 0) global
    if (condition && failedConditionList)
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenTrue)

    elseif (condition)
        failedConditionList = RPB_Memory.FastArray("<string>")
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenTrue)
        DebugWarn("Utility::EnsureFalse", messageWhenTrue)
    endif

    return failedConditionList
endFunction

; ==========================================================
;                 Skill Stats/Perks Functions
; ==========================================================

string[] function GetAllSkillNames(bool abIncludeStatSkills = true, bool abIncludePerkSkills = true) global
    if (!abIncludeStatSkills && !abIncludePerkSkills)
        return none
    endif

    string skillList = ""

    if (abIncludeStatSkills)
        skillList += "Health,Stamina,Magicka,"
    endif

    if (abIncludePerkSkills)
        skillList += "Heavy Armor,Light Armor,Sneak,One-Handed,Two-Handed,Archery,Block," + \
                     "Smithing,Speechcraft,Pickpocketing,Lockpicking,Alteration,Conjuration," + \
                     "Destruction,Illusion,Restoration,Enchanting,Alchemy,"
    endif

    if (skillList != "")
        ; Remove trailing comma
        skillList = StringUtil.Substring(skillList, 0, StringUtil.GetLength(skillList) - 1)
    endif

    return StringUtil.Split(skillList, delim = ",")
endFunction

string function GetSkillName(string asSkillInternalReference) global
    string[] skillNames = GetAllSkillNames()
    string[] skillInternalReferences = GetAllSkills()

    int i = 0
    while (i < skillNames.Length)
        if (asSkillInternalReference == skillInternalReferences[i])
            return skillNames[i]
        endif
        i += 1
    endWhile
endFunction

string[] function GetAllSkills(bool abIncludeStatSkills = true, bool abIncludePerkSkills = true) global
    if (!abIncludeStatSkills && !abIncludePerkSkills)
        return none
    endif

    string skillList = ""

    if (abIncludeStatSkills)
        skillList += "Health,Stamina,Magicka,"
    endif

    if (abIncludePerkSkills)
        skillList += "HeavyArmor,LightArmor,Sneak,OneHanded,TwoHanded,Marksman,Block," + \
                     "Smithing,Speechcraft,Pickpocket,Lockpicking,Alteration,Conjuration," + \
                     "Destruction,Illusion,Restoration,Enchanting,Alchemy,"
    endif

    if (skillList != "")
        ; Remove trailing comma
        skillList = StringUtil.Substring(skillList, 0, StringUtil.GetLength(skillList) - 1)
    endif

    return StringUtil.Split(skillList, delim = ",")
endFunction

string[] function GetStatSkills() global
    return GetAllSkills(true, false)
endFunction

string[] function GetPerkSkills() global
    return GetAllSkills(false, true)
endFunction

bool function IsStatSkill(string asSkillName) global
    string[] statSkills = GetStatSkills()
    
    int i = 0
    while (i < statSkills.Length)
        if (asSkillName == statSkills[i])
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

bool function IsPerkSkill(string asSkillName) global
    return !IsStatSkill(asSkillName)
endFunction

string function GetRandomSkill(string asSkillType = "Stat") global
    if (asSkillType != "Stat" && asSkillType != "Perk")
        return none
    endif

    string[] skills = GetAllSkills(abIncludeStatSkills = asSkillType == "Stat", abIncludePerkSkills = asSkillType == "Perk")
    return skills[Utility.RandomInt(0, skills.Length - 1)]
endFunction

; ==========================================================
;                       Lock Functions
; ==========================================================

string[] function GetLockLevels() global
    return StringUtil.Split("Novice,Apprentice,Adept,Expert,Master,Requires Key", delim = ",")
endFunction

; ==========================================================
;                System Time Related Functions
; ==========================================================

; Retrieves the system time in the format Y-m-d H:i:s
string function GetDateTimeNow() global
    int[] systemTime = PO3_SKSEFunctions.GetSystemTime()
    int year    = systemTime[0]
    int month   = systemTime[1]
    int day     = systemTime[3]
    int hour    = systemTime[4]
    int minute  = systemTime[5]
    int second  = systemTime[6]

    return year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second
endFunction


; ==========================================================
;                 Game-Time Related Functions
; ==========================================================

float function now() global
    return Utility.GetCurrentGameTime()
endFunction

float function GetCurrentTime() global
    return Utility.GetCurrentGameTime()
endFunction

int function GetDaysOfMonth(int aiMonth) global
    if (aiMonth == 2) ; Sun's Dawn
        return 28
    elseif (aiMonth == 1 || aiMonth == 3 || aiMonth == 5 || aiMonth == 7 || aiMonth == 8 || aiMonth == 10 || aiMonth == 12)
        return 31
    elseif (aiMonth == 4 || aiMonth == 6 || aiMonth == 9 || aiMonth == 11)
        return 30
    else
        return -1
    endif
endFunction

int function GetCurrentMinute() global
    float hourWithMinutes = GetCurrentHourFloat()
    return GetMinutesFromHour(hourWithMinutes)
endFunction

int function GetCurrentHour() global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    return GameHour.GetValueInt()
endFunction

float function GetCurrentHourFloat() global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    return GameHour.GetValue()
endFunction

int function GetCurrentDay() global
    GlobalVariable GameDay = Game.GetFormEx(0x37) as GlobalVariable
    return GameDay.GetValueInt()
endFunction

int function GetCurrentMonth() global
    GlobalVariable GameMonth = Game.GetFormEx(0x36) as GlobalVariable
    return GameMonth.GetValueInt() + 1  ; starts at 0, ends at 11, the Getters/Setters are 1-12
endFunction

int function GetCurrentYear() global
    GlobalVariable GameYear = Game.GetFormEx(0x35) as GlobalVariable
    return GameYear.GetValueInt()
endFunction

int function GetDaysPassed() global
    GlobalVariable GameYear = Game.GetFormEx(0x39) as GlobalVariable
    return GameYear.GetValueInt()
endFunction

int function GetLastDayOfMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth)
endFunction

float function GetElapsedTimeBetweenTimes(float afStartTime, float afEndTime) global
    return afEndTime - afStartTime
endFunction

float function GetElapsedTimeSincePointInTime(float afPointInTime) global
    return now() - afPointInTime
endFunction

bool function IsLastDayOfMonth() global
    return GetCurrentDay() == GetLastDayOfMonth(GetCurrentMonth())
endFunction

bool function IsLastDayOfYear() global
    return GetCurrentMonth() == 12 && IsLastDayOfMonth()
endFunction

bool function SetGameHour(int aiGameHour) global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    GameHour.SetValueInt(aiGameHour)
endFunction

bool function ModGameHour(float afIncrementByHours) global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    GameHour.Mod(afIncrementByHours)
endFunction

int function GetMinutesFromHour(float aiHour) global
    ; 13.50 = 1:30 PM
    ; Get the minutes from the hour
    float minutesOfHourAsDecimal = aiHour - math.floor(aiHour) ; 0.50 if x.50

    int resultAsMinutes = math.floor(60 * minutesOfHourAsDecimal) ; convert the decimal into minutes (0.5 becomes 30, half an hour)

    ; DebugWithArgs("Utility::GetMinutesFromHour", aiHour, "Getting minutes from hour " + aiHour + " = " + resultAsMinutes + " minutes" + " ("+ "minutesOfHourAsDecimal: " + minutesOfHourAsDecimal + ")")

    return resultAsMinutes
endFunction

string function GetClockFormat(int aiHour, int aiMinutes = 0, string format = "12 Hour") global
    bool isTwelveHourClock = (format == "12 Hour" || format == "12h")

    if (isTwelveHourClock)
        int hourConverted = 0
        if (aiHour >= 0 && aiHour < 12) ; AM
            if (aiHour == 0)
                hourConverted = 12 ; 12 AM
            else
                hourConverted = aiHour ; No need to convert, already in the form of 1-11 AM
            endif
    
            return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " AM", ":00 AM")
        elseif (aiHour >= 12 && aiHour < 24) ; PM
            if (aiHour == 12)
                hourConverted = 12 ; 12 PM
            else
                hourConverted = aiHour - 12
            endif
    
            return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " PM", ":00 PM")
        endif

    else ; 24h
        string shownHour    = string_if (aiHour < 10, "0" + aiHour, aiHour)
        string shownMinutes = string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes)

        return shownHour + ":" + shownMinutes
    endif

endFunction

string function GetTimeAs12Hour(int aiHour, int aiMinutes = 0) global
    int hourConverted = 0
    if (aiHour >= 0 && aiHour < 12) ; AM
        if (aiHour == 0)
            hourConverted = 12 ; 12 AM
        else
            hourConverted = aiHour ; No need to convert, already in the form of 1-11 AM
        endif

        return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " AM", ":00 AM")
    elseif (aiHour >= 12 && aiHour < 24) ; PM
        if (aiHour == 12)
            hourConverted = 12 ; 12 PM
        else
            hourConverted = aiHour - 12
        endif

        return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " PM", ":00 PM")
    endif
endFunction

bool function IsLeapYear(int aiYear) global
    return (aiYear % 4 == 0 && (aiYear % 100 != 0 || aiYear % 400 == 0))
endFunction

bool function IsWeekend(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Loredas") || dayOfWeek == GetDayOfWeekByName("Sundas")
endFunction

bool function IsLoredas(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Loredas")
endFunction

bool function IsSundas(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Sundas")
endFunction

bool function IsWeekday(int aiDay, int aiMonth, int aiYear) global
    return !IsWeekend(aiDay, aiMonth, aiYear)
endFunction

int function CalculateDaysPassedFromDate(int aiDay, int aiMonth, int aiYear) global
    int daysInMonth = GetDaysOfMonth(aiMonth)

    if (daysInMonth == -1)
        return -1
    endif

    int totalDaysPassed = 0 ; All days of all months

    int month = 1
    while (month < aiMonth)
        totalDaysPassed += GetDaysOfMonth(month)
        month += 1
    endWhile

    ; DebugWithArgs("Utility::CalculateDaysPassedFromDate", aiDay + ", " + aiMonth + ", " + aiYear, "month: " + month + ", " + "totalDaysPassed: " + totalDaysPassed)

    ; Add days in the current month
    totalDaysPassed += aiDay

    ; Adjust for leap year if needed
    if (IsLeapYear(aiYear) && aiMonth > 2)
        totalDaysPassed += 1
    endif

    return totalDaysPassed
endFunction

int function GetDayOfWeekByName(string asDayOfWeekName) global
    if (asDayOfWeekName == "Sundas")
        return 1
    elseif (asDayOfWeekName == "Morndas")
        return 2
    elseif (asDayOfWeekName == "Tirdas")
        return 3
    elseif (asDayOfWeekName == "Middas")
        return 4
    elseif (asDayOfWeekName == "Turdas")
        return 5
    elseif (asDayOfWeekName == "Fredas")
        return 6
    elseif (asDayOfWeekName == "Loredas")
        return 7
    endif
endFunction

string function GetDayOfWeekName(int aiDayOfWeek) global
    if (aiDayOfWeek == 1)
        return "Sundas"
    elseif (aiDayOfWeek == 2)
        return "Morndas"
    elseif (aiDayOfWeek == 3)
        return "Tirdas"
    elseif (aiDayOfWeek == 4)
        return "Middas"
    elseif (aiDayOfWeek == 5)
        return "Turdas"
    elseif (aiDayOfWeek == 6)
        return "Fredas"
    elseif (aiDayOfWeek == 7)
        return "Loredas"
    endif
endFunction

string function GetDayOfWeekGregorianName(int aiDayOfWeek) global
    if (aiDayOfWeek == 1)
        return "Monday"
    elseif (aiDayOfWeek == 2)
        return "Tuesday"
    elseif (aiDayOfWeek == 3)
        return "Wednesday"
    elseif (aiDayOfWeek == 4)
        return "Thursday"
    elseif (aiDayOfWeek == 5)
        return "Friday"
    elseif (aiDayOfWeek == 6)
        return "Saturday"
    elseif (aiDayOfWeek == 7)
        return "Sunday"
    endif
endFunction

int function GetFirstDayOfWeek(int aiYear) global
    int daysOfWeek = 7 ; (Morndas, Tirdas, Middas, Turdas, Fredas, Loredas, Sundas)
    
    ; Assign the day of week for 4E 201
    int dayOfWeek4E201 = 3 ; Middas

    int dayOfWeek4EPassedYear = dayOfWeek4E201 ; Assume it's 4E 201 as default

    int startingYear = 201
    while (startingYear < aiYear)
        dayOfWeek4EPassedYear = (dayOfWeek4EPassedYear % daysOfWeek) + 1
        startingYear += 1
    endWhile

    return dayOfWeek4EPassedYear
endFunction

int function CalculateDayOfWeek(int aiDay, int aiMonth, int aiYear) global
    ; Constants
    int daysInWeek = 7

    ; Determine the starting day of the year
    int startingDay = GetFirstDayOfWeek(aiYear)

    ; Calculate total days passed from the beginning of the year
    int totalDaysPassed = CalculateDaysPassedFromDate(aiDay, aiMonth, aiYear)

    ; Determine the day of the week (1 for Morndas, 2 for Tirdas, ..., 7 for Sundas)
    int dayOfWeek = (((totalDaysPassed + startingDay - 1) % daysInWeek)) + 1

    ; DebugWithArgs("Utility::CalculateDayOfWeek", aiDay + ", " + aiMonth + ", " + aiYear, "startingDay: " + startingDay + ", totalDaysPassed: " + totalDaysPassed + ", dayOfWeek: " + dayOfWeek)

    return dayOfWeek
endFunction

int function GetDateFromDaysPassed(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    int currentDay = aiDay + aiDaysPassed
    int currentMonth = aiMonth
    int currentYear = aiYear

    while (currentDay > GetDaysOfMonth(currentMonth)) 
        currentDay -= GetDaysOfMonth(currentMonth)
        currentMonth += 1

        if (currentMonth > 12)
            currentYear += 1
            currentMonth = 1
        endif
    endWhile

    int struct = new_struct()
    SetStructMemberInt(struct, "day", currentDay)
    SetStructMemberInt(struct, "month", currentMonth)
    SetStructMemberInt(struct, "year", currentYear)

    return struct
endFunction

string function GetDateFormat(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, string format = "d/m/Y") global
    string formattedDate = ""

    if (format == "d/m/Y")
        string day      = string_if(aiDay < 10, "0" + aiDay, aiDay)
        string month    = string_if (aiMonth < 10, "0" + aiMonth, aiMonth)
        string year     = "4E " + aiYear

        formattedDate = day + "/" + month + "/" + year

    elseif (format == "D M Y")
        string day      = RPB_Utility.ToOrdinalNthDay(aiDay)
        string month    = RPB_Utility.GetMonthName(aiMonth)
        string year     = "4E " + aiYear

        formattedDate = day + " of " + month + ", " + year
    endif

    return formattedDate
endFunction

int function GetPreviousDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    if (aiDayOfWeek < GetDayOfWeekByName("Sundas") || aiDayOfWeek > GetDayOfWeekByName("Loredas"))
        return -10
    endif

    int dayOfWeekForPassedDate      = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    int dayOfWeekDifference         = aiDayOfWeek - dayOfWeekForPassedDate
    bool dayOfWeekIsPreviousWeek    = dayOfWeekDifference >= 0
    int daysBackward                = int_if (dayOfWeekIsPreviousWeek, -7 + dayOfWeekDifference, dayOfWeekDifference)

    int newDateForDayOfWeek = GetDateFromDaysPassed(aiDay, aiMonth, aiYear, daysBackward)
    int day      = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "day")
    int month    = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "month")
    int year     = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "year")

    int retval = new_struct()
    SetStructMemberInt(retval, "day", day)
    SetStructMemberInt(retval, "month", month)
    SetStructMemberInt(retval, "year", year)
    SetStructMemberInt(retval, "daysAgo", daysBackward)

    return retval
endFunction

int function GetNextDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    if (aiDayOfWeek < GetDayOfWeekByName("Sundas") || aiDayOfWeek > GetDayOfWeekByName("Loredas"))
        return -10
    endif

    int dayOfWeekForPassedDate = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    int dayOfWeekDifference     = aiDayOfWeek - dayOfWeekForPassedDate
    bool dayOfWeekIsNextWeek    = dayOfWeekDifference <= 0
    int daysForward             = int_if (dayOfWeekIsNextWeek, 7 + dayOfWeekDifference, dayOfWeekDifference)

    int newDateForDayOfWeek = GetDateFromDaysPassed(aiDay, aiMonth, aiYear, daysForward)
    int day      = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "day")
    int month    = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "month")
    int year     = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "year")

    int retval = new_struct()
    SetStructMemberInt(retval, "day", day)
    SetStructMemberInt(retval, "month", month)
    SetStructMemberInt(retval, "year", year)
    SetStructMemberInt(retval, "daysFromNow", daysForward)

    return retval
endFunction


string function GetMonthName(int aiMonth) global
    if (aiMonth == 1)
        return "Morning Star"
    elseif (aiMonth == 2)
        return "Sun's Dawn"
    elseif (aiMonth == 3)
        return "First Seed"
    elseif (aiMonth == 4)
        return "Rain's Hand"
    elseif (aiMonth == 5)
        return "Second Seed"
    elseif (aiMonth == 6)
        return "Midyear"
    elseif (aiMonth == 7)
        return "Sun's Height"
    elseif (aiMonth == 8)
        return "Last Seed"
    elseif (aiMonth == 9)
        return "Heartfire"
    elseif (aiMonth == 10)
        return "Frostfall"
    elseif (aiMonth == 11)
        return "Sun's Dusk"
    elseif (aiMonth == 12)
        return "Evening Star"
    endif

    return none
endFunction

int function GetMonthByName(string asMonthName) global
    if (asMonthName == "Morning Star")
        return 1
    elseif (asMonthName == "Sun's Dawn")
        return 2
    elseif (asMonthName == "First Seed")
        return 3
    elseif (asMonthName == "Rain's Hand")
        return 4
    elseif (asMonthName == "Second Seed")
        return 5
    elseif (asMonthName == "Midyear")
        return 6
    elseif (asMonthName == "Sun's Height")
        return 7
    elseif (asMonthName == "Last Seed")
        return 8
    elseif (asMonthName == "Heartfire")
        return 9
    elseif (asMonthName == "Frostfall")
        return 10
    elseif (asMonthName == "Sun's Dusk")
        return 11
    elseif (asMonthName == "Evening Star")
        return 12
    endif

    return 0
endFunction

bool function Is28DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 28
endFunction

bool function Is30DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 30
endFunction

bool function Is31DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 31
endFunction

string function ToOrdinalNthDay(int aiDay) global
    return aiDay + GetDayOrdinality(aiDay)
endFunction

string function GetDayOrdinality(int aiDay) global
    if (aiDay > 3 && aiDay < 21)
        return "th"
    endif

    int nthDayOrdinalValue = aiDay % 10

    if (nthDayOrdinalValue == 1)
        return "st"
    elseif (nthDayOrdinalValue == 2)
        return "nd"
    elseif (nthDayOrdinalValue == 3)
        return "rd"
    else
        return "th"
    endif
endFunction

; TODO: Fix weeks calculations
string function GetTimeFormatted(float afTime, bool abIncludeMinutes = false, bool abIncludeHours = true, bool abIncludeDays = true, bool abIncludeWeeks = true, bool abIncludeMonths = true, bool abIncludeYears = true, string asNullValue = "") global
    float timeGameTime  = afTime
    float timeHours     = ((timeGameTime - floor(timeGameTime)) / 0.0416)
    float timeMinutes   = (timeHours - floor(timeHours)) * 60
    float timeDays      = timeGameTime
    float timeMonths    = timeGameTime / 30
    float timeWeeks     = (timeGameTime / 7)
    float timeYears     = (timeDays / 365)

    string timeString = ""

    ; Only display Years, Months or Years
    if (abIncludeYears && floor(timeYears) >= 1)
        timeString = math.floor(timeYears) + " " + string_if (floor(timeYears) == 1, "Year", "Years")

        timeMonths = ((timeYears - floor(timeYears)) * 12)

        if (abIncludeMonths && floor(timeMonths) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeMonths) + " " + string_if (floor(timeMonths) == 1, "Month", "Months"))
        endif

        return timeString
    endif

    ; Only display Months or Months, Days
    if (abIncludeMonths && floor(timeMonths) >= 1)
        timeString = floor(timeMonths) + " " + string_if (floor(timeMonths) == 1, "Month", "Months")

        timeDays = ((timeMonths - floor(timeMonths)) * 30)
        timeWeeks = (floor(timeDays) % 30) / 7
  
        if (abIncludeWeeks && floor(timeWeeks) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeWeeks) + " " + string_if (floor(timeWeeks) == 1, "Week", "Weeks"))

        elseif (abIncludeDays && floor(timeDays) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days"))
        endif

        return timeString
    endif

    if (abIncludeWeeks && floor(timeWeeks) >= 1)
        timeString = floor(timeWeeks) + " " + string_if (floor(timeWeeks) == 1, "Week", "Weeks")

        timeDays = (timeWeeks - floor(timeWeeks)) * 7

        if (abIncludeDays && floor(timeDays) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days"))
        endif

        return timeString
    endif

    ; Only display Days or Days, Hours
    if (abIncludeDays && floor(timeDays) >= 1)
        timeHours = ((timeDays - floor(timeDays)) * 24)

        if (timeHours > 24)
            timeDays += 1
            timeHours -= 24
        endif

        timeString = floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days")

        if (abIncludeHours && floor(timeHours) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeHours) + " " + string_if (floor(timeHours) == 1, "Hour", "Hours"))
        endif

        return timeString
    endif

    ; Only display Hours or Hours, Minutes
    if (abIncludeHours && floor(timeHours) >= 1)
        timeString = floor(timeHours) + " " + string_if (floor(timeHours) == 1, "Hour", "Hours")

        timeMinutes = ((timeHours - floor(timeHours)) * 60)

        if (abIncludeMinutes && floor(timeMinutes) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeMinutes) + " " + string_if (floor(timeMinutes) == 1, "Minute", "Minutes"))
        endif

        return timeString
    endif

    ; Only display Minutes
    if (abIncludeMinutes && floor(timeMinutes) >= 1)
        timeString = floor(timeMinutes) + " " + string_if (floor(timeMinutes) == 1, "Minute", "Minutes")

        return timeString
    endif

    return asNullValue
endFunction

string function GetFormattedDate(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, bool abShowDayOfWeek = true, bool abShowDay = true, bool abShowTime = true, bool abShowYear = true) global
    string dayOfWeek    = GetDayOfWeekName(CalculateDayOfWeek(aiDay, aiMonth, aiYear))
    string hour         = GetClockFormat(aiHour, aiMinute)
    string dayOrdinal   = ToOrdinalNthDay(aiDay)
    string monthName    = GetMonthName(aiMonth)
    string yearString   = "4E " + aiYear

    string dateResult = ""

    if (abShowDayOfWeek)
        dateResult += dayOfWeek + ", "
    endif

    if (abShowTime)
        dateResult += hour + ", "
    endif

    if (abShowDay)
        dateResult += dayOrdinal + " of "
    endif

    dateResult += monthName + ", "

    if (abShowYear)
        dateResult += yearString
    endif

    return dateResult
    ; Fredas, 7:00 AM, 21st of Sun's Dusk, 4E 201
    ; return dayOfWeek + ", " + hour + ", " + dayOrdinal + " of " + monthName + ", " + yearString
endFunction

string function GetFormattedDate24Hours(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0) global

endFunction

string function GetCurrentDateFormatted() global
    int currentDay      = GetCurrentDay()
    int currentMonth    = GetCurrentMonth()
    int currentYear     = GetCurrentYear()
    float currentHour   = GetCurrentHourFloat()
    int minutesFromHour = GetMinutesFromHour(currentHour)

    return GetFormattedDate(currentDay, currentMonth, currentYear, floor(currentHour), minutesFromHour)
endFunction

string function GetNextDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    int nextDayOfWeek       = GetNextDayOfWeekFromDate(GetCurrentDay(), GetCurrentMonth(), GetCurrentYear(), GetDayOfWeekByName(asDayOfWeek))
    int day                 = GetStructMemberInt(nextDayOfWeek, "day")
    int month               = GetStructMemberInt(nextDayOfWeek, "month")
    int year                = GetStructMemberInt(nextDayOfWeek, "year")
    int daysTillDayOfWeek   = GetStructMemberInt(nextDayOfWeek, "daysFromNow")

    return GetFormattedDate(day, month, year, GetCurrentHour(), GetCurrentMinute(), abShowTime = abShowTime)
endFunction

string function GetPreviousDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    int previousDayOfWeek   = GetPreviousDayOfWeekFromDate(GetCurrentDay(), GetCurrentMonth(), GetCurrentYear(), GetDayOfWeekByName(asDayOfWeek))
    int day                 = GetStructMemberInt(previousDayOfWeek, "day")
    int month               = GetStructMemberInt(previousDayOfWeek, "month")
    int year                = GetStructMemberInt(previousDayOfWeek, "year")
    int daysFromDayOfWeek   = GetStructMemberInt(previousDayOfWeek, "daysAgo")

    return GetFormattedDate(day, month, year, GetCurrentHour(), GetCurrentMinute(), abShowTime = abShowTime)
endFunction


bool function PassTimeInDays(int aiPassByDays) global
    GlobalVariable GameDaysPassed = Game.GetFormEx(0x39) as GlobalVariable
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable

    int maxDays = GetMaxDayEventsPerUpdate()
    if (aiPassByDays > maxDays)
        DebugError("Utility::PassTimeInDays", "Asked to pass " + aiPassByDays + " days, more than the " + maxDays + " day bound: passing " + maxDays + ".")
        aiPassByDays = maxDays
    endif

    bool logging = IsDebuggingEnabled() ; the message below costs about ten natives a day: only build it when it will be logged

    int daysPassed = 0
    while (daysPassed < aiPassByDays)
        GameHour.Mod(24)
        Utility.Wait(0.01)

        if (logging)
            string currentDate = GetCurrentDay() + "/" + GetCurrentMonth() + "/" + GetCurrentYear()
            DebugWithArgs("Utility::PassTimeInDays", aiPassByDays, "Date: " + currentDate +  " at " + GetTimeAs12Hour(GetCurrentHour()) + " ("+ GetTimeAs12Hour(GetCurrentHour()) +", "+  ToOrdinalNthDay(GetCurrentDay()) +" of " + GetMonthName(GetCurrentMonth()) +")" + ", " + "GameDaysPassed: " + GameDaysPassed.GetValue())
        endif
        daysPassed += 1
    endWhile
    ; GameHour.Mod(-1) ; Take off one hour, for some reason, after passing the days, the time is incremented by 1h
endFunction


string function FormatFloat(float number) global
    string numberAsString       = number as string
    int decimalPlacePosition    = StringUtil.Find(numberAsString, ".")

    if (decimalPlacePosition == -1) 
        return numberAsString
    endif

    string wholePart            = StringUtil.Substring(numberAsString, 0, decimalPlacePosition)
    string decimalPart          = StringUtil.Substring(numberAsString, decimalPlacePosition + 1)

    int decimalLength = StringUtil.GetLength(decimalPart)
    int decimalsToUse = Min(2, decimalLength) as int

    string formattedNumber = wholePart + "." + StringUtil.Substring(decimalPart, 0, decimalsToUse)

    ; DebugParams(number + "," + numberAsString + ",", "number, numberAsString")
    return formattedNumber
endFunction

; ==========================================================
;                           Actions
; ==========================================================

function SendCourierDelivery(ReferenceAlias apItemAlias, Form akItem) global
    WICourierScript courierScript = RPB_Utility.GetCourierQuest()
    apItemAlias.ForceRefTo(Game.GetPlayer().PlaceAtMe(akItem))
    courierScript.AddAliasToContainer(apItemAlias)
endFunction

function ScheduleCourierDeliveryInGameTime(ReferenceAlias apItemAlias, Form akItem, float afTimeFromNow) global

endFunction

; ==========================================================
;                           Struct
; ==========================================================
;/
    int myStruct = struct( \ 
        "bool: (isImprisoned = false, isInCell = false) |" + \ 
        "string: () |" + \ 
        "Form[]: (prisons) |" \ 
    )

    GetStructMemberBool(myStruct, "isInCell")
/;

; int function struct(string apStructMembers, bool abRetain = false) global
;     int structObj = JMap.object()

;     if (abRetain)
;         JValue.retain(structObj, "struct")
;     endif

;     return structObj
; endFunction

int function new_struct(bool abRetain = false, string asStructType = "") global
    int structObj = JMap.object()

    if (abRetain)
        JValue.retain(structObj, asStructType)
    endif

    return structObj
endFunction

bool function GetStructMemberBool(int apStructObject, string asMemberName) global
    return JMap.getInt(apStructObject, asMemberName) as bool
endFunction

int function GetStructMemberInt(int apStructObject, string asMemberName) global
    return JMap.getInt(apStructObject, asMemberName)
endFunction

float function GetStructMemberFloat(int apStructObject, string asMemberName) global
    return JMap.getFlt(apStructObject, asMemberName)
endFunction

string function GetStructMemberString(int apStructObject, string asMemberName) global
    return JMap.getStr(apStructObject, asMemberName)
endFunction

Form function GetStructMemberForm(int apStructObject, string asMemberName) global
    return JMap.getForm(apStructObject, asMemberName)
endFunction

function SetStructMemberBool(int apStructObject, string asMemberName, bool value) global
    JMap.setInt(apStructObject, asMemberName, value as int)
endFunction

function SetStructMemberInt(int apStructObject, string asMemberName, int value) global
    JMap.setInt(apStructObject, asMemberName, value)
endFunction

function SetStructMemberFloat(int apStructObject, string asMemberName, float value) global
    JMap.setFlt(apStructObject, asMemberName, value)
endFunction

function SetStructMemberString(int apStructObject, string asMemberName, string value) global
    JMap.setStr(apStructObject, asMemberName, value)
endFunction

function SetStructMemberForm(int apStructObject, string asMemberName, Form value) global
    JMap.setForm(apStructObject, asMemberName, value)
endFunction

function DestroyStruct(int apStructObject) global
    if (apStructObject)
        JValue.release(apStructObject)
    endif
endFunction

function DestroyStructsOfType(string asStructType) global
    JValue.releaseObjectsWithTag(asStructType)
endFunction


; ==========================================================
;                    Benchmark Functions
; ==========================================================

float function StartBenchmark(bool condition = true) global
    if (condition)
        float startTime = Utility.GetCurrentRealTime()
        return startTime
    endif
endFunction

int function EndBenchmark(float startTime, string _message = "", bool condition = true) global
    if (condition)
        float endTime = Utility.GetCurrentRealTime()
        int elapsedTime = ((endTime - startTime) * 1000) as int
        base_log("BENCHMARK:", string_if (_message != "", _message + " ") + "execution took " + elapsedTime + " ms")
        return elapsedTime
    endif
endFunction


; ==========================================================
;                           Temporary
; ==========================================================

;/
    Temporary function
    Gets the Base Jail Door ID for the specified hold

    SDoorJail01 - 5E91D (Solitude) [Haafingar]
    WRJailDoor01 - A7613 (Whiterun) [Whiterun]
    ImpJailDoor01 - 40BB2 (Windhelm, Riften) [Eastmarch, The Rift]
    FarmhouseJailDoor01 - EC563 (Falkreath, Morthal, Dawnstar) [Falkreath, Hjaalmarch, The Pale]
/;
int function GetJailBaseDoorID(string hold) global
    if (hold == "Haafingar")
        return 0x5E91D

    elseif (hold == "Whiterun")
        return 0xA7613

    elseif (hold == "Windhelm" || hold == "The Rift")
        return 0x40BB2

    elseif (hold == "Falkreath" || hold == "Hjaalmarch" || hold == "The Pale")
        return 0xEC563
    endif
endFunction

ObjectReference function GetNearestJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    int i = 10

    Form doorRef = Game.GetFormEx(jailBaseDoorId)
    ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(doorRef, centerRef, radius)
    return _cellDoor

    ; while (i > 0)
    ;     ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(doorRef.GetBaseObject(), centerRef, radius)
    ;     if (_cellDoor)
    ;         return _cellDoor
    ;     endif

    ;     if (radius < 8000)
    ;         radius *= 2
    ;     endif
    ;     i -= 1
    ; endWhile

    return none
endFunction

ObjectReference function GetNearestJailDoorOfTypeEx(Form akJailBaseDoor, ObjectReference akCenterRef, float afRadius) global
    ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(akJailBaseDoor, akCenterRef, afRadius)
    return _cellDoor
endFunction

ObjectReference function GetRandomJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    Form doorRef = Game.GetFormEx(jailBaseDoorId)
    ObjectReference _cellDoor = Game.FindRandomReferenceOfTypeFromRef(doorRef, centerRef, radius)
    return _cellDoor
endFunction

function OpenMultipleDoorsOfType(int jailBaseDoorId, ObjectReference scanFromWhere, float radius) global
    int i = 10

    Form doorRef = Game.GetFormEx(jailBaseDoorId)

    while (i > 0)
        ObjectReference _cellDoor = Game.FindRandomReferenceOfTypeFromRef(doorRef, scanFromWhere, radius)
        bool isOpen = _cellDoor.GetOpenState() == 1 || _cellDoor.GetOpenState() == 2
        if (isOpen)
            OpenMultipleDoorsOfType(jailBaseDoorId, scanFromWhere, radius)
        endif

        if (_cellDoor)
            _cellDoor.SetOpen(true)
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile
endFunction

Actor function GetNearestActor(ObjectReference centerRef, float radius) global
    int i = 10

    while (i > 0)
        Actor _actor = Game.FindRandomActorFromRef(centerRef, radius)
        ; if (_actor && _actor.GetActorBase().GetSex() == 1 && _actor.GetFormID() != 0x14 && !_actor.IsChild())
        if (_actor && _actor.GetFormID() != 0x14 && !_actor.IsChild() && _actor.IsGuard())
            return _actor
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile

    return none
endFunction

Actor function GetNearestActorFromList(Actor akRef, Form[] akRefs) global
    float nearestRefDistance = GetInfinityDistance()
    int nearestRefIndex = -1
    int i = 0
    while (i < akRefs.Length)
        if (akRefs[i] != none)
            Actor akRefFromList = akRefs[i] as Actor
            float distanceToRef = akRefFromList.GetDistance(akRef)
            if (distanceToRef < nearestRefDistance)
                nearestRefDistance = distanceToRef
                nearestRefindex = i
            endif
        endif
        i += 1
    endWhile

    if (nearestRefIndex != -1)
        return akRefs[nearestRefIndex] as Actor
    endif

    return none
endFunction

Actor function GetNearbyActorFromRefWithPrototype(ObjectReference akCenterRef, ActorBase akPrototype, float afMaxRadius = 1000.0) global
    int tries       = 0
    int maxTries    = 30
    float radius    = 50

    while (tries < maxTries)
        Actor scannedActor = Game.FindRandomActorFromRef(akCenterRef, radius)
        bool conditions = scannedActor.GetActorBase() == akPrototype

        if (conditions)
            return scannedActor
        endif

        if (radius < afMaxRadius)
            radius += 100
        endif

        tries += 1
    endWhile

    return none
endFunction

Actor function GetNearbyGuardForFactionFromRef( \
    ObjectReference akCenterRef, \ 
    Faction akCrimeFaction = none, \ 
    float afMinRadius = 50.0, \ 
    float afMaxRadius = 1000.0, \ 
    float afIncreaseRadiusBy = 100.0, \
    int aiMaxScans = 30 \ 
) global
    int scans    = 0
    float radius = afMinRadius

    while (scans < aiMaxScans)
        Actor scannedActor = Game.FindRandomActorFromRef(akCenterRef, radius)

        bool conditions = \ 
            scannedActor.GetFormID() != 0x14 && \
            !scannedActor.IsChild() && \
            scannedActor.IsGuard()

        if (conditions)
            return scannedActor
        endif

        if (radius < afMaxRadius)
            radius += afIncreaseRadiusBy
        endif

        scans += 1
    endWhile

    return none
endFunction

Actor function GetNearestGuard(ObjectReference centerRef, float radius, ObjectReference exclude) global
    int i = 30

    while (i > 0)
        Actor _actor = Game.FindRandomActorFromRef(centerRef, radius)
        bool notPlayer = _actor.GetFormID() != 0x14
        if (_actor && notPlayer && !_actor.IsChild() && _actor.IsGuard() && _actor != exclude)
            return _actor
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile

    return none
endFunction

bool function IsActorNearReference(Actor akActor, ObjectReference akReference, float radius = 80.0) global
    ObjectReference referenceToFind = Game.FindClosestReferenceOfTypeFromRef(akReference.GetBaseObject(), akActor, radius)
    if (referenceToFind)
        return true
    endif

    return false
endFunction


;/
    Gets whether or not aiChance is in the specified range

    @aiValue: the value to check
    @aiMin: the minimum starting point
    @aiMax: the range specified

    returns true if aiValue is in the range
    returns false if it's not
/;
bool function IsWithin(int aiValue, int aiMin, int aiMax, bool abMinInclusive = true, bool abMaxInclusive = true) global
    return bool_if(abMinInclusive && abMaxInclusive, (aiValue >= aiMin && aiValue <= aiMax), \
            bool_if(abMinInclusive, (aiValue >= aiMin && aiValue < aiMax), \
            bool_if(abMaxInclusive, (aiValue > aiMin && aiValue <= aiMax))) \
    )
    ;return (aiChance >= aiMin && aiChance <= aiMax)
endfunction


string function __internal_GetMapElement( \
    int map, \
    string paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    ;/ const /; int VALUE_TYPE_NO_VALUE = 0
    ;/ const /; int VALUE_TYPE_NONE     = 1
    ;/ const /; int VALUE_TYPE_INT      = 2
    ;/ const /; int VALUE_TYPE_FLOAT    = 3
    ;/ const /; int VALUE_TYPE_FORM     = 4
    ;/ const /; int VALUE_TYPE_OBJECT   = 5
    ;/ const /; int VALUE_TYPE_STRING   = 6

    bool isIntValue     = JMap.valueType(map, paramKey) == VALUE_TYPE_INT
    bool isFloatValue   = JMap.valueType(map, paramKey) == VALUE_TYPE_FLOAT
    bool isStringValue  = JMap.valueType(map, paramKey) == VALUE_TYPE_STRING
    bool isFormValue    = JMap.valueType(map, paramKey) == VALUE_TYPE_FORM
    bool isObjValue     = JMap.valueType(map, paramKey) == VALUE_TYPE_OBJECT

    if (isStringValue)
        string paramValueStr = JMap.getStr(map, paramKey)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValueFlt = JMap.getFlt(map, paramKey)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValueInt = JMap.getInt(map, paramKey)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValueObj = JMap.getObj(map, paramKey)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValueForm = JMap.getForm(map, paramKey)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    else ; Might never reach here because it gets evaluated as int
        bool paramValueBool = JMap.getInt(map, paramKey)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetIntegerMapElement( \
    int map, \
    int paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JIntMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JIntMap.getInt(map, paramKey) as bool
    int paramValueInt = JIntMap.getInt(map, paramKey)
    float paramValueFlt = JIntMap.getFlt(map, paramKey)
    string paramValueStr = JIntMap.getStr(map, paramKey)
    int paramValueObj = JIntMap.getObj(map, paramKey)
    Form paramValueForm = JIntMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetFormMapElement( \
    int map, \
    Form paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JFormMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JFormMap.getInt(map, paramKey) as bool
    int paramValueInt = JFormMap.getInt(map, paramKey)
    float paramValueFlt = JFormMap.getFlt(map, paramKey)
    string paramValueStr = JFormMap.getStr(map, paramKey)
    int paramValueObj = JFormMap.getObj(map, paramKey)
    Form paramValueForm = JFormMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetArrayElement( \
    int array, \
    int index, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int arrayLength = JArray.count(array)

    if (arrayLength == 0)
        return ""
    endif

    bool paramValueBool = JArray.getInt(array, index) as bool
    int paramValueInt = JArray.getInt(array, index)
    float paramValueFlt = JArray.getFlt(array, index)
    string paramValueStr = JArray.getStr(array, index)
    int paramValueObj = JArray.getObj(array, index)
    Form paramValueForm = JArray.getForm(array, index)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return index + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return index + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return index + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return index + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return index + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return index + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetIndentLevel(int indentLevel) global
    string output
    if (indentLevel > 1)
        int currentIndentLevel = 0
        while (currentIndentLevel != indentLevel)
            output += "    "
            currentIndentLevel += 1
        endWhile
    endif

    return output
endFunction

string function GetContainerList( \
    int _container, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    string paramOutput

    int containerLength = JValue.count(_container)
    bool isArray = JValue.isArray(_container)

    if (containerLength == 0)
        return string_if (!isArray, "{}", "[]")
    endif

    int i = 0
    while (i < containerLength)
        ; Add indentation before getting the element
        paramOutput += __internal_GetIndentLevel(indentLevel)
        string elementSpacing = "\n" + string_if(i != containerLength - 1, "\t")
        
        if (JValue.isMap(_container))
            string paramKey = JMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeStringFilter != "" && StringUtil.Find(paramKey, includeStringFilter) != -1
            bool hasExcludeFilter = excludeStringFilter != "" && StringUtil.Find(paramKey, excludeStringFilter) != -1

            if (hasIncludeFilter || includeStringFilter == "")
                paramOutput += __internal_GetMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (JValue.isIntegerMap(_container))
            int paramKey = JIntMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeIntegerFilter != -1 && paramKey == includeIntegerFilter
            bool hasExcludeFilter = excludeIntegerFilter != -1 && paramKey == excludeIntegerFilter

            if ((hasIncludeFilter && !hasExcludeFilter) || (!hasIncludeFilter && !hasExcludeFilter))
                paramOutput += __internal_GetIntegerMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (JValue.isFormMap(_container))
            Form paramKey = JFormMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeFormFilter != none && paramKey == includeFormFilter
            bool hasExcludeFilter = excludeFormFilter != none && paramKey == excludeFormFilter

            if ((hasIncludeFilter && !hasExcludeFilter) || (!hasIncludeFilter && !hasExcludeFilter))
                paramOutput += __internal_GetFormMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (isArray)
            int index = i
            paramOutput += __internal_GetArrayElement( \
                _container, \
                index, \
                includeStringFilter = includeStringFilter, \
                excludeStringFilter = excludeStringFilter, \
                includeIntegerFilter = includeIntegerFilter, \
                excludeIntegerFilter = excludeIntegerFilter, \
                includeFormFilter = includeFormFilter, \
                excludeFormFilter = excludeFormFilter, \
                indentLevel = indentLevel + 1 \
            ) + elementSpacing
        endif

        i += 1
    endWhile

    if (paramOutput == "")
        return string_if (!isArray, "{}", "[]")
    endif

    ; Add indentation after getting the element
    paramOutput += __internal_GetIndentLevel(indentLevel)

    ; EndBenchmark(start, "GetContainerList [Length: "+ containerLength +", indentLevel: "+ indentLevel +"]")
    return string_if (!isArray, "{\n\t" + paramOutput + "}", "[\n\t" + paramOutput + "]")
endFunction