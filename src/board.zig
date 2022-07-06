const std = @import("std");
const w4 = @import("wasm4.zig");

const Point = @import("snake.zig").Point;

const fmt = std.fmt;

// fruit
const fruit_width = 8;
const fruit_height = 8;
const fruit_flags = 1; // BLIT_2BPP
const fruit_sprite = [16]u8{ 0x00, 0xa0, 0x02, 0x00, 0x0e, 0xf0, 0x36, 0x5c, 0xd6, 0x57, 0xd5, 0x57, 0x35, 0x5c, 0x0f, 0xf0 };


pub var score: u8 = undefined;

pub fn draw_score() void {
    const score_prefix: []const u8 = "Score:";
    var score_: [10]u8 = undefined;
    const score_slice = score_[0..];
    const together = fmt.bufPrint(score_slice, "{s}{d}", .{ score_prefix, score }) catch @panic("can't convert score");
    
    w4.DRAW_COLORS.* = 0x0002;
    w4.text(together, 1, 1);
}


pub fn place_fruit(fruit: Point) void {
    w4.DRAW_COLORS.* = 0x4320;
    w4.blit(&fruit_sprite, fruit.x * 8, fruit.y * 8, 8, 8, w4.BLIT_2BPP);
}
