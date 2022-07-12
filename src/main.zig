const std = @import("std");
const w4 = @import("wasm4.zig");

const board = @import("board.zig");
const utils = @import("utils.zig");
const Snake = @import("snake.zig").Snake;
const Point = @import("snake.zig").Point;

const fmt = std.fmt;

var snake: Snake = Snake.init();
var life: board.Life = board.Life.init();  // TODO: encapsulate into board
var fruit: Point = undefined;
var frame_count: u32 = 0;
var prev_state: u8 = 0;
var prng: std.rand.DefaultPrng = undefined;
var random: std.rand.Random = undefined;
var game_over: bool = false;
var lock_input: bool = false;
var snake_speed: u32 = 15;


export fn start() void {
    // Ice Cream
    w4.PALETTE.* = .{
        0xfff6d3,
        0xf9a875,
        0xeb6b6f,
        0x7c3f58,
    };

    utils.init_random();
    fruit = Point.init(utils.rnd(0, 20), utils.rnd(1, 20));
    board.score = 0;
}

fn proceed_input() void {
    const gamepad = w4.GAMEPAD1.*;
    const just_pressed = gamepad & (gamepad ^ prev_state);

    if (lock_input == false) {
        if (just_pressed & w4.BUTTON_UP != 0) {
            if (snake.is_up()) {
                snake_speed = 5;
            } else {
                snake.up();
                lock_input = true;
            }
        }

        if (just_pressed & w4.BUTTON_DOWN != 0) {
            if (snake.is_down()) {
                snake_speed = 5;
            } else {
                snake.down();
                lock_input = true;
            }
        }

        if (just_pressed & w4.BUTTON_LEFT != 0) {
            if (snake.is_left()) {
                snake_speed = 5;
            } else {
                snake.left();
                lock_input = true;
            }
        }

        if (just_pressed & w4.BUTTON_RIGHT != 0) {
            if (snake.is_right()) {
                snake_speed = 5;
            } else {
                snake.right();
                lock_input = true;
            }
        }
    }

    if (just_pressed & w4.BUTTON_1 != 0) {
        game_over = false;
        board.score = 0;
        frame_count = 0;
        snake = Snake.init();
        life.lifes_cnt = 3;
        snake_speed = 15;
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

    // Return back to normal speed in 3 sec
    if (frame_count % 180 == 0) snake_speed = 15;

    if (frame_count % snake_speed == 0 and game_over == false) {
        snake.update();
        lock_input = false;

        if (snake.idDead()) {
            life.lifes_cnt -= 1;
            if (life.lifes_cnt == 0) game_over = true;
        }

        if (snake.body.get(0).equals(fruit)) {
            const tail = snake.body.get(snake.body.len - 1);
            snake.body.append(Point.init(tail.x, tail.y)) catch @panic("can't grow the snake");
            w4.tone(20 | (60 << 16), 80, 20, w4.TONE_PULSE2 | w4.TONE_MODE3);
            board.score += 1;

            fruit.x = utils.rnd(0, 20);
            fruit.y = utils.rnd(1, 20);

            while (fruit.is_inside(snake)) {
                fruit.x = utils.rnd(0, 20);
                fruit.y = utils.rnd(1, 20);
            }
        }
    }

    snake.draw();
    board.draw_score();
    board.place_fruit(fruit);
    life.draw();
}
