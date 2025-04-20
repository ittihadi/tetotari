///! Handles calling update and render functions as well as timing the next

// Taken from
// https://github.com/JamzOJamz/pvz-bloomiverse/blob/a390ee4609e3641a12d8eb2cb3778fbb147c837c/src/game/Ticker.zig
// Based on https://gafferongames.com/post/fix_your_timestep/

// Hacky modification to allow spreading updates when fps < tps

// TODO: Test when tick + render doesn't let the game run at full speed

const rl = @import("raylib");

const Self = @This();

fixed_dt: f64 = 1.0 / 120.0,
frame_dt: f64 = 1.0 / 120.0,
current_time: f64,
tick_accumulator: f64 = 0,
frame_accumulator: f64 = 0,
fixedUpdate: *const fn () anyerror!void,
renderUpdate: *const fn (f32) void,
draw: *const fn (f32) anyerror!void,

/// Ticks the functions, fixedUpdate is called 1 / fixed_dt times per second.
pub fn step(self: *Self) !void {
    const new_time = rl.getTime();
    const step_time = new_time - self.current_time;

    self.current_time = new_time;
    self.tick_accumulator += step_time;
    self.frame_accumulator += step_time;

    while (self.tick_accumulator >= self.fixed_dt) {
        try self.fixedUpdate();
        self.tick_accumulator -= self.fixed_dt;
    }

    // Calculate how far between "fixed steps" the current frame is
    const alpha: f32 = @floatCast(self.tick_accumulator / self.fixed_dt);

    if (self.frame_accumulator >= self.frame_dt) {
        self.renderUpdate(alpha);
        try self.draw(alpha);

        while (self.frame_accumulator >= self.frame_dt)
            self.frame_accumulator -= self.frame_dt;
    }
}

/// Waits for either the next update or draw scheduled
pub fn wait(self: *Self) !void {
    const time_to_next_tick = @max(0, self.fixed_dt - self.tick_accumulator);
    const time_to_next_draw = @max(0, self.frame_dt - self.frame_accumulator);
    const time_to_wait = @min(time_to_next_draw, time_to_next_tick);

    if (time_to_wait > 0.001)
        rl.waitTime(time_to_wait);
}
