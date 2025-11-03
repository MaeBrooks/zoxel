const flecs = @import("zflecs");

pub const Tick = struct {};

pub fn defaults(world: *flecs.world_t) void {
    register(world, Tick);
}

pub fn register(world: *flecs.world_t, comptime t: type) void {
    flecs.TAG(world, t);
}
