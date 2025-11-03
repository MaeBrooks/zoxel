const std = @import("std");

const flecs = @import("zflecs");

const Components = @import("components.zig");
const Config = @import("config.zig");
const Renderer = @import("renderer.zig");
const Systems = @import("systems.zig");
const Tags = @import("tags.zig");
const Mem = @import("mem.zig");

const Phase = @import("phase.zig");

pub fn main() !void {
    const renderer = Renderer.init();
    const config: Config.T = .{ .target_fps = 0 };
    renderer.start(&config);
    defer renderer.end();

    const world = flecs.init();
    {
        Tags.defaults(world);
        Components.defaults(world);

        flecs.singleton_add(world, Config.T);
        _ = flecs.singleton_set(world, Config.T, config);

        Phase._init(world);
    }

    std.debug.print("spawning thread\n", .{});
    _ = try std.Thread.spawn(.{}, server, .{world});

    std.debug.print("starting ui render\n", .{});
    while (true) {
        if (flecs.should_quit(world)) break;
        if (renderer.should_window_close()) break;

        renderer.begin_drawing();
        try renderer.overlay();
        renderer.end_drawing();
    }

    Systems.OnQuit.run(world);
}

fn server(world: *flecs.world_t) !void {
    std.debug.print("starting server: {}\n", .{world});
    const init_system = try Systems.OnInit.init(world);
    defer Mem.destroy(init_system);

    const before_update_system = try Systems.OnBeforeUpdate.init(world);
    defer Mem.destroy(before_update_system);

    const tick_system = try Systems.OnTick.init(world);
    defer Mem.destroy(tick_system);

    std.debug.print("Adding tick handlers\n", .{});
    try Systems.OnTick.add(my_on_tick_func);

    std.debug.print("Staring process loop!\n", .{});
    while (!flecs.should_quit(world)) {
        while (flecs.progress(world, 0)) {}
    }
}

fn my_on_tick_func(it: *flecs.iter_t) void {
    std.debug.print("on_tick: {s}\n", .{flecs.get_name(it.world, it.system).?});
}
