// Taken from
//https://github.com/JamzOJamz/pvz-bloomiverse/blob/a390ee4609e3641a12d8eb2cb3778fbb147c837c/src/game/Ticker.zig

const rl = @import("raylib");

const Self = @This();

fixed_dt: f64 = 1.0 / 60.0,
current_time: f64,
accumulator: f64 = 0,
fixedUpdate: *const fn () anyerror!void,
renderUpdate: *const fn (f32) void,
draw: *const fn (f32) anyerror!void,

/// Ticks the functions, fixedUpdate is called 1 / fixed_dt times per second.
pub fn step(self: *Self) !void {
    const new_time = rl.getTime();
    const frame_time = new_time - self.current_time;

    self.current_time = new_time;
    self.accumulator += frame_time;

    while (self.accumulator >= self.fixed_dt) {
        try self.fixedUpdate();
        self.accumulator -= self.fixed_dt;
    }

    // Calculate how far between "fixed steps" the current frame is
    const alpha: f32 = @floatCast(self.accumulator / self.fixed_dt);

    self.renderUpdate(alpha);
    try self.draw(alpha);
}
