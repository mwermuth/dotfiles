#!/usr/bin/env bash
# Claude Code Status Line — reads JSON from stdin

# ── Colors (ANSI) ──
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Read JSON from stdin ──
INPUT=$(cat)

# ── Parse fields with jq ──
MODEL_NAME=$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"')
CTX_SIZE=$(echo "$INPUT" | jq -r '.context_window.context_window_size // 200000')
TOTAL_IN=$(echo "$INPUT" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUT=$(echo "$INPUT" | jq -r '.context_window.total_output_tokens // 0')
PCT_USED=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
PCT_REMAIN=$(echo "$INPUT" | jq -r '.context_window.remaining_percentage // 100')

# Rate limits (from Claude.ai subscription)
FIVE_HR_PCT=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_HR_RESET=$(echo "$INPUT" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_DAY_PCT=$(echo "$INPUT" | jq -r '.rate_limits.seven_day.used_percentage // empty')
SEVEN_DAY_RESET=$(echo "$INPUT" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ── Derived values ──
TOKENS_USED=$(( TOTAL_IN + TOTAL_OUT ))
TOKENS_REMAIN=$(( CTX_SIZE - TOKENS_USED ))
(( TOKENS_REMAIN < 0 )) && TOKENS_REMAIN=0

# Round percentages to integers
PCT_USED=$(printf '%.0f' "$PCT_USED")
PCT_REMAIN=$(printf '%.0f' "$PCT_REMAIN")

# ── Helper: human-readable token count ──
human_tokens() {
  local n=$1
  if (( n >= 1000000 )); then
    printf "%.1fm" "$(echo "scale=1; $n / 1000000" | bc)"
  elif (( n >= 1000 )); then
    printf "%dk" "$(( n / 1000 ))"
  else
    printf "%d" "$n"
  fi
}

# ── Helper: format number with commas ──
comma() {
  printf "%'d" "$1"
}

# ── Helper: progress circles (10 slots) ──
circles() {
  local pct=${1:-0}
  pct=$(printf '%.0f' "$pct")
  local filled=$(( pct / 10 ))
  local empty=$(( 10 - filled ))
  (( filled > 10 )) && filled=10 && empty=0
  (( filled < 0 )) && filled=0 && empty=10
  local out=""
  for (( i=0; i<filled; i++ )); do out+="●"; done
  for (( i=0; i<empty; i++ )); do out+="○"; done
  printf '%s' "$out"
}

# ── Helper: epoch to human time ──
epoch_to_time() {
  local epoch=$1
  if [[ -z "$epoch" || "$epoch" == "null" ]]; then
    echo "—"
    return
  fi
  date -r "$epoch" '+%-I:%M%p' 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "—"
}

epoch_to_datetime() {
  local epoch=$1
  if [[ -z "$epoch" || "$epoch" == "null" ]]; then
    echo "—"
    return
  fi
  date -r "$epoch" '+%b %-d, %-I:%M%p' 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "—"
}

# ── Context window label ──
if (( CTX_SIZE >= 1000000 )); then
  CTX_LABEL="$(( CTX_SIZE / 1000000 ))M context"
elif (( CTX_SIZE >= 1000 )); then
  CTX_LABEL="$(( CTX_SIZE / 1000 ))K context"
else
  CTX_LABEL="${CTX_SIZE} context"
fi

# ── Thinking (check if model supports it — Opus/Sonnet do) ──
THINK_LABEL="On"

# ── Rate limit values with defaults ──
FIVE_PCT=${FIVE_HR_PCT:-0}
WEEK_PCT=${SEVEN_DAY_PCT:-0}
FIVE_PCT_INT=$(printf '%.0f' "$FIVE_PCT")
WEEK_PCT_INT=$(printf '%.0f' "$WEEK_PCT")

# ── Reset times from API epoch timestamps ──
if [[ -n "$FIVE_HR_RESET" && "$FIVE_HR_RESET" != "null" ]]; then
  DAILY_RESET=$(epoch_to_time "$FIVE_HR_RESET")
else
  DAILY_RESET="—"
fi

if [[ -n "$SEVEN_DAY_RESET" && "$SEVEN_DAY_RESET" != "null" ]]; then
  WEEKLY_RESET=$(epoch_to_datetime "$SEVEN_DAY_RESET")
else
  WEEKLY_RESET="—"
fi


# ── Line 1: Model & Token Info ──
printf "${GREEN}${BOLD}%s (%s)${RESET}" "$MODEL_NAME" "$CTX_LABEL"
printf "${GRAY} | ${RESET}"
printf "${CYAN}%s / %s${RESET}" "$(human_tokens $TOKENS_USED)" "$(human_tokens $CTX_SIZE)"
printf "${GRAY} | ${RESET}"
printf "${YELLOW}${BOLD}%d%% used${RESET} ${WHITE}%s${RESET}" "$PCT_USED" "$(comma $TOKENS_USED)"
printf "${GRAY} | ${RESET}"
printf "${BLUE}${BOLD}%d%% remain${RESET} ${WHITE}%s${RESET}" "$PCT_REMAIN" "$(comma $TOKENS_REMAIN)"
printf "${GRAY} | ${RESET}"
printf "${YELLOW}thinking: ${BOLD}%s${RESET}" "$THINK_LABEL"
printf "\n"

# ── Line 2: Usage Circles ──
printf "${WHITE}current: ${GREEN}%s${RESET} ${GREEN}%d%%${RESET}" "$(circles $FIVE_PCT)" "$FIVE_PCT_INT"
printf "${GRAY} | ${RESET}"
printf "${WHITE}weekly: ${CYAN}%s${RESET} ${CYAN}%d%%${RESET}" "$(circles $WEEK_PCT)" "$WEEK_PCT_INT"
printf "\n"

# ── Line 3: Reset Times ──
printf "${GRAY}resets %s${RESET}" "$DAILY_RESET"
printf "${GRAY} | ${RESET}"
printf "${GRAY}resets %s${RESET}" "$WEEKLY_RESET"
printf "\n"
