set_draw_shapes :: (enabled: bool) {
    if enabled && !debug_draw {
        debug_draw = create_draw_struct();
        b2World.SetDebugDraw(world, debug_draw);
    } else if !enabled && debug_draw {
        b2World.SetDebugDraw(world, null);
        // TODO probably dont need to do this?
        b2Draw.virtual_Destructor(debug_draw);
        free(debug_draw);
    }

    // print("%\n", << cast(*b2PolygonShape) Fixture_get_shape(Body_get_fixture_list(World_get_body_list(world))));
}

draw_shapes :: () {
    old_transform := Koda.koda.transform;
    defer Koda.koda.transform = old_transform;

    Koda.koda.transform = scale(Koda.koda.transform, xyz(world_scale, world_scale, world_scale));
    b2World.DebugDraw(world);
    // World_debug_draw(world);
}

#scope_file

create_draw_struct :: () -> *b2Draw {
    draw := New(b2Draw);
    b2Draw.Constructor(draw);
    // print("made draw %\n", draw.vtable);
    draw.vtable = New(b2Draw_VTable);
    draw.vtable.DrawPolygon = draw_polygon;
    draw.vtable.DrawSolidPolygon = draw_solid_polygon;
    draw.vtable.DrawCircle = draw_circle;
    draw.vtable.DrawSolidCircle = draw_solid_circle;
    draw.vtable.DrawSegment = draw_segment;
    draw.vtable.DrawTransform = draw_transform;
    draw.vtable.DrawPoint = draw_point;
    // draw.vtable.DrawPolygon = draw_polygon;
    // draw.vtable.DrawSolidPolygon = draw_solid_polygon;
    // draw.vtable = New(b2Draw_VTable);
    // draw := Draw_new(draw_polygon, draw_solid_polygon, draw_circle, draw_solid_circle, draw_particles, draw_segment, draw_transform, draw_point);
    b2Draw.AppendFlags(draw, xx b2Draw.e_2.shapeBit);
    b2Draw.AppendFlags(draw, xx b2Draw.e_2.jointBit);
    b2Draw.AppendFlags(draw, xx b2Draw.e_2.centerOfMassBit);

    return draw;
}

// vtable: b2Draw_VTable = .{
//     DrawPolygon = draw_polygon,
//     DrawSolidPolygon = draw_solid_polygon,
//     DrawCircle = draw_circle,
//     DrawSolidCircle = draw_solid_circle,
//     DrawSegment = draw_segment,
//     DrawTransform = draw_transform,
//     DrawPoint = draw_point,
// };

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

// draw_particles :: (this: *b2Draw, centers: *Vector2, radius: float32, colors: *b2ParticleColor, count: s32) #c_call {
//     new_context: Context;
//     push_context new_context {
//         koda_centers: [] Vector2;
//         koda_centers.data = centers;
//         koda_centers.count = count;

//         koda_colors: [] b2ParticleColor;
//         koda_colors.data = colors;
//         koda_colors.count = count;

//         for i: 0..count - 1 {
//             center := koda_centers[i];
//             color: Koda.Color;
//             if colors == null {
//                 color.r = 1;
//                 color.g = 1;
//                 color.b = 1;
//                 color.a = 1;
//             } else {
//                 color.r = koda_colors[i].r / 255.0;
//                 color.g = koda_colors[i].g / 255.0;
//                 color.b = koda_colors[i].b / 255.0;
//                 color.a = koda_colors[i].a / 255.0;
//             }

//             // Koda.draw_rect(center - radius, xy(radius, radius), color);
//             Koda.draw_ellipse(center, radius * 2 * 0.75, radius * 2 * 0.75, color);
//         }
//     }
// }

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
