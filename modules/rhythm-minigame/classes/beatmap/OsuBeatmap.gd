extends Resource

var BeatmapVersion: int = -1

#[General]
var AudioFilename: String = ""
var AudioLeadIn: int = 0
var PreviewTime: int = 0
var Countdown: int = 0
var SampleSet: String
var StackLeniency: float = 0.7
var Mode: int = 3  #3 is osu!mania
var LetterboxInBreaks: int = 0
var SpecialStyle: int = 0
var WidescreenStoryboard: int = 0
var OverlayPosition: String = "NoChange"
var SkinPreference: String
var EpilepsyWarning: int = 0
var CountdownOffset: int = 0
var SamplesMatchPlaybackRate: int = 0

#[Editor] ###unused
var DistanceSpacing: float = 0.8
var BeatDivisor: int = 4
var GridSize: int = 8
var TimelineZoon: float = 1.7

#[Metadata]
var Title: String = ""
var TitleUnicode: String = ""
var Artist: String = ""
var ArtistUnicode: String = ""
var Creator: String = ""
var Version: String = "Normal"
var Source: String = ""
var Tags: String = ""
var BeatmapID: int = 0
var BeatmapSetID: int = 0

#[Difficulty] ### will probably be left unused
var HPDrainRate: int = 7
var CircleSize: int = 4
var OverallDifficulty: int = 7
var ApproachRate: int = 5
var SliderMultiplier: int = 1
var SliderTickRate: int = 1

#[Events]
var Events: Array = []  #Array of OsuEvents

#[TimingPoints]
var TimingPoints: Array = []  #Array of OsuTimingPoints

#[Colors]
var Colors: Dictionary = {}  #Color#: Color

#[HitObjects]
var HitObjects: Array = []  #Array of HitObjects


func has_hit_objects():
	return HitObjects.size() > 0
