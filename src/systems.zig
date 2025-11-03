const std = @import("std");
const flecs = @import("zflecs");

const Config = @import("config.zig");
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

    fn run(_: *flecs.iter_t) callconv(.c) void {}
};

pub const OnTick = struct {
    const Ticker = struct {
        const Callback = *const fn (*flecs.iter_t) void;
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

    fn run(_: *flecs.iter_t) callconv(.c) void {}
};

pub const OnQuit = struct {
    pub fn run(_: *flecs.world_t) callconv(.c) void {}
};
