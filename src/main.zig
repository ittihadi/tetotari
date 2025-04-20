// Screens:
// - Menu
// - Game

const std = @import("std");
const rl = @import("raylib");
const builtin = @import("builtin");

const assets = @import("assets.zig");
const Ticker = @import("Ticker.zig");

const stage = @import("stage.zig");
const menu = @import("menu.zig");

// Global state lol
pub var state: State = undefined;

pub fn main() !void {
    // Set global state
    state = .{
        .allocator = std.heap.page_allocator,
        .screen = .menu,
    };

    // Initialize raylib window
    rl.setConfigFlags(.{ .vsync_hint = false });

    rl.initWindow(640, 360, "Tetotari");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    _ = rl.changeDirectory(rl.getApplicationDirectory());

    try menu.init();
    defer menu.deinit();

    var ticker = Ticker{
        .current_time = rl.getTime(),
        .fixedUpdate = fixedUpdate,
        .renderUpdate = renderUpdate,
        .draw = draw,
    };

    // TODO: Maybe utilize separete input thread instead
    while (!rl.windowShouldClose()) {
        try ticker.step();
        try ticker.wait();
    }
}

pub fn fixedUpdate() !void {
    rl.pollInputEvents();

    // TODO: This thing
    // if (rl.isKeyPressed(.f11)) {
    //     std.log.info("Toggle fullscreen", .{});
    //     rl.toggleFullscreen();
    // }

    if (state.screen == .menu) {
        try menu.fixedUpdate();
    } else if (state.screen == .stage) {
        try stage.fixedUpdate();
    }
}

pub fn renderUpdate(alpha: f32) void {
    if (state.screen == .menu) {
        menu.renderUpdate(alpha);
    } else if (state.screen == .stage) {
        stage.renderUpdate(alpha);
    }
}

pub fn draw(alpha: f32) !void {
    rl.beginDrawing();

    rl.clearBackground(.black);

    if (state.screen == .menu) {
        try menu.draw(alpha);
    } else if (state.screen == .stage) {
        try stage.draw(alpha);
    }

    rl.endDrawing();
    rl.swapScreenBuffer();
}

const State = struct {
    allocator: std.mem.Allocator,
    screen: Screens,
};

// Move to file later I guess
const Screens = enum {
    menu,
    stage,
};
