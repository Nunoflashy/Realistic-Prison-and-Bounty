scriptname RealisticPrisonAndBounty_Arrest extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

; ==========================================================
;                      Arrest Topic Types
; ==========================================================

int property TOPIC_START    = 0 autoreadonly
int property TOPIC_END      = 1 autoreadonly

int property TOPIC_TYPE_ARREST_SUSPICIOUS                       = 5 autoreadonly
int property TOPIC_TYPE_ARREST_DIALOGUE_ELUDING                 = 6 autoreadonly
int property TOPIC_TYPE_ARREST_PURSUIT_ELUDING                  = 7 autoreadonly
int property TOPIC_TYPE_ARREST_CONFRONT                         = 10 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT               = 11 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_WILLINGLY      = 12 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED       = 13 autoreadonly
int property TOPIC_TYPE_ARREST_PAY_BOUNTY_MAX                   = 14 autoreadonly
int property TOPIC_TYPE_ARREST_RESIST                           = 15 autoreadonly
int property TOPIC_TYPE_COMBAT_YIELD                            = 16 autoreadonly
int property TOPIC_TYPE_ARREST_GO_TO_JAIL                       = 20 autoreadonly

; ==========================================================
;                 Arrest Pay Bounty Scenarios
; ==========================================================

string property ARREST_PAY_BOUNTY_ON_SPOT           = "ArrestPayOnSpot" autoreadonly
string property ARREST_PAY_BOUNTY_ESCORT_WILLINGLY  = "ArrestEscortWillingly" autoreadonly
string property ARREST_PAY_BOUNTY_ESCORT_BY_FORCE   = "ArrestEscortByForce" autoreadonly

; ==========================================================
;                         Arrest Types
; ==========================================================

string property ARREST_TYPE_TELEPORT_TO_JAIL    = "TeleportToJail" autoreadonly
string property ARREST_TYPE_TELEPORT_TO_CELL    = "TeleportToCell" autoreadonly
string property ARREST_TYPE_ESCORT_TO_JAIL      = "EscortToJail" autoreadonly
string property ARREST_TYPE_ESCORT_TO_CELL      = "EscortToCell" autoreadonly

; ==========================================================
;                         Arrest Goals
; ==========================================================

string property ARREST_GOAL_IMPRISONMENT        = "Imprisonment" autoreadonly
string property ARREST_GOAL_BOUNTY_PAYMENT      = "BountyPayment" autoreadonly
string property ARREST_GOAL_TEMPORARY_HOLD      = "TemporaryHold" autoreadonly ; Unused for Now, later will be used to hold suspects (temporary imprisonment, short term), should they be considered a RPB_Prisoner though?


RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_ActorVars property ActorVars
    RealisticPrisonAndBounty_ActorVars function get()
        return Config.ActorVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return Config.MiscVars
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager property SceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return Config.SceneManager
    endFunction
endProperty

RealisticPrisonAndBounty_CaptorRef property CaptorRef auto

;/
    Reference to container to store every possible Arrestee's state Script,
    this makes it possible to retrieve this script's actions that are attached to the Actor that is arrested
    without having them been passed through an Event.

    Making it possible then to do something like this in another script to control the behavior of an Arrestee:
        RPB_Arrestee arresteeRef = Arrestees.GetAt(akArrestee) as RPB_Arrestee

    Since we can add or remove this reference from the list through this script, 
    it also makes it possible to manage the lifetime of this object through an individual Arrestee script attached to the Actor,
    instead of managing it in some other script and checking for the Actor's state.
/;
RPB_ArresteeList property Arrestees
    RPB_ArresteeList function get()
        return self.GetAliasByName("ArresteeList") as RPB_ArresteeList
    endFunction
endProperty

RPB_CaptorList property Captors
    RPB_CaptorList function get()
        return self.GetAliasByName("CaptorList") as RPB_CaptorList
    endFunction
endProperty

;/
    Retrieves the Hold's data object.

    string  @asHold: The hold to retrieve the data object from.
    string? @asHoldObjectCategory: The category of object to get from the Hold object.

    returns (any& <JContainer>): The reference to the Hold data object, or an object inside the Hold object if a category is specified.
/;
int function GetDataObjectForHold(string asHold, string asHoldObjectCategory = "null")
    int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
    int returnedObject  = rootObject

    if (asHoldObjectCategory != "null")
        returnedObject = JMap.getObj(rootObject, asHoldObjectCategory) ; any& <JContainer>
    endif

    return returnedObject
endFunction

; ==========================================================
;                  Arrestee-specific Methods
; ==========================================================

;/
    Binds @akArrestee to an instance of RPB_Arrestee,
    giving us the arrest state of the Actor bound to this reference.

    Used when this Actor is Arrested, lasts until Release or Imprisonment.
/;
bool function RegisterArrestee(RPB_Arrestee apArrestee)
    Arrestees.Add(apArrestee)
    return Arrestees.Exists(apArrestee)
endFunction

;/
    Marks an Actor as an Arrestee.
    This function should be used whenever an Actor should have an Arrest state (e.g: when beginning an arrest.)

    Actor   @akActor: The Actor to mark as arrestee.
    bool?   @abDelayExecution: Whether to delay the execution of this function after marking the Actor (In order to obtain the reference for slower systems).

    returns (RPB_Arrestee): A reference to the arrest state of the Actor.
/;
RPB_Arrestee function MakeArrestee(Actor akActor, bool abDelayExecution = true)
    Spell arrestSpell = GetFormFromMod(0x187B3) as Spell
    akActor.AddSpell(arrestSpell, false)

    if (abDelayExecution)
        Utility.Wait(0.2)
    endif

    ; Since the spell is cast, a reference of type RPB_Arrestee is now available for akActor
    return self.GetArresteeReference(akActor)
endFunction

;/
    Removes an arrestee from the Arrestee list.

    RPB_Arrestee    @apArrestee: The reference to the arrestee.
/;
function RemoveArresteeFromList(RPB_Arrestee apArrestee)
    if (apArrestee && Arrestees.Exists(apArrestee))
        Arrestees.Remove(apArrestee)
    endif
endFunction

;/
    Removes the Arrestee spell (and consequently, the MagicEffect) from this arrestee.
/;
function UnregisterArrestee(RPB_Arrestee apArrestee)
    ; Remove the spell from the arrestee
    Spell arrestSpell = GetFormFromMod(0x187B3) as Spell
    if (apArrestee.HasSpell(arrestSpell))
        apArrestee.RemoveSpell(arrestSpell)
    endif
endFunction

RPB_Arrestee function GetArresteeReference(Actor akArrestee)
    RPB_Arrestee arresteeRef = Arrestees.AtKey(akArrestee)

    if (!arresteeRef)
        ; Warn(self, "Arrest::GetArresteeReference", "The Actor " + akArrestee + " is not arrested or there was a state mismatch!")
        Debug(self, "Arrest::GetArresteeReference", "The Actor " + akArrestee + " is not arrested or there was a state mismatch!")

        return none
    endif

    return arresteeRef
endFunction

; ==========================================================
;                  Captor-specific Methods
; ==========================================================

;/
    Binds @akCaptorRef to an instance of RPB_Captor,
    giving us the captor state of the Actor bound to this reference.

    Used when this Actor is arresting an Actor, lasts until Escort end or Death.
/;
bool function RegisterCaptor(RPB_Captor apCaptor)
    Captors.Add(apCaptor)
    return Captors.Exists(apCaptor)
endFunction

RPB_Captor function MakeCaptor(Actor akActor, bool abDelayExecution = true)
    Spell arrestSpell = GetFormFromMod(0x187B3) as Spell ; change formid
    akActor.AddSpell(arrestSpell, false)

    if (abDelayExecution)
        Utility.Wait(0.2)
    endif

    if (akActor.HasSpell(arrestSpell))
        Debug(self, "Arrest::MakeCaptor", "The Actor does not have the spell attached to them! (This is possibly a bug!)")
        return none
    endif

    ; Since the spell is cast, a reference of type RPB_Captor is now available for akActor
    return self.GetCaptorReference(akActor)
endFunction

function UnregisterCaptor(Actor akCaptor)
    RPB_Captor captor = self.GetCaptorReference(akCaptor)
    string containerKey = "Captor["+ akCaptor.GetFormID() +"]"

    if (captor)
        Captors.Remove(captor)
    endif
endFunction

RPB_Captor function GetCaptorReference(Actor akCaptor)
    string listKey = "Captor["+ akCaptor.GetFormID() +"]"

    RPB_Captor captor = Captors.GetAt(listKey) as RPB_Captor

    if (!captor)
        Warn(self, "Arrest::GetCaptorReference", "The Actor " + akCaptor + " is not a captor or there was a state mismatch!")
        return none
    endif

    return captor
endFunction


bool function IsActorArrested(Actor akActor)
    return RPB_StorageVars.GetBoolOnForm("Arrested", akActor, "Arrest")
    ; return ArrestVars.GetBool(string_if (akActor == Config.Player, "Arrest::Arrested", "["+ akActor.GetFormID() +"]Arrest::Arrested"))
endFunction

event OnInit()
    RegisterHotkeys()
endEvent

event OnPlayerLoadGame()
    RegisterHotkeys()
endEvent

;/
    GetDateFromDaysPassed(17, 8, 201, 30)
    =
    totalDaysPassed = 229
    totalDaysPassed += 30 (259)

    while (259 > 0)
        daysInMonth = GetDaysOfMonth(currentMonth)
        
        if (259 <= daysInMonth) (false)
            aiDay = 259
            totalDaysPassed = 0
        else (true)
            currentMonth += 1 (9) (10 when totalDays is 229)

            if (9 > 12) (false)
                currentMonth = 1
                currentYear += 1
            endif

            totalDaysPassed -= daysInMonth (229 assuming daysOfMonth is 30)

        endif
    endWhile
/;

event OnKeyDown(int keyCode)
    if (keyCode == 0x58) ; F12
        RPB_PrisonManager prisonManager = GetFormFromMod(0x1B825) as RPB_PrisonManager
        RPB_Prison prison       = prisonManager.GetPrison("Haafingar")
        RPB_Prisoner prisonerReference = prison.GetPrisoner(Config.Player)
        prisonerReference.Imprison()
        return
        string currentHold = Config.GetCurrentPlayerHoldLocation()
        Actor nearbyGuard = GetNearestActor(config.Player, 7000)
        nearbyGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_TELEPORT_TO_CELL)
    
    elseif (keyCode == 0x44) ; F10
        int daysPassed = RPB_Utility.CalculateDaysPassedFromDate(17, 8, 201)
        RPB_Utility.Debug("Arrest::OnKeyDown", "Days Passed from 01/01/201 to 17/08/201: " + daysPassed)
        int daysPassed2 = RPB_Utility.CalculateDaysPassedFromDate(31, 12, 201)
        RPB_Utility.Debug("Arrest::OnKeyDown", "Days Passed from 01/01/201 to 31/12/201: " + daysPassed2)

        ; int[] daysFromDate = RPB_Utility.GetDateFromDaysPassed(17, 8, 201, 30)
        ; RPB_Utility.Debug("Arrest::OnKeyDown", "30 days after 17/08/201: " + daysFromDate[0] + "/" + daysFromDate[1] + "/" + daysFromDate[2])

        ; int d = 1
        ; int m = 3
        ; int y = 201
        int d = 1
        int m = 1
        int y = 201
        ; int d = 1
        ; int m = 8
        ; int y = 201
        int numberOfDays = 35
        ; int numberOfDays = 32
        while (numberOfDays <= 365)
            int[] daysFromDate = RPB_Utility.GetDateFromDaysPassed(d, m, y, numberOfDays)
            RPB_Utility.Debug("Arrest::OnKeyDown", numberOfDays + " days after "+ d + "/" + m + "/" + y +": " + daysFromDate[0] + "/" + daysFromDate[1] + "/" + daysFromDate[2])
            numberOfDays += 30
        endWhile

        ; RPB_Utility.Debug("Arrest::OnKeyDown", "Day of week for 01/01/201: " + RPB_Utility.CalculateDayOfWeek(1, 1, 201))

        ; int year = 201
        ; while (year <= 220)
        ;     string yearShown = "4E " + string_if (year < 10, "20" + year, year)
        ;     int firstDayOfWeekInYear        = RPB_Utility.GetFirstDayOfWeek(year)
        ;     string dayOfWeekName            = RPB_Utility.GetDayOfWeekName(firstDayOfWeekInYear)
        ;     string dayOfWeekGregorianName   = RPB_Utility.GetDayOfWeekGregorianName(firstDayOfWeekInYear)
        ;     RPB_Utility.Debug("Arrest::OnKeyDown", "First Day of Week " + yearShown + ": " + firstDayOfWeekInYear + " ["+ dayOfWeekName + " ("+ dayOfWeekGregorianName +")" + "]")
        ;     RPB_Utility.Debug("Arrest::OnKeyDown", "Day of week for 12/01/" + year +": " + RPB_Utility.CalculateDayOfWeek(12, 1, year))

        ;     year += 1
        ; endWhile

        int year = 201
        while (year <= 201)
            RPB_Utility.Debug("Arrest::OnKeyDown", "==================== 4E " + year + " ====================")
            int month = 1
            while (month <= 2)
                RPB_Utility.Debug("Arrest::OnKeyDown", "========== " + RPB_Utility.GetMonthName(month) + " ==========")
                string yearShown = "4E " + year
                ; int firstDayOfWeekInYear        = RPB_Utility.GetFirstDayOfWeek(year)
                ; int dayOfWeek                   = RPB_Utility.CalculateDayOfWeek(12, month, year)
                ; string dayOfWeekName            = RPB_Utility.GetDayOfWeekName(dayOfWeek)
                ; string dayOfWeekGregorianName   = RPB_Utility.GetDayOfWeekGregorianName(firstDayOfWeekInYear)
                ; RPB_Utility.Debug("Arrest::OnKeyDown", "Day of week for 12/"+ month +"/" + year +": " + dayOfWeek + " ("+ dayOfWeekName +")")

                int day = 1
                while (day <= RPB_Utility.GetDaysOfMonth(month))
                    int firstDayOfWeekInYear        = RPB_Utility.GetFirstDayOfWeek(year)
                    int dayOfWeek                   = RPB_Utility.CalculateDayOfWeek(day, month, year)
                    string dayOfWeekName            = RPB_Utility.GetDayOfWeekName(dayOfWeek)
                    string dayOfWeekGregorianName   = RPB_Utility.GetDayOfWeekGregorianName(firstDayOfWeekInYear)
                    RPB_Utility.Debug("Arrest::OnKeyDown", "Day of week for "+ day +"/"+ month +"/" + year +": " + dayOfWeek + " ("+ dayOfWeekName +")")
                    day += 1
                endWhile
                RPB_Utility.Debug("Arrest::OnKeyDown", "")
                month += 1
            endWhile
            RPB_Utility.Debug("Arrest::OnKeyDown", "")
            year += 1
        endWhile

        ; RPB_Utility.Debug("Arrest::OnKeyDown", "First Day of Week 4E 201 " + RPB_Utility.GetFirstDayOfWeek(201))
        ; RPB_Utility.Debug("Arrest::OnKeyDown", "First Day of Week 4E 202 " + RPB_Utility.GetFirstDayOfWeek(202))
        return
        ; Actor playerCopy = config.Player.PlaceActorAtMe(config.Player.GetBaseObject() as ActorBase, 1, none)
        ; Actor playerCopy2 = config.Player.PlaceActorAtMe(config.Player.GetBaseObject() as ActorBase, 1, none)

        ; RPB_Arrestee playerCopyArrestee = self.MarkActorAsArrestee(playerCopy)
        ; playerCopyArrestee.SetActiveBounty(2500)

        ; Actor nearbyGuard = GetNearestGuard(config.Player, 3500, none)
        ; self.ArrestActor(nearbyGuard, playerCopy, ARREST_TYPE_ESCORT_TO_JAIL)

        Actor nearbyGuard = GetNearestGuard(config.Player, 3500, none)
        ; Actor anotherGuard = Config.Player.PlaceActorAtMe(nearbyGuard.GetBaseObject() as ActorBase, 1, none)
        ; Actor anotherGuard2 = Config.Player.PlaceActorAtMe(nearbyGuard.GetBaseObject() as ActorBase, 1, none)
        ; Actor anotherGuard3 = Config.Player.PlaceActorAtMe(nearbyGuard.GetBaseObject() as ActorBase, 1, none)
        ; Actor anotherGuard4 = Config.Player.PlaceActorAtMe(nearbyGuard.GetBaseObject() as ActorBase, 1, none)
        ; Actor anotherGuard5 = Config.Player.PlaceActorAtMe(nearbyGuard.GetBaseObject() as ActorBase, 1, none)


        ; RPB_Arrestee anotherGuardArrestee = self.MarkActorAsArrestee(anotherGuard)
        ; self.MarkActorAsArrestee(anotherGuard)
        ; self.MarkActorAsArrestee(anotherGuard2)
        ; self.MarkActorAsArrestee(anotherGuard3)
        ; self.MarkActorAsArrestee(anotherGuard4)
        ; self.MarkActorAsArrestee(anotherGuard5)
        ; anotherGuardArrestee.SetActiveBounty(2500)

        RPB_Prison haafingarPrison = (RPB_API.GetPrisonManager()).GetPrison("Haafingar")

        int actorsToArrestCount = 8
        Actor[] actorsToArrest = new Actor[8]

        int i = 0
        while (i < actorsToArrestCount)
            actorsToArrest[i] = Config.Player.PlaceActorAtMe(nearbyGuard.GetBaseObject() as ActorBase, 1, none)
            ; self.MarkActorAsArrestee(actorsToArrest[i], false)
            ; actorsToArrest[i].MoveTo(Config.GetRandomJailMarker("Haafingar"))
            haafingarPrison.ImprisonActorImmediately(actorsToArrest[i])
            ; Actor nearActor = GetNearestActor(nearbyGuard, 2000)
            ; self.MarkActorAsArrestee(nearActor)
            ; self.ArrestActor(nearbyGuard, nearActor, ARREST_TYPE_ESCORT_TO_JAIL)
            i += 1
        endWhile
        ; Actor[] actorsToArrest = new Actor[5]
        ; actorsToArrest[0] = anotherGuard
        ; actorsToArrest[1] = anotherGuard2
        ; actorsToArrest[2] = anotherGuard3
        ; actorsToArrest[3] = anotherGuard4
        ; actorsToArrest[4] = anotherGuard5

        ; self.ArrestActors(nearbyGuard, actorsToArrest, ARREST_TYPE_ESCORT_TO_JAIL)

        ; self.ArrestActor(nearbyGuard, anotherGuard, ARREST_TYPE_ESCORT_TO_JAIL)
        ; Utility.Wait(0.5)
        ; self.ArrestActor(nearbyGuard, anotherGuard2, ARREST_TYPE_ESCORT_TO_JAIL)
        ; Utility.Wait(0.5)
        ; self.ArrestActor(nearbyGuard, anotherGuard3, ARREST_TYPE_ESCORT_TO_JAIL)
        ; Utility.Wait(0.5)
        ; self.ArrestActor(nearbyGuard, anotherGuard4, ARREST_TYPE_ESCORT_TO_JAIL)
        ; Utility.Wait(0.5)
        ; self.ArrestActor(nearbyGuard, anotherGuard5, ARREST_TYPE_ESCORT_TO_JAIL)

        ; ==================================

        ; Quest WIRemoveItem01 = Game.GetFormEx(0x2C6AB) as Quest
        ; WIRemoveItem01.Start()

        ; Actor solitudeGuard = Game.GetFormEx(0xF684E) as Actor
        ; Actor playerCopy = config.Player.PlaceActorAtMe(config.Player.GetBaseObject() as ActorBase, 1, none)
        ; self.MarkActorAsArrested(playerCopy)
        ; Debug(self, "Arrest::OnKeyDown", "Keys: " + ArresteeList.GetKeys())
        ; sceneManager.StartEscortFromCell(ArrestVars.Captor, ArrestVars.Arrestee, ArrestVars.CellDoor, ArrestVars.PrisonerItemsContainer)
        ; Debug(self, "Arrest::OnKeyDown", "F10 Pressed - SceneManager")

    elseif (keyCode == 0x41) ; F7
        Debug(self, "Arrest::OnKeyDown", "F7 Pressed")

        Actor nearbyGuard = GetNearestGuard(config.Player, 3500, none)
        self.ArrestActor(nearbyGuard, config.Player, ARREST_TYPE_ESCORT_TO_JAIL)

        return

        int rootObj     = RPB_StorageVars.GetObjectHandle()
        int arrestObj   = RPB_StorageVars.GetObjectHandleOnForm(Config.Player, "Jail")

        Debug(self, "Arrest::OnKeyDown", "rootObj: " + GetContainerList(rootObj))
        Debug(self, "Arrest::OnKeyDown", "arrestObj: " + GetContainerList(arrestObj))
        return
        
        RPB_PrisonManager prisonManager = GetFormFromMod(0x1B825) as RPB_PrisonManager
        RPB_Prison returnedPrison       = prisonManager.GetPrison("Haafingar")
        Debug(none, "Arrest::OnKeyDown", "Prisoner Keys: " + returnedPrison.Prisoners.GetKeys())

        return

        int rootItem            = RPB_Data.GetRootObject()
        int haafingarRootItem   = RPB_Data.GetRootObject("Haafingar")
        int haafingarJailItem   = RPB_Data.Hold_GetJailObject(haafingarRootItem)
        int solitudeCells       = RPB_Data.Jail_GetCellsObject(haafingarJailItem)

        Form[] jailCellParents = RPB_Data.JailCell_GetParents(solitudeCells)

        int i = 0
        while (i < jailCellParents.Length)
            RPB_JailCell jailCell = jailCellParents[i] as RPB_JailCell
            int jailCellParentObject = RPB_Data.RawObject_GetJailCellParent(haafingarJailItem, jailCell)
            i += 1
        endWhile

    elseif (keyCode == 0x42) ; F8
        Debug(self, "Arrest::OnKeyDown", "F8 Pressed")

        int rootItem = RPB_Data.GetRootObject()
        int haafingarRootItem = RPB_Data.GetRootObject("Haafingar")
        int haafingarJailItem = RPB_Data.Hold_GetJailObject(haafingarRootItem)
        int solitudeCells     = RPB_Data.Jail_GetCellsObject(haafingarJailItem)

        ; Config.AddJailCellMarker(Config.Player, haafingarJailItem, "Interior", true)
        ; Form[] forms = Config.GetJailCellParentMarkers(haafingarJailItem, "Interior")
        Form[] forms = RPB_Data.JailCell_GetParents(solitudeCells)

        int i = 0
        while (i < forms.Length)
            ; Config.GetJailCellChildMarkers(haafingarJailItem, forms[i])
            ; Config.GetJailCellChildMarkers(haafingarJailItem, forms[i], "Exterior")
            RPB_Data.GetJailCellChildren(haafingarJailItem, forms[i], "Interior")
            RPB_Data.GetJailCellChildren(haafingarJailItem, forms[i], "Exterior")
            i += 1
        endWhile
        ; Config.SaveData()

        return
        Debug(none, "Arrest::OnKeyDown", "Prisoner Keys: " + Arrestees.GetKeys())
        Debug(none, "Arrest::OnKeyDown", "Cities: " + Config.Cities)

        ; int i = 0
        ; ActiveMagicEffect[] prisonersAsArray =  ArresteeList.GetAsArray()
        ; while (i < prisonersAsArray.Length)
        ;     RPB_Prisoner prisonerRef = prisonersAsArray[i] as RPB_Prisoner
        ;     Debug(none, "Arrest::OnKeyDown", "IsStrippedNaked: " + prisonerRef.IsStrippedNaked + ", IsStrippedToUnderwear: " + prisonerRef.IsStrippedToUnderwear)
        ;     i += 1
        ; endWhile

        return
        ; Actor solitudeGuard = Game.GetFormEx(0xF684E) as Actor
        ; Actor theGuard = config.Player.PlaceActorAtMe(solitudeGuard.GetBaseObject() as ActorBase, 1, none)
        Actor nearbyGuard = GetNearestGuard(config.Player, 3500, none)
        ObjectReference arrestee = Game.GetCurrentCrosshairRef()
        nearbyGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, arrestee.GetFormID())
    endif
endEvent


; Temporary Event Handlers
event OnArrestStart(Actor akCaptor, Actor akArrestee)
    ; Jail.EscortToJail()
endEvent

event OnArresting(Actor akCaptor, Actor akArrestee)
    self.RestrainArrestee(akArrestee)
endEvent

; ==========================================================
;                        Event Handlers
; ==========================================================

;/
    Master Event for all types of dialogue concerning Arrest, anything to do with arrest through dialogue is
    handled here.

    int     @aiTopicInfoType: The type of the dialogue, Arrest to Jail, Arrest Resist, Arrest Confront, etc...
    int     @aiTopicInfoEvent: The time of the event, at the Start or End of the dialogue.
    string  @asTopicInfoDialogue: The dialogue lines, used if a unique action should be done depending on the dialogue.
    Actor   @akSpeakerArrester: The guard actively trying to arrest the player.
    Actor   @akSpokenToArrestee: The Actor that is being spoken to by @akSpeakerArrester, in most cases, an arrestee.

    Dialogue Lines (@asTopicInfoDialogue):
        - TOPIC_TYPE_ARREST_DIALOGUE_ELUDING
            - Wait... I know you.

        - TOPIC_TYPE_ARREST_PURSUIT_ELUDING
            - That'll teach you to break the law on my watch.
            - I thought it was finally going to be a quiet day.
            - You really thought you could get away with it?
            - Don't get any bright ideas.
            - Stop, in the name of the Jarl!
            - Come quietly or face the Jarl's justice!
            - By order of the Jarl, I command you to halt!
            - Sheathe your wepaons and come quietly!

        - TOPIC_TYPE_ARREST_CONFRONT
            - By order of the Jarl, stop right there!
            - You have committed crimes against Skyrim and her people. What say you in your defense?

        - TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT
            - Good enough. I'll just confiscate any stolen goods you're carrying, then you're free to go.

        - TOPIC_TYPE_ARREST_PAY_BOUNTy_ESCORT_WILLINGLY
            - Smart man. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.
            - Smart woman. Now come along with us. We'll take any stolen goods and you'll be free to go. After you pay the fine, of course.

        - TOPIC_TYPE_COMBAT_YIELD
            - I'll let you live. This time
            - I'll spare you - for now.
            - All right, you've had enough.
            - You're not worth it.
            - I didn't think you had the stomach for it.

        - TOPIC_TYPE_ARREST_RESIST
            - Time to cleanse the Empire of its filth.
            - Then suffer the Emperor's wrath.
            - Skyrim has no use for your kind.
            - Then let me speed your passage to Sovngarde!
            - Then pay with your blood.
            - That can be arranged.
            - So be it.
/;
event OnArrestDialogue(int aiTopicInfoEvent, int aiTopicInfoType, string asTopicInfoDialogue, Actor akSpeakerArrester, Actor akSpokenToArrestee)
    if (aiTopicInfoEvent == TOPIC_START)
        if (aiTopicInfoType == TOPIC_TYPE_ARREST_CONFRONT)
            self.SetupArrestPayableBountyVars(akSpeakerArrester.GetCrimeFaction()) ; Setup arrest payable bounty vars
            self.SetActorWantsToPayBounty(akSpokenToArrestee, false) ; Reset any possibility of paying the bounty, before actually selecting it

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_RESIST)
            self.SetAsResisting(akSpeakerArrester, akSpokenToArrestee)

        elseif (aiTopicInfoType == TOPIC_TYPE_COMBAT_YIELD)
            self.SetAsYielding(akSpeakerArrester, akSpokenToArrestee)
        endif

    elseif (aiTopicInfoEvent == TOPIC_END)
        if (aiTopicInfoType == TOPIC_TYPE_ARREST_DIALOGUE_ELUDING)
            self.SetAsEluding(akSpeakerArrester, akSpokenToArrestee, "Dialogue")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PURSUIT_ELUDING)
            self.SetAsEluding(akSpeakerArrester, akSpokenToArrestee, "Pursuit")

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ON_SPOT)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ON_SPOT)

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
            
        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_PAY_BOUNTY_ESCORT_ARRESTED)
            self.StartBountyPayment(akSpeakerArrester, akSpokenToArrestee, ARREST_PAY_BOUNTY_ESCORT_BY_FORCE)

        elseif (aiTopicInfoType == TOPIC_TYPE_ARREST_GO_TO_JAIL)
            self.ArrestActor(akSpeakerArrester, akSpokenToArrestee, ARREST_TYPE_ESCORT_TO_JAIL)
        endif
    endif
endEvent

;/
    TODO: Fix arrestee reference not being cleared after failed arrest (the actor has RPB_Arrestee bound to them)

    RPB_Arrestee    @apArrestee: The reference to the actor that will be arrested.
    Actor           @akCaptor: The actor that is performing the arrest. (Can be none if a Faction arrest is performed)
    Faction         @akCrimeFaction: The crime faction for this arrest.
    string          @asArrestType: The type of the arrest, whether to escort or to move to jail, etc... (for more info, see ARREST_TYPES)
/;
event OnArrestBegin(RPB_Arrestee apArrestee, Actor akCaptor, Faction akCrimeFaction, string asArrestType)
    if (apArrestee.IsArrested)
        Config.NotifyArrest("You are already under arrest.", apArrestee.IsPlayer())
        Error(self, "Arrest::OnArrestBegin", apArrestee.GetName() + " has already been arrested, cannot arrest for "+ akCrimeFaction.GetName() +", aborting!")
        return
    endif

    if (apArrestee.IsImprisoned)
        Config.NotifyArrest("You are already in prison.", apArrestee.IsPlayer())
        Error(self, "Arrest::OnArrestBegin", apArrestee.GetName() + " has already been arrested, and is currently in prison. Cannot arrest for "+ akCrimeFaction.GetName() +", aborting!")
        return
    endif

    ; apArrestee.SetArrestParameters(ARREST_TYPE_ESCORT_TO_CELL, akCaptor, akCrimeFaction)
    ; apArrestee.SetArrestParameters(ARREST_TYPE_ESCORT_TO_JAIL, akCaptor, akCrimeFaction)
    ; apArrestee.SetActiveBounty(7000)
    apArrestee.SetArrestParameters(ARREST_TYPE_TELEPORT_TO_CELL, akCaptor, akCrimeFaction)
    ; apArrestee.SetActiveBounty(Utility.RandomInt(1200, 7800))
    ; apArrestee.SetActiveBounty(4200)

    ; Trace(self, "Arrest::OnArrestBegin", "ArresteeRef: [\n" + \
    ;     "\t arresteeRef: " + apArrestee + "\n" + \
    ;     "\t apArrestee.HasLatentBounty(): " + apArrestee.HasLatentBounty() + "\n" + \
    ;     "\t apArrestee.HasActiveBounty(): " + apArrestee.HasActiveBounty() + "\n" + \
    ;     "\t apArrestee.GetActiveBounty(): " + apArrestee.GetActiveBounty() + "\n" + \
    ;     "\t apArrestee.GetLatentBounty(): " + apArrestee.GetLatentBounty() + "\n" + \
    ;     "\t apArrestee.GetFaction(): " + apArrestee.GetFaction() + "\n" + \
    ; "]")

    if (!apArrestee.HasLatentBounty() && !apArrestee.HasActiveBounty())
        Config.NotifyArrest("You can't be arrested in " + akCrimeFaction.GetName() + " since you do not have a bounty in the hold", apArrestee.IsPlayer())
        Error(self, "Arrest::OnArrestBegin", apArrestee.Name + " has no bounty, cannot arrest for "+ akCrimeFaction.GetName() +", aborting!")
        apArrestee.Destroy()
        return
    endif

    if (apArrestee.IsPlayer())
        self.AllowArrestForcegreets(false)
    endif

    self.BeginArrest(apArrestee)
endEvent

;/
    Event that happens when the player is beginning to elude arrest.
    For Pursuit type arrest eludes, this is the only event that happens, because once the state is changed to Eluded,
    the penalty is given there. However, for Dialogue type arrest eluding, this is the event that is first fired upon making
    contact with a guard, which then gives way to their new dialogue that triggers OnEludingArrestDialogue which is where the penalties are given
    for that arrest elude type.

    Actor   @akEludedGuard: The guard that is being eluded.
    string  @asEludeType: How the arrest is being eluded, options are: [Dialogue, Pursuit]
        Eluding arrest through Dialogue means that the player has tried to avoid the "Wait, I know you..." guard dialogue
        but they caught up and demanded an explanation.

        Eluding arrest through Pursuit means that the player is trying to run away from the guards after they say lines such as:
        "In the name of the Jarl, I command you to stop!", or "Come quietly or face the Jarl's justice!"
/;
event OnArrestEludeStart(Actor akEludedGuard, string asEludeType)
    Debug(self, "Arrest::OnArrestEludeStart", "Started Eluding Arrest with Elude Type: " + asEludeType + ", akEludedGuard: " + akEludedGuard)

    if (asEludeType == "Dialogue")
        self.TriggerForcegreetEluding(akEludedGuard)
        return

    elseif (asEludeType == "Pursuit")
        self.TriggerPursuitEluding(akEludedGuard)
        return
    endif

    Error(self, "Arrest::OnArrestEludeStart", "The passed in Elude Type is invalid, the event failed!")
endEvent

event OnArrestEludeTriggered(Actor akEludedGuard, string asEludeType)
    self.ApplyArrestEludedPenalty(akEludedGuard.GetCrimeFaction()) ; Set as eluding arrest from this guard

    if (asEludeType == "Pursuit")
        akEludedGuard.StartCombat(config.Player)
    
    elseif (asEludeType == "Dialogue")
        SceneManager.ReleaseAlias("Guard") ; Unbind alias running the AI package from eluded guard
        SceneManager.ReleaseAlias("Eluder") ; Unbind alias from the player
    endif
endEvent

event OnArrestResist(Actor akArrestResister, Actor akGuard, Faction akCrimeFaction)
    ; if (ArrestVars.GetBool("Arrest::Captured"))
    ;     Warn(self, "Arrest::OnArrestResist", akArrestResister.GetBaseObject().GetName() + " was arrested, no arrest was resisted (maybe multiple guards talked at once and triggered resist arrest?) [BUG]")
    ;     return
    ; endif

    bool isCaptured = RPB_StorageVars.GetBoolOnForm("Captured", akArrestResister, "Arrest")
    if (isCaptured)
        Warn(self, "Arrest::OnArrestResist", akArrestResister.GetBaseObject().GetName() + " was arrested, no arrest was resisted (maybe multiple guards talked at once and triggered resist arrest?) [BUG]")
        return
    endif

    akGuard.SetPlayerResistingArrest() ; Needed to make the guards attack the player, otherwise they will loop arrest dialogue

    if (self.HasResistedArrestRecently(akCrimeFaction))
        Info(self, "Arrest::OnArrestResist", "You have already resisted arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    self.ApplyArrestResistedPenalty(akCrimeFaction)
endEvent

event OnArrestPayBounty(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, string asPayBountyScenario)
    Debug(self, "Arrest::OnArrestPayBounty", "Paying Bounty for Faction " + akCrimeFaction + ", Payer: " + akPayerArrestee + ", paying to: " + akArresterGuard)

    if (asPayBountyScenario == ARREST_PAY_BOUNTY_ON_SPOT)
        self.PayCrimeGold(akPayerArrestee, akCrimeFaction)

    elseif (asPayBountyScenario == ARREST_PAY_BOUNTY_ESCORT_WILLINGLY)
        ; Start escort Scene, where guard will take the person paying the bounty to jail, to be frisked and pay it.
        ; If the payer strays from the path, give a bounty penalty and start combat
        CaptorRef.ForceRefTo(akArresterGuard)
        CaptorRef.AssignArrestee(akPayerArrestee)
        CaptorRef.RegisterForSingleUpdate(5.0)
        self.SetActorWantsToPayBounty(akPayerArrestee)
        self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_BOUNTY_PAYMENT)

        ; Get current bounty and hide it
        ; self.HideBounty(akCrimeFaction)

        SceneManager.StartArrestBountyPaymentFollowWillingly(akArresterGuard, akPayerArrestee, Config.GetJailPrisonerItemsContainer(akCrimeFaction.GetName()) as ObjectReference)
    elseif (asPayBountyScenario == ARREST_PAY_BOUNTY_ESCORT_BY_FORCE)
        ; Start escort Scene, where guard will detain the person paying the bounty to jail and take them there by force, to be frisked and pay it.
        ; temporary escort location:
        self.SetArrestScene(akPayerArrestee, SceneManager.SCENE_ARREST_START_01)
        self.ArrestActor(akArresterGuard, akPayerArrestee, ARREST_TYPE_ESCORT_TO_JAIL)

        ; Set vars to differentiate from normal arrest
        self.SetActorWantsToPayBounty(akPayerArrestee)
        self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_BOUNTY_PAYMENT)
    endif
endEvent

event OnArrestDefeat(Actor akAttacker)
    self.ApplyArrestDefeatedPenalty(akAttacker.GetCrimeFaction())

    Form handcuffs = Game.GetFormEx(0xA033D9E)
    config.Player.StopCombatAlarm()
    config.Player.EquipItem(handcuffs, true, true)
endEvent

event OnArrestCaptorDeath(Actor akCaptor, Actor akCaptorKiller)
    Actor anotherGuard = GetNearestGuard(ArrestVars.Arrestee, 3500, exclude = akCaptor) ; TODO: Refactor ArrestVars to get the actual arrestee

    if (!anotherGuard)
        config.NotifyArrest("Your captor has died, you may now try to break free")
        self.ReleaseDetainee(akCaptor, ArrestVars.Arrestee)
        return
    endif

    config.NotifyArrest("Your captor has died, you are being escorted by another guard")
    self.ChangeArrestEscort(anotherGuard, ArrestVars.Arrestee)

    if (akCaptorKiller == none) ; to be changed to Player later, but this is easier to test
        int bounty = 10000
        config.NotifyArrest("You have gained " + bounty + " Bounty in " + ArrestVars.Hold + " for killing your captor!")
    endif

    Debug(self, "Arrest::OnArrestCaptorDeath", "[\n"+ \ 
        "\tOld Captor: "+ akCaptor +"\n" + \
        "\tNew Captor: "+ anotherGuard +"\n" \
    +"]")
endEvent

;/
    Event to handle what happens when the arrestee yields in combat against a guard.

    Actor   @akGuard: The guard that is in combat and trying to perform an arrest.
    Actor   @akYieldedArrestee: The Actor that has yielded and is about to be arrested.
/;
event OnCombatYield(Actor akGuard, Actor akYieldedArrestee)
    ; Only begin arrest if they are within this distance,
    ; this is to avoid Guards triggering their dialogue while the player has already ran away.
    if (akYieldedArrestee.GetDistance(akGuard) <= 1200)
        ; ArrestVars.SetString("Arrest::Arrest Scene", "ArrestStartFree01")
        RPB_StorageVars.SetStringOnForm("Arrest Scene", akYieldedArrestee, "ArrestStartFree01", "Arrest")
        akGuard.SendModEvent("RPB_ArrestBegin", ARREST_TYPE_ESCORT_TO_JAIL, akYieldedArrestee.GetFormID())
    endif
endEvent

;/
    Event to handle what happens when the bounty payer gets to jail to pay their bounty.
    
    Actor   @akArresterGuard: The guard that performed the arrest to take the person to pay their bounty.
    Actor   @akPayerArrestee: The actor currently detained in order to pay their bounty.
    Faction @akCrimeFaction: The crime faction this bounty's going to.
    bool    @abEscortedForcefully: Whether the bounty payer was restrained and escorted forcefully while getting to jail.
/;
event OnArrestPayBountyEnd(Actor akArresterGuard, Actor akPayerArrestee, Faction akCrimeFaction, bool abEscortedForcefully)
    if (abEscortedForcefully) ; Payer is restrained
        self.UnrestrainArrestee(akPayerArrestee)
    endif

    self.PayCrimeGold(akPayerArrestee, akCrimeFaction)

    ; Reset Bounty Payment vars
    self.SetActorWantsToPayBounty(akPayerArrestee, false)
endEvent

event OnArrestSceneChanged(Actor akArrestee, string asSceneName)
    if (akArrestee == Config.Player)
        ; ArrestVars.SetString("Arrest::Scene", asSceneName)
        RPB_StorageVars.SetStringOnForm("Scene", akArrestee, asSceneName, "Arrest")
    endif
endEvent

;/
    Event to handle what happens when the arrest goal for a specific arrestee changes.

    Actor   @akArrestee: The Actor that is currently arrested and is having their goal for the arrest changed.
    string  @asOldArrestGoal: The previous arrest goal for this Actor.
    string  @asNewArrestGoal: The new arrest goal for this Actor.
/;
event OnArrestGoalChanged(Actor akArrestee, string asOldArrestGoal, string asNewArrestGoal)
    ; ArrestVars.SetString("Arrest::Arrest Goal", asNewArrestGoal)
    RPB_StorageVars.SetStringOnForm("Arrest Goal", akArrestee, asNewArrestGoal, "Arrest")
    Debug(self, "Arrest::OnArrestGoalChanged", "Arrest Goal for Actor " + akArrestee + " was set to " + asNewArrestGoal, asOldArrestGoal == "")
    Debug(self, "Arrest::OnArrestGoalChanged", "Arrest Goal for Actor " + akArrestee + " was changed from " + asOldArrestGoal + " to " + asNewArrestGoal, asOldArrestGoal != "")
endEvent

; Prototype may be different later, like this:
; event OnArrestFailed(RPB_Captor akCaptorRef, RPB_Arrestee akArresteeRef, string asFailReason)
event OnArrestFailed(Actor akCaptor, Actor akArrestee, string asFailReason)
    Error(self, "Arrest::OnArrestFailed", asFailReason)
endEvent

event OnUpdateGameTime()
    self.ResetEludedFlag()      ; Reset Eluded Arrest flags for all Holds
    self.ResetResistedFlag()    ; Reset Resisted Arrest flags for all Holds
endEvent


RPB_Arrestee[] function GetArrestees(Actor akCaptor = none)
    if (akCaptor)
        RPB_Captor captorReference = self.GetCaptorReference(akCaptor)
        return captorReference.GetArrestees()
    endif

    ; Get all captors in Captors list
    ; Iterate through them all and get an array of all arrestees
    RPB_Arrestee[] arresteesArr = new RPB_Arrestee[128] ; how to make size dynamic in this case?
    int i = 0
    while (i < Captors.GetSize())
        
        i += 1
    endWhile
endFunction

; ==========================================================
;                 Event Handlers - Arrestee
; ==========================================================

event OnActorArrested(Actor akArrestee, Actor akArrestGuard)

endEvent

event OnArresteeDeath(Actor akArrestee, Actor akArrestGuard, Actor akKiller)

endEvent

event OnArresteeRestrained(Actor akArrestee, Actor akRestrainer)

endEvent

event OnArresteeFreed(Actor akArrestee, Actor akGuard)

endEvent

; ==========================================================
;                  Event Handlers - Captor
; ==========================================================


; ==========================================================
;                           Functions
; ==========================================================
; ==========================================================
;                      Callers to Events

;/
    Sets the arrest scene for @akArrestee.

    The verification is handled through EventManager which is then handled
    through OnArrestSceneChanged.

    Actor   @akArrestee: The arrestee from the arrest of which the scene is to be set.
    string  @asSceneName: The name of the arrest scene.
/;
function SetArrestScene(Actor akArrestee, string asSceneName)
    akArrestee.SendModEvent("RPB_SetArrestScene", asSceneName)
endFunction

;/
    Sets the primary arrest goal for @akArrestee.

    The verification is handled through EventManager which is then handled
    through OnArrestGoalChanged.

    Actor   @akArrestee: The arrestee from the arrest of which the scene is to be set.
    string  @asArrestGoal: The type of the arrest goal.
/;
function SetArrestGoal(Actor akArrestee, string asArrestGoal)
    akArrestee.SendModEvent("RPB_SetArrestGoal", asArrestGoal)
endFunction

;/
    Arrests the passed in Actor.

    The verification is handled through EventManager,
    the arrest begins with OnArrestBegin.

    Actor   @akArrester: The Actor that is performing the arrest, usually a guard.
    Actor   @akArrestee: The Actor that is to be arrested.
    string  @asArrestType: The type of the arrest, whether to escort to jail, cell, or teleport to jail or cell.
/;
function ArrestActor(Actor akArrester, Actor akArrestee, string asArrestType)
    akArrester.SendModEvent("RPB_ArrestBegin", asArrestType, akArrestee.GetFormID())
endFunction

;/
    Arrests the passed in Actors.

    Wrapper to handle multiple actors using ArrestActor()

    Actor   @akArrester: The Actor that is performing the arrest, usually a guard.
    Actor[] @akArrestees: The Actors that will be arrested.
    string  @asArrestType: The type of the arrest, whether to escort to jail, cell, or teleport to jail or cell.
    float   @afWaitTimeBetweenArrests: The delay to wait between each actor arrest, since the event can only handle one at once.
/;
function ArrestActors(Actor akArrester, Actor[] akArrestees, string asArrestType, bool abEnsureAllArrested = true, float afWaitTimeBetweenArrests = 0.3)
    int i = 0
    while (i < akArrestees.Length)
        if (akArrestees[i])
            self.ArrestActor(akArrester, akArrestees[i], asArrestType)
        endif

        Utility.Wait(afWaitTimeBetweenArrests)
        if (abEnsureAllArrested && !self.IsActorArrested(akArrestees[i])) ; If they are not arrested yet
            int arrestAttempt = 0
            int arrestTries = 20

            while (arrestAttempt < arrestTries)
                if (!self.IsActorArrested(akArrestees[i]))
                    self.ArrestActor(akArrester, akArrestees[i], asArrestType)
                    Utility.Wait(afWaitTimeBetweenArrests)
                endif

                arrestAttempt += 1
            endWhile
        endif
        i += 1
    endWhile
endFunction

;/
    Sets the passed in Actor as being eluding arrest.

    The verification is handled through EventManager,
    and it's handled by OnArrestEludeStart

    Actor   @akEludedGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akEluder: The Actor that is eluding arrest.
    string  @asEludeType: The type of the arrest elude, Dialogue or Pursuit
/;
function SetAsEluding(Actor akEludedGuard, Actor akEluder, string asEludeType)
    akEludedGuard.SendModEvent("RPB_EludingArrest", asEludeType)
endFunction

;/
    Sets the passed in Actor as being resisting arrest.

    The verification is handled through EventManager,
    and it's handled by OnArrestResist

    Actor   @akGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akResister: The Actor that is resisting arrest.
/;
function SetAsResisting(Actor akGuard, Actor akResister)
    akGuard.SendModEvent("RPB_ResistArrest", "", akResister.GetFormID())
endFunction

;/
    Sets the passed in Actor as having yielded and been spared.

    The verification is handled through EventManager,
    and it's handled by OnCombatYield

    Actor   @akSparerGuard: The Actor that is performing the arrest, usually a guard.
    Actor   @akYieldedArrestee: The Actor that has yielded and will be arrested.
/;
function SetAsYielding(Actor akSparerGuard, Actor akYieldedArrestee)
    akSparerGuard.SendModEvent("RPB_CombatYield", "", akYieldedArrestee.GetFormID())
endFunction

;/
    Starts the bounty payment scenario for @akPayerArrestee, handled by @akGuard.

    The verification is handled through EventManager,
    and it's handled by OnArrestPayBounty

    Actor   @akGuard: The Actor that is requesting the payment, usually a guard.
    Actor   @akPayerArrestee: The Actor that is going to pay the bounty.
    string  @asBountyPaymentScenario: Whether the payer will pay the bounty on the spot, be escorted willingly or restrained and escorted forcefully
/;
function StartBountyPayment(Actor akGuard, Actor akPayerArrestee, string asBountyPaymentScenario)
    akGuard.SendModEvent("RPB_PayBounty", asBountyPaymentScenario, akPayerArrestee.GetFormID())
endFunction

; ==========================================================
;                       Arrest-Specific

function BeginArrest(RPB_Arrestee akArresteeRef)
    Actor arrestee          = akArresteeRef.GetActor()
    Actor captor            = akArresteeRef.GetCaptor()
    Faction arrestFaction   = akArresteeRef.GetFaction()
    string arrestType       = akArresteeRef.GetArrestType()
    string hold             = akArresteeRef.GetHold()

    akArresteeRef.HideBounty()
    akArresteeRef.StopCombat()

    ; Actually consider the actor Arrested
    akArresteeRef.Arrest()

    ; Next step, escort/move to prison
    if (arrestType == ARREST_TYPE_TELEPORT_TO_CELL)
        akArresteeRef.MoveToPrison(abMoveDirectlyToCell = true)

    ; Could be used when the arrestee still has a chance to pay their bounty, and not go to the cell immediately
    elseif (arrestType == ARREST_TYPE_TELEPORT_TO_JAIL) ; Not implemented yet (Idea: Arrestee will be teleported to some location in jail and then either escorted or teleported to the cell)
        akArresteeRef.MoveToPrison()

    ; Will most likely be used when the arrestee has no chance to pay their bounty, and therefore will get immediately escorted into the cell
    elseif (arrestType == ARREST_TYPE_ESCORT_TO_CELL)
        akArresteeRef.EscortToPrison(abEscortDirectlyToCell = true)

    elseif (arrestType == ARREST_TYPE_ESCORT_TO_JAIL)
        akArresteeRef.EscortToPrison()

        ; Reset Arrest scene for future arrests
        self.SetArrestScene(arrestee, SceneManager.SCENE_ARREST_START_02)
    endif

    ; if (!self.GetCaptorReference(captor))
    ;     ; Bind the captor to their state script
    ;     RPB_Captor captorReference = self.MarkActorAsCaptor(captor)
    ;     captorReference.AddArrestee(akArresteeRef)
    ; endif
endFunction

function PunishPaymentEvader(Actor akGuard, Actor akPayerArrestee)
    Debug(self, "Arrest::PunishPaymentEvader", "You have strayed too far from the path, punishment is upon you!")

    int evadingPenalty = 2000
    Faction crimeFaction = akGuard.GetCrimeFaction()
    string hold = crimeFaction.GetName()

    ; Revert Bounty
    ; self.RevertBounty(akGuard.GetCrimeFaction())
    crimeFaction.ModCrimeGold(evadingPenalty)

    CaptorRef.AssignArrestee(none)
    BindAliasTo(CaptorRef, none)
    akGuard.StartCombat(akPayerArrestee)

    ; Reset Bounty Payment vars
    self.SetActorWantsToPayBounty(akPayerArrestee, false)
    self.SetArrestGoal(akPayerArrestee, ARREST_GOAL_IMPRISONMENT)

    Config.NotifyArrest("You have gained " + evadingPenalty + " bounty in " + hold + " for evading bounty payment!")
endFunction

function ChangeArrestEscort(Actor akNewEscort, Actor akDetainee)
    ; A new guard was found, escort Detainee to jail
    ArrestVars.SetReference("Arrest::Arresting Guard", akNewEscort) ; Change the captor for further scenes and to lead to the cell
    BindAliasTo(CaptorRef, akNewEscort)
    sceneManager.StartEscortToJail(akNewEscort, ArrestVars.Arrestee, ArrestVars.PrisonerItemsContainer)
endFunction

; TODO: Determine what to use this for, I don't think it's in use right now
function ReleaseDetainee(Actor akCaptor, Actor akDetainee)
    ; Revert Bounty
    Faction crimeFaction = akCaptor.GetCrimeFaction()
    crimeFaction.SetCrimeGold(ArrestVars.BountyNonViolent)
    crimeFaction.SetCrimeGoldViolent(ArrestVars.BountyViolent)

    RPB_StorageVars.DeleteCategoryOnForm(akDetainee, "Arrest")

    ; ArrestVars.Remove("Arrest::Captured")
    ; ArrestVars.Remove("Arrest::Arrest Faction")
    ; ArrestVars.Remove("Arrest::Hold")
    ; ArrestVars.Remove("Arrest::Arrestee")
    ; ArrestVars.Remove("Arrest::Arrest Type")
    ; ArrestVars.Remove("Arrest::Arrested")
    ; ArrestVars.Remove("Arrest::Time of Arrest")

    self.AllowArrestForcegreets()
    Game.SetPlayerAIDriven(false)
endFunction

function ApplyArrestResistedPenalty(Faction akArrestFaction)
    string hold = akArrestFaction.GetName()

    int resistBountyFlat                    = config.GetArrestAdditionalBountyResistingFlat(hold)
    float resistBountyFromCurrentBounty     = GetPercentAsDecimal(config.GetArrestAdditionalBountyResistingFromCurrentBounty(hold))
    int resistArrestPenalty                 = int_if (resistBountyFromCurrentBounty > 0, floor(akArrestFaction.GetCrimeGold() * resistBountyFromCurrentBounty)) + resistBountyFlat

    if (resistArrestPenalty > 0)
        akArrestFaction.ModCrimeGold(resistArrestPenalty)
        config.NotifyArrest("You have gained " + resistArrestPenalty + " Bounty in " + hold +" for resisting arrest!")
    endif

    Actor arrestResister = config.Player ; Temporary

    ActorVars.IncrementStat("Arrests Resisted", akArrestFaction, arrestResister)
    self.SetResistedFlag(akArrestFaction)
endFunction

function SetAsDefeated(Faction akCrimeFaction)
    if (!self.HasResistedArrestRecently(akCrimeFaction))
        ; Do not punish if the player hasn't resisted arrest upon being defeated
        return
    endif

    string hold = akCrimeFaction.GetName()

    int defeatBountyFlat                = config.GetArrestAdditionalBountyDefeatedFlat(hold)
    float defeatBountyFromCurrentBounty = config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)
    float defeatBountyPercentModifier   = GetPercentAsDecimal(defeatBountyFromCurrentBounty)
    int defeatArrestPenalty             = floor(akCrimeFaction.GetCrimeGold() * defeatBountyPercentModifier) + defeatBountyFlat

    Debug(self, "Arrest::SetAsDefeated", "\n" +  \
        "defeatBountyFlat: " + defeatBountyFlat + "\n" + \
        "defeatBountyFromCurrentBounty: " + defeatBountyFromCurrentBounty + "\n" + \
        "defeatBountyPercentModifier: " + defeatBountyPercentModifier  + "\n" + \
        "defeatArrestPenalty: " + defeatArrestPenalty  + "\n" \
    )

    if (defeatArrestPenalty > 0)
        ArrestVars.ModInt("Arrest::Bounty Non-Violent", defeatArrestPenalty)
        config.NotifyArrest("You have gained " + defeatArrestPenalty + " Bounty in " + hold +" for being defeated")
    endif
endFunction

;/
    Sets the arrest resisted flag to true.
    While the flag is active, further arrests of this faction will no longer incur a penalty upon resisting again. 
    This is to prevent multiple guards trying to arrest the player
    and eventually end up with multiple penalties from each guard for something that should only be punished once.
    After some time, this flag will be set to false and the next arrest will be punished once again.
    For more info, see the Resisted state

    Faction     @akFaction: The arresting faction
/;
function SetResistedFlag(Faction akFaction)
    ArrestVars.SetBool("Arrest::"+ akFaction.GetName() +"::Arrest Resisted", true) ; Set arrest resisted flag
    RPB_StorageVars.SetBoolOnForm("Arrest Resisted", Config.Player, true, "Arrest") ; Set arrest resisted flag
endFunction

;/
    Sets the Eluded Arrest flag to be active.
    While this flag is active, further arrest attempts of this Faction will no longer incur a penalty upon eluding again.

    This is to prevent multiple guards attempting to arrest the player and eventually end up with multiple penalties from each
    guard for something that should only be punished once.

    After some time, this flag will be inactive again and the next arrest attempt will be punished once again.

    Faction     @akFaction: The arresting faction
/;
function SetEludedFlag(Faction akFaction)
    ArrestVars.SetBool("Arrest::"+ akFaction.GetName() +"::Arrest Eluded", true) ; Set arrest eluded flag
    RPB_StorageVars.SetBoolOnForm("Arrest Eluded", Config.Player, true, "Arrest") ; Set arrest eluded flag
    RegisterForDelayedEventGameTime("Eluding", 1.0)
endFunction

;/
    Resets the arrest resisted flag for all the holds.

    This flag is used to determine whether an actor should be punished for resisting arrest,
    and is set to true upon resisting, and for the remainder of that time, no further resists will
    incur another penalty, unless enough time has passed to where the flag gets set to false here
    in this function, at which point the resist will be punished again.
/;
function ResetResistedFlag()
    int i = 0
    while (i < miscVars.GetLengthOf("Holds"))
        string hold = miscVars.GetStringFromArray("Holds", i) ; To be tested
        string arrestResistKey = "Arrest::"+ hold +"::Arrest Resisted"

        if (ArrestVars.Exists(arrestResistKey))
            ArrestVars.Remove(arrestResistKey)
            Info(self, "Arrest::ResetResistedFlag", "The resist arrest flag for " + hold +" has been reset.")
        endif
        i += 1
    endWhile
endFunction

function ResetEludedFlag()
    Debug(self, "Arrest::ResetEludedFlag", "This is called")
    int i = 0
    while (i < miscVars.GetLengthOf("Holds"))
        string hold = miscVars.GetStringFromArray("Holds", i) ; To be tested
        string arrestEludeKey = "Arrest::"+ hold +"::Arrest Eluded"

        if (ArrestVars.Exists(arrestEludeKey))
            ArrestVars.Remove(arrestEludeKey)
            Info(self, "Arrest::ResetEludedFlag", "The eluding arrest flag for " + hold +" has been reset.")
        endif
        i += 1
    endWhile
endFunction

function ApplyArrestEludedPenalty(Faction akArrestFaction)
    if (self.HasEludedArrestRecently(akArrestFaction))
        Info(self, "Arrest::ApplyArrestEludedPenalty", "You have already eluded arrest recently, no bounty will be added as it most likely is the same arrest.")
        return
    endif

    string hold = akArrestFaction.GetName()

    int eludeBountyFlat = config.GetArrestAdditionalBountyEludingFlat(akArrestFaction.GetName())
    float eludeBountyPercent = GetPercentAsDecimal(config.GetArrestAdditionalBountyEludingFromCurrentBounty(akArrestFaction.GetName()))
    int totalEludeBounty = int_if (eludeBountyPercent > 0, round(akArrestFaction.GetCrimeGold() * eludeBountyPercent)) + eludeBountyFlat

    if (totalEludeBounty > 0)
        akArrestFaction.ModCrimeGold(totalEludeBounty)
        config.NotifyArrest("You have gained " + totalEludeBounty + " Bounty in " + hold + " for eluding arrest!")
    endif

    ArrestVars.SetBool("Arrest::Eluded", true)
    self.SetEludedFlag(akArrestFaction)
endFunction

;/
    Refactor idea:
    Have an ArresteeRef or SuspectRef script that is attached to each character arrested, storing their arrest state and then:
    Arrestee.ApplyDefeatedPenalty()
    Since the state is known, the hold, bounty and everything will be handled internally by the function without any need for params
/;
function ApplyArrestDefeatedPenalty(Faction akArrestFaction)
    string hold = akArrestFaction.GetName()

    ; Setup Defeated penalties
    ; Helper.GetArrestAdditionalBountyOnDefeat(hold)
    ; ArrestVars.SetInt("Arrest::Bounty for Defeat", Helper.GetArrestAdditionalBountyOnDefeat(hold))

    ; ArrestVars.SetInt("Arrest::Additional Bounty when Defeated", config.GetArrestAdditionalBountyDefeatedFlat(hold))
    ; ArrestVars.SetFloat("Arrest::Additional Bounty when Defeated from Current Bounty", GetPercentAsDecimal(config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold)))
    ; ArrestVars.SetInt("Arrest::Bounty for Defeat", int_if (ArrestVars.DefeatedAdditionalBountyPercentage > 0, round(akArrestFaction.GetCrimeGold() * ArrestVars.DefeatedAdditionalBountyPercentage)) + ArrestVars.DefeatedAdditionalBounty)
    ; ArrestVars.SetBool("Arrest::Defeated", true)

    RPB_StorageVars.SetIntOnForm("Additional Bounty when Defeated", Config.Player, Config.GetArrestAdditionalBountyDefeatedFlat(hold), "Arrest")
    RPB_StorageVars.SetFloatOnForm("Additional Bounty when Defeated from Current Bounty", Config.Player, Config.GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold), "Arrest")
    RPB_StorageVars.SetIntOnForm("Bounty for Defeat", Config.Player, int_if (ArrestVars.DefeatedAdditionalBountyPercentage > 0, round(akArrestFaction.GetCrimeGold() * ArrestVars.DefeatedAdditionalBountyPercentage)) + ArrestVars.DefeatedAdditionalBounty, "Arrest")
    RPB_StorageVars.SetBoolOnForm("Defeated", Config.Player, true, "Arrest")

    ; Bounty is applied later at the Arrest stage.
endFunction



bool function MeetsPursuitEludeRequirements(Actor akEluder)
    return akEluder.IsRunning() || akEluder.IsSprinting()
endFunction

bool function HasResistedArrestRecently(Faction akArrestFaction)
    return ArrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Resisted")
endFunction

bool function HasEludedArrestRecently(Faction akArrestFaction)
    return ArrestVars.GetBool("Arrest::" + akArrestFaction.GetName() + "::Arrest Eluded")
endFunction

function SetEludedGuard(Actor akEludedGuard, string asEludeType)
    ArrestVars.SetActor("Arrest::Eluded Captor", akEludedGuard)
    ArrestVars.SetString("Arrest::Elude Type", asEludeType)
endFunction

function TriggerForcegreetEluding(Actor akEludedGuard)
    Debug(self, "Arrest::TriggerForcegreetEluding", "Distance from Speaker: " + akEludedGuard.GetDistance(akEludedGuard.GetDialogueTarget()))
    self.SetEludedGuard(akEludedGuard, "Dialogue")
    SceneManager.StartEludingArrest(akEludedGuard, config.Player)
endFunction

function TriggerPursuitEluding(Actor akEludedGuard)
    self.SetEludedGuard(akEludedGuard, "Pursuit")
    RegisterForDelayedEvent("Eluding", config.ArrestEludeWarningTime) ; Register for a delayed event on Eluding::OnUpdate()
endFunction

function AddBountyGainedWhileJailed(Faction akArrestFaction)
    ArrestVars.ModInt("Jail::Bounty Non-Violent", akArrestFaction.GetCrimeGoldNonViolent())
    ArrestVars.ModInt("Jail::Bounty Violent", akArrestFaction.GetCrimeGoldViolent())
    ClearBounty(akArrestFaction)
endFunction

function SetActorWantsToPayBounty(Actor akPayerArrestee, bool abWantsToPay = true)
    ArrestVars.SetBool("Arrest::Paying Bounty" , abWantsToPay)
    Debug(self, "Arrest::SetActorWantsToPayBounty", "Arrest::Paying Bounty: " + ArrestVars.GetBool("Arrest::Paying Bounty"))
endFunction

bool function GetActorIsPayingBounty(Actor akPayerArrestee)
    return ArrestVars.GetBool("Arrest::Paying Bounty")
endFunction

string function GetArrestScene(Actor akArrestee, string asFallbackScene = "RPB_ArrestStart02")
    if (akArrestee == Config.Player)

        ; return RPB_StorageVars.GetStringOnForm("Scene", akArrestee, "Arrest")

        if (ArrestVars.Exists("Arrest::Scene"))
            return ArrestVars.GetString("Arrest::Scene")
        endif

        return asFallbackScene
    endif
endFunction

string function GetArrestGoal(Actor akArrestee)
    return RPB_StorageVars.GetStringOnForm("Arrest Goal", akArrestee, "Arrest")
    return ArrestVars.GetString("Arrest::Arrest Goal")
endFunction

bool function IsActorToBeImprisoned(Actor akArrestee)
    return self.GetArrestGoal(akArrestee) == ARREST_GOAL_IMPRISONMENT
endFunction

bool function IsActorToPayBounty(Actor akArrestee)
    return self.GetArrestGoal(akArrestee) == ARREST_GOAL_BOUNTY_PAYMENT
endFunction

function PayCrimeGold(Actor akPayer, Faction akCrimeFaction)
    if (akPayer == Config.Player) ; Later this should be dynamic for all Actors without a condition
        int currentBountyNonViolent = ArrestVars.GetInt("Arrest::Bounty Non-Violent")
        int currentBountyViolent    = ArrestVars.GetInt("Arrest::Bounty Violent")
        int totalBounty = currentBountyNonViolent + currentBountyViolent
        Form gold = Game.GetFormEx(0xF)
        akPayer.RemoveItem(gold, totalBounty, true)

        ; Clear Bounty
        ArrestVars.Remove("Arrest::Bounty Non-Violent")
        ArrestVars.Remove("Arrest::Bounty Violent")
        akCrimeFaction.PlayerPayCrimeGold(false, false)

        Config.NotifyArrest("Your bounty in " + akCrimeFaction.GetName() + " has been paid")
    endif
endFunction

function ResetArrest(string reason = "")
    ; Clear all arrest related vars
    ArrestVars.Clear()
    Info(self, "ResetArrest", reason, reason != "")
endFunction

; ==========================================================
;                           Utility
;/
    Registers a delayed event through a state's OnUpdate()

    string  @stateName: The name of the state that represents the event name
    float   @delaySeconds: The time waited in seconds before the event is fired
/;
function RegisterForDelayedEvent(string stateName, float delaySeconds)
    RegisterForSingleUpdate(delaySeconds)
    GotoState(stateName)
endFunction

;/
    Registers a delayed event through a state's OnUpdateGameTime()

    string  @stateName: The name of the state that represents the event name
    float   @delayGameTime: The time waited in game-time before the event is fired (1 = 1 Day | 1/24 = 1h)
/;
function RegisterForDelayedEventGameTime(string stateName, float delayGameTime)
    RegisterForSingleUpdateGameTime(delayGameTime)
    GotoState(stateName)
endFunction

function RestrainArrestee(Actor akArrestee)
    ; Hand Cuffs Backside Rusty - 0xA081D2F
    ; Hand Cuffs Front Rusty - 0xA081D33
    ; Hand Cuffs Front Shiny - 0xA081D34
    ; Hand Cuffs Crossed Front 01 - 0xA033D9D
    ; Hands Crossed Front in Scarfs - 0xA073A14
    ; Hands in Irons Front Black - 0xA033D9E
    Form cuffs = Game.GetFormEx(0xA081D2F)
    akArrestee.SheatheWeapon()
    UnequipHandsForActor(akArrestee)
    akArrestee.EquipItem(cuffs, true, true)
endFunction

function UnrestrainArrestee(Actor akRestrainedArrestee)
    Form restraints = akRestrainedArrestee.GetEquippedArmorInSlot(59)
    akRestrainedArrestee.UnequipItemSlot(59)
    akRestrainedArrestee.RemoveItem(restraints)
    ReleaseAI()
endFunction

; ==========================================================
;                  Validation & Maintenance

function RegisterHotkeys()
    RegisterForKey(0x58) ; F12
    RegisterForKey(0x57) ; F11
    RegisterForKey(0x44) ; F10
    RegisterForKey(0x42) ; F8
    RegisterForKey(0x41) ; F7
    RegisterForKey(0x40) ; F6
endFunction

function AllowArrestForcegreets(bool allow = true)
    ; Allow/Disallow Forcegreets (used in AI package RPB_DGForcegreet for Arrest eludes)
    GlobalVariable RPB_AllowArrestForcegreet = GetFormFromMod(0x130D7) as GlobalVariable
    RPB_AllowArrestForcegreet.SetValueInt(int_if (allow, 1, 0))
endFunction

function SetupArrestPayableBountyVars(Faction akCrimeFaction)
    GlobalVariable RPB_ArrestGuaranteedPayableBounty = GetFormFromMod(0x161D2) as GlobalVariable
    GlobalVariable RPB_ArrestMaxPayableBounty        = GetFormFromMod(0x161D4) as GlobalVariable
    GlobalVariable RPB_ArrestRollDiceResult          = GetFormFromMod(0x16737) as GlobalVariable
    GlobalVariable RPB_ArrestAllowFrisk              = GetFormFromMod(0x1776A) as GlobalVariable
    
    string hold = akCrimeFaction.GetName()

    ; Update Globals (Determines if the arrest will be payable for sure, or if it falls within the maximum payable, which needs a roll of the dice)
    RPB_ArrestGuaranteedPayableBounty.SetValueInt(Config.GetArrestGuaranteedPayableBounty(hold))
    RPB_ArrestMaxPayableBounty.SetValueInt(Config.GetArrestMaximumPayableBounty(hold))
    RPB_ArrestAllowFrisk.SetValueInt(Config.IsFriskingEnabled(hold) as int)

    ; Roll the dice for max payable bounty chance
    int maxPayableChance = Config.GetArrestMaximumPayableChance(hold)
    int random = Utility.RandomInt(1, 100)
    RPB_ArrestRollDiceResult.SetValueInt(int_if (random <= maxPayableChance, 1, 0)) ; 1 = able to pay max bounty / 0 = not able
    Debug(self, "Arrest::SetupArrestPayableBountyVars", "Needed: <= " + maxPayableChance + ", Got: " + random)

    Trace(self, "Arrest::SetupArrestPayableBountyVars", "Stack Trace: [\n" + \
        "\tRPB_ArrestGuaranteedPayableBounty: " + RPB_ArrestGuaranteedPayableBounty.GetValueInt() + "\n" + \
        "\tRPB_ArrestMaxPayableBounty: " + RPB_ArrestMaxPayableBounty.GetValueInt() + "\n" + \
        "\tRPB_ArrestRollDiceResult: " + RPB_ArrestRollDiceResult.GetValueInt() + "\n" + \
        "\tmaxPayableChance: " + maxPayableChance + "\n" + \
        "\trandom: " + random + "\n" + \
        "\tAble to Pay Max Bounty: " + (random <= maxPayableChance) + "\n" + \
        "\takCrimeFaction: " + akCrimeFaction + "\n" + \
    "\n]")
endFunction

function ResetDiceRollForMaxPayableBounty()
    GlobalVariable RPB_ArrestRollDiceResult = GetFormFromMod(0x16737) as GlobalVariable
    RPB_ArrestRollDiceResult.SetValueInt(0)
endFunction

bool function IsValidArrestGoal(string asArrestGoal)
    return  asArrestGoal == ARREST_GOAL_IMPRISONMENT || \
            asArrestGoal == ARREST_GOAL_BOUNTY_PAYMENT || \
            asArrestGoal == ARREST_GOAL_TEMPORARY_HOLD
endFunction

bool function ValidateArrestType(string arrestType)
    return  arrestType == ARREST_TYPE_TELEPORT_TO_JAIL || \ 
            arrestType == ARREST_TYPE_TELEPORT_TO_CELL || \ 
            arrestType == ARREST_TYPE_ESCORT_TO_JAIL || \
            arrestType == ARREST_TYPE_ESCORT_TO_CELL
endFunction

string function GetValidArrestTypes()
    return  ARREST_TYPE_TELEPORT_TO_JAIL + ", " + \ 
            ARREST_TYPE_TELEPORT_TO_CELL + ", " + \ 
            ARREST_TYPE_ESCORT_TO_JAIL + ", " + \ 
            ARREST_TYPE_ESCORT_TO_CELL
endFunction

; ==========================================================
;                   States & Delayed Events
; ==========================================================

state Eluding
    event OnBeginState()
        Debug(self, "Arrest::OnBeginState", "Begin State " + self.GetState())
    endEvent

    event OnUpdate()
        ; string eludeType = ArrestVars.GetString("Arrest::Elude Type")
        string eludeType = RPB_StorageVars.GetString("Elude Type", "Arrest")

        if (eludeType == "Pursuit")
            if (self.MeetsPursuitEludeRequirements(Config.Player))
                Actor eludedCaptor = ArrestVars.GetActor("Arrest::Eluded Captor")
                self.OnArrestEludeTriggered(eludedCaptor, eludeType) ; Explicitly call Event
            endif
        endif

        GotoState("")
    endEvent

    event OnEndState()
        Debug(self, "Arrest::OnStartState", "End State " + self.GetState())
    endEvent
endState
