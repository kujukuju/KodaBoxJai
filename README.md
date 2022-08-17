## Setup
Just `#import "KodaBoxJai";`. 

## Core
```jai
FixedPolygon :: struct (Size: int) {
    vertices: [Size] Vector2;
    count: int;
}

initialize :: ();
get_gravity :: () -> Vector2;
set_gravity :: (gravity: Vector2);
```

## Physics
```jai
BodyType :: enum {
    Static;
    Kinematic;
    Dynamic;
}
Body :: struct {
    data: *b2Body;
}

create_body :: (type: BodyType) -> Body; // implement
destroy_body :: (body: *Body); // implement
add_polygon :: (body: *Body, polygon: [] Vector2); // implement
add_polygon :: (body: *Body, polygon: [] Vector2, density: float = 1, friction: float = 0, restitution: float = 0); // implement
remove_polygon :: (body: *Body, poylgon: [] Vector2); // implement
add_circle :: (body: *Body, center: Vector2, radius: float); // implement
add_circle :: (body: *Body, center: Vector2, radius: float, density: float = 1, friction: float = 0, restitution: float = 0); // implement
remove_circle :: (body: *Body, center: Vector2, radius: float); // implement
get_position :: (body: Body) -> Vector2; // implement
set_position :: (body: *Body, position: Vector2); // implement
get_velocity :: (body: Body) -> Vector2; // implement
set_velocity :: (body: *Body, velocity: Vector2);
get_rotation :: (body: Body) -> float; // implement
set_rotation :: (body: *Body, rotation: float); // implement
get_rotational_velocity :: (body: Body) -> float; // implement
set_rotational_velocity :: (body: *Body, rotational_velocity: float); // implement
get_local_center_of_mass :: (body: Body) -> Vector2; // implement
apply_force :: (body: *Body, force: Vector2); // implement
apply_force :: (body: *Body, force: Vector2, local_point: Vector2); // implement
apply_linear_impulse :: (body: *Body, impulse: Vector2); // implement
apply_linear_impulse :: (body: *Body, impulse: Vector2, local_point: Vector2); // implement
apply_torque :: (body: *Body, torque: float); // implement
apply_angular_impulse :: (body: *Body, impulse: float); // implement
get_mass :: (body: Body) -> float; // implement
get_enabled :: (body: Body) -> bool; // implement
set_enabled :: (body: *Body, enabled: bool); // implement
get_gravity_scale :: (body: Body) -> float; // implement
set_gravity_scale :: (body: *Body, scale: float); // implement
get_linear_damping :: (body: Body) -> float; // implement
set_linear_damping :: (body: *Body, damping: float); // implement
get_angular_damping :: (body: Body) -> float; // implement
set_angular_damping :: (body: *Body, damping: float); // implement
get_collision_normals :: (body: Body) -> [] Vector2; // implement
get_collision_flags :: (body: Body) -> u64; // implement
set_collision_flags :: (body: *Body, flags: u64); // implement
get_world_point :: (body: Body, local_point: Vector2) -> Vector2; // implement
get_local_point :: (body: Body, world_point: Vector2) -> Vector2; // implement
get_world_vector :: (body: Body, local_vector: Vector2) -> Vector2; // implement
get_local_vector :: (body: Body, world_vector: Vector2) -> Vector2; // implement
// TODO automatically toggle on/off is_bullet based on radius and speed
```
