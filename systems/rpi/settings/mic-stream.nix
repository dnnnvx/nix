{ pkgs, ... }:

let
  port = 8554;
  # ALSA input: the C-Media USB PnP Sound Device (`arecord -l`). Addressed by
  # card name, since card indices can change between boots.
  device = "plughw:CARD=Device";
in
{
  # Streams the mic as rtsp://<hostname>.local:8554/mic for BirdNET-Go on the cluster
  services.mediamtx = {
    enable = true;
    settings = {
      rtspTransports = [ "tcp" ];
      rtspAddress = ":${toString port}";
      rtmp = false;
      hls = false;
      webrtc = false;
      srt = false;

      # mediamtx restarts ffmpeg whenever it exits, e.g. while no mic is plugged in.
      # Lossless 48 kHz mono, so detection matches a directly attached mic.
      paths.mic = {
        runOnInit = "${pkgs.ffmpeg-headless}/bin/ffmpeg -nostdin -f alsa -ac 1 -ar 48000 -i ${device} -c:a pcm_s16be -f rtsp rtsp://localhost:${toString port}/mic";
        runOnInitRestart = true;
      };
    };
  };

  systemd.services.mediamtx.serviceConfig.SupplementaryGroups = [ "audio" ];

  # arecord -l / arecord -D <device> -d 5 test.wav, to find and test the mic
  environment.systemPackages = [ pkgs.alsa-utils ];

  networking.firewall.allowedTCPPorts = [ port ];
}
