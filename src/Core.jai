initialize :: () {
    if world {
        // destroy the world
        assert(false, "We don't yet support this.");
    }

    world = World_new(.{0, 0});
}

get_gravity :: () -> Vector2 {
    return World_get_gravity(world);
}

set_gravity :: (gravity: Vector2) {
    World_set_gravity(world, *gravity);
}
