const flecs = @import("zflecs");

const CONFIG_ENTITY_NAME = "CONFIG";

pub const T = struct {
    target_fps: i32 = 120,
};

pub fn fps() f32 {
    return 0.0;
    // return 1.0 / @as(f32, @floatFromInt(120));
}
