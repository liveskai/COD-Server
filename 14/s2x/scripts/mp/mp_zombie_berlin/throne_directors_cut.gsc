main()
{
    if (dc_dvar_enabled("dc_throne_build_melee"))
    {
        level thread dc_skip_stock_melee_quests();
    }

    replacefunc(maps\mp\mp_zombie_berlin_ee_hc::hc_quest_finale_init, ::dc_finale_init);

    if (dc_dvar_enabled("dc_throne_build_wunderbuss"))
    {
        replacefunc(maps\mp\mp_zombie_berlin_ee::quest_wunderbuss_logic, ::dc_wunderbuss_logic);
    }

    level thread dc_set_reveal_flags();

    if (dc_dvar_enabled("dc_auto_complete_pap"))
    {
        level thread dc_unlock_shattered_pap();
    }
}

dc_dvar_enabled(dvar_name)
{
    value = getdvar(dvar_name);

    if (!isDefined(value) || value == "")
    {
        setdvar(dvar_name, "1");
        return 1;
    }

    return getdvarint(dvar_name) != 0;
}

// ------------------------------------------------------------
// Flag helpers
// ------------------------------------------------------------

dc_init_flags(flags)
{
    foreach (flag in flags)
    {
        common_scripts\utility::flag_init(flag);
    }
}

dc_set_flags(flags)
{
    foreach (flag in flags)
    {
        common_scripts\utility::flag_set(flag);
    }
}

dc_wait_for_flags(flags)
{
    for (;;)
    {
        var_0 = 1;

        foreach (flag in flags)
        {
            if (!common_scripts\utility::_id_3C83(flag))
            {
                var_0 = 0;
                break;
            }
        }

        if (var_0)
        {
            return;
        }

        waitframe();
    }
}

dc_hide_targetname(name)
{
    var_0 = getEntArray(name, "targetname");

    foreach (var_1 in var_0)
    {
        var_1 hide();
    }
}

dc_show_targetname(name)
{
    var_0 = getEntArray(name, "targetname");

    foreach (var_1 in var_0)
    {
        var_1 show();
    }
}

dc_hide_noteworthy(name)
{
    var_0 = getEntArray(name, "script_noteworthy");

    foreach (var_1 in var_0)
    {
        var_1 hide();
    }
}

// ------------------------------------------------------------
// Melee weapons: let the map's original quest initialization and weapon
// handlers run. Only satisfy the prerequisites that hide the three weapons.
// This keeps the stock Bat trigger, Dagger safe, and Pickaxe drawer flow,
// including the stock weapon-grant logic and its upgrade-related state.
// ------------------------------------------------------------

dc_skip_stock_melee_quests()
{
    // Let the stock map init register its quest flags and start its handlers.
    wait 1;

    // Stock skip helper advances the Bat quest without replacing its handlers.
    // The stock door interaction and bat_pickup_trigger listener remain intact.
    maps\mp\mp_zombie_berlin_ee_hc::hc_quest_bat_debug_skip_step02_alt();

    // Skip the Dagger's projector/painting/collection/safe puzzle prerequisites.
    // The stock safe initializer, safe opening animation, and pickup handler run.
    dc_set_flags([
        "flag_hc_quest_dagger_step01_film_reel_complete",
        "apartment_dagger_painting_found",
        "flag_hc_quest_dagger_step01_painting_complete",
        "flag_hc_quest_dagger_step01_projector_on_complete",
        "flag_hc_quest_dagger_step02_soul_collection_complete",
        "flag_hc_quest_dagger_step03_safe_opened"
    ]);

    // Use the stock Pickaxe debug skip. The original scale/drawer code reveals
    // the weapon and registers axe_pickup_trigger with the stock weapon helper.
    maps\mp\mp_zombie_berlin_ee_hc::hc_quest_axe_debug_skip_all();
}

// ------------------------------------------------------------
// Start with the first three melee weapons already displayed in the garden
// keyholes. Weapon acquisition and swapping stay at the normal map pickups.
// The normal sword-to-keyhole progression is retained for the sword itself.
// ------------------------------------------------------------

dc_finale_init()
{
    dc_init_flags([
        "flag_hc_quest_finale_weapons_collected",
        "flag_hc_quest_finale_door_open",
        "statue_puzzle_success",
        "flag_hc_quest_finale_sword_door_open"
    ]);

    dc_set_flags([
        "flag_hc_quest_finale_weapons_collected",
        "flag_hc_quest_finale_door_open",
        "statue_puzzle_success"
    ]);

    // These slots are already completed for Directors Cut; keep their models visible.
    // Weapon pickups remain at the original Smuggler, safe, and axe locations.
    level.bat_key_placed = 1;
    level.dagger_key_placed = 1;
    level.pickaxe_key_placed = 1;

    dc_show_targetname("garden_keyhole_placed_bat");
    dc_show_targetname("garden_keyhole_placed_dagger");
    dc_show_targetname("garden_keyhole_placed_pickaxe");

    var_0 = getEnt("garden_door_bat_keyhole", "targetname");
    if (isDefined(var_0))
    {
        var_0 setHintString("");
    }

    var_0 = getEnt("garden_door_dagger_keyhole", "targetname");
    if (isDefined(var_0))
    {
        var_0 setHintString("");
    }

    var_0 = getEnt("garden_door_pickaxe_keyhole", "targetname");
    if (isDefined(var_0))
    {
        var_0 setHintString("");
    }

    if (!dc_dvar_enabled("dc_throne_build_melee"))
    {
        return;
    }

    var_0 = getEnt("garden_keyhole_placed_sword", "targetname");
    if (isDefined(var_0))
    {
        var_0 hide();
    }

    // This is the cover removed by the stock bird puzzle to expose the sword.
    var_0 = getEnt("bird_statue_sword_bit", "targetname");
    if (isDefined(var_0))
    {
        var_0 delete();
    }

    var_0 = getEnt("sword_pickup_trig", "targetname");
    if (isDefined(var_0))
    {
        var_0 setHintString(&"ZOMBIE_BERLIN_WEAPON_PICKUP");
        level thread maps\mp\mp_zombie_berlin_utils::special_melee_weapon_pickup_think(var_0, "sword");
    }

    // Keep the stock sword placement progression for the later gate.
    level thread maps\mp\mp_zombie_berlin_ee_hc::hc_quest_finale_step03_handler();

    // Open the gate leading to the sword now instead of closing it for the bird quest.
    level thread maps\mp\mp_zombie_berlin_ee_hc::hc_quest_finale_utility_open_doors();
}


// ------------------------------------------------------------
// Wunderbuss: preassemble the workbench weapon. The stock builder
// still reveals the finished weapon and handles taking it from the bench.
// ------------------------------------------------------------

dc_wunderbuss_logic()
{
    // Remove the hidden collision blocker immediately; do not move the gate models.
    dc_open_wunderbuss_room();

    var_0 = common_scripts\utility::_id_46B5("weapon_assembly_bench", "targetname");

    while (!isDefined(var_0) || !isDefined(var_0.assembly_trig) || !isDefined(var_0.assembly_model_complete))
    {
        waitframe();
    }

    dc_set_flags([
        "flag_quest_wunderbuss_battery_collected",
        "flag_quest_wunderbuss_battery_placed",
        "flag_quest_wunderbuss_geistbolt_collected",
        "flag_quest_wunderbuss_geistbolt_placed"
    ]);

}

dc_open_wunderbuss_room()
{
    if (!dc_dvar_enabled("dc_throne_build_wunderbuss"))
    {
        return;
    }

    level.smuggler_den_doors_open = 1;

    var_0 = getEntArray("smuggler_den_door_main_body", "script_noteworthy");

    foreach (var_1 in var_0)
    {
        var_1 notsolid();
        var_1 connectpaths();
    }
}

// ------------------------------------------------------------
// Pack-a-Punch: fire the two stock completion notifications used by
// the existing electric-box/elevator handler.
// ------------------------------------------------------------

dc_unlock_shattered_pap()
{
    dc_wait_for_flags(["pap_ww_blasted_1", "pap_ww_blasted_2"]);
    wait 1;

    level notify("pap_electric_box_complete");

    while (!common_scripts\utility::_id_3C77("pap_ww_blasted_1"))
    {
        waitframe();
    }

    level notify("pap_electric_box_complete");

    while (!common_scripts\utility::_id_3C77("pap_ww_blasted_2"))
    {
        waitframe();
    }
}

// The stock notebook initializes these global reveal flags in parallel
// with the skipped quests. Wait until that initialization is complete,
// then mark each of the four melee weapons and the Wunderbuss revealed.
dc_set_reveal_flags()
{
    if (dc_dvar_enabled("dc_throne_build_melee"))
    {
        dc_wait_for_flags([
            "hc_bat_revealed",
            "hc_dagger_revealed",
            "hc_pickaxe_revealed"
        ]);

        dc_set_flags([
            "hc_bat_revealed",
            "hc_dagger_revealed",
            "hc_pickaxe_revealed"
        ]);
    }

    if (dc_dvar_enabled("dc_throne_build_melee"))
    {
        dc_wait_for_flags(["hc_sword_revealed"]);
        dc_set_flags(["hc_sword_revealed"]);
    }

    if (dc_dvar_enabled("dc_throne_build_wunderbuss"))
    {
        dc_wait_for_flags(["hc_wunderbuss_zm_revealed"]);
        dc_set_flags(["hc_wunderbuss_zm_revealed"]);
    }
}
