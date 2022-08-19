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

step_physics :: (delta: float) {
    // TODO auto set tracked/dynamic bodies to bullets or not bullets based on radius and speed

    b2World.Step(world, delta / 1000.0, 8, 3);

    update_contacts();
}
