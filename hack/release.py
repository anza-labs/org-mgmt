#!/usr/bin/env python3

import os
import shutil
import subprocess
import argparse
import json
import sys

# --- ANSI Color Codes ---
class Colors:
    RESET = '\033[0m'
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    RED = '\033[91m'
    BOLD = '\033[1m'

CLONE_DIR_PARENT = "tmp"
CLONE_DIR_REPOS = os.path.join(CLONE_DIR_PARENT, "repos")

# --- Helper Print Functions ---
def print_dry_run(message, command=""):
    if command:
        print(f"{Colors.YELLOW}[DRY RUN]{Colors.RESET} {message} {Colors.CYAN}{command}{Colors.RESET}")
    else:
        print(f"{Colors.YELLOW}[DRY RUN]{Colors.RESET} {message}")

def print_error(message):
    print(f"{Colors.RED}Error: {message}{Colors.RESET}")

def print_success(message):
    print(f"{Colors.GREEN}{message}{Colors.RESET}")

def print_info(message):
    print(message)

# --- Subprocess Helpers ---
def run_streamed(cmd, cwd=None):
    """Run subprocess while streaming stdout/stderr to console in real time."""
    process = subprocess.Popen(
        cmd,
        cwd=cwd,
        stdout=sys.stdout,
        stderr=sys.stderr,
        text=True
    )
    process.communicate()
    return process.returncode

# --- Core Logic Functions ---
def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Clones GitHub repositories, ensures release branches, and runs 'make release' if tag is missing."
    )
    parser.add_argument("--repos-file", type=str, required=True)
    parser.add_argument(
        "--dry-run",
        type=str,
        nargs='?',
        const="gh,git,make",
        default=None,
        help="Specify dry-run components: gh, git, make"
    )
    return parser.parse_args()

def load_repos_from_json(file_path):
    try:
        with open(file_path, 'r') as f:
            repos = json.load(f)
            if not isinstance(repos, dict):
                print_error(f"JSON file {file_path} must contain a dictionary.")
                return None
            return repos
    except Exception as e:
        print_error(f"Failed to load {file_path}: {e}")
        return None

def setup_clone_directory(is_dry_run_filesystem):
    if os.path.exists(CLONE_DIR_REPOS):
        print_info(f"Removing existing directory: {CLONE_DIR_REPOS}")
        if not is_dry_run_filesystem:
            shutil.rmtree(CLONE_DIR_REPOS)
            print_success(f"Successfully removed {CLONE_DIR_REPOS}")
        else:
            print_dry_run(f"Would remove directory: {CLONE_DIR_REPOS}")

    print_info(f"Ensuring clone directory {CLONE_DIR_REPOS} exists.")
    if not is_dry_run_filesystem:
        os.makedirs(CLONE_DIR_REPOS, exist_ok=True)
        print_success(f"Clone directory {CLONE_DIR_REPOS} is ready.")
    else:
        print_dry_run(f"Would create directory: {CLONE_DIR_REPOS}")

def clone_repository(repo_url, destination_path, repo_name, is_dry_run_gh, original_cwd):
    clone_command_list = ["gh", "repo", "clone", repo_url, destination_path]
    if not is_dry_run_gh:
        print_info(f"Executing: {' '.join(clone_command_list)}")
        try:
            rc = run_streamed(clone_command_list, cwd=original_cwd)
            if rc == 0:
                print_success(f"Successfully cloned {repo_name}.")
                return True
            else:
                print_error(f"Failed to clone {repo_name}, return code {rc}")
                return False
        except FileNotFoundError:
            print_error("'gh' command not found. Please install GitHub CLI.")
            sys.exit(1)
    else:
        print_dry_run("Would execute 'gh repo clone' command:", ' '.join(clone_command_list))
        return True

def ensure_specific_release_branch_local(repo_path, repo_name, major_minor_str, is_dry_run_git, original_cwd):
    target_local_branch_name = f"release-{major_minor_str}"
    target_remote_ref = f"remotes/origin/{target_local_branch_name}"

    print_info(f"Ensuring local branch '{target_local_branch_name}' in {repo_name}...")
    if is_dry_run_git:
        print_dry_run(f"Would check and create branch {target_local_branch_name} tracking {target_remote_ref}")
        return

    try:
        result = subprocess.run(["git", "branch", "-a"], cwd=repo_path, stdout=subprocess.PIPE, text=True, check=True)
        if target_remote_ref not in result.stdout:
            print_info(f"Remote branch {target_remote_ref} not found.")
            return

        local_branches = subprocess.run(["git", "branch"], cwd=repo_path, stdout=subprocess.PIPE, text=True, check=True)
        if target_local_branch_name in local_branches.stdout:
            print_info(f"Local branch '{target_local_branch_name}' already exists.")
        else:
            print_info(f"Creating local branch '{target_local_branch_name}'...")
            run_streamed(["git", "branch", target_local_branch_name, target_remote_ref], cwd=repo_path)
    except Exception as e:
        print_error(f"Failed branch setup in {repo_name}: {e}")

def check_git_tag_exists(tag_name, repo_path, is_dry_run_git):
    git_tag_command = ["git", "tag", "-l", tag_name]
    if is_dry_run_git:
        print_dry_run(f"Would check for git tag {tag_name}")
        return False
    try:
        result = subprocess.run(git_tag_command, cwd=repo_path, stdout=subprocess.PIPE, text=True, check=True)
        return result.stdout.strip() == tag_name
    except Exception:
        return False

def run_make_release(destination_path, version_tag, repo_name, is_dry_run_git, is_dry_run_make, original_cwd):
    tag_exists = check_git_tag_exists(version_tag, destination_path, is_dry_run_git)

    if tag_exists and not is_dry_run_git:
        print_info(f"Tag {version_tag} exists. Skipping make.")
        return

    make_cmd = ["make", "release", f"VERSION={version_tag}"]
    if is_dry_run_make:
        print_dry_run(f"Would run {' '.join(make_cmd)} in {destination_path}")
        return

    print_info(f"Executing make in {destination_path}...")
    rc = run_streamed(make_cmd, cwd=destination_path)
    if rc == 0:
        print_success(f"'make release' completed for {repo_name}.")
    else:
        print_error(f"'make release' failed for {repo_name} with code {rc}")

def process_repositories(repos, is_dry_run_gh, is_dry_run_git, is_dry_run_make):
    print_info("\nStarting repository processing...")
    cwd = os.getcwd()

    for repo_name, version_tag in repos.items():
        repo_url = f"{repo_name}"
        destination_path = os.path.abspath(os.path.join(CLONE_DIR_REPOS, repo_name))

        print_info(f"\nProcessing {Colors.BOLD}{repo_name}{Colors.RESET} ({version_tag})...")
        clone_success = clone_repository(repo_url, destination_path, repo_name, is_dry_run_gh, cwd)

        if clone_success:
            parts = version_tag.lstrip('v').split('.')
            if len(parts) >= 2:
                major_minor = f"{parts[0]}.{parts[1]}"
                ensure_specific_release_branch_local(destination_path, repo_name, major_minor, is_dry_run_git, cwd)

            run_make_release(destination_path, version_tag, repo_name, is_dry_run_git, is_dry_run_make, cwd)

    print_info("\nScript finished.")

def main():
    args = parse_arguments()

    is_dry_run_gh = is_dry_run_git = is_dry_run_make = is_dry_run_filesystem = False

    if args.dry_run:
        comps = set(c.strip().lower() for c in args.dry_run.split(',') if c.strip())
        if 'gh' in comps:
            is_dry_run_gh = is_dry_run_git = is_dry_run_make = is_dry_run_filesystem = True
        elif 'git' in comps:
            is_dry_run_git = is_dry_run_make = True
        elif 'make' in comps:
            is_dry_run_make = True

        print_info(f"{Colors.BOLD}{Colors.YELLOW}--- DRY RUN MODE ENABLED ---{Colors.RESET}")

    repos = load_repos_from_json(args.repos_file)
    if not repos:
        print_error("No repositories to process.")
        sys.exit(1)
    print_success(f"Loaded {len(repos)} repositories from {args.repos_file}.")

    setup_clone_directory(is_dry_run_filesystem)
    process_repositories(repos, is_dry_run_gh, is_dry_run_git, is_dry_run_make)

if __name__ == "__main__":
    main()
