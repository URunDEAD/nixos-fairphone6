{ config, lib, ... }:
let cfg = config.handsets.development;
in {
  options.handsets.development = {
    enable = lib.mkEnableOption "explicit key-only development access";
    authorizedKeys = lib.mkOption { type = with lib.types; listOf str; default = []; };
    user = lib.mkOption { type = lib.types.str; default = "developer"; };
  };
  config = lib.mkIf cfg.enable {
    assertions = [{ assertion = cfg.authorizedKeys != []; message = "Development access requires an explicitly supplied SSH public key."; }];
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "no";
    };
    users.users.${cfg.user} = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
    # No automatic wheel membership, passwordless sudo, ADB or USB networking.
  };
}
