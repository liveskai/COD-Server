init()
{
    level thread dc_magicbox_all();
}

dc_magicbox_all()
{
    level endon("game_ended");
    // ---------------------------------------------------------------
    // 1) 等主控把箱子数组建出来（_zombies_magicbox.gsc:1467）
    //    level.var_5F74 = getEntArray("magic_box", "targetname");
    // ---------------------------------------------------------------
    while (!isDefined(level._id_5F74) || level._id_5F74.size == 0)
        wait 0.5;

    // ---------------------------------------------------------------
    // 2) 等主控初始化彻底走完
    //    :1524 先把主控箱 var_08BE 置 1
    //    :1526 wait(2)
    //    :1528 把【所有】箱 func_6AE1 关一遍
    //    :1530 才置 magic_box_init
    //    早于 :1530 动手，你的箱会被 :1528 关掉。
    // ---------------------------------------------------------------
    while (!common_scripts\utility::_id_3C83("magic_box_init") ||
           !common_scripts\utility::_id_3C77("magic_box_init"))
    {
        wait 0.05;
    }

    wait 0.5;
    level.dc_magicbox_done = 1;

    // ---------------------------------------------------------------
    // 3) 备份全部箱子
    // ---------------------------------------------------------------
    level.dc_all_boxes = [];
    foreach (entry in level._id_5F74)
    {
        level.dc_all_boxes[level.dc_all_boxes.size] = entry;
    }

    if (level.dc_all_boxes.size <= 1)
    {
        // 这张图只有一个箱，什么都不用做
        return;
    }

    // ---------------------------------------------------------------
    // 4) 找出主控当前正在服务的那个箱（唯一 var_08BE == 1 的）
    //    主控 func_5F7B 会一直阻塞在 func_A922(var_00, 0) 上，
    //    必须把它留在数组里，否则会有两条线程同时服务同一个箱。
    // ---------------------------------------------------------------
    var_main = undefined;
    foreach (cand in level.dc_all_boxes)
    {
        if (!isDefined(var_main) && isDefined(cand._id_08BE) && cand._id_08BE)
        {
            var_main = cand;
        }
    }

    if (!isDefined(var_main))
    {
        var_main = level.dc_all_boxes[0];
    }

    // ---------------------------------------------------------------
    // 5) ★ 核心一行：箱子数组只保留主控箱
    //    => _zombies_magicbox.gsc:1814 的 level.var_5F74.size > 1
    //       永远为 false
    //    => var_0F 永远为 false
    //    => 用满 4~6 次也不会关箱、不会换位置、不会"失败"
    // ---------------------------------------------------------------
    level._id_5F74 = [];
    level._id_5F74[0] = var_main;

    // ---------------------------------------------------------------
    // 6) 剩下的箱子：全部点亮 + 各开一条常驻服务线程
    //    _id_6AB4 = 开盖 / 亮灯 / solid()    （:1596 func_6AB4）
    //    _id_A922 = 单箱服务循环             （:1779 func_A922）
    //    第二个参数必须是 0：传 1 是 fire sale 模式，
    //    :1796 if(param_01 && !fire_sale) break; 会立刻退出。
    // ---------------------------------------------------------------
    foreach (box in level.dc_all_boxes)
    {
        if (box == var_main)
        {
            continue;
        }

        box._id_08BE = 1;
        level thread _id_0548::_id_6AB4(box);
        level thread dc_magic_box_serve(box);
    }
}


// ----------------------------------------------------------------------
//  单箱常驻服务
//  func_A922 是阻塞式循环，正常情况因为 size == 1 永不返回；
//  外面套 for(;;) 只是兜底（万一收到 deactivated / fireSaleOver）。
//  退出时 func_A922 末尾会调 func_6AE1 关箱，
//  所以重新进入时靠它开头的 func_6AB4 自己重新打开。
// ----------------------------------------------------------------------
dc_magic_box_serve(box)
{
    level endon("game_ended");

    for (;;)
    {
		level waittill("zombie_wave_ended");
        box._id_08BE = 1;
        _id_0548::_id_A922(box, 0);
        wait 0.5;
    }
}
