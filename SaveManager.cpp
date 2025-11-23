//
//  SaveManager.cpp
//  Grape
//
//  Created by Jarrod Norwell on 19/8/2025.
//

#include <stdio.h>
#include <string.h>

#include "SaveManager.h"
#include "Platform.h"

void SaveManager::start() {
    thread = std::jthread([this](std::stop_token stoken) {
        run(stoken);
    });
}

void SaveManager::stop() {
    thread.request_stop();  // cooperative stop request
    if (thread.joinable())
        thread.join();
}

SaveManager::SaveManager(std::string path) {
    SecondaryBuffer = nullptr;
    SecondaryBufferLength = 0;

    Running = false;

    Path = path;

    Buffer = nullptr;
    Length = 0;
    FlushRequested = false;

    FlushVersion = 0;
    PreviousFlushVersion = 0;
    TimeAtLastFlushRequest = 0;

    if (!path.empty())
    {
        Running = true;
        start();
    }
}

SaveManager::~SaveManager()
{
    if (Running)
    {
        Running = false;
        stop();
        FlushSecondaryBuffer();
    }

    if (SecondaryBuffer) delete[] SecondaryBuffer;

    // delete SecondaryBufferLock;

    if (Buffer) delete[] Buffer;
}

std::string SaveManager::GetPath()
{
    return Path;
}

void SaveManager::SetPath(std::string path, bool reload)
{
    Path = path;

    if (reload)
    {
        FILE* f = Platform::OpenFile(Path, "rb", true);
        if (f)
        {
            fread(Buffer, 1, Length, f);
            fclose(f);
        }
    }
    else
        FlushRequested = true;
}

void SaveManager::RequestFlush(const u8* savedata, u32 savelen, u32 writeoffset, u32 writelen)
{
    if (Length != savelen)
    {
        if (Buffer) delete[] Buffer;

        Length = savelen;
        Buffer = new u8[Length];

        memcpy(Buffer, savedata, Length);
    }
    else
    {
        if ((writeoffset+writelen) > savelen)
        {
            u32 len = savelen - writeoffset;
            memcpy(&Buffer[writeoffset], &savedata[writeoffset], len);
            len = writelen - len;
            if (len > savelen) len = savelen;
            memcpy(&Buffer[0], &savedata[0], len);
        }
        else
        {
            memcpy(&Buffer[writeoffset], &savedata[writeoffset], writelen);
        }
    }

    FlushRequested = true;
}

void SaveManager::CheckFlush()
{
    if (!FlushRequested) return;

    std::unique_lock lock{SecondaryBufferLock};
    lock.lock();

    printf("SaveManager: Flush requested\n");

    if (SecondaryBufferLength != Length)
    {
        if (SecondaryBuffer) delete[] SecondaryBuffer;

        SecondaryBufferLength = Length;
        SecondaryBuffer = new u8[SecondaryBufferLength];
    }

    memcpy(SecondaryBuffer, Buffer, Length);

    FlushRequested = false;
    FlushVersion++;
    TimeAtLastFlushRequest = time(nullptr);

    lock.unlock();
}

void SaveManager::run(std::stop_token token)
{
    while (!token.stop_requested())
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));

        if (!Running) return;

        // We debounce for two seconds after last flush request to ensure that writing has finished.
        if (TimeAtLastFlushRequest == 0 || difftime(time(nullptr), TimeAtLastFlushRequest) < 2)
        {
            continue;
        }

        FlushSecondaryBuffer();
    }
}

void SaveManager::FlushSecondaryBuffer(u8* dst, u32 dstLength)
{
    if (!SecondaryBuffer) return;

    // When flushing to a file, there's no point in re-writing the exact same data.
    if (!dst && !NeedsFlush()) return;
    // When flushing to memory, we don't know if dst already has any data so we only check that we CAN flush.
    if (dst && dstLength < SecondaryBufferLength) return;

    std::unique_lock lock{SecondaryBufferLock};
    lock.lock();
    if (dst)
    {
        memcpy(dst, SecondaryBuffer, SecondaryBufferLength);
    }
    else
    {
        FILE* f = Platform::OpenFile(Path, "wb");
        if (f)
        {
            printf("SaveManager: Written\n");
            fwrite(SecondaryBuffer, SecondaryBufferLength, 1, f);
            fclose(f);
        }
    }
    PreviousFlushVersion = FlushVersion;
    TimeAtLastFlushRequest = 0;
    lock.unlock();
}

bool SaveManager::NeedsFlush()
{
    return FlushVersion != PreviousFlushVersion;
}
