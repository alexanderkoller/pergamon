#!/opt/homebrew/bin/fish

# typst-publish.fish
# A guided workflow for publishing Typst packages to the Universe

# ─────────────────────────────────────────────────────────────────────────────
# Global flags
# ─────────────────────────────────────────────────────────────────────────────

set -g DRY_RUN false
set -g PACKAGES_DIR /tmp/packages

# ─────────────────────────────────────────────────────────────────────────────
# Colors and styling
# ─────────────────────────────────────────────────────────────────────────────

set -g C_RESET (set_color normal)
set -g C_BOLD (set_color --bold)
set -g C_DIM (set_color --dim)
set -g C_CYAN (set_color cyan)
set -g C_GREEN (set_color green)
set -g C_YELLOW (set_color yellow)
set -g C_RED (set_color red)
set -g C_MAGENTA (set_color magenta)

# ─────────────────────────────────────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────────────────────────────────────

function print_header
    echo
    echo {$C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{$C_RESET}
    echo {$C_BOLD}{$C_CYAN}"  $argv"{$C_RESET}
    echo {$C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{$C_RESET}
    echo
end

function print_step
    echo {$C_MAGENTA}▸{$C_RESET} {$C_BOLD}"$argv"{$C_RESET}
end

function print_success
    echo {$C_GREEN}✓{$C_RESET} "$argv"
end

function print_error
    echo {$C_RED}✗{$C_RESET} "$argv"
end

function print_info
    echo {$C_DIM}"  $argv"{$C_RESET}
end

function print_warning
    echo {$C_YELLOW}⚠{$C_RESET} "$argv"
end

function print_dry
    echo {$C_YELLOW}"[DRY RUN]"{$C_RESET} {$C_DIM}"$argv"{$C_RESET}
end

function run_cmd
    # Runs a command, or prints it in dry-run mode
    if test "$DRY_RUN" = true
        print_dry "$argv"
        return 0
    else
        eval $argv
        return $status
    end
end

function prompt_confirm
    set -l message $argv[1]
    set -l default $argv[2]  # Optional: "y" or "n"

    while true
        # Show prompt with appropriate hint based on default
        if test "$default" = y
            read -P {$C_YELLOW}"?"{$C_RESET}" $message "{$C_DIM}"(Y/n)"{$C_RESET}" " answer
        else if test "$default" = n
            read -P {$C_YELLOW}"?"{$C_RESET}" $message "{$C_DIM}"(y/N)"{$C_RESET}" " answer
        else
            read -P {$C_YELLOW}"?"{$C_RESET}" $message "{$C_DIM}"(y/n)"{$C_RESET}" " answer
        end
        or return 2  # Ctrl-C pressed

        # Handle empty answer with default
        if test -z "$answer" -a -n "$default"
            set answer $default
        end

        switch (string lower $answer)
            case y yes
                return 0
            case n no
                return 1
        end
    end
end

function prompt_input
    set -l message $argv[1]
    set -l default $argv[2]
    if test -n "$default"
        read -P {$C_YELLOW}"?"{$C_RESET}" $message "{$C_DIM}"[$default]"{$C_RESET}" " answer
        or return 2  # Ctrl-C pressed
        if test -z "$answer"
            echo "$default"
        else
            echo "$answer"
        end
    else
        read -P {$C_YELLOW}"?"{$C_RESET}" $message " answer
        or return 2  # Ctrl-C pressed
        echo "$answer"
    end
end

function spinner
    set -l pid $argv[1]
    set -l frames "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"
    while kill -0 $pid 2>/dev/null
        for frame in $frames
            printf "\r%s%s%s " {$C_CYAN} $frame {$C_RESET}
            sleep 0.1
        end
    end
    printf "\r"
end

# ─────────────────────────────────────────────────────────────────────────────
# Core functions
# ─────────────────────────────────────────────────────────────────────────────

function check_prerequisites
    print_step "Checking prerequisites..."
    
    set -l missing
    
    for cmd in git gh
        if not command -q $cmd
            set -a missing $cmd
        end
    end
    
    if test (count $missing) -gt 0
        print_error "Missing required commands: $missing"
        return 1
    end
    
    print_success "All prerequisites found"
    return 0
end

function parse_typst_toml
    set -l toml_path $argv[1]
    
    if not test -f "$toml_path"
        print_error "typst.toml not found at $toml_path"
        return 1
    end
    
    # Extract values from typst.toml
    set -g PKG_NAME (grep '^name' "$toml_path" | sed 's/.*= *"\([^"]*\)".*/\1/')
    set -g PKG_VERSION (grep '^version' "$toml_path" | sed 's/.*= *"\([^"]*\)".*/\1/')
    set -g PKG_DESCRIPTION (grep '^description' "$toml_path" | sed 's/.*= *"\([^"]*\)".*/\1/')
    
    if test -z "$PKG_NAME" -o -z "$PKG_VERSION"
        print_error "Could not parse name or version from typst.toml"
        return 1
    end
    
    return 0
end

function select_package
    print_step "Scanning for packages..."
    
    set -l release_base "./release/preview"
    
    if not test -d "$release_base"
        print_error "No release/preview directory found"
        print_info "Expected structure: ./release/preview/<package-name>/<version>/"
        return 1
    end
    
    # Find all package/version directories
    set -l packages
    set -l package_paths
    
    for pkg_dir in $release_base/*/
        if not test -d "$pkg_dir"
            continue
        end
        set -l pkg_name (basename "$pkg_dir")
        for ver_dir in $pkg_dir/*/
            if not test -d "$ver_dir"
                continue
            end
            if test -f "$ver_dir/typst.toml"
                set -l ver (basename "$ver_dir")
                set -a packages "$pkg_name@$ver"
                set -a package_paths "$ver_dir"
            end
        end
    end

    # Sort packages by version (descending) so newest is first
    if test (count $packages) -gt 1
        # Build "index version" pairs for sorting
        set -l pairs
        for i in (seq (count $packages))
            set -a pairs "$i "(string split '@' $packages[$i])[-1]
        end

        # Sort by version descending and reorder arrays
        set -l sorted_packages
        set -l sorted_paths
        for idx in (printf '%s\n' $pairs | sort -t' ' -k2 -V -r | cut -d' ' -f1)
            set -a sorted_packages $packages[$idx]
            set -a sorted_paths $package_paths[$idx]
        end
        set packages $sorted_packages
        set package_paths $sorted_paths
    end

    if test (count $packages) -eq 0
        print_error "No packages found in $release_base"
        print_info "Expected structure: ./release/preview/<package-name>/<version>/typst.toml"
        return 1
    else if test (count $packages) -eq 1
        set -g PKG_SOURCE_DIR (realpath "$package_paths[1]")
        print_success "Found package: $packages[1]"
    else
        echo
        echo {$C_YELLOW}"?"{$C_RESET}" Select a package to publish: "{$C_DIM}"(↑/↓ to move, Enter to select)"{$C_RESET}
        echo

        set -l selected 1
        set -l num_packages (count $packages)

        # Function to draw the menu
        function _draw_menu -S
            # Move cursor up to redraw (skip on first draw)
            if test $argv[1] = redraw
                printf "\e[%dA" $num_packages
            end

            set -l i 1
            for pkg in $packages
                if test $i -eq $selected
                    echo "  "{$C_CYAN}"▸"{$C_RESET}" "{$C_BOLD}$pkg{$C_RESET}
                else
                    echo "    "{$C_DIM}$pkg{$C_RESET}
                end
                set i (math $i + 1)
            end
        end

        # Initial draw
        _draw_menu first

        # Save terminal state and switch to raw mode
        set -l saved_stty (stty -g)
        stty raw -echo

        # Read arrow keys and enter
        while true
            # Read a single character
            set -l key (dd bs=1 count=1 2>/dev/null)

            if test "$key" = \r -o "$key" = \n  # Enter key
                break
            else if test "$key" = \e  # Escape sequence (arrow keys)
                # Read the next two characters of the escape sequence
                set -l seq (dd bs=1 count=2 2>/dev/null)
                switch "$seq"
                    case "[A" "OA"  # Up arrow
                        if test $selected -gt 1
                            set selected (math $selected - 1)
                            stty $saved_stty  # Restore briefly for output
                            _draw_menu redraw
                            stty raw -echo
                        end
                    case "[B" "OB"  # Down arrow
                        if test $selected -lt $num_packages
                            set selected (math $selected + 1)
                            stty $saved_stty  # Restore briefly for output
                            _draw_menu redraw
                            stty raw -echo
                        end
                end
            else if test "$key" = \cC -o "$key" = \x03  # Ctrl-C
                stty $saved_stty
                functions -e _draw_menu
                return 2
            end
        end

        # Restore terminal state
        stty $saved_stty
        functions -e _draw_menu
        echo
        set -g PKG_SOURCE_DIR (realpath "$package_paths[$selected]")
        print_success "Selected: $packages[$selected]"
    end
    
    return 0
end

function tag_release
    print_step "Tagging release in your repository..."
    
    set -l tag "$PKG_VERSION"
    
    # Check if tag already exists
    if git tag -l | grep -q "^$tag\$"
        print_warning "Tag $tag already exists"
        prompt_confirm "Delete and recreate it?" y
        or return $status
        run_cmd "git tag -d $tag"
        run_cmd "git push origin --delete $tag 2>/dev/null"
    end
    
    run_cmd "git tag -a $tag -m 'Release version $PKG_VERSION'"
    print_success "Created tag $tag"
    
    run_cmd "git push origin $tag"
    print_success "Pushed tag to origin"
    
    return 0
end

function setup_packages_clone
    print_step "Setting up typst/packages clone..."
    
    if test -d "$PACKAGES_DIR"
        print_info "Directory exists at $PACKAGES_DIR"
        prompt_confirm "Re-clone fresh?" n
        switch $status
            case 0
                # Yes - remove and re-clone
                run_cmd "rm -rf '$PACKAGES_DIR'"
            case 1
                # No - just sync with upstream
                set -l pkg_path "packages/preview/$PKG_NAME"
                print_info "Syncing with upstream..."
                if test "$DRY_RUN" = true
                    print_dry "cd $PACKAGES_DIR"
                    print_dry "git sparse-checkout add $pkg_path"
                    print_dry "git fetch upstream"
                    print_dry "git checkout main"
                    print_dry "git merge upstream/main"
                else
                    cd "$PACKAGES_DIR"
                    # Ensure sparse-checkout includes this package
                    git sparse-checkout add "$pkg_path"
                    git fetch upstream
                    git checkout main
                    git merge upstream/main --no-edit 2>/dev/null
                end
                print_success "Synced with upstream"
                return 0
            case 2
                # Ctrl-C
                return 2
        end
    end
    
    print_info "Forking repository..."
    run_cmd "gh repo fork typst/packages --clone=false 2>/dev/null"
    
    print_info "Cloning with sparse checkout (this is fast)..."
    
    set -l pkg_path "packages/preview/$PKG_NAME"

    if test "$DRY_RUN" = true
        set -l gh_user (gh api user -q .login 2>/dev/null; or echo "YOUR-USERNAME")
        print_dry "git clone --sparse --filter=blob:none --depth=1 git@github.com:$gh_user/packages.git $PACKAGES_DIR"
        print_dry "cd $PACKAGES_DIR"
        print_dry "git remote add upstream https://github.com/typst/packages.git"
        print_dry "git sparse-checkout set $pkg_path"
        print_dry "git fetch upstream main"
        print_dry "git merge upstream/main"
    else
        set -l gh_user (gh api user -q .login)
        git clone --sparse --filter=blob:none --depth=1 "git@github.com:$gh_user/packages.git" "$PACKAGES_DIR" &
        spinner $last_pid
        wait $last_pid

        if test $status -ne 0
            # Fallback to HTTPS
            git clone --sparse --filter=blob:none --depth=1 "https://github.com/$gh_user/packages.git" "$PACKAGES_DIR"
        end

        cd "$PACKAGES_DIR"
        git remote add upstream https://github.com/typst/packages.git 2>/dev/null

        # Configure sparse-checkout to include the package directory
        print_info "Configuring sparse checkout for $pkg_path..."
        git sparse-checkout set "$pkg_path"

        # Fetch and merge upstream to get existing versions
        print_info "Fetching upstream to check for existing versions..."
        git fetch upstream main
        git merge upstream/main --no-edit 2>/dev/null
    end

    print_success "Packages repository ready"
    return 0
end

function copy_package
    print_step "Copying package to packages repository..."
    
    set -l dest "$PACKAGES_DIR/packages/preview/$PKG_NAME/$PKG_VERSION"
    
    if test -d "$dest"
        print_warning "Directory already exists: $dest"
        prompt_confirm "Overwrite?" y
        or return $status
        run_cmd "rm -rf '$dest'"
    end
    
    run_cmd "mkdir -p '$dest'"
    
    # Copy all files from the source directory
    run_cmd "cp -r '$PKG_SOURCE_DIR'/. '$dest/'"
    print_success "Copied all files to $dest"
    
    return 0
end

function push_changes
    print_step "Pushing changes..."
    
    if test "$DRY_RUN" = true
        print_dry "cd $PACKAGES_DIR"
    else
        cd "$PACKAGES_DIR"
    end
    
    set -l branch "$PKG_NAME-$PKG_VERSION"
    
    if test "$DRY_RUN" = true
        run_cmd "git checkout -b $branch"
        run_cmd "git add ."
        run_cmd "git commit -m 'Add $PKG_NAME $PKG_VERSION'"
        run_cmd "git push -u origin $branch"
    else
        if git branch -a | grep -q "$branch"
            print_warning "Branch $branch already exists"
            git checkout $branch
            git add .
            git commit --amend --no-edit 2>/dev/null
            git push -f origin $branch
        else
            git checkout -b $branch
            git add .
            git commit -m "Add $PKG_NAME $PKG_VERSION"
            git push -u origin $branch
        end
    end
    
    print_success "Pushed branch $branch"
    
    return 0
end

function show_summary
    print_header "Summary"
    
    echo "  "{$C_DIM}"Package:"{$C_RESET}"     $PKG_NAME"
    echo "  "{$C_DIM}"Version:"{$C_RESET}"     $PKG_VERSION"
    echo "  "{$C_DIM}"Description:"{$C_RESET}" $PKG_DESCRIPTION"
    echo "  "{$C_DIM}"Source:"{$C_RESET}"      $PKG_SOURCE_DIR"
    echo
end

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

function main
    # Parse arguments
    for arg in $argv
        switch $arg
            case -n --dry-run
                set -g DRY_RUN true
            case -h --help
                echo "Usage: typst-publish.fish [OPTIONS]"
                echo
                echo "Options:"
                echo "  -n, --dry-run    Walk through all steps without making changes"
                echo "  -h, --help       Show this help message"
                return 0
        end
    end
    
    if test "$DRY_RUN" = true
        print_header "Typst Universe Publisher (DRY RUN)"
        echo {$C_YELLOW}"  ⚠ Dry run mode: no changes will be made"{$C_RESET}
        echo {$C_DIM}"  Commands that would be executed are shown in yellow"{$C_RESET}
        echo
    else
        print_header "Typst Universe Publisher"
    end
    
    # Check prerequisites
    check_prerequisites
    or return $status
    echo
    
    # Select package from release/preview
    select_package
    or return $status
    echo
    
    # Parse typst.toml
    parse_typst_toml "$PKG_SOURCE_DIR/typst.toml"
    or return $status
    
    show_summary
    
    prompt_confirm "Continue with this package?" y
    or return $status
    echo
    
    set -l original_dir (pwd)
    
    # Step 1: Setup packages clone
    print_header "Step 1: Setup Packages Repository"
    
    setup_packages_clone
    or return $status
    echo
    
    # Step 2: Copy package
    print_header "Step 2: Copy Package"
    
    copy_package
    or return $status
    echo
    
    # Step 3: Push changes
    print_header "Step 3: Push Changes"
    
    push_changes
    or return $status
    echo
    
    # Step 4: Tag release (final step, after changes are pushed)
    print_header "Step 4: Tag Release"
    
    if test "$DRY_RUN" != true
        cd "$original_dir"
    else
        print_dry "cd $original_dir"
    end
    
    if git -C "$original_dir" rev-parse --git-dir >/dev/null 2>&1
        prompt_confirm "Tag $PKG_VERSION in your repository?" y
        switch $status
            case 0
                tag_release
            case 2
                return 2
        end
    else
        print_warning "Not a git repository, skipping tagging"
    end
    echo
    
    # Done
    if test "$DRY_RUN" = true
        print_header "Dry Run Complete"
        echo "  No changes were made. Run without --dry-run to execute."
    else
        print_header "Done!"
        echo "  Your changes have been pushed. Create a PR using the link above."
        echo "  The Typst team will review your PR and merge it."
    end
    
    echo
    echo "  "{$C_DIM}"Once merged, users can import your package with:"{$C_RESET}
    echo "  "{$C_CYAN}"#import \"@preview/$PKG_NAME:$PKG_VERSION\""{$C_RESET}
    echo
end

# Run if executed directly
main $argv