set_draw_shapes :: (enabled: bool) {
    if enabled && !debug_draw {
        debug_draw = create_draw_struct();
        b2World.SetDebugDraw(world, debug_draw);
    } else if !enabled && debug_draw {
        b2World.SetDebugDraw(world, null);
        free(debug_draw);
        debug_draw = null;
    }
}

draw_shapes :: () {
    old_view := Koda.koda.view;
    defer Koda.koda.view = old_view;

    cull_face := Koda.get_cull_face();
    defer Koda.set_cull_face(cull_face);
    Koda.set_cull_face(false);

    Koda.koda.view = scale(Koda.koda.view, xyz(world_scale, world_scale, world_scale));
    b2World.DebugDraw(world);
}

#scope_file

create_draw_struct :: () -> *b2Draw {
    draw := New(b2Draw);
    b2Draw.Constructor(draw);
    draw.vtable = New(b2Draw_VTable);
    draw.vtable.DrawPolygon = draw_polygon;
    draw.vtable.DrawSolidPolygon = draw_solid_polygon;
    draw.vtable.DrawCircle = draw_circle;
    draw.vtable.DrawSolidCircle = draw_solid_circle;
    draw.vtable.DrawSegment = draw_segment;
    draw.vtable.DrawTransform = draw_transform;
    draw.vtable.DrawPoint = draw_point;
    b2Draw.AppendFlags(draw, xx b2Draw.e_2.shapeBit);
    b2Draw.AppendFlags(draw, xx b2Draw.e_2.jointBit);
    b2Draw.AppendFlags(draw, xx b2Draw.e_2.centerOfMassBit);

    return draw;
}

draw_polygon :: (this: *b2Draw, vertices: *Vector2, vertexCount: s32, color: *b2Color) #cpp_method {
    new_context: Context;
    push_context new_context {
        koda_points: [] Vector2;
        koda_points.data = vertices;
        koda_points.count = vertexCount;

        koda_color: Koda.Color;
        koda_color.r = color.r;
        koda_color.g = color.g;
        koda_color.b = color.b;
        koda_color.a = color.a;

        Koda.draw_polygon(koda_points, koda_color);
    }
}

draw_solid_polygon :: (this: *b2Draw, vertices: *Vector2, vertexCount: s32, color: *b2Color) #cpp_method {
    new_context: Context;
    push_context new_context {
        koda_points: [] Vector2;
        koda_points.data = vertices;
        koda_points.count = vertexCount;

        koda_color: Koda.Color;
        koda_color.r = color.r;
        koda_color.g = color.g;
        koda_color.b = color.b;
        koda_color.a = color.a;

        Koda.draw_polygon(koda_points, koda_color);
    }
}

draw_circle :: (this: *b2Draw, center: *Vector2, radius: float32, color: *b2Color) #cpp_method {
    new_context: Context;
    push_context new_context {
        koda_color: Koda.Color;
        koda_color.r = color.r;
        koda_color.g = color.g;
        koda_color.b = color.b;
        koda_color.a = color.a;

        Koda.draw_ellipse(center, radius, radius, koda_color);
    }
}

draw_solid_circle :: (this: *b2Draw, center: *Vector2, radius: float32, axis: *Vector2, color: *b2Color) #cpp_method {
    new_context: Context;
    push_context new_context {
        koda_color: Koda.Color;
        koda_color.r = color.r;
        koda_color.g = color.g;
        koda_color.b = color.b;
        koda_color.a = color.a;

        Koda.draw_ellipse(center, radius * 2, radius * 2, koda_color);
    }
}

draw_segment :: (this: *b2Draw, p1: *Vector2, p2: *Vector2, color: *b2Color) #cpp_method {

}

draw_transform :: (this: *b2Draw, xf: *b2Transform) #cpp_method {

}

draw_point :: (this: *b2Draw, p: *Vector2, size: float, color: *b2Color) #cpp_method {

}

draw_segment :: (this: *b2Draw, p1: Vector2, p2: Vector2, color: b2Color) #c_call {
    new_context: Context;
    push_context new_context {
        koda_color: Koda.Color;
        koda_color.r = color.r / 255.0;
        koda_color.g = color.g / 255.0;
        koda_color.b = color.b / 255.0;
        koda_color.a = color.a / 255.0;

        Koda.draw_line(p1.x, p1.y, p2.x, p2.y, 1.0, koda_color);
    }
}

draw_transform :: (this: *b2Draw, xf: b2Transform) #c_call {
    new_context: Context;
    push_context new_context {

    }
}

draw_point :: (this: *b2Draw, p: Vector2, size: float, color: b2Color) #c_call {
    new_context: Context;
    push_context new_context {
        koda_color: Koda.Color;
        koda_color.r = color.r / 255.0;
        koda_color.g = color.g / 255.0;
        koda_color.b = color.b / 255.0;
        koda_color.a = color.a / 255.0;
        
        Koda.draw_line(p.x - 4, p.y - 4, p.x + 4, p.y + 4, 1.0, koda_color);
        Koda.draw_line(p.x + 4, p.y - 4, p.x - 4, p.y + 4, 1.0, koda_color);
    }
}

Koda :: #import "KodaJai";
