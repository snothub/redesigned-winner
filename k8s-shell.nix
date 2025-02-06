let
  # Pin nixpkgs to a specific version
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/23.11.tar.gz";
    sha256 = "1ndiv385w1qyb3b18vw13991fzb9wg4cl21wglk89grsfsnra41k";
  };

  # Import pinned nixpkgs
  pkgs = import nixpkgs {
    config = {
      allowUnfree = true;
    };
    overlays = [];
  };

in pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core tools
    kubernetes-helm
    kubectl
    cilium-cli
    istioctl

    # Additional helpful tools
    k9s
    kubectx
    kubelogin
    stern
  ];

  shellHook = ''
    # Set up kubectl config directory
    export KUBECONFIG="$PWD/.kube/config"
    mkdir -p "$PWD/.kube"

    # Set up Helm config and cache directories
    export HELM_CONFIG_HOME="$PWD/.helm"
    export HELM_CACHE_HOME="$PWD/.helm/cache"
    mkdir -p "$HELM_CONFIG_HOME" "$HELM_CACHE_HOME"

    # Configure common Helm repositories
    helm repo add stable https://charts.helm.sh/stable 2>/dev/null
    helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null
    helm repo update >/dev/null

    # Set up Istio configuration
    export ISTIO_HOME="$PWD/.istio"
    mkdir -p "$ISTIO_HOME"

    # Function to display tool versions
    show_versions() {
      echo "🛠️  Kubernetes Development Environment"
      echo "==============================="
      echo "📦 Installed tools:"
      kubectl version --client --short 2>/dev/null | sed 's/^/- kubectl: /'
      helm version --short 2>/dev/null | sed 's/^/- helm: /'
      cilium version --client 2>/dev/null | head -n1 | sed 's/^/- cilium: /'
      istioctl version --remote=false 2>/dev/null | head -n1 | sed 's/^/- istioctl: /'
      echo "- k9s $(k9s version 2>/dev/null | head -n1)"
      echo "- kubectx $(kubectx --version 2>/dev/null)"
      echo "- stern $(stern --version 2>/dev/null)"
      echo "\n💡 Tip: Run 'show_versions' to see this information again"
    }

    # Show initial versions
    show_versions

    # Set up shell prompt
    export PS1="\[\033[1;32m\][k8s-dev]\[\033[0m\] $PS1"
  '';

  # Environment variables
  KUBERNETES_SKIP_VERIFY = "true";  # Skip TLS verification for local development
  HELM_EXPERIMENTAL_OCI = "1";      # Enable OCI support in Helm
}
