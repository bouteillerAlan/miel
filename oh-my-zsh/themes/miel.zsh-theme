# Miel theme for Oh My Zsh

setopt prompt_subst

: ${MIEL_VERSIONS_COMMAND:=miel-versions}

_miel_path() {
  local -a parts output
  local index last_full
  [[ $PWD == / ]] && { print -nr -- /; return }
  parts=("${(s:/:)PWD}")
  last_full=$(( ${#parts} - 2 ))
  output=()

  for ((index = 1; index <= ${#parts}; index++)); do
    [[ -z ${parts[index]} ]] && continue
    if (( index < last_full )); then
      if [[ ${parts[index]} == .* ]]; then
        output+=("/${parts[index][1,2]}")
      else
        output+=("/${parts[index][1]}")
      fi
    else
      output+=("/${parts[index]}")
    fi
  done
  print -nr -- "${(j::)output}"
}

_miel_git() {
  local inside branch branch_status worktree_count staged_count stash_count
  local rebase merge result
  inside=$(git rev-parse --is-inside-work-tree 2>/dev/null) || return
  [[ $inside == true ]] || return

  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
  [[ -n $branch ]] || branch=$(git rev-parse --short HEAD 2>/dev/null)
  branch_status=$(git status --porcelain=v1 --branch 2>/dev/null | sed -n '1p' | sed -E 's/^## [^ ]+ ?//')
  worktree_count=$(git status --porcelain=v1 2>/dev/null | awk 'substr($0, 2, 1) != " " { count++ } END { print count + 0 }')
  staged_count=$(git status --porcelain=v1 2>/dev/null | awk 'substr($0, 1, 1) != " " { count++ } END { print count + 0 }')
  stash_count=$(git stash list 2>/dev/null | awk 'END { print NR + 0 }')
  rebase=''
  merge=''
  [[ -d .git/rebase-merge || -d .git/rebase-apply ]] && rebase=' 󰑓'
  [[ -f .git/MERGE_HEAD ]] && merge=' 󰘬'

  result="on "
  [[ $(git rev-parse --git-dir 2>/dev/null) != $(git rev-parse --git-common-dir 2>/dev/null) ]] && result+="󰉍 "
  result+=" ${branch}"
  [[ -n ${branch_status} ]] && result+=" ${branch_status}"
  result+="${rebase}${merge}"
  (( worktree_count > 0 )) && result+=" [38;5;250m󰏫 ${worktree_count}"
  (( worktree_count > 0 && staged_count > 0 )) && result+=" |"
  (( staged_count > 0 )) && result+=" [38;5;250m󰦉 ${staged_count}"
  (( stash_count > 0 )) && result+="  ${stash_count}"
  print -nr -- "$result"
}

_miel_versions() {
  local index value color
  local -a colors=("#d70000" "#ff5f00" "#ffaf00" "#e5a717")
  for index in {0..9}; do
    value="$($MIEL_VERSIONS_COMMAND "$index" 2>/dev/null)"
    [[ -z $value ]] && continue
    color=${colors[$(( index % 4 + 1 ))]}
    print -n -- "%F{$color}${value}%f"
    (( index < 9 )) && print -n -- $'\u2060 '
  done
}

_miel_precmd() {
  local exit_status=$?
  local git_info
  git_info=$(_miel_git)

  PROMPT=''
  (( EUID == 0 )) && PROMPT+="%F{#A66A2C}root %F{#FFF1CC}in%f "
  PROMPT+="%F{#E6A817}$(_miel_path)%f "
  [[ -n $git_info ]] && PROMPT+="%F{#FFC857}${git_info}%f "
  (( exit_status != 0 )) && PROMPT+="%F{#A66A2C}⁠ x %f"
  PROMPT+=$'\n'
  PROMPT+="$(_miel_versions)"
  PROMPT+=$'\n%F{#FFC857}λ %f'
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _miel_precmd
_miel_precmd
