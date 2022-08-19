#load "src/Body.jai";
#load "src/Core.jai";
#load "src/Debug.jai";

#scope_module

#load "src/ContactListener.jai";
#load "src/Utilities.jai";

TrackedCollision :: struct {
    contact: *b2Contact;
    body_a: *b2Body;
    body_b: *b2Body;
    normal: Vector2;
}

world: *b2World;
world_scale: float = 100.0;
debug_draw: *b2Draw;
contact_listener: *b2ContactListener;

allocated_bodies: BlockAllocator(Body);
tracked_bodies: [..] *b2Body;
tracked_collisions: [..] TrackedCollision;

#import "JaiBox2DAuto";
#import "JaiMath";
#import "BlockAllocatorJai";
#import "Math";
#import "Basic";
