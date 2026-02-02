# up - navigate up multiple directories
# Usage: up <number>
# Example: up 3  -> equivalent to cd ../../..
up() {
    local count="${1:-1}"

    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo "Usage: up <number>" >&2
        return 1
    fi

    local path=""
    for ((i = 0; i < count; i++)); do
        path="../${path}"
    done

    cd "$path" || return 1
}
