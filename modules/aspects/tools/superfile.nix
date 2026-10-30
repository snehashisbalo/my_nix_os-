{ ... }:
{
  den.aspects.tools.superfile = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [ superfile ];
    };
  };
}
