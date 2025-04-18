FROM cmaf-dev
ARG FFMEPG_BRANCH
WORKDIR /app/ffmpeg
ADD https://github.com/sessystems/FFmpeg/archive/refs/heads/patched/${FFMEPG_BRANCH}.zip .
RUN unzip ${FFMEPG_BRANCH}.zip && FFMEPGDIR=$(find  -maxdepth 1 -type d |grep -i mpeg) && mv $FFMEPGDIR/* . && rm -rf $FFMEPGDIR
RUN ./configure --enable-static --disable-doc \
--extra-ldflags='-Wl,-rpath,/usr/local/cuda-12.4/targets/x86_64-linux/lib -L/usr/local/cuda-12.4/targets/x86_64-linux/lib' \
--enable-rpath \
--enable-libx264 \
--enable-libx265 \
--enable-libxml2 \
--enable-libsrt \
--enable-libfreetype \
--enable-libfontconfig \
--enable-libharfbuzz \
--enable-libfribidi \
--enable-gnutls \
--enable-vaapi \
--disable-ffplay \
--enable-gpl \
--enable-ffnvcodec \
--enable-libmp3lame
RUN make -j