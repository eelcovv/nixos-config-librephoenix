{ lib, ... }:

{
  services.timesyncd.enable = lib.mkDefault true;
}
