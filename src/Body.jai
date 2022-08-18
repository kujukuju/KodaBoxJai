BodyType :: enum {
    Static;
    Kinematic;
    Dynamic;
}

Body :: struct {
    data: *b2Body;
}

create_body :: (type: BodyType) -> Body {
    assert(world, "You must initialize the library before doing anything.");

    body_def := BodyDef_create();
    if type == #complete {
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
    body.data = World_create_body(*body_def);
}

destroy_body :: (body: *Body) {
    World_destroy_body(body.data);
}

add_polygon :: (body: *Body, polygon: [] Vector2, density: float = 1, friction: float = 0, restitution: float = 0) {
    valid_polygons := get_valid_polygons(polygon);
    defer array_free(valid_polygons);

    for valid_polygon: valid_polygons {
        fixture_def := FixtureDef_create();
        fixture_def.density = density;
        fixture_def.friction = friction;
        fixture_def.restitution = restitution;

        polygon_shape := PolygonShape_create();
        PolygonShape_set(*polygon_shape, valid_polygon.vertices.data, valid_polygon.count);
        fixture_def.shape = *polygon_shape;

        Body_create_fixture(body.data, *fixture_def);
    }
}

remove_polygon :: (body: *Body, poylgon: [] Vector2) {
    valid_polygons := get_valid_polygons(polygon);
    defer array_free(valid_polygons);

    removed_list := NewArray(valid_polygons.count, bool);
    defer array_free(removed_list);

    fixture := Body_get_fixture_list();
    while fixture != null {
        shape := Fixture_get_shape(fixture);
        if !shape {
            continue;
        }
        if shape.m_type != .e_polygon {
            continue;
        }

        polygon_shape := cast(*b2PolygonShape) shape;
        print("checking vertices %\n", polygon_shape.m_vertices);
        for i: 0..valid_polygons.count - 1 {
            if removed_list[i] {
                continue;
            }

            if valid_polygons[i].vertices == polygon_shape.m_vertices {
                Body_destroy_fixture(body.data, fixture);
                removed_list[i] = true;

                // check if were done
                if !contains(removed_list, false) {
                    return;
                }
            }
        }

        fixture = Fixture_get_next(fixture);
    }

    if contains(removed_list, false) {
        print("Unable to remove all requested polygons.\n%\n%\n", removed_list, valid_polygons);
    }
}

add_circle :: (body: *Body, center: Vector2, radius: float, density: float = 1, friction: float = 0, restitution: float = 0) {
    assert(false, "Circles are not yet supported.");
}

remove_circle :: (body: *Body, center: Vector2, radius: float) {
    assert(false, "Circles are not yet supported.");
}

get_position :: (body: Body) -> Vector2 {
    return << Body_get_position(body.data);
}

set_position :: (body: *Body, position: Vector2) {
    Body_set_transform(body.data, *position, Body_get_angle(body));
}

get_velocity :: (body: Body) -> Vector2 {
    return << Body_get_linear_velocity(body.data);
}

set_velocity :: (body: *Body, velocity: Vector2) {
    Body_set_linear_velocity(body.data, *velocity);
}

get_rotation :: (body: Body) -> float {
    return Body_get_angle(body.data);
}

set_rotation :: (body: *Body, rotation: float) {
    Body_set_transform(body.data, Body_get_position(body), rotation);
}

get_rotational_velocity :: (body: Body) -> float {
    return Body_get_angular_velocity(body.data);
}

set_rotational_velocity :: (body: *Body, rotational_velocity: float) {
    Body_set_angular_velocity(body.data, rotational_velocity);
}

get_world_center_of_mass :: (body: Body) -> Vector2 {
    return << Body_get_world_center(body.data);
}

get_local_center_of_mass :: (body: Body) -> Vector2 {
    return << Body_get_local_center(body.data);
}

apply_force :: (body: *Body, force: Vector2) {
    Body_apply_force_to_center(body.data, *force, true);
}

apply_force :: (body: *Body, force: Vector2, local_point: Vector2) {
    Body_apply_force(body.data, *force, *local_point, true);
}

apply_linear_impulse :: (body: *Body, impulse: Vector2) {
    Body_apply_linear_impulse_to_center(body.data, *impulse, true);
}

apply_linear_impulse :: (body: *Body, impulse: Vector2, local_point: Vector2) {
    Body_apply_linear_impulse(body.data, *impulse, *local_point, true);
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
    Body_set_fixed_rotation(body, fixed);
}

get_body_type :: (body: Body) -> BodyType {
    type := Body_get_type(body.data);
    if type == #complete {
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
    if type == #complete {
        case .Static;
            type = .b2_staticBody;
        case .Kinematic;
            type = .b2_kinematicBody;
        case .Dynamic;
            type = .b2_dynamicBody;
    }

    Body_set_type(body, type);
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
    return Body_get_linear_velocity_from_world_point(body.data, *world_point);
}

get_linear_velocity_at_local_point :: (body: Body, local_point: Vector2) -> Vector2 {
    return Body_get_linear_velocity_from_local_point(body.data, *local_point);
}

get_world_point :: (body: Body, local_point: Vector2) -> Vector2 {
    return Body_get_world_point(body.data, *local_point);
}

get_local_point :: (body: Body, world_point: Vector2) -> Vector2 {
    return Body_get_local_point(body.data, *world_point);
}

get_world_vector :: (body: Body, local_vector: Vector2) -> Vector2 {
    return Body_get_world_vector(body.data, *local_vector);
}

get_local_vector :: (body: Body, world_vector: Vector2) -> Vector2 {
    return Body_get_local_vector(body.data, *world_vector);
}
