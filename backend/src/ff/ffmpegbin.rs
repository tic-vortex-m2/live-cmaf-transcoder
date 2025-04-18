use tokio::process::Command;

use crate::model::ff::{
    audioadaptationset::AudioEncoder,
    ffconfig::{self, Acceleration},
    videoadaptationset::VideoEncoder,
};

#[derive(Clone)]
pub struct FFmpegBin {
    pub ffmpeg: String,
    pub supported_audio_codecs: Vec<AudioEncoder>,
    pub supported_video_codecs: Vec<(Acceleration, VideoEncoder)>,
    pub ast_delay_us_supported: bool,
}

impl FFmpegBin {
    pub async fn new(ffmpeg: String) -> std::io::Result<Self> {
        let codecs = Self::get_encoder_codecs(&ffmpeg).await?;
        let dash_muxer_opts = Self::get_dash_muxer_options(&ffmpeg).await?;
        let mut supported_audio_codecs = Vec::new();
        let mut supported_video_codecs = Vec::new();
        let ast_delay_us_supported = dash_muxer_opts.contains("-ast_delay_us");

        if Self::has_codec("AAC (Advanced Audio Coding)", &codecs) {
            supported_audio_codecs.push(AudioEncoder::Aac);
        }

        if Self::has_codec("libfdk_aac", &codecs) {
            supported_audio_codecs.push(AudioEncoder::FDKAac);
        }

        if Self::has_codec("libx264", &codecs) {
            supported_video_codecs.push((Acceleration::Software, VideoEncoder::H264));
        }

        if Self::has_codec("h264_vaapi", &codecs) {
            supported_video_codecs.push((Acceleration::Vaapi, VideoEncoder::H264));
        }

        if Self::has_codec("h264_nvenc", &codecs) {
            supported_video_codecs.push((Acceleration::Cuda, VideoEncoder::H264));
        }

        if Self::has_codec("libx265", &codecs) {
            supported_video_codecs.push((Acceleration::Software, VideoEncoder::HEVC));
        }

        if Self::has_codec("hevc_vaapi", &codecs) {
            supported_video_codecs.push((Acceleration::Vaapi, VideoEncoder::HEVC));
        }

        if Self::has_codec("hevc_nvenc", &codecs) {
            supported_video_codecs.push((Acceleration::Cuda, VideoEncoder::HEVC));
        }

        Ok(Self {
            ffmpeg,
            supported_audio_codecs,
            supported_video_codecs,
            ast_delay_us_supported,
        })
    }

    pub fn is_config_supported(&self, config: &ffconfig::FFConfig) -> bool {
        if !self
            .supported_audio_codecs
            .contains(&config.audio_adaptation_set.encoder)
        {
            return false;
        }

        for adaptation in &config.video_adaptation_set {
            if !self
                .supported_video_codecs
                .contains(&(config.acceleration, adaptation.encoder))
            {
                return false;
            }
        }

        true
    }

    async fn get_dash_muxer_options(ffmpeg: &str) -> std::io::Result<String> {
        let opts = Command::new(ffmpeg)
            .arg("-h")
            .arg("muxer=dash")
            .output()
            .await;
        if opts.is_err() {
            tracing::error!("Wrong FFMPEG binary {} ?", ffmpeg);
            return Err(std::io::Error::new(
                std::io::ErrorKind::Other,
                "Failed to execute ffmpeg",
            ));
        }

        let opts = opts.unwrap();
        Ok(String::from_utf8_lossy(&opts.stdout).to_string())
    }

    async fn get_encoder_codecs(ffmpeg: &str) -> std::io::Result<String> {
        let codecs = Command::new(ffmpeg).arg("-encoders").output().await;
        if codecs.is_err() {
            tracing::error!("Wrong FFMPEG binary {} ?", ffmpeg);
            return Err(std::io::Error::new(
                std::io::ErrorKind::Other,
                "Failed to execute ffmpeg",
            ));
        }

        let codecs = codecs.unwrap();
        let codecs = String::from_utf8_lossy(&codecs.stdout).to_string();
        Ok(codecs)
    }

    fn has_codec(codec: &str, list_of_codecs: &str) -> bool {
        for line in list_of_codecs.lines() {
            if line.contains(codec) {
                return true;
            }
        }

        false
    }
}

#[derive(Clone)]
pub struct FFmpegBinList {
    ffmpegs: Vec<FFmpegBin>,
}

impl FFmpegBinList {
    pub async fn new(ffmpegs: &Vec<String>) -> std::io::Result<Self> {
        let mut ffmpeg_bins = Vec::new();

        for ffmpeg in ffmpegs {
            let ffmpeg_bin = FFmpegBin::new(ffmpeg.clone()).await?;
            ffmpeg_bins.push(ffmpeg_bin);
        }

        Ok(Self {
            ffmpegs: ffmpeg_bins,
        })
    }

    pub fn find(&self, config: &ffconfig::FFConfig) -> Option<&FFmpegBin> {
        for ffmpeg in &self.ffmpegs {
            if ffmpeg.is_config_supported(config) {
                return Some(ffmpeg);
            }
        }

        None
    }
}
