Scriptname RealisticPrisonAndBounty_Daymoyl extends daymoyl_QuestTemplate

RealisticPrisonAndBounty_Config property config auto

bool function QuestCondition(Location akLocation, Actor akAggressor, Actor akFollower)
    config.NotifyArrest("QuestCondition - DA Integration is working!")
    Faction arrestFaction = akAggressor.GetCrimeFaction()
	; SendModEvent("da_ForceBlackout")
    ; akAggressor.PushActorAway(config.Player, 1.0)
    ; config.Player.SetUnconscious()
    ; arrestFaction.SendModEvent("RPB_ArrestBegin", "TeleportToCell", 0x14)

    return arrestFaction.GetCrimeGold() > 0

    return true
endFunction

bool function QuestStart(Location akCurrentLoc, Actor akAggressor, Actor akFollower)
    config.NotifyArrest("QuestStart - DA Integration is working!")
    ; akAggressor.PushActorAway(config.Player, 1.0)
    ; config.Player.SetUnconscious()
	SendModEvent("da_DisableAnimationSystem")
	SendModEvent("da_StartRecoverSequence")

    akAggressor.SendModEvent("RPB_SetPlayerDefeated")
    akAggressor.SendModEvent("RPB_ArrestBegin", "TeleportToCell", 0x14)
    return true
endFunction