{ userSettings, ... }:

{
  imports = [ ./base.nix
              ( import ../../system/security/sshd.nix {
                authorizedKeys = [ "add contents ~/.ssh/id_rsa.pub here"];
                inherit userSettings; })
            ];
}
