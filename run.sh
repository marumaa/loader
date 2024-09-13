
sudo clear

handle_error() {
    echo "Error: $1"
    exit 1
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
 
original_binary_name="dll"
 
temp_binary_name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
 
temp_binary_path="/$script_dir/$temp_binary_name"
 
if ! cp "$script_dir/$original_binary_name" "$temp_binary_path"; then
    exit 1
fi
(sudo env XDG_RUNTIME_DIR="/run/user/0" "./$temp_binary_name") & pid=$! 

if echo "$pid" | sudo tee /proc/sys/kernel/ns_last_pid > /dev/null; then
    child_pids=$(pgrep -P $pid)
    for child_pid in $child_pids; do
        if echo "$child_pid" | sudo tee /proc/sys/kernel/ns_last_pid > /dev/null; then
            echo "successfully"
        else
            echo "Failed"
        fi
    done
else
    echo "Failed"
fi

if ! wait $pid; then
    rm "$temp_binary_name"
    exit 1
fi
 

