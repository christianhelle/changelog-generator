const std = @import("std");
const models = @import("models.zig");
const changelog_generator = @import("changelog_generator.zig");
const markdown_formatter = @import("markdown_formatter.zig");
const test_data = @import("test_data.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("=== Changelog Generator Integration Test ===\n\n", .{});

    // Parse mock releases
    std.debug.print("Parsing mock releases...\n", .{});
    var releases_parsed = try std.json.parseFromSlice(
        []models.Release,
        allocator,
        test_data.test_releases,
        .{},
    );
    defer releases_parsed.deinit();
    const releases = releases_parsed.value;

    std.debug.print("Found {d} releases\n", .{releases.len});
    for (releases) |release| {
        std.debug.print("  - {s} ({s})\n", .{ release.tag_name, release.published_at });
    }

    // Parse mock PRs
    std.debug.print("\nParsing mock pull requests...\n", .{});
    var prs_parsed = try std.json.parseFromSlice(
        []models.PullRequest,
        allocator,
        test_data.test_pull_requests,
        .{},
    );
    defer prs_parsed.deinit();
    const prs = prs_parsed.value;

    std.debug.print("Found {d} pull requests\n", .{prs.len});
    for (prs) |pr| {
        std.debug.print("  - #{d}: {s} by @{s}\n", .{ pr.number, pr.title, pr.user.login });
        for (pr.labels) |label| {
            std.debug.print("      Label: {s}\n", .{label.name});
        }
    }

    // Generate changelog
    std.debug.print("\nGenerating changelog...\n", .{});
    var gen = changelog_generator.ChangelogGenerator.init(allocator, null);
    const changelog = try gen.generate(releases, prs);
    defer gen.deinit(changelog);

    std.debug.print("Generated {d} releases in changelog\n", .{changelog.len});
    for (changelog) |rel| {
        std.debug.print("  Release {s}: {d} sections\n", .{ rel.version, rel.sections.len });
        for (rel.sections) |sec| {
            std.debug.print("    - {s}: {d} entries\n", .{ sec.name, sec.entries.len });
        }
    }

    // Format to Markdown
    std.debug.print("\nFormatting to Markdown...\n", .{});
    var formatter = markdown_formatter.MarkdownFormatter.init(allocator);
    const markdown = try formatter.format(changelog);
    defer formatter.deinit(markdown);

    // Write to test file
    const output_path = "CHANGELOG_TEST.md";
    try formatter.writeToFile(output_path, markdown);
    std.debug.print("Wrote changelog to {s}\n\n", .{output_path});

    // Print sample of the output
    std.debug.print("=== Sample Output (first 500 chars) ===\n", .{});
    const sample_len = @min(500, markdown.len);
    std.debug.print("{s}\n", .{markdown[0..sample_len]});
    if (markdown.len > sample_len) {
        std.debug.print("... (truncated, total {d} bytes)\n", .{markdown.len});
    }

    std.debug.print("\n✅ Integration test completed successfully!\n", .{});
}
