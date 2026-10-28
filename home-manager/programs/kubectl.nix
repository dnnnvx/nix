{ pkgs, ... }:

let
  json = pkgs.formats.json { }; # JSON is valid YAML, and avoids the `%YAML` header kubectl chokes on
in
{
  home.packages = [ pkgs.kubectl ];

  # kubectl user preferences, see https://kubernetes.io/docs/reference/kubectl/kuberc/
  home.file.".kube/kuberc".source = json.generate "kuberc" {
    apiVersion = "kubectl.config.k8s.io/v1beta1";
    kind = "Preference";

    # flag defaults, explicit flags on the command line still win
    defaults = [
      {
        # field ownership tracking + proper merges, no giant last-applied annotation
        command = "apply";
        options = [
          { name = "server-side"; default = "true"; }
        ];
      }
      {
        command = "diff";
        options = [
          { name = "server-side"; default = "true"; }
        ];
      }
      {
        # preview + confirm before anything gets deleted
        command = "delete";
        options = [
          { name = "interactive"; default = "true"; }
        ];
      }
      {
        command = "logs";
        options = [
          { name = "timestamps"; default = "true"; }
        ];
      }
    ];

    aliases = [
      {
        # kubectl getw pods -> wide output
        name = "getw";
        command = "get";
        options = [
          { name = "output"; default = "wide"; }
        ];
      }
      {
        # kubectl gety deploy foo -> yaml output
        name = "gety";
        command = "get";
        options = [
          { name = "output"; default = "yaml"; }
        ];
      }
      {
        # kubectl pods -> every pod in every namespace
        name = "pods";
        command = "get";
        prependArgs = [ "pods" ];
        options = [
          { name = "all-namespaces"; default = "true"; }
          { name = "output"; default = "wide"; }
        ];
      }
      {
        # kubectl tail <pod> -> follow the last 100 lines
        name = "tail";
        command = "logs";
        options = [
          { name = "follow"; default = "true"; }
          { name = "tail"; default = "100"; }
        ];
      }
      {
        # kubectl warnings -> only warning events
        name = "warnings";
        command = "events";
        options = [
          { name = "types"; default = "Warning"; }
        ];
      }
    ];
  };
}
