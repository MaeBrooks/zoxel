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
    const world = flecs.init();
		flecs.set_threads(world, @intCast(try std.Thread.getCpuCount()));

    Tags.defaults(world);
    Components.defaults(world);

		const config: Config.T = .{ .target_fps = 0 };
		const renderer = Renderer.init();

		{
				flecs.singleton_add(world, Config.T);
				flecs.singleton_add(world, Renderer.T);
				_ = flecs.singleton_set(world, Config.T, config);
				_ = flecs.singleton_set(world, Renderer.T, renderer);
		}

		Phase._init(world);

		const init_system = try Systems.OnInit.init(world);
		const before_update_system = try Systems.OnBeforeUpdate.init(world);
		const render_system = try Systems.OnRender.init(world);
		const tick_system = try Systems.OnTick.init(world);

		defer Mem.destroy(init_system);
		defer Mem.destroy(before_update_system);
		defer Mem.destroy(render_system);
		defer Mem.destroy(tick_system);

		try Systems.OnTick.add(my_on_tick_func);

		while (!flecs.should_quit(world)) {
				while (flecs.progress(world, 0)) {}
		}

		Systems.OnQuit.run(world);
}


fn my_on_tick_func(it: *flecs.iter_t) void {
		std.debug.print("on_tick: {s}\n", .{ flecs.get_name(it.world, it.system).? });
}
