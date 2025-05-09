#!/usr/bin/env python3

import os
import shutil
import subprocess
import argparse # For command-line arguments
import json     # For reading JSON file
import sys      # For sys.exit
import re       # For regular expression matching (though less used now for branches)

# --- ANSI Color Codes ---
class Colors:
    """ANSI color codes for terminal output."""
    RESET = '\033[0m'
    YELLOW = '\033[93m' # Bright Yellow
    CYAN = '\033[96m'   # Bright Cyan
    GREEN = '\033[92m'  # Bright Green
    RED = '\033[91m'    # Bright Red
    BOLD = '\033[1m'

# Define the target directory for cloning
CLONE_DIR_PARENT = "tmp"
CLONE_DIR_REPOS = os.path.join(CLONE_DIR_PARENT, "repos")

# --- Helper Print Functions ---
def print_dry_run(message, command=""):
    """Helper function to print dry run messages with color."""
    if command:
        print(f"{Colors.YELLOW}[DRY RUN]{Colors.RESET} {message} {Colors.CYAN}{command}{Colors.RESET}")
    else:
        print(f"{Colors.YELLOW}[DRY RUN]{Colors.RESET} {message}")

def print_error(message):
    """Helper function to print error messages with color."""
    print(f"{Colors.RED}Error: {message}{Colors.RESET}")

def print_success(message):
    """Helper function to print success messages with color."""
    print(f"{Colors.GREEN}{message}{Colors.RESET}")

def print_info(message):
    """Helper function to print general info messages."""
    print(message)

# --- Core Logic Functions ---

def parse_arguments():
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Clones GitHub repositories, ensures specific local release branches (release-MAJOR.MINOR), "
                    "and runs 'make release' if the version tag from repos.json doesn't exist. "
                    "Offers granular dry-run capabilities."
    )
    parser.add_argument(
        "--repos-file",
        type=str,
        required=True,
        help="Path to a JSON file containing repositories and their versions (e.g., vMAJOR.MINOR.PATCH). (Required)"
    )
    parser.add_argument(
        "--org",
        type=str,
        default="github.com/anza-labs",
        help="GitHub organization or user (e.g., github.com/your-org). Default: github.com/anza-labs"
    )
    parser.add_argument(
        "--dry-run",
        type=str,
        nargs='?',
        const="gh,git,make",
        default=None,
        help="Specify components for dry run (gh, git, make), comma-separated. "
             "If flag is present without a value, all components (gh,git,make) are dry-run. "
             "Dependencies are enforced: gh implies git and make; git implies make."
    )
    return parser.parse_args()

def load_repos_from_json(file_path):
    """Loads repository data from a JSON file."""
    try:
        with open(file_path, 'r') as f:
            repos = json.load(f)
            if not isinstance(repos, dict):
                print_error(f"JSON file {file_path} must contain a dictionary (object).")
                return None
            for key, value in repos.items():
                if not isinstance(key, str) or not isinstance(value, str):
                    print_error(f"Invalid entry in {file_path}: ('{key}': '{value}'). Both key and value must be strings.")
                    return None
            return repos
    except FileNotFoundError:
        print_error(f"Repository JSON file not found: {file_path}")
        return None
    except json.JSONDecodeError:
        print_error(f"Invalid JSON format in file: {file_path}")
        return None
    except Exception as e:
        print_error(f"An unexpected error occurred while reading {file_path}: {e}")
        return None

def setup_clone_directory(is_dry_run_filesystem):
    """Removes existing clone directory and creates a new one."""
    if os.path.exists(CLONE_DIR_REPOS):
        print_info(f"Removing existing directory: {CLONE_DIR_REPOS}")
        if not is_dry_run_filesystem:
            try:
                shutil.rmtree(CLONE_DIR_REPOS)
                print_success(f"Successfully removed {CLONE_DIR_REPOS}")
            except OSError as e:
                print_error(f"Failed to remove directory {CLONE_DIR_REPOS}. Reason: {e.strerror}")
                sys.exit(1)
        else:
            print_dry_run(f"Would remove directory: {CLONE_DIR_REPOS}")
    else:
        print_info(f"Directory {CLONE_DIR_REPOS} does not exist, no need to remove.")

    try:
        print_info(f"Ensuring clone directory {CLONE_DIR_REPOS} exists.")
        if not is_dry_run_filesystem:
            os.makedirs(CLONE_DIR_REPOS, exist_ok=True)
            print_success(f"Clone directory {CLONE_DIR_REPOS} is ready.")
        else:
            print_dry_run(f"Would create directory: {CLONE_DIR_REPOS}")
    except OSError as e:
        print_error(f"Failed to create directory {CLONE_DIR_REPOS}. Reason: {e.strerror}")
        sys.exit(1)

def clone_repository(repo_url, destination_path, repo_name, is_dry_run_gh, original_cwd):
    """Clones a single repository."""
    clone_command_list = ["gh", "repo", "clone", repo_url, destination_path]
    clone_command_str = ' '.join(clone_command_list)

    if not is_dry_run_gh:
        print_info(f"Executing: {clone_command_str}")
        try:
            result = subprocess.run(clone_command_list, capture_output=True, text=True, check=True, cwd=original_cwd)
            print_success(f"Successfully cloned {repo_name}.")
            if result.stdout:
                print_info("Clone Output:\n" + result.stdout.strip())
            return True
        except FileNotFoundError:
            print_error("'gh' command not found. Please ensure GitHub CLI is installed and in your PATH.")
            print_info("You can install it from https://cli.github.com/")
            sys.exit(1)
        except subprocess.CalledProcessError as e:
            print_error(f"cloning {repo_name}:")
            print_info(f"Command: {' '.join(e.cmd)}")
            print_info(f"Return code: {e.returncode}")
            if e.stdout: print_info("stdout:\n" + e.stdout.strip())
            if e.stderr: print_error("stderr:\n" + e.stderr.strip())
            return False
        except Exception as e:
            print_error(f"An unexpected error occurred while cloning {repo_name}: {e}")
            return False
    else:
        print_dry_run(f"Would execute 'gh repo clone' command:", clone_command_str)
        return True

def ensure_specific_release_branch_local(repo_path, repo_name, major_minor_str, is_dry_run_git, original_cwd):
    """
    Checks for a specific remote release branch (release-MAJOR.MINOR) and ensures it's available locally.
    'git' operations are dry-run if is_dry_run_git is True.
    """
    target_local_branch_name = f"release-{major_minor_str}"
    # Standard remote name is 'origin'. If this could vary, the logic would need to find the remote name first.
    target_remote_ref_for_creation = f"remotes/origin/{target_local_branch_name}"

    print_info(f"Ensuring local branch '{target_local_branch_name}' exists and tracks remote in {repo_name}...")

    current_dir_for_git_ops = os.getcwd()
    try:
        os.chdir(repo_path)

        git_branch_a_cmd = ["git", "branch", "-a"]
        git_branch_cmd = ["git", "branch"] # For listing local branches

        if is_dry_run_git:
            print_dry_run(f"Would check for remote branch '{target_remote_ref_for_creation}' using 'git branch -a'.")
            print_dry_run(f"Would check for local branch '{target_local_branch_name}' using 'git branch'.")
            print_dry_run(f"If remote exists and local doesn't, would execute: git branch {target_local_branch_name} {target_remote_ref_for_creation}")
            return

        # 1. Get all branches (remote and local)
        try:
            result_branches_a = subprocess.run(git_branch_a_cmd, capture_output=True, text=True, check=True)
            all_branches_lines = result_branches_a.stdout.splitlines()
        except FileNotFoundError:
            print_error("'git' command not found. Please ensure Git is installed and in your PATH.")
            return
        except subprocess.CalledProcessError as e:
            print_error(f"Failed to list all branches for {repo_name}: {e.stderr}")
            return

        # 2. Check if the target remote branch exists
        # We need to be careful with exact matching, as 'git branch -a' might have spaces or '*'
        remote_branch_exists = False
        for line in all_branches_lines:
            # Example line: "  remotes/origin/release-1.2" or "* remotes/origin/HEAD -> origin/main"
            # We are looking for the exact remote ref.
            if target_remote_ref_for_creation == line.strip().lstrip('* '):
                remote_branch_exists = True
                break

        if not remote_branch_exists:
            print_info(f"Target remote branch '{target_remote_ref_for_creation}' not found for {repo_name}. Cannot create local tracking branch.")
            return

        # 3. Get current local branches
        try:
            result_local_branches = subprocess.run(git_branch_cmd, capture_output=True, text=True, check=True)
            local_branches_list = [b.strip().lstrip('* ') for b in result_local_branches.stdout.splitlines()]
        except subprocess.CalledProcessError as e:
            print_error(f"Failed to list local branches for {repo_name}: {e.stderr}")
            return

        # 4. Check if target local branch exists
        if target_local_branch_name in local_branches_list:
            print_info(f"Local branch '{target_local_branch_name}' already exists in {repo_name}.")
        else:
            # 5. Create local branch tracking the remote one
            print_info(f"Remote branch '{target_remote_ref_for_creation}' found. Local branch '{target_local_branch_name}' does not exist.")
            create_local_branch_cmd = ["git", "branch", target_local_branch_name, target_remote_ref_for_creation]
            print_info(f"Creating local branch '{target_local_branch_name}' to track '{target_remote_ref_for_creation}'...")
            try:
                subprocess.run(create_local_branch_cmd, capture_output=True, text=True, check=True)
                print_success(f"Successfully created local branch '{target_local_branch_name}'.")
            except subprocess.CalledProcessError as e:
                print_error(f"Failed to create local branch '{target_local_branch_name}': {e.stderr}")
    finally:
        os.chdir(current_dir_for_git_ops)


def check_git_tag_exists(tag_name, repo_path, is_dry_run_git):
    """Checks if a git tag exists. 'git' operations are dry-run if is_dry_run_git is True."""
    git_tag_command = ["git", "tag", "-l", tag_name]

    if is_dry_run_git:
        print_dry_run(f"Would check for git tag '{tag_name}' in {repo_path} using command:", ' '.join(git_tag_command))
        return False

    try:
        result = subprocess.run(git_tag_command, capture_output=True, text=True, check=True, cwd=repo_path)
        return result.stdout.strip() == tag_name
    except FileNotFoundError:
        print_error("'git' command not found. Please ensure Git is installed and in your PATH.")
        return False
    except subprocess.CalledProcessError:
        print_info(f"Could not verify git tag {tag_name} in {repo_path} (may not be a git repo or other git error).")
        return False
    except Exception as e:
        print_error(f"An unexpected error occurred while checking git tag {tag_name} in {repo_path}: {e}")
        return False

def run_make_release(destination_path, version_tag, repo_name, is_dry_run_git, is_dry_run_make, original_cwd):
    """
    Checks if a version tag exists (honoring is_dry_run_git).
    If not, runs 'make release' (honoring is_dry_run_make).
    """
    if not os.path.isdir(destination_path):
        if not (is_dry_run_git or is_dry_run_make):
            print_error(f"Repository directory {destination_path} not found. Skipping 'make release' for {repo_name}.")
            return
        else:
            print_dry_run(f"Directory {destination_path} assumed to exist for dry run of git/make checks.")

    current_dir_for_tag_check = os.getcwd()
    tag_actually_exists = False
    try:
        if os.path.isdir(destination_path):
             os.chdir(destination_path)
             tag_actually_exists = check_git_tag_exists(version_tag, ".", is_dry_run_git)
        elif is_dry_run_git:
             tag_actually_exists = check_git_tag_exists(version_tag, destination_path, is_dry_run_git)
    finally:
        os.chdir(current_dir_for_tag_check)

    if tag_actually_exists and not is_dry_run_git:
        print_info(f"Tag '{version_tag}' already exists in {repo_name}. Skipping 'make release'.")
        return

    make_command_str = f"make release VERSION={version_tag}"

    if is_dry_run_make:
        if not is_dry_run_git and not tag_actually_exists:
             print_info(f"Tag '{version_tag}' not found in {repo_name}.")
        # If is_dry_run_git was true, check_git_tag_exists already printed its dry run message.
        print_dry_run(f"In directory {destination_path}, would execute make command:", make_command_str)
        return

    if not is_dry_run_git and not tag_actually_exists:
        print_info(f"Tag '{version_tag}' not found in {repo_name}. Proceeding with 'make release'.")
    elif is_dry_run_git:
        print_info(f"Git operations were dry-run (tag '{version_tag}' assumed not to exist). Proceeding with actual 'make release'.")

    print_info(f"Preparing to run in {destination_path}: {make_command_str}")
    try:
        print_info(f"Changing working directory to: {destination_path}")
        os.chdir(destination_path)

        print_info(f"Executing: {make_command_str}")
        make_result = subprocess.run(["make", "release", f"VERSION={version_tag}"], capture_output=True, text=True, check=True)
        print_success(f"'make release' completed successfully for {repo_name}.")
        if make_result.stdout: print_info("Make Output:\n" + make_result.stdout.strip())
        if make_result.stderr: print_info("Make Stderr (if any):\n" + make_result.stderr.strip())
    except FileNotFoundError:
        print_error(f"'make' command not found in {destination_path} or PATH, or directory issue.")
    except subprocess.CalledProcessError as e:
        print_error(f"running 'make release' for {repo_name}:")
        print_info(f"Command: {' '.join(e.cmd)}")
        print_info(f"Return code: {e.returncode}")
        if e.stdout: print_info("stdout:\n" + e.stdout.strip())
        if e.stderr: print_error("stderr:\n" + e.stderr.strip())
    except Exception as e:
        print_error(f"An unexpected error occurred during 'make release' for {repo_name}: {e}")
    finally:
        print_info(f"Changing working directory back to: {original_cwd}")
        os.chdir(original_cwd)

def process_repositories(repos_to_process, org, is_dry_run_gh, is_dry_run_git, is_dry_run_make):
    """Clones, ensures local release branches, and runs make for each repository."""
    print_info("\nStarting repository processing...")
    original_cwd_for_processing = os.getcwd()

    for repo_name, version_tag_from_json in repos_to_process.items(): # Renamed for clarity
        repo_url = f"{org}/{repo_name}"
        destination_path = os.path.abspath(os.path.join(CLONE_DIR_REPOS, repo_name))

        print_info(f"\nProcessing {Colors.BOLD}{repo_name}{Colors.RESET} (version from JSON: {version_tag_from_json})...")
        print_info(f"Repository URL: {repo_url}")
        print_info(f"Target clone path: {destination_path}")

        clone_success = clone_repository(repo_url, destination_path, repo_name, is_dry_run_gh, original_cwd_for_processing)

        if clone_success:
            # Parse version_tag_from_json to get MAJOR.MINOR for branch checking
            parsed_version = version_tag_from_json.lstrip('v')
            parts = parsed_version.split('.')
            major_minor_str = None
            if len(parts) >= 2:
                major_minor_str = f"{parts[0]}.{parts[1]}"

            if major_minor_str:
                if os.path.isdir(destination_path) or is_dry_run_git:
                     ensure_specific_release_branch_local(destination_path, repo_name, major_minor_str, is_dry_run_git, original_cwd_for_processing)
                elif not is_dry_run_gh:
                     print_error(f"Cloned directory {destination_path} not found. Skipping release branch check for {repo_name}.")
            else:
                print_info(f"Version tag '{version_tag_from_json}' for {repo_name} does not have a clear MAJOR.MINOR structure. Skipping release branch check.")

            # Proceed to make release using the original version_tag_from_json for the VERSION argument
            run_make_release(destination_path, version_tag_from_json, repo_name, is_dry_run_git, is_dry_run_make, original_cwd_for_processing)
        else:
            if not is_dry_run_gh :
                 print_info(f"Skipping subsequent steps for {repo_name} due to cloning issues.")
    print_info("\nScript finished.")

def main():
    """
    Main orchestrator function.
    """
    args = parse_arguments()

    is_dry_run_gh = False
    is_dry_run_git = False
    is_dry_run_make = False
    is_dry_run_filesystem = False

    if args.dry_run is not None:
        dry_run_specified_components = set(c.strip().lower() for c in args.dry_run.split(',') if c.strip())
        valid_components = {"gh", "git", "make"}
        for comp in dry_run_specified_components:
            if comp not in valid_components:
                print_error(f"Invalid dry-run component specified: '{comp}'. Valid components are: {', '.join(valid_components)}")
                sys.exit(1)

        if 'gh' in dry_run_specified_components: is_dry_run_gh = True
        if 'git' in dry_run_specified_components: is_dry_run_git = True
        if 'make' in dry_run_specified_components: is_dry_run_make = True

        if is_dry_run_gh:
            is_dry_run_git = True
            is_dry_run_make = True
            is_dry_run_filesystem = True
        elif is_dry_run_git:
            is_dry_run_make = True

    any_dry_run_active = is_dry_run_gh or is_dry_run_git or is_dry_run_make
    if any_dry_run_active:
        display_list = []
        if is_dry_run_gh: display_list.append("gh (implies git, make, filesystem)")
        elif is_dry_run_git: display_list.append("git (implies make)")
        elif is_dry_run_make: display_list.append("make")

        if not display_list and is_dry_run_filesystem : display_list.append("filesystem (implicitly with gh)")
        print_info(f"{Colors.BOLD}{Colors.YELLOW}--- DRY RUN MODE ENABLED for: {', '.join(display_list)} ---{Colors.RESET}")

    print_info(f"Using organization: {args.org}")

    repos_to_process = load_repos_from_json(args.repos_file)
    if repos_to_process is None:
        print_error(f"Failed to load repositories from {args.repos_file}. Exiting.")
        sys.exit(1)
    if not repos_to_process:
        print_error(f"No repositories found in {args.repos_file}. Exiting.")
        sys.exit(1)
    print_success(f"Successfully loaded {len(repos_to_process)} repositories from {args.repos_file}.")

    setup_clone_directory(is_dry_run_filesystem)
    process_repositories(repos_to_process, args.org, is_dry_run_gh, is_dry_run_git, is_dry_run_make)

if __name__ == "__main__":
    main()
