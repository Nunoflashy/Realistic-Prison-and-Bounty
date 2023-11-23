Scriptname RPB_Prison extends ReferenceAlias  

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

; ==========================================================
;                     Script References
; ==========================================================

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property Arrest
    RealisticPrisonAndBounty_Arrest function get()
        return Config.Arrest
    endFunction
endProperty


RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return Config.MiscVars
    endFunction
endProperty

; ==========================================================
;                       Prison Settings
; ==========================================================
;/
    These settings are retrieved directly through Config, which retrieves them
    from the MCM menu as soon as they are changed, so they are always up to date.
/;

;                           Jail
; ==========================================================

int property GuaranteedPayableBounty
    int function get()
        return Config.GetJailGuaranteedPayableBounty(Hold)
    endFunction
endProperty

int property MaximumPayableBounty
    int function get()
        return Config.GetJailMaximumPayableBounty(Hold)
    endFunction
endProperty

int property MaximumPayableBountyChance
    int function get()
        return Config.GetJailMaximumPayableChance(Hold)
    endFunction
endProperty

int property BountyExchange
    int function get()
        return Config.GetJailBountyExchange(Hold)
    endFunction
endProperty

int property BountyToSentence
    int function get()
        return Config.GetJailBountyToSentence(Hold)
    endFunction
endProperty

int property MinimumSentence
    int function get()
        return Config.GetJailMinimumSentence(Hold)
    endFunction
endProperty

int property MaximumSentence
    int function get()
        return Config.GetJailMaximumSentence(Hold)
    endFunction
endProperty

int property CellSearchThoroughness
    int function get()
        return Config.GetJailCellSearchThoroughness(Hold)
    endFunction
endProperty

string property CellLockLevel
    string function get()
        return Config.GetJailCellDoorLockLevel(Hold)
    endFunction
endProperty

bool property FastForward
    bool function get()
        return Config.IsJailFastForwardEnabled(Hold)
    endFunction
endProperty

int property DayToFastForwardFrom
    int function get()
        return Config.GetJailFastForwardDay(Hold)
    endFunction
endProperty

string property HandleSkillLoss
    string function get()
        return Config.GetJailHandleSkillLoss(Hold)
    endFunction
endProperty

int property DayToStartLosingSkills
    int function get()
        return Config.GetJailDayToStartLosingSkills(Hold)
    endFunction
endProperty

int property ChanceToLoseSkills
    int function get()
        return Config.GetJailChanceToLoseSkillsDaily(Hold)
    endFunction
endProperty

float property RecognizedCriminalPenalty
    float function get()
        return Config.GetJailRecognizedCriminalPenalty(Hold)
    endFunction
endProperty

float property KnownCriminalPenalty
    float function get()
        return Config.GetJailKnownCriminalPenalty(Hold)
    endFunction
endProperty

int property MinimumBountyToTriggerCriminalPenalty
    int function get()
        return Config.GetJailBountyToTriggerCriminalPenalty(Hold)
    endFunction
endProperty

;                           Release
; ==========================================================

bool property EnableReleaseFees
    bool function get()
        return Config.IsJailReleaseFeesEnabled(Hold)
    endFunction
endProperty

int property ReleaseFeesChanceForEvent
    int function get()
        return Config.GetReleaseChanceForReleaseFeesEvent(Hold)
    endFunction
endProperty

int property MinimumBountyToOweReleaseFees
    int function get()
        return Config.GetReleaseBountyToOweFees(Hold)
    endFunction
endProperty

float property ReleaseFeesOfCurrentBounty
    float function get()
        return Config.GetReleaseReleaseFeesFromBounty(Hold)
    endFunction
endProperty

int property ReleaseFees
    int function get()
        return Config.GetReleaseReleaseFeesFlat(Hold)
    endFunction
endProperty

int property DaysGivenToPayReleaseFees
    int function get()
        return Config.GetReleaseDaysGivenToPayReleaseFees(Hold)
    endFunction
endProperty

bool property EnableItemRetention
    bool function get()
        return Config.IsItemRetentionEnabledOnRelease(Hold)
    endFunction
endProperty

int property MinimumBountyToRetainItems
    int function get()
        return Config.GetReleaseBountyToRetainItems(Hold)
    endFunction
endProperty

bool property AutoRedressOnRelease
    bool function get()
        return Config.IsAutoDressingEnabledOnRelease(Hold)
    endFunction
endProperty

;                           Escape
; ==========================================================

float property EscapeBountyOfCurrentBounty
    float function get()
        return Config.GetEscapedBountyFromCurrentArrest(Hold)
    endFunction
endProperty

int property EscapeBounty
    int function get()
        return Config.GetEscapedBountyFlat(Hold)
    endFunction
endProperty

bool property AccountForTimeServedOnEscape
    bool function get()
        return Config.IsTimeServedAccountedForOnEscape(Hold)
    endFunction
endProperty

bool property FriskUponCapturedOnEscape
    bool function get()
        return Config.ShouldFriskOnEscape(Hold)
    endFunction
endProperty

bool property StripUponCapturedOnEscape
    bool function get()
        return Config.ShouldStripOnEscape(Hold)
    endFunction
endProperty

;                           Infamy
; ==========================================================

bool property EnableInfamy
    bool function get()
        return Config.IsInfamyEnabled(Hold)
    endFunction
endProperty

int property InfamyRecognizedThreshold
    int function get()
        return Config.GetInfamyRecognizedThreshold(Hold)
    endFunction
endProperty

int property InfamyKnownThreshold
    int function get()
        return Config.GetInfamyKnownThreshold(Hold)
    endFunction
endProperty

float property InfamyGainedDailyOfCurrentBounty
    float function get()
        return Config.GetInfamyGainedDailyFromArrestBounty(Hold)
    endFunction
endProperty

int property InfamyGainedDaily
    int function get()
        return Config.GetInfamyGainedDaily(Hold)
    endFunction
endProperty

float property InfamyGainModifierRecognized
    float function get()
        return Config.GetInfamyGainModifier(Hold, "Recognized")
    endFunction
endProperty

float property InfamyGainModifierKnown
    float function get()
        return Config.GetInfamyGainModifier(Hold, "Known")
    endFunction
endProperty

;                          Frisking
; ==========================================================

bool property AllowFrisking
    bool function get()
        return Config.IsFriskingEnabled(Hold)
    endFunction
endProperty

int property MinimumBountyForFrisking
    int function get()
        return Config.GetFriskingBountyRequired(Hold)
    endFunction
endProperty

int property FriskingThoroughness
    int function get()
        return Config.GetFriskingThoroughness(Hold)
    endFunction
endProperty

bool property ConfiscateStolenItemsOnFrisk
    bool function get()
        return Config.IsFriskingStolenItemsConfiscated(Hold)
    endFunction
endProperty

bool property StripIfStolenItemsFoundOnFrisk
    bool function get()
        return Config.IsFriskingStripSearchWhenStolenItemsFound(Hold)
    endFunction
endProperty

int property MinimumNumberOfStolenItemsRequiredToStripOnFrisk
    int function get()
        return Config.GetFriskingStolenItemsRequiredForStripping(Hold)
    endFunction
endProperty

;                         Stripping
; ==========================================================

bool property AllowStripping
    bool function get()
        return Config.IsStrippingEnabled(Hold)
    endFunction
endProperty

string property HandleStrippingOn
    string function get()
        return Config.GetStrippingHandlingCondition(Hold)
    endFunction
endProperty

int property MinimumBountyToStrip
    int function get()
        return Config.GetStrippingMinimumBounty(Hold)
    endFunction
endProperty

int property MinimumViolentBountyToStrip
    int function get()
        return Config.GetStrippingMinimumViolentBounty(Hold)
    endFunction
endProperty

int property MinimumSentenceToStrip
    int function get()
        return Config.GetStrippingMinimumSentence(Hold)
    endFunction
endProperty

int property StrippingThoroughness
    int function get()
        return Config.GetStrippingThoroughness(Hold)
    endFunction
endProperty

int property StrippingThoroughnessModifier
    int function get()
        return Config.GetStrippingThoroughnessBountyModifier(Hold)
    endFunction
endProperty

;                        Clothing
; ==========================================================

bool property AllowClothing
    bool function get()
        return Config.IsClothingEnabled(Hold)
    endFunction
endProperty

string property HandleClothingOn
    string function get()
        return Config.GetClothingHandlingCondition(Hold)
    endFunction
endProperty

int property MaximumBountyClothing
    int function get()
        return Config.GetClothingMaximumBounty(Hold)
    endFunction
endProperty

int property MaximumViolentBountyClothing
    int function get()
        return Config.GetClothingMaximumViolentBounty(Hold)
    endFunction
endProperty

int property MaximumSentenceClothing
    int function get()
        return Config.GetClothingMaximumSentence(Hold)
    endFunction
endProperty

bool property ClotheWhenDefeated
    bool function get()
        return Config.IsClothedOnDefeat(Hold)
    endFunction
endProperty

string property ClothingOutfit
    string function get()
        return Config.GetClothingOutfit(Hold)
    endFunction
endProperty

;                          Outfit
; ==========================================================

string property OutfitName
    string function get()
        return Config.GetClothingOutfit(Hold)
    endFunction
endProperty

Form property OutfitPartHead
    Form function get()
        return Config.GetOutfitPart(Hold, "Head")
    endFunction
endProperty

Form property OutfitPartBody
    Form function get()
        return Config.GetOutfitPart(Hold, "Body")
    endFunction
endProperty

Form property OutfitPartHands
    Form function get()
        return Config.GetOutfitPart(Hold, "Hands")
    endFunction
endProperty

Form property OutfitPartFeet
    Form function get()
        return Config.GetOutfitPart(Hold, "Feet")
    endFunction
endProperty

bool property IsOutfitConditional
    bool function get()
        return Config.IsClothingOutfitConditional(Hold)
    endFunction
endProperty

int property OutfitMinimumBounty
    int function get()
        return Config.GetClothingOutfitMinimumBounty(Hold)
    endFunction
endProperty

int property OutfitMaximumBounty
    int function get()
        return Config.GetClothingOutfitMaximumBounty(Hold)
    endFunction
endProperty

; ==========================================================

; ==========================================================
;                        Prison Config
; ==========================================================

Location __prisonLocation
Location property PrisonLocation
    Location function get()
        return __prisonLocation
    endFunction
endProperty

Faction __prisonFaction
Faction property PrisonFaction
    Faction function get()
        return __prisonFaction
    endFunction
endProperty

string __hold
string property Hold
    string function get()
        return __hold
    endFunction
endProperty

; ==========================================================
;                     Prison Properties
; ==========================================================

RPB_Prisoner[] __prisoners
RPB_Prisoner[] property Prisoners
    RPB_Prisoner[] function get()
        return self.GetPrisoners()
    endFunction
endProperty
 
; ==========================================================
;                         Prisoners
; ==========================================================

function SetSentence(RPB_Prisoner akPrisoner, int aiSentence = 0)
    akPrisoner.SetSentence(aiSentence)
endFunction

int function GetRandomSentence(int aiMinSentence, int aiMaxSentence)
    return Utility.RandomInt( \
        Min(aiMinSentence, self.MinimumSentence) as int, \
        Min(aiMaxSentence, self.MaximumSentence) as int \
    )
endFunction

bool function HasPrisoners(RPB_JailCell akPrisonCell = none)

endFunction

bool function HasFemalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyFemales = false)

endFunction

bool function HasMalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyMales = false)

endFunction

RPB_Prisoner[] function GetPrisoners(RPB_JailCell akPrisonCell = none)

endFunction

RPB_Prisoner[] function GetFemalePrisoners(RPB_JailCell akPrisonCell = none)

endFunction

RPB_Prisoner[] function GetMalePrisoners(RPB_JailCell akPrisonCell = none)
    
endFunction

;                         Escape
; ==========================================================

function TriggerEscape(RPB_Prisoner akPrisoner)

endFunction

; ==========================================================
;                          Cell
; ==========================================================

RPB_JailCell[] function GetEmptyCells()
    ; Prison_GetInt("Cell 01")
    ; Get all Prisoners from Cell 01
    ; If no prisoners, the cell is empty, add it to an array
    ; do the same for the remaining cells
endFunction

; Available does not mean empty, if the cell has two beds and one prisoner, it is considered available, if it has two beds and two prisoners, it's not available.
; RPB_JailCell should have a property determing if the cell is available: IsAvailable, and another IsEmpty, etc
RPB_JailCell[] function GetAvailableCells()
    ; Iterate through all the cells in the prison
    ; Get the beds from each cell
    ; Get the number of prisoners from each cell
    ; If the number of prisoners is less than the number of beds, it is available, if it's equal or more, then it is not available
endFunction

RPB_JailCell[] function GetCellsWithFemalePrisoners()
    ; Iterate through all the cells in the prison
    ; Get each prisoner from each cell
    ; Determine the sex of the prisoner
    ; Store the prisoner's gender, or just a bool determining if it's female or male and set to true
    ; If all the prisoners are the same sex, this cell only has female prisoners
endFunction

RPB_JailCell[] function GetCellsWithMalePrisoners()
    ; Iterate through all the cells in the prison
    ; Get each prisoner from each cell
    ; Determine the sex of the prisoner
    ; Store the prisoner's gender, or just a bool determining if it's female or male and set to true
    ; If all the prisoners are the same sex, this cell only has male prisoners
endFunction

RPB_JailCell[] function GetCellsWithMixedPrisoners()
    ; Iterate through all the cells in the prison
    ; Get each prisoner from each cell
    ; Determine the sex of the prisoner
    ; Store the prisoner's gender, or just a bool determining if it's female or male and set to true
    ; If all the prisoners are not the same sex, this cell has both male and female prisoners
endFunction

; ==========================================================

function AwaitPrisonersRelease()
    int prisonerCount = 0

    int i = 0
    while (i < checkedPrisoners.Length)
        RPB_Prisoner currentPrisoner = checkedPrisoners[i]

        if (currentPrisoner && !currentPrisoner.IsEffectActive)
            prisonerCount += 1
            ; Maybe take into account possible bounty gain and infamy updates

            if (currentPrisoner.IsSentenceServed)
                ; Release Prisoner
                Debug(none, "Prison::AwaitPrisonersRelease", "Released Prisoner:  " + currentPrisoner + currentPrisoner.GetPrisoner())
                currentPrisoner.Release()
                checkedPrisoners[i] = none
            else
                ; int timeServedDays  = currentPrisoner.GetTimeServed("Days")
                ; int timeLeftDays    = currentPrisoner.GetTimeLeftInSentence("Days")
                ; Debug(none, "Prison::AwaitPrisonersRelease", "Prisoner:  " + currentPrisoner.GetActor() + " has not served their sentence yet ("+ timeServedDays + " days served, " +  timeLeftDays +" days left).")
                Debug(none, "Prison::AwaitPrisonersRelease", currentPrisoner + " " + currentPrisoner.GetActor() + " ("+ currentPrisoner.GetSex() +")" + " has not served their sentence yet in "+ Hold +".")
            endif
        endif
        i += 1
    endWhile
    
    ; Debug(none, "Prison::AwaitPrisonersRelease", "Checked Prisoners in " + Hold + ": " + prisonerCount)
    Debug(none, "Prison::AwaitPrisonersRelease", "Awaiting release for " + prisonerCount + " prisoners in " + Hold)
endFunction

function AwaitPrisonersQueuedImprisonment()
    if (isProcessingQueuedPrisonersForImprisonment)
        return
    endif

    int i = 0
    while (i < queuedPrisonersForImprisonment.Length)
        if (queuedPrisonersForImprisonment[i] != none)
            queuedPrisonersForImprisonment[i].Imprison()    ; Imprison this Prisoner
            queuedPrisonersForImprisonment[i] = none        ; Remove from Queue
        endif
        Utility.Wait(0.2)
        i += 1
    endWhile
endFunction

; ==========================================================
;                          Events
; ==========================================================

event OnPrisonPeriodicUpdate()
    self.AwaitPrisonersQueuedImprisonment() ; Delayed Imprisonment for registered Prisoners
    self.AwaitPrisonersRelease()            ; Keep checking for Prisoners to Release

    Debug(none, "Prison::OnPrisonPeriodicUpdate", "Prisoners in " + Hold + ": " + Prisoners.Length)

    ; ; TODO: If all the prisoners do not require processing anymore, unregister the update here

    ; Debug(none, "Prison::OnPrisonPeriodicUpdate", "Prisoners in " + Hold + ": " + prisonerCount)
endEvent

event OnPrisonerTimeElapsed(RPB_Prisoner akPrisoner)

endEvent

event OnPrisonerDying(RPB_Prisoner akPrisoner, Actor akKiller)
    
endEvent

event OnPrisonerDeath(RPB_Prisoner akPrisoner, Actor akKiller)

endEvent

event OnPrisonerReleased(RPB_Prisoner akPrisoner)

endEvent

event OnGuardDeath(RPB_Guard akGuard, Actor akKiller)

endEvent

event OnCellDoorOpen(RPB_JailCell akPrisonCell, Actor akOpener)

endEvent

event OnCellDoorClosed(RPB_JailCell akPrisonCell, Actor akCloser)
    
endEvent


; ==========================================================
;                          Management
; ==========================================================

; Temporary, to hold periodically updates prisoners for now
RPB_Prisoner[] checkedPrisoners
int checkedPrisonersIndex

function ProcessPrisonerState(RPB_Prisoner akPrisoner)
    if (self.EnableInfamy)
        akPrisoner.UpdateInfamy()
    endif

    akPrisoner.UpdateDaysImprisoned()
    ; akPrisoner.DEBUG_ShowPrisonInfo()
    self.DEBUG_ShowPrisonerSentenceInfo(akPrisoner, true)
    akPrisoner.RegisterLastUpdate()

endFunction

event OnInit()
    ; Temporary, to hold periodically updates prisoners for now
    checkedPrisoners        = new RPB_Prisoner[128]
    checkedPrisonersIndex   = 0

    __prisoners             = new RPB_Prisoner[128]
    __prisonersIndex        = 0


    Debug(none, "Prison::OnInit", "OnInit PRISON")

    MiscVars.CreateStringMap("prison/cell")
    MiscVars.CreateStringMap("prison/cell/door")
endEvent

event OnUpdateGameTime()
    __isReceivingUpdates = true
    __isAwaitingUpdateForGameTime = false
    
    self.OnPrisonPeriodicUpdate()

    RegisterForSingleUpdateGameTime(5.0)
endEvent

function ConfigurePrison( \
    Location akLocation, \
    Faction akFaction, \
    string asHold \
)

    __prisonLocation    = akLocation
    __prisonFaction     = akFaction
    __hold              = asHold

    __isInitialized     = true

    Debug(self.GetOwningQuest(), "Prison::ConfigurePrison", "Prison Location: " + PrisonLocation + ", Prison Faction: " + PrisonFaction + ", Prison Hold: " + Hold)
endFunction

function AddPrisonCell(RPB_JailCell akPrisonCell)

endFunction

; Return type later to be changed to RPB_PrisonCell
ObjectReference function GetRandomPrisonCell(bool abPrioritizeEmptyCells = true)
    return Config.GetRandomJailMarker(Hold)
endFunction

ObjectReference function GetPrisonerCell(RPB_Prisoner akPrisoner)
    ; Search in the prison cell map for the prisoner and get their cell
    ; OR - search in the prisoner map through a key which will be "Cell"
    
    ObjectReference prisonerCell = MiscVars.GetReference("["+ akPrisoner.GetPrisoner().GetFormID() +"]Cell", "Prison/" + Hold + "/Prisoner/Cell") ; something like this?
    ; This will allow a 1:N relation, 1 Cell to N Prisoners
    ; [20]Cell, [80]Cell, etc...


    if (!prisonerCell)
        ; Error out here or warning
    endif

    return prisonerCell
endFunction

; Return type later to be changed to RPB_CellDoor
; akPrisonCell to be changed to RPB_PrisonCell
ObjectReference function GetCellDoor(ObjectReference akPrisonCell)
    ; First try to retrieve the cell door from a local map (to be created)
    ; If the form is already in a map, this not only allows faster retrieval, but also processing without the Player being present in the prison location (useful for NPC imprisonment)
    ; Map's key will be the prison cell

    ObjectReference cellDoorInMap = MiscVars.GetReference(akPrisonCell.GetFormID(), "prison/cell/door")
    if (cellDoorInMap)
        Debug(self.GetOwningQuest(), "Prison::GetCellDoor", "Retrieved Cell Door through map: " + cellDoorInMap)
        return cellDoorInMap
    endif

    ; Otherwise, scan the area and get the nearest door to the cell, and add it to the map if it doesn't exist yet
    ObjectReference cellDoor = GetNearestJailDoorOfType(GetJailBaseDoorID(Hold), akPrisonCell, 4000)
    Debug(self.GetOwningQuest(), "Prison::GetCellDoor", "Retrieved Cell Door through scanning the cell: " + cellDoor)
    MiscVars.SetReference(akPrisonCell.GetFormID(), cellDoor, "prison/cell/door")

    return cellDoor
endFunction

function RegisterForPrisonPeriodicUpdate(RPB_Prisoner akPrisoner)
    Debug(none, "Prison::RegisterForPrisonPeriodicUpdate", "Called RegisterForPrisonPeriodicUpdate()")
    ; Add this prisoner to the list of prisoners to check periodically
    if (!akPrisoner.IsEnabledForBackgroundUpdates)
        checkedPrisoners[checkedPrisonersIndex] = akPrisoner
        Debug(none, "Prison::RegisterForPrisonPeriodicUpdate", "Added Prisoner to check for updates: " + checkedPrisoners[checkedPrisonersIndex] + ", index: " + checkedPrisonersIndex)
        checkedPrisonersIndex += 1
        akPrisoner.IsEnabledForBackgroundUpdates = true
    endif

    __isReceivingUpdates = true
    self.RegisterForSingleUpdateGameTime(5.0)
endFunction

;/
    Binds the actor to an instance of RPB_Prisoner,
    giving us the prisoner state of the Actor bound to this reference.

    Used when this Actor is a Prisoner, lasts until Release or Escape.

    This function is used inside RPB_Prisoner, since there is no other way to obtain
    a reference to the script as of now.

    RPB_Prisoner    @akPrisonerRef: The Prisoner reference to bind to the Actor.
    Actor           @akActor: The actor to be registered into prison.
/;
bool function RegisterPrisoner(RPB_Prisoner akPrisonerRef, Actor akActor)
    string containerKey = "Prisoner["+ akActor.GetFormID() +"]"
    RPB_ActiveMagicEffectContainer prisonerList = Config.MainAPI as RPB_ActiveMagicEffectContainer

    prisonerList.AddAt(akPrisonerRef, containerKey)
    __prisoners[__prisonersIndex] = akPrisonerRef

    Debug(none, "Prison::RegisterPrisoner", "Added Actor " + akActor + " to the prisoner list " + akPrisonerRef + " with key: " + containerKey + " for prison " + self.Hold)
    return prisonerList.GetAt(containerKey) == akPrisonerRef ; Did it register successfully?
endFunction

;/
    Removes the Actor bound to @akPrisonerRef from its currently bound instance of RPB_Prisoner.

    Used when this Actor is a Prisoner.

    RPB_Prisoner   @akPrisonerRef: The prisoner to be removed from prison.
/;
function UnregisterPrisoner(RPB_Prisoner akPrisonerRef)
    string containerKey = "Prisoner["+ akPrisonerRef.GetPrisoner().GetFormID() +"]"

    if (akPrisonerRef)
        RPB_ActiveMagicEffectContainer prisonerList = Config.MainAPI as RPB_ActiveMagicEffectContainer
        ; TODO: remove from __prisoners
        prisonerList.Remove(containerKey)
    endif
endFunction

RPB_Prisoner function GetPrisonerReference(Actor akPrisoner)
    RPB_ActiveMagicEffectContainer prisonerList = Config.MainAPI as RPB_ActiveMagicEffectContainer

    string listKey = "Prisoner["+ akPrisoner.GetFormID() +"]"
    RPB_Prisoner prisonerRef = prisonerList.GetAt(listKey) as RPB_Prisoner

    if (!prisonerRef)
        Warn(none, "Prison::GetPrisonerReference", "The Actor " + akPrisoner + " is not a prisoner or there was a state mismatch!")
        return none
    endif

    return prisonerRef
endFunction


bool __isReceivingUpdates
bool function IsReceivingUpdates()
    return __isReceivingUpdates
endFunction

bool function WasInitialized()
    return __isInitialized
endFunction

; TODO: Store the prisoners for each prison here, making the AME list futile since we can always retrieve them through here,
; maybe map the index to a key for easier access like it's done in the AME list.

int __prisonersIndex


RPB_JailCell[] __prisonCells

bool __isInitialized

; ; ==========================================================

; ==========================================================
;                            Test
; ==========================================================

bool __isAwaitingUpdateForGameTime
bool property IsAwaitingUpdateForGameTime
    bool function get()
        return __isAwaitingUpdateForGameTime
    endFunction
endProperty


function RegisterForSingleUpdateGameTime(float afInterval)
    parent.RegisterForSingleUpdateGameTime(afInterval)
    __isAwaitingUpdateForGameTime = true
endFunction

RPB_Prisoner[] queuedPrisonersForImprisonment
bool isProcessingQueuedPrisonersForImprisonment
int queuedPrisonerAvailableIndex

bool function IsPrisonerQueuedForImprisonment(RPB_Prisoner akPrisoner)
    float startBench = StartBenchmark()
    int i = 0
    while (i < queuedPrisonersForImprisonment.Length)
        if (queuedPrisonersForImprisonment[i] == akPrisoner)
            EndBenchmark(startBench, "IsPrisonerQueuedForImprisonment -> returned true")
            return true
        endif
        i += 1
    endWhile
    
    EndBenchmark(startBench, "IsPrisonerQueuedForImprisonment -> returned false")
    return false
endFunction

function RegisterForQueuedImprisonment()
    ; Don't process, we are already processing
    if (isProcessingQueuedPrisonersForImprisonment)
        return
    endif

    ; GotoState("ProcessQueuedPrisonersForImprisonment")
    RegisterForSingleUpdateGameTime(0.1)
endFunction

function QueuePrisonerForImprisonment(RPB_Prisoner akPrisoner)
    if (self.IsPrisonerQueuedForImprisonment(akPrisoner))
        return
    endif

    if (!queuedPrisonersForImprisonment)
        queuedPrisonersForImprisonment = new RPB_Prisoner[128]
        queuedPrisonerAvailableIndex = 0
    endif
    Debug(none, "Prison::QueuePrisonerForImprisonment", "queuedPrisonersForImprisonment.Length: " + queuedPrisonersForImprisonment.Length)

    queuedPrisonersForImprisonment[queuedPrisonerAvailableIndex] = akPrisoner
    Debug(none, "Prison::QueuePrisonerForImprisonment", "Queued " + queuedPrisonersForImprisonment[queuedPrisonerAvailableIndex] + " for imprisonment.")
    queuedPrisonerAvailableIndex += 1
endFunction

function ProcessImprisonmentForQueuedPrisoners()
    int i = 0
    while (i < queuedPrisonersForImprisonment.Length)
        if (queuedPrisonersForImprisonment[i] != none)
            queuedPrisonersForImprisonment[i].Imprison()    ; Imprison this Prisoner
            queuedPrisonersForImprisonment[i] = none        ; Remove from Queue
        endif
        Utility.Wait(0.2)
        i += 1
    endWhile

    ; Finished processing prisoners
    isProcessingQueuedPrisonersForImprisonment = false
endFunction

function MarkActorAsPrisoner(Actor akActor, bool abDelayExecution = true)
    Spell prisonerSpell = GetFormFromMod(0x197D7) as Spell
    akActor.AddSpell(prisonerSpell, false)

    if (abDelayExecution)
        Utility.Wait(0.2)
    endif
endFunction

RPB_Prisoner function MakePrisoner(Actor akActor, bool abDelayExecution = true)
    ; Cast the Prisoner spell (to bind the RPB_Prisoner instance script)
    Spell prisonerSpell = GetFormFromMod(0x197D7) as Spell
    akActor.AddSpell(prisonerSpell, false)

    ; Delay execution before returning an instance of the prisoner, since we need to let the RPB_Prisoner script register this Prisoner
    if (abDelayExecution)
        Utility.Wait(0.2)
    endif

    ; The instance should be available by now, since after the spell is added, the script will register this actor as a Prisoner OnInitialize() through self.RegisterPrisoner()
    return self.GetPrisonerReference(akActor)
endFunction

function ImprisonActorImmediately(Actor akActor)
    ArrestVars.SetForm("["+ akActor.GetFormID() +"]Arrest::Faction", self.PrisonFaction)
    ArrestVars.SetForm("["+ akActor.GetFormID() +"]Arrest::Arrestee", akActor)
    ArrestVars.SetString("["+ akActor.GetFormID() +"]Arrest::Arrest Type", Arrest.ARREST_TYPE_TELEPORT_TO_CELL)
    ArrestVars.SetString("["+ akActor.GetFormID() +"]Arrest::Hold", self.Hold)

    RPB_Prisoner prisonerRef = self.MakePrisoner(akActor)

    if (!prisonerRef.AssignCell())
        Debug(akActor, "Prison::ImprisonActorImmediately", "Could not assign a cell to actor " + akActor)
        return
    endif

    prisonerRef.QueueForImprisonment()
    prisonerRef.MoveToCell()
    prisonerRef.SetSentence(self.GetRandomSentence(0, 75))
endFunction

; ==========================================================
;                           States
; ==========================================================

;/
    State that happens when there are prisoners awaiting to be processed for imprisonment
/;
; state ProcessQueuedPrisonersForImprisonment
;     event OnUpdateGameTime()
;         if (!isProcessingQueuedPrisonersForImprisonment)
;             self.ProcessImprisonmentForQueuedPrisoners()
;             isProcessingQueuedPrisonersForImprisonment = true
;         endif

;         GotoState("")
;         self.RegisterForSingleUpdateGameTime(5.0)
;     endEvent
; endState

; ==========================================================
;                            Debug
; ==========================================================

function DEBUG_ShowPrisonerSentenceInfo(RPB_Prisoner akPrisoner, bool abShort = false)
    if (abShort)
        ; Time Served
        int timeServedDays           = akPrisoner.GetTimeServed("Days")
        int timeServedHours          = akPrisoner.GetTimeServed("Hours of Day")

        ; Time Left
        int timeLeftToServeDays      = akPrisoner.GetTimeLeftInSentence("Days")
        int timeLeftToServeHours     = akPrisoner.GetTimeLeftInSentence("Hours of Day")

        string sentenceString   = "Sentence: " + akPrisoner.Sentence + " Days"
        string timeServedString = timeServedDays + " Days, " + timeServedHours + " Hours"
        string timeLeftString   = timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours"
        
        Info(none, "ShowSentenceInfo", self.Hold + " Sentence for " + akPrisoner.GetActor() + ": {"+ sentenceString +", (Served: "+ timeServedString +"), (Left: "+ timeLeftString +")} (Cell: " + akPrisoner.Prison_GetReference("Cell") + ", Door: " + akPrisoner.Prison_GetReference("Cell Door") + ")")
        ; Info(none, "ShowSentenceInfo", self.Hold + " Sentence for " + akPrisoner.GetActor() + ": {"+ sentenceString +", Served: "+ timeServedString +", Left: "+ timeLeftString +"} (Cell: " + akPrisoner.Prison_GetReference("Cell") + ", Door: " + akPrisoner.Prison_GetReference("Cell Door") + ")")
    else
        ; Time Served
        int timeServedDays           = akPrisoner.GetTimeServed("Days")
        int timeServedHours          = akPrisoner.GetTimeServed("Hours of Day")
        int timeServedMinutes        = akPrisoner.GetTimeServed("Minutes of Hour")
        int timeServedSeconds        = akPrisoner.GetTimeServed("Seconds of Minute")

        ; Time Left
        int timeLeftToServeDays      = akPrisoner.GetTimeLeftInSentence("Days")
        int timeLeftToServeHours     = akPrisoner.GetTimeLeftInSentence("Hours of Day")
        int timeLeftToServeMinutes   = akPrisoner.GetTimeLeftInSentence("Minutes of Hour")
        int timeLeftToServeSeconds   = akPrisoner.GetTimeLeftInSentence("Seconds of Minute")

        Info(none, "DEBUG_ShowPrisonerSentenceInfo", "\n" + Hold + " Sentence: { \n\t" + \
            "Prisoner: "            + "(Name: " + akPrisoner.GetName() + ", Prisoner Reference: " + akPrisoner +  ", Actor Reference: " + akPrisoner.GetActor() + ")" + "\n\t" + \
            "Minimum Sentence: "    + MinimumSentence + " Days, \n\t" + \
            "Maximum Sentence: "    + MaximumSentence + " Days, \n\t" + \
            "Sentence: "            + akPrisoner.Sentence + " Days, \n\t" + \
            "Time of Arrest: "      + akPrisoner.TimeOfArrest + ", \n\t" + \
            "Time of Imprisonment: "+ akPrisoner.TimeOfImprisonment + ", \n\t" + \
            "Time Served: "         + akPrisoner.TimeServed + " ("+ (akPrisoner.TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"], \n\t" + \
            "Time Left: "           + akPrisoner.TimeLeftInSentence + " ("+ (akPrisoner.TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"], \n\t" + \
            "Release Time: "        + akPrisoner.ReleaseTime + "\n" + \
        " }")
    endif
endFunction