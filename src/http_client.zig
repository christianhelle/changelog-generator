const std = @import("std");

pub const HttpClient = struct {
    allocator: std.mem.Allocator,
    token: []const u8,
    base_url: []const u8 = "https://api.github.com",

    pub fn init(allocator: std.mem.Allocator, token: []const u8) HttpClient {
        return HttpClient{
            .allocator = allocator,
            .token = token,
        };
    }

    pub fn get(self: *HttpClient, endpoint: []const u8) ![]u8 {
        // For now, return a mock response showing the structure
        // In a real implementation, this would use std.http.Client.fetch()
        const url = try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ self.base_url, endpoint });
        defer self.allocator.free(url);

        std.debug.print("Note: Would fetch from {s}\n", .{url});
        std.debug.print("Using Authorization: token {s}\n", .{self.token[0..@min(10, self.token.len)]});

        // Return empty array for now - real implementation needed
        return try self.allocator.alloc(u8, 0);
    }

    pub fn deinit(self: *HttpClient) void {
        _ = self;
    }
};
