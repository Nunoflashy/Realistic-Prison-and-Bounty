scriptname RealisticPrisonAndBounty_EventManager extends Quest

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

RealisticPrisonAndBounty_SceneManager property sceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return config.sceneManager
    endFunction
endProperty


; ==========================================================
;                        Scene Events
; ==========================================================

event OnSceneStart(string sceneName, ObjectReference[] data, Scene sender)
    if (sceneName == sceneManager.SCENE_ESCORT_TO_CELL)
        Actor escort   = data[0] as Actor
        Actor escortee = data[1] as Actor

        if (escortee == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        int i = 0
        while (i < data.Length)
            if (data[i] != None && data[i] != escort)
                jail.OnEscortToCellBegin(escort, data[i] as Actor)
            endif
            i += 1
        endWhile

    elseif (sceneName == sceneManager.SCENE_ESCORT_TO_JAIL)
        Actor escort   = data[0] as Actor
        Actor escortee = data[1] as Actor
        Actor escortee02 = data[2] as Actor
        Actor escortee03 = data[3] as Actor

        if (escortee == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        int i = 0
        while (i < data.Length)
            if (data[i] != None && data[i] != escort)
                jail.OnEscortToJailBegin(escort, data[i] as Actor)
            endif
            i += 1
        endWhile

        ; jail.OnEscortToJailBegin(escort, escortee)

    elseif (sceneName == sceneManager.SCENE_STRIPPING)
        Actor stripperGuard     = data[0] as Actor
        Actor strippedPrisoner  = data[1] as Actor

        if (strippedPrisoner == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        jail.OnStripBegin(stripperGuard, strippedPrisoner)

    elseif (sceneName == sceneManager.SCENE_FRISKING)
        Actor searcherGuard     = data[0] as Actor
        Actor searchedPrisoner  = data[1] as Actor

        if (searchedPrisoner == config.Player)
            Game.SetPlayerAIDriven(true)
        endif
        
        jail.OnFriskBegin(searcherGuard, searchedPrisoner)

    elseif (sceneName == sceneManager.SCENE_PAYMENT_FAIL)
        Actor guard     = data[0] as Actor
        Actor prisoner  = data[1] as Actor

        if (prisoner == config.Player)
            Game.SetPlayerAIDriven(true)
        endif
        
        ; jail.OnBountyPaymentFailed(guard, prisoner)
    endif

    Debug(self, "EventManager::OnSceneStart", "Scene: " + sender +", Scene name: " + sender.GetName())
    Debug(self, "EventManager::OnSceneStart", sceneManager.GetSceneParametersDebugInfo(sceneName, data))
endEvent

event OnScenePlaying(string sceneName, int scenePart, int phase, ObjectReference[] data, Scene sender)
    Debug(self, "EventManager::OnScenePlaying", string_if (scenePart == sceneManager.SCENE_PLAYING_START, "(Start) Playing", "(End) Played") + " Phase " + phase + " of " + sceneName)
    
    if (sceneName == sceneManager.SCENE_ESCORT_TO_CELL)
        if (scenePart == sceneManager.SCENE_PLAYING_START)
            if (phase == 4)
                debug.notification("Phase 4 played for " + sceneName)
            endif
            
        elseif (scenePart == sceneManager.SCENE_PLAYING_END)

        endif

    elseif (sceneName == sceneManager.SCENE_ESCORT_TO_JAIL)

        if (scenePart == sceneManager.SCENE_PLAYING_START)
            
        elseif (scenePart == sceneManager.SCENE_PLAYING_END)

        endif

    elseif (sceneName == sceneManager.SCENE_STRIPPING)
        Actor stripperGuard     = data[0] as Actor
        Actor strippedPrisoner  = data[1] as Actor

        if (scenePart == sceneManager.SCENE_PLAYING_START)
            if (phase == 7)
                ; Remove underwear
                jail.Prisoner.RemoveUnderwear()
            endif
            
        elseif (scenePart == sceneManager.SCENE_PLAYING_END)
            if (phase == 3)
                debug.notification("Played Phase " + phase + " of " + sceneName)
                int i = 0
                while (i < data.Length)
                    if (data[i] != None && data[i] != stripperGuard)
                        jail.OnStripping(stripperGuard, data[i] as Actor)
                    endif
                    i += 1
                endWhile
                ; jail.OnStripping(stripperGuard, strippedPrisoner)
            endif
        endif

    elseif (sceneName == sceneManager.SCENE_FRISKING)

        if (scenePart == sceneManager.SCENE_PLAYING_START)
            
        elseif (scenePart == sceneManager.SCENE_PLAYING_END)

        endif

    elseif (sceneName == sceneManager.SCENE_GIVE_CLOTHING)

        if (scenePart == sceneManager.SCENE_PLAYING_START)
            
        elseif (scenePart == sceneManager.SCENE_PLAYING_END)

        endif

    elseif (sceneName == sceneManager.SCENE_UNLOCK_CELL)

        if (scenePart == sceneManager.SCENE_PLAYING_START)
            
        elseif (scenePart == sceneManager.SCENE_PLAYING_END)
            if (phase == 3)
                debug.notification("Phase 3 played for " + sceneName)
            endif
        endif

    endif
endEvent

event OnSceneEnd(string sceneName, ObjectReference[] data, Scene sender)
    if (sceneName == sceneManager.SCENE_ESCORT_TO_CELL)
        Actor escort   = data[0] as Actor
        Actor escortee = data[1] as Actor

        if (escortee == config.Player)
            Game.SetPlayerAIDriven(false)
        endif

        jail.OnEscortToCellEnd(escort, escortee)

    elseif (sceneName == sceneManager.SCENE_ESCORT_TO_JAIL)
        Actor escort   = data[0] as Actor
        Actor escortee = data[1] as Actor

        jail.OnEscortToJailEnd(escort, escortee)

    elseif (sceneName == sceneManager.SCENE_STRIPPING)
        Actor stripperGuard     = data[0] as Actor
        Actor strippedPrisoner  = data[1] as Actor

        int i = 0
        while (i < data.Length)
            Form cuffs = Game.GetFormEx(0xA081D33)

            if (data[i] != None && data[i] != stripperGuard)
                (data[i] as Actor).SheatheWeapon()
                (data[i] as Actor).EquipItem(cuffs, true, true)
            endif
            i += 1
        endWhile

        jail.OnStripEnd(stripperGuard, strippedPrisoner)

    elseif (sceneName == sceneManager.SCENE_FRISKING)
        Actor searcherGuard     = data[0] as Actor
        Actor searchedPrisoner  = data[1] as Actor

        jail.OnFriskEnd(searcherGuard, searchedPrisoner)

    elseif (sceneName == sceneManager.SCENE_GIVE_CLOTHING)
        Actor searcherGuard     = data[0] as Actor
        Actor searchedPrisoner  = data[1] as Actor

        if (searchedPrisoner == config.Player)
            Game.SetPlayerAIDriven(false)
        endif

        jail.OnClothingGiven(searcherGuard, searchedPrisoner)

    elseif (sceneName == sceneManager.SCENE_PAYMENT_FAIL)
        Actor guard     = data[0] as Actor
        Actor prisoner  = data[1] as Actor

        if (prisoner == config.Player)
            Game.SetPlayerAIDriven(true)
        endif

        jail.OnBountyPaymentFailed(guard, prisoner)
    endif

    Debug(self, "EventManager::OnSceneEnd", "Scene: " + sender +", Scene name: " + sender.GetName())
    Debug(self, "EventManager::OnSceneEnd", sceneManager.GetSceneParametersDebugInfo(sceneName, data))
endEvent

