init()
{
	thread dc_wheel_boot();
}

dc_wheel_boot()
{
	level endon( "game_ended" );

	// interaction_magicwheel::_id_94EF() 内部先 wait 2 才做 getEntArray，
	// 这里等实体表出现，再多给 1 秒让它那条 foreach（每元素 waitframe）跑完。
	while ( !isDefined( level._id_B163 ) )
	{
		wait 0.1;
	}

	while ( level._id_B163.size <= 0 )
	{
		wait 0.1;
	}

	wait 1;

	level.dc_wheels = [];
	foreach ( var_w in level._id_B163 )
	{
		if ( !isDefined( var_w ) )
		{
			continue;
		}

		level.dc_wheels[ level.dc_wheels.size ] = var_w;
		var_w._dc_busy = 0;
		var_w._dc_cool = 0;
	}

	// 缓存所有"暂停服务 / OUT OF ORDER"牌子
	level.dc_ooo = getEntArray( "out_of_order", "script_noteworthy" );

	// 首次全量点亮：直接复用原版 _id_100ED()，
	// 由它一次性完成 FX、藏牌、makeusable、tag_use、usefov/usarange、hint。
	foreach ( var_w in level.dc_wheels )
	{
		var_w._dc_busy = 1;
		level thread dc_wheel_relight( var_w );
		wait 0.1;
	}

	level thread dc_wheel_watch();
}

// 复用原版点亮流程（带火焰特效，正好做出"全场激活"的观感）
dc_wheel_relight( var_w )
{
	scripts\cp\zombies\interaction_magicwheel::_id_100ED( var_w );
	var_w._dc_busy = 0;
}

// 该用哪种灯效：fire sale > 原版逻辑（normal / upgrade）
// 原版 get_default_fx_state() 读的是 level.magic_wheel_upgraded_pap1 / _pap2，
// 并且还要 cp_disco 的 complete_skull_buster 前置条件，直接转调最省事。
dc_wheel_fx()
{
	if ( scripts\engine\utility::flag_exist( "fire_sale" ) && scripts\engine\utility::flag( "fire_sale" ) )
		return "firesale";

	return scripts\cp\zombies\interaction_magicwheel::get_default_fx_state();
}

/* ------------------------------------------------------------------ */

dc_wheel_watch()
{
	level endon( "game_ended" );

	for ( ;; )
	{
		// ①② 掐掉搬家判定与搬家标志
		level._id_13D01 = 0;
		level._id_B162 = 0;

		var_fx = dc_wheel_fx();

		foreach ( var_w in level.dc_wheels )
		{
			if ( !isDefined( var_w ) )
			{
				continue;
			}

			// ③ 抹掉区域归属，让所有"换区 / 熄灭别台"的代码空转
			var_w.area_name = undefined;

			// 玩家正在这台轮盘上抽奖：把"当前激活"指过去，并进入静默期
			if ( scripts\engine\utility::is_true( var_w.inuse ) )
			{
				level.current_active_wheel = var_w;
				var_w._dc_cool = 4;
				continue;
			}

			// 静默期（4 * 0.25s ≈ 1s）：覆盖原版收尾里那 0.5s 删枪窗口
			if ( scripts\engine\utility::is_true( var_w._dc_cool ) )
			{
				var_w._dc_cool = var_w._dc_cool - 1;
				continue;
			}

			if ( scripts\engine\utility::is_true( var_w._dc_busy ) )
			{
				continue;
			}

			// ④ 幂等恢复：不播特效、不加 wait，纯状态对齐
			var_w setscriptablepartstate( "base", "on" );
			var_w setscriptablepartstate( "fx", var_fx );

			if ( isDefined( var_w._id_10A03 ) )
			{
				var_w._id_10A03 setscriptablepartstate( "spinner", "idle" );
			}

			var_w makeusable();
			var_w setusefov( 60 );
			var_w setuserange( 72 );
		}

		// 压掉所有"暂停服务"牌子
		foreach ( var_f in level.dc_ooo )
		{
			if ( isDefined( var_f ) )
			{
				var_f hide();
			}
		}
		level waittill("spawn_wave_done");
		wait 0.25;
	}
}
