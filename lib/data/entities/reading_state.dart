import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_state.freezed.dart';
part 'reading_state.g.dart';

@freezed
abstract class ReadingState with _$ReadingState {
  const factory ReadingState({
    @Default('') String pastText,
    @Default('') String focusText,
    @Default('') String upcomingText,
    @Default(0) int currentWordIndex,
    @Default(0) int totalWords,
    @Default(false) bool isPlaying,
    @Default(false) bool isComplete,
    @Default(0) int currentWpm,
    String? highlightedWord,
  }) = _ReadingState;

  factory ReadingState.fromJson(Map<String, dynamic> json) =>
      _$ReadingStateFromJson(json);
}
