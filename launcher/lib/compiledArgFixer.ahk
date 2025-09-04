#Include <Misc>
if A_IsCompiled and A_Args.Length >= 1 and A_Args[1] == A_ScriptFullPath {
  newargs := []
  for i in range(A_Args.Length) {
    if i == 1
      continue
    newargs.push(A_Args[i])
  }
  A_Args := [newargs*]
}