package grig.midi;

enum abstract ControlChangeType(Int) to Int
{
    var BankSelectMSB =      0x00;
    var BankSelectLSB =      0x20;
    var ModulationMSB =      0x01;
    var ModulationLSB =      0x21;
    var BreathMSB =          0x02;
    var BreathLSB =          0x22;
    var FootPedalMSB =       0x04;
    var FootPedalLSB =       0x24;
    var PortamentoTimeMSB =  0x05;
    var PortamentoTimeLSB =  0x25;
    var DataEntryMSB =       0x06;
    var DataEntryLSB =       0x26;
    var VolumeMSB =          0x07;
    var VolumeLSB =          0x27;
    var BalanceMSB =         0x08;
    var BalanceLSB =         0x28;
    var PanPositionMSB =     0x0a;
    var PanPositionLSB =     0x2a;
    var ExpressionMSB =      0x0b;
    var ExpressionLSB =      0x2b;
    var EffectControl1MSB =  0x0c;
    var EffectControl1LSB =  0x2c;
    var EffectControl2MSB =  0x0d;
    var EffectControl2LSB =  0x2d;
    var RibbonController =   0x10;
    var Knob1 =              0x11;
    var GeneralSlider3 =     0x12;
    var Knob2 =              0x13;
    var Knob3 =              0x14;
    var Knob4 =              0x15;
    var Sustain =            0x40;
    var Portamento =         0x41;
    var SostenutoPedal =     0x42;
    var SoftPedal =          0x43;
    var LegatoPedal =        0x44;
    var Hold2Pedal =         0x45;
    var SoundVariation =     0x46;
    var Resonance =          0x47;
    var SoundReleaseTime =   0x48;
    var SoundAttackTime =    0x49;
    var FrequencyCutoff =    0x4a;
    var SoundControl6 =      0x4b;
    var SoundControl7 =      0x4c;
    var SoundControl8 =      0x4d;
    var SoundControl9 =      0x4e;
    var SoundControl10 =     0x4f;
    var Decay =              0x50;
    var HPFFrequency =       0x51;
    var GeneralPurposeBtn3 = 0x52;
    var GeneralPurposeBtn4 = 0x53;
    var ReverbLevel =        0x5b;
    var TremoloLevel =       0x5c;
    var ChorusLevel =        0x5d;
    var Detune =             0x5e;
    var Phaser =             0x5f;
    var DataBtnIncrement =   0x60;
    var DataBtnDecrement =   0x61;
    var UnregisteredMSB =    0x62;
    var UnregisteredLSB =    0x63;
    var RegisteredMSB =      0x64;
    var RegisteredLSB =      0x65;
    var AllSoundOff =        0x78;
    var AllControllersOff =  0x79;
    var LocalKeyboard =      0x7a;
    var AllNotesOff =        0x7b;
    var OmniModeOff =        0x7c;
    var OmniModeOn =         0x7d;
    var MonoOperation =      0x7e;
    var PolyOperation =      0x7f;
    var Undefined =            -1;
    var NonControl =           -2;
    var Invalid =              -3;

    private function new(byte:Int)
    {
        this = byte;
    }

    public static function ofByte(byte:Int):ControlChangeType
    {
        if (byte < 0 || byte > 0x7f) return Invalid;
        return new ControlChangeType(byte);
    }
}