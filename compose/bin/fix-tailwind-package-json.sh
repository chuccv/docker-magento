#!/bin/bash
# Script to fix Tailwind CSS package.json issues for PHPStorm
# This creates package.json and node_modules symlink for vendor modules with tailwind.config.js

THEME_NODE_MODULES="/var/www/html/evelant/app/design/frontend/Gsp/hyva_child/web/tailwind/node_modules"

if [ ! -d "$THEME_NODE_MODULES" ]; then
    echo "Error: Theme node_modules not found at $THEME_NODE_MODULES"
    exit 1
fi

echo "Fixing Tailwind CSS package.json for vendor modules..."

find /var/www/html/evelant/vendor -path "*/view/frontend/tailwind/tailwind.config.js" -type f 2>/dev/null | while read config_file; do
    dir=$(dirname "$config_file")
    
    # Create package.json if it doesn't exist
    if [ ! -f "$dir/package.json" ]; then
        module_name=$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$dir")")")")")
        cat > "$dir/package.json" << EOF
{
  "name": "$module_name-tailwind",
  "version": "1.0.0",
  "description": "Tailwind config for $module_name",
  "main": "tailwind.config.js",
  "dependencies": {
    "tailwindcss": "^3.4.17"
  }
}
EOF
        echo "Created package.json: $dir/package.json"
    fi
    
    # Create node_modules symlink if it doesn't exist
    if [ ! -e "$dir/node_modules" ]; then
        ln -sf "$THEME_NODE_MODULES" "$dir/node_modules"
        echo "Created node_modules symlink: $dir/node_modules"
    fi
done

echo "Done!"

