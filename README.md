curl -L https://nixos.org/nix/install | sh -s -- --daemon

curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/snothub/redesigned-winner/refs/heads/main/k8s-shell.nix > shell.nix && nix-shell
