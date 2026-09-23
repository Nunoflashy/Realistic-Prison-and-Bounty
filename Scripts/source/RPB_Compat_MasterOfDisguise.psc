scriptname RPB_Compat_MasterOfDisguise hidden

;/
@functions:
    Form[] function GetFactions() global
@events:
/;

;/
    Compatibility block for fireundubh's Master of Disguise (SE), NOT general RPB logic - kept in its own file, with its own
    naming, specifically so it's easy to find/remove/generalize later. See RPB_Utility.RPB_GetHostileFactions(), which unions
    this with RPB's own vanilla hostile-faction list.

    Why this exists: MoD adds the player to one of its OWN Faction records while disguised (e.g. "Bandits" while wearing a
    bandit disguise), not to the vanilla BanditFaction/etc. RPB's hostile-prisoner neutralization only ever checked the
    vanilla factions, so it silently never found (or removed) anything for a disguised player - confirmed by me
    manually removing MoD's actual Bandits faction via the console (one call, no reapplication, arrest worked end to end)
    while RPB's own fix, still checking vanilla BanditFaction, kept reporting nothing to remove.

    The 31 factions (installed plugin: "Master of Disguise - Special Edition.esp") were enumerated directly from the in-game
    console (a Faction-type filter), not guessed: editor IDs are a clean, zero-padded "dubhDisguiseFaction" + NN pattern,
    NN 01 through 31 (01 Blades, 02 Cultists, 03 Dark Brotherhood, 04 Dawnguard, 05 Forsworn, 06 Imperial Legion, 07 Morag
    Tong, 08 Penitus Oculatus, 09 Silver Hand, 10 Stormcloaks, 11 Thalmor, 12 Thieves Guild, 13 Vigil of Stendarr, 14
    Volkihar Clan, 15 Necromancers, 16 Vampires, 17 Werewolves, 18 Companions, 19-28 one per Hold's own guard faction
    (Falkreath/Hjaalmarch/Markarth/Pale/Raven Rock/Riften/Solitude/Whiterun/Windhelm/Winterhold Guard), 29 Daedric Influence,
    30 Alik'r Mercenaries, 31 Bandits).

    Resolved by editor ID (through PO3 Papyrus Extender, already a dependency) rather than pinning the exact FormIDs: local
    form IDs could shift if MoD is ever updated (records reordered/inserted), but a deliberately-named editor ID like
    "dubhDisguiseFaction05" is far less likely to change. RPB_GetHostileFactions() caches the combined result, so this list
    (31 editor-ID resolutions) only actually runs once per save, not on every arrest/hourly check.

    Not yet configurable - I've hardcoded this to this one mod, deliberately, for now, until a second disguise mod actually
    needs supporting.
/;
Form[] function GetFactions() global
    int count = 31
    Form[] factions = new Form[31]
    int resolved = 0
    int i = 1
    while (i <= count)
        string suffix = i as string
        if (i < 10)
            suffix = "0" + suffix
        endif

        Faction disguiseFaction = PO3_SKSEFunctions.GetFormFromEditorID("dubhDisguiseFaction" + suffix) as Faction
        if (disguiseFaction)
            factions[resolved] = disguiseFaction
            resolved += 1
        else
            RPB_Utility.Warn("RPB_Compat_MasterOfDisguise could not resolve editor ID 'dubhDisguiseFaction" + suffix + "' to a Faction (Master of Disguise not installed, or a different version)")
        endif
        i += 1
    endWhile

    if (resolved == count)
        return factions
    endif
    if (resolved == 0)
        return none ; Master of Disguise isn't installed (or every editor ID failed): the common case for most users
    endif

    Form[] trimmed = Utility.CreateFormArray(resolved)
    i = 0
    while (i < resolved)
        trimmed[i] = factions[i]
        i += 1
    endWhile
    return trimmed
endFunction
