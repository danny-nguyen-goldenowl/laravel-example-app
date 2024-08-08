#!/bin/bash

# Pre-push hook content
read -r -d '' HOOK_CONTENT <<'EOF'
#!/bin/bash

is_destructive="^git push (-f|--force)( .+)?$"

policy='[Policy] Never force push to a branch! (Prevented with pre-push hook.)'
push_command=$(ps -ocommand= -p $PPID | grep -Eo 'git push.*')

do_exit(){
  echo $policy
  exit 1
}

if [[ $push_command =~ $is_destructive ]]; then
  do_exit
fi

# If all checks passed, allow the push
exit 0
EOF

# Function to add the pre-push hook to a given .git/hooks directory
add_pre_push_hook() {
    local git_hooks_dir=$1
    echo "$HOOK_CONTENT" > "$git_hooks_dir/pre-push"
    chmod +x "$git_hooks_dir/pre-push"
}

# Find all .git directories and add the pre-push hook
find . -type d -name ".git" | while read -r git_dir; do
    add_pre_push_hook "$git_dir/hooks"
    echo "Added pre-push hook to $git_dir/hooks"
done

