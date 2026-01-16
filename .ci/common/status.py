#!/usr/bin/env python3

# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Description: Sends CI/CD build status to Forgejo commit

import os
import requests
import sys
import argparse

# --- Required Forgejo environment variables ---
FORGEJO_HOST = os.getenv("FORGEJO_HOST", "git.eden-emu.dev")
FORGEJO_REPO = os.getenv("FORGEJO_REPO")
FORGEJO_REF = os.getenv("FORGEJO_REF")
FORGEJO_TOKEN = os.getenv("FORGEJO_TOKEN")
FORGEJO_TOKEN_INVALID_STATUS = os.getenv("FORGEJO_TOKEN_INVALID_STATUS", "")

# --- GitHub Actions environment for workflow URL ---
GITHUB_SERVER_URL = os.getenv("GITHUB_SERVER_URL", "https://github.com")
GITHUB_REPOSITORY = os.getenv("GITHUB_REPOSITORY")
GITHUB_RUN_ID = os.getenv("GITHUB_RUN_ID")
GITHUB_RUN_ATTEMPT = os.getenv("GITHUB_RUN_ATTEMPT", "1")

def build_workflow_url():
    """Construct workflow run URL from GitHub Actions env."""
    if GITHUB_REPOSITORY and GITHUB_RUN_ID:
        return f"{GITHUB_SERVER_URL}/{GITHUB_REPOSITORY}/actions/runs/{GITHUB_RUN_ID}/attempts/{GITHUB_RUN_ATTEMPT}"
    return None

WORKFLOW_URL = build_workflow_url()

# --- Validate token ---
def is_token_valid():
    """Check if Forgejo token is valid before sending requests."""
    if not FORGEJO_TOKEN:
        print("[ERROR] FORGEJO_TOKEN not set, skipping requests.")
        return False
    if FORGEJO_TOKEN == FORGEJO_TOKEN_INVALID_STATUS:
        print("[ERROR] FORGEJO_TOKEN previously marked invalid, skipping requests.")
        return False
    return True

# --- Send commit status ---
def send_commit_status(state: str, release_url: str | None = None):
    """Send build status to the last commit of the PR."""
    if not is_token_valid():
        return
    if not (FORGEJO_REPO and FORGEJO_REF and FORGEJO_TOKEN):
        print("[ERROR] Missing repository or commit info, cannot send commit status.")
        return
    if not WORKFLOW_URL:
        print("[ERROR] Missing GITHUB_RUN_ID, cannot build workflow link, skipping status.")
        return

    api_url = f"https://{FORGEJO_HOST}/api/v1/repos/{FORGEJO_REPO}/statuses/{FORGEJO_REF}"

    description_mapping = {
        "release": "Build succeeded – Release published",
        "pending": "Build started",
        "success": "Build succeeded",
        "failure": "Build failed",
        "error": "Build cancelled",
        "cancelled": "Build cancelled"
        # <https://forgejo.your.host/api/swagger#/repository/repoListStatusesByRef>
        # TODO: Add Warning (forgejo only)
        #"warning: "???""
    }

    if state not in description_mapping:
        print(f"[ERROR] Unknown state '{state}', skipping commit status.")
        return
    if state == "release" and not release_url:
        print("[ERROR] Missing release_url, skipping commit status.")
        return
    # TODO: Make it only when from Github -> Forgejo
    # DraVee: Forgejo dont have cancelled, switch to error
    if state == "cancelled":
        state = "error"
    if state == "release" and release_url:
        target_state = "success"
        target_url = release_url
        target_description = "[CD]"
        target_context = "Releases"
    else:
        target_state = state
        target_url = WORKFLOW_URL
        target_description = "[CI]"
        target_context = "Actions"

    data = {
        "state": target_state,
        "target_url": target_url,
        "description": f"{target_description} {description_mapping[state]}",
        "context": f"GitHub {target_context}"
    }

    headers = {"Authorization": f"token {FORGEJO_TOKEN}", "Content-Type": "application/json"}

    try:
        r = requests.post(api_url, headers=headers, json=data, timeout=10)
        if r.status_code not in (200, 201):
            print(f"[WARN] Failed to send commit status: HTTP {r.status_code} -> {r.text}")
            if r.status_code == 401:
                print("[INFO] Token unauthorized, skipping further requests.")
        else:
            print(f"[INFO] Commit status sent successfully ({data['context']}): {target_state}")
            if state == "release" and release_url:
                print(f"[INFO] Target URL: {target_url}")
    except Exception as e:
        print(f"[ERROR] Exception while sending commit status: {e}")

def is_truthy(value):
    if value is None:
        return False
    return str(value).lower() in ("1", "true", "yes", "on")

def parse_args():
    parser = argparse.ArgumentParser(description="Send commit status to the repository")
    parser.add_argument("--pending", metavar="BOOL")
    parser.add_argument("--success", metavar="BOOL")
    parser.add_argument("--failure", metavar="BOOL")
    parser.add_argument("--cancelled", metavar="BOOL")
    parser.add_argument("--error", metavar="BOOL")
    # <https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#needs-context>
    # TODO: Add skipped (github only)
    #parser.add_argument("--skipped", metavar="BOOL")
    parser.add_argument("--release", metavar="URL", help="Set commit status to release with URL")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    if args.release:
        return "release", args.release

    flags = {
        "pending": is_truthy(args.pending),
        "success": is_truthy(args.success),
        "failure": is_truthy(args.failure),
        "error": is_truthy(args.error),
        "cancelled": is_truthy(args.cancelled),
    }

    if flags["failure"]:
        return "failure", None
    if flags["cancelled"]:
        return "cancelled", None
    if flags["error"]:
        return "error", None
    if flags["pending"]:
        return "pending", None
    if flags["success"] and not any(flags[k] for k in ("pending", "failure", "cancelled", "error")):
        return "success", None

    parser.print_help()
    sys.exit(0)

if __name__ == "__main__":
    state, release_url = parse_args()
    send_commit_status(state, release_url)

