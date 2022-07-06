const std = @import("std");
const w4 = @import("wasm4.zig");

const board = @import("board.zig");
const utils = @import("utils.zig");
const Snake = @import("snake.zig").Snake;
const Point = @import("snake.zig").Point;

const fmt = std.fmt;

var snake: Snake = Snake.init();
var fruit: Point = undefined;
var frame_count: u32 = 0;
var prev_state: u8 = 0;
var prng: std.rand.DefaultPrng = undefined;
var random: std.rand.Random = undefined;
var game_over: bool = false;


export fn start() void {
    // Ice Cream
    w4.PALETTE.* = .{
        0xfff6d3,
        0xf9a875,
        0xeb6b6f,
        0x7c3f58,
    };

    utils.init_random();
    fruit = Point.init(utils.rnd(20), utils.rnd(20));
    board.score = 0;
}

fn proceed_input() void {
    const gamepad = w4.GAMEPAD1.*;
    const just_pressed = gamepad & (gamepad ^ prev_state);

    if (just_pressed & w4.BUTTON_UP != 0) {
        snake.up();
    }

    if (just_pressed & w4.BUTTON_DOWN != 0) {
        snake.down();
    }

    if (just_pressed & w4.BUTTON_LEFT != 0) {
        snake.left();
    }

    if (just_pressed & w4.BUTTON_RIGHT != 0) {
        snake.right();
    }

    if (just_pressed & w4.BUTTON_1 != 0) {
        game_over = false;
        board.score = 0;
        frame_count = 0;
        snake = Snake.init();
    }

    prev_state = gamepad;
}

export fn update() void {
    frame_count += 1;

    proceed_input();

    if (game_over) {
        w4.DRAW_COLORS.* = 0x0002;
        w4.text("Press X to restart", 1 * 8, 10 * 8);
    }

    if (frame_count % 15 == 0 and game_over == false) {
        snake.update();

        if (snake.idDead()) {
            game_over = true;
        }

        if (snake.body.get(0).equals(fruit)) {
            const tail = snake.body.get(snake.body.len - 1);
            snake.body.append(Point.init(tail.x, tail.y)) catch @panic("can't grow the snake");
            w4.tone(20 | (60 << 16), 80, 10, w4.TONE_PULSE2 | w4.TONE_MODE3);
            board.score += 1;
            fruit.x = utils.rnd(20);
            fruit.y = utils.rnd(20);
        }
    }

    snake.draw();
    board.draw_score();
    board.place_fruit(fruit);
}
