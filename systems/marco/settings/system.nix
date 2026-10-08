{ user, ... }:

{
  system.stateVersion = 6;

  system.primaryUser = user;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      AppleKeyboardUIMode = 3;
      InitialKeyRepeat = 16;
      KeyRepeat = 6;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      _HIHideMenuBar = false;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
      persistent-apps = [
        { app = "/Applications/Blender.app"; }
      ];
    };

    finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
    };

    screencapture.location = "~/Downloads";

    trackpad = {
      Clicking = false;
      TrackpadThreeFingerDrag = false;
    };

    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # 64: cmd + space
          "64" = {
            enabled = false;
            value = {
              parameter = [
                32
                49
                1048576
              ];
              type = "standard";
            };
          };
          # 65: alt + cmd + space (finder search)
          "65" = {
            enabled = false;
            value = {
              parameter = [
                32
                49
                1572864
              ];
              type = "standard";
            };
          };
        };
      };
    };
  };

  # Apply the defaults above without needing a logout
  system.activationScripts.postActivation.text = ''
    sudo -u ${user} \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
  '';

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = false;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}
