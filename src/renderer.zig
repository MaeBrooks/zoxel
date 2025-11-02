const std = @import("std");

const flecs = @import("zflecs");
const rl = @import("raylib");

const Config = @import("config.zig");

pub const RenderResult = enum {
    success,
    failure,
};

// TODO:
// Make ecs system have entity Sun
// Cause sun to move its position on update
// Voxels will be stored OUTSIDE the ecs system
// But
// terrian = [0, 0, 0, 1, 1, 0, 1]
// where 0 is air
// Each voxel CAN have an entity, but thats as an attribute like, 100% water (source), 80% water, fire, health, etc
// By default they should be basically bit masks
// Static (block type id), air (0) should be the item marked
// Where water is just an attribute placed inside an air block
pub const T = struct {
    flush_color: rl.Color,

    pub fn end(_: *const T) void {
        rl.closeWindow();
    }

		pub fn begin_drawing(self: *const T) void {
				rl.beginDrawing();
				rl.clearBackground(self.flush_color);
		}

		pub fn overlay(_: *const T) !void {
				var buf: [9]u8 = undefined;
				const str = try std.fmt.bufPrintZ(&buf, "{}", .{ rl.getFPS() });

				const x = @divFloor(rl.getScreenWidth(), 2);
				const y = @divFloor(rl.getScreenHeight(), 2);
				rl.drawText(str, x, y, 16, rl.getColor(0xFFFFFFFF));
		}

		pub fn end_drawing(_: *const T) void {
				rl.endDrawing();
		}

		pub fn start(_: *const T, _: *const Config.T) void {
				rl.initWindow(800, 450, "Vox");
		}

		pub fn should_window_close(_: T) bool {
				return rl.windowShouldClose();
		}
};

pub fn init() T {
		return .{
				.flush_color = rl.getColor(0xFFAAFFFF),
		};
}
