const std = @import("std");
const rl = @import("raylib");

const menu = @import("menu.zig");
const stage = @import("stage.zig");
const editor = @import("editor.zig");

const assets = @import("assets.zig");

const Ticker = @import("Ticker.zig");

const Screens = enum {
    menu,
    stage,
    editor,
};

var allocator: std.mem.Allocator = undefined;
var screen: Screens = .menu;

pub fn init() !void {
    allocator = std.heap.page_allocator;
    try assets.init(allocator);
}

pub fn deinit() void {
    menu.deinit();

    assets.deinit();
    rl.closeAudioDevice();
    rl.closeWindow();
}

pub fn run() !void {
    // Initialize raylib window
    rl.setConfigFlags(.{ .vsync_hint = false });
    rl.initWindow(640, 360, "Tetotari");
    rl.initAudioDevice();

    _ = rl.changeDirectory(rl.getApplicationDirectory());

    // This needs to be moved later, or have raylib change the directory
    // before initialization
    try menu.init(allocator);

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

    switch (screen) {
        .menu => try menu.fixedUpdate(),
        .stage => try stage.fixedUpdate(),
        .editor => {},
    }
}

pub fn renderUpdate(alpha: f32) void {
    switch (screen) {
        .menu => menu.renderUpdate(alpha),
        .stage => stage.renderUpdate(alpha),
        .editor => {},
    }
}

pub fn draw(alpha: f32) !void {
    rl.beginDrawing();

    rl.clearBackground(.black);

    switch (screen) {
        .menu => try menu.draw(alpha),
        .stage => try stage.draw(alpha),
        .editor => {},
    }

    rl.endDrawing();
    rl.swapScreenBuffer();
}
