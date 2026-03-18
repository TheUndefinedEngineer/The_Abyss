```bash
#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0")" && pwd)"

case "$1" in
  qnx)
    nix-shell "$DIR/qnx-fhs.nix"
    ;;
  *)
    echo "Usage: fshell qnx"
    ;;
esac
```

#linux #nixos 