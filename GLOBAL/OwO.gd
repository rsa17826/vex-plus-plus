@tool
class_name OwO
# --- Regex Constants ---
static var END_SENTENCE_PATTERN := "([\\w ,.!?]+)?"
# static var END_SENTENCE_PATTERN_1 := "([\\w ,.?]+)?"
# static var END_SENTENCE_PATTERN_2 := "([\\w ,.]+)?"
static var VOWEL := "[aiueo]"
static var VOWEL_NO_E := "[aiuo]"
static var VOWEL_NO_IE := "[auo]"
static var ZACKQY_WORD := "[jzckq]"

# --- Compiled RegEx ---
# We compile them once to reuse them
# --- Emotes ---
static var REGEX_BORED: RegEx = _create_regex("(?i)(i(?:'|)m(?:\\s+|\\s+so+\\s+)bored)$%s" % END_SENTENCE_PATTERN)
static var REGEX_LOVE: RegEx = _create_regex("(?i)(love\\s+(?:you|him|her|them))$%s" % END_SENTENCE_PATTERN)
static var REGEX_CARE: RegEx = _create_regex("(?i)(i\\s+don(?:'|)t\\s+care|i\\s*d\\s*c)$%s" % END_SENTENCE_PATTERN)

# --- Word Substitution ---
static var REGEX_SUB_LUV: RegEx = _create_regex("(?i)l[ou]ve?" % VOWEL)

# --- Translation ---
static var REGEX_SUB_R: RegEx = _create_regex("(?i)r")
# Fixed-width alternatives for [wl][aiueo]: 2 chars
static var L_FIXED_2 = "[wl]%s" % VOWEL

# Fixed-width alternatives for [wl][aiueo][aiueo]: 3 chars
static var L_FIXED_3 = "[wl]%s%s" % [VOWEL, VOWEL]

# The full fixed-width lookbehind pattern:
# (?<!(2-char pattern)|(3-char pattern)|l)

static var REGEX_SUB_L: RegEx = _create_regex("(?i)(?<!(%s)|(%s)|l)l(?!(${vowel}?l+)|.%s)(?![lw])" % [L_FIXED_3, L_FIXED_2, VOWEL])
# static var REGEX_SUB_L : RegEx= _create_regex("(?i)(?<!([wl]%s{1,5})|l)l(?!(%s?l+)|.%s)" % [VOWEL, VOWEL, VOWEL])
static var REGEX_SUB_NYA_ALL_LOWER: RegEx = _create_regex("[nN]([aiuo]+)")
static var REGEX_SUB_NYA_LATER_UPPER: RegEx = _create_regex("N([AIUO]+)")
static var REGEX_SUB_MYA: RegEx = _create_regex("(?i)m(%s+)(?!w*%s)" % [VOWEL_NO_IE, ZACKQY_WORD])
static var REGEX_SUB_PWA: RegEx = _create_regex("(?i)p(%s+)(?!w*%s)" % [VOWEL_NO_IE, ZACKQY_WORD])

static var REGEX_END_SPACE := _create_regex("^\\s+$")

# --- Helpers ---

## Helper to create a case-insensitive RegEx object
static func _create_regex(pattern: String) -> RegEx:
  var regex = RegEx.new()
  # log.pp(pattern)
  regex.compile(pattern, true)
  return regex

## Main owowify function
static func owowify(input_text: String) -> String:
  var result = input_text

  # --- OwO emote ---
  result = _custom_replace(result, REGEX_BORED, _sub_owo_emote("-w-"))
  result = _custom_replace(result, REGEX_LOVE, _sub_owo_emote("uwu"))
  result = _custom_replace(result, REGEX_CARE, _sub_owo_emote("0w0"))

  # --- world substitution ---
  # ($0 => subSameCase($0, "luv"))
  var sub_luv = func(match): return _sub_same_case(match, "luv")
  result = _custom_replace(result, REGEX_SUB_LUV, sub_luv)

  # --- OwO translation ---
  # ($0 => subSameCase($0, "w"))
  var sub_w = func(match, ...__):
    return _sub_same_case(match, "w")
  result = _custom_replace(result, REGEX_SUB_R, sub_w)
  result = _custom_replace(result, REGEX_SUB_L, sub_w)

  # ($0, $vowel) => subSameCase($0, `ny${$vowel}`)
  var sub_nya = func(match, vowel, ...__): return _sub_same_case(match, "ny" + vowel)
  result = _custom_replace(result, REGEX_SUB_NYA_ALL_LOWER, sub_nya)
  result = _custom_replace(result, REGEX_SUB_NYA_LATER_UPPER, sub_nya)

  # ($0, $vowel) => subSameCase($0, `my${$vowel}`)
  var sub_mya = func(match, vowel, ...__): return _sub_same_case(match, "my" + vowel)
  result = _custom_replace(result, REGEX_SUB_MYA, sub_mya)

  # ($0, $vowel) => subSameCase($0, `pw${$vowel}`)
  var sub_pwa = func(match, vowel, ...__): return _sub_same_case(match, "pw" + vowel)
  result = _custom_replace(result, REGEX_SUB_PWA, sub_pwa)

  return result

## Helper to replicate JS .replace(regex, callback)
## Since RegEx.sub() doesn't support Callables, we do it manually.
static func _custom_replace(input_text: String, regex: RegEx, callback: Callable) -> String:
  var new_string_parts = []
  var last_index = 0

  for match in regex.search_all(input_text):
    var start = match.get_start()
    var end = match.get_end()

    # 1. Add the text *before* the match
    # log.pp(input_text, last_index, start - last_index, new_string_parts)
    new_string_parts.append(input_text.substr(last_index, start - last_index))

    # 2. Prepare arguments for the callback
    var original_match = match.get_string(0)
    var args = [original_match]
    for i in range(1, match.get_group_count() + 1):
      args.append(match.get_string(i))

    # 3. Call the callback and add the replacement text
    var replacement = callback.callv(args)
    # log.pp(replacement, new_string_parts, args, callback)
    new_string_parts.append(replacement)

    last_index = end

  # 4. Add any remaining text after the last match
  # log.pp(last_index, input_text, new_string_parts)
  new_string_parts.append(input_text.substr(last_index))
  return "".join(new_string_parts)

## Port of subOwoEmote
## This returns a Callable (lambda) that captures the 'emote' variable.
static func _sub_owo_emote(emote: String) -> Callable:
  var callback = func(original_match, sentence_before_end, end_sentence):
    # In JS, an optional unmatched group is 'undefined'.
    # In GDScript, RegExMatch.get_string() returns an empty string "".
    if end_sentence.is_empty() or REGEX_END_SPACE.search(end_sentence):
      return "%s %s" % [sentence_before_end, emote]
    else:
      return original_match
  return callback

## Port of subSameCase
static func _sub_same_case(input_text: String, replace_text: String) -> String:
  var result = ""

  for i in range(replace_text.length()):
    var rep_char = replace_text[i]
    if i < input_text.length():
      var in_char = input_text[i]

      # --- CORRECTED LINES ---
      # Check if the character is already uppercase
      if in_char in 'QWERTYUIOPASDFGHJKLZXCVBNM':
        result += rep_char.to_upper()
      # Check if the character is already lowercase
      elif in_char in 'qwertyuiopasdfghjklzxcvbnm':
        result += rep_char.to_lower()
      # --- END CORRECTION ---

      else:
        result += rep_char # Non-cased character
    else:
      result += rep_char # replace_text is longer than input_text

  return result
