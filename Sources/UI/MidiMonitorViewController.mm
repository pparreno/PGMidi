//
//  MidiMonitorViewController.m
//  MidiMonitor
//
//  Created by Pete Goodliffe on 10/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MidiMonitorViewController.h"

#import "PGMidiMessage.h"
#import "PGMidiSession.h"
#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>

UInt8 RandomNoteNumber() { return UInt8(rand() / (RAND_MAX / 127)); }

@interface MidiMonitorViewController () {
    PGMidiSession *session;
}
/*
- (void) updateCountLabel;
- (void) addString:(NSString*)string;
- (void) sendMidiDataInBackground;*/
@end

@implementation MidiMonitorViewController

#pragma mark PGMidiDelegate

@synthesize countLabel;
@synthesize textView;
//@synthesize midi;
@synthesize sendButton;

#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated
{
    session = [PGMidiSession sharedSession];
    
    // [self clearTextView];
    //[self updateCountLabel];

    /*IF_IOS_HAS_COREMIDI
    (
         [self addString:@"This iOS Version supports CoreMIDI"];
    )
    else
    {
        [self addString:@"You are running iOS before 4.2. CoreMIDI is not supported."];
    }*/
}

#pragma mark IBActions

- (IBAction) clearTextView
{
    textView.text = nil;
}

const char *ToString(BOOL b) { return b ? "yes":"no"; }

NSString *ToString(PGMidiConnection *connection)
{
    return [NSString stringWithFormat:@"< PGMidiConnection: name=%@ isNetwork=%s >",
            connection.name, ToString(connection.isNetworkSession)];
}
- (IBAction) listAllInterfaces
{
    /*IF_IOS_HAS_COREMIDI
    ({
        [self addString:@"\n\nInterface list:"];
        for (PGMidiSource *source in midi.sources)
        {
            NSString *description = [NSString stringWithFormat:@"Source: %@", ToString(source)];
            [self addString:description];
        }
        [self addString:@""];
        for (PGMidiDestination *destination in midi.destinations)
        {
            NSString *description = [NSString stringWithFormat:@"Destination: %@", ToString(destination)];
            [self addString:description];
        }
    })*/
}

- (IBAction) sendNoteOn0
{
    [session sendMidiMessage:[PGMidiMessage noteOn:0 withVelocity:127 withChannel:1] quantizedToFraction:0.25];
}

- (IBAction) sendNoteOff0
{
    [session sendMidiMessage:[PGMidiMessage noteOff:0 withVelocity:127 withChannel:1 withQuantizedNoteOffStrategy:QuantizedNoteOffStrategySameLength] quantizedToFraction:0.25];
}

- (IBAction) sendNoteOn1
{
    [session sendMidiMessage:[PGMidiMessage noteOn:1 withVelocity:127 withChannel:1] quantizedToFraction:0.25];
}

- (IBAction) sendNoteOff1
{
    [session sendMidiMessage:[PGMidiMessage noteOff:1 withVelocity:127 withChannel:1 withQuantizedNoteOffStrategy:QuantizedNoteOffStrategyOneStep] quantizedToFraction:0.25];
}

- (IBAction) sendNoteOn2
{
    [session sendMidiMessage:[PGMidiMessage noteOn:2 withVelocity:127 withChannel:1] quantizedToFraction:0.25];
}

- (IBAction) sendNoteOff2
{
    [session sendMidiMessage:[PGMidiMessage noteOff:2 withVelocity:127 withChannel:1] quantizedToFraction:0.25];
}

- (IBAction) sendMidiData
{
    [self performSelectorInBackground:@selector(sendMidiDataInBackground) withObject:nil];
}

#pragma mark Shenanigans

/*- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in midi.sources)
    {
        source.delegate = self;
    }
}

- (void) setMidi:(PGMidi*)m
{
    midi.delegate = nil;
    midi = m;
    midi.delegate = self;

    [self attachToAllExistingSources];
}

- (void) addString:(NSString*)string
{
    NSString *newText = [textView.text stringByAppendingFormat:@"\n%@", string];
    textView.text = newText;

    if (newText.length)
        [textView scrollRangeToVisible:(NSRange){newText.length-1, 1}];
}

- (void) updateCountLabel
{
    countLabel.text = [NSString stringWithFormat:@"sources=%u destinations=%u", midi.sources.count, midi.destinations.count];
}

- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    source.delegate = self;
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Source added: %@", ToString(source)]];
}

- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Source removed: %@", ToString(source)]];
}

- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Desintation added: %@", ToString(destination)]];
}

- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Desintation removed: %@", ToString(destination)]];
}

NSString *StringFromPacket(const MIDIPacket *packet)
{
    // Note - this is not an example of MIDI parsing. I'm just dumping
    // some bytes for diagnostics.
    // See comments in PGMidiSourceDelegate for an example of how to
    // interpret the MIDIPacket structure.
    return [NSString stringWithFormat:@"  %u bytes: [%02x,%02x,%02x]",
            packet->length,
            (packet->length > 0) ? packet->data[0] : 0,
            (packet->length > 1) ? packet->data[1] : 0,
            (packet->length > 2) ? packet->data[2] : 0
           ];
}

- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
    [self performSelectorOnMainThread:@selector(addString:)
                           withObject:@"MIDI received:"
                        waitUntilDone:NO];

    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        [self performSelectorOnMainThread:@selector(addString:)
                               withObject:StringFromPacket(packet)
                            waitUntilDone:NO];
        packet = MIDIPacketNext(packet);
    }
}

- (void) sendMidiDataInBackground
{
    for (int n = 0; n < 20; ++n)
    {
        const UInt8 note      = RandomNoteNumber();
        const UInt8 noteOn[]  = { 0x90, note, 127 };
        const UInt8 noteOff[] = { 0x80, note, 0   };

        [midi sendBytes:noteOn size:sizeof(noteOn)];
        [NSThread sleepForTimeInterval:0.1];
        [midi sendBytes:noteOff size:sizeof(noteOff)];
    }
}*/

@end
