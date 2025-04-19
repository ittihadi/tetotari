const rl = @import("raylib");
const Texture = rl.Texture;
const Sound = rl.Sound;
const Music = rl.Music;
const std = @import("std");

var textures: std.StringHashMap(Texture) = undefined;
var sound: std.StringHashMap(Sound) = undefined;
var music: std.StringHashMap(Music) = undefined;

/// Initializes asset loader
pub fn init(allocator: std.mem.Allocator) !void {
    textures = std.StringHashMap(Texture).init(allocator);
    sound = std.StringHashMap(Sound).init(allocator);
    music = std.StringHashMap(Music).init(allocator);
}

pub fn deinit() void {
    var it_tex = textures.iterator();
    var it_snd = sound.iterator();
    var it_msc = music.iterator();

    while (it_tex.next()) |entry| {
        textures.allocator.free(entry.key_ptr.*);
        entry.value_ptr.*.unload();
    }

    while (it_snd.next()) |entry| {
        sound.allocator.free(entry.key_ptr.*);
        rl.unloadSound(entry.value_ptr.*);
    }

    while (it_msc.next()) |entry| {
        music.allocator.free(entry.key_ptr.*);
        rl.unloadMusicStream(entry.value_ptr.*);
    }

    textures.deinit();
    sound.deinit();
    music.deinit();
}

pub fn getTexture(path: []const u8) !Texture {
    _ = path;
}

pub fn getSound(path: []const u8) !Sound {
    _ = path;
}

pub fn getMusic(path: []const u8) !Music {
    _ = path;
}

pub fn unloadTexture(path: []const u8) void {
    _ = path;
}

pub fn unloadSound(path: []const u8) void {
    _ = path;
}

pub fn unloadMusic(path: []const u8) void {
    _ = path;
}
// etc
