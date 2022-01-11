const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});
const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,
    fn squraredDistance(a: *Vec2, b: Vec2) i32 {
        const x_diff = (a.*.x - b.x);
        const y_diff = (a.*.y - b.y);
        return x_diff * x_diff + y_diff * y_diff;
    }
    fn distance(a: *Vec2, b: Vec2) f32 {
        return std.math.sqrt(@intToFloat(f32, squraredDistance(a, b)));
    }
};
const Circle = struct { position: Vec2, radius: f32 };
const Enemy = struct { shape: Circle, velocity: Vec2 };

const EnemyList = std.MultiArrayList(Enemy);
pub fn main() !void {
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));
    var rng = std.rand.DefaultPrng.init(seed);
    const screen_width = 800;
    const screen_height = 450;
    var circle = Circle{ .position = Vec2{ .x = screen_width / 2, .y = screen_height / 2 }, .radius = 5.0 };
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var enemy_list = EnemyList{};
    defer enemy_list.deinit(allocator);
    const max_radius = 20;
    const min_radius = 3;
    var deafeted = false;
    var start_waiting: f64 = 2;
    var ending_waiting: f64 = 3;
    {
        var i: i32 = 0;
        const number_of_enemies = screen_height / 2 / max_radius;
        var y_at_least: i32 = max_radius;
        var y_at_most: i32 = @minimum(screen_height - max_radius, y_at_least + 2 * max_radius);
        while (i < number_of_enemies) : (i += 1) {
            const x = rng.random().intRangeAtMost(i32, max_radius, screen_width - max_radius);
            const y = rng.random().intRangeAtMost(i32, y_at_least, y_at_most);
            const radius = rng.random().intRangeAtMost(i32, min_radius, min_radius * (i + 1)); // Ensures at least one enemy
            try enemy_list.append(allocator, .{ .shape = .{ .position = .{ .x = x, .y = y }, .radius = @intToFloat(f32, radius) }, .velocity = .{ .x = if (x < screen_width / 2) @divTrunc(max_radius, radius) else @divTrunc(-max_radius, radius), .y = 0 } });
            y_at_least = y + radius;
            y_at_most = @minimum(screen_height - max_radius, y_at_least + 2 * max_radius);
        }
    }

    raylib.InitWindow(screen_width, screen_height, "Rising Circle");
    raylib.SetTargetFPS(60);
    while (!raylib.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        // Player logics
        const mouse_position: Vec2 = .{ .x = raylib.GetMouseX(), .y = raylib.GetMouseY() };
        circle.position = mouse_position;
        {
            const enemy_slice = enemy_list.slice();
            const enemy_shapes = enemy_slice.items(.shape);
            var i: usize = enemy_list.len -% 1;
            //utilize overflow
            while (i < std.math.maxInt(usize)) : (i -%= 1) {
                const enemy_circle = enemy_shapes[i];
                const distance = circle.position.distance(enemy_circle.position);
                if (distance < circle.radius and circle.radius > enemy_circle.radius) {
                    circle.radius += min_radius;
                    enemy_list.swapRemove(i);
                } else if (distance < enemy_circle.radius and enemy_circle.radius > circle.radius) {
                    deafeted = true;
                    break;
                }
            }
        }
        // Check game ending condition and update
        const is_game_end = enemy_list.len <= 0 or deafeted;
        if (is_game_end) {
            if (ending_waiting <= 0) {
                break; // Break game loop
            }
            ending_waiting -= raylib.GetFrameTime();
        }

        //Enemy movement
        if (start_waiting <= 0) {
            const enemy_shapes = enemy_list.items(.shape);
            const enemy_velocities = enemy_list.items(.velocity);
            for (enemy_shapes) |*enemy_circle, i| {
                enemy_circle.*.position.x += enemy_velocities[i].x;
                if (enemy_circle.*.position.x < 0) {
                    enemy_circle.*.position.x = screen_width;
                } else if (enemy_circle.*.position.x > screen_width) {
                    enemy_circle.*.position.x = 0;
                }
                enemy_circle.*.position.y += enemy_velocities[i].y;
                if (enemy_circle.*.position.y < 0) {
                    enemy_circle.*.position.y = screen_height;
                } else if (enemy_circle.*.position.y > screen_height) {
                    enemy_circle.*.position.y = 0;
                }
            }
        } else {
            start_waiting -= raylib.GetFrameTime();
        }

        // Draw
        //----------------------------------------------------------------------------------
        raylib.BeginDrawing();
        {
            raylib.ClearBackground(raylib.RAYWHITE);
            const message = msg: {
                if (start_waiting > 0) {
                    break :msg "Prepare for the battle!";
                } else if (is_game_end) {
                    if (deafeted) {
                        break :msg "You've been eaten!";
                    } else {
                        break :msg "Congrats! You cleared the board!";
                    }
                } else {
                    break :msg "Eat'em all!";
                }
            };
            raylib.DrawText(message, 190, 200, 20, raylib.LIGHTGRAY);
            const mouse_string: [:0]u8 = try std.fmt.allocPrintZ(allocator, "x:{d} y:{d}", .{ mouse_position.x, mouse_position.y });
            defer allocator.free(mouse_string);
            raylib.DrawText(mouse_string.ptr, 200, 220, 20, raylib.LIGHTGRAY);
            const enemy_shapes = enemy_list.items(.shape);
            for (enemy_shapes) |enemy_circle| {
                raylib.DrawCircle(enemy_circle.position.x, enemy_circle.position.y, enemy_circle.radius, raylib.RED);
            }
            if (!deafeted) {
                raylib.DrawCircle(circle.position.x, circle.position.y, circle.radius, raylib.GREEN);
            }
        }

        raylib.EndDrawing();
        //----------------------------------------------------------------------------------
    }
    raylib.CloseWindow();
}
