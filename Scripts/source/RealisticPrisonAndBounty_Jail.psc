scriptname RealisticPrisonAndBounty_Jail extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import PO3_SKSEFunctions

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property arrest
    RealisticPrisonAndBounty_Arrest function get()
        return config.Arrest
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return config.MiscVars
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager property SceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return config.SceneManager
    endFunction
endProperty

string property STATE_JAILED    = "Jailed" autoreadonly
string property STATE_ESCAPING  = "Escaping" autoreadonly
string property STATE_ESCAPED   = "Escaped" autoreadonly
string property STATE_RELEASED  = "Released" autoreadonly
string property STATE_FREE      = "Free" autoreadonly

string property CurrentState
    string function get()
        return self.GetState()
    endFunction
endProperty

; ==========================================================
;                       Infamy Messages
; ==========================================================
;/
    Properties used to determine if infamy messages have fired at least once,
    determines for both Recognized and Known thresholds
/;
bool property HasInfamyRecognizedNotificationFired
    bool function get()
        return miscVars.GetBool("Jail::Infamy Recognized Threshold Notification")
    endFunction
endProperty

bool property HasInfamyKnownNotificationFired
    bool function get()
        return miscVars.GetBool("Jail::Infamy Known Threshold Notification")
    endFunction
endProperty

string property InfamyRecognizedSentenceAppliedNotification
    string function get()
        return "Due to being a recognized criminal in the hold, your sentence was extended"
    endFunction
endProperty

string property InfamyKnownSentenceAppliedNotification
    string function get()
        return "Due to being a known criminal in the hold, your sentence was extended"
    endFunction
endProperty

; ==========================================================

string property Hold
    string function get()
        return arrestVars.GetString("Arrest::Hold")
    endFunction
endProperty

Actor property Arrestee
    Actor function get()
        return arrestVars.GetForm("Arrest::Arrestee") as Actor
    endFunction
endProperty

RealisticPrisonAndBounty_CaptorRef property Captor auto
RealisticPrisonAndBounty_PrisonerRef property Prisoner auto

function RegisterEvents()

endFunction

function SetupJailVars()
    float x = StartBenchmark()
    arrestVars.SetBool("Jail::Infamy Enabled", config.IsInfamyEnabled(Hold))
    arrestVars.SetFloat("Jail::Infamy Recognized Threshold", config.GetInfamyRecognizedThreshold(Hold))
    arrestVars.SetFloat("Jail::Infamy Known Threshold", config.GetInfamyKnownThreshold(Hold))
    arrestVars.SetFloat("Jail::Infamy Gained Daily from Current Bounty", config.GetInfamyGainedDailyFromArrestBounty(Hold))
    arrestVars.SetFloat("Jail::Infamy Gained Daily", config.GetInfamyGainedDaily(Hold))
    arrestVars.SetInt("Jail::Infamy Gain Modifier (Recognized)", config.GetInfamyGainModifier(Hold, "Recognized"))
    arrestVars.SetInt("Jail::Infamy Gain Modifier (Known)", config.GetInfamyGainModifier(Hold, "Known"))
    arrestVars.SetFloat("Jail::Bounty Exchange", config.GetJailBountyExchange(Hold))
    arrestVars.SetFloat("Jail::Bounty to Sentence", config.GetJailBountyToSentence(Hold))
    arrestVars.SetFloat("Jail::Minimum Sentence", config.GetJailMinimumSentence(Hold))
    arrestVars.SetFloat("Jail::Maximum Sentence", config.GetJailMaximumSentence(Hold))
    arrestVars.SetFloat("Jail::Cell Search Thoroughness", config.GetJailCellSearchThoroughness(Hold))
    arrestVars.SetString("Jail::Cell Lock Level", config.GetJailCellDoorLockLevel(Hold))
    arrestVars.SetBool("Jail::Fast Forward", config.IsJailFastForwardEnabled(Hold))
    arrestVars.SetFloat("Jail::Day to Fast Forward From", config.GetJailFastForwardDay(Hold))
    arrestVars.SetString("Jail::Handle Skill Loss", config.GetJailHandleSkillLoss(Hold))
    arrestVars.SetFloat("Jail::Day to Start Losing Skills", config.GetJailDayToStartLosingSkills(Hold))
    arrestVars.SetFloat("Jail::Chance to Lose Skills", config.GetJailChanceToLoseSkillsDaily(Hold))
    arrestVars.SetFloat("Jail::Recognized Criminal Penalty", config.GetJailRecognizedCriminalPenalty(Hold))
    arrestVars.SetFloat("Jail::Known Criminal Penalty", config.GetJailKnownCriminalPenalty(Hold))
    arrestVars.SetFloat("Jail::Bounty to Trigger Infamy", config.GetJailBountyToTriggerCriminalPenalty(Hold))
    arrestVars.SetBool("Release::Release Fees Enabled", config.IsJailReleaseFeesEnabled(Hold))
    arrestVars.SetFloat("Release::Chance for Release Fees Event", config.GetReleaseChanceForReleaseFeesEvent(Hold))
    arrestVars.SetFloat("Release::Bounty to Owe Fees", config.GetReleaseBountyToOweFees(Hold))
    arrestVars.SetFloat("Release::Release Fees from Arrest Bounty", config.GetReleaseReleaseFeesFromBounty(Hold))
    arrestVars.SetFloat("Release::Release Fees Flat", config.GetReleaseReleaseFeesFlat(Hold))
    arrestVars.SetFloat("Release::Days Given to Pay Release Fees", config.GetReleaseDaysGivenToPayReleaseFees(Hold))
    arrestVars.SetBool("Release::Item Retention Enabled", config.IsItemRetentionEnabledOnRelease(Hold))
    arrestVars.SetFloat("Release::Bounty to Retain Items", config.GetReleaseBountyToRetainItems(Hold))
    arrestVars.SetBool("Release::Redress on Release", config.IsAutoDressingEnabledOnRelease(Hold))
    arrestVars.SetFloat("Escape::Escape Bounty from Current Arrest", config.GetEscapedBountyFromCurrentArrest(Hold))
    arrestVars.SetFloat("Escape::Escape Bounty Flat", config.GetEscapedBountyFlat(Hold))
    arrestVars.SetBool("Escape::Allow Surrendering", config.IsSurrenderEnabledOnEscape(Hold))
    arrestVars.SetBool("Escape::Account for Time Served", config.IsTimeServedAccountedForOnEscape(Hold))
    arrestVars.SetBool("Escape::Should Frisk Search", config.ShouldFriskOnEscape(Hold))
    arrestVars.SetBool("Escape::Should Strip Search", config.ShouldStripOnEscape(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Impersonation", config.GetChargeBountyForImpersonation(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Enemy of Hold", config.GetChargeBountyForEnemyOfHold(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Stolen Items", config.GetChargeBountyForStolenItems(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Stolen Item", config.GetChargeBountyForStolenItemFromItemValue(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Contraband", config.GetChargeBountyForContraband(Hold))
    arrestVars.SetFloat("Additional Charges::Bounty for Cell Key", config.GetChargeBountyForCellKey(Hold))
    arrestVars.SetBool("Frisking::Allow Frisking", config.IsFriskingEnabled(Hold))
    arrestVars.SetBool("Frisking::Unconditional Frisking", config.IsFriskingUnconditional(Hold))
    arrestVars.SetFloat("Frisking::Bounty for Frisking", config.GetFriskingBountyRequired(Hold))
    arrestVars.SetFloat("Frisking::Frisking Thoroughness", config.GetFriskingThoroughness(Hold))
    arrestVars.SetBool("Frisking::Confiscate Stolen Items", config.IsFriskingStolenItemsConfiscated(Hold))
    arrestVars.SetBool("Frisking::Strip if Stolen Items Found", config.IsFriskingStripSearchWhenStolenItemsFound(Hold))
    arrestVars.SetFloat("Frisking::Stolen Items Required for Stripping", config.GetFriskingStolenItemsRequiredForStripping(Hold))
    arrestVars.SetBool("Stripping::Allow Stripping", config.IsStrippingEnabled(Hold))
    arrestVars.SetString("Stripping::Handle Stripping On", config.GetStrippingHandlingCondition(Hold))
    arrestVars.SetInt("Stripping::Bounty to Strip", config.GetStrippingMinimumBounty(Hold))
    arrestVars.SetInt("Stripping::Violent Bounty to Strip", config.GetStrippingMinimumViolentBounty(Hold))
    arrestVars.SetInt("Stripping::Sentence to Strip", config.GetStrippingMinimumSentence(Hold))
    arrestVars.SetBool("Stripping::Strip when Defeated", config.IsStrippedOnDefeat(Hold))
    arrestVars.SetFloat("Stripping::Stripping Thoroughness", config.GetStrippingThoroughness(Hold))
    arrestVars.SetInt("Stripping::Stripping Thoroughness Modifier", config.GetStrippingThoroughnessBountyModifier(Hold))
    arrestVars.SetBool("Clothing::Allow Clothing", config.IsClothingEnabled(Hold))
    arrestVars.SetString("Clothing::Handle Clothing On", config.GetClothingHandlingCondition(Hold))
    arrestVars.SetFloat("Clothing::Maximum Bounty to Clothe", config.GetClothingMaximumBounty(Hold))
    arrestVars.SetFloat("Clothing::Maximum Violent Bounty to Clothe", config.GetClothingMaximumViolentBounty(Hold))
    arrestVars.SetFloat("Clothing::Maximum Sentence to Clothe", config.GetClothingMaximumSentence(Hold))
    arrestVars.SetBool("Clothing::Clothe when Defeated", config.IsClothedOnDefeat(Hold))
    arrestVars.SetString("Clothing::Outfit", config.GetClothingOutfit(Hold))

    ; Outfit
    arrestVars.SetString("Clothing::Outfit::Name", config.GetClothingOutfit(Hold))
    arrestVars.SetForm("Clothing::Outfit::Head", config.GetOutfitPart(Hold, "Head"))
    arrestVars.SetForm("Clothing::Outfit::Body", config.GetOutfitPart(Hold, "Body"))
    arrestVars.SetForm("Clothing::Outfit::Hands", config.GetOutfitPart(Hold, "Hands"))
    arrestVars.SetForm("Clothing::Outfit::Feet", config.GetOutfitPart(Hold, "Feet"))
    arrestVars.SetBool("Clothing::Outfit::Conditional", config.IsClothingOutfitConditional(Hold))
    arrestVars.SetFloat("Clothing::Outfit::Minimum Bounty", config.GetClothingOutfitMinimumBounty(Hold))
    arrestVars.SetFloat("Clothing::Outfit::Maximum Bounty", config.GetClothingOutfitMaximumBounty(Hold))

    arrestVars.SetBool("Override::Release::Item Retention Enabled", false)
    ; arrestVars.SetInt("Override::Jail::Minimum Sentence", 1)
    ; arrestVars.SetString("Override::Stripping::Handle Stripping On", "Unconditionally")
    ; arrestVars.SetString("Override::Clothing::Handle Clothing On", "Unconditionally")
    EndBenchmark(x, "SetupJailVars")
endFunction

int function GetCellDoorLockLevel()
    string configuredLockLevel = arrestVars.GetString("Jail::Cell Lock Level")
    return  int_if (configuredLockLevel == "Novice", 1, \
            int_if (configuredLockLevel == "Apprentice", 25, \
            int_if (configuredLockLevel == "Adept", 50, \
            int_if (configuredLockLevel == "Expert", 75, \
            int_if (configuredLockLevel == "Master", 100, \
            int_if (configuredLockLevel == "Requires Key", 255))))))
endFunction

function ShowArrestVars()
    Debug(self, "ShowArrestVars", "\n" + Hold + " Arrest Vars: " + GetContainerList(arrestVars.GetHandle()))
endFunction

function ShowArrestParams()
    int arrestParams = arrestVars.GetObject("Arrest::Arrest Params")
    int arrestParamsObj = JMap.getObj(arrestVars.GetHandle(), "Arrest::Arrest Params")
    int arrestParamsBV = JMap.getInt(arrestVars.GetHandle(), "Arrest::Bounty Violent")
    bool isObject = JValue.isMap(arrestParamsObj)
    Debug(self, "ShowArrestParams (id: "+ arrestParamsObj +", isObject: "+ isObject +", arrestParamsBV: "+ arrestParamsBV +")", "\n" + Hold + " Arrest Params: " + GetContainerList(arrestParams))
endFunction

; event OnJailedBegin(string eventName, string strArg, float numArg, Form sender)
;     self.SetupJailVars()
;     Prisoner.ForceRefTo(arrestVars.Arrestee) ; To be changed later to ActiveMagicEffect in order to attach to multiple Actors
;     Prisoner.SetupPrisonerVars()
;     GotoState(STATE_JAILED)
;     self.TriggerImprisonment()
; endEvent

event OnJailBegin()
    self.SetupJailVars()
    Prisoner.ForceRefTo(arrestVars.Arrestee) ; To be changed later to ActiveMagicEffect in order to attach to multiple Actors
    Prisoner.SetupPrisonerVars()
    GotoState(STATE_JAILED)
    self.TriggerImprisonment()
endEvent

event OnJailedEnd(string eventName, string strArg, float numArg, Form sender)
    Debug(self, "OnJailedEnd", "Ending jailing process... (Released, Escaped?)")
    arrestVars.Clear()
endEvent

state Jailed
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin", config.IS_DEBUG)

        ; First jail update
        Prisoner.RegisterLastUpdate()
        RegisterForSingleUpdateGameTime(1.0)
    endEvent
 
    event OnFriskBegin(Actor friskSearchPerformer, Actor actorToFrisk)
        ; Happens when the actor is beginning to be frisked
    endEvent

    event OnFriskEnd(Actor friskSearchPerformer, Actor friskedActor)
        ; Happens when the actor has been frisked
        if (arrestVars.IsStrippingEnabled)
            ; We dont use ShouldBeStripped since it contains bounty and sentence conditions,
            ; here we already know we want the actor to be stripped because of the Frisking condition,
            ; so we only need to check if stripping is enabled
            int stolenItemsFound = 0 ; Logic to be determined
            bool shouldStripSearchStolenItemsFound  = arrestVars.GetBool("Frisking::Strip if Stolen Items Found")
            int stolenItemsRequiredToStrip          = arrestVars.GetInt("Frisking::Stolen Items Required for Stripping")
            bool meetsStolenItemsCriteriaToStrip    = stolenItemsFound >= stolenItemsRequiredToStrip

            if (shouldStripSearchStolenItemsFound && meetsStolenItemsCriteriaToStrip)
                Prisoner.Strip()
            endif

        endif
    endEvent

    event OnStripBegin(Actor stripSearchPerformer, Actor actorToStrip)
        ; Happens when the actor is about to be stripped
    endEvent

    event OnStripEnd(Actor stripSearchPerformer, Actor strippedActor)
        ; Happens when the actor has been stripped
        Prisoner.Strip()
        arrestVars.Captor.EvaluatePackage() ; temp
        ; Game.SetPlayerAIDriven(false)
        debug.notification("Jail::OnStripEnd")
        sceneManager.StartEscortToCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.JailCell, arrestVars.CellDoor)
    endEvent

    event OnEscortToCellBegin(Actor escortActor, Actor escortedActor)
        ; Happens when the actor is being escorted to their cell
    endEvent

    event OnEscortToCellEnd(Actor escortActor, Actor escortedActor)
        ; Happens when the actor has been escorted to their cell
    endEvent

    event OnEscortFromCellBegin(Actor escortActor, Actor escortedActor, ObjectReference destination)
        ; Happens when the actor is being escorted from their cell to the destination
    endEvent

    event OnEscortFromCellEnd(Actor escortActor, Actor escortedActor, ObjectReference destination)
        ; Happens when the actor has been escorted from their cell to the destination
    endEvent

    event OnActorCuffed(Actor cuffedActor, bool hands, bool feet)
        ; Happens when the actor has been cuffed (hands bound, maybe feet?)
    endEvent

    event OnActorUncuffed(Actor uncuffedActor, bool hands, bool feet)
        ; Happens when the actor has been uncuffed (hands unbound, maybe feet?)
    endEvent

    event OnUndressed(Actor undressedActor)
        ; Actor should be undressed at this point
        if (Prisoner.ShouldBeClothed())
            Prisoner.Clothe()
        endif

        Debug(self, "OnUndressed", "undressedActor: " + undressedActor, config.IS_DEBUG)
    endEvent

    event OnClothed(Actor clothedActor, RealisticPrisonAndBounty_Outfit prisonerOutfit)
        ; Do anything that needs to be done after the actor has been stripped and clothed.
        Debug(self, "OnClothed", "clothedActor: " + clothedActor, config.IS_DEBUG)

    endEvent

    event OnCellDoorOpen(ObjectReference akCellDoor, Actor whoOpened)
        if (whoOpened == Arrestee)
            GotoState(STATE_ESCAPED)
            self.TriggerEscape()
            return
            ; arrestVars.SetForm("Jail::Cell Door", akCellDoor)
            ; Make noise to attract guards attention,
            ; if the guard sees the door open, goto Escaped state
            akCellDoor.CreateDetectionEvent(Arrestee, 300)
            GotoState(STATE_ESCAPING)
            Actor _captor = arrestVars.GetForm("Arrest::Arresting Guard") as Actor
            Captor.RegisterForLOS(_captor, Arrestee)

            _captor.SetAlert()
            Debug(self, "OnCellDoorOpen", "Got Actor: " + _captor, config.IS_DEBUG)
            Captor.ForceRefTo(_captor)
        endif
    endEvent

    event OnCellDoorClosed(ObjectReference akCellDoor, Actor whoClosed)
        
    endEvent

    event OnGuardSeesPrisoner(Actor akGuard)
        Debug(self, "OnGuardSeesPrisoner", akGuard + " is seeing " + Arrestee + ", but the prisoner is in jail.", config.IS_DEBUG)
    endEvent

    event OnEscapeFail()
        if (Prisoner.ShouldBeStripped())
            Prisoner.Strip()

        elseif (Prisoner.ShouldBeClothed() && Prisoner.IsNaked())
            ; Only handle clothing here when not stripped, which means the Actor did not have any clothing
            Prisoner.Clothe()
        endif

        Prisoner.UpdateSentence()
        Prisoner.TriggerCrimimalPenalty()
        Prisoner.SetTimeOfImprisonment() ; Start the sentence from this point
    endEvent

    event OnSentenceChanged(Actor akPrisoner, int oldSentence, int newSentence, bool hasSentenceIncreased, bool bountyAffected)
        if (akPrisoner != config.Player)
            ; Prisoner is an NPC
            return
        endif
        
        if (hasSentenceIncreased)
            int daysIncreased = newSentence - oldSentence
            config.NotifyJail("Your sentence was extended by " + daysIncreased + " days")

            if (Prisoner.ShouldBeStripped())
                ; Strip since the sentence got extended
                ; StartGuardWalkToCellToStrip()
                Prisoner.Strip()

            elseif (Prisoner.ShouldBeFrisked())
                Prisoner.Frisk()
            endif

        else
            int daysDecreased = oldSentence - newSentence
            config.NotifyJail("Your sentence was reduced by " + daysDecreased + " days")
        endif
    endEvent

    event OnUpdateGameTime()
        Debug(self, "OnUpdateGameTime", "{ timeSinceLastUpdate: "+ Prisoner.TimeSinceLastUpdate +", CurrentTime: "+ Prisoner.CurrentTime +", LastUpdate: "+ Prisoner.LastUpdate +" }", config.IS_DEBUG)
        
        if (Prisoner.HasActiveBounty())
            ; Update any active bounty the prisoner may have while in jail, and add it to the sentence
            Prisoner.UpdateSentenceFromCurrentBounty()
        endif

        if (arrestVars.InfamyEnabled)
            Prisoner.UpdateInfamy()
        endif

        Prisoner.UpdateDaysJailed()

        if (Prisoner.IsSentenceServed)
            GotoState(STATE_RELEASED)
            return
        endif

        ; Prisoner.ShowJailInfo()
        Prisoner.ShowSentenceInfo()
        Prisoner.ShowHoldStats()
        ; arrestVars.List("Stripping")
        ; arrestVars.List("Jail")
        ; arrestVars.ListOverrides("Stripping")
        ; Prisoner.ShowActorVars()
        Prisoner.RegisterLastUpdate() ; Registers the last update in-game time for the prisoner
        ; Keep updating while in jail
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end", config.IS_DEBUG)
        ; Terminate Jailed process, Actor should be released by now.
        ; Revert to normal timescale
    endEvent
endState

;/
    This state represents the scenario where the prisoner
    is trying to escape, but hasn't been seen yet.
/;
state Escaping
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin", config.IS_DEBUG)
    endEvent

    event OnUpdateGameTime()
        ; Prisoner is trying to escape, but they are still inside the prison,
        ; infamy should still be updated
        if (arrestVars.InfamyEnabled)
            Prisoner.UpdateInfamy()
        endif

        Prisoner.RegisterLastUpdate()
        RegisterForSingleUpdateGameTime(1.0)
    endEvent

    event OnGuardSeesPrisoner(Actor akGuard)
        Debug(self, "OnGuardSeesPrisoner", akGuard + " is seeing " + Arrestee, config.IS_DEBUG)
        akGuard.SetAlert()
        akGuard.StartCombat(Arrestee)
        GotoState(STATE_ESCAPED)
        TriggerEscape()
    endEvent

    event OnCellDoorOpen(ObjectReference akCellDoor, Actor whoOpened)
        Debug(self, "OnCellDoorOpen", "Cell door open", config.IS_DEBUG)
    endEvent

    event OnCellDoorClosed(ObjectReference akCellDoor, Actor whoClosed)
        if (whoClosed == Arrestee)
            ;/ 
                If the prisoner closed the door, that means that it has been lockpicked or unlocked with the key
                Maybe make a guard suspicion system that checks if the door is unlocked, and locks it when he passes by (optionally increasing the sentence for unlocking the door)
            /;
            Key cellKey = akCellDoor.GetKey()
            if (Arrestee.GetItemCount(cellKey) > 0)
                ; Arrestee has the key, lock the door
                akCellDoor.Lock()
            endif

            bool isArresteeInsideCell = IsActorNearReference(Arrestee, Prisoner.JailCell)

            if (isArresteeInsideCell)
                Debug(self, "OnCellDoorClosed", Arrestee + " is inside the cell.", config.IS_DEBUG)
                GotoState("Jailed") ; Revert to Jailed since we have not been found escaping yet
            endif
            float distanceFromMarkerToDoor = Prisoner.JailCell.GetDistance(arrestVars.CellDoor)
            Debug(self, "OnCellDoorClosed", "Distance from marker to cell door: " + distanceFromMarkerToDoor, config.IS_DEBUG)
        endif
        Debug(self, "OnCellDoorClosed", "Cell door closed", config.IS_DEBUG)
    endEvent

    event OnEscapeFail()

    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end", config.IS_DEBUG)
        ; Terminate Escaped process, Actor should have escaped by now.
    endEvent
endState

;/
    This state represents the scenario where the prisoner
    is trying to escape and has been seen, or has escaped successfully (before transitioning to the Free state)
/;
state Escaped
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin", config.IS_DEBUG)
    endEvent

    event OnGuardSeesPrisoner(Actor akGuard)
        Debug(self, "OnGuardSeesPrisoner", akGuard + " is seeing " + Arrestee + " but the prisoner has already been seen escaping.", config.IS_DEBUG)
        Captor.UnregisterForLOS(akGuard, config.Player)
    endEvent

    event OnCellDoorClosed(ObjectReference akCellDoor, Actor whoClosed)
        if (whoClosed == Arrestee)
            bool isArresteeInsideCell = IsActorNearReference(Arrestee, Prisoner.JailCell)

            Actor _captor = arrestVars.GetForm("Arrest::Arresting Guard") as Actor
            if (_captor.IsInCombat() && isArresteeInsideCell)
                _captor.StopCombat()
                Arrestee.StopCombatAlarm()
                akCellDoor.SetOpen(false)
                akCellDoor.Lock()

                GotoState(STATE_JAILED)
                OnEscapeFail()

                ; ShowArrestVars()
            endif
        endif
    endEvent

    event OnUndressed(Actor undressedActor)
        ; Actor should be undressed at this point
        if (Prisoner.ShouldBeClothed())
            Prisoner.Clothe()
        endif

        Debug(self, "OnUndressed", "undressedActor: " + undressedActor, config.IS_DEBUG)
    endEvent

    event OnClothed(Actor clothedActor, RealisticPrisonAndBounty_Outfit prisonerOutfit)
        ; Do anything that needs to be done after the actor has been stripped and clothed.
        Debug(self, "OnClothed", "clothedActor: " + clothedActor, config.IS_DEBUG)

    endEvent

    event OnLocationChange(Location akOldLocation, Location akNewLocation)
        Debug(self, "Jail::OnLocationChange", "akOldLocation: " + akOldLocation + ", akNewLocation: " + akNewLocation)
    endEvent

    event OnUpdateGameTime()
        ; Not arrested anymore, break out of this state
        if (!arrestVars.IsArrested)
            Prisoner.ResetArrestVars() ; May change, as an escape doesn't necessarily mean all vars should be deleted.
            GotoState("")
            return
        endif
        ; Prisoner is escaping, but they are still inside the prison,
        ; infamy should still be updated
        ; if (arrestVars.InfamyEnabled)
        ;     Prisoner.UpdateInfamy()
        ; endif

        Prisoner.RegisterLastUpdate()
        RegisterForSingleUpdateGameTime(12.0)
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end", config.IS_DEBUG)
    endEvent
endState

state Released
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin", config.IS_DEBUG)
        ; Begin Release process, Actor is arrested and not yet free
        Prisoner.OpenCellDoor()
        ; Prisoner.ForceRefTo(arrestVars.Arrestee)
        if (arrestVars.ArrestType == arrest.ARREST_TYPE_TELEPORT_TO_CELL)
            if (!Prisoner.ShouldItemsBeRetained())
                Prisoner.GiveItemsBack()
            endif

            Prisoner.MoveToReleaseLocation()
        endif

        GotoState(STATE_FREE)
    endEvent

    event OnEndState()
        ; Terminate Release process, Actor should be free at this point
        Debug(self, "OnEndState", CurrentState + " state end", config.IS_DEBUG)
    endEvent
endState

state Free
    event OnBeginState()
        Debug(self, "OnBeginState", CurrentState + " state begin", config.IS_DEBUG)
        ; Begin Free process, Actor is not arrested and is Free
        ; arrestVars.Clear()
        Prisoner.ResetArrestVars()
        Prisoner.Clear()
        arrest.GotoState("")
        GotoState("")
    endEvent

    event OnEndState()
        Debug(self, "OnEndState", CurrentState + " state end", config.IS_DEBUG)
        ; Terminate Free process, Processing after Actor is free should be done by now.
    endEvent
endState

; event OnEscortToJailEnd()
;     ; Happens when the Actor should be imprisoned after being arrested and upon arriving at the jail. (called from Arrest)
; endEvent

event OnFriskBegin(Actor friskSearchPerformer, Actor actorToFrisk)
    ; Happens when the actor is beginning to be frisked
    Debug(self, "OnFriskBegin", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnFriskEnd(Actor friskSearchPerformer, Actor friskedActor)
    ; Happens when the actor has been frisked
    Debug(self, "OnFriskEnd", CurrentState + " event invoked", config.IS_DEBUG)
    self.SetupJailVars()
    Prisoner.Frisk()
    Prisoner.Restrain()
    Prisoner.SetupPrisonerVars()
    arrestVars.Captor.EvaluatePackage() ; temp
    ; Game.SetPlayerAIDriven(false)
    debug.notification("Jail::OnFriskEnd")
    sceneManager.StartEscortToCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.JailCell, arrestVars.CellDoor)
endEvent

event OnStripBegin(Actor stripSearchPerformer, Actor actorToStrip)
    ; Happens when the actor is about to be stripped
    Debug(self, "OnStripBegin", CurrentState + " event invoked")
endEvent

event OnStripping(Actor stripSearchPerformer, Actor actorToStrip)
    Debug(self, "OnStripping", CurrentState + " event invoked")

    Prisoner.Strip()
    if (actorToStrip != Prisoner.this)
        actorToStrip.RemoveAllItems(arrestVars.PrisonerItemsContainer, true, true)
    endif
endEvent

event OnStripEnd(Actor stripSearchPerformer, Actor strippedActor)
    ; Happens when the actor has been stripped
    Debug(self, "OnStripEnd", CurrentState + " event invoked")

    debug.notification("OnStripEnd: Called from within the Jail Script")
    self.SetupJailVars()
    Prisoner.Strip()
    ; Prisoner.Restrain(inFront = true)
    arrestVars.Captor.EvaluatePackage() ; temp

    debug.notification("Jail::OnStripEnd")
    ; arrestVars.SetForm("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(arrestVars.Hold), arrestVars.JailCell, 10000))
    Prisoner.SetupPrisonerVars()
    Debug(self, "OnStripEnd", "Vars: [ \n" + \
    "arrestVars.Captor: " + arrestVars.Captor + "(Object: "+ arrestVars.Captor.GetBaseObject().GetName() +")\n" + \
    "arrestVars.Arrestee: " + arrestVars.Arrestee + "(Object: "+ arrestVars.Arrestee.GetBaseObject().GetName() +")\n" + \
    "arrestVars.JailCell: " + arrestVars.JailCell + "(Object: "+ arrestVars.JailCell.GetBaseObject().GetName() +")\n" + \
    "arrestVars.CellDoor: " + arrestVars.CellDoor + "(Object: "+ arrestVars.CellDoor.GetBaseObject().GetName() +")\n" + \
"]")
    
    if (Prisoner.ShouldBeClothed())
        sceneManager.StartGiveClothing(arrestVars.Captor, Prisoner.this)
        sceneManager.StartEscortToCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.JailCell, arrestVars.CellDoor)
    else
        ; sceneManager.StartNoClothing(stripSearchPerformer, strippedActor)
        sceneManager.StartEscortToCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.JailCell, arrestVars.CellDoor)
    endif

endEvent

event OnBountyPaymentFailed(Actor akGuard, Actor akPrisoner)
    Debug(self, "Jail::OnBountyPaymentFailed", CurrentState + " event invoked")
    sceneManager.StartStripping(akGuard, akPrisoner)
endEvent

event OnEscortToJailBegin(Actor escortActor, Actor escortedActor)
    ; Happens when the actor is being escorted to jail
    Debug(self, "OnEscortToJailBegin", CurrentState + " event invoked")
    Form cuffs = Game.GetFormEx(0xA081D2F)

    escortedActor.SheatheWeapon()
    escortedActor.EquipItem(cuffs, true, true)
endEvent

event OnEscortToJailEnd(Actor escortActor, Actor escortedActor)
    ; Happens when the Actor has been escorted to the jail location
    Debug(self, "OnEscortToJailEnd", CurrentState + " event invoked")
    ; sceneManager.StartForcedStripping(escortActor, escortedActor)
    Prisoner.SetupPrisonerVars()
    BindAliasTo(Prisoner, escortedActor)
    self.SetupJailVars()
    Prisoner.SetupPrisonerVars()
    ; sceneManager.StartEscortToCell(escortActor, escortedActor, arrestVars.JailCell, arrestVars.CellDoor)
    sceneManager.StartStripping_02(escortActor, escortedActor)
    return

    if (Prisoner.ShouldBeFrisked())
        sceneManager.StartFrisking(escortActor, escortedActor)

    elseif (Prisoner.ShouldBeStripped())
        ; sceneManager.StartStripping(escortActor, escortedActor)
        sceneManager.StartForcedStripping02(escortActor, escortedActor)

    else
        sceneManager.StartEscortToCell_02(escortActor, escortedActor, arrestVars.JailCell, arrestVars.CellDoor)
    endif
    
    ; if (Prisoner.ShouldBeStripped())
    ;     sceneManager.StartStripping(escortActor, escortedActor)
    ; endif
endEvent

event OnEscortToCellBegin(Actor escortActor, Actor escortedActor)
    ; Happens when the actor is being escorted to their cell
    Debug(self, "Jail::OnEscortToCellBegin", CurrentState + " event invoked")
    Debug(self, "Jail::OnEscortToCellBegin", "Escorted Actor: " + escortedActor)
endEvent

event OnEscortToCellEnd(Actor escortActor, Actor escortedActor)
    ; Happens when the actor has been escorted to their cell
    Debug(self, "OnEscortToCellEnd", CurrentState + " event invoked")
    debug.notification("OnEscortToCellEnd: Called from within the Jail Script")
    if (Prisoner.ShouldBeClothed())
        sceneManager.StartGiveClothing(escortActor, escortedActor)
    endif
    SendModEvent("RPB_JailBegin") ; Start the imprisonment
endEvent

event OnEscortFromCellBegin(Actor escortActor, Actor escortedActor, ObjectReference destination)
    ; Happens when the actor is being escorted from their cell to the destination
    Debug(self, "OnEscortFromCellBegin", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnEscortFromCellEnd(Actor escortActor, Actor escortedActor, ObjectReference destination)
    ; Happens when the actor has been escorted from their cell to the destination
    Debug(self, "Jail::OnEscortFromCellEnd", CurrentState + " event invoked")

    ; Release Prisoner (later this Event can be used for more things and not just Release, but lets keep it simple for now)
    Prisoner.GiveItemsBack()
    Prisoner.ResetArrestVars()
    BindAliasTo(Prisoner, none)
endEvent

event OnClothingGiven(Actor clothingGiver, Actor clothingPrisoner)
    Debug(self, "OnClothingGiven", CurrentState + " event invoked")
    Prisoner.Clothe()
    ; if still in jail, not in the cell
    ; sceneManager.StartEscortToCell(clothingGiver, clothingPrisoner, arrestVars.JailCell, arrestVars.CellDoor)
endEvent

event OnActorCuffed(Actor cuffedActor, bool hands, bool feet)
    ; Happens when the actor has been cuffed (hands bound, maybe feet?)
    Debug(self, "OnActorCuffed", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnActorUncuffed(Actor uncuffedActor, bool hands, bool feet)
    ; Happens when the actor has been uncuffed (hands unbound, maybe feet?)
    Debug(self, "OnActorUncuffed", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnUndressed(Actor undressedActor)
    Debug(self, "OnUndressed", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnClothed(Actor clothedActor, RealisticPrisonAndBounty_Outfit prisonerOutfit)
    ; Do anything that needs to be done after the actor has been stripped and clothed.
    Debug(self, "OnClothed", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnCellDoorLocked(ObjectReference _cellDoor, Actor whoLocked)
    Debug(self, "OnCellDoorLocked", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnCellDoorUnlocked(ObjectReference _cellDoor, Actor whoUnlocked)
    Debug(self, "OnCellDoorUnlocked", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnCellDoorOpen(ObjectReference _cellDoor, Actor whoOpened)
    ; If the cell door was opened by the player, and they are not jailed, this must mean that they lockpicked the door either just because or to get someone out of jail.
    if (whoOpened == config.Player && config.Player != Arrestee)
        Faction jailFaction = config.GetFaction(config.GetCurrentPlayerHoldLocation())
        ; Add bounty for lockpicking / breaking someone out of jail if they are witnessed
        ; if (witnessedCrime)
        jailFaction.ModCrimeGold(2000)
        Debug(self, "OnCellDoorOpen", "jailFaction: " + jailFaction + ", bounty: " + jailFaction.GetCrimeGold(), config.IS_DEBUG)
    endif
    Debug(self, "OnCellDoorOpen", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnCellDoorClosed(ObjectReference _cellDoor, Actor whoOpened)
    Debug(self, "OnCellDoorClosed", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

; Placeholders for State events
event OnEscapeFail()
    Error(self, "OnEscapeFail", "Not currently Escaping, invalid call!")
endEvent

event OnGuardSeesPrisoner(Actor akGuard)
    Debug(self, "OnGuardSeesPrisoner", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnSentenceChanged(Actor akPrisoner, int oldSentence, int newSentence, bool hasIncreased, bool bountyAffected)
    Debug(self, "OnSentenceChanged", CurrentState + " event invoked", config.IS_DEBUG)
endEvent

event OnPrisonerLocationChanged(RealisticPrisonAndBounty_PrisonerRef akPrisoner, Location akOldLocation, Location akNewLocation)
    Debug(self, "OnPrisonerLocationChanged", CurrentState + " event invoked")

    if (akPrisoner.IsJailed && akNewLocation != akPrisoner.PrisonLocation)
        akPrisoner.SetEscaped()
        akPrisoner.RevertBounty()
        akPrisoner.AddEscapeBounty()
    endif

endEvent

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    Debug(self, "OnLocationChange", CurrentState + " event invoked")
endEvent


function TriggerEscape()
    if (CurrentState != STATE_ESCAPED)
        Error(self, "TriggerEscape", "Not currently Escaping, invalid call!")
        return
    endif

    Prisoner.SetEscaped()
    Prisoner.RevertBounty()
    Prisoner.AddEscapeBounty()
    ; Prisoner.ResetArrestVars() ; May change, as an escape doesn't necessarily mean all vars should be deleted.
endFunction

function TriggerImprisonment()
    if (CurrentState != STATE_JAILED)
        Error(self, "TriggerImprisonment", "Not currently jailed, invalid call!")
        return
    endif

    Debug(self, "TriggerImprisonment", "Triggered Imprisonment", config.IS_DEBUG)
    float startBench = StartBenchmark()
    ; Begin Jailed process, Actor is arrested and jailed
    ; Switch timescale to prison timescale

    Prisoner.MarkAsJailed()

    ; if (Prisoner.JailCell)
    ;     Prisoner.CloseCellDoor()
    ; endif
    
    ; ShowArrestVars()

    Prisoner.UpdateSentence()

    ; Trigger infamy penalty, only if infamy is enabled
    if (arrestVars.InfamyEnabled)
        Prisoner.TriggerCrimimalPenalty()
    endif

    Prisoner.SetTimeOfImprisonment() ; Start the sentence from this point

    ; if (Prisoner.ShouldBeFrisked())
    ;     Prisoner.Frisk()
    ; endif

    ; if (Prisoner.ShouldBeStripped())
    ;     Prisoner.Strip()

    ; elseif (Prisoner.ShouldBeClothed() && Prisoner.IsNaked())
    ;     ; Only handle clothing here when not stripped, which means the Actor did not have any clothing
    ;     Prisoner.Clothe()
    ; endif

    Prisoner.ShowJailInfo()
    ; Prisoner.ShowOutfitInfo()
    ; Prisoner.ShowHoldStats()
    ; ShowArrestParams()
    ; ShowArrestVars()

    ; config.NotifyJail("Your sentence in " + Hold + " was set to " + Prisoner.Sentence + " days in jail")
    config.NotifyJail("You have been sentenced to " + Prisoner.Sentence + " days in jail for " + Hold)
    EndBenchmark(startBench, "TriggerImprisonment")
endFunction

function MovePrisonerToCell()
    Prisoner.MoveToCell()
endFunction

function StartTeleportToCell()
    SendModEvent("RPB_JailBegin")
    arrestVars.Arrestee.MoveTo(arrestVars.JailCell)

    Prisoner.Strip()

    if (Prisoner.ShouldBeFrisked())
        Prisoner.Frisk()
    endif

    if (Prisoner.ShouldBeStripped())
        Prisoner.Strip()

    elseif (Prisoner.ShouldBeClothed() && Prisoner.IsNaked())
        ; Only handle clothing here when not stripped, which means the Actor did not have any clothing
        Prisoner.Clothe()
    endif
endFunction

function EscortToJail()
    ; Get the suspect's possible prisoner chest (since we don't know if the suspect stays in jail yet)
    arrestVars.SetForm("Jail::Prisoner Items Container", config.GetJailPrisonerItemsContainer(Hold))
    ObjectReference prisonerChest  = arrestVars.PrisonerItemsContainer

    ; Prisoner.SetupPrisonerVars()
    ; Start the escorting scene
    ; sceneManager.StartEscortToCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.JailCell, arrestVars.CellDoor)
    sceneManager.StartEscortToJail(arrestVars.Captor, arrestVars.Arrestee, prisonerChest)
endFunction

function EscortToCell()
    sceneManager.StartEscortToCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.JailCell, arrestVars.CellDoor)
endFunction

function TeleportToJail()
    arrestVars.SetForm("Jail::Prisoner Items Container", config.GetJailPrisonerItemsContainer(Hold))
    ObjectReference prisonerChest  = arrestVars.PrisonerItemsContainer
    arrestVars.Arrestee.MoveTo(prisonerChest)
    arrestVars.Captor.MoveTo(prisonerChest)

    sceneManager.StartEscortToCell(arrestVars.Captor, arrestVars.Arrestee, arrestVars.JailCell, arrestVars.CellDoor)
endFunction

bool function AssignJailCell(Actor akPrisoner)
    ObjectReference randomJailCell = config.GetRandomJailMarker(Hold)
    Debug(self, "AssignJailCell", "jail cell: " + randomJailCell, config.IS_DEBUG)

    if (arrestVars.JailCell && arrestVars.CellDoor.GetFormID() != 0x5E922)
        Debug(self, "AssignJailCell", "A jail cell has already been assigned to " + akPrisoner + ": " + arrestVars.JailCell, config.IS_DEBUG)
        return true
    endif

    ; arrestVars.SetForm("Jail::Cell", randomJailCell) ; Assign cell to Player
    arrestVars.SetForm("Jail::Cell", Game.GetFormEx(0x36897)) ; Assign cell to Player
    ; arrestVars.SetReference("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(arrestVars.Hold), randomJailCell, 10000))
    arrestVars.SetReference("Jail::Cell Door", Game.GetFormEx(0x5E921) as ObjectReference)

    Debug(self, "AssignJailCell", "Set up new Jail Cell for " + akPrisoner + ": " + arrestVars.JailCell)
    return arrestVars.JailCell != none

endFunction

; bool function AssignJailCell(Actor akPrisoner)
;     ObjectReference randomJailCell = config.GetRandomJailMarker(Hold)
;     Debug(self, "AssignJailCell", "jail cell: " + randomJailCell, config.IS_DEBUG)

;     if (akPrisoner == config.Player)
;         if (arrestVars.JailCell)
;             Debug(self, "AssignJailCell", "A jail cell has already been assigned to " + akPrisoner + ": " + arrestVars.JailCell, config.IS_DEBUG)
;             return true
;         endif

;         arrestVars.SetForm("Jail::Cell", randomJailCell) ; Assign cell to Player
;         arrestVars.SetReference("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(arrestVars.Hold), randomJailCell, 10000))

;         Debug(self, "AssignJailCell", "Set up new Jail Cell for " + akPrisoner + ": " + arrestVars.JailCell, config.IS_DEBUG)
;         return arrestVars.JailCell != none

;     else
;         string jailCellId = "["+ akPrisoner.GetFormID() +"]Jail::Cell"
;         Form npcJailCell = arrestVars.GetForm(jailCellId)
;         if (npcJailCell)
;             Debug(self, "AssignJailCell", "A jail cell has already been assigned to " + akPrisoner + ": " + npcJailCell, config.IS_DEBUG)
;             return true
;         endif

;         arrestVars.SetForm(jailCellId, randomJailCell) ; Assign cell to NPC
;         Debug(self, "AssignJailCell", "Set up new Jail Cell for " + akPrisoner + ": " + npcJailCell, config.IS_DEBUG)
;         return arrestVars.GetForm(jailCellId) != none
;     endif

;     return false
; endFunction

; ==========================================================
;                       Infamy Messages
; ==========================================================

function NotifyInfamyRecognizedThresholdMet(string hold, bool asNotification = false)
    if (miscVars.GetBool("["+ hold +"]Jail::Infamy Recognized Threshold Message Sent"))
        return
    endif

    miscVars.SetBool("["+ hold +"]Jail::Infamy Recognized Threshold Message Sent", true)
    miscVars.SetBool("Jail::Infamy Recognized Threshold Notification", true)

    if (config.ShouldDisplayInfamyNotifications && asNotification)
        debug.notification("You are now recognized as a criminal in " + hold)
        return
    endif

    debug.MessageBox("You are now recognized as a criminal in " + hold)
endFunction

function NotifyInfamyKnownThresholdMet(string hold, bool asNotification = false)
    if (miscVars.GetBool("["+ hold +"]Jail::Infamy Known Threshold Message Sent"))
        return
    endif

    miscVars.SetBool("["+ hold +"]Jail::Infamy Known Threshold Message Sent", true)
    miscVars.SetBool("Jail::Infamy Known Threshold Notification", true)

    if (config.ShouldDisplayInfamyNotifications && asNotification)
        debug.notification("You are now a known criminal in " + hold)
        return
    endif

    debug.MessageBox("You are now a known criminal in " + hold)
endFunction

; ==========================================================