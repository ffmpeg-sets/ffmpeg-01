//
//  ViewController.m
//  ffmpeg-01
//
//  Created by suntongmian on 2018/1/10.
//  Copyright © 2018年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "ViewController.h"
#include "libavformat/avformat.h"

@interface ViewController ()
{
    AVFormatContext *_pFormatContext;
    AVCodecParameters *_pVideoCodecParameters;
    AVCodecParameters *_pAudioCodecParameters;
    AVCodec *_pVideoCodec;
    AVCodec *_pAudioCodec;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *liveStreamingString = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    const char *liveStreamingURL = [liveStreamingString UTF8String];
    
    av_register_all();
    
    avformat_network_init();
    
    _pFormatContext = avformat_alloc_context();
    
    if(avformat_open_input(&_pFormatContext, liveStreamingURL, NULL, NULL) != 0) {
        NSLog(@"Couldn't open input stream");
        return;
    }
    
    if(avformat_find_stream_info(_pFormatContext, NULL) < 0) {
        NSLog(@"Couldn't find stream information");
        return;
    }
    
    av_dump_format(_pFormatContext, 0, liveStreamingURL, 0);
    
    int videoIndex = -1;
    for(int i = 0; i < _pFormatContext->nb_streams; i++) {
        if(_pFormatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoIndex = i;
            break;
        }
    }
    
    if(videoIndex == -1) {
        NSLog(@"Didn't find a video stream");
        return;
    }
    
    int audioIndex = -1;
    for(int i = 0; i < _pFormatContext->nb_streams; i++) {
        if(_pFormatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            audioIndex = i;
            break;
        }
    }
    
    if(audioIndex == -1) {
        NSLog(@"Didn't find a audio stream");
        return;
    }
    
    _pVideoCodecParameters = _pFormatContext->streams[videoIndex]->codecpar;
    _pVideoCodec = avcodec_find_decoder(_pVideoCodecParameters->codec_id);
    if(_pVideoCodec == NULL) {
        NSLog(@"Video codec not found");
        return;
    }
    
    _pAudioCodecParameters = _pFormatContext->streams[audioIndex]->codecpar;
    _pAudioCodec = avcodec_find_decoder(_pAudioCodecParameters->codec_id);
    if(_pAudioCodec == NULL) {
        NSLog(@"Audio codec not found");
        return;
    }
    
    avformat_close_input(&_pFormatContext);
    _pFormatContext = NULL;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
