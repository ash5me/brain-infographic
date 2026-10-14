//! Data engine for the brain infographic.
//!
//! Compiled to WebAssembly (wasm32-freestanding, no allocator, no libc) and
//! loaded by the Svelte front end. Zig owns the activity x region table, the
//! overlap counts, the ranking, and the explanatory text, so the UI never
//! hard-codes any of it.

const std = @import("std");

pub const activity_n = 5;
pub const region_n = 9;

/// Column order. Must match `REGIONS` in web/src/lib/regions.js.
pub const Region = enum(u8) { pf, mo, pa, oc, tp, au, br, we, cb };

/// Row order. Must match `ACTIVITIES` in web/src/lib/activities.js.
pub const Activity = enum(u8) { writing, programming, design, drawing, music };

const Cell = struct {
    /// 0 = not involved, 1 = supporting role, 2 = main role.
    w: u8,
    role: []const u8,
};

const none: Cell = .{ .w = 0, .role = "" };

fn c(w: u8, role: []const u8) Cell {
    return .{ .w = w, .role = role };
}

//                      pf   mo   pa   oc   tp   au   br   we   cb
const table: [activity_n][region_n]Cell = .{
    // writing
    .{
        c(2, "Generates ideas, plans plot and structure"),
        c(1, "Controls the hands for typing or writing"),
        none,
        none,
        c(1, "Retrieves memories and mental imagery"),
        none,
        c(2, "Turns thoughts into fluent sentences"),
        c(2, "Finds word meaning and checks that it makes sense"),
        none,
    },
    // programming
    .{
        c(2, "Working memory, planning, and logical rules"),
        none,
        c(2, "Symbols, maths, and tracking variables"),
        c(1, "Visually scans code on screen"),
        none,
        none,
        c(1, "Parses code much like a language"),
        c(1, "Maps names and comments to meaning"),
        none,
    },
    // design thinking
    .{
        c(2, "Switches between divergent and convergent thinking"),
        none,
        c(2, "Spatial layout and mental rotation"),
        c(1, "Processes form, colour, and composition"),
        c(2, "Links ideas, recalls objects and patterns"),
        none,
        none,
        none,
        none,
    },
    // drawing
    .{
        c(1, "Plans the composition and makes decisions"),
        c(2, "Drives precise hand and finger movement"),
        c(2, "Eye-hand coordination and spatial mapping"),
        c(2, "Analyses shape, edges, and colour"),
        none,
        none,
        none,
        none,
        c(2, "Fine-tunes smooth, accurate strokes"),
    },
    // music
    .{
        c(1, "Plans phrases and improvises"),
        c(2, "Controls fingers, breath, or voice"),
        c(1, "Links sound, touch, and notation"),
        none,
        c(1, "Recalls melodies and musical memory"),
        c(2, "Processes pitch, timbre, and rhythm"),
        none,
        none,
        c(2, "Keeps timing and coordinates movement"),
    },
};

/// Sentinel passed to `rank` to rank regions by how many activities use them.
const all_activities: u32 = 0xFFFF_FFFF;

var out_buf: [region_n]u8 = undefined;

fn cell(a: u32, r: u32) Cell {
    if (a >= activity_n or r >= region_n) return none;
    return table[a][r];
}

fn overlapOf(r: u32) u32 {
    var n: u32 = 0;
    for (0..activity_n) |a| {
        if (cell(@intCast(a), r).w > 0) n += 1;
    }
    return n;
}

fn score(a: u32, r: u32) u32 {
    return if (a == all_activities) overlapOf(r) else cell(a, r).w;
}

// ---------------------------------------------------------------- exports

export fn activity_count() u32 {
    return activity_n;
}

export fn region_count() u32 {
    return region_n;
}

/// 0, 1 or 2. Out-of-range indices return 0.
export fn weight(a: u32, r: u32) u32 {
    return cell(a, r).w;
}

/// Number of activities (0..5) that involve region `r`.
export fn overlap(r: u32) u32 {
    return overlapOf(r);
}

export fn role_ptr(a: u32, r: u32) [*]const u8 {
    return cell(a, r).role.ptr;
}

export fn role_len(a: u32, r: u32) u32 {
    return @intCast(cell(a, r).role.len);
}

/// Address of the shared output buffer that `rank` writes into.
export fn out_ptr() [*]const u8 {
    return &out_buf;
}

/// Writes the region indices involved in activity `a` into the output buffer,
/// strongest first (ties keep region order). Pass 0xFFFFFFFF for "all
/// activities" to rank by overlap. Returns how many indices were written.
export fn rank(a: u32) u32 {
    var n: u32 = 0;
    for (0..region_n) |r| {
        if (score(a, @intCast(r)) > 0) {
            out_buf[n] = @intCast(r);
            n += 1;
        }
    }
    // Insertion sort: tiny n, stable, no allocation.
    var i: u32 = 1;
    while (i < n) : (i += 1) {
        const key = out_buf[i];
        const ks = score(a, key);
        var j: u32 = i;
        while (j > 0 and score(a, out_buf[j - 1]) < ks) : (j -= 1) {
            out_buf[j] = out_buf[j - 1];
        }
        out_buf[j] = key;
    }
    return n;
}

// ------------------------------------------------------------------ tests

test "prefrontal cortex is used by every activity" {
    try std.testing.expectEqual(@as(u32, 5), overlap(@intFromEnum(Region.pf)));
}

test "auditory cortex is music only" {
    try std.testing.expectEqual(@as(u32, 1), overlap(@intFromEnum(Region.au)));
    try std.testing.expectEqual(@as(u32, 2), weight(@intFromEnum(Activity.music), @intFromEnum(Region.au)));
}

test "rank puts main roles before supporting roles" {
    const n = rank(@intFromEnum(Activity.drawing));
    try std.testing.expectEqual(@as(u32, 5), n);
    try std.testing.expectEqual(@as(u8, @intFromEnum(Region.mo)), out_buf[0]);
    try std.testing.expectEqual(@as(u8, @intFromEnum(Region.pf)), out_buf[4]);
}

test "rank by overlap leads with prefrontal cortex" {
    const n = rank(all_activities);
    try std.testing.expectEqual(@as(u32, 9), n);
    try std.testing.expectEqual(@as(u8, @intFromEnum(Region.pf)), out_buf[0]);
}

test "out-of-range lookups are safe" {
    try std.testing.expectEqual(@as(u32, 0), weight(9, 0));
    try std.testing.expectEqual(@as(u32, 0), role_len(0, 99));
}
