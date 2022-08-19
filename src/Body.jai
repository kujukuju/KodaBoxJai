BodyType :: enum {
    Static;
    Kinematic;
    Dynamic;
}

Body :: struct {
    data: *b2Body;
}

create_body :: (type: BodyType) -> Body {
    assert(!!world, "You must initialize the library before doing anything.");

    body_def := BodyDef_create();
    if #complete type == {
        case .Static;
            body_def.type = .b2_staticBody;
        case .Kinematic;
            body_def.type = .b2_kinematicBody;
        case .Dynamic;
            body_def.type = .b2_dynamicBody;
    }
    body_def.linearDamping = 0;
    body_def.angularDamping = 0;

    body: Body;
    body.data = World_create_body(world, *body_def);

    return body;
}

destroy_body :: (body: *Body) {
    World_destroy_body(world, body.data);
}

add_polygon :: (body: *Body, polygon: [] Vector2, density: float = 1, friction: float = 0, restitution: float = 0) {
    valid_polygons := get_valid_polygons(polygon);
    defer array_free(valid_polygons);

    for *valid_polygon: valid_polygons {
        for *vertex: valid_polygon.vertices {
            << vertex /= world_scale;
        }
    }

    for valid_polygon: valid_polygons {
        fixture_def := FixtureDef_create();
        fixture_def.density = density;
        fixture_def.friction = friction;
        fixture_def.restitution = restitution;

        polygon_shape := PolygonShape_create();
        PolygonShape_set(*polygon_shape, valid_polygon.vertices.data, xx valid_polygon.count);
        fixture_def.shape = *polygon_shape;

        Body_create_fixture(body.data, *fixture_def);
    }
}

remove_polygon :: (body: *Body, polygon: [] Vector2) {
    valid_polygons := get_valid_polygons(polygon);
    defer array_free(valid_polygons);

    // box2d sometimes reverses the vertices in my polygons when I set the shape, and sometimes shifts the order offsets
    // so I'm just going to duplicate it and then check
    for *valid_polygon: valid_polygons {
        polygon_shape := PolygonShape_create();
        PolygonShape_set(*polygon_shape, valid_polygon.vertices.data, xx valid_polygon.count);
        valid_polygon.vertices = polygon_shape.m_vertices;

        for *vertex: valid_polygon.vertices {
            << vertex /= world_scale;
        }
    }

    removed_list := NewArray(valid_polygons.count, bool);
    defer array_free(removed_list);

    fixture := Body_get_fixture_list(body.data);
    while fixture != null {
        defer fixture = Fixture_get_next(fixture);

        shape := Fixture_get_shape(fixture);
        if !shape {
            continue;
        }
        if shape.m_type != .e_polygon {
            continue;
        }

        polygon_shape := cast(*b2PolygonShape) shape;
        fixed_vertices := fixed_polygon(polygon_shape.m_vertices, polygon_shape.m_count);
        for i: 0..valid_polygons.count - 1 {
            if removed_list[i] {
                continue;
            }

            if valid_polygons[i] == fixed_vertices {
                Body_destroy_fixture(body.data, fixture);
                removed_list[i] = true;

                // check if were done
                if !contains(removed_list, false) {
                    return;
                }
            }
        }
    }

    print("Unable to remove all requested polygons.\n%\n%\n", removed_list, valid_polygons);
}

add_circle :: (body: *Body, center: Vector2, radius: float, density: float = 1, friction: float = 0, restitution: float = 0) {
    fixture_def := FixtureDef_create();
    fixture_def.density = density;
    fixture_def.friction = friction;
    fixture_def.restitution = restitution;

    circle_shape := CircleShape_create();
    circle_shape.m_radius = radius / world_scale;
    circle_shape.m_p = center / world_scale;

    fixture_def.shape = *circle_shape;

    Body_create_fixture(body.data, *fixture_def);
}

remove_circle :: (body: *Body, center: Vector2, radius: float) {
    new_center := center / world_scale;
    new_radius := radius / world_scale;

    fixture := Body_get_fixture_list(body.data);
    while fixture != null {
        defer fixture = Fixture_get_next(fixture);

        shape := Fixture_get_shape(fixture);
        if !shape {
            continue;
        }
        if shape.m_type != .e_circle {
            continue;
        }

        circle_shape := cast(*b2CircleShape) shape;
        if circle_shape.m_p == new_center && circle_shape.m_radius == new_radius {
            Body_destroy_fixture(body.data, fixture);
            return;
        }
    }

    print("Unable to remove requested circle.\n% %\n", center, radius);
}

get_position :: (body: Body) -> Vector2 {
    position := << Body_get_position(body.data);
    return position * world_scale;
}

set_position :: (body: *Body, position: Vector2) {
    new := position / world_scale;
    Body_set_transform(body.data, *new, Body_get_angle(body.data));
}

get_velocity :: (body: Body) -> Vector2 {
    velocity := << Body_get_linear_velocity(body.data);
    return velocity * world_scale;
}

set_velocity :: (body: *Body, velocity: Vector2) {
    new := velocity / world_scale;
    Body_set_linear_velocity(body.data, *new);
}

get_rotation :: (body: Body) -> float {
    return Body_get_angle(body.data);
}

set_rotation :: (body: *Body, rotation: float) {
    Body_set_transform(body.data, Body_get_position(body.data), rotation);
}

get_rotational_velocity :: (body: Body) -> float {
    return Body_get_angular_velocity(body.data);
}

set_rotational_velocity :: (body: *Body, rotational_velocity: float) {
    Body_set_angular_velocity(body.data, rotational_velocity);
}

get_world_center_of_mass :: (body: Body) -> Vector2 {
    position := << Body_get_world_center(body.data);
    return position * world_scale;
}

get_local_center_of_mass :: (body: Body) -> Vector2 {
    position := << Body_get_local_center(body.data);
    return position * world_scale;
}

apply_force :: (body: *Body, force: Vector2) {
    new := force / world_scale;
    Body_apply_force_to_center(body.data, *new, true);
}

apply_force :: (body: *Body, force: Vector2, local_point: Vector2) {
    new_force := force / world_scale;
    new_point := local_point / world_scale;
    Body_apply_force(body.data, *new_force, *new_point, true);
}

apply_linear_impulse :: (body: *Body, impulse: Vector2) {
    new := impulse / world_scale;
    Body_apply_linear_impulse_to_center(body.data, *new, true);
}

apply_linear_impulse :: (body: *Body, impulse: Vector2, local_point: Vector2) {
    new_impulse := impulse / world_scale;
    new_point := local_point / world_scale;
    Body_apply_linear_impulse(body.data, *new_impulse, *new_point, true);
}

apply_torque :: (body: *Body, torque: float) {
    Body_apply_torque(body.data, torque, true);
}

apply_angular_impulse :: (body: *Body, impulse: float) {
    Body_apply_angular_impulse(body.data, impulse, true);
}

get_mass :: (body: Body) -> float {
    return Body_get_mass(body.data);
}

get_enabled :: (body: Body) -> bool {
    return Body_is_enabled(body.data);
}

set_enabled :: (body: *Body, enabled: bool) {
    Body_set_enabled(body.data, enabled);
}

get_gravity_scale :: (body: Body) -> float {
    return Body_get_gravity_scale(body.data);
}

set_gravity_scale :: (body: *Body, scale: float) {
    Body_set_gravity_scale(body.data, scale);
}

get_linear_damping :: (body: Body) -> float {
    return Body_get_linear_damping(body.data);
}

set_linear_damping :: (body: *Body, damping: float) {
    Body_set_linear_damping(body.data, damping);
}

get_angular_damping :: (body: Body) -> float {
    return Body_get_angular_damping(body.data);
}

set_angular_damping :: (body: *Body, damping: float) {
    Body_set_angular_damping(body.data, damping);
}

get_fixed_rotation :: (body: Body) -> bool {
    return Body_is_fixed_rotation(body.data);
}

set_fixed_rotation :: (body: *Body, fixed: bool) {
    Body_set_fixed_rotation(body.data, fixed);
}

get_body_type :: (body: Body) -> BodyType {
    type := Body_get_type(body.data);
    if #complete type == {
        case .b2_staticBody;
            return .Static;
        case .b2_kinematicBody;
            return .Kinematic;
        case .b2_dynamicBody;
            return .Dynamic;
    }
}

set_body_type :: (body: *Body, type: BodyType) {
    type: b2BodyType;
    if #complete type == {
        case .Static;
            type = .b2_staticBody;
        case .Kinematic;
            type = .b2_kinematicBody;
        case .Dynamic;
            type = .b2_dynamicBody;
    }

    Body_set_type(body.data, type);
}

get_collision_flags :: (body: Body) -> u64 {

}

set_collision_flags :: (body: *Body, flags: u64) {

}

get_collision_normals :: (body: Body) -> [] Vector2 {

}

get_collision_bodies :: (body: Body) -> [] *Body {

}

get_linear_velocity_at_world_point :: (body: Body, world_point: Vector2) -> Vector2 {
    return Body_get_linear_velocity_from_world_point(body.data, *world_point) * world_scale;
}

get_linear_velocity_at_local_point :: (body: Body, local_point: Vector2) -> Vector2 {
    return Body_get_linear_velocity_from_local_point(body.data, *local_point) * world_scale;
}

get_world_point :: (body: Body, local_point: Vector2) -> Vector2 {
    new := local_point / world_scale;
    return Body_get_world_point(body.data, *new) * world_scale;
}

get_local_point :: (body: Body, world_point: Vector2) -> Vector2 {
    new := world_point / world_scale;
    return Body_get_local_point(body.data, *new) * world_scale;
}

get_world_vector :: (body: Body, local_vector: Vector2) -> Vector2 {
    new := local_vector / world_scale;
    return Body_get_world_vector(body.data, *new) * world_scale;
}

get_local_vector :: (body: Body, world_vector: Vector2) -> Vector2 {
    new := world_vector / world_scale;
    return Body_get_local_vector(body.data, *new) * world_scale;
}
