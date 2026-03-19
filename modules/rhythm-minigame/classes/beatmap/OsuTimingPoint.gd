extends RefCounted

var time: int = 0
var beatLength: float = 120.0
var meter: int = 4
var sampleSet: int = SampleSet.SAMPLE_SET_DEFAULT
var sampleIndex: float = 0
var volume: int = 50
var uninherited: int = 1
var effects: int = 0  #bit flags

enum SampleSet { SAMPLE_SET_DEFAULT, SAMPLE_SET_NORMAL, SAMPLE_SET_SOFT, SAMPLE_SET_DRUM }

enum OsuEffects {
	OSU_EFFECTS_KIAI_TIME = 0,
	OSU_EFFECTS_FIRST_BARLINE_OMITTED = 3,
}
