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
get_scale :: () -> float;
set_scale :: (scale: float);
get_body_at_point :: (point: Vector2) -> *Body;
get_bodies_at_point :: (point: Vector2) -> [..] *Body;
get_body_at_line :: (line: Line2) -> *Body;
get_bodies_at_line :: (line: Line2) -> [..] *Body;
get_body_in_aabb :: (aabb: AABB2) -> *Body;
get_bodies_in_aabb :: (aabb: AABB2) -> [..] *Body;
step_physics :: (delta: float);
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
    position: Vector2;
    velocity: Vector2;
    rotation: float;
    rotational_velocity: float;
    enabled: bool;
    gravity_scale: float;
    linear_damping: float;
    angular_damping: float;
    fixed_rotation: bool;
    body_type: BodyType;
    self_collision_flags: u16;
    collision_flags: u16;
}

// TODO automatically toggle on/off is_bullet based on radius and speed
// TODO allow sensor polygons?

create_body :: (type: BodyType) -> *Body;
destroy_body :: (body: *Body);
add_polygon :: (body: *Body, polygon: [] Vector2, density: float = 1, friction: float = 0, restitution: float = 0);
remove_polygon :: (body: *Body, polygon: [] Vector2);
add_circle :: (body: *Body, center: Vector2, radius: float, density: float = 1, friction: float = 0, restitution: float = 0);
remove_circle :: (body: *Body, center: Vector2, radius: float);
get_world_center_of_mass :: (body: Body) -> Vector2;
get_local_center_of_mass :: (body: Body) -> Vector2;
apply_force :: (body: *Body, force: Vector2);
apply_force :: (body: *Body, force: Vector2, local_point: Vector2);
apply_linear_impulse :: (body: *Body, impulse: Vector2);
apply_linear_impulse :: (body: *Body, impulse: Vector2, local_point: Vector2);
apply_torque :: (body: *Body, torque: float);
apply_angular_impulse :: (body: *Body, impulse: float);
get_mass :: (body: Body) -> float;
get_linear_velocity_at_world_point :: (body: Body, world_point: Vector2) -> Vector2;
get_linear_velocity_at_local_point :: (body: Body, local_point: Vector2) -> Vector2;
get_world_point :: (body: Body, local_point: Vector2) -> Vector2;
get_local_point :: (body: Body, world_point: Vector2) -> Vector2;
get_world_vector :: (body: Body, local_vector: Vector2) -> Vector2;
get_local_vector :: (body: Body, world_vector: Vector2) -> Vector2;
get_collision_normals :: (body: Body) -> [..] Vector2;
get_collision_bodies :: (body: Body) -> [..] *Body;
distance_to_body :: (body: Body, point: Vector2) -> float;
nearest_point_on_body :: (body: Body, point: Vector2) -> Vector2;
apply_force_away_from_bodies :: (body: *Body, force: float); // ? implement
```

## Debug
```jai
set_draw_shapes :: (enabled: bool);
draw :: ();
```