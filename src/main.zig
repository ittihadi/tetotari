const game = @import("game.zig");

pub fn main() !void {
    // Run the game
    try game.init();
    defer game.deinit();

    try game.run();
}
