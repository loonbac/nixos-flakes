# Montaje exclusivo de nixos-pc para la particion NTFS etiquetada "Juegos".
# Se identifica por UUID para no depender del nombre asignado al NVMe.
{ ... }:

{
  fileSystems."/home/loonbac/Juegos" = {
    device = "/dev/disk/by-uuid/A20C21340C21053F";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "umask=0022"
      "nofail"
    ];
  };
}
