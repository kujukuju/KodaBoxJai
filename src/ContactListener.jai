create_contact_listener :: () {
    if contact_listener {
        free(contact_listener.vtable);
        free(contact_listener);
        contact_listener = null;
    }

    contact_listener = New(b2ContactListener);
    contact_listener.vtable = New(b2ContactListener_VTable);
    contact_listener.vtable.BeginContact = begin_contact;
    contact_listener.vtable.EndContact = end_contact;
    contact_listener.vtable.PreSolve = pre_solve;
    contact_listener.vtable.PostSolve = post_solve;

    b2World.SetContactListener(world, contact_listener);
}

update_contacts :: () {
    for *collision: tracked_collisions {
        world_manifold: b2WorldManifold;
        b2Contact.GetWorldManifold(collision.contact, *world_manifold);

        collision.normal = world_manifold.normal;
    }
}

begin_contact :: (this: *b2ContactListener, contact: *b2Contact) #cpp_method {
    new_context: Context;
    push_context new_context {
        convert_body :: (a: *Body) -> *b2Body {
            return a.data;
        }

        body_a := ifx contact.m_fixtureA && contact.m_fixtureA.m_body then find(tracked_bodies, convert_body, contact.m_fixtureA.m_body) else null;
        body_b := ifx contact.m_fixtureB && contact.m_fixtureB.m_body then find(tracked_bodies, convert_body, contact.m_fixtureB.m_body) else null;
        if body_a || body_b {
            collision: TrackedCollision;
            collision.contact = contact;
            collision.body_a = body_a;
            collision.body_b = body_b;

            world_manifold: b2WorldManifold;
            b2Contact.GetWorldManifold(contact, *world_manifold);
            collision.normal = world_manifold.normal;

            array_add(*tracked_collisions, collision);
        }
    }
}

end_contact :: (this: *b2ContactListener, contact: *b2Contact) #cpp_method {
    new_context: Context;
    push_context new_context {
        for i: 0..tracked_collisions.count - 1 {
            if tracked_collisions[i].contact == contact {
                array_ordered_remove_by_index(*tracked_collisions, i);
                return;
            }
        }
    }
}

pre_solve :: (this: *b2ContactListener, contact: *b2Contact, oldManifold: *b2Manifold) #cpp_method {

}

post_solve :: (this: *b2ContactListener, contact: *b2Contact, impulse: *b2ContactImpulse) #cpp_method {

}
