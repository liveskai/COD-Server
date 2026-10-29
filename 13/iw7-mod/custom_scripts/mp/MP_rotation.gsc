init()
{
	thread rot_init();
}
rot_build()
{
	maps  = 
	[
		"mp_permafrost2", "mp_frontier", "mp_afghan", "mp_depot", "mp_flip",
		"mp_geneva", "mp_renaissance2", "mp_hawkwar", "mp_junk", "mp_mansion",
		"mp_marsoasis", "mp_turista2", "mp_neon", "mp_nova", "mp_overflow",
		"mp_paris", "mp_pixel", "mp_prime", "mp_rally", "mp_carnage2",
		"mp_parkour", "mp_proto", "mp_quarry", "mp_riot", "mp_rivet",
		"mp_skyway", "mp_breakneck", "mp_codphish", "mp_desert", "mp_divide",
		"mp_dome_iw", "mp_fallen", "mp_metropolis", "mp_dome_dusk"
	];
	modes = ["war", "dom", "conf", "koth"];

	if(!isDefined(modes) || modes.size == 0)
		modes = ["war"];

	// Fisher-Yates 洗牌：打乱地图顺序
	for(i = maps.size - 1; i > 0; i--)
	{
		j = randomInt(i + 1);
		t = maps[i];
		maps[i] = maps[j];
		maps[j] = t;
	}

	// 每张图配一个随机模式
	s = "";
	foreach(m in maps)
		s = s + "gametype " + modes[randomInt(modes.size)] + " map " + m + " ";

	return s;
}
rot_init()
{
	// 等地图加载完再写，太早会被引擎初始化覆盖
	wait 2;

	r = rot_build();

	// 两个都写：
	//   sv_mapRotation        —— 整轮顺序
	//   sv_mapRotationCurrent —— 当前剩余；非空时优先读它，覆盖它才是"每局重洗"
	setDvar("sv_mapRotation", r);
	setDvar("sv_mapRotationCurrent", r);

	print("^2[轮换] ^7本局已重新洗牌");
	print("^2[轮换] ^7" + r);
}
