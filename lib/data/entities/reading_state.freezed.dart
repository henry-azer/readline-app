// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingState {

 String get pastText; String get focusText; String get upcomingText; int get currentWordIndex; int get totalWords; bool get isPlaying; bool get isComplete; int get currentWpm; String? get highlightedWord;
/// Create a copy of ReadingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingStateCopyWith<ReadingState> get copyWith => _$ReadingStateCopyWithImpl<ReadingState>(this as ReadingState, _$identity);

  /// Serializes this ReadingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingState&&(identical(other.pastText, pastText) || other.pastText == pastText)&&(identical(other.focusText, focusText) || other.focusText == focusText)&&(identical(other.upcomingText, upcomingText) || other.upcomingText == upcomingText)&&(identical(other.currentWordIndex, currentWordIndex) || other.currentWordIndex == currentWordIndex)&&(identical(other.totalWords, totalWords) || other.totalWords == totalWords)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.currentWpm, currentWpm) || other.currentWpm == currentWpm)&&(identical(other.highlightedWord, highlightedWord) || other.highlightedWord == highlightedWord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pastText,focusText,upcomingText,currentWordIndex,totalWords,isPlaying,isComplete,currentWpm,highlightedWord);

@override
String toString() {
  return 'ReadingState(pastText: $pastText, focusText: $focusText, upcomingText: $upcomingText, currentWordIndex: $currentWordIndex, totalWords: $totalWords, isPlaying: $isPlaying, isComplete: $isComplete, currentWpm: $currentWpm, highlightedWord: $highlightedWord)';
}


}

/// @nodoc
abstract mixin class $ReadingStateCopyWith<$Res>  {
  factory $ReadingStateCopyWith(ReadingState value, $Res Function(ReadingState) _then) = _$ReadingStateCopyWithImpl;
@useResult
$Res call({
 String pastText, String focusText, String upcomingText, int currentWordIndex, int totalWords, bool isPlaying, bool isComplete, int currentWpm, String? highlightedWord
});




}
/// @nodoc
class _$ReadingStateCopyWithImpl<$Res>
    implements $ReadingStateCopyWith<$Res> {
  _$ReadingStateCopyWithImpl(this._self, this._then);

  final ReadingState _self;
  final $Res Function(ReadingState) _then;

/// Create a copy of ReadingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pastText = null,Object? focusText = null,Object? upcomingText = null,Object? currentWordIndex = null,Object? totalWords = null,Object? isPlaying = null,Object? isComplete = null,Object? currentWpm = null,Object? highlightedWord = freezed,}) {
  return _then(_self.copyWith(
pastText: null == pastText ? _self.pastText : pastText // ignore: cast_nullable_to_non_nullable
as String,focusText: null == focusText ? _self.focusText : focusText // ignore: cast_nullable_to_non_nullable
as String,upcomingText: null == upcomingText ? _self.upcomingText : upcomingText // ignore: cast_nullable_to_non_nullable
as String,currentWordIndex: null == currentWordIndex ? _self.currentWordIndex : currentWordIndex // ignore: cast_nullable_to_non_nullable
as int,totalWords: null == totalWords ? _self.totalWords : totalWords // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,currentWpm: null == currentWpm ? _self.currentWpm : currentWpm // ignore: cast_nullable_to_non_nullable
as int,highlightedWord: freezed == highlightedWord ? _self.highlightedWord : highlightedWord // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingState].
extension ReadingStatePatterns on ReadingState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingState value)  $default,){
final _that = this;
switch (_that) {
case _ReadingState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingState value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pastText,  String focusText,  String upcomingText,  int currentWordIndex,  int totalWords,  bool isPlaying,  bool isComplete,  int currentWpm,  String? highlightedWord)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingState() when $default != null:
return $default(_that.pastText,_that.focusText,_that.upcomingText,_that.currentWordIndex,_that.totalWords,_that.isPlaying,_that.isComplete,_that.currentWpm,_that.highlightedWord);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pastText,  String focusText,  String upcomingText,  int currentWordIndex,  int totalWords,  bool isPlaying,  bool isComplete,  int currentWpm,  String? highlightedWord)  $default,) {final _that = this;
switch (_that) {
case _ReadingState():
return $default(_that.pastText,_that.focusText,_that.upcomingText,_that.currentWordIndex,_that.totalWords,_that.isPlaying,_that.isComplete,_that.currentWpm,_that.highlightedWord);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pastText,  String focusText,  String upcomingText,  int currentWordIndex,  int totalWords,  bool isPlaying,  bool isComplete,  int currentWpm,  String? highlightedWord)?  $default,) {final _that = this;
switch (_that) {
case _ReadingState() when $default != null:
return $default(_that.pastText,_that.focusText,_that.upcomingText,_that.currentWordIndex,_that.totalWords,_that.isPlaying,_that.isComplete,_that.currentWpm,_that.highlightedWord);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingState implements ReadingState {
  const _ReadingState({this.pastText = '', this.focusText = '', this.upcomingText = '', this.currentWordIndex = 0, this.totalWords = 0, this.isPlaying = false, this.isComplete = false, this.currentWpm = 0, this.highlightedWord});
  factory _ReadingState.fromJson(Map<String, dynamic> json) => _$ReadingStateFromJson(json);

@override@JsonKey() final  String pastText;
@override@JsonKey() final  String focusText;
@override@JsonKey() final  String upcomingText;
@override@JsonKey() final  int currentWordIndex;
@override@JsonKey() final  int totalWords;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool isComplete;
@override@JsonKey() final  int currentWpm;
@override final  String? highlightedWord;

/// Create a copy of ReadingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingStateCopyWith<_ReadingState> get copyWith => __$ReadingStateCopyWithImpl<_ReadingState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingState&&(identical(other.pastText, pastText) || other.pastText == pastText)&&(identical(other.focusText, focusText) || other.focusText == focusText)&&(identical(other.upcomingText, upcomingText) || other.upcomingText == upcomingText)&&(identical(other.currentWordIndex, currentWordIndex) || other.currentWordIndex == currentWordIndex)&&(identical(other.totalWords, totalWords) || other.totalWords == totalWords)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.currentWpm, currentWpm) || other.currentWpm == currentWpm)&&(identical(other.highlightedWord, highlightedWord) || other.highlightedWord == highlightedWord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pastText,focusText,upcomingText,currentWordIndex,totalWords,isPlaying,isComplete,currentWpm,highlightedWord);

@override
String toString() {
  return 'ReadingState(pastText: $pastText, focusText: $focusText, upcomingText: $upcomingText, currentWordIndex: $currentWordIndex, totalWords: $totalWords, isPlaying: $isPlaying, isComplete: $isComplete, currentWpm: $currentWpm, highlightedWord: $highlightedWord)';
}


}

/// @nodoc
abstract mixin class _$ReadingStateCopyWith<$Res> implements $ReadingStateCopyWith<$Res> {
  factory _$ReadingStateCopyWith(_ReadingState value, $Res Function(_ReadingState) _then) = __$ReadingStateCopyWithImpl;
@override @useResult
$Res call({
 String pastText, String focusText, String upcomingText, int currentWordIndex, int totalWords, bool isPlaying, bool isComplete, int currentWpm, String? highlightedWord
});




}
/// @nodoc
class __$ReadingStateCopyWithImpl<$Res>
    implements _$ReadingStateCopyWith<$Res> {
  __$ReadingStateCopyWithImpl(this._self, this._then);

  final _ReadingState _self;
  final $Res Function(_ReadingState) _then;

/// Create a copy of ReadingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pastText = null,Object? focusText = null,Object? upcomingText = null,Object? currentWordIndex = null,Object? totalWords = null,Object? isPlaying = null,Object? isComplete = null,Object? currentWpm = null,Object? highlightedWord = freezed,}) {
  return _then(_ReadingState(
pastText: null == pastText ? _self.pastText : pastText // ignore: cast_nullable_to_non_nullable
as String,focusText: null == focusText ? _self.focusText : focusText // ignore: cast_nullable_to_non_nullable
as String,upcomingText: null == upcomingText ? _self.upcomingText : upcomingText // ignore: cast_nullable_to_non_nullable
as String,currentWordIndex: null == currentWordIndex ? _self.currentWordIndex : currentWordIndex // ignore: cast_nullable_to_non_nullable
as int,totalWords: null == totalWords ? _self.totalWords : totalWords // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,currentWpm: null == currentWpm ? _self.currentWpm : currentWpm // ignore: cast_nullable_to_non_nullable
as int,highlightedWord: freezed == highlightedWord ? _self.highlightedWord : highlightedWord // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
