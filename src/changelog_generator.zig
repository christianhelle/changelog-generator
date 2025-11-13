const std = @import("std");
const models = @import("models.zig");

pub const ChangelogEntry = struct {
    title: []const u8,
    url: []const u8,
    author: []const u8,
    number: u32,
};

pub const ChangelogSection = struct {
    name: []const u8,
    entries: []ChangelogEntry,
};

pub const ChangelogRelease = struct {
    version: []const u8,
    date: []const u8,
    sections: []ChangelogSection,
};

pub const ChangelogGenerator = struct {
    allocator: std.mem.Allocator,
    exclude_labels: ?[]const u8 = null,

    pub fn init(allocator: std.mem.Allocator, exclude_labels: ?[]const u8) ChangelogGenerator {
        return ChangelogGenerator{
            .allocator = allocator,
            .exclude_labels = exclude_labels,
        };
    }

    /// Check if an entry should be excluded based on labels
    fn shouldExclude(self: ChangelogGenerator, labels: []models.Label) bool {
        if (self.exclude_labels == null) return false;

        const exclude = self.exclude_labels.?;
        for (labels) |label| {
            if (std.mem.indexOf(u8, exclude, label.name) != null) {
                return true;
            }
        }
        return false;
    }

    /// Categorize PR/issue based on labels
    fn categorizeEntry(_: ChangelogGenerator, labels: []models.Label) []const u8 {
        for (labels) |label| {
            if (std.mem.eql(u8, label.name, "feature") or std.mem.eql(u8, label.name, "enhancement")) {
                return "Features";
            } else if (std.mem.eql(u8, label.name, "bug") or std.mem.eql(u8, label.name, "bugfix")) {
                return "Bug Fixes";
            }
        }
        return "Other";
    }

    /// Generate changelog from releases and PRs
    pub fn generate(
        self: ChangelogGenerator,
        releases: []models.Release,
        prs: []models.PullRequest,
    ) ![]ChangelogRelease {
        var result = try std.ArrayList(ChangelogRelease).initCapacity(self.allocator, releases.len);

        for (releases) |release| {
            var sections_map = std.StringHashMap(std.ArrayList(ChangelogEntry)).init(self.allocator);
            defer {
                var it = sections_map.iterator();
                while (it.next()) |entry| {
                    entry.value_ptr.deinit(self.allocator);
                }
                sections_map.deinit();
            }

            // Group PRs by category
            for (prs) |pr| {
                if (self.shouldExclude(pr.labels)) continue;

                const category = self.categorizeEntry(pr.labels);

                var section_list = sections_map.getOrPut(category) catch continue;
                if (!section_list.found_existing) {
                    const arr = try std.ArrayList(ChangelogEntry).initCapacity(self.allocator, 10);
                    section_list.value_ptr.* = arr;
                }

                const entry = ChangelogEntry{
                    .title = pr.title,
                    .url = pr.html_url,
                    .author = pr.user.login,
                    .number = pr.number,
                };

                section_list.value_ptr.appendAssumeCapacity(entry);
            }

            // Convert sections map to array
            var sections_array = try std.ArrayList(ChangelogSection).initCapacity(self.allocator, sections_map.count());

            var it = sections_map.iterator();
            while (it.next()) |entry| {
                const changelog_section = ChangelogSection{
                    .name = entry.key_ptr.*,
                    .entries = try entry.value_ptr.toOwnedSlice(self.allocator),
                };
                sections_array.appendAssumeCapacity(changelog_section);
            }

            const release_entry = ChangelogRelease{
                .version = release.tag_name,
                .date = release.published_at,
                .sections = try sections_array.toOwnedSlice(self.allocator),
            };

            result.appendAssumeCapacity(release_entry);
        }

        return result.toOwnedSlice(self.allocator);
    }

    pub fn deinit(self: ChangelogGenerator, releases: []ChangelogRelease) void {
        for (releases) |release| {
            for (release.sections) |section| {
                self.allocator.free(section.entries);
            }
            self.allocator.free(release.sections);
        }
        self.allocator.free(releases);
    }
};
