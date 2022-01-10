const std=@import("std");
const raylib=@cImport({@cInclude("raylib.h");});
const Vec2 = struct {
    x:i32=0, y:i32=0,
    fn squraredDistance(a:*Vec2, b: Vec2) i32{
        const x_diff=(a.*.x-b.x);
        const y_diff=(a.*.y-b.y);
        return x_diff*x_diff+y_diff*y_diff;
    }
    fn distance(a:*Vec2,b:Vec2) f32{
        return std.math.sqrt(@intToFloat(f32,squraredDistance(a,b)));
    }
};
const Circle = struct {
    position:Vec2,
    radius:f32
};

const CircleList = std.MultiArrayList(Circle);
pub fn main() !void {
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));
    var rng=std.rand.DefaultPrng.init(seed);
    const screenWidth = 800;
    const screenHeight = 450;
    var circle=Circle{.position=Vec2{.x=screenWidth/2,.y=screenHeight/2},.radius=5.0};
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator=gpa.allocator();
    var enemyList = CircleList{};
    defer enemyList.deinit(allocator);
    const maxRadius=20;
    
    var ending_waiting:f64=3;
    {
    var i:i32=0;
    while (i<10):(i+=1){
    try enemyList.append(allocator, .{
        .position=.{.x=rng.random().intRangeAtMost(i32,maxRadius,screenWidth-maxRadius),.y=rng.random().intRangeAtMost(i32,maxRadius,screenHeight-maxRadius)},
        .radius=@intToFloat(f32,rng.random().uintAtMost(u32,maxRadius))
    });
    }
    }
    
    raylib.InitWindow(screenWidth, screenHeight, "Rising Circle");
    raylib.SetTargetFPS(60);
    while (!raylib.WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        const mousePosition=raylib.GetMousePosition();
        circle.position.x=@floatToInt(i32,mousePosition.x);
        circle.position.y=@floatToInt(i32,mousePosition.y);
        {
            const enemySlice=enemyList.slice();
            const enemyPositions=enemySlice.items(.position);
            const enemyRadii=enemySlice.items(.radius);
            var i:usize=enemyList.len-%1;
            //utilize overflow
            while(i<std.math.maxInt(usize)):(i-%=1){
                const enemyPosition=enemyPositions[i];
                const enemyRadius=enemyRadii[i];
                if(circle.position.distance(enemyPosition)<circle.radius-enemyRadius)
                {
                    circle.radius+=enemyRadius;
                    enemyList.swapRemove(i);
                }
            }
        }
        const isGameEnd=enemyList.len<=0;
        if (isGameEnd)
        {
            if(ending_waiting<=0){
                break;
            }
            ending_waiting-=raylib.GetFrameTime();
        }

        // Draw
        //----------------------------------------------------------------------------------
        raylib.BeginDrawing();
            {
            raylib.ClearBackground(raylib.RAYWHITE);
            const message=if(isGameEnd) "Congrats! You cleared the board!" else "Eat'em all!";
            raylib.DrawText(message, 190, 200, 20, raylib.LIGHTGRAY);
            const mouseString:[:0]u8=try std.fmt.allocPrintZ(allocator,"x:{d} y:{d}",.{@floatToInt(i32,mousePosition.x),@floatToInt(i32,mousePosition.y)});
            defer allocator.free(mouseString);
            raylib.DrawText(mouseString.ptr, 200, 220, 20, raylib.LIGHTGRAY);
            const enemySlice=enemyList.slice();
            const enemyPositions=enemySlice.items(.position);
            const enemyRadii=enemySlice.items(.radius);
            for (enemyPositions) |position, i|{
                raylib.DrawCircle(position.x,position.y,enemyRadii[i],raylib.RED);
            }
            raylib.DrawCircle(circle.position.x,circle.position.y,circle.radius,raylib.GREEN);
            }

        raylib.EndDrawing();
        //----------------------------------------------------------------------------------
    }
    raylib.CloseWindow();  
}
