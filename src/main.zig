const std = @import("std");
const json = std.json;

fn isJsonType(value: *const json.Value) bool {
    const obj = value.*.object;

    if (obj.get("computedValueType")) |cvt| {
        switch (cvt) {
            .object => |cvt_obj| {
                if (cvt_obj.get("type")) |type_val| {
                    return switch (type_val) {
                        .string => |s| std.mem.eql(u8, s, "json"),
                        else => false,
                    };
                }
            },
            else => {},
        }
    }
    return false;
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    // Read all of stdin (up to 32 MiB) into memory.
    const raw = try std.io.getStdIn().reader().readAllAlloc(alloc, 32 * 1024 * 1024);
    defer alloc.free(raw);

    var parsed = try json.parseFromSlice(json.Value, alloc, raw, .{});
    defer parsed.deinit();

    const root = parsed.value;
    switch (root) {
        .object => {},
        else => return error.InvalidJson,
    }

    const out = std.io.getStdOut().writer();
    try out.writeAll("{\n");

    var it = root.object.iterator();
    var first: bool = true;
    while (it.next()) |e| {
        const key = e.key_ptr.*;
        const val = e.value_ptr.*;

        if (!first) try out.writeAll(",\n");
        first = false;

        try out.print("  \"{s}\": {{{{ .{s} ", .{ key, key });
        if (isJsonType(&val)) {
            try out.writeAll("}}");
        } else {
            try out.writeAll("| tojson }}");
        }
    }

    if (!first) try out.writeAll("\n");
    try out.writeAll("}\n");
}
