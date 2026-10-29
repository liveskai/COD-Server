main()
{
    if (directors_cut_dvar_enabled("dc_shore_auto_build_ripsaw"))
    {
        replacefunc(
            maps\mp\zquests\casual\island_ee_main::razergun_parts_collect,
            ::directors_cut_razergun_parts_collect
        );

        level thread directors_cut_enable_ripsaw_pap();
    }

    replacefunc(
        maps\mp\mp_zombie_island_ee_pack_a_punch_unlock::add_player_fuse_count,
        ::directors_cut_add_player_fuse_count
    );
    level thread directors_cut_give_all_pap_fuses();
}


directors_cut_razergun_parts_collect()
{
    // Automatically collect all Ripsaw components.
    common_scripts\utility::flag_set("players_have_razergun_1");
    common_scripts\utility::flag_set("players_have_razergun_2");
    common_scripts\utility::flag_set("players_have_razergun_3");

    // Automatically assemble all three parts.
    common_scripts\utility::flag_set("razergun_1_placed");
    common_scripts\utility::flag_set("razergun_2_placed");
    common_scripts\utility::flag_set("razergun_3_placed");

    // Skip the soul-charging and infusion requirements.
    common_scripts\utility::flag_set("razergun_half_charged");
    common_scripts\utility::flag_set("razergun_charged");
    common_scripts\utility::flag_set("razergun_infused");

    // Preserve stock quest progression.
    common_scripts\utility::_id_3CA0(
        "players_have_razergun_1",
        "players_have_razergun_2"
    );

    _id_0557::_id_782D("explore_the_island", "Explore Pen");
}


directors_cut_enable_ripsaw_pap()
{
    if (!directors_cut_dvar_enabled("dc_shore_auto_build_ripsaw"))
    {
        return;
    }

    // Wait for Darkest Shore's stock flags to initialize.
    while (!common_scripts\utility::_id_3C83("ibeam_complete"))
    {
        waitframe();
    }

    // Bypass the normal Ripsaw Pack-a-Punch unlock requirement.
    common_scripts\utility::flag_set("ripsaw_punch_active");
}

directors_cut_give_all_pap_fuses()
{
    // Grant the fuses once the first player spawns.
    level waittill("player_spawned", player);

    if (!directors_cut_dvar_enabled("dc_auto_complete_pap"))
    {
        return;
    }

    while (!isDefined(level.pack_a_punch_current_access_count))
    {
        waitframe();
    }

    level.pack_a_punch_current_access_count = 3;

    common_scripts\utility::flag_set("pap_elevator_access_1");
    common_scripts\utility::flag_set("pap_elevator_access_2");
    common_scripts\utility::flag_set("pap_elevator_access_3");
}


directors_cut_add_player_fuse_count()
{
    // Never let the shared fuse count exceed three.
    if (level.pack_a_punch_current_access_count >= 3)
    {
        return;
    }

    level.pack_a_punch_current_access_count++;

    common_scripts\utility::flag_set(
        "pap_elevator_access_" + level.pack_a_punch_current_access_count
    );
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