#!/usr/bin/env python3
"""Resolve the next stable three-part SemVer for a GitHub Release."""

from __future__ import annotations

import argparse
import re
import sys
import unittest
from dataclasses import dataclass


_SEMVER = re.compile(r"^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")


@dataclass(frozen=True, order=True)
class Version:
    major: int
    minor: int
    patch: int

    @classmethod
    def parse(cls, value: str) -> "Version":
        match = _SEMVER.fullmatch(value.strip())
        if match is None:
            raise ValueError(f"invalid stable SemVer: {value}")
        return cls(*(int(part) for part in match.groups()))

    def next_patch(self) -> "Version":
        return Version(self.major, self.minor, self.patch + 1)

    def __str__(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}"


def resolve_next(latest: str | None, minimum: str) -> Version:
    floor = Version.parse(minimum)
    if latest is None or not latest.strip():
        return floor
    current = Version.parse(latest)
    return floor if current < floor else current.next_patch()


class VersionTests(unittest.TestCase):
    def test_no_release_uses_minimum(self) -> None:
        self.assertEqual(str(resolve_next(None, "0.1.11")), "0.1.11")

    def test_below_minimum_uses_minimum(self) -> None:
        self.assertEqual(str(resolve_next("v0.1.9", "0.1.11")), "0.1.11")

    def test_increments_patch(self) -> None:
        self.assertEqual(str(resolve_next("v0.1.11", "0.1.11")), "0.1.12")

    def test_rejects_prerelease_and_invalid_tags(self) -> None:
        for value in ("v1.2.3-beta", "1.2.3.4", "01.2.3", "latest"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                Version.parse(value)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--latest")
    parser.add_argument("--minimum", default="0.1.11")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(VersionTests)
        return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1
    try:
        print(resolve_next(args.latest, args.minimum))
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
