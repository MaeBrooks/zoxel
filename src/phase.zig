const flecs = @import("zflecs");

pub var OnTick: flecs.entity_t = undefined;

pub fn _init(world: *flecs.world_t) void {
		OnTick = flecs.new_w_id(world, flecs.Phase);
}
