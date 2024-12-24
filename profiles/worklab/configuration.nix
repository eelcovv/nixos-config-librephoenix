{ userSettings, ... }:

{
  imports = [ ../homelab/base.nix
              ( import ../../system/security/sshd.nix {
                authorizedKeys = [ "add ssh-rsa here" ];
                inherit userSettings; })
            ];
}
