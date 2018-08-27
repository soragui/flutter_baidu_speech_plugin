//
//  AudioDataQueue.hpp
//  SDKTester
//
//  Created by lappi on 1/8/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#ifndef AudioDataQueue_hpp
#define AudioDataQueue_hpp

class AudioDataQueue
{
public:
    AudioDataQueue(int bufferCapacity = 0);
    int queueAudio(const uint8_t* audioData, int dataLength);
    int dequeSamples(uint8_t* dataBuffer, int bufferSize, bool dequeRemaining);
    bool haveData();
    void reset();
    ~AudioDataQueue();
    
private:
    uint8_t* mData;
    int mDataLength;
    int mBufferCapacity;
    uint8_t* mLoopStart;
    uint8_t* mLoopEnd;
    uint8_t* mDataEnd;
};

#endif /* AudioDataQueue_hpp */
