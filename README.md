## Setup
Just `#import "KodaBoxJai";`. 

## Core
```jai
FixedPolygon :: struct (size: int) {
    vertices: [size] Vector2;
    count: int;
}

koda_box_init :: ();
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

// TODO allow sensor polygons?

create_body :: (type: BodyType) -> Body;
destroy_body :: (body: *Body);
add_polygon :: (body: *Body, polygon: [] Vector2);
add_polygon :: (body: *Body, polygon: [] Vector2, density: float = 1, friction: float = 0, restitution: float = 0);
remove_polygon :: (body: *Body, poylgon: [] Vector2);
add_circle :: (body: *Body, center: Vector2, radius: float); // implement
add_circle :: (body: *Body, center: Vector2, radius: float, density: float = 1, friction: float = 0, restitution: float = 0); // implement
remove_circle :: (body: *Body, center: Vector2, radius: float); // implement
get_position :: (body: Body) -> Vector2;
set_position :: (body: *Body, position: Vector2);
get_velocity :: (body: Body) -> Vector2;
set_velocity :: (body: *Body, velocity: Vector2);
get_rotation :: (body: Body) -> float;
set_rotation :: (body: *Body, rotation: float);
get_rotational_velocity :: (body: Body) -> float;
set_rotational_velocity :: (body: *Body, rotational_velocity: float);
get_world_center_of_mass :: (body: Body) -> Vector2;
get_local_center_of_mass :: (body: Body) -> Vector2;
apply_force :: (body: *Body, force: Vector2);
apply_force :: (body: *Body, force: Vector2, local_point: Vector2);
apply_linear_impulse :: (body: *Body, impulse: Vector2);
apply_linear_impulse :: (body: *Body, impulse: Vector2, local_point: Vector2);
apply_torque :: (body: *Body, torque: float);
apply_angular_impulse :: (body: *Body, impulse: float);
get_mass :: (body: Body) -> float;
get_enabled :: (body: Body) -> bool;
set_enabled :: (body: *Body, enabled: bool);
get_gravity_scale :: (body: Body) -> float;
set_gravity_scale :: (body: *Body, scale: float);
get_linear_damping :: (body: Body) -> float;
set_linear_damping :: (body: *Body, damping: float);
get_angular_damping :: (body: Body) -> float;
set_angular_damping :: (body: *Body, damping: float);
get_fixed_rotation :: (body: Body) -> bool;
set_fixed_rotation :: (body: *Body, fixed: bool);
get_body_type :: (body: Body) -> BodyType;
set_body_type :: (body: *Body, type: BodyType);
get_collision_flags :: (body: Body) -> u64;
set_collision_flags :: (body: *Body, flags: u64);
get_collision_normals :: (body: Body) -> [] Vector2; // implement
get_collision_bodies :: (body: Body) -> [] *Body; // implement
get_linear_velocity_at_world_point :: (body: Body, world_point: Vector2) -> Vector2;
get_linear_velocity_at_local_point :: (body: Body, local_point: Vector2) -> Vector2;
get_world_point :: (body: Body, local_point: Vector2) -> Vector2;
get_local_point :: (body: Body, world_point: Vector2) -> Vector2;
get_world_vector :: (body: Body, local_vector: Vector2) -> Vector2;
get_local_vector :: (body: Body, world_vector: Vector2) -> Vector2;
// TODO automatically toggle on/off is_bullet based on radius and speed
```

## Debug
```jai
set_draw_shapes :: (enabled: bool);
draw :: ();
```