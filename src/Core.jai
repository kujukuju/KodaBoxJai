koda_box_init :: () {
    if world {
        // destroy the world
        assert(false, "We don't yet support this.");
    }

    world = World_new(.{0, 0});
}

get_gravity :: () -> Vector2 {
    return World_get_gravity(world) * world_scale;
}

set_gravity :: (gravity: Vector2) {
    new := gravity / world_scale;
    World_set_gravity(world, *new);
}

get_scale :: () -> float {
    return world_scale;
}

set_scale :: (scale: float) {
    world_scale = scale;
}

step_physics :: (delta: float) {
    World_step(world, delta / 1000.0, 8, 3, 0);
}
