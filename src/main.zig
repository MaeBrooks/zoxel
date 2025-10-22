const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(800, 450, "Vox");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.getColor(0xFFAAFFFF));
        rl.drawText("Hai :3", 190, 200, 20, rl.getColor(0x000000FF));
    }
}
