enum VideoKind { asset, network }

class VideoSource {
  final VideoKind kind;
  final String pathOrUrl;

  const VideoSource.asset(this.pathOrUrl) : kind = VideoKind.asset;
  const VideoSource.network(this.pathOrUrl) : kind = VideoKind.network;
}


