/*
 * Copyright (c) 2024 HePinyin IME Contributors
 *
 * Licensed under the MIT License
 */

export {
  ShuangpinEngine,
  CandidateManager,
  CONSONANT_MAP,
  VOWEL_MAP,
  runTests,
  type EncodingResult,
  type InputState,
  type WordEntry
} from './ShuangpinEngine';

export {
  SwipeInputEngine,
  EdgeCaseHandler,
  type KeyPosition,
  type GesturePoint,
  type SwipePath,
  type EdgeCaseType,
  EdgeCaseType as SwipeEdgeCase
} from './SwipeInputEngine';

export {
  Log
} from './Log';

export {
  Logger
} from './Logger';