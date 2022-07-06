const std = @import("std");

var prng: std.rand.DefaultPrng = undefined;
var random: std.rand.Random = undefined;


pub fn init_random() void {
    prng = std.rand.DefaultPrng.init(0);
    random = prng.random();
}


pub fn rnd(max: i32) i32 {
    return random.intRangeLessThan(i32, 0, max);
}
