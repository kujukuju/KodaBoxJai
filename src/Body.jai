BodyType :: enum {
    Static;
    Kinematic;
    Dynamic;
}

Body :: struct {
    data: *b2Body;
    position: Vector2;
    dirty_position_: Vector2;
    velocity: Vector2;
    dirty_velocity_: Vector2;
    rotation: float;
    dirty_rotation_: float;
    rotational_velocity: float;
    dirty_rotational_velocity_: float;
    enabled: bool;
    dirty_enabled_: bool;
    gravity_scale: float;
    dirty_gravity_scale_: float;
    linear_damping: float;
    dirty_linear_damping_: float;
    angular_damping: float;
    dirty_angular_damping_: float;
    fixed_rotation: bool;
    dirty_fixed_rotation_: bool;
    body_type: BodyType;
    dirty_body_type_: BodyType;
    self_collision_flags: u16;
    dirty_self_collision_flags_: u16;
    collision_flags: u16;
    dirty_collision_flags_: u16;
}

operator == :: (a: Body, b: Body) -> bool {
    return a.data == b.data;
}

create_body :: (type: BodyType) -> *Body {
    assert(!!world, "You must initialize the library before doing anything.");

    body_def: b2BodyDef;
    b2BodyDef.Constructor(*body_def);
    if #complete type == {
        case .Static;
            body_def.type = .staticBody;
        case .Kinematic;
            body_def.type = .kinematicBody;
        case .Dynamic;
            body_def.type = .dynamicBody;
    }
    body_def.linearDamping = 0;
    body_def.angularDamping = 0;

    body: *Body = claim(*allocated_bodies);
    body.data = b2World.CreateBody(world, *body_def);
    body.enabled = true;
    body.dirty_enabled_ = true;
    body.gravity_scale = 1.0;
    body.dirty_gravity_scale_ = 1.0;
    body.body_type = type;
    body.dirty_body_type_ = type;
    body.self_collision_flags = 0x0001;
    body.dirty_self_collision_flags_ = 0x0001;
    body.collision_flags = 0xffff;
    body.dirty_collision_flags_ = 0xffff;

    array_add(*tracked_bodies, body.data);

    return body;
}

destroy_body :: (body: *Body) {
    array_ordered_remove_by_value(*tracked_bodies, body.data);

    b2World.DestroyBody(world, body.data);
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
        fixture_def: b2FixtureDef;
        b2FixtureDef.Constructor(*fixture_def);
        fixture_def.density = density;
        fixture_def.friction = friction;
        fixture_def.restitution = restitution;
        filter: b2Filter;
        b2Filter.Constructor(*filter);
        filter.categoryBits = body.self_collision_flags;
        filter.maskBits = body.collision_flags;
        fixture_def.filter = filter;

        polygon_shape: b2PolygonShape;
        b2PolygonShape.Constructor(*polygon_shape);
        b2PolygonShape.Set(*polygon_shape, valid_polygon.vertices.data, xx valid_polygon.count);
        fixture_def.shape = *polygon_shape;

        b2Body.CreateFixture(body.data, *fixture_def);
    }
}

remove_polygon :: (body: *Body, polygon: [] Vector2) {
    valid_polygons := get_valid_polygons(polygon);
    defer array_free(valid_polygons);

    // box2d sometimes reverses the vertices in my polygons when I set the shape, and sometimes shifts the order offsets
    // so I'm just going to duplicate it and then check
    for *valid_polygon: valid_polygons {
        polygon_shape: b2PolygonShape;
        b2PolygonShape.Constructor(*polygon_shape);
        b2PolygonShape.Set(*polygon_shape, valid_polygon.vertices.data, xx valid_polygon.count);
        valid_polygon.vertices = polygon_shape.m_vertices;

        for *vertex: valid_polygon.vertices {
            << vertex /= world_scale;
        }
    }

    removed_list := NewArray(valid_polygons.count, bool);
    defer array_free(removed_list);

    fixture := b2Body.GetFixtureList(body.data);
    while fixture != null {
        defer fixture = b2Fixture.GetNext(fixture);

        shape := b2Fixture.GetShape(fixture);
        if !shape {
            continue;
        }
        if shape.m_type != .polygon {
            continue;
        }

        polygon_shape := cast(*b2PolygonShape) shape;
        fixed_vertices := fixed_polygon(polygon_shape.m_vertices, polygon_shape.m_count);
        for i: 0..valid_polygons.count - 1 {
            if removed_list[i] {
                continue;
            }

            if valid_polygons[i] == fixed_vertices {
                b2Body.DestroyFixture(body.data, fixture);
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
    fixture_def: b2FixtureDef;
    b2FixtureDef.Constructor(*fixture_def);
    fixture_def.density = density;
    fixture_def.friction = friction;
    fixture_def.restitution = restitution;
    filter: b2Filter;
    b2Filter.Constructor(*filter);
    filter.categoryBits = body.self_collision_flags;
    filter.maskBits = body.collision_flags;
    fixture_def.filter = filter;

    circle_shape: b2CircleShape;
    b2CircleShape.Constructor(*circle_shape);
    circle_shape.m_radius = radius / world_scale;
    circle_shape.m_p = center / world_scale;

    fixture_def.shape = *circle_shape;

    b2Body.CreateFixture(body.data, *fixture_def);
}

remove_circle :: (body: *Body, center: Vector2, radius: float) {
    new_center := center / world_scale;
    new_radius := radius / world_scale;

    fixture := b2Body.GetFixtureList(body.data);
    while fixture != null {
        defer fixture = b2Fixture.GetNext(fixture);

        shape := b2Fixture.GetShape(fixture);
        if !shape {
            continue;
        }
        if shape.m_type != .circle {
            continue;
        }

        circle_shape := cast(*b2CircleShape) shape;
        if circle_shape.m_p == new_center && circle_shape.m_radius == new_radius {
            b2Body.DestroyFixture(body.data, fixture);
            return;
        }
    }

    print("Unable to remove requested circle.\n% %\n", center, radius);
}

get_world_center_of_mass :: (body: Body) -> Vector2 {
    position := << b2Body.GetWorldCenter(body.data);
    return position * world_scale;
}

get_local_center_of_mass :: (body: Body) -> Vector2 {
    position := << b2Body.GetLocalCenter(body.data);
    return position * world_scale;
}

apply_force :: (body: *Body, force: Vector2) {
    new := force / world_scale;
    b2Body.ApplyForceToCenter(body.data, *new, true);
}

apply_force :: (body: *Body, force: Vector2, local_point: Vector2) {
    new_force := force / world_scale;
    new_point := local_point / world_scale;
    b2Body.ApplyForce(body.data, *new_force, *new_point, true);
}

apply_linear_impulse :: (body: *Body, impulse: Vector2) {
    new := impulse / world_scale;
    b2Body.ApplyLinearImpulseToCenter(body.data, *new, true);
}

apply_linear_impulse :: (body: *Body, impulse: Vector2, local_point: Vector2) {
    new_impulse := impulse / world_scale;
    new_point := local_point / world_scale;
    b2Body.ApplyLinearImpulse(body.data, *new_impulse, *new_point, true);
}

apply_torque :: (body: *Body, torque: float) {
    b2Body.ApplyTorque(body.data, torque, true);
}

apply_angular_impulse :: (body: *Body, impulse: float) {
    b2Body.ApplyAngularImpulse(body.data, impulse, true);
}

get_mass :: (body: Body) -> float {
    return b2Body.GetMass(body.data);
}

get_linear_velocity_at_world_point :: (body: Body, world_point: Vector2) -> Vector2 {
    return b2Body.GetLinearVelocityFromWorldPoint(body.data, *world_point) * world_scale;
}

get_linear_velocity_at_local_point :: (body: Body, local_point: Vector2) -> Vector2 {
    return b2Body.GetLinearVelocityFromLocalPoint(body.data, *local_point) * world_scale;
}

get_world_point :: (body: Body, local_point: Vector2) -> Vector2 {
    new := local_point / world_scale;
    return b2Body.GetWorldPoint(body.data, *new) * world_scale;
}

get_local_point :: (body: Body, world_point: Vector2) -> Vector2 {
    new := world_point / world_scale;
    return b2Body.GetLocalPoint(body.data, *new) * world_scale;
}

get_world_vector :: (body: Body, local_vector: Vector2) -> Vector2 {
    new := local_vector / world_scale;
    return b2Body.GetWorldVector(body.data, *new) * world_scale;
}

get_local_vector :: (body: Body, world_vector: Vector2) -> Vector2 {
    new := world_vector / world_scale;
    return b2Body.GetLocalVector(body.data, *new) * world_scale;
}

get_collision_normals :: (body: Body) -> [..] Vector2 {
    normals: [..] Vector2;
    for collision: tracked_collisions {
        if collision.body_a == body.data {
            array_add(*normals, -collision.normal);
        } else if collision.body_b == body.data {
            array_add(*normals, collision.normal);
        }
    }

    return normals;
}

get_collision_bodies :: (body: Body) -> [..] Body {
    bodies: [..] Body;
    for collision: tracked_collisions {
        if collision.body_a == body.data {
            body: Body;
            body.data = collision.body_b;

            array_add(*bodies, body);
        } else if collision.body_b == body.data {
            body: Body;
            body.data = collision.body_a;

            array_add(*bodies, body);
        }
    }

    return bodies;
}

#scope_module

update_dirty :: (using body: *Body) {
    if position != dirty_position_ || rotation != dirty_rotation_ {
        set_transform(body, position, rotation);
        set_awake(body, true);
        dirty_position_ = position;
        dirty_rotation_ = rotation;
    }
    if velocity != dirty_velocity_ {
        set_velocity(body, velocity);
        dirty_velocity_ = velocity;
    }
    if rotational_velocity != dirty_rotational_velocity_ {
        set_rotational_velocity(body, rotational_velocity);
        dirty_rotational_velocity_ = rotational_velocity;
    }
    if enabled != dirty_enabled_ {
        set_enabled(body, enabled);
        dirty_enabled_ = enabled;
    }
    if gravity_scale != dirty_gravity_scale_ {
        set_gravity_scale(body, gravity_scale);
        dirty_gravity_scale_ = gravity_scale;
    }
    if linear_damping != dirty_linear_damping_ {
        set_linear_damping(body, linear_damping);
        dirty_linear_damping_ = linear_damping;
    }
    if angular_damping != dirty_angular_damping_ {
        set_angular_damping(body, angular_damping);
        dirty_angular_damping_ = angular_damping;
    }
    if fixed_rotation != dirty_fixed_rotation_ {
        set_fixed_rotation(body, fixed_rotation);
        dirty_fixed_rotation_ = fixed_rotation;
    }
    if body_type != dirty_body_type_ {
        set_body_type(body, body_type);
        dirty_body_type_ = body_type;
    }
    if self_collision_flags != dirty_self_collision_flags_ || collision_flags != dirty_collision_flags_ {
        set_collision_flags(body, self_collision_flags, collision_flags);
        dirty_self_collision_flags_ = self_collision_flags;
        dirty_collision_flags_ = collision_flags;
    }
}

update_values :: (using body: *Body) {
    // static bodies cant update without updating their values
    if body_type == .Static {
        return;
    }

    position = get_position(<< body);
    dirty_position_ = position;
    velocity = get_velocity(<< body);
    dirty_velocity_ = velocity;
    rotation = get_rotation(<< body);
    dirty_rotation_ = rotation;
    rotational_velocity = get_rotational_velocity(<< body);
    dirty_rotational_velocity_ = rotational_velocity;
}

#scope_file

get_position :: (body: Body) -> Vector2 {
    position := << b2Body.GetPosition(body.data);
    return position * world_scale;
}

set_position :: (body: *Body, position: Vector2) {
    new := position / world_scale;
    b2Body.SetTransform(body.data, *new, b2Body.GetAngle(body.data));
}

get_velocity :: (body: Body) -> Vector2 {
    velocity := << b2Body.GetLinearVelocity(body.data);
    return velocity * world_scale;
}

set_velocity :: (body: *Body, velocity: Vector2) {
    new := velocity / world_scale;
    b2Body.SetLinearVelocity(body.data, *new);
}

get_rotation :: (body: Body) -> float {
    return b2Body.GetAngle(body.data);
}

set_rotation :: (body: *Body, rotation: float) {
    b2Body.SetTransform(body.data, Body_get_position(body.data), rotation);
}

get_rotational_velocity :: (body: Body) -> float {
    return b2Body.GetAngularVelocity(body.data);
}

set_transform :: (body: *Body, position: Vector2, rotation: float) {
    new := position / world_scale;
    b2Body.SetTransform(body.data, *new, rotation);
}

set_awake :: (body: *Body, awake: bool) {
    b2Body.SetAwake(body.data, awake);
}

set_rotational_velocity :: (body: *Body, rotational_velocity: float) {
    b2Body.SetAngularVelocity(body.data, rotational_velocity);
}

// get_world_center_of_mass :: (body: Body) -> Vector2 {
//     position := << b2Body.GetWorldCenter(body.data);
//     return position * world_scale;
// }

// get_local_center_of_mass :: (body: Body) -> Vector2 {
//     position := << b2Body.GetLocalCenter(body.data);
//     return position * world_scale;
// }

// apply_force :: (body: *Body, force: Vector2) {
//     new := force / world_scale;
//     b2Body.ApplyForceToCenter(body.data, *new, true);
// }

// apply_force :: (body: *Body, force: Vector2, local_point: Vector2) {
//     new_force := force / world_scale;
//     new_point := local_point / world_scale;
//     b2Body.ApplyForce(body.data, *new_force, *new_point, true);
// }

// apply_linear_impulse :: (body: *Body, impulse: Vector2) {
//     new := impulse / world_scale;
//     b2Body.ApplyLinearImpulseToCenter(body.data, *new, true);
// }

// apply_linear_impulse :: (body: *Body, impulse: Vector2, local_point: Vector2) {
//     new_impulse := impulse / world_scale;
//     new_point := local_point / world_scale;
//     b2Body.ApplyLinearImpulse(body.data, *new_impulse, *new_point, true);
// }

// apply_torque :: (body: *Body, torque: float) {
//     b2Body.ApplyTorque(body.data, torque, true);
// }

// apply_angular_impulse :: (body: *Body, impulse: float) {
//     b2Body.ApplyAngularImpulse(body.data, impulse, true);
// }

// get_mass :: (body: Body) -> float {
//     return b2Body.GetMass(body.data);
// }

get_enabled :: (body: Body) -> bool {
    return b2Body.IsEnabled(body.data);
}

set_enabled :: (body: *Body, enabled: bool) {
    b2Body.SetEnabled(body.data, enabled);
}

get_gravity_scale :: (body: Body) -> float {
    return b2Body.GetGravityScale(body.data);
}

set_gravity_scale :: (body: *Body, scale: float) {
    b2Body.SetGravityScale(body.data, scale);
}

get_linear_damping :: (body: Body) -> float {
    return b2Body.GetLinearDamping(body.data);
}

set_linear_damping :: (body: *Body, damping: float) {
    b2Body.SetLinearDamping(body.data, damping);
}

get_angular_damping :: (body: Body) -> float {
    return b2Body.GetAngularDamping(body.data);
}

set_angular_damping :: (body: *Body, damping: float) {
    b2Body.SetAngularDamping(body.data, damping);
}

get_fixed_rotation :: (body: Body) -> bool {
    return b2Body.IsFixedRotation(body.data);
}

set_fixed_rotation :: (body: *Body, fixed: bool) {
    b2Body.SetFixedRotation(body.data, fixed);
}

get_body_type :: (body: Body) -> BodyType {
    b2type := b2Body.GetType(body.data);
    if #complete b2type == {
        case .staticBody;
            return .Static;
        case .kinematicBody;
            return .Kinematic;
        case .dynamicBody;
            return .Dynamic;
    }
}

set_body_type :: (body: *Body, type: BodyType) {
    b2type: b2BodyType;
    if #complete type == {
        case .Static;
            b2type = .staticBody;
        case .Kinematic;
            b2type = .kinematicBody;
        case .Dynamic;
            b2type = .dynamicBody;
    }

    b2Body.SetType(body.data, b2type);
}

set_collision_flags :: (body: *Body, self_collision_flags: u16, collision_flags: u16) {
    fixture := b2Body.GetFixtureList(body.data);
    while fixture != null {
        defer fixture = b2Fixture.GetNext(fixture);

        filter: b2Filter;
        b2Filter.Constructor(*filter);
        filter.categoryBits = self_collision_flags;
        filter.maskBits = collision_flags;

        b2Fixture.SetFilterData(fixture, filter);
    }
}

// get_linear_velocity_at_world_point :: (body: Body, world_point: Vector2) -> Vector2 {
//     return b2Body.GetLinearVelocityFromWorldPoint(body.data, *world_point) * world_scale;
// }

// get_linear_velocity_at_local_point :: (body: Body, local_point: Vector2) -> Vector2 {
//     return b2Body.GetLinearVelocityFromLocalPoint(body.data, *local_point) * world_scale;
// }

// get_world_point :: (body: Body, local_point: Vector2) -> Vector2 {
//     new := local_point / world_scale;
//     return b2Body.GetWorldPoint(body.data, *new) * world_scale;
// }

// get_local_point :: (body: Body, world_point: Vector2) -> Vector2 {
//     new := world_point / world_scale;
//     return b2Body.GetLocalPoint(body.data, *new) * world_scale;
// }

// get_world_vector :: (body: Body, local_vector: Vector2) -> Vector2 {
//     new := local_vector / world_scale;
//     return b2Body.GetWorldVector(body.data, *new) * world_scale;
// }

// get_local_vector :: (body: Body, world_vector: Vector2) -> Vector2 {
//     new := world_vector / world_scale;
//     return b2Body.GetLocalVector(body.data, *new) * world_scale;
// }

#scope_export
