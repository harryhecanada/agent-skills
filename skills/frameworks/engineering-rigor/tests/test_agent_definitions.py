import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
AGENTS_DIR = REPO_ROOT / "agents"


def parse_frontmatter(content: str) -> dict:
    assert content.startswith("---"), "Missing frontmatter delimiter"
    parts = content.split("---", 2)
    assert len(parts) >= 3, "Invalid frontmatter structure"
    data = {}
    for line in parts[1].strip().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" in line:
            key, val = line.split(":", 1)
            data[key.strip()] = val.strip()
    return data


class TestAgentBriefs(unittest.TestCase):
    """agents/ holds brief templates, not registrations — they must be usable on any agent."""

    def test_briefs_exist_with_usable_frontmatter(self):
        briefs = sorted(AGENTS_DIR.glob("*.md"))
        self.assertGreaterEqual(len(briefs), 2, f"expected >= 2 briefs, found {len(briefs)}")
        for brief in briefs:
            fm = parse_frontmatter(brief.read_text(encoding="utf-8"))
            self.assertIn("name", fm, f"{brief.name} missing 'name'")
            self.assertIn("description", fm, f"{brief.name} missing 'description'")
            self.assertGreater(
                len(fm["description"]), 40, f"{brief.name} description is too thin to trigger"
            )

    def test_frontmatter_stays_portable(self):
        """A brief carries neutral metadata only: name, description, and optionally a version."""
        allowed = {"name", "description", "version"}
        for brief in sorted(AGENTS_DIR.glob("*.md")):
            fm = parse_frontmatter(brief.read_text(encoding="utf-8"))
            extra = set(fm) - allowed
            self.assertFalse(
                extra, f"{brief.name} carries non-portable frontmatter keys: {sorted(extra)}"
            )

    def test_delegate_brief_carries_the_contract(self):
        content = (AGENTS_DIR / "poteto-agent.md").read_text(encoding="utf-8")
        self.assertIn("TOOLS.md", content)
        self.assertIn("skills/poteto-mode/SKILL.md", content)
        self.assertIn("exactly one result", content)
        self.assertIn("Verify against the real artifact", content)
        self.assertIn("cannot spawn further subagents", content)


if __name__ == "__main__":
    unittest.main()
