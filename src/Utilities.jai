
get_valid_polygons :: (polygon: [] Vector2) -> [..] FixedPolygon(b2_maxPolygonVertices) {
    valid: [..] FixedPolygon(b2_maxPolygonVertices);

    if !is_ccw(polygon) {
        copied := array_copy(polygon);
        defer array_free(copied);
        reverse(*copied);

        if !is_convex(copied) {
            split := decompose(copied);
            defer array_free(split);
            
            for convex: split {
                defer array_free(convex);

                if convex.count > b2_maxPolygonVertices {
                    divided_list := split_convex_polygon(convex, b2_maxPolygonVertices);
                    defer array_free(divided_list);

                    for divided: divided_list {
                        fixed: FixedPolygon(b2_maxPolygonVertices);
                        fixed.count = divided.count;
                        for i: 0..divided.count - 1 {
                            fixed.vertices[i] = divided.vertices[i];
                        }

                        array_add(*valid, fixed);
                    }
                } else {
                    fixed: FixedPolygon(b2_maxPolygonVertices);
                    fixed.count = convex.count;
                    for i: 0..convex.count - 1 {
                        fixed.vertices[i] = convex[i];
                    }

                    array_add(*valid, fixed);
                }
            }
        }
    } else if !is_convex(polygon) {
        split := decompose(polygon);
        defer array_free(split);
        
        for convex: split {
            defer array_free(convex);

            if convex.count > b2_maxPolygonVertices {
                divided_list := split_convex_polygon(convex, b2_maxPolygonVertices);
                defer array_free(divided_list);

                for divided: divided_list {
                    fixed: FixedPolygon(b2_maxPolygonVertices);
                    fixed.count = divided.count;
                    for i: 0..divided.count - 1 {
                        fixed.vertices[i] = divided.vertices[i];
                    }

                    array_add(*valid, fixed);
                }
            } else {
                fixed: FixedPolygon(b2_maxPolygonVertices);
                fixed.count = convex.count;
                for i: 0..convex.count - 1 {
                    fixed.vertices[i] = convex[i];
                }

                array_add(*valid, fixed);
            }
        }
    } else {
        if polygon.count > b2_maxPolygonVertices {
            divided_list := split_convex_polygon(polygon, b2_maxPolygonVertices);
            defer array_free(divided_list);

            for divided: divided_list {
                fixed: FixedPolygon(b2_maxPolygonVertices);
                fixed.count = divided.count;
                for i: 0..divided.count - 1 {
                    fixed.vertices[i] = divided.vertices[i];
                }

                array_add(*valid, fixed);
            }
        } else {
            fixed: FixedPolygon(b2_maxPolygonVertices);
            fixed.count = polygon.count;
            for i: 0..polygon.count - 1 {
                fixed.vertices[i] = polygon[i];
            }

            array_add(*valid, fixed);
        }
    }

    return valid;
}

contains :: (list: [] $T, b: T) -> bool {
    for entry: list {
        if entry == b {
            return true;
        }
    }

    return false;
}

contains :: (list: [] $A, $convert: (a: A) -> $B, b: B) -> bool {
    for entry: list {
        if convert(entry) == b {
            return true;
        }
    }

    return false;
}

find :: (list: [] $A, $convert: (a: A) -> $B, b: B) -> A, bool {
    for entry: list {
        if convert(entry) == b {
            return entry, true;
        }
    }
    
    empty: A;
    return empty, false;
}