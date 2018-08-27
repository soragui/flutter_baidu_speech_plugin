//
//  AudioDataQueue.cpp
//  SDKTester
//
//  Created by lappi on 1/8/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "AudioDataQueue.hpp"

int AudioDataQueue::queueAudio(const uint8_t* audioData, int dataLength)
{
    if(dataLength == 0)
        return mDataLength;
    
    if (dataLength > mBufferCapacity) {
        audioData += (dataLength-mBufferCapacity);
        dataLength = mBufferCapacity;
    }
    long remainingLen = mDataEnd - mLoopEnd;
    long rightLen = remainingLen >= dataLength ? dataLength : remainingLen;
    memcpy(mLoopEnd, audioData, rightLen);
    mLoopEnd += rightLen;
    if (mLoopEnd == mDataEnd) {
        mLoopEnd = mData;
    }
    
    long leftLen = dataLength > rightLen ? dataLength - rightLen : 0;
    if (leftLen > 0) {
        memcpy(mLoopEnd, audioData + rightLen, leftLen);
        mLoopEnd += leftLen;
    }
    
    mDataLength += dataLength;
    if (mDataLength >= mBufferCapacity) {
        mDataLength = mBufferCapacity;
        mLoopStart = mLoopEnd;
    }
    
    return mDataLength;
}

int AudioDataQueue::dequeSamples(uint8_t* dataBuffer, int bufferSize, bool dequeRemaining)
{
    if (mDataLength >= bufferSize || dequeRemaining) {
        long tmp = mDataEnd - mLoopStart;
        long dataRightLen = tmp >= mDataLength ? mDataLength : tmp;
        long rightLen = dataRightLen >= bufferSize ? bufferSize : dataRightLen;
        memcpy(dataBuffer, mLoopStart, rightLen);
        mLoopStart += rightLen;
        if (mLoopStart == mDataEnd) {
            mLoopStart = mData;
        }
        
        long leftLen = 0;
        long left = bufferSize - rightLen;
        if (left > 0) {
            long dataLeftLen = mDataLength > dataRightLen ? mDataLength - dataRightLen : 0;
            leftLen = dataLeftLen >= left ? left : dataLeftLen;
            memcpy(dataBuffer + rightLen, mLoopStart, leftLen);
            mLoopStart += leftLen;
        }
        
        mDataLength -= bufferSize;
        if (mDataLength <= 0) {
            mDataLength = 0;
            mLoopStart = mLoopEnd = mData;
        }
        
        return (int)(rightLen + leftLen);
    }
    
    return 0;
}

bool AudioDataQueue::haveData()
{
    return (mDataLength > 0);
}

void AudioDataQueue::reset()
{
    mDataLength = 0;
    mDataEnd = mData + mBufferCapacity;
    mLoopStart = mLoopEnd = mData;
}

AudioDataQueue::AudioDataQueue(int bufferCapacity)
{
    mDataLength = 0;
    mBufferCapacity = bufferCapacity;
    
    mData = (uint8_t*)malloc(mBufferCapacity);
    mDataEnd = mData + mBufferCapacity;
    mLoopStart = mLoopEnd = mData;
}

AudioDataQueue::~AudioDataQueue()
{
    if(mData)
    {
        free(mData);
        mData = NULL;
        mDataEnd = NULL;
        mLoopStart = NULL;
        mLoopEnd = NULL;
    }
    mDataLength = 0;
    mBufferCapacity = 0;
}
