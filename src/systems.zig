const std = @import("std");
const flecs = @import("zflecs");

const Config = @import("config.zig");
const Renderer = @import("renderer.zig");
const Mem = @import("mem.zig");
const Phase = @import("phase.zig");

fn init_system() !*flecs.system_desc_t {
		const system = try Mem.create(flecs.system_desc_t);
		system.* = .{}; // Zero out the memory
		return system;
}

pub const OnInit = struct {
		pub fn init(world: *flecs.world_t) !*flecs.system_desc_t {
				var system = try init_system();
				system.callback = OnInit.run;
				system.interval = 0.0;

				_ = flecs.SYSTEM(world, "initialize", flecs.OnStart, system);

				return system;
		}

		fn run(it: *flecs.iter_t) callconv(.c) void {
				const renderer = flecs.singleton_get(it.world, Renderer.T).?;
				const config = flecs.singleton_get(it.world, Config.T).?;
				renderer.start(config);
		}
};

pub const OnTick = struct {
		const Ticker = struct {
				const Callback = *const fn(*flecs.iter_t) void;
				var ID: u64 = 0;

				id: u64,
				cb: Callback,
		};

		var tickers: std.ArrayList(Ticker) = .{};

		pub fn init(world: *flecs.world_t) !*flecs.system_desc_t {
				var system = try init_system();
				system.callback = OnTick.run;
				// system.interval = 0.015;
				system.interval = 1;

				_ = flecs.SYSTEM(world, "on_tick", Phase.OnTick, system);
				return system;
		}

		// This gets run after Phase.OnTick
		fn run(it: *flecs.iter_t) callconv(.c) void {
				for (tickers.items) |t| t.cb(it);
		}

		pub fn add(ticker: Ticker.Callback) !void {
				try tickers.append(Mem.allocator(), .{
						.id = Ticker.ID,
						.cb = ticker,
				});
				Ticker.ID += 1;
		}
};

pub const OnBeforeUpdate = struct {
		pub fn init(world: *flecs.world_t) !*flecs.system_desc_t {
				var system = try init_system();
				system.callback = OnBeforeUpdate.run;
				system.immediate = false;

				_ = flecs.SYSTEM(world, "before_update", flecs.PreUpdate, system);

				return system;
		}

		fn run(it: *flecs.iter_t) callconv(.c) void {
				const renderer = flecs.singleton_get(it.world, Renderer.T).?;

				if (renderer.should_window_close()) {
						flecs.quit(it.world);
				}
		}
};

pub const OnRender = struct {
		pub fn init(world: *flecs.world_t) !*flecs.system_desc_t {
				var system = try init_system();
				system.callback = OnRender.run;
				system.immediate = false;

				const config = flecs.singleton_get(world, Config.T).?;
				if (config.target_fps != 0) {
						system.interval = 1.0 / @as(f32, @floatFromInt(config.target_fps));
				}

				_ = flecs.SYSTEM(world, "on_render", flecs.PostUpdate, system);

				return system;
		}

		fn run(it: *flecs.iter_t) callconv(.c) void {
				const renderer = flecs.singleton_get(it.world, Renderer.T).?;

				renderer.begin_drawing();
				renderer.overlay() catch |e| {
						std.debug.print("WARNING: Failed to draw overlay: {}\n", .{ e });
				};
				defer renderer.end_drawing();
		}
};

pub const OnQuit = struct {
		pub fn run(world: *flecs.world_t) callconv(.c) void {
				const renderer = flecs.singleton_get(world, Renderer.T).?;
				renderer.end();
		}
};
