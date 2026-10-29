main()
{
    level thread setup_packed_mystery_box(); 
    level thread directors_cut_perk_manager();
    level thread give_starting_points();
}

setup_packed_mystery_box()
{
    if (!directors_cut_dvar_enabled("dc_pap_box_weapons"))
    {
        return;
    }

    while (!isDefined(level._id_5F7F))
    {
        wait 0.05;
    }

    level.mystery_box_packed = 1;

    pack_mystery_box_weapons();

    // Refresh the preview cache after changing the pool.
    level.magicboxpreviewweapons = undefined;
    level.directors_cut_box_pool_ready = 1;
}


pack_mystery_box_weapons()
{
    foreach (var_3 in level._id_5F7F)
    {
        var_4 = _id_0547::_id_AAF9(
            var_3["baseNameNoMP"],
            undefined,
            1
        );

        var_1 = _id_0547::_id_9475(var_4) + "_pap_zm";

        if (!_id_0547::_id_5843(var_1))
        {
            continue;
        }

        _id_0548::_id_7CEA(var_3["baseNameNoMP"]);
        _id_0548::_id_09C8(var_1, "none", "none", "none");
    }
}

// Global perk manager: grant Blitz perks, restore lost perks,
// and increase the Quick Revive purchase limit to six.
directors_cut_perk_manager()
{
    if (!directors_cut_dvar_enabled("dc_give_all_perks"))
    {
        return;
    }

    while (
        !isDefined(level._id_6F5C) ||
        !isDefined(level._id_6F5C["quickrevive"])
    )
    {
        wait 0.05;
    }

    if (!directors_cut_dvar_enabled("dc_give_all_perks"))
    {
        return;
    }

    level._id_6F5C["quickrevive"]._id_6078 = 6;

    foreach (player in level.players)
    {
        setup_directors_cut_perks(player);
    }

    for (;;)
    {
        level waittill("player_spawned", player);
        setup_directors_cut_perks(player);
    }
}


setup_directors_cut_perks(player)
{
    if (
        !isDefined(player) ||
        !directors_cut_dvar_enabled("dc_give_all_perks")
    )
    {
        return;
    }

    if (!isDefined(player.dc_perk_monitor_installed))
    {
        player.dc_perk_monitor_installed = 1;
        player thread watch_lost_perks();
    }

    if (!isDefined(player.dc_initial_perks_granted))
    {
        player.dc_initial_perks_granted = 1;
        player thread grant_all_blitz_perks();
    }
}


grant_all_blitz_perks()
{
    self endon("disconnect");

    while (
        !isAlive(self) ||
        _id_0547::_id_577E(self) ||
        _id_0547::_id_57E1(self) ||
        self.sessionstate == "spectator"
    )
    {
        wait 0.05;
    }

    if (!directors_cut_dvar_enabled("dc_give_all_perks"))
    {
        return;
    }

    self _id_056A::_id_4772(0);
}


watch_lost_perks()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("take_perk", perk_name);

        if (!directors_cut_dvar_enabled("dc_give_all_perks"))
        {
            continue;
        }

        // Quick Revive must be repurchased.
        if (perk_name == "quickrevive")
        {
            continue;
        }

        // Ignore nonstandard Blitz entries.
        if (
            perk_name == "armor" ||
            perk_name == "perk_random" ||
            perk_name == "perk_all"
        )
        {
            continue;
        }

        if (!isDefined(level._id_6F5C[perk_name]))
        {
            continue;
        }

        self thread restore_lost_blitz_perk(perk_name);
    }
}


restore_lost_blitz_perk(perk_name)
{
    self endon("disconnect");

    wait 0.1;

    while (
        !isAlive(self) ||
        _id_0547::_id_577E(self) ||
        _id_0547::_id_57E1(self) ||
        self.sessionstate == "spectator"
    )
    {
        wait 0.05;
    }

    if (!directors_cut_dvar_enabled("dc_give_all_perks"))
    {
        return;
    }

    wait 0.1;

    if (
        isDefined(self._id_6F66) &&
        isDefined(self._id_6F66[perk_name])
    )
    {
        return;
    }

    if (!isDefined(level._id_6F5C[perk_name]))
    {
        return;
    }

    self _id_056A::_id_4792(perk_name);
}

give_starting_points()
{
    for (;;)
    {
        level waittill("player_spawned", player);

        if (
            directors_cut_dvar_enabled("dc_give_25000_points") &&
            !isDefined(player.dc_starting_points_granted)
        )
        {
            player.dc_starting_points_granted = 1;
            player maps\mp\gametypes\zombies::_id_7D63(25000);
        }
    }
}


directors_cut_dvar_enabled(dvar_name)
{
    value = getdvar(dvar_name);
    if (!isDefined(value) || value == "")
    {
        setdvar(dvar_name, "1");
        return 1;
    }

    return getdvarint(dvar_name) != 0;
}