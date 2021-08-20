{pkgs, lib, ... }:

{
  home-manager.users.jules = {
    nixpkgs.config.allowUnfree = true;

    home.sessionVariables.EDITOR = "vim";

    programs = {
      starship = {
        enable = true;
        enableBashIntegration = true;

        settings = {
          username = {
            # show_always = true;
          };

          hostname = {
            # ssh_only = false;
            style = "bold dimmed blue";
          };

          directory.truncation_length = 0;

          memory_usage.disabled = false;

          package  = {
            format = "[$symbol$version]($style) ";
            symbol = "📦 ";
          };

          status = {
            disabled = false;
            # format = "exit [$common_meaning$signal_name$maybe_int]($style) ";
            format = "[$int]($style) ";
            symbol = "🔴";
          };

          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };


          format = lib.concatStrings [
            "$username"
            "$hostname"
            "$shlvl"
            "$kubernetes"
            "$directory"
            "$git_branch"
            "$git_commit"
            "$git_state"
            "$git_status"
            "$hg_branch"
            "$docker_context"
            "$cmake"
            "$dart"
            "$elm"
            "$erlang"
            "$golang"
            "$helm"
            "$java"
            "$julia"
            "$kotlin"
            "$nim"
            "$nodejs"
            "$elixir"
            "$dotnet"
            "$ocaml"
            "$perl"
            "$php"
            "$purescript"
            "$python"
            "$ruby"
            "$rust"
            "$scala"
            "$swift"
            "$crystal"
            "$terraform"
            "$vagrant"
            "$zig"
            "$nix_shell"
            "$conda"
            "$memory_usage"
            "$openstack"
            "$custom"
            "$cmd_duration"
            "$lua"
            "$jobs"
            "$time"
            # "$status"
            "$line_break"
            "$status"
            "$shell"
            "$character"
          ];
        };
      };

      bash = {
        enable = true;        
        historyIgnore = [ "fg" "ls" "ll" "la" ".." "cd" "exit" ];
        shellAliases = {
          ls = "ls --color=auto";
          la = "ls --color=auto -A";
          ll = "ls --color=auto -Alh";
          ".." = "cd ..";
        };
        # initExtra = (builtins.readFile ./jules/.bashrc);
      };

      git = {
        enable = true;
        userName = "Jules Lefebvre";
        userEmail = "jules.lefebvre@epita.fr";
        aliases = {
          tree = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
          lg = "log --abbrev-commit --decorate --format=format:'%C(bold blue)%h %C(bold red)<%an> %C(bold green)(%ar)%C(reset) %C(white)%s%C(bold yellow)%d%C(reset)'";
          cd = "checkout";
          b = "branch";
        };
        ignores = [ "*~" "*.swp" "*.d" "*.o" ];
      };

      vim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          vim-airline
          vim-airline-themes
          # plugins.onedark-vim
        ];
        settings = {
          number = true;
          copyindent = true;
          expandtab = true;
          tabstop = 4;
          shiftwidth = 4;
        };
        extraConfig = (builtins.readFile ./jules/vimrc);
      };

      kitty = {
        enable = true;

        settings = {
          enable_audio_bell = false;

          font_family = "Fira Code Regular";
          bold_font = "Fira Code Bold";
          italic_font = "Fira Mono Regular Italic";
          bold_italic_font = "Fira Mono Bold Italic";

          cursor = "#cccccc";
          cursor_shape = "beam";
          cursor_blink_interval = "1";

          url_color = "#0087bd";
          url_style = "curly";

          window_border_width = "0pt";
          window_margin_width = "5";

          foreground = "#DCDCDC";
          background = "#181818";

          color0 = "#434C5E";
          color1 = "#FA5A77";
          color2 = "#2BE491";
          color3 = "#FA946E";
          color4 = "#6381EA";
          color5 = "#CF8EF4";
          color6 = "#89CCF7";
          color7 = "#DCDCDC";
          color8 = "#4C566A";
          color9 = "#FA748D";
          color10 = "#44EB9F";
          color11 = "#FAA687";
          color12 = "#7A92EA";
          color13 = "#D8A6F4";
          color14 = "#A1D5F7";
          color15 = "#F4F4F4";
        };

      };

      vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          ms-vscode.cpptools
          # matklad.rust-analyzer
        ];
      };
    };
  };
}

