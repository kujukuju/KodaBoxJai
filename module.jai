#load "src/Body.jai";
#load "src/Core.jai";
#load "src/Debug.jai";

#scope_module

#load "src/Utilities.jai";

world: *b2World;
world_scale: float = 100.0;
debug_draw: *b2Draw;

#import "JaiBox2DAuto";
#import "JaiMath";
#import "Math";
#import "Basic";
