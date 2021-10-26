############################################################
################# Anaconda Stress Test #####################
############################################################
#                                                          #
# Script that tests the project creation and deletion,     #
# and the session start and stop in Anaconda.              #
#                                                          #
# This stress test generates N projects, open 1 session    #
# per each project, and then stops the sessions and remove #
# the projects.                                            #
#                                                          #
# The output is stored in a CSV file where each column     #
# corresponds to:                                          #
# 1st column: project name                                 #
# 2nd column: time (s) for creating each project           #
# 3rd column: time (s) for opening each project session    #
# 4th column: time (s) for closing each project session    #
# 5th column: time (s) for removing each project           #
#                                                          #
############################################################

# Global vars
PROJECTNAME="stresstest"
OUTPUT_PATH="stress_output/$(date +'%Y%m%d%H').csv"
N=25
isfirst=0

# Append content to output csv
append_to_csv() {
    # $1 = content to be appended
    if [ ${isfirst} -eq 0 ]; then 
        echo -n $1 >> "${OUTPUT_PATH}"
        isfirst=1
    else
        echo -n "," >> "${OUTPUT_PATH}"
        echo -n $1 >> "${OUTPUT_PATH}"
    fi 
}

# Append new line to output csv
newline_to_csv() {
    echo "" >> ${OUTPUT_PATH}
    isfirst=0
}

# Create projects with sample code (if already exists, it will give error)
create_projects() {
    LOCAL_START="$(date +%s)"
    for i in $(seq 1 $N); do 
        ATOMIC_START="$(date +%s)"
        ae5 sample clone Attractors --name $PROJECTNAME$i
        ATOMIC_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
        echo "Create project ${PROJECTNAME}${i} took: ${ATOMIC_DURATION} s"
        append_to_csv $ATOMIC_DURATION
    done
    newline_to_csv
    LOCAL_DURATION=$[ $(date +%s) - ${LOCAL_START} ]
    echo "Running create projects took: ${LOCAL_DURATION} s"
}

# Remove projects created (if session is opened, it will give error)
delete_projects() {
    LOCAL_START="$(date +%s)"
    for i in $(seq 1 $N); do 
        ATOMIC_START="$(date +%s)"
        ae5 project delete $PROJECTNAME$i --yes
        ATOMIC_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
        echo "Delete project ${PROJECTNAME}${i} took: ${ATOMIC_DURATION} s"
        append_to_csv $ATOMIC_DURATION
    done
    newline_to_csv
    LOCAL_DURATION=$[ $(date +%s) - ${LOCAL_START} ]
    echo "Running delete projects took: ${LOCAL_DURATION} s"
}

# Open sessions
open_sessions() {
    LOCAL_START="$(date +%s)"
    for i in $(seq 1 $N); do 
        ATOMIC_START="$(date +%s)"
        ae5 session start $PROJECTNAME$i
        ATOMIC_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
        echo "Create session for ${PROJECTNAME}${i} took: ${ATOMIC_DURATION} s"
        append_to_csv $ATOMIC_DURATION
    done
    newline_to_csv
    LOCAL_DURATION=$[ $(date +%s) - ${LOCAL_START} ]
    echo "Running open sessions took: ${LOCAL_DURATION} s"
}

# Stop sessions
stop_sessions() {
    LOCAL_START="$(date +%s)"
    for i in $(seq 1 $N); do
        ATOMIC_START="$(date +%s)"
        ae5 session stop $PROJECTNAME$i --yes
        ATOMIC_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
        echo "Stop session for ${PROJECTNAME}${i} took: ${ATOMIC_DURATION} s"
        append_to_csv $ATOMIC_DURATION
    done
    newline_to_csv
    LOCAL_DURATION=$[ $(date +%s) - ${LOCAL_START} ]
    echo "Running stop sessions took: ${LOCAL_DURATION} s"
}

# Run all scripts
run_all() {
    START="$(date +%s)"
    create_projects
    open_sessions
    stop_sessions
    delete_projects
    DURATION=$[ $(date +%s) - ${START} ]
    echo "Running all scripts took: ${DURATION} s"
}

# Mock entire user process
user_simulation() {
    START="$(date +%s)"
    MOCK_PROJECT=$PROJECTNAME$1
    # Create project
    ATOMIC_START="$(date +%s)"
    ae5 sample clone Attractors --name $MOCK_PROJECT
    CREATE_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
    echo "Create project for ${MOCK_PROJECT} took: ${CREATE_DURATION} s"
    # Open session
    ATOMIC_START="$(date +%s)"
    ae5 session start $MOCK_PROJECT
    OPEN_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
    echo "Open session for ${MOCK_PROJECT} took: ${OPEN_DURATION} s"
    # Stop session
    ATOMIC_START="$(date +%s)"
    ae5 session stop $MOCK_PROJECT --yes
    STOP_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
    echo "Stop session for ${MOCK_PROJECT} took: ${STOP_DURATION} s"
    # Delete project
    ATOMIC_START="$(date +%s)"
    ae5 project delete $MOCK_PROJECT --yes
    DELETE_DURATION=$[ $(date +%s) - ${ATOMIC_START} ]
    echo "Delete project for ${MOCK_PROJECT} took: ${DELETE_DURATION} s"
    DURATION=$[ $(date +%s) - ${START} ]
    echo -e "${MOCK_PROJECT} took: ${DURATION} s\n\t- Create project: ${CREATE_DURATION} s\n\t- Open session: ${OPEN_DURATION} s\n\t- Stop session: ${STOP_DURATION} s\n\t- Delete project: ${DELETE_DURATION} s"
    echo "${MOCK_PROJECT},${CREATE_DURATION},${OPEN_DURATION},${STOP_DURATION},${DELETE_DURATION}" >> "${OUTPUT_PATH}"
}

# Run all async
run_all_async() {
    START="$(date +%s)"
    for i in $(seq 1 $N); do
        user_simulation $i &
    done
    wait
    DURATION=$[ $(date +%s) - ${START} ]
    echo "Running all scripts asynchronously took: ${DURATION} s"
}

# Monitor conections (firstly, open this in another terminal)
monitor() {
    kubectl get pods -o wide
}

#### MAIN ####

if [ $# -gt 0 ] && [ $1 -eq $1 ]; then
    N=$1
    echo "Number of projects set to ${N}"
else
    echo "No parameter specified or error while reading, so number of projects set to ${N}"
fi

# Display options
echo "
    1. Create projects (sync)
    2. Remove projects (sync)
    3. Open sessions (sync)
    4. Stop sessions (sync)
    90. Monitor
    98. Run all (sync)
    99. Run all (async)
"

# Read option chosen
read -p " Select an option: " option

# Create or clear output file
echo "project,create_project,open_session,stop_session,delete_project" > $OUTPUT_PATH
echo "Output file created: ${OUTPUT_PATH}"

# Option handling
case $option in
    1) create_projects;;
    2) delete_projects;;
    3) open_sessions;;
    4) stop_sessions;;
    5) create_projects_async;;
    6) delete_projects_async;;
    7) open_sessions_async;;
    8) stop_sessions_async;;
    90) monitor;;
    98) run_all;;
    99) run_all_async;;
    *) echo "Option not found";;
esac

# End of script
echo "Finished! Check the output here: ${OUTPUT_PATH}"
