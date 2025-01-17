{ lib
, stdenv
, fetchurl
, raspberrypifw
, pcre
, boost
, freetype
, zlib
}:

let
  ffmpeg = stdenv.mkDerivation rec {
    pname = "ffmpeg";
    version = "1.1.3";

    src = fetchurl {
      url = "http://www.ffmpeg.org/releases/ffmpeg-${version}.tar.bz2";
      sha256 = "03s1zsprz5p6gjgwwqcf7b6cvzwwid6l8k7bamx9i0f1iwkgdm0j";
    };

    configurePlatforms = [ ];
    configureFlags = [
      "--arch=${stdenv.hostPlatform.parsed.cpu.name}"
    ] ++ lib.optionals stdenv.hostPlatform.isAarch32 [
      # TODO be better with condition
      "--cpu=arm1176jzf-s"
    ] ++ [
      "--disable-muxers"
      "--enable-muxer=spdif"
      "--enable-muxer=adts"
      "--disable-encoders"
      "--enable-encoder=ac3"
      "--enable-encoder=aac"
      "--disable-decoder=mpeg_xvmc"
      "--disable-devices"
      "--disable-ffprobe"
      "--disable-ffplay"
      "--disable-ffserver"
      "--disable-ffmpeg"
      "--enable-shared"
      "--disable-doc"
      "--enable-postproc"
      "--enable-gpl"
      "--enable-protocol=http"
      "--enable-pthreads"
      "--disable-runtime-cpudetect"
      "--enable-pic"
      "--disable-armv5te"
      "--disable-neon"
      "--enable-armv6t2"
      "--enable-armv6"
      "--enable-hardcoded-tables"
      "--disable-runtime-cpudetect"
      "--disable-debug"
      "--arch=${stdenv.hostPlatform.parsed.cpu.name}"
      "--target_os=${stdenv.hostPlatform.parsed.kernel.name}"
    ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      "--cross-prefix=${stdenv.cc.targetPrefix}"
      "--enable-cross-compile"
    ];

    enableParallelBuilding = true;

    meta = {
      homepage = "http://www.ffmpeg.org/";
      description = "A complete, cross-platform solution to record, convert and stream audio and video";
    };
  };
in
stdenv.mkDerivation rec {
  pname = "omxplayer";
  version = "20130328-fbee325dc2";
  src = fetchurl {
    url = "https://github.com/huceke/omxplayer/tarball/fbee325dc2";
    name = "omxplayer-${version}.tar.gz";
    sha256 = "0fkvv8il7ffqxki2gp8cxa5shh6sz9jsy5vv3f4025g4gss6afkg";
  };
  patchPhase = ''
    sed -i 1d Makefile
    export INCLUDES="-I${raspberrypifw}/include/interface/vcos/pthreads -I${raspberrypifw}/include/interface/vmcs_host/linux/"
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp omxplayer.bin $out/bin
  '';
  buildInputs = [ raspberrypifw ffmpeg pcre boost freetype zlib ];

  meta = {
    homepage = "https://github.com/huceke/omxplayer";
    description = "Commandline OMX player for the Raspberry Pi";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.arm;
  };
}
