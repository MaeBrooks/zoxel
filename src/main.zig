const std = @import("std");
const rl = @import("raylib");
const ecs = @import("zflecs");

pub fn main() !void {
    const world = ecs.init();
    defer _ = ecs.fini(world);

    rl.initWindow(800, 450, "Vox");
    defer rl.closeWindow();

    _ = ecs.ADD_SYSTEM(world, "draw_text", ecs.OnStore, draw_text);

    while (true) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.getColor(0xFFAAFFFF));

        if (rl.windowShouldClose()) ecs.quit(world);
        if (!ecs.progress(world, 0.0)) break;
    }
}

fn draw_text(_: *ecs.iter_t) void {
    rl.drawText("Hai :3", 190, 200, 20, rl.getColor(0x000000FF));
}
