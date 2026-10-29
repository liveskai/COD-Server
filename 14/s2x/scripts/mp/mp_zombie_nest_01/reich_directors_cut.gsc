main()
{
    if (directors_cut_dvar_enabled("dc_reich_auto_build_tesla"))
    {
        replacefunc(
            maps\mp\mp_zombie_nest_ee_hc_raven_weapon_upgrades::_id_7B96,
            ::directors_cut_tesla_upgrade
        );

        replacefunc(
            maps\mp\mp_zombie_nest_ee_workbench::_id_AA70,
            ::directors_cut_auto_build_base_tesla
        );
    }

    if (directors_cut_dvar_enabled("dc_auto_complete_pap"))
    {
        level thread dc_open_pack_a_punch();
    }
    
    level thread give_red_talon_on_spawn();
}


// Give the Red Talon sword when players spawn.
give_red_talon_on_spawn()
{
    for (;;)
    {
        level waittill("player_spawned", player);
        if (directors_cut_dvar_enabled("dc_reich_red_talon"))
        {
            player thread grant_red_talon();
        }
    }
}


grant_red_talon()
{
    self endon("disconnect");

    wait 0.25;

    if (
        directors_cut_dvar_enabled("dc_reich_red_talon") &&
        isAlive(self)
    )
    {
        self _id_0586::_id_078C("raven_sword_zm");
        self _id_0586::_id_078E("raven_sword_zm");
    }
}

directors_cut_tesla_upgrade(
    var_0,
    var_1,
    var_2,
    var_3,
    var_4,
    var_5,
    var_6,
    var_7,
    var_8,
    var_9
)
{
    // Preserve stock analytics.
    _id_0557::_id_4BC9(var_7);
    _id_0557::_id_4BC9(var_8);
    _id_0557::_id_4BC9(var_9);

    // Initialize the workbench using the stock function.
    maps\mp\mp_zombie_nest_ee_workbench::_id_AA75();

    if (!isDefined(level._id_AACA))
    {
        level._id_AACA = [];
    }

    if (!isDefined(level._id_AACA[var_4]))
    {
        level._id_AACA[var_4] =
            maps\mp\mp_zombie_nest_ee_workbench::_id_AA7D(
                var_4,
                self
            );
    }

    // Wait until a player approaches the workbench.
    // Stock check: within 250 units horizontally and 64 vertically.
    var_35 = [0, undefined];

    while (!var_35[0])
    {
        var_35 = maps\mp\mp_zombie_nest_ee_util::_id_745D(
            level._id_AACA[var_4]._id_48F2.origin,
            250,
            128
        );

        wait 0.25;
    }

    // Only bring the workbench out after a player approaches.
    maps\mp\mp_zombie_nest_ee_workbench::_id_AA7A(
        level._id_AACA[var_4]
    );

    common_scripts\utility::_id_9DA3();

    self setHintString(
        maps\mp\mp_zombie_nest_ee_workbench::_id_AA71(var_4)
    );

    // Wait for an actual interaction with the upgrade trigger.
    // Require the player to be holding a Tesla Gun.
    var_36 = "";
    var_11 = undefined;

    while (!issubstr(var_36, "teslagun_zm"))
    {
        self waittill("trigger", var_11);

        var_36 = var_11 getcurrentweapon();

        if (!issubstr(var_36, "teslagun_zm"))
        {
            var_11 iprintlnbold(
                &"ZOMBIE_NEST_ASSEMBLE_WW_REQUIRES"
            );
        }
    }

    // Consume the Tesla Gun submitted for upgrading.
    var_11 _id_0586::_id_0790(
        var_11 getcurrentweapon()
    );

    // Switch away from the consumed weapon.
    var_37 = var_11 getweaponlistprimaries();

    if (var_37.size > 0)
    {
        var_11 switchtoweapon(var_37[0]);
    }

    self setHintString(
        &"ZOMBIE_NEST_ASSEMBLING_WW"
    );

    // Run the crafting animation without restarting the
    // separate Geiskraft/cart electrical activation sequence.
    var_38 = level._id_3578;
    level._id_3578 = 1;

    level._id_AACA[var_4] maps\mp\mp_zombie_nest_ee_workbench::_id_AA73();

    level._id_3578 = var_38;

    // Restore the stock hint and weapon pickup behaviour.
    self setHintString(
        maps\mp\mp_zombie_nest_ee_workbench::_id_AA72(var_4)
    );

    level._id_AACA[var_4] thread maps\mp\mp_zombie_nest_ee_workbench::_id_AA76();

    // Preserve stock completion analytics.
    _id_0557::_id_4BC8(var_9);
    _id_0557::_id_4BC8("tesla gun upgraded");

    // Preserve the original assembled-flag handling.
    if (
        isDefined(var_6) &&
        common_scripts\utility::_id_3C83(var_6)
    )
    {
        common_scripts\utility::flag_set(var_6);
    }
}

// Automatically satisfy the base Tesla workbench's assembly gate.
// The stock _id_AA6B() continues with the actual assembly sequence.
directors_cut_auto_build_base_tesla()
{
    // Assemble the Tesla frame at the workbench.
    self._id_10C0 linkTo(self._id_48F2, "clamp");

    // Show the barrel and core.
    self._id_10BE show();
    self._id_10BF show();
}

dc_open_pack_a_punch()
{
    // Wait until mp_zombie_nest_pneumos has initialized the stock cage state.
    while (!isDefined(level._id_6E33) ||
           !isDefined(level._id_6E33._id_1E31) ||
           !isDefined(level._id_6E33._id_1E2D) ||
           !isDefined(level._id_1E2E) ||
           !isDefined(level._id_1E30))
    {
        waitframe();
    }

    // Let the stock cage-button setup finish first.
    wait 1;

    // Run each remaining stock cage-lift stage. The stock routine performs
    // the normal cage animations/events and calls its own finalizer at the
    // final stage, which removes the clip and sets flag_pap_available.
    while (level._id_1E2E < level._id_1E30)
    {
        maps\mp\mp_zombie_nest_pneumos::_id_7A2D();
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