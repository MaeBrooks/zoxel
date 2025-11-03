const flecs = @import("zflecs");

const Config = @import("config.zig");
const Renderer = @import("renderer.zig");

pub fn defaults(world: *flecs.world_t) void {
    register(world, Config.T);
}

pub fn register(world: *flecs.world_t, comptime t: type) void {
    flecs.COMPONENT(world, t);
}
