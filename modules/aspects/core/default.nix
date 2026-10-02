{ den, ... }: {
  # Shared, reusable system config. Pull in only what a given host/user needs.
  den.aspects.core.default = {
    includes = with den.aspects.core; [
      common
    ];
  };
}
