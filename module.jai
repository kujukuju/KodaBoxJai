#load "src/Body.jai";
#load "src/Core.jai";
#load "src/Debug.jai";

#scope_module

#load "src/ContactListener.jai";
#load "src/Utilities.jai";

TrackedCollision :: struct {
    contact: *b2Contact;
    body_a: *Body;
    body_b: *Body;
    normal: Vector2;
}

world: *b2World;
world_scale: float = 100.0;
debug_draw: *b2Draw;
contact_listener: *b2ContactListener;

allocated_bodies: BlockAllocator(Body, 1024);
tracked_bodies: [..] *Body;
tracked_collisions: [..] TrackedCollision;

get_body_from_physics_body :: (physics_body: *b2Body) -> *Body {
    for *body: allocated_bodies {
        if body.data == physics_body {
            return body;
        }
    }

    return null;
}

#import "JaiBox2D";
#import "JaiMath";
#import "BlockAllocatorJai";
#import "Math";
#import "Basic";
