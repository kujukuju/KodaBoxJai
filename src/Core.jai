koda_box_init :: () {
    if world {
        // destroy the world
        assert(false, "We don't yet support this.");
    }

    world = New(b2World);
    b2World.Constructor(world, Vector2.{0, 0});

    create_contact_listener();
}

get_gravity :: () -> Vector2 {
    return b2World.GetGravity(world);
}

set_gravity :: (gravity: Vector2) {
    b2World.SetGravity(world, gravity);
}

get_scale :: () -> float {
    return world_scale;
}

set_scale :: (scale: float) {
    world_scale = scale;
}

get_body_potentially_at_point :: (point: Vector2) -> *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            callback := cast(*QueryCallback) this;
            callback.body = get_body_from_physics_body(fixture.m_body);

            return false;
        }
    };

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        body: *Body;
    }
    callback: QueryCallback;
    callback.vtable = *vtable;

    aabb: b2AABB;
    aabb.lowerBound = point / world_scale;
    aabb.upperBound = point / world_scale;

    b2World.QueryAABB(world, *callback, *aabb);

    return callback.body;
}

get_bodies_potentially_at_point :: (point: Vector2) -> [..] *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            callback := cast(*QueryCallback) this;
            array_add(*callback.bodies, get_body_from_physics_body(fixture.m_body));

            return true;
        }
    };

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        bodies: [..] *Body;
    }
    callback: QueryCallback;
    callback.vtable = *vtable;

    aabb: b2AABB;
    aabb.lowerBound = point / world_scale;
    aabb.upperBound = point / world_scale;

    b2World.QueryAABB(world, *callback, *aabb);

    return callback.bodies;
}

get_body_at_point :: (point: Vector2) -> *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            callback := cast(*QueryCallback) this;
            if b2Fixture.TestPoint(fixture, *callback.point) {
                callback.body = get_body_from_physics_body(fixture.m_body);
                return false;
            }

            return true;
        }
    };

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        point: Vector2;
        body: *Body;
    }
    callback: QueryCallback;
    callback.point = point / world_scale;
    callback.vtable = *vtable;

    aabb: b2AABB;
    aabb.lowerBound = point / world_scale;
    aabb.upperBound = point / world_scale;

    b2World.QueryAABB(world, *callback, *aabb);

    return callback.body;
}

get_bodies_at_point :: (point: Vector2) -> [..] *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            callback := cast(*QueryCallback) this;
            if b2Fixture.TestPoint(fixture, *callback.point) {
                array_add(*callback.bodies, get_body_from_physics_body(fixture.m_body));
            }

            return true;
        }
    };

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        point: Vector2;
        bodies: [..] *Body;
    }
    callback: QueryCallback;
    callback.point = point / world_scale;
    callback.vtable = *vtable;

    aabb: b2AABB;
    aabb.lowerBound = point / world_scale;
    aabb.upperBound = point / world_scale;

    b2World.QueryAABB(world, *callback, *aabb);

    return callback.bodies;
}

get_body_at_line :: (line: Line2) -> *Body {
    if distance(line.p1, line.p2) == 0 {
        return get_body_at_point(line.p1);
    }

    vtable: b2RayCastCallback_VTable;
    vtable.ReportFixture = (this: *b2RayCastCallback, fixture: *b2Fixture, point: *b2Vec2, normal: *b2Vec2, fraction: float) -> float #cpp_method {
        new_context: Context;
        push_context new_context {
            if fraction <= 1 {
                callback := cast(*RayCastCallback) this;
                callback.body = get_body_from_physics_body(fixture.m_body);
                return 0;
            }
            assert(fraction >= 0, "The fraction shouldn't ever be less than 0.");

            return 1;
        }
    };

    RayCastCallback :: struct {
        using #as callback: b2RayCastCallback;
        body: *Body;
    }
    callback: RayCastCallback;
    callback.vtable = *vtable;

    p1 := line.p1 / world_scale;
    p2 := line.p2 / world_scale;

    b2World.RayCast(world, *callback, *p1, *p2);

    return callback.body;
}

get_bodies_at_line :: (line: Line2) -> [..] *Body {
    if distance(line.p1, line.p2) == 0 {
        return get_bodies_at_point(line.p1);
    }

    vtable: b2RayCastCallback_VTable;
    vtable.ReportFixture = (this: *b2RayCastCallback, fixture: *b2Fixture, point: *b2Vec2, normal: *b2Vec2, fraction: float) -> float #cpp_method {
        new_context: Context;
        push_context new_context {
            if fraction <= 1 {
                callback := cast(*RayCastCallback) this;
                array_add(*callback.bodies, get_body_from_physics_body(fixture.m_body));
            }
            assert(fraction >= 0, "The fraction shouldn't ever be less than 0.");

            return 1;
        }
    };

    RayCastCallback :: struct {
        using #as callback: b2RayCastCallback;
        bodies: [..] *Body;
    }
    callback: RayCastCallback;
    callback.vtable = *vtable;

    p1 := line.p1 / world_scale;
    p2 := line.p2 / world_scale;

    b2World.RayCast(world, *callback, *p1, *p2);

    return callback.bodies;
}

get_body_potentially_in_aabb :: (aabb: AABB2) -> *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            callback := cast(*QueryCallback) this;
            callback.body = get_body_from_physics_body(fixture.m_body);

            return false;
        }
    };

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        body: *Body;
    }
    callback: QueryCallback;
    callback.vtable = *vtable;

    b2aabb: b2AABB;
    b2aabb.lowerBound = aabb.lower / world_scale;
    b2aabb.upperBound = aabb.upper / world_scale;

    b2World.QueryAABB(world, *callback, *b2aabb);

    return callback.body;
}

get_bodies_potentially_in_aabb :: (aabb: AABB2) -> [..] *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            callback := cast(*QueryCallback) this;
            array_add(*callback.bodies, get_body_from_physics_body(fixture.m_body));

            return true;
        }
    };

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        bodies: [..] *Body;
    }
    callback: QueryCallback;
    callback.vtable = *vtable;

    b2aabb: b2AABB;
    b2aabb.lowerBound = aabb.lower / world_scale;
    b2aabb.upperBound = aabb.upper / world_scale;

    b2World.QueryAABB(world, *callback, *b2aabb);

    return callback.bodies;
}

get_body_in_aabb :: (aabb: AABB2) -> *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            if !fixture.m_shape {
                return true;
            }

            fixture_transform := b2Body.GetTransform(fixture.m_body);

            callback := cast(*QueryCallback) this;
            shape := callback.shape;
            transform := callback.transform;
            if b2TestOverlap(shape, 0, fixture.m_shape, 0, transform, fixture_transform) {
                callback.body = get_body_from_physics_body(fixture.m_body);

                return false;
            }

            return true;
        }
    };

    delta := aabb.upper / world_scale - aabb.lower / world_scale;
    center := aabb.lower / world_scale + delta / 2;

    box_shape: b2PolygonShape;
    b2PolygonShape.Constructor(*box_shape);
    b2PolygonShape.SetAsBox(*box_shape, delta.x / 2, delta.y / 2);

    transform: b2Transform;
    b2Transform.Set(*transform, *center, 0);

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        shape: *b2PolygonShape;
        transform: *b2Transform;
        body: *Body;
    }
    callback: QueryCallback;
    callback.shape = *box_shape;
    callback.transform = *transform;
    callback.vtable = *vtable;

    b2aabb: b2AABB;
    b2aabb.lowerBound = aabb.lower / world_scale;
    b2aabb.upperBound = aabb.upper / world_scale;

    b2World.QueryAABB(world, *callback, *b2aabb);

    return callback.body;
}

get_bodies_in_aabb :: (aabb: AABB2) -> [..] *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            if !fixture.m_shape {
                return true;
            }

            convert :: (body: *Body) -> *b2Body {
                return body.data;
            }

            callback := cast(*QueryCallback) this;
            if contains(callback.bodies, convert, fixture.m_body) {
                return true;
            }

            fixture_transform := b2Body.GetTransform(fixture.m_body);

            shape := callback.shape;
            transform := callback.transform;
            if b2TestOverlap(shape, 0, fixture.m_shape, 0, transform, fixture_transform) {
                array_add(*callback.bodies, get_body_from_physics_body(fixture.m_body));
            }

            return true;
        }
    };

    delta := aabb.upper / world_scale - aabb.lower / world_scale;
    center := aabb.lower / world_scale + delta / 2;

    box_shape: b2PolygonShape;
    b2PolygonShape.Constructor(*box_shape);
    b2PolygonShape.SetAsBox(*box_shape, delta.x / 2, delta.y / 2);

    transform: b2Transform;
    b2Transform.Set(*transform, *center, 0);

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        shape: *b2PolygonShape;
        transform: *b2Transform;
        bodies: [..] *Body;
    }
    callback: QueryCallback;
    callback.shape = *box_shape;
    callback.transform = *transform;
    callback.vtable = *vtable;

    b2aabb: b2AABB;
    b2aabb.lowerBound = aabb.lower / world_scale;
    b2aabb.upperBound = aabb.upper / world_scale;

    b2World.QueryAABB(world, *callback, *b2aabb);

    return callback.bodies;
}

get_body_in_circle :: (center: Vector2, radius: float) -> *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            if !fixture.m_shape {
                return true;
            }

            fixture_transform := b2Body.GetTransform(fixture.m_body);

            callback := cast(*QueryCallback) this;
            shape := callback.shape;
            transform := callback.transform;
            if b2TestOverlap(shape, 0, fixture.m_shape, 0, transform, fixture_transform) {
                callback.body = get_body_from_physics_body(fixture.m_body);

                return false;
            }

            return true;
        }
    };

    circle_center := center / world_scale;

    circle_shape: b2CircleShape;
    b2CircleShape.Constructor(*circle_shape);
    circle_shape.m_radius = radius / world_scale;

    transform: b2Transform;
    b2Transform.Set(*transform, *circle_center, 0);

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        shape: *b2CircleShape;
        transform: *b2Transform;
        body: *Body;
    }
    callback: QueryCallback;
    callback.shape = *circle_shape;
    callback.transform = *transform;
    callback.vtable = *vtable;

    b2aabb: b2AABB;
    b2aabb.lowerBound = circle_center - radius / world_scale;
    b2aabb.upperBound = circle_center + radius / world_scale;

    b2World.QueryAABB(world, *callback, *b2aabb);

    return callback.body;
}

get_bodies_in_circle :: (center: Vector2, radius: float) -> [..] *Body {
    vtable: b2QueryCallback_VTable;
    vtable.ReportFixture = (this: *b2QueryCallback, fixture: *b2Fixture) -> bool #cpp_method {
        new_context: Context;
        push_context new_context {
            if !fixture.m_shape {
                return true;
            }

            convert :: (body: *Body) -> *b2Body {
                return body.data;
            }

            callback := cast(*QueryCallback) this;
            if contains(callback.bodies, convert, fixture.m_body) {
                return true;
            }

            fixture_transform := b2Body.GetTransform(fixture.m_body);

            shape := callback.shape;
            transform := callback.transform;
            if b2TestOverlap(shape, 0, fixture.m_shape, 0, transform, fixture_transform) {
                array_add(*callback.bodies, get_body_from_physics_body(fixture.m_body));
            }

            return true;
        }
    };

    circle_center := center / world_scale;

    circle_shape: b2CircleShape;
    b2CircleShape.Constructor(*circle_shape);
    circle_shape.m_radius = radius / world_scale;

    transform: b2Transform;
    b2Transform.Set(*transform, *circle_center, 0);

    QueryCallback :: struct {
        using #as callback: b2QueryCallback;
        shape: *b2CircleShape;
        transform: *b2Transform;
        bodies: [..] *Body;
    }
    callback: QueryCallback;
    callback.shape = *circle_shape;
    callback.transform = *transform;
    callback.vtable = *vtable;

    b2aabb: b2AABB;
    b2aabb.lowerBound = circle_center - radius / world_scale;
    b2aabb.upperBound = circle_center + radius / world_scale;

    b2World.QueryAABB(world, *callback, *b2aabb);

    return callback.bodies;
}

step_physics :: (delta: float) {
    // TODO auto set tracked/dynamic bodies to bullets or not bullets based on radius and speed
    for *body: allocated_bodies {
        update_dirty(body);
    }

    b2World.Step(world, delta / 1000.0, 8, 3);

    for *body: allocated_bodies {
        update_values(body);
    }

    update_contacts();
}
