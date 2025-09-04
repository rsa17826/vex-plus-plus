/*
	Name: Array.ahk
	Version 0.4 (05.09.23)
	Created: 27.08.22
	Author: Descolada

	Description:
	A compilation of useful array methods.

    Array.Slice(start:=1, end:=0, step:=1)  => Returns a section of the array from 'start' to 'end',
        optionally skipping elements with 'step'.
    Array.Swap(a, b)                        => Swaps elements at indexes a and b.
    Array.Map(func, arrays*)                => Applies a function to each element in the array.
    Array.ForEach(func)                     => Calls a function for each element in the array.
    Array.Filter(func)                      => Keeps only values that satisfy the provided function
    Array.Reduce(func, initialValue?)       => Applies a function cumulatively to all the values in
        the array, with an optional initial value.
    Array.IndexOf(value, start:=1)          => Finds a value in the array and returns its index.
    Array.Find(func, &match?, start:=1)     => Finds a value satisfying the provided function and returns the index.
        match will be set to the found value.
    Array.Reverse()                         => Reverses the array.
    Array.Count(value)                      => Counts the number of occurrences of a value.
    Array.Sort(OptionsOrCallback?, Key?)    => Sorts an array, optionally by object values.
    Array.Shuffle()                         => Randomizes the array.
    Array.Join(delim:=",")                  => Joins all the elements to a string using the provided delimiter.
    Array.Flat()                            => Turns a nested array into a one-level array.
    Array.Extend(enums*)                    => Adds the values of other arrays or enumerables to the end of this one.
*/

Array.Prototype.base := Array2
class Array2 {
  ; #############
  static Length := 0
  static push(*) {
  }
  static pushFront(a*) {
    this.reverse()
    this.push(a*)
    this.reverse()
  }
  static __Enum(*) {
  }
  ; #############

  ; static __New() {
  ;   ; Add String2 methods and properties into String object
  ;   __ObjDefineProp := Object.Prototype.DefineProp
  ;   for __String2_Prop in Array2.OwnProps()
  ;     if SubStr(__String2_Prop, 1, 2) != "__"
  ;       __ObjDefineProp(Array.Prototype, __String2_Prop, Array2.GetOwnPropDesc(__String2_Prop))
  ;   ; __ObjDefineProp(Array.Prototype, "__Item", {
  ;   ;   get: (args*) => Array2.__Item[args*]
  ;   ; })
  ;   ; __ObjDefineProp(String.Prototype, "__Enum", {
  ;   ;   call: Array2.__Enum
  ;   ; })
  ; }

  static substr => this.sub
  static substring => this.sub
  static sub(start, end) {
    if end < 0
      end := this.Length + (end + 1)
    temp := []
    loop end - start + 1 {
      temp.push(this[start + A_Index - 1])
    }
    return temp
  }
  static random() {
    return this[random(1, this.Length)]
  }

  /**
   * returns a random item from the array
   */
  static randFrom() {
    idx := Random(1, this.Length)
    return this[idx]
  }

  /**
   * Returns a section of the array from 'start' to 'end', optionally skipping elements with 'step'.
   * Modifies the original array.
   * @param start Optional: index to start from. Default is 1.
   * @param end Optional: index to end at. Can be negative. Default is 0 (includes the last element).
   * @param step Optional: an integer specifying the incrementation. Default is 1.
   * @returns {Array}
   */
  static Slice(start := 1, end := 0, step := 1) {
    local reverse
    len := this.Length, i := start < 1 ? len + start : start, j := Min(end < 1 ? len + end : end, len), r := [], reverse := False
    if len = 0
      return []
    if i < 1
      i := 1
    if step = 0
      Throw(Error("Slice: step cannot be 0", -1))
    else if step < 0 {
      while i >= j {
        r.Push(this[i])
        i += step
      }
    } else {
      while i <= j {
        r.Push(this[i])
        i += step
      }
    }
    return this := r
  }

  /**
   * Swaps elements at indexes a and b
   * @param a First elements index to swap
   * @param b Second elements index to swap
   * @returns {Array}
   */
  static Swap(a, b) {
    temp := this[b]
    this[b] := this[a]
    this[a] := temp
    return this
  }

  /**
   * Applies a function to each element in the array (mutates the array).
   * @param func The mapping function that accepts one argument.
   * @returns {Array}
   */
  static toMapped(func) {
    if !HasMethod(func)
      throw(ValueError("Map: func must be a function", -1))
    for i, v in this {
      this[i] := callFuncWithOptionalArgs(func, v?, i)
    }
    return this
  }

  /**
   * Applies a function to each element in the array (mutates the array).
   * @param func The mapping function that accepts one argument.
   * @returns {Array}
   */
  static Map(func) {
    if !HasMethod(func)
      throw(ValueError("Map: func must be a function", -1))
    newarr := [
      this*
    ]
    for i, v in this {
      newarr[i] := callFuncWithOptionalArgs(func, v?, i)
    }
    return newarr
  }

  /**
   * Applies a function to each element in the array.
   * @param func The callback function with arguments Callback(value[, index, array]).
   * @returns {Array}
   */
  static ForEach(func) {
    if !HasMethod(func)
      throw(ValueError("ForEach: func must be a function", -1))
    for i, v in this
      func(v, i, this)
    return this
  }

  /**
   * Keeps only values that satisfy the provided function
   * @param func The filter function that accepts one argument.
   * @returns {Array}
   */
  static Filter(func) {
    if !HasMethod(func)
      throw(ValueError("Filter: func must be a function", -1))
    r := []
    for v in this
      if func(v)
        r.Push(v)
    return this := r
  }

  /**
   * Applies a function cumulatively to all the values in the array, with an optional initial value.
   * @param func The function that accepts two arguments and returns one value
   * @param initialValue Optional: the starting value. If omitted, the first value in the array is used.
   * @returns {func return type}
   * @example
   * [1,2,3,4,5].Reduce((a,b) => (a+b)) ; returns 15 (the sum of all the numbers)
   */
  static Reduce(func, initialValue?) {
    if !HasMethod(func)
      throw(ValueError("Reduce: func must be a function", -1))
    len := this.Length + 1
    if len = 1
      return initialValue ?? ""
    if IsSet(initialValue)
      out := initialValue, i := 0
    else
      out := this[1], i := 1
    while ++i < len {
      out := func(out, this[i])
    }
    return out
  }

  /**
   * returns true if the item was found
   * @param value The value to search for.
   * @param start Optional: the index to start the search from. Default is 1.
   * @returns {Boolean} 
   */
  static includes(value, start := 1) {
    return !!this.IndexOf(value, start)
  }

  /**
   * Finds a value in the array and returns its index.
   * @param value The value to search for.
   * @param start Optional: the index to start the search from. Default is 1.
   */
  static IndexOf(value, start := 1) {
    if !IsInteger(start)
      throw(ValueError("IndexOf: start value must be an integer"))
    for i, v in this {
      if i < start
        continue
      if IsSet(v) && IsSet(value) {
        if v == value
          return i
      } else if !IsSet(v) && !IsSet(value)
        return i
    }
    return 0
  }

  ; static IndexOfFunc(value, start := 1) {
  ;   if !IsInteger(start)
  ;     throw ValueError("IndexOf: start value must be an integer")
  ;   for i, v in this {
  ;     if i < start
  ;       continue
  ;     if value(v, i)
  ;       return i
  ;   }
  ;   return 0
  ; }

  /**
   * Finds a value satisfying the provided function and returns its index.
   * @param func The condition function that accepts one argument.
   * @param match Optional: is set to the found value
   * @param start Optional: the index to start the search from. Default is 1.
   * @example
   * [1,2,3,4,5].Find((v) => (Mod(v,2) == 0)) ; returns 2
   */
  static Find(func, &match?, start := 1) {
    if !HasMethod(func)
      throw(ValueError("Find: func must be a function", -1))
    for i, v in this {
      if i < start
        continue
      if callFuncWithOptionalArgs(func, v?, i) {
        match := v
        return i
      }
    }
    return 0
  }

  /**
   * Reverses the array.
   * @example
   * [1,2,3].Reverse() ; returns [3,2,1]
   */
  static Reverse() {
    local max
    len := this.Length + 1, max := (len // 2), i := 0
    while ++i <= max
      this.Swap(i, len - i)
    return this
  }

  /**
   * Counts the number of occurrences of a value
   * @param value The value to count. Can also be a function.
   */
  static Count(value) {
    local count
    count := 0
    if HasMethod(value) {
      for _, v in this
        if value(v?)
          count++
    } else
      for _, v in this
        if v == value
          count++
    return count
  }

  /**
   * Sorts an array, optionally by object keys
   * @param OptionsOrCallback Optional: either a callback function, or one of the following:
   * 
   *     N => array is considered to consist of only numeric values. This is the default option.
   *     C, C1 or COn => case-sensitive sort of strings
   *     C0 or COff => case-insensitive sort of strings
   * 
   *     The callback function should accept two parameters elem1 and elem2 and return an integer:
   *     Return integer < 0 if elem1 less than elem2
   *     Return 0 is elem1 is equal to elem2
   *     Return > 0 if elem1 greater than elem2
   * @param Key Optional: Omit it if you want to sort a array of primitive values (strings, numbers etc).
   *     If you have an array of objects, specify here the key by which contents the object will be sorted.
   * @returns {Array}
   */
  static Sort(optionsOrCallback := "N", key?) {
    static sizeofFieldType := 16 ; Same on both 32-bit and 64-bit
    if HasMethod(optionsOrCallback)
      pCallback := CallbackCreate(CustomCompare.Bind(optionsOrCallback), "F Cdecl", 2), optionsOrCallback := ""
    else {
      if InStr(optionsOrCallback, "N")
        pCallback := CallbackCreate(IsSet(key) ? NumericCompareKey.Bind(key) : NumericCompare, "F CDecl", 2)
      if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn")
        pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key, , True) : StringCompare.Bind(, , True), "F CDecl", 2)
      if RegExMatch(optionsOrCallback, "i)C0|COff")
        pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key) : StringCompare, "F CDecl", 2)
      if InStr(optionsOrCallback, "Random")
        pCallback := CallbackCreate(RandomCompare, "F CDecl", 2)
      if !IsSet(pCallback)
        throw(ValueError("No valid options provided!", -1))
    }
    mFields := NumGet(ObjPtr(this) + (8 + (VerCompare(A_AhkVersion, "<2.1-") > 0 ? 3 : 5) * A_PtrSize), "Ptr") ; in v2.0: 0 is VTable. 2 is mBase, 3 is mFields, 4 is FlatVector, 5 is mLength and 6 is mCapacity
    DllCall("msvcrt.dll\qsort", "Ptr", mFields, "UInt", this.Length, "UInt", sizeofFieldType, "Ptr", pCallback, "Cdecl")
    CallbackFree(pCallback)
    if RegExMatch(optionsOrCallback, "i)R(?!a)")
      this.Reverse()
    if InStr(optionsOrCallback, "U")
      this := this.Unique()
    return this

    CustomCompare(compareFunc, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), compareFunc(fieldValue1, fieldValue2))
    NumericCompare(pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (fieldValue1 > fieldValue2) - (fieldValue1 < fieldValue2))
    NumericCompareKey(key, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (f1 := fieldValue1.HasProp("__Item") ? fieldValue1[key] : fieldValue1.%key%), (f2 := fieldValue2.HasProp("__Item") ? fieldValue2[key] : fieldValue2.%key%), (f1 > f2) - (f1 < f2))
    StringCompare(pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1 "", fieldValue2 "", casesense))
    StringCompareKey(key, pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1.%key% "", fieldValue2.%key% "", casesense))
    RandomCompare(pFieldType1, pFieldType2) => (Random(0, 1) ? 1 : -1)

    ValueFromFieldType(pFieldType, &fieldValue?) {
      static SYM_STRING := 0, PURE_INTEGER := 1, PURE_FLOAT := 2, SYM_MISSING := 3, SYM_OBJECT := 5
      switch SymbolType := NumGet(pFieldType + 8, "Int") {
        case PURE_INTEGER: fieldValue := NumGet(pFieldType, "Int64")
        case PURE_FLOAT: fieldValue := NumGet(pFieldType, "Double")
        case SYM_STRING: fieldValue := StrGet(NumGet(pFieldType, "Ptr") + 2 * A_PtrSize)
        case SYM_OBJECT: fieldValue := ObjFromPtrAddRef(NumGet(pFieldType, "Ptr"))
        case SYM_MISSING: return
      }
    }
  }

  /**
   * Randomizes the array. Slightly faster than Array.Sort(,"Random N")
   * @returns {Array}
   */
  static Shuffle() {
    len := this.Length
    loop len - 1
      this.Swap(A_index, Random(A_index, len))
    return this
  }

  /**
   * 
   */
  static Unique() {
    unique := Map()
    for v in this
      unique[v] := 1
    return [
      unique*
    ]
  }

  /**
   * Joins all the elements to a string using the provided delimiter.
   * @param delim Optional: the delimiter to use. Default is comma.
   * @returns {String}
   */
  static Join(delim := ",") {
    result := ""
    for v in this
      result .= v delim
    return (len := StrLen(delim)) ? SubStr(result, 1, -len) : result
  }

  /**
   * Turns a nested array into a one-level array
   * @returns {Array}
   * @example
   * [1,[2,[3]]].Flat() ; returns [1,2,3]
   */
  static Flat() {
    r := []
    for v in this {
      if !IsSet(v)
        r.Push(unset)
      else if Type(v) = "Array"
        r.Extend(v.Flat())
      else
        r.Push(v)
    }
    return this := r
  }

  /**
   * Adds the contents of another array to the end of this one.
   * @param enums The arrays or other enumerables that are used to extend this one.
   * @returns {Array}
   */
  static Extend(enums*) {
    for enum in enums {
      if !HasMethod(enum, "__Enum")
        throw(ValueError("Extend: arr must be an iterable"))
      for _, v in enum
        this.Push(IsSet(v) ? v : unset)
    }
    return this
  }
}

/*
	Name: String.ahk
	Version 0.15 (05.09.23)
	Created: 27.08.22
	Author: Descolada
	Credit:
	tidbit		--- Author of "String Things - Common String & Array Functions", from which
					I copied/based a lot of methods
	Contributors: Axlefublr, neogna2
	Contributors to "String Things": AfterLemon, Bon, Lexikos, MasterFocus, Rseding91, Verdlin

	Description:
	A compilation of useful string methods. Also lets strings be treated as objects.

	These methods cannot be used as stand-alone. To do that, you must add another argument
	'string' to the function and replace all occurrences of 'this' with 'string'.
	.-==========================================================================-.
	| Properties                                                                 |
	|============================================================================|
	| String.Length                                                              |
	|       .IsDigit                                                             |
	|       .IsXDigit                                                            |
	|       .IsAlpha                                                             |
	|       .IsUpper                                                             |
	|       .IsLower                                                             |
	|       .IsAlnum                                                             |
	|       .IsSpace                                                             |
	|       .IsTime                                                              |
	|============================================================================|
	| Methods                                                                    |
	|============================================================================|
	| Native functions as methods:                                               |
	| String.ToUpper()                                                           |
	|       .ToLower()                                                           |
	|       .ToTitle()                                                           |
	|       .Split([Delimiters, OmitChars, MaxParts])                            |
	|       .Replace(Needle [, ReplaceText, CaseSense, &OutputVarCount, Limit])  |
	|       .Trim([OmitChars])                                                   |
	|       .LTrim([OmitChars])                                                  |
	|       .RTrim([OmitChars])                                                  |
	|       .Compare(comparison [, CaseSense])                                   |
	|       .Sort([, Options, Function])                                         |
	|       .Format([Values...])                                                 |
	|       .Find(Needle [, CaseSense, StartingPos, Occurrence])                 |
	|       .SplitPath() => returns object {FileName, Dir, Ext, NameNoExt, Drive}|                                                       |
	|		.RegExMatch(needleRegex, &match?, startingPos?)                      |
	|       .RegExMatchAll(needleRegex, startingPos?)                            |
	|		.RegExReplace(needle, replacement?, &count?, limit?, startingPos?)   |
	|                                                                            |
	| String[n] => gets nth character                                            |
	| String[i,j] => substring from i to j                                       |
	| for [index,] char in String => loops over the characters in String         |
	| String.Length                                                              |
	| String.Count(searchFor)                                                    |
	| String.Insert(insert, into [, pos])                                        |
	| String.Delete(string [, start, length])                                    |
	| String.Overwrite(overwrite, into [, pos])                                  |
	| String.Repeat(count)                                                       |
	| Delimeter.Concat(words*)                                                   |
	|                                                                            |
	| String.LineWrap([column:=56, indentChar:=""])                              |
	| String.WordWrap([column:=56, indentChar:=""])                              |
	| String.ReadLine(line [, delim:="`n", exclude:="`r"])                       |
	| String.DeleteLine(line [, delim:="`n", exclude:="`r"])                     |
	| String.InsertLine(insert, into, line [, delim:="`n", exclude:="`r"])       |
	|                                                                            |
	| String.Reverse()                                                           |
	| String.Contains(needle1 [, needle2, needle3...])                           |
	| String.RemoveDuplicates([delim:="`n"])                                     |
	| String.LPad(count)                                                         |
	| String.RPad(count)                                                         |
	|                                                                            |
	| String.Center([fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width])  |
	| String.Right([fill:=" ", delim:="`n", exclude:="`r"])                      |
	'-==========================================================================-'
*/
class String2 {
  static __New() {

    ; Add String2 methods and properties into String object
    __ObjDefineProp := Object.Prototype.DefineProp
    for __String2_Prop in String2.OwnProps()
      if SubStr(__String2_Prop, 1, 2) != "__"
        __ObjDefineProp(String.Prototype, __String2_Prop, String2.GetOwnPropDesc(__String2_Prop))
    __ObjDefineProp(String.Prototype, "__Item", {
      get: (args*) => String2.__Item[args*]
    })
    __ObjDefineProp(String.Prototype, "__Enum", {
      call: String2.__Enum
    })
  }

  static __Item[args*] {
    get {
      if args.length = 2
        return SubStr(args[1], args[2], 1)
      else {
        len := StrLen(args[1])
        if args[2] < 0
          args[2] := len + args[2] + 1
        if args[3] < 0
          args[3] := len + args[3] + 1
        if args[3] >= args[2]
          return SubStr(args[1], args[2], args[3] - args[2] + 1)
        else
          return SubStr(args[1], args[3], args[2] - args[3] + 1)
          .Reverse()
      }
    }
  }

  static __Enum(varCount) {
    pos := 0, len := StrLen(this)
    EnumElements(&char) {
      char := StrGet(StrPtr(this) + 2 * pos, 1)
      return ++pos <= len
    }

    EnumIndexAndElements(&index, &char) {
      char := StrGet(StrPtr(this) + 2 * pos, 1), index := ++pos
      return pos <= len
    }

    return varCount = 1 ? EnumElements : EnumIndexAndElements
  }

  ; Native functions implemented as methods for the String object
  static Length => StrLen(this)
  static WLength => (RegExReplace(this, "s).", "", &i), i)
  static ULength => StrLen(RegExReplace(this, "s)((?>\P{M}(\p{M}|\x{200D}))+\P{M})|\X", "_"))
  static IsDigit => IsDigit(this)
  static IsXDigit => IsXDigit(this)
  static IsUpper => IsUpper(this)
  static IsLower => IsLower(this)
  static IsAlnum => IsAlnum(this)
  static IsSpace => IsSpace(this)
  static IsTime => IsTime(this)
  static ToUpper() => StrUpper(this)
  static ToLower() => StrLower(this)
  static ToTitle() => StrTitle(this)
  static Split(args*) => StrSplit(this, args*)
  static Replace(args*) => StrReplace(this, args*)
  static Trim(args*) => Trim(this, args*)
  static LTrim(args*) => LTrim(this, args*)
  static RTrim(args*) => RTrim(this, args*)
  static Compare(args*) => StrCompare(this, args*)
  static Sort(args*) => Sort(this, args*)
  static Format(args*) => Format(this, args*)
  static Find(args*) => InStr(this, args*)
  static IndexOf(args*) => InStr(this, args*)
  static includes(args*) => args[1] && !!InStr(this, args*)
  static SplitPath() => (SplitPath(this, &a1, &a2, &a3, &a4, &a5), {
    FileName: a1,
    Dir: a2,
    Ext: a3,
    NameNoExt: a4,
    Drive: a5
  })
  static SubString(start, end := this.length) => this[start, end]
  static SubStr(start, end := this.length) => this[start, end]
  /**
   * returns 1 if the string starts with str
   * @param {String} str string to check
   */
  static startsWith(str) {
    return SubStr(this, 1, str.length) == str
  }

  /**
   * returns 1 if the string ends with str
   * @param {String} str string to check
   */
  static endsWith(str) {
    return SubStr(this, this.length - str.length + 1, this.Length) == str
  }

  /**
   * Returns the match object
   * @param needleRegex *String* What pattern to match
   * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
   * @returns {Object}
   */
  static RegExMatch(needleRegex, &match?, startingPos?) => (RegExMatch(this, needleRegex, &match, startingPos?), match)

  /**
   * Returns all RegExMatch results in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
   * @param needleRegEx *String* The RegEx pattern to search for.
   * @param startingPosition *Integer* If StartingPos is omitted, it defaults to 1 (the beginning of haystack).
   * @returns {Array}
   */
  static RegExMatchAll(needleRegEx, startingPosition := 1) {
    out := []
    while startingPosition := RegExMatch(this, needleRegEx, &outputVar, startingPosition)
      out.Push(outputVar), startingPosition += outputVar[0] ? StrLen(outputVar[0]) : 1
    return out
  }

  /**
   * Uses regex to perform a replacement, returns the changed string
   * @param needleRegex *String* What pattern to match.
   * 	This can also be a Array of needles (and replacement a corresponding array of replacement values), 
   * 	in which case all of the pairs will be searched for and replaced with the corresponding replacement. 
   * 	replacement should be left empty, outputVarCount will be set to the total number of replacements, limit is the maximum
   * 	number of replacements for each needle-replacement pair.
   * @param replacement *String* What to replace that match into
   * @param outputVarCount *VarRef* Specify a variable with a `&` before it to assign it to the amount of replacements that have occured
   * @param limit *Integer* The maximum amount of replacements that can happen. Unlimited by default
   * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
   * @returns {String} The changed string
   */
  static RegExReplace(needleRegex, replacement?, &outputVarCount?, limit?, startingPos?) {
    if IsObject(needleRegex) {
      out := this, count := 0
      for i, needle in needleRegex {
        out := RegExReplace(out, needle, IsSet(replacement) ? replacement[i] : unset, &count, limit?, startingPos?)
        if IsSet(outputVarCount)
          outputVarCount += count
      }
      return out
    }
    return RegExReplace(this, needleRegex, replacement?, &outputVarCount, limit?, startingPos?)
  }

  /**
   * Add character(s) to left side of the input string.
   * example: "aaa".LPad("+", 5)
   * output: +++++aaa
   * @param padding Text you want to add
   * @param count How many times do you want to repeat adding to the left side.
   * @returns {String}
   */
  static LPad(padding, count := 1) {
    str := this
    if (count > 0) {
      loop count
        str := padding str
    }
    return str
  }

  /**
   * Add character(s) to right side of the input string.
   * example: "aaa".RPad("+", 5)
   * output: aaa+++++
   * @param padding Text you want to add
   * @param count How many times do you want to repeat adding to the left side.
   * @returns {String}
   */
  static RPad(padding, count := 1) {
    str := this
    if (count > 0) {
      loop count
        str := str padding
    }
    return str
  }

  /**
   * Count the number of occurrences of needle in the string
   * input: "12234".Count("2")
   * output: 2
   * @param needle Text to search for
   * @param caseSensitive
   * @returns {Integer}
   */
  static Count(needle, caseSensitive := False) {
    StrReplace(this, needle, , caseSensitive, &count)
    return count
  }

  /**
   * Duplicate the string 'count' times.
   * input: "abc".Repeat(3)
   * output: "abcabcabc"
   * @param count *Integer*
   * @returns {String}
   */
  static Repeat(count) => StrReplace(Format("{:" count "}", ""), " ", this)

  /**
   * Reverse the string.
   * @returns {String}
   */
  static Reverse() {
    DllCall("msvcrt\_wcsrev", "str", str := this, "CDecl str")
    return str
  }
  static WReverse() {
    str := this, out := "", m := ""
    while str && (m := Chr(Ord(str))) && (out := m . out)
      str := SubStr(str, StrLen(m) + 1)
    return out
  }

  /**
   * Insert the string inside 'insert' into position 'pos'
   * input: "abc".Insert("d", 2)
   * output: "adbc"
   * @param insert The text to insert
   * @param pos *Integer*
   * @returns {String}
   */
  static Insert(insert, pos := 1) {
    Length := StrLen(this)
    ((pos > 0)
      ? pos2 := pos - 1
      : (pos = 0
        ? (pos2 := StrLen(this), Length := 0)
          : pos2 := pos
      )
    )
    output := SubStr(this, 1, pos2) . insert . SubStr(this, pos, Length)
    if (StrLen(output) > StrLen(this) + StrLen(insert))
      ((Abs(pos) <= StrLen(this) / 2)
        ? (output := SubStr(output, 1, pos2 - 1)
        . SubStr(output, pos + 1, StrLen(this)))
        : (output := SubStr(output, 1, pos2 - StrLen(insert) - 2)
        . SubStr(output, pos - StrLen(insert), StrLen(this)))
      )
    return output
  }

  /**
   * Replace part of the string with the string in 'overwrite' starting from position 'pos'
   * input: "aaabbbccc".Overwrite("zzz", 4)
   * output: "aaazzzccc"
   * @param overwrite Text to insert.
   * @param pos The position where to begin overwriting. 0 may be used to overwrite at the very end, -1 will offset 1 from the end, and so on.
   * @returns {String}
   */
  static Overwrite(overwrite, pos := 1) {
    if (Abs(pos) > StrLen(this))
      return ""
    else if (pos > 0)
      return SubStr(this, 1, pos - 1) . overwrite . SubStr(this, pos + StrLen(overwrite))
    else if (pos < 0)
      return SubStr(this, 1, pos) . overwrite . SubStr(this " ", (Abs(pos) > StrLen(overwrite) ? pos + StrLen(overwrite) : 0), Abs(pos + StrLen(overwrite)))
    else if (pos = 0)
      return this . overwrite
  }

  /**
   * Delete a range of characters from the specified string.
   * input: "aaabbbccc".Delete(4, 3)
   * output: "aaaccc"
   * @param start The position where to start deleting.
   * @param length How many characters to delete.
   * @returns {String}
   */
  static Delete(start := 1, length := 1) {
    if (Abs(start) > StrLen(this))
      return ""
    if (start > 0)
      return SubStr(this, 1, start - 1) . SubStr(this, start + length)
    else if (start <= 0)
      return SubStr(this " ", 1, start - 1) SubStr(this " ", ((start < 0) ? start - 1 + length : 0), -1)
  }

  /**
   * Wrap the string so each line is never more than a specified length.
   * input: "Apples are a round fruit, usually red".LineWrap(20, "---")
   * output: "Apples are a round f
   *          ---ruit, usually red"
   * @param column Specify a maximum length per line
   * @param indentChar Choose a character to indent the following lines with
   * @returns {String}
   */
  static LineWrap(column := 56, indentChar := "") {
    CharLength := StrLen(indentChar)
    , columnSpan := column - CharLength
    , Ptr := A_PtrSize ? "Ptr" : "UInt"
    , UnicodeModifier := 2
    , VarSetStrCapacity(&out, (finalLength := (StrLen(this) + (Ceil(StrLen(this) / columnSpan) * (column + CharLength + 1)))) * 2)
    , A := StrPtr(out)

    loop parse, this, "`n", "`r" {
      if ((FieldLength := StrLen(ALoopField := A_LoopField)) > column) {
        DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", column * UnicodeModifier)
        , A += column * UnicodeModifier
        , NumPut("UShort", 10, A)
        , A += UnicodeModifier
        , Pos := column

        while (Pos < FieldLength) {
          if CharLength
            DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(indentChar), "UInt", CharLength * UnicodeModifier)
            , A += CharLength * UnicodeModifier

          if (Pos + columnSpan > FieldLength)
            DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", (FieldLength - Pos) * UnicodeModifier)
            , A += (FieldLength - Pos) * UnicodeModifier
            , Pos += FieldLength - Pos
          else
            DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", columnSpan * UnicodeModifier)
            , A += columnSpan * UnicodeModifier
            , Pos += columnSpan

          NumPut("UShort", 10, A)
          , A += UnicodeModifier
        }
      } else
        DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", FieldLength * UnicodeModifier)
        , A += FieldLength * UnicodeModifier
        , NumPut("UShort", 10, A)
        , A += UnicodeModifier
    }
    NumPut("UShort", 0, A)
    VarSetStrCapacity(&out, -1)
    return SubStr(out, 1, -1)
  }

  /**
   * Wrap the string so each line is never more than a specified length.
   * Unlike LineWrap(), this method takes into account words separated by a space.
   * input: "Apples are a round fruit, usually red.".WordWrap(20, "---")
   * output: "Apples are a round
   *          ---fruit, usually
   *          ---red."
   * @param column Specify a maximum length per line
   * @param indentChar Choose a character to indent the following lines with
   * @returns {String}
   */
  static WordWrap(column := 56, indentChar := "") {
    if !IsInteger(column)
      throw(TypeError("WordWrap: argument 'column' must be an integer", -1))
    out := ""
    indentLength := StrLen(indentChar)

    loop parse, this, "`n", "`r" {
      if (StrLen(A_LoopField) > column) {
        pos := 1
        loop parse, A_LoopField, " "
          if (pos + (LoopLength := StrLen(A_LoopField)) <= column)
            out .= (A_Index = 1 ? "" : " ") A_LoopField
            , pos += LoopLength + 1
          else
            pos := LoopLength + 1 + indentLength
              , out .= "`n" indentChar A_LoopField

        out .= "`n"
      } else
        out .= A_LoopField "`n"
    }
    return SubStr(out, 1, -1)
  }

  /**
   * Insert a line of text at the specified line number.
   * The line you specify is pushed down 1 and your text is inserted at its
   * position. A "line" can be determined by the delimiter parameter. Not
   * necessarily just a `r or `n. But perhaps you want a | as your "line".
   * input: "aaa|ccc|ddd".InsertLine("bbb", 2, "|")
   * output: "aaa|bbb|ccc|ddd"
   * @param insert Text you want to insert.
   * @param line What line number to insert at. Use a 0 or negative to start inserting from the end.
   * @param delim The character which defines a "line".
   * @param exclude The text you want to ignore when defining a line.
   * @returns {String}
   */
  static InsertLine(insert, line, delim := "`n", exclude := "`r") {
    if StrLen(delim) != 1
      throw(ValueError("InsertLine: Delimiter can only be a single character", -1))
    into := this, new := ""
    count := into.Count(delim) + 1

    ; Create any lines that don't exist yet, if the Line is less than the total line count.
    if (line < 0 && Abs(line) > count) {
      loop Abs(line) - count
        into := delim into
      line := 1
    }
    if (line == 0)
      line := Count + 1
    if (line < 0)
      line := count + line + 1

    ; Create any lines that don't exist yet. Otherwise the Insert doesn't work.
    if (count < line)
      loop line - count
        into .= delim

    loop parse, into, delim, exclude
      new .= ((a_index == line) ? insert . delim . A_LoopField . delim : A_LoopField . delim)

    return SubStr(new, 1, -(line > count ? 2 : 1))
  }

  /**
   * Delete a line of text at the specified line number.
   * The line you specify is deleted and all lines below it are shifted up.
   * A "line" can be determined by the delimiter parameter. Not necessarily
   * just a `r or `n. But perhaps you want a | as your "line".
   * input: "aaa|bbb|777|ccc".DeleteLine(3, "|")
   * output: "aaa|bbb|ccc"
   * @param string Text you want to delete the line from.
   * @param line What line to delete. You may use -1 for the last line and a negative an offset from the last. -2 would be the second to the last.
   * @param delim The character which defines a "line".
   * @param exclude The text you want to ignore when defining a line.
   * @returns {String}
   */
  static DeleteLine(line, delim := "`n", exclude := "`r") {
    if StrLen(delim) != 1
      throw(ValueError("DeleteLine: Delimiter can only be a single character", -1))
    new := ""

    ; checks to see if we are trying to delete a non-existing line.
    count := this.Count(delim) + 1
    if (abs(line) > Count)
      throw(ValueError("DeleteLine: the line number cannot be greater than the number of lines", -1))
    if (line < 0)
      line := count + line + 1
    else if (line = 0)
      throw(ValueError("DeleteLine: line number cannot be 0", -1))

    loop parse, this, delim, exclude {
      if (a_index == line) {
        continue
      } else
        (new .= A_LoopField . delim)
    }

    return SubStr(new, 1, -1)
  }

  /**
   * Read the content of the specified line in a string. A "line" can be
   * determined by the delimiter parameter. Not necessarily just a `r or `n.
   * But perhaps you want a | as your "line".
   * input: "aaa|bbb|ccc|ddd|eee|fff".ReadLine(4, "|")
   * output: "ddd"
   * @param line What line to read*. "L" = The last line. "R" = A random line. Otherwise specify a number to get that line. You may specify a negative number to get the line starting from the end. -1 is the same as "L", the last. -2 would be the second to the last, and so on.
   * @param delim The character which defines a "line".
   * @param exclude The text you want to ignore when defining a line.
   * @returns {String}
   */
  static ReadLine(line, delim := "`n", exclude := "`r") {
    out := "", count := this.Count(delim) + 1

    if (line = "R")
      line := Random(1, count)
    else if (line = "L")
      line := count
    else if abs(line) > Count
      throw(ValueError("ReadLine: the line number cannot be greater than the number of lines", -1))
    else if (line < 0)
      line := count + line + 1
    else if (line = 0)
      throw(ValueError("ReadLine: line number cannot be 0", -1))

    loop parse, this, delim, exclude {
      if A_Index = line
        return A_LoopField
    }
    throw(Error("ReadLine: something went wrong, the line was not found", -1))
  }

  /**
   * Replace all consecutive occurrences of 'delim' with only one occurrence.
   * input: "aaa|bbb|||ccc||ddd".RemoveDuplicates("|")
   * output: "aaa|bbb|ccc|ddd"
   * @param delim *String*
   */
  static RemoveDuplicates(delim := "`n") => RegExReplace(this, "(\Q" delim "\E)+", "$1")

  /**
   * Checks whether the string contains any of the needles provided.
   * input: "aaa|bbb|ccc|ddd".Contains("eee", "aaa")
   * output: 1 (although the string doesn't contain "eee", it DOES contain "aaa")
   * @param needles
   * @returns {Boolean}
   */
  static Contains(needles*) {
    for needle in needles
      if InStr(this, needle)
        return 1
    return 0
  }

  /**
   * Centers a block of text to the longest item in the string.
   * example: "aaa`na`naaaaaaaa".Center()
   * output: "aaa
   *           a
   *       aaaaaaaa"
   * @param text The text you would like to center.
   * @param fill A single character to use as the padding to center text.
   * @param symFill 0: Just fill in the left half. 1: Fill in both sides.
   * @param delim The character which defines a "line".
   * @param exclude The text you want to ignore when defining a line.
   * @param width Can be specified to add extra padding to the sides
   * @returns {String}
   */
  static Center(fill := " ", symFill := 0, delim := "`n", exclude := "`r", width?) {
    fill := SubStr(fill, 1, 1), longest := 0, new := ""
    loop parse, this, delim, exclude
      if (StrLen(A_LoopField) > longest)
        longest := StrLen(A_LoopField)
    if IsSet(width)
      longest := Max(longest, width)
    loop parse this, delim, exclude {
      filled := "", len := StrLen(A_LoopField)
      loop (longest - len) // 2
        filled .= fill
      new .= filled A_LoopField ((symFill = 1) ? filled (2 * StrLen(filled) + len = longest ? "" : fill) : "") "`n"
    }
    return RTrim(new, "`r`n")
  }

  /**
   * Align a block of text to the right side.
   * input: "aaa`na`naaaaaaaa".Right()
   * output: "     aaa
   *                 a
   *          aaaaaaaa"
   * @param fill A single character to use as to push the text to the right.
   * @param delim The character which defines a "line".
   * @param exclude The text you want to ignore when defining a line.
   * @returns {String}
   */
  static Right(fill := " ", delim := "`n", exclude := "`r") {
    fill := SubStr(fill, 1, 1), longest := 0, new := ""
    loop parse, this, delim, exclude
      if (StrLen(A_LoopField) > longest)
        longest := StrLen(A_LoopField)
    loop parse, this, delim, exclude {
      filled := ""
      loop Abs(longest - StrLen(A_LoopField))
        filled .= fill
      new .= filled A_LoopField "`n"
    }
    return RTrim(new, "`r`n")
  }

  /**
   * Join a list of strings together to form a string separated by delimiter this was called with.
   * input: "|".Concat("111", "222", "333", "abc")
   * output: "111|222|333|abc"
   * @param words A list of strings separated by a comma.
   * @returns {String}
   */
  static Concat(words*) {
    delim := this, s := ""
    for v in words
      s .= v . delim
    return SubStr(s, 1, -StrLen(this))
  }
}

/*
	Name: Map.ahk
	Version 0.1 (05.09.23)
	Created: 05.09.23
	Author: Descolada

	Description:
	A compilation of useful Map methods.

    Map.Keys                              => All keys of the map in an array
    Map.Values                            => All values of the map in an array
    Map.Map(func, enums*)                 => Applies a function to each element in the map.
    Map.ForEach(func)                     => Calls a function for each element in the map.
    Map.Filter(func)                      => Keeps only key-value pairs that satisfy the provided function
    Map.Reduce(func, initialValue?)       => Applies a function cumulatively to all the values in
        the array, with an optional initial value.
    Map.Find(func, &match?, start:=1)     => Finds a value satisfying the provided function and returns the index.
        match will be set to the found value.
    Map.Count(value)                      => Counts the number of occurrences of a value.
    Map.Merge(enums*)                     => Adds the contents of other maps/enumerables to this map
*/

Map.Prototype.base := Map2

class Map2 {
  static __Enum(*) {
  }
  /**
   * Returns all the keys of the Map in an array
   * @returns {Array}
   */
  static Keys {
    get => [
      this*
    ]
  }

  /**
   * Returns all the values of the Map in an array
   * @returns {Array}
   */
  static Values {
    get => [
      this.__Enum(2)
      .Bind(&_)*
    ]
  }

  /**
   * Applies a function to each element in the map (mutates the map).
   * @param func The mapping function that accepts at least key and value (key, value1, [value2, ...]).
   * @param enums Additional enumerables to be accepted in the mapping function
   * @returns {Map}
   */
  static Map(func, enums*) {
    if !HasMethod(func)
      throw(ValueError("Map: func must be a function", -1))
    for k, v in this {
      bf := func.Bind(k, v)
      for _, vv in enums
        bf := bf.Bind(vv.Has(k) ? vv[k] : unset)
      try bf := bf()
      this[k] := bf
    }
    return this
  }

  /**
   * Applies a function to each key/value pair in the map.
   * @param func The callback function with arguments Callback(value[, key, map]).
   * @returns {Map}
   */
  static ForEach(func) {
    if !HasMethod(func)
      throw(ValueError("ForEach: func must be a function", -1))
    for i, v in this
      func(v, i, this)
    return this
  }

  /**
   * Keeps only values that satisfy the provided function
   * @param func The filter function that accepts key and value.
   * @returns {Map}
   */
  static Filter(func) {
    if !HasMethod(func)
      throw(ValueError("Filter: func must be a function", -1))
    r := Map()
    for k, v in this
      if func(k, v)
        r[k] := v
    return this := r
  }

  /**
   * Finds a value satisfying the provided function and returns its key.
   * @param func The condition function that accepts one argument (value).
   * @param match Optional: is set to the found value
   * @example
   * Map("a", 1, "b", 2, "c", 3).Find((v) => (Mod(v,2) == 0)) ; returns "b"
   */
  static Find(func, &match?) {
    if !HasMethod(func)
      throw(ValueError("Find: func must be a function", -1))
    for k, v in this {
      if func(v) {
        match := v
        return k
      }
    }
    return 0
  }

  /**
   * Counts the number of occurrences of a value
   * @param value The value to count. Can also be a function that accepts a value and evaluates to true/false.
   */
  static Count(value) {
    count := 0
    if HasMethod(value) {
      for _, v in this
        if value(v?)
          count++
    } else
      for _, v in this
        if v == value
          count++
    return count
  }

  /**
   * Adds the contents of other enumerables to this one.
   * @param enums The enumerables that are used to extend this one.
   * @returns {Array}
   */
  static Extend(enums*) {
    for i, enum in enums {
      if !HasMethod(enum, "__Enum")
        throw(ValueError("Extend: argument " i " is not an iterable"))
      for k, v in enum
        this[k] := v
    }
    return this
  }
}
#Include <Misc>