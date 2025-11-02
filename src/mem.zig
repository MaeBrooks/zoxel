const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var alloc = arena.allocator();

pub fn allocator() std.mem.Allocator {
		return alloc;
}

pub fn create(comptime T: type) std.mem.Allocator.Error!*T {
		return alloc.create(T);
}

pub fn destroy(ptr: anytype) void {
		return alloc.destroy(ptr);
}

pub fn deinit() void {
		arena.deinit();
}

