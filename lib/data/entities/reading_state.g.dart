// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingState _$ReadingStateFromJson(Map<String, dynamic> json) =>
    _ReadingState(
      pastText: json['pastText'] as String? ?? '',
      focusText: json['focusText'] as String? ?? '',
      upcomingText: json['upcomingText'] as String? ?? '',
      currentWordIndex: (json['currentWordIndex'] as num?)?.toInt() ?? 0,
      totalWords: (json['totalWords'] as num?)?.toInt() ?? 0,
      isPlaying: json['isPlaying'] as bool? ?? false,
      isComplete: json['isComplete'] as bool? ?? false,
      currentWpm: (json['currentWpm'] as num?)?.toInt() ?? 0,
      highlightedWord: json['highlightedWord'] as String?,
    );

Map<String, dynamic> _$ReadingStateToJson(_ReadingState instance) =>
    <String, dynamic>{
      'pastText': instance.pastText,
      'focusText': instance.focusText,
      'upcomingText': instance.upcomingText,
      'currentWordIndex': instance.currentWordIndex,
      'totalWords': instance.totalWords,
      'isPlaying': instance.isPlaying,
      'isComplete': instance.isComplete,
      'currentWpm': instance.currentWpm,
      'highlightedWord': instance.highlightedWord,
    };
