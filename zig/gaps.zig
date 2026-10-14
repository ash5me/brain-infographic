//! Data engine for the "missing areas" page.
//!
//! Compiled to WebAssembly next to brain.zig. Owns the table of brain areas
//! and the activities that engage them, and tracks which activities the
//! person has ticked off so the page can show coverage.

const std = @import("std");

pub const area_n = 9;
pub const max_acts = 5;

/// Order must match `AREAS` in web/src/lib/areas.js.
pub const Area = enum(u8) { hippocampus, amygdala, cingulate_insula, basal_ganglia, somatosensory, social, orbitofrontal, smell_taste, vestibular };

const Entry = struct {
    name: []const u8,
    what: []const u8,
    acts: []const []const u8,
};

const areas = [area_n]Entry{
    .{
        .name = "Hippocampus",
        .what = "Forming memories, spatial navigation",
        .acts = &[_][]const u8{
            "Learning a new route without GPS",
            "Building a memory palace",
            "Orienteering",
            "Aerobic exercise like running or swimming",
        },
    },
    .{
        .name = "Amygdala and limbic system",
        .what = "Emotion, emotional memory",
        .acts = &[_][]const u8{
            "Improv theatre",
            "Journaling about feelings",
            "Storytelling",
            "Listening to music that moves you",
        },
    },
    .{
        .name = "Anterior cingulate and insula",
        .what = "Attention control, body awareness, empathy",
        .acts = &[_][]const u8{
            "Mindfulness or breath meditation",
            "Yoga",
            "Body-scan practice",
        },
    },
    .{
        .name = "Basal ganglia",
        .what = "Habits, learned movement sequences, reward",
        .acts = &[_][]const u8{
            "Dance",
            "Martial arts",
            "Juggling",
            "Racquet sports",
            "Learning a new physical skill",
        },
    },
    .{
        .name = "Somatosensory cortex",
        .what = "Touch and body position",
        .acts = &[_][]const u8{
            "Clay sculpting",
            "Cooking",
            "Woodworking",
            "Reading Braille",
        },
    },
    .{
        .name = "Social brain",
        .what = "Understanding other people's thoughts and intentions",
        .acts = &[_][]const u8{
            "Team sports",
            "Debate",
            "Role-play",
            "Group projects",
            "Reading fiction",
        },
    },
    .{
        .name = "Orbitofrontal cortex",
        .what = "Valuing choices, reward and taste",
        .acts = &[_][]const u8{
            "Cooking and tasting",
            "Negotiating",
            "Weighing real trade-offs",
        },
    },
    .{
        .name = "Olfactory and gustatory areas",
        .what = "Smell and taste",
        .acts = &[_][]const u8{
            "Wine or tea tasting",
            "Perfumery",
            "Cooking with unfamiliar spices",
        },
    },
    .{
        .name = "Vestibular and balance circuits",
        .what = "Balance, orientation in space",
        .acts = &[_][]const u8{
            "Tai chi",
            "Rock climbing",
            "Slacklining",
            "Surfing",
        },
    },
};

const empty: []const u8 = "";

const Flags = [area_n][max_acts]bool;

var done: Flags = std.mem.zeroes(Flags);

fn validAct(a: u32, i: u32) bool {
    return a < area_n and i < areas[a].acts.len;
}

// ---------------------------------------------------------------- exports

export fn area_count() u32 {
    return area_n;
}

export fn name_ptr(a: u32) [*]const u8 {
    return if (a < area_n) areas[a].name.ptr else empty.ptr;
}

export fn name_len(a: u32) u32 {
    return if (a < area_n) @intCast(areas[a].name.len) else 0;
}

export fn what_ptr(a: u32) [*]const u8 {
    return if (a < area_n) areas[a].what.ptr else empty.ptr;
}

export fn what_len(a: u32) u32 {
    return if (a < area_n) @intCast(areas[a].what.len) else 0;
}

export fn act_count(a: u32) u32 {
    return if (a < area_n) @intCast(areas[a].acts.len) else 0;
}

export fn act_ptr(a: u32, i: u32) [*]const u8 {
    return if (validAct(a, i)) areas[a].acts[i].ptr else empty.ptr;
}

export fn act_len(a: u32, i: u32) u32 {
    return if (validAct(a, i)) @intCast(areas[a].acts[i].len) else 0;
}

/// Mark activity `i` of area `a` as done (v != 0) or not done (v == 0).
export fn set_done(a: u32, i: u32, v: u32) void {
    if (validAct(a, i)) done[a][i] = v != 0;
}

export fn is_done(a: u32, i: u32) u32 {
    return if (validAct(a, i) and done[a][i]) 1 else 0;
}

/// How many of area `a`'s activities are ticked.
export fn done_count(a: u32) u32 {
    if (a >= area_n) return 0;
    var n: u32 = 0;
    for (0..areas[a].acts.len) |i| {
        if (done[a][i]) n += 1;
    }
    return n;
}

/// How many areas have at least one ticked activity.
export fn covered_count() u32 {
    var n: u32 = 0;
    for (0..area_n) |a| {
        if (done_count(@intCast(a)) > 0) n += 1;
    }
    return n;
}

export fn reset() void {
    done = std.mem.zeroes(Flags);
}

// ------------------------------------------------------------------ tests

test "every area has between one and max_acts activities" {
    for (areas) |e| {
        try std.testing.expect(e.acts.len >= 1 and e.acts.len <= max_acts);
    }
}

test "ticking activities updates coverage" {
    reset();
    try std.testing.expectEqual(@as(u32, 0), covered_count());
    set_done(@intFromEnum(Area.basal_ganglia), 0, 1);
    set_done(@intFromEnum(Area.basal_ganglia), 3, 1);
    set_done(@intFromEnum(Area.vestibular), 1, 1);
    try std.testing.expectEqual(@as(u32, 2), done_count(@intFromEnum(Area.basal_ganglia)));
    try std.testing.expectEqual(@as(u32, 2), covered_count());
    set_done(@intFromEnum(Area.vestibular), 1, 0);
    try std.testing.expectEqual(@as(u32, 1), covered_count());
    reset();
    try std.testing.expectEqual(@as(u32, 0), covered_count());
}

test "out-of-range activity indices are ignored" {
    reset();
    set_done(@intFromEnum(Area.hippocampus), 4, 1); // hippocampus has only 4 (0..3)
    set_done(99, 0, 1);
    try std.testing.expectEqual(@as(u32, 0), covered_count());
    try std.testing.expectEqual(@as(u32, 0), act_len(99, 0));
}

test "area names match the table" {
    try std.testing.expectEqualStrings("Hippocampus", areas[@intFromEnum(Area.hippocampus)].name);
    try std.testing.expectEqual(@as(u32, 5), act_count(@intFromEnum(Area.social)));
}
