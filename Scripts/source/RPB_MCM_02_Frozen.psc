Scriptname RPB_MCM_02_Frozen hidden

;/
    RPB - Stats' "Frozen NPCs" page (only listed while one is frozen, RPB_MCM_02.InitializePages): an NPC whose Papyrus
    object stopped answering, what RPB knew of him and what it did about him. Everything shown was stored before or when
    he was found (RPB_Utility.MarkGuardFrozen, NoteFrozenAction, RememberActorName): a call into him would hang the menu.
@functions:
    function Render(RPB_MCM_02 mcm, Actor akFrozen) global
/;

import RPB_Utility

function Render(RPB_MCM_02 mcm, Actor akFrozen) global
    int report = FrozenReport(akFrozen)
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)

    mcm.AddOptionCategory("Frozen NPC")
    mcm.AddOptionText("Name", ActorNameNoCall(akFrozen), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Role", JMap.getStr(report, "role"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Form ID", akFrozen as string, defaultFlags = mcm.OPTION_DISABLED)
    string prison = JMap.getStr(report, "prison")
    if (prison != "")
        mcm.AddOptionText("Prisoner in", prison, defaultFlags = mcm.OPTION_DISABLED)
    endif
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("When and where")
    mcm.AddOptionText("Found", JMap.getStr(report, "foundAt"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Doing", JMap.getStr(report, "probedAt"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Found by", JMap.getStr(report, "foundBy"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Player was in", JMap.getStr(report, "where"), defaultFlags = mcm.OPTION_DISABLED)
    mcm.AddOptionText("Distance", JMap.getStr(report, "distance"), defaultFlags = mcm.OPTION_DISABLED)

    mcm.SetCursorPosition(1)
    mcm.AddOptionCategory("What RPB did")
    int actions = JMap.getObj(report, "actions")
    int count = JArray.count(actions)
    if (count == 0)
        mcm.AddOptionText("Nothing yet", "", defaultFlags = mcm.OPTION_DISABLED)
    endif
    int i = 0
    while (i < count)
        mcm.AddOptionText(JArray.getStr(actions, i), "", defaultFlags = mcm.OPTION_DISABLED)
        i += 1
    endWhile
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Magic effects on him (" + JMap.getInt(report, "effectCount") + ")")
    int effects = JMap.getObj(report, "effects")
    i = 0
    while (i < JArray.count(effects))
        mcm.AddOptionText(JArray.getStr(effects, i), "", defaultFlags = mcm.OPTION_DISABLED)
        i += 1
    endWhile
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Note")
    mcm.AddOptionText("He answers again once a save is loaded", "", defaultFlags = mcm.OPTION_DISABLED)
endFunction
