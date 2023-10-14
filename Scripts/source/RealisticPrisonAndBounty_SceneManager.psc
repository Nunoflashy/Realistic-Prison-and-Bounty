scriptname RealisticPrisonAndBounty_SceneManager extends Quest

import RealisticPrisonAndBounty_Config
import RealisticPrisonAndBounty_Util

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property arrest
    RealisticPrisonAndBounty_Arrest function get()
        return config.arrest
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property jail
    RealisticPrisonAndBounty_Jail function get()
        return config.jail
    endFunction
endProperty

Idle property LockpickingIdle auto

; ==========================================================
;                           Scenes
; ==========================================================
Scene property UnlockCell auto
Scene property LockCell auto

Scene property ArrestStart
    Scene function get()
        return Game.GetFormFromFile(0xF569, GetPluginName()) as Scene
    endFunction
endProperty

Scene property ArrestStart02
    Scene function get()
        return Game.GetFormFromFile(0xFAF6, GetPluginName()) as Scene
    endFunction
endProperty

Scene property EscortToJail
    Scene function get()
        return Game.GetFormFromFile(0xF532, GetPluginName()) as Scene
    endFunction
endProperty

Scene property EscortToCell
    Scene function get()
        return Game.GetFormFromFile(0xCF58, GetPluginName()) as Scene
    endFunction
endProperty

Scene property SearchStart
    Scene function get()
        return Game.GetFormFromFile(0xF55C, GetPluginName()) as Scene
    endFunction
endProperty

Scene property Frisking
    Scene function get()
        return Game.GetFormFromFile(0xCF5A, GetPluginName()) as Scene
    endFunction
endProperty

Scene property Stripping
    Scene function get()
        return Game.GetFormFromFile(0xCF59, GetPluginName()) as Scene
    endFunction
endProperty

Scene property Stripping02
    Scene function get()
        return Game.GetFormFromFile(0xEA60, GetPluginName()) as Scene
    endFunction
endProperty

Scene property ForcedStripping01
    Scene function get()
        return Game.GetFormFromFile(0xF587, GetPluginName()) as Scene
    endFunction
endProperty

Scene property StrippingStart
    Scene function get()
        return Game.GetFormFromFile(0xF561, GetPluginName()) as Scene
    endFunction
endProperty

Scene property GiveClothing
    Scene function get()
        return Game.GetFormFromFile(0xF52A, GetPluginName()) as Scene
    endFunction
endProperty

Scene property NoClothing
    Scene function get()
        return Game.GetFormFromFile(0xF571, GetPluginName()) as Scene
    endFunction
endProperty

Scene property BountyPaymentFail
    Scene function get()
        return Game.GetFormFromFile(0xF54E, GetPluginName()) as Scene
    endFunction
endProperty

; ==========================================================
;                       Scene Names
; ==========================================================
string property SCENE_GENERIC_ESCORT    = "RPB_GenericEscort" autoreadonly
string property SCENE_ESCORT_TO_JAIL    = "RPB_EscortToJail" autoreadonly
string property SCENE_ESCORT_TO_CELL    = "RPB_EscortToCell" autoreadonly
string property SCENE_STRIPPING         = "RPB_Stripping" autoreadonly
string property SCENE_FRISKING          = "RPB_Frisking" autoreadonly
string property SCENE_GIVE_CLOTHING     = "RPB_GiveClothing" autoreadonly
string property SCENE_UNLOCK_CELL       = "RPB_UnlockCell" autoreadonly
string property SCENE_PAYMENT_FAIL      = "RPB_BountyPaymentFail" autoreadonly
string property SCENE_ARREST_START      = "ArrestStart" autoreadonly
string property SCENE_NO_CLOTHING       = "NoClothing" autoreadonly
string property SCENE_FORCED_STRIPPING_01  = "ForcedStripping01" autoreadonly

; Type of Event during OnScenePlaying
int property SCENE_PLAYING_START    = 0 autoreadonly
int property SCENE_PLAYING_END      = 1 autoreadonly

; ==========================================================
;                     Scene Control Queue
; ==========================================================
Scene _previousScene
Scene _currentScene
Scene _nextScene

; ==========================================================
;                       Scene Aliases
; ==========================================================

ReferenceAlias function GetEscort(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Escort", "Escort" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetEscortee(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Escortee", "Escortee" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetGuard(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Guard", "Guard" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetPrisoner(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Prisoner", "Prisoner" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetCell(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Player_EscortLocation", "Player_EscortLocation" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetGuardLocation(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Guard_EscortLocation", "Guard_EscortLocation" + index)) as ReferenceAlias
endFunction

ReferenceAlias property EscorteeRef auto
ReferenceAlias property Escortee1Ref auto
ReferenceAlias property Escortee2Ref auto
ReferenceAlias property Escortee3Ref auto
ReferenceAlias property Escortee4Ref auto
ReferenceAlias property Escortee5Ref auto
ReferenceAlias property Escortee6Ref auto
ReferenceAlias property Escortee7Ref auto
ReferenceAlias property Escortee8Ref auto
ReferenceAlias property Escortee9Ref auto

; Possible Escorts
ReferenceAlias property EscortRef auto
ReferenceAlias property Escort02Ref auto
ReferenceAlias property Escort03Ref auto

; Possible Escort locations for Escortees / Arrestees / Prisoners
ReferenceAlias property Player_EscortLocationRef auto
ReferenceAlias property Player_EscortLocation000Ref auto
ReferenceAlias property Player_EscortLocation001Ref auto
ReferenceAlias property Player_EscortLocation002Ref auto
ReferenceAlias property Player_EscortLocation003Ref auto
ReferenceAlias property Player_EscortLocation004Ref auto
ReferenceAlias property Player_EscortLocation005Ref auto
ReferenceAlias property Player_EscortLocation006Ref auto
ReferenceAlias property Player_EscortLocation007Ref auto
ReferenceAlias property Player_EscortLocation008Ref auto
ReferenceAlias property Player_EscortLocation009Ref auto

; Possible Escort locations for Escorts / Guards
ReferenceAlias property Guard_EscortLocationRef auto
ReferenceAlias property Guard_EscortLocation02Ref auto
ReferenceAlias property Guard_EscortLocation03Ref auto

; Possible Prisoners
ReferenceAlias property PrisonerRef auto
ReferenceAlias property Prisoner1Ref
    ReferenceAlias function get()
        return self.GetAliasByName("Prisoner1") as ReferenceAlias
    endFunction
endProperty

ReferenceAlias property Prisoner2Ref
    ReferenceAlias function get()
        return self.GetAliasByName("Prisoner2") as ReferenceAlias
    endFunction
endProperty

ReferenceAlias property Prisoner3Ref
    ReferenceAlias function get()
        return self.GetAliasByName("Prisoner3") as ReferenceAlias
    endFunction
endProperty

; Possible guards for searching simultaneously (Stripping / Frisking)
ReferenceAlias property GuardRef auto
ReferenceAlias property Guard2Ref auto
ReferenceAlias property Guard3Ref auto

RealisticPrisonAndBounty_EventManager property eventManager
    RealisticPrisonAndBounty_EventManager function get()
        return Game.GetFormFromFile(0xEA67, GetPluginName()) as RealisticPrisonAndBounty_EventManager
    endFunction
endProperty

function ClearAliases()
    BindAliasTo(EscorteeRef, none)
    BindAliasTo(EscortRef, none)
    BindAliasTo(Player_EscortLocationRef, none)
    BindAliasTo(Guard_EscortLocationRef, none)
    BindAliasTo(PrisonerRef, none)
    BindAliasTo(GuardRef, none)
endFunction

ObjectReference[] function GetSceneParameters(string sceneName)
    ObjectReference[] params = new ObjectReference[10]
    ; int i = 0
    ; while (i < params.Length)
    ;     ReferenceAlias currentEscort = self.GetAliasByName("Escort00" + i) as ReferenceAlias
    ;     if (currentEscort != None)
    ;         params[i] = currentEscort.GetReference()
    ;     endif
    ;     i += 1
    ; endWhile

    if (sceneName == SCENE_ESCORT_TO_CELL)
        ;/
            self.AddEscort(1)
            self.AddEscortee(3)
        /;
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()
        params[2] = self.GetEscortee(1).GetActorReference()
        params[3] = self.GetEscortee(2).GetActorReference()
        params[4] = self.GetCell().GetReference()
        params[5] = self.GetGuardLocation().GetReference()

        ; params[0] = EscortRef.GetActorReference()
        ; params[1] = EscorteeRef.GetActorReference()
        ; params[2] = Escortee1Ref.GetActorReference()
        ; params[3] = Escortee2Ref.GetActorReference()
        ; params[4] = Player_EscortLocationRef.GetReference()
        ; params[5] = Guard_EscortLocationRef.GetReference()

    elseif (sceneName == SCENE_ESCORT_TO_JAIL)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()
        params[2] = self.GetEscortee(1).GetActorReference()
        params[3] = self.GetEscortee(2).GetActorReference()

        ; params[0] = EscortRef.GetActorReference()
        ; params[1] = EscorteeRef.GetActorReference()
        ; params[2] = Escortee1Ref.GetActorReference()
        ; params[3] = Escortee2Ref.GetActorReference()

    elseif (sceneName == SCENE_STRIPPING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()
        params[2] = self.GetPrisoner(1).GetActorReference()
        params[3] = self.GetPrisoner(2).GetActorReference()

    elseif (sceneName == SCENE_STRIPPING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_FRISKING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_GIVE_CLOTHING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_PAYMENT_FAIL)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_ARREST_START)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()

    elseif (sceneName == SCENE_NO_CLOTHING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()
        params[2] = self.GetPrisoner(1).GetActorReference()
        params[3] = self.GetPrisoner(2).GetActorReference()
        params[4] = self.GetPrisoner(3).GetActorReference()

    elseif (sceneName == SCENE_FORCED_STRIPPING_01)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()
    endif

    return params
endFunction

string function GetSceneParametersDebugInfo(Scene sender, string sceneName, ObjectReference[] params)
    string debugInfo = ""

    int i = 0
    while (i < params.Length)
        if (params[i] != none)
            string baseId     = "[BaseID: " + params[i].GetBaseObject().GetFormID() + "] "
            string formId     = "[FormID: " + params[i].GetFormID() + "] "
            string objectName = "[Name: " + params[i].GetBaseObject().GetName() + "] "

            debugInfo += "\t["+i+"]: " + params[i] + " " + formId + baseId + string_if (objectName != "[Name: ] ", objectName) + "\n"
        endif
        i += 1
    endWhile

    debugInfo += "]"

    return "Scene: " + sceneName + " " + sender + "\nParameters: [\n" + debugInfo
endFunction

event OnSceneStart(string name, Scene sender)
    ObjectReference[] params = self.GetSceneParameters(name)

    if (name == SCENE_ESCORT_TO_CELL)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor
        ; self.GetParams("Escort", max = 1)
        ; self.GetParams("Escortee", max = 3)

        if (escortee == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != escort)
                jail.OnEscortToCellBegin(escort, params[i] as Actor)
            endif
            i += 1
        endWhile

    elseif (name == SCENE_ESCORT_TO_JAIL)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor
        Actor escortee02 = params[2] as Actor
        Actor escortee03 = params[3] as Actor

        if (escortee == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != escort)
                jail.OnEscortToJailBegin(escort, params[i] as Actor)
            endif
            i += 1
        endWhile

        ; jail.OnEscortToJailBegin(escort, escortee)

    elseif (name == SCENE_STRIPPING)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        if (strippedPrisoner == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        jail.OnStripBegin(stripperGuard, strippedPrisoner)

    elseif (name == SCENE_FRISKING)
        Actor searcherGuard     = params[0] as Actor
        Actor searchedPrisoner  = params[1] as Actor

        if (searchedPrisoner == config.Player)
            Game.SetPlayerAIDriven(true)
        endif
        
        jail.OnFriskBegin(searcherGuard, searchedPrisoner)

    elseif (name == SCENE_PAYMENT_FAIL)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        if (prisoner == config.Player)
            Game.SetPlayerAIDriven(true)
        endif
        
        ; jail.OnBountyPaymentFailed(guard, prisoner)

    elseif (name == SCENE_ARREST_START)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        if (escortee == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        ; arrest.OnArrestStart()
    endif

    Debug(self, "SceneManager::OnSceneStart", self.GetSceneParametersDebugInfo(sender, name, params))
endEvent

event OnScenePlaying(string name, int scenePart, int phase, Scene sender)
    ObjectReference[] params = self.GetSceneParameters(name)

    Debug(self, "SceneManager::OnScenePlaying", string_if (scenePart == SCENE_PLAYING_START, "(Start) Playing", "(End) Played") + " Phase " + phase + " of " + name)
    
    if (name == SCENE_ESCORT_TO_CELL)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor
        ObjectReference jailCell  = params[4]
        ObjectReference cellDoor  = params[5]

        if (scenePart == SCENE_PLAYING_START)
            if (phase == 4)
                debug.notification("Phase 4 played for " + name)

            elseif (phase == 7)
                cellDoor.SetLockLevel(100)
                cellDoor.SetOpen(false)
                cellDoor.Lock()
                Debug.SendAnimationEvent(guard, "IdleLockpick")
            endif
            
        elseif (scenePart == SCENE_PLAYING_END)
            if (phase == 4)
                Debug.SendAnimationEvent(guard, "IdleLockpick")
                cellDoor.Lock(false)
                cellDoor.SetOpen(true)

            elseif (phase == 6)

            endif
        endif

    elseif (name == SCENE_ESCORT_TO_JAIL)

        if (scenePart == SCENE_PLAYING_START)
            
        elseif (scenePart == SCENE_PLAYING_END)

        endif

    elseif (name == SCENE_STRIPPING)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        if (scenePart == SCENE_PLAYING_START)
            if (phase == 2)
                debug.notification("Played Phase " + phase + " of " + name)
                int i = 0
                while (i < params.Length)
                    if (params[i] != None && params[i] != stripperGuard)
                        jail.OnStripping(stripperGuard, params[i] as Actor)
                    endif
                    i += 1
                endWhile
                ; jail.OnStripping(stripperGuard, strippedPrisoner)

            elseif (phase == 6)
                ; Remove underwear
                jail.Prisoner.RemoveUnderwear()
            endif
            
        elseif (scenePart == SCENE_PLAYING_END)
            ; if (phase == 2)
            ;     debug.notification("Played Phase " + phase + " of " + name)
            ;     int i = 0
            ;     while (i < params.Length)
            ;         if (params[i] != None && params[i] != stripperGuard)
            ;             jail.OnStripping(stripperGuard, params[i] as Actor)
            ;         endif
            ;         i += 1
            ;     endWhile
            ;     ; jail.OnStripping(stripperGuard, strippedPrisoner)
            ; endif
        endif

    elseif (name == SCENE_FRISKING)

        if (scenePart == SCENE_PLAYING_START)
            
        elseif (scenePart == SCENE_PLAYING_END)

        endif

    elseif (name == SCENE_GIVE_CLOTHING)

        if (scenePart == SCENE_PLAYING_START)
            
        elseif (scenePart == SCENE_PLAYING_END)

        endif

    elseif (name == SCENE_UNLOCK_CELL)

        if (scenePart == SCENE_PLAYING_START)
            
        elseif (scenePart == SCENE_PLAYING_END)

        endif

    elseif (name == SCENE_ARREST_START)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        if (scenePart == SCENE_PLAYING_START)
            if (phase == 3)
                arrest.OnArresting(escort, escortee)
            endif

        elseif (scenePart == SCENE_PLAYING_END)
            if (phase == 1)
                OrientRelative(escortee, escort)
                Debug.SendAnimationEvent(escortee, "ZazAPC001")
            endif
        endif

    elseif (name == SCENE_FORCED_STRIPPING_01)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        if (scenePart == SCENE_PLAYING_START)
            
        elseif (scenePart == SCENE_PLAYING_END)
            if (phase == 0)
                
            endif

            if (phase == 1)
                ; Debug.SendAnimationEvent(strippedPrisoner, "ZazAPC013")
                ; strippedPrisoner.SetAV("Paralysis", 1)
                ; strippedPrisoner.PushActorAway(strippedPrisoner, 1)
                Debug.SendAnimationEvent(strippedPrisoner, "IdleLayDownEnter")

            elseif (phase == 2)
                jail.OnStripping(stripperGuard, strippedPrisoner)
            endif
        endif

    endif
endEvent

event OnSceneEnd(string name, Scene sender)
    ObjectReference[] params = self.GetSceneParameters(name)

    if (name == SCENE_ESCORT_TO_CELL)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor
        ObjectReference jailCell  = params[4]
        ObjectReference cellDoor  = params[5]

        if (escortee == config.Player)
            Game.SetPlayerAIDriven(false)
        endif

        cellDoor.SetLockLevel(100)
        cellDoor.Lock()

        jail.OnEscortToCellEnd(escort, escortee)

    elseif (name == SCENE_ESCORT_TO_JAIL)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        jail.OnEscortToJailEnd(escort, escortee)

    elseif (name == SCENE_STRIPPING)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        int i = 0
        while (i < params.Length)
            Form cuffs = Game.GetFormEx(0xA081D33)

            if (params[i] != None && params[i] != stripperGuard)
                (params[i] as Actor).SheatheWeapon()
                (params[i] as Actor).EquipItem(cuffs, true, true)
            endif
            i += 1
        endWhile

        jail.OnStripEnd(stripperGuard, strippedPrisoner)

    elseif (name == SCENE_FRISKING)
        Actor searcherGuard     = params[0] as Actor
        Actor searchedPrisoner  = params[1] as Actor

        jail.OnFriskEnd(searcherGuard, searchedPrisoner)

    elseif (name == SCENE_GIVE_CLOTHING)
        Actor searcherGuard     = params[0] as Actor
        Actor searchedPrisoner  = params[1] as Actor

        if (searchedPrisoner == config.Player)
            Game.SetPlayerAIDriven(false)
        endif

        jail.OnClothingGiven(searcherGuard, searchedPrisoner)

    elseif (name == SCENE_PAYMENT_FAIL)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        jail.OnBountyPaymentFailed(guard, prisoner)

    elseif (name == SCENE_ARREST_START)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        arrest.OnArrestStart(escort, escortee)

    elseif (name == SCENE_FORCED_STRIPPING_01)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        ; strippedPrisoner.SetAV("Paralysis", 0)
        Debug.SendAnimationEvent(strippedPrisoner, "IdleLayDownExit")
        Debug(self, "SceneManager::OnSceneEnd", "Reached Forced Stripping block")
        jail.Prisoner.RemoveUnderwear()
        jail.OnStripEnd(stripperGuard, strippedPrisoner)
    endif

    Debug(self, "SceneManager::OnSceneEnd", self.GetSceneParametersDebugInfo(sender, name, params))
endEvent

ReferenceAlias function GetAvailableAlias(string aliasType)
    if (aliasType == "Prisoner")
        ReferenceAlias currentTraversedAlias = PrisonerRef

        if (currentTraversedAlias.GetReference() == None)
            return currentTraversedAlias
        endif
    endif
endFunction

function StartEscortToCell(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, ObjectReference akJailCellDoor)
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(EscortRef, akEscortLeader)

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(EscorteeRef, akEscortedPrisoner)

    ; Bind the prisoner's destination point, the jail cell
    BindAliasTo(Player_EscortLocationRef, akJailCellMarker)

    ; Bind the guard's destination point, the jail cell door
    BindAliasTo(Guard_EscortLocationRef, akJailCellDoor)

    EscortToCell.Start()
endFunction

function StartEscortToJail(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akPrisonerChest)
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(EscortRef, akEscortLeader)
    ; BindAliasTo(Escortee1Ref, GetNearestActor(akEscortedPrisoner, 9000))
    ; BindAliasTo(Escortee2Ref, GetNearestActor(akEscortedPrisoner, 9000))

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(EscorteeRef, akEscortedPrisoner)

    ; Bind the destination point, the chest
    BindAliasTo(Player_EscortLocationRef, akPrisonerChest)

    ; Bind the guard's destination point, the jail cell door
    BindAliasTo(Guard_EscortLocationRef, akPrisonerChest)

    EscortToJail.Start()
endFunction

function StartMultipleEscortsToJail(Actor akEscortLeader, Actor[] akEscortedPrisoners, ObjectReference akPrisonerChest)
    ; Bind the leader to its alias to lead the escort scene
    BindAliasTo(EscortRef, akEscortLeader)

    ; Bind the prisoners to their aliases to be escorted
    int i = 0
    while (i < akEscortedPrisoners.Length)
        BindAliasTo(self.GetAliasByName("Escortee" + i) as ReferenceAlias, akEscortedPrisoners[i])
        i += 1
    endWhile

    ; Bind the destination point, the chest
    BindAliasTo(Player_EscortLocationRef, akPrisonerChest)

    ; Bind the destination point, the chest
    BindAliasTo(Guard_EscortLocationRef, akPrisonerChest)
endFunction

function StartStrippingStart(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAliasTo(GuardRef, akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAliasTo(PrisonerRef, akStrippedPrisoner)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAliasTo(Prisoner1Ref, Escortee1Ref.GetActorReference())
    BindAliasTo(Prisoner2Ref, Escortee2Ref.GetActorReference())
    BindAliasTo(Prisoner3Ref, Escortee2Ref.GetActorReference())

    StrippingStart.Start()
endFunction

function StartStripping(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAliasTo(GuardRef, akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAliasTo(PrisonerRef, akStrippedPrisoner)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAliasTo(Prisoner1Ref, Escortee1Ref.GetActorReference())
    BindAliasTo(Prisoner2Ref, Escortee2Ref.GetActorReference())

    Stripping02.Start()
endFunction

function StartFrisking(Actor akFriskerGuard, Actor akFriskedPrisoner)
    ; Bind the guard to be the one performing the frisk search
    BindAliasTo(GuardRef, akFriskerGuard)

    ; Bind the Prisoner to be the actor being frisk searched
    BindAliasTo(PrisonerRef, akFriskedPrisoner)

    Frisking.Start()
endFunction

function StartGiveClothing(Actor akGuard, Actor akPrisoner)
    ; Bind the guard to be the one giving clothing
    BindAliasTo(GuardRef, akGuard)

    ; Bind the Prisoner to be the actor being given clothing
    BindAliasTo(PrisonerRef, akPrisoner)

    GiveClothing.Start()
endFunction

function StartUnlockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAliasTo(EscortRef, akGuard)
    BindAliasTo(Guard_EscortLocationRef, akJailCellDoor)

    UnlockCell.Start()
endFunction

function StartLockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAliasTo(EscortRef, akGuard)
    BindAliasTo(Guard_EscortLocationRef, akJailCellDoor)

    LockCell.Start()
endFunction

function StartBountyPaymentFail(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(GuardRef, akGuard)

    ; Bind the Prisoner, who's trying to pay the bounty
    BindAliasTo(PrisonerRef, akPrisoner)

    BountyPaymentFail.Start()
endFunction

function StartArrestStart(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(EscortRef, akGuard)

    ; Bind the Prisoner, who's getting arrested
    BindAliasTo(EscorteeRef, akPrisoner)

    ArrestStart02.Start()
endFunction

function StartNoClothing(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(GuardRef, akGuard)

    ; Bind the Prisoner, who's undressed and given no clothing
    BindAliasTo(PrisonerRef, akPrisoner)

    NoClothing.Start()
endFunction

function StartForcedStripping(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(GuardRef, akGuard)

    ; Bind the Prisoner, who's about to be stripped
    BindAliasTo(PrisonerRef, akPrisoner)

    ForcedStripping01.Start()
endFunction