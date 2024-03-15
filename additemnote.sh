#!/bin/bash
###############################################################################
#
# Adds a note to (an) item(s) in Symphony ILS.
# 
#  Copyright 2024 Andrew Nisbet
#  
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#  
#       http://www.apache.org/licenses/LICENSE-2.0
#  
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Tue 06 Feb 2024 03:34:18 PM EST
#
###############################################################################
set -o pipefail

. ~/.bashrc

VERSION="0.0.1"
APP=$(basename -s .sh "$0")
SERVER=$(hostname)
ILS=true
[ "$SERVER" != 'edpl.sirsidynix.net' ] && ILS=false
if [ "$ILS" == true ]; then
    WORKING_DIR='/tmp'
else 
    WORKING_DIR='.' 
fi
IS_TEST=false
ITEMS=''
MESSAGE=''
NOTE_FIELD='STAFF'
API_FILE="$WORKING_DIR/${APP}.api"
## Set up logging.
LOG_FILE="$WORKING_DIR/${APP}.log"
# Logs messages to STDERR and $LOG file.
# param:  Log file name. The file is expected to be a fully qualified path or the output
#         will be directed to a file in the directory the script's running directory.
# param:  Message to put in the file.
# param:  (Optional) name of a operation that called this function.
logit()
{
    local message="$1"
    local time=''
    time=$(date +"%Y-%m-%d %H:%M:%S")
    if [ -t 0 ]; then
        # If run from an interactive shell message STDERR.
        echo -e "[$time] $message"
    fi
    echo -e "[$time] $message" >>"$LOG_FILE"
}

# Prints out usage message.
usage()
{
    cat << EOFU!
 Usage: $APP [flags]

Adds a note to an arbitrary but specific item, or items if multiple are 
specified on command line.

Flags:
-f, --field: Specify the note field. The choice is, 'CIRCNOTE', 
  'PUBLIC', or default 'STAFF'.
-h, --help: This help message.
-i, --items=[item1,item2,...] List of one or more items. If the item
  does not exist the fact is logged and the item is ignored.
-t, --test Set test mode, will create the API necessary but does not 
  add the note(s).
-m, --message Message to add to the item(s).
-v, --version Print $APP version and exits.
 Example:
    # Create the API commands to add a specific note to an item.
    $APP --items="31221012345678" --test --message="Test message"
    # Apply the message 'Test' to two items.
    $APP --items="31221012345678,312210123456777" --message="Test"

Current version $VERSION
EOFU!
    exit 0
}

# Tests if an item exists
add_note()
{
    local item="$1"
    local message="$2"
    local which_field="$3"
    local callnum
    if [ "$ILS" == true ]; then 
        callnum=$(echo "$item" | selitem -iB -oN | selcallnum -iN -oD)
        [ -n "$callnum" ] || { logit "$item not found!"; return; } 
    else 
        callnum="Test callnum"
    fi
    logit "Adding '$message' to ${item}'s '$which_field' field."
    echo "S01IVFFADMIN^FEEPLMNA^FcNONE^FWADMIN^NQ${item}^IQ${callnum}^daLC^ND3^NI2^Nz0^NH${which_field}^NE${message}^Fv3000000^^O" >>"$API_FILE" 
    echo "S02IVFFADMIN^FEEPLMNA^FcNONE^FWADMIN^NQ${item}^IQ${callnum}^IoADMIN^Fv3000000^^O" >>"$API_FILE"
}

### Check input parameters.
# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "field:,help,items:,test,message:,version" -o "f:hi:tm:v" -a -- "$@")
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"

while true
do
    case $1 in
    -f|--field)
        shift
        case $1 in
            CIRCNOTE|PUBLIC|STAFF)
                NOTE_FIELD="$1"
                ;;
            *)
                logit "Invalid input '$1'. Please enter one of: CIRCNOTE, PUBLIC, or STAFF."
                exit 1
               ;;
        esac
        ;;
    -h|--help)
        usage
        ;;
    -i|--items)
        shift
        ITEMS="$1"
        ;;
    -t|--test)
        IS_TEST=true
        ;;
    -m|--message)
        shift
        MESSAGE="$1"
        ;;
    -v|--version)
        echo "$APP version: $VERSION"
        exit 0
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done
# Required ITEMS check.
: "${ITEMS:?Missing -i,--items\=\'barcode1,barcode2\'}"
: "${ITEMS:?Missing -m,--message\=\'Some note\'}"
# Get rid of the old commands if any.
[ -f "$API_FILE" ] && rm "$API_FILE"
# Save the current value of IFS
OLD_IFS=$IFS

# Set IFS to ',' to split words by commas
IFS=','

# Iterate over each word
for item in $ITEMS; do
    add_note "$item" "$MESSAGE" "$NOTE_FIELD"
done

# Restore the value of IFS
IFS=$OLD_IFS

# If this isn't a test run the file.
if [ "$IS_TEST" == false ] && [ -s "$API_FILE" ]; then 
    logit "running commands in '$API_FILE'"
    if [ "$ILS" == true ]; then 
        apiserver -h <"$API_FILE" >>"$LOG_FILE"
    fi
else 
    logit "run the api commands in '$API_FILE' manually with 'apiserver -h < $API_FILE'"
fi

exit 0
