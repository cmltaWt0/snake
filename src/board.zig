const std = @import("std");
const w4 = @import("wasm4.zig");

const Point = @import("snake.zig").Point;

const fmt = std.fmt;

// fruit
const fruit_width = 8;
const fruit_height = 8;
const fruit_flags = 1; // BLIT_2BPP
const fruit_sprite = [16]u8{ 0x00, 0xa0, 0x02, 0x00, 0x0e, 0xf0, 0x36, 0x5c, 0xd6, 0x57, 0xd5, 0x57, 0x35, 0x5c, 0x0f, 0xf0 };


const heart_full = [8]u8{
    0b00000000,
    0b01101100,
    0b11111110,
    0b11111110,
    0b11111110,
    0b01111100,
    0b00111000,
    0b00000000,
};
// To change life loss into empty heart
const heart_empty = [8]u8{
    0b00000000,
    0b01100110,
    0b01011010,
    0b10000001,
    0b10000001,
    0b01000010,
    0b00100010,
    0b00011000,
};


pub const Life = struct {
    lifes: std.BoundedArray(Point, 3),
    lifes_cnt: u8,

    pub fn init() @This() {
        return @This() {
            .lifes = std.BoundedArray(Point, 3).fromSlice(&.{
                Point.init(17, 0),
                Point.init(18, 0),
                Point.init(19, 0),
            }) catch @panic("couldn't init life indicator"),
            .lifes_cnt = 3,

        };
    }

    pub fn restart(this: @This()) void {
        this.lifes_cnt = 3;
    }

    pub fn draw(this: @This()) void {
        w4.DRAW_COLORS.* = 0x0040;

        for(this.lifes.constSlice()) |life, i| {
            if (i < this.lifes_cnt) {
                w4.blit(&heart_full, life.x * 8, life.y * 8, 8, 8, w4.BLIT_1BPP);
            }
        }
    }
};

pub var score: u8 = undefined;

pub fn draw_score() void {
    const score_prefix: []const u8 = "Score:";
    var score_: [10]u8 = undefined;
    const score_slice = score_[0..];
    const together = fmt.bufPrint(
        score_slice, "{s}{d}", .{ score_prefix, score }) catch @panic("can't convert score");
    
    w4.DRAW_COLORS.* = 0x0002;
    w4.text(together, 1, 1);
}


pub fn place_fruit(fruit: Point) void {
    w4.DRAW_COLORS.* = 0x4320;
    w4.blit(&fruit_sprite, fruit.x * 8, fruit.y * 8, 8, 8, w4.BLIT_2BPP);
}
