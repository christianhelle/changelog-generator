const std = @import("std");

// Mock test data for integration testing
pub const test_releases = 
    \\[
    \\  {
    \\    "tag_name": "v1.2.0",
    \\    "name": "Release v1.2.0",
    \\    "published_at": "2024-01-15T10:30:00Z"
    \\  },
    \\  {
    \\    "tag_name": "v1.1.0",
    \\    "name": "Release v1.1.0",
    \\    "published_at": "2024-01-10T08:15:00Z"
    \\  }
    \\]
;

pub const test_pull_requests = 
    \\[
    \\  {
    \\    "number": 123,
    \\    "title": "Add new feature X",
    \\    "body": "This PR adds feature X",
    \\    "html_url": "https://github.com/owner/repo/pull/123",
    \\    "user": {
    \\      "login": "alice",
    \\      "html_url": "https://github.com/alice"
    \\    },
    \\    "labels": [
    \\      {
    \\        "name": "feature",
    \\        "color": "0366d6"
    \\      }
    \\    ],
    \\    "merged_at": "2024-01-14T12:00:00Z"
    \\  },
    \\  {
    \\    "number": 124,
    \\    "title": "Fix critical bug",
    \\    "body": "This fixes bug in module X",
    \\    "html_url": "https://github.com/owner/repo/pull/124",
    \\    "user": {
    \\      "login": "bob",
    \\      "html_url": "https://github.com/bob"
    \\    },
    \\    "labels": [
    \\      {
    \\        "name": "bug",
    \\        "color": "d73a4a"
    \\      }
    \\    ],
    \\    "merged_at": "2024-01-12T10:00:00Z"
    \\  },
    \\  {
    \\    "number": 125,
    \\    "title": "Update documentation",
    \\    "body": "Documentation updates",
    \\    "html_url": "https://github.com/owner/repo/pull/125",
    \\    "user": {
    \\      "login": "charlie",
    \\      "html_url": "https://github.com/charlie"
    \\    },
    \\    "labels": [],
    \\    "merged_at": "2024-01-11T14:00:00Z"
    \\  }
    \\]
;
