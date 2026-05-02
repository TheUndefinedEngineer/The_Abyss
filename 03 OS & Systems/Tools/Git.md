## .gitignore
### Basic syntax
```c
# This is a comment

# Ignore a specific file
secret.txt

# Ignore a file type (all .log files)
*.log

# Ignore a folder
node_modules/

# Ignore a folder's contents but keep the folder
logs/*

# Negate a pattern (don't ignore this even if matched above)
!important.log
```
### Common Patterns
```c
# OS files
.DS_Store        # macOS
Thumbs.db        # Windows

# Dependencies
node_modules/
vendor/

# Build output
dist/
build/
*.o
*.exe

# Environment & secrets
.env
.env.local
*.pem

# Logs
*.log
logs/

# IDE files
.vscode/
.idea/
*.swp
```

Tags: #guide #reference 