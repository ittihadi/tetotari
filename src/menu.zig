const std = @import("std");
const rl = @import("raylib");

const assets = @import("assets.zig");

var alloc: std.mem.Allocator = undefined;

var songs: std.ArrayList(i32) = undefined;
var selected_song: u32 = 0;


pub fn init(allocator: std.mem.Allocator) !void {
    alloc = allocator;
    songs = .init(alloc);


    try reloadSongs();
}

pub fn deinit() void {
    songs.deinit();
}

pub fn fixedUpdate() !void {
    if (rl.isKeyPressed(.down) or rl.isKeyPressedRepeat(.down)) {
        selected_song +%= 1;
    } else if (rl.isKeyPressed(.up) or rl.isKeyPressedRepeat(.up)) {
        selected_song -%= 1;
    }

    if (rl.isKeyPressed(.enter) or rl.isKeyPressed(.space)) {
        // load selected level and enter
    }
}

pub fn renderUpdate(alpha: f32) void {
    _ = alpha;
}

pub fn draw(alpha: f32) !void {
    _ = alpha;

    // Layout draft:
    //     ic title
    //    ic title
    // ICON TITLE
    //      DESC + DETAIL
    //    ic title
    //     ic title
}

pub fn reloadSongs() !void {
    // Where to scan for songs?
    // maybe '/charts' relative to exe directory?

    // Clear current songs list

    if (!rl.directoryExists("charts")) {
        // TODO: Handle error value
        _ = rl.makeDirectory("charts");
        return;
    }

    const chart_paths = rl.loadDirectoryFilesEx("charts", "DIR", false);
    defer rl.unloadDirectoryFiles(chart_paths);

    if (chart_paths.count == 0) {
        std.log.debug("No charts found", .{});
        // skip all
        return;
    }

    for (0..chart_paths.count) |i| {
        std.log.debug("Chart folder found: {s}", .{chart_paths.paths[i]});
        // Do stuff
    }
}
