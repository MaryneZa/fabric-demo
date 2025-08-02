C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'

function infoln() {
  println "${C_BLUE}${1}${C_RESET}"
}

# warnln echos in yellow color
function warnln() {
  println "${C_YELLOW}${1}${C_RESET}"
}

function println() {
  echo -e "$1"
}


export -f infoln
export -f warnln